#!/usr/bin/env python3
"""Build both disks from source, identified data, and temporary inputs.

Does not read the original images or invoke extraction. This incremental build
is not the final source/assets-only deliverable while temporary inputs remain.
"""
import argparse
from collections import Counter
import json
from pathlib import Path
import re
import subprocess

from disk_layout import ROOT, sha
from storage_encoding import transform


def contained_file(root, name):
    path = (root / name).resolve()
    if not path.is_relative_to(root.resolve()) or not path.is_file():
        raise ValueError(f"Missing or escaping input path: {name}")
    return path


def compose_image(disk, components):
    """Require complete, non-overlapping output coverage and bounded input slices."""
    if disk["size"] <= 0:
        raise ValueError("Image size must be positive")
    image = bytearray()
    for region in sorted(disk["regions"], key=lambda r: r["offset"]):
        offset, size, input_offset = (region[key] for key in ("offset", "size", "input_offset"))
        if offset != len(image) or size <= 0 or offset + size > disk["size"]:
            raise ValueError(f"Gap, overlap, or invalid size at image offset {offset}")
        raw = components[region["input"]]
        if input_offset < 0 or input_offset + size > len(raw):
            raise ValueError(f"Input slice outside component {region['input']}")
        image.extend(raw[input_offset:input_offset + size])
    if len(image) != disk["size"]:
        raise ValueError("Incomplete image coverage")
    return bytes(image)


def temporary_inputs(manifest):
    """Count declared temporary inputs and their mapped disk occurrences.

    An unused or zero-length temporary declaration still prevents the strict
    build: otherwise removing mappings could conceal unfinished input cleanup.
    This census is not a substitute for reviewing code/data evidence.
    """
    result = []
    for name, spec in manifest['components'].items():
        if spec['kind'] != 'temporary-unresolved':
            continue
        disks = Counter()
        for disk in manifest['disks']:
            for region in disk['regions']:
                if region['input'] == name:
                    disks[disk['id']] += region['size']
        result.append(dict(component=name, input_bytes=spec['size'],
                           mapped_disk_bytes=sum(disks.values()), disk_bytes=dict(disks)))
    return result


def build(manifest_path, output, *, no_temporary=False):
    manifest = json.loads(manifest_path.read_text())
    if manifest["schema_version"] != 1:
        raise ValueError("Unsupported reconstruction manifest version")
    temporary = temporary_inputs(manifest)
    if no_temporary and temporary:
        count = sum(item['mapped_disk_bytes'] for item in temporary)
        details = ', '.join(f"{item['component']} ({item['input_bytes']} input bytes, "
                            f"{item['mapped_disk_bytes']} mapped bytes)" for item in temporary)
        raise ValueError(f"Strict build refused: {len(temporary)} temporary input components "
                         f"remain, mapping {count} disk bytes: {details}")
    output.mkdir(parents=True, exist_ok=True)
    objects = output / "components"
    objects.mkdir(exist_ok=True)
    components = {}
    for name, spec in manifest["components"].items():
        if not re.fullmatch(r"[a-z0-9_]+", name):
            raise ValueError(f"Invalid component identifier: {name}")
        if spec["kind"] == "ca65-source":
            source = contained_file(ROOT, spec["source"])
            config = contained_file(ROOT, spec["config"])
            obj, binary = objects / (name + ".o"), objects / (name + ".bin")
            subprocess.run(["ca65", "-I", str(source.parent), "-o", str(obj),
                            "-l", str(objects / (name + ".lst")), str(source)], check=True)
            subprocess.run(["ld65", "-C", str(config), "-o", str(binary),
                            "-m", str(objects / (name + ".map")), str(obj)], check=True)
            data = binary.read_bytes()
            if 'storage_encoding' in spec:
                contained_file(ROOT, spec['storage_encoding']['evidence'])
                data = transform(data,spec['storage_encoding'])
                # Keep the normal component artifact in its mapped disk encoding.
                binary.with_suffix('.decoded.bin').write_bytes(binary.read_bytes())
                binary.write_bytes(data)
        elif spec["kind"] == "identified-data":
            if not spec.get('classification_evidence') or not spec.get('format'):
                raise ValueError('Identified data component lacks format or evidence')
            contained_file(ROOT, spec['classification_evidence'])
            data = contained_file(ROOT, spec['path']).read_bytes()
        elif spec["kind"] == "temporary-unresolved":
            data = contained_file(manifest_path.parent, spec["path"]).read_bytes()
        else:
            raise ValueError(f"Unsupported component kind: {spec['kind']}")
        if len(data) != spec["size"] or sha(data) != spec["sha256"]:
            raise ValueError(f"Component differs from its exact-byte baseline: {name}")
        components[name] = data
    coverage = Counter()
    receipts = []
    for disk in manifest["disks"]:
        filename = disk["filename"]
        if Path(filename).name != filename:
            raise ValueError("Output disk filename must be a basename")
        image = compose_image(disk, components)
        if sha(image) != disk["sha256"]:
            raise ValueError(f"Built image hash mismatch: {filename}")
        (output / filename).write_bytes(image)
        for region in disk["regions"]:
            coverage[manifest["components"][region["input"]]["kind"]] += region["size"]
        receipts.append({"filename": filename, "size": len(image), "sha256": sha(image)})
        print(f"Built {filename}: {len(image)} bytes, {sha(image)}")
    report = {"status": manifest["status"], "manifest_sha256": sha(manifest_path.read_bytes()),
              "disks": receipts, "coverage_bytes": dict(coverage),
              "temporary_inputs": temporary, "has_temporary_inputs": bool(temporary),
              "no_temporary_required": no_temporary}
    (output / "build-report.json").write_text(json.dumps(report, indent=2) + "\n")
    print("Coverage:", json.dumps(dict(coverage), sort_keys=True))
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", type=Path, default=ROOT / "reconstruction/manifest.json")
    parser.add_argument("--output", type=Path, default=ROOT / "build/disks")
    parser.add_argument("--no-temporary", action="store_true",
                        help="Reject all temporary input components before creating build outputs; "
                             "a necessary but insufficient final-completion check")
    args = parser.parse_args()
    try:
        build(args.manifest.resolve(), args.output.resolve(), no_temporary=args.no_temporary)
    except (ValueError, OSError) as error:
        parser.exit(1, str(error) + "\n")


if __name__ == "__main__":
    main()
