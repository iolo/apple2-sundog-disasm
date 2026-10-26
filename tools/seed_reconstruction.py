#!/usr/bin/env python3
"""One-time extraction of explicitly temporary inputs for the incremental build.

The normal build never runs this script. Replace temporary ranges with source
or classified assets as reconstruction proceeds; they do not satisfy the PRD.
"""
import argparse
import json
from pathlib import Path

from disk_layout import ROOT, INPUTS, block_bytes, logical_sector_offset, sha
from verify_inputs import main as verify_inputs


def seed(output):
    verify_inputs()
    output.mkdir(parents=True, exist_ok=False)
    (output / "temporary").mkdir()
    images = {disk: (ROOT / filename).read_bytes() for disk, filename in INPUTS.items()}
    bootstrap = block_bytes(images["disk1"], 0, 2)[:768]
    system_entry = block_bytes(images["disk1"], 252, 253)[:36]
    components = {
        "bootstrap": {"kind": "ca65-source", "source": "src/native/bootstrap.s",
                      "config": "src/native/bootstrap.cfg", "size": len(bootstrap),
                      "sha256": sha(bootstrap)},
        "system_entry": {"kind": "ca65-source", "source": "src/pcode/runtime_entry.s",
                         "config": "src/pcode/runtime_entry.cfg", "size": len(system_entry),
                         "sha256": sha(system_entry)},
    }
    disks = []
    for disk, image in images.items():
        compiled = []
        if disk == "disk1":
            compiled = [{"offset": logical_sector_offset(sector), "size": 256,
                         "input": "bootstrap", "input_offset": sector * 256}
                        for sector in range(3)]
            compiled.append({"offset": logical_sector_offset(504), "size": 36,
                             "input": "system_entry", "input_offset": 0})
        compiled.sort(key=lambda item: item["offset"])
        remaining = bytearray()
        records = []
        cursor = 0
        input_id = disk + "_unresolved"
        # Sentinel closes the final gap; it is never emitted as a region.
        for record in compiled + [{"offset": len(image), "size": 0}]:
            if record["offset"] > cursor:
                records.append({"offset": cursor, "size": record["offset"] - cursor,
                                "input": input_id, "input_offset": len(remaining)})
                remaining.extend(image[cursor:record["offset"]])
            if record["size"]:
                records.append(record)
            cursor = record["offset"] + record["size"]
        path = f"temporary/{disk}-unresolved.bin"
        (output / path).write_bytes(remaining)
        components[input_id] = {"kind": "temporary-unresolved", "path": path,
                                "size": len(remaining), "sha256": sha(remaining),
                                "description": "Unreconstructed code, assets, metadata, and unused bytes; not accepted final inputs"}
        disks.append({"id": disk, "filename": INPUTS[disk], "size": len(image),
                      "sha256": sha(image), "regions": records})
    manifest = {"schema_version": 1,
                "status": "incremental proof; temporary executable bytes remain",
                "components": components, "disks": disks}
    (output / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    print(f"Created incremental inputs in {output}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path, help="New directory; existing directories are refused")
    seed(parser.parse_args().output.resolve())


if __name__ == "__main__":
    main()
