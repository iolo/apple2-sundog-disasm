#!/usr/bin/env python3
"""Lossless sector inventory and candidate Pascal-directory extraction.

This is a container round trip, not a source build. Uninterpreted bytes remain
explicitly unresolved. Directory views can overlap and are not allocation proof.
"""
import argparse
import hashlib
import json
from pathlib import Path
import struct

from verify_inputs import ROOT, main as verify_inputs

TRACK_SIZE = 4096
SECTOR_SIZE = 256
IMAGE_SIZE = 35 * TRACK_SIZE
DOS_TO_PHYSICAL = (0, 13, 11, 9, 7, 5, 3, 1, 14, 12, 10, 8, 6, 4, 2, 15)
BLOCK_ORDER = (0, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 15)
INPUTS = {"disk1": "sundog-disk1-game.dsk", "disk2": "sundog-disk2-util.dsk"}


def sha(data):
    return hashlib.sha256(data).hexdigest()


def logical_sector_offset(sector):
    if not 0 <= sector < 560:
        raise ValueError(f"Logical sector out of range: {sector}")
    return sector // 16 * TRACK_SIZE + BLOCK_ORDER[sector % 16] * SECTOR_SIZE


def block_bytes(image, start, end):
    if len(image) != IMAGE_SIZE or not 0 <= start <= end <= 280:
        raise ValueError("Invalid block extent or image size")
    return b"".join(image[offset:offset + SECTOR_SIZE]
                    for sector in range(start * 2, end * 2)
                    for offset in [logical_sector_offset(sector)])


def directory(image, block):
    data = block_bytes(image, block, block + 1)
    start, end, kind = struct.unpack_from("<HHH", data)
    name_len = data[6]
    total, count = struct.unpack_from("<HH", data, 14)
    if not (start == 0 and end == 3 and kind == 0 and 1 <= name_len <= 7
            and total == 280 and 0 < count <= 18):
        raise ValueError(f"Not a supported directory header in block {block}")
    name = data[7:7 + name_len].decode("ascii")
    files = []
    previous_end = end
    for index in range(count):
        position = (index + 1) * 26
        first, last, file_type = struct.unpack_from("<HHH", data, position)
        length = data[position + 6]
        remaining, date = struct.unpack_from("<HH", data, position + 22)
        if not (previous_end <= first < last <= total and 1 <= length <= 15
                and 1 <= remaining <= 512):
            raise ValueError(f"Invalid directory extent/name/length in block {block}")
        filename = data[position + 7:position + 7 + length].decode("ascii")
        if not all(c.isupper() or c.isdigit() or c in "._" for c in filename):
            raise ValueError(f"Unsupported Pascal filename: {filename!r}")
        size = (last - first - 1) * 512 + remaining
        files.append({"name": filename, "start_block": first, "end_block": last,
                      "file_type": file_type, "size": size, "date_raw": date,
                      "directory_entry_offset": position})
        previous_end = last
    return {"logical_block": block, "image_offsets": [logical_sector_offset(block * 2 + i) for i in [0, 1]],
            "volume": name, "total_blocks": total, "files": files,
            "status": "directory-format verified; runtime selection not yet traced"}


def inspect_image(image, disk_id):
    if len(image) != IMAGE_SIZE:
        raise ValueError(f"Expected {IMAGE_SIZE} bytes")
    candidates = []
    for block in range(280):
        try:
            candidates.append(directory(image, block))
        except (ValueError, UnicodeError):
            pass
    sectors = []
    for track in range(35):
        for index in range(16):
            offset = track * TRACK_SIZE + index * SECTOR_SIZE
            logical_sector = track * 16 + BLOCK_ORDER.index(index)
            contents = image[offset:offset + SECTOR_SIZE]
            classification = "unresolved"
            if track == 0 and index == 0:
                classification = "boot sector: native 6502 and data"
            elif disk_id == "disk1" and track == 0 and index in [14, 13]:
                classification = "boot continuation: native 6502 and data"
            elif any(logical_sector // 2 == d["logical_block"] for d in candidates):
                classification = "Pascal directory view and trailing bytes"
            elif not any(contents):
                classification = "zero-filled; allocation/meaning unresolved"
            views = []
            for candidate in candidates:
                for entry in candidate["files"]:
                    if entry["start_block"] <= logical_sector // 2 < entry["end_block"]:
                        views.append(f"directory-{candidate['logical_block']:03d}/{entry['name']}")
            sectors.append({"image_offset": offset, "track": track, "image_sector_index": index,
                            "physical_sector": DOS_TO_PHYSICAL[index],
                            "logical_block": logical_sector // 2, "block_half": logical_sector % 2,
                            "sha256": sha(contents), "classification": classification,
                            "directory_views": views})
    return {"id": disk_id, "original": INPUTS[disk_id], "size": len(image), "sha256": sha(image),
            "directories": candidates, "sectors": sectors}


def unpack(output):
    verify_inputs()
    output = output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    manifest = {"schema_version": 1, "purpose": "baseline container reconstruction, not a source build",
                "sector_size": SECTOR_SIZE, "track_size": TRACK_SIZE,
                "sector_order": "DOS image order; logical blocks use Pascal/ProDOS order",
                "disks": []}
    for disk_id, filename in INPUTS.items():
        image = (ROOT / filename).read_bytes()
        disk = inspect_image(image, disk_id)
        tracks = output / disk_id / "tracks"
        tracks.mkdir(parents=True)
        disk["tracks"] = []
        for track in range(35):
            offset = track * TRACK_SIZE
            data = image[offset:offset + TRACK_SIZE]
            path = tracks / f"{track:02d}.bin"
            path.write_bytes(data)
            disk["tracks"].append({"offset": offset, "size": TRACK_SIZE, "sha256": sha(data),
                                   "path": str(path.relative_to(output))})
        for candidate in disk["directories"]:
            folder = output / disk_id / f"directory-{candidate['logical_block']:03d}"
            folder.mkdir()
            (folder / "directory.bin").write_bytes(block_bytes(image, candidate["logical_block"], candidate["logical_block"] + 1))
            for entry in candidate["files"]:
                data = block_bytes(image, entry["start_block"], entry["end_block"])
                path = folder / entry["name"]
                path.write_bytes(data[:entry["size"]])
                entry["path"] = str(path.relative_to(output))
                entry["sha256"] = sha(data[:entry["size"]])
        manifest["disks"].append(disk)
    (output / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    print(f"Inventoried {len(manifest['disks']) * IMAGE_SIZE} bytes, 1120 sectors, 70 tracks: {output}")
    for disk in manifest["disks"]:
        print(disk["id"], "directory candidates:", [d["logical_block"] for d in disk["directories"]])


def reconstruct(manifest_dir, disk):
    """Require each track exactly once, intact; refuse traversal and overlap."""
    root = manifest_dir.resolve()
    records = sorted(disk["tracks"], key=lambda item: item["offset"])
    if len(records) != 35 or [item["offset"] for item in records] != list(range(0, IMAGE_SIZE, TRACK_SIZE)):
        raise ValueError("Track records have gaps, overlap, or wrong count")
    parts = []
    for record in records:
        path = (root / record["path"]).resolve()
        if not path.is_relative_to(root):
            raise ValueError("Track path escapes extraction directory")
        data = path.read_bytes()
        if record["size"] != TRACK_SIZE or len(data) != TRACK_SIZE or sha(data) != record["sha256"]:
            raise ValueError(f"Track data does not match inventory: {path}")
        parts.append(data)
    image = b"".join(parts)
    if disk["size"] != IMAGE_SIZE or sha(image) != disk["sha256"]:
        raise ValueError("Reconstructed image does not match baseline")
    return image


def pack(source, output):
    manifest = json.loads((source / "manifest.json").read_text())
    if manifest["schema_version"] != 1 or [d["id"] for d in manifest["disks"]] != list(INPUTS):
        raise ValueError("Unexpected extraction manifest")
    images = {disk["id"]: reconstruct(source, disk) for disk in manifest["disks"]}
    # Exclusive creation ensures neither originals nor previous artifacts get overwritten.
    output.mkdir(parents=True, exist_ok=False)
    for disk_id, data in images.items():
        path = output / INPUTS[disk_id]
        path.write_bytes(data)
        print(f"Repacked {path}: {sha(data)}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="action", required=True)
    unpack_parser = sub.add_parser("unpack")
    unpack_parser.add_argument("output", type=Path)
    pack_parser = sub.add_parser("pack")
    pack_parser.add_argument("source", type=Path)
    pack_parser.add_argument("output", type=Path)
    args = parser.parse_args()
    if args.action == "unpack":
        unpack(args.output)
    else:
        pack(args.source, args.output)


if __name__ == "__main__":
    main()
