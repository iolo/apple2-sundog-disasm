#!/usr/bin/env python3
"""Compare rebuilt images to originals, locating the first differing byte."""
import argparse
import json
from pathlib import Path

from disk_layout import ROOT, BLOCK_ORDER, DOS_TO_PHYSICAL, sha
from verify_inputs import main as verify_inputs


def difference(expected, actual):
    for offset, (left, right) in enumerate(zip(expected, actual)):
        if left != right:
            return offset
    return min(len(expected), len(actual)) if len(expected) != len(actual) else None


def describe_offset(disk, offset):
    if offset >= disk["size"]:
        return "past expected end of image"
    track, within_track = divmod(offset, 4096)
    image_sector, byte = divmod(within_track, 256)
    logical_sector = track * 16 + BLOCK_ORDER.index(image_sector)
    region = next((r for r in disk["regions"] if r["offset"] <= offset < r["offset"] + r["size"]), None)
    component = region["input"] if region else "unmapped"
    return (f"track {track}, image sector {image_sector}, physical sector {DOS_TO_PHYSICAL[image_sector]}, "
            f"logical block {logical_sector // 2}, half {logical_sector % 2}, byte {byte}; component {component}")


def verify(image_dir, manifest_path):
    verify_inputs()
    manifest = json.loads(manifest_path.read_text())
    errors = []
    for disk in manifest["disks"]:
        expected = (ROOT / disk["filename"]).read_bytes()
        actual = (image_dir / disk["filename"]).read_bytes()
        offset = difference(expected, actual)
        if offset is not None:
            left = f"${expected[offset]:02X}" if offset < len(expected) else "EOF"
            right = f"${actual[offset]:02X}" if offset < len(actual) else "EOF"
            errors.append(f"{disk['filename']}: first difference at ${offset:05X} ({offset}), "
                          f"expected {left}, got {right}; {describe_offset(disk, offset)}")
        elif len(actual) != disk["size"] or sha(actual) != disk["sha256"]:
            errors.append(f"{disk['filename']}: baseline manifest disagrees with originals")
        else:
            print(f"Exact match: {disk['filename']} ({len(actual)} bytes, {sha(actual)})")
    if errors:
        raise ValueError("\n".join(errors))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("image_dir", type=Path, nargs="?", default=ROOT / "build/disks")
    parser.add_argument("--manifest", type=Path, default=ROOT / "reconstruction/manifest.json")
    args = parser.parse_args()
    try:
        verify(args.image_dir, args.manifest)
    except (ValueError, OSError) as error:
        parser.exit(1, str(error) + "\n")


if __name__ == "__main__":
    main()
