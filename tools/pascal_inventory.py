#!/usr/bin/env python3
"""Inventory Apple Pascal segment headers and procedure boundaries.

This is a structural inventory, not an instruction disassembler. Candidate
headers and failed procedure dictionaries remain visible in the output. Native
procedure relocation tables and p-code instruction dialects are not decoded.
"""
import argparse
from collections import Counter
import json
from pathlib import Path
import struct

from disk_layout import ROOT, INPUTS, block_bytes, logical_sector_offset, sha
from verify_inputs import main as verify_inputs


def word(data, offset):
    if not 0 <= offset <= len(data) - 2:
        raise ValueError(f"Word outside buffer at {offset}")
    return struct.unpack_from("<H", data, offset)[0]


def parse_header(data):
    """Accept the observed version-5 format, including stripped names.

    Structural acceptance is deliberately weaker than executable acceptance.
    In particular, block 84 has plausible metadata but no valid local segment.
    """
    if len(data) != 512:
        raise ValueError("A segment header must occupy exactly one block")
    entries = []
    for slot in range(16):
        relative_block, length = word(data, slot * 4), word(data, slot * 4 + 2)
        kind, text, info = (word(data, base + slot * 2) for base in (192, 224, 256))
        if not any((relative_block, length, kind, text, info)):
            continue
        version, machine = info >> 13, (info >> 8) & 15
        if (kind > 7 or text >= 280 or relative_block >= 280 or length % 2
                or (relative_block and not length)
                or (info and (version != 5 or machine not in (2, 7)))
                or (not relative_block and length and kind != 7)):
            raise ValueError(f"Unsupported segment metadata in slot {slot}")
        entries.append({
            "slot": slot, "relative_block": relative_block, "length": length,
            "name_hex": data[64 + slot * 8:72 + slot * 8].hex(),
            "kind": kind, "text_block": text, "info_word": info,
            "segment_number": info & 255, "machine_type": machine,
            "segment_version": version,
        })
    if not any(entry["length"] for entry in entries):
        raise ValueError("Empty segment header")
    return entries


def procedure_attributes(data, offset, number):
    """Offsets are relative to this data buffer, even for a split procedure."""
    if offset % 2 or not 2 <= offset <= len(data) - 2:
        raise ValueError("Attribute pointer is unaligned or outside the buffer")
    marker = data[offset]
    if marker not in (0, number):
        raise ValueError(f"Procedure number mismatch: expected {number}, found {marker}")
    entry = offset - 2 - word(data, offset - 2)
    if not 0 <= entry < offset - 2:
        raise ValueError("Entry pointer is outside the procedure buffer")
    result = {"attribute_offset": offset, "entry_offset": entry,
              "representation": "native-6502" if marker == 0 else "p-code",
              "lexical_level": struct.unpack_from("b", data, offset + 1)[0]}
    if marker:
        if offset < 8:
            raise ValueError("Truncated p-code attributes")
        exit_offset = offset - 4 - word(data, offset - 4)
        if not entry <= exit_offset < offset - 8:
            raise ValueError("Exit pointer is outside the p-code body")
        result.update(exit_offset=exit_offset, parameter_bytes=word(data, offset - 6),
                      local_bytes=word(data, offset - 8), attribute_start=offset - 8)
    return result


def procedure_dictionary(data, segment_number, *, load_address=None, fragments=()):
    """Keep bad references visible; resolve cross-part pointers only from traces.

    A fragment is (id, load_address, bytes). In the observed SYSTEM.PASCAL,
    procedure 38's unsigned backwards displacement crosses from LC to main RAM.
    """
    if len(data) < 4 or len(data) % 2:
        raise ValueError("Segment length must be even and at least four")
    if data[-2] != segment_number:
        raise ValueError(f"Segment trailer mismatch: expected {segment_number}, found {data[-2]}")
    count = data[-1]
    table_start = len(data) - 2 - 2 * count
    if not count or table_start < 0:
        raise ValueError("Procedure count exceeds segment bounds or is zero")
    procedures = []
    for number in range(1, count + 1):
        pointer = len(data) - 2 - 2 * number
        backward = word(data, pointer)
        offset = pointer - backward
        proc = {"number": number, "dictionary_offset": pointer,
                "backward_offset": backward}
        try:
            if not backward:
                raise ValueError("Empty dictionary entry")
            if 0 <= offset < table_start - 1:
                proc.update(procedure_attributes(data[:table_start], offset, number))
                proc["storage"] = "segment"
            elif load_address is not None:
                address = (load_address + offset) & 0xFFFF
                matches = [(name, address - base, raw) for name, base, raw in fragments
                           if base <= address < base + len(raw) - 1]
                if len(matches) != 1:
                    raise ValueError("Attribute pointer has no unique mapped fragment")
                name, fragment_offset, raw = matches[0]
                proc.update(procedure_attributes(raw, fragment_offset, number))
                proc.update(storage=name, attribute_address=address)
            else:
                raise ValueError(f"Attribute pointer outside segment: {offset}")
            proc["status"] = "structurally-valid"
        except ValueError as error:
            proc.update(status="unresolved", issue=str(error))
        procedures.append(proc)
    return {"procedure_count": count, "dictionary_start": table_start,
            "valid": all(p["status"] == "structurally-valid" for p in procedures),
            "procedures": procedures}


def image_ranges(block, length):
    ranges = []
    for sector in range(block * 2, block * 2 + (length + 255) // 256):
        size = min(256, length - len(ranges) * 256)
        ranges.append({"offset": logical_sector_offset(sector), "length": size})
    return ranges


def inventory(images):
    headers = []
    for disk, image in images.items():
        for block in range(280):
            raw_header = block_bytes(image, block, block + 1)
            try:
                entries = parse_header(raw_header)
            except ValueError:
                continue
            header = {"disk": disk, "block": block, "sha256": sha(raw_header),
                      "status": "structural candidate; inspect segment results", "entries": entries}
            for entry in entries:
                relative, length = entry["relative_block"], entry["length"]
                if not length:
                    entry["status"] = "unused-header-slot-with-metadata"
                    continue
                if not relative:
                    entry["status"] = "data-segment-allocation"
                    continue
                start = block + relative
                end = start + (length + 511) // 512
                entry.update(start_block=start, end_block=end)
                if end > 280:
                    entry.update(status="unresolved", issue="Extent exceeds disk")
                    continue
                segment = block_bytes(image, start, end)[:length]
                entry.update(sha256=sha(segment), image_ranges=image_ranges(start, length))
                # These memory locations are demonstrated in runtime-init.json,
                # not inferred from other Pascal releases or generic heuristics.
                kwargs = {}
                if (disk, block, entry["slot"]) == ("disk1", 251, 15):
                    entry.update(status="split-system-procedure", load_address=0xBC72,
                                 owner="disk1:251:0:procedure38")
                    continue
                if (disk, block, entry["slot"]) == ("disk1", 251, 0):
                    fragment = block_bytes(image, 259, 260)[:170]
                    kwargs = {"load_address": 0xF248,
                              "fragments": [("header-slot-15", 0xBC72, fragment)]}
                    entry["load_address"] = 0xF248
                try:
                    parsed = procedure_dictionary(segment, entry["segment_number"], **kwargs)
                    entry.update(parsed)
                    entry["status"] = "valid-procedure-dictionary" if parsed["valid"] else "unresolved"
                except ValueError as error:
                    entry.update(status="unresolved", issue=str(error))
            headers.append(header)

    # Cross-disk matches are evidence of location, not proof of runtime selection.
    for header in headers:
        for entry in header["entries"]:
            if entry["status"] != "unresolved":
                continue
            matches = []
            for other in headers:
                if other["disk"] == header["disk"] or other["sha256"] != header["sha256"]:
                    continue
                for candidate in other["entries"]:
                    if candidate["slot"] == entry["slot"] and candidate["status"] == "valid-procedure-dictionary":
                        matches.append({"disk": other["disk"], "header_block": other["block"],
                                        "slot": candidate["slot"], "sha256": candidate["sha256"]})
            if matches:
                entry["other_disk_matches"] = matches

    statuses = Counter(e["status"] for h in headers for e in h["entries"])
    unique = {}
    for header in headers:
        for entry in header["entries"]:
            if entry["status"] == "valid-procedure-dictionary":
                unique.setdefault(entry["sha256"], entry)
    representations = Counter(p["representation"] for e in unique.values() for p in e["procedures"])
    return {"schema_version": 1,
            "scope": "Version-5 segment/procedure structure; not complete executable coverage or instruction decoding",
            "inputs": {disk: {"filename": INPUTS[disk], "sha256": sha(image)} for disk, image in images.items()},
            "summary": {"candidate_headers": len(headers), "entry_status_counts": dict(statuses),
                        "unique_valid_segments": len(unique), "unique_segment_procedures": dict(representations)},
            "headers": headers}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    verify_inputs()
    result = inventory({disk: (ROOT / filename).read_bytes() for disk, filename in INPUTS.items()})
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result["summary"], indent=2))


if __name__ == "__main__":
    main()
