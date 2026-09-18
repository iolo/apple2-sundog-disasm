#!/usr/bin/env python3
"""Recheck recorded emulator memory against original disk bytes (not a build)."""
import json

from disk_layout import ROOT, INPUTS, block_bytes, sha
from verify_inputs import main as verify_inputs


def main():
    verify_inputs()
    evidence = json.loads((ROOT / "docs/reference/runtime-init.json").read_text())
    images = {key: (ROOT / name).read_bytes() for key, name in INPUTS.items()}
    checked = 0
    for observation in evidence["observations"]:
        if "source" not in observation:
            continue
        capture, source = observation["capture"], observation["source"]
        actual = bytes.fromhex(capture["hex"])
        if len(actual) != capture["length"] or sha(actual) != capture["sha256"]:
            raise ValueError(f"Corrupt capture: {observation['id']}")
        start, skip = source["start_block"], source["byte_offset"]
        end = start + (skip + len(actual) + 511) // 512
        expected = block_bytes(images[source["disk"]], start, end)[skip:skip + len(actual)]
        if actual != expected:
            raise ValueError(f"Disk/memory mismatch: {observation['id']}")
        checked += len(actual)
        print(f"OK {observation['id']}: {len(actual)} bytes at ${capture['address']:04X}")
    print(f"Verified {checked} captured bytes against their disk sources")
    trace = json.loads((ROOT / "docs/reference/pcode-entry-trace.json").read_text())
    for sample in trace["observations"]:
        source = sample["source"]
        offset = sample["pcode_address"] - source["load_address"]
        start = source["start_block"]
        actual = bytes(sample["bytes"])
        if offset < 0:
            raise ValueError("Trace address precedes its segment load address")
        expected = block_bytes(images[source["disk"]], start,
                               start + (offset + len(actual) + 511) // 512)[offset:offset + len(actual)]
        if actual != expected or sample["stop"]["PC"] != 0xD293:
            raise ValueError(f"Invalid p-code trace sample at ${sample['pcode_address']:04X}")
    print(f"Verified {len(trace['observations'])} p-code dispatch snapshots against disk bytes")


if __name__ == "__main__":
    main()
