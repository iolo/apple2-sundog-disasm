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
    overlays = json.loads((ROOT / "docs/reference/overlay-loads.json").read_text())
    for event in overlays["loads"]:
        captured = bytes.fromhex(event["capture_hex"])
        table = bytes.fromhex(event["segment_table_hex"])
        zero_page = bytes.fromhex(event["zero_page_50_hex"])
        block = int.from_bytes(table[2:4], "little")
        length = int.from_bytes(table[4:6], "little")
        destination = int.from_bytes(zero_page[12:14], "little") - length
        expected = block_bytes(images[event["disk"]], block, block + (length + 511) // 512)[:length]
        if (block != event["block"] or destination != event["destination"]
                or length != event["length"] or captured != expected
                or event["entry_state"]["PC"] != 0xE46D
                or event["return_state"]["PC"] != 0xE4DE
                or event["return_state"]["X"] != 0):
            raise ValueError(f"Invalid overlay load: segment {event['segment']}")
    entry = overlays["startup_entry"]
    zp = bytes.fromhex(entry["zero_page_50_hex"])
    if (int.from_bytes(zp[8:10], "little") != entry["pcode_address"]
            or entry["pcode_address"] != entry["segment_load_address"] + entry["entry_offset"]
            or int.from_bytes(zp[4:6], "little") != entry["segment_load_address"] + entry["attribute_offset"]):
        raise ValueError("Startup entry/attribute pointers disagree with the segment")
    expected = block_bytes(images[entry["disk"]], entry["block"], entry["block"] + 2)
    captured = bytes.fromhex(entry["capture_hex"])
    if captured != expected[entry["entry_offset"]:entry["entry_offset"] + len(captured)]:
        raise ValueError("Startup entry bytes differ from disk")
    print(f"Verified {len(overlays['loads'])} whole overlay loads and SYSTEM.STARTUP entry")


if __name__ == "__main__":
    main()
