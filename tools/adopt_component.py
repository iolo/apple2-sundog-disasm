#!/usr/bin/env python3
"""Replace temporary disk ranges with a verified newly assembled component.

Maintenance tool, not a normal build dependency. A recipe supplies name, source,
config, and mappings with disk/offset/size/input_offset. Baseline rebuilt disks
must match the current manifest. No original disk image is read.
"""
import argparse
import copy
import json
from pathlib import Path
import re
import subprocess

from build_disks import contained_file
from disk_layout import ROOT, sha


def replacement_plan(manifest, images, recipe, binary):
    """Validate everything before returning new metadata and remainder bytes."""
    name = recipe["name"]
    if not re.fullmatch(r"[a-z0-9_]+", name) or name in manifest["components"]:
        raise ValueError("Component name is invalid or already adopted")
    if not binary or not recipe["mappings"]:
        raise ValueError("Component and mappings must be nonempty")
    result = copy.deepcopy(manifest)
    disks = {disk["id"]: disk for disk in result["disks"]}
    for disk_id, disk in disks.items():
        data = images[disk_id]
        if len(data) != disk["size"] or sha(data) != disk["sha256"]:
            raise ValueError(f"Baseline image differs from manifest: {disk_id}")
    groups = {}
    covered = bytearray(len(binary))
    for mapping in recipe["mappings"]:
        disk = disks[mapping["disk"]]
        offset, size, source = (mapping[key] for key in ("offset", "size", "input_offset"))
        if size <= 0 or offset < 0 or offset + size > disk["size"]:
            raise ValueError("Output mapping exceeds image bounds")
        if source < 0 or source + size > len(binary):
            raise ValueError("Input mapping exceeds component bounds")
        owners = [r for r in disk["regions"] if r["offset"] <= offset
                  and offset + size <= r["offset"] + r["size"]]
        if len(owners) != 1 or result["components"][owners[0]["input"]]["kind"] != "temporary-unresolved":
            raise ValueError("Replacement must lie wholly within a temporary region")
        if images[disk["id"]][offset:offset + size] != binary[source:source + size]:
            raise ValueError(f"Source bytes differ at {disk['id']} image offset ${offset:05X}")
        covered[source:source + size] = bytes([1]) * size
        groups.setdefault(disk["id"], []).append({"offset": offset, "size": size,
                                                  "input": name, "input_offset": source})
    if not all(covered):
        raise ValueError("Not every assembled byte has an output mapping")
    files = {}
    for disk_id, additions in groups.items():
        disk = disks[disk_id]
        temporary_ids = {r["input"] for r in disk["regions"]
                         if result["components"][r["input"]]["kind"] == "temporary-unresolved"}
        if len(temporary_ids) != 1:
            raise ValueError("This maintenance tool requires one temporary component per affected disk")
        temporary_id = temporary_ids.pop()
        keep = [r for r in disk["regions"] if r["input"] != temporary_id] + additions
        keep.sort(key=lambda r: r["offset"])
        remainder, regions, cursor = bytearray(), [], 0
        for region in keep + [{"offset": disk["size"], "size": 0}]:
            if region["offset"] < cursor:
                raise ValueError("Replacement output ranges overlap")
            if region["offset"] > cursor:
                regions.append({"offset": cursor, "size": region["offset"] - cursor,
                                "input": temporary_id, "input_offset": len(remainder)})
                remainder.extend(images[disk_id][cursor:region["offset"]])
            if region["size"]:
                regions.append(region)
            cursor = region["offset"] + region["size"]
        disk["regions"] = regions
        spec = result["components"][temporary_id]
        if spec["path"] in files:
            raise ValueError("Temporary files must not be shared between disks")
        files[spec["path"]] = bytes(remainder)
        spec.update(size=len(remainder), sha256=sha(remainder))
    result["components"][name] = {"kind": "ca65-source", "source": recipe["source"],
                                   "config": recipe["config"], "size": len(binary), "sha256": sha(binary)}
    return result, files


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("recipe", type=Path)
    parser.add_argument("--manifest", type=Path, default=ROOT / "reconstruction/manifest.json")
    parser.add_argument("--baseline", type=Path, default=ROOT / "build/disks")
    args = parser.parse_args()
    recipe, manifest = (json.loads(path.read_text()) for path in (args.recipe, args.manifest))
    if not re.fullmatch(r"[a-z0-9_]+", recipe["name"]):
        raise ValueError("Invalid component name")
    output = ROOT / "build/adoption"
    output.mkdir(parents=True, exist_ok=True)
    source = contained_file(ROOT, recipe["source"])
    config = contained_file(ROOT, recipe["config"])
    obj, binary_file = (output / (recipe["name"] + suffix) for suffix in (".o", ".bin"))
    subprocess.run(["ca65", "-I", str(source.parent), "-o", str(obj), str(source)], check=True)
    subprocess.run(["ld65", "-C", str(config), "-o", str(binary_file), str(obj)], check=True)
    images = {d["id"]: contained_file(args.baseline, d["filename"]).read_bytes() for d in manifest["disks"]}
    planned, replacements = replacement_plan(manifest, images, recipe, binary_file.read_bytes())
    destinations = {}
    for path, data in replacements.items():
        target = contained_file(args.manifest.parent, path)
        old_specs = [s for s in manifest["components"].values() if s.get("path") == path]
        if len(old_specs) != 1 or sha(target.read_bytes()) != old_specs[0]["sha256"]:
            raise ValueError(f"Temporary input changed before adoption: {path}")
        destinations[target] = data
    for path, data in destinations.items():
        path.write_bytes(data)
    args.manifest.write_text(json.dumps(planned, indent=2) + "\n")
    print(f"Adopted {recipe['name']}: {len(binary_file.read_bytes())} source-built bytes")


if __name__ == "__main__":
    main()
