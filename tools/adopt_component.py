#!/usr/bin/env python3
"""Replace temporary disk ranges with verified source or classified data.

Maintenance tool, not a normal build dependency. A recipe supplies name, source,
config (or data/format/classification), and disk byte mappings. Baseline rebuilt disks
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
from storage_encoding import transform, validate_encoding


def replacement_plan(manifest, images, recipe, binary):
    """Validate everything before returning new metadata and remainder bytes."""
    name = recipe["name"]
    if not re.fullmatch(r"[a-z0-9_]+", name) or name in manifest["components"]:
        raise ValueError("Component name is invalid or already adopted")
    if not binary or not recipe["mappings"]:
        raise ValueError("Component and mappings must be nonempty")
    if 'data' in recipe:
        if 'storage_encoding' in recipe:
            raise ValueError('Storage encoding is reserved for disassembled source')
        if 'source' in recipe or 'config' in recipe or not recipe.get('classification') or not recipe.get('format'):
            raise ValueError('Identified data needs format/evidence and cannot also be source')
        new_spec = dict(kind='identified-data', path=recipe['data'], format=recipe['format'],
                        classification_evidence=recipe['classification'])
    else:
        new_spec = dict(kind='ca65-source', source=recipe['source'], config=recipe['config'])
        if 'storage_encoding' in recipe:
            validate_encoding(recipe['storage_encoding'])
            new_spec['storage_encoding'] = copy.deepcopy(recipe['storage_encoding'])
    new_spec.update(size=len(binary), sha256=sha(binary))
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
    # Complete disassembly may need surrounding bytes already reconstructed by
    # another source component. Verify those bytes and their exact owner without
    # replacing their mappings. Every new source byte still needs disk evidence.
    if recipe.get('context_mappings'):
        if 'data' in recipe or 'storage_encoding' in recipe or not recipe.get('context_evidence'):
            raise ValueError('Context mappings require ordinary source and review evidence')
        new_spec['classification_evidence'] = recipe['context_evidence']
        for mapping in recipe['context_mappings']:
            disk = disks[mapping['disk']]
            offset,size,source = (mapping[k] for k in ('offset','size','input_offset'))
            if (size <= 0 or offset < 0 or offset+size > disk['size']
                    or source < 0 or source+size > len(binary)):
                raise ValueError('Context mapping exceeds input/output bounds')
            owners = [r for r in disk['regions'] if r['offset'] <= offset
                      and offset+size <= r['offset']+r['size']]
            if (len(owners) != 1 or owners[0]['input'] != mapping['existing_input']
                    or result['components'][owners[0]['input']]['kind'] != 'ca65-source'
                    or 'storage_encoding' in result['components'][owners[0]['input']]
                    or owners[0]['input_offset']+offset-owners[0]['offset'] != mapping['existing_input_offset']):
                raise ValueError('Context must match its existing source owner')
            if (images[disk['id']][offset:offset+size] != binary[source:source+size]
                    or any(covered[source:source+size])):
                raise ValueError('Context bytes differ or duplicate source coverage')
            covered[source:source+size] = bytes([1])*size
    if not all(covered):
        raise ValueError("Not every assembled byte has an output mapping")
    result["components"][name] = new_spec
    return replace_temporary_regions(result, images, groups)


def replace_temporary_regions(result, images, groups):
    """Apply validated, possibly mixed-component additions to a copied manifest."""
    disks = {disk['id']: disk for disk in result['disks']}
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
    return result, files


def source_copy_plan(manifest, images, mappings, binaries):
    """Reuse existing assembled source ranges after independent copy review.

    Complete source components already have their original disk mappings. New
    copies may select instruction/data subranges, including clipped boundaries.
    This routine verifies bytes/ownership; the caller must retain the source
    classification and copy-provenance audit.
    """
    if not mappings:
        raise ValueError('No source copies selected')
    result = copy.deepcopy(manifest)
    disks = {d['id']:d for d in result['disks']}
    for disk_id,disk in disks.items():
        if len(images[disk_id]) != disk['size'] or sha(images[disk_id]) != disk['sha256']:
            raise ValueError('Stale copy baseline')
    groups = {}
    for mapping in mappings:
        name = mapping['input']
        spec = result['components'][name]
        data = binaries[name]
        if spec['kind'] != 'ca65-source' or len(data) != spec['size'] or sha(data) != spec['sha256']:
            raise ValueError('Copy source is not the verified assembled component')
        if not any(r['input']==name for d in disks.values() for r in d['regions']):
            raise ValueError('Copy source has no existing disk ownership')
        disk = disks[mapping['disk']]
        offset,size,start = (mapping[k] for k in ('offset','size','input_offset'))
        if size <= 0 or offset < 0 or offset+size > disk['size'] or start < 0 or start+size > len(data):
            raise ValueError('Source copy exceeds input/output bounds')
        owners = [r for r in disk['regions'] if r['offset'] <= offset and offset+size <= r['offset']+r['size']]
        if len(owners) != 1 or result['components'][owners[0]['input']]['kind'] != 'temporary-unresolved':
            raise ValueError('Source copy must replace only temporary bytes')
        if images[disk['id']][offset:offset+size] != data[start:start+size]:
            raise ValueError('Source copy bytes differ')
        groups.setdefault(disk['id'],[]).append(dict(offset=offset,size=size,input=name,input_offset=start))
    return replace_temporary_regions(result,images,groups)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("recipe", type=Path)
    parser.add_argument("--manifest", type=Path, default=ROOT / "reconstruction/manifest.json")
    parser.add_argument("--baseline", type=Path, default=ROOT / "build/disks")
    args = parser.parse_args()
    recipe, manifest = (json.loads(path.read_text()) for path in (args.recipe, args.manifest))
    if recipe.get('context_mappings'):
        contained_file(ROOT,recipe['context_evidence'])
    if not re.fullmatch(r"[a-z0-9_]+", recipe["name"]):
        raise ValueError("Invalid component name")
    output = ROOT / "build/adoption"
    output.mkdir(parents=True, exist_ok=True)
    if 'data' in recipe:
        contained_file(ROOT, recipe['classification'])
        binary_file = contained_file(ROOT, recipe['data'])
    else:
        source = contained_file(ROOT, recipe["source"])
        config = contained_file(ROOT, recipe["config"])
        obj, binary_file = (output / (recipe["name"] + suffix) for suffix in (".o", ".bin"))
        subprocess.run(["ca65", "-I", str(source.parent), "-o", str(obj), str(source)], check=True)
        subprocess.run(["ld65", "-C", str(config), "-o", str(binary_file), str(obj)], check=True)
    images = {d["id"]: contained_file(args.baseline, d["filename"]).read_bytes() for d in manifest["disks"]}
    binary = binary_file.read_bytes()
    if 'storage_encoding' in recipe:
        if 'data' in recipe:
            raise ValueError('Cannot encode a binary data asset as executable source')
        contained_file(ROOT,recipe['storage_encoding']['evidence'])
        binary = transform(binary,recipe['storage_encoding'])
    planned, replacements = replacement_plan(manifest, images, recipe, binary)
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
    print(f"Adopted {recipe['name']}: {len(binary_file.read_bytes())} verified bytes")


if __name__ == "__main__":
    main()
