#!/usr/bin/env python3
"""Recheck recorded emulator memory against original disk bytes (not a build)."""
import json

from disk_layout import ROOT, INPUTS, block_bytes, sha
from hgr_asset import row_offset
from glyph_asset import pack_rows
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
    raw = json.loads((ROOT / 'docs/reference/raw-screen-runtime.json').read_text())['observations']
    entry, exit_state = raw['rawEntryFirst']['state'], raw['rawScreenInitExit']['state']
    loaded, tables = raw['rawScreenInitCapture']['value'], raw['rawScreenTables']['value']
    expected_tables = (bytes((0x1800+y*20) & 255 for y in range(96)) +
                       bytes((0x1800+y*20) >> 8 for y in range(96)) +
                       bytes(row_offset(y) & 255 for y in range(192)))
    if (entry['PC'] != 0x0F40 or exit_state['PC'] != 0x0FA8
            or exit_state['S'] != entry['S']+2
            or loaded['address'] != 0x0E80 or loaded['length'] != 512
            or bytes.fromhex(loaded['hex']) != block_bytes(images['disk1'], 2, 3)
            or tables['address'] != 0x0D00 or tables['length'] != 384
            or bytes.fromhex(tables['hex']) != expected_tables):
        raise ValueError('Raw screen initializer capture or generated tables disagree')
    print('Verified raw screen initializer: 512 loaded bytes and 384 generated address bytes')
    font_capture = json.loads((ROOT / 'docs/reference/shared-font-runtime.json').read_text())['capture']['value']
    font = (ROOT / 'assets/font/font.bin').read_bytes()
    rows = json.loads((ROOT / 'assets/font/rows.json').read_text())
    if (font_capture['address'] != 0x1000 or font_capture['length'] != 1024
            or bytes.fromhex(font_capture['hex']) != font or pack_rows(rows) != font
            or any(block_bytes(image, 3, 5) != font for image in images.values())):
        raise ValueError('Shared font capture, listing, or disk copy differs')
    print('Verified shared font: 1024 live bytes, both disk copies, and lossless row listing')


if __name__ == "__main__":
    main()
