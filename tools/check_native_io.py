#!/usr/bin/env python3
"""Check bank-2 instruction boundaries, overlaps, patch sites, and disk tables.

This is a structural audit, not a claim that every peripheral path was executed.
"""
import argparse
import json
from pathlib import Path
import re
import struct
import subprocess
import tempfile

from disk_layout import ROOT, sha
from native_io_storage import audit_storage

BASE, END = 0xD000, 0xE000
CODE_SPANS = [(0xD000, 0xD028), (0xD029, 0xD258), (0xD259, 0xD395),
              (0xD500, 0xD5D2), (0xD5D3, 0xD648), (0xD658, 0xD680),
              (0xD683, 0xDC3B), (0xDC3C, 0xDC59)]
# Each prefix executes BIT across an independently reachable instruction.
OVERLAPS = {0xD028: bytes.fromhex("2c a0 01"),
            0xD258: bytes.fromhex("24 38"),
            0xD5D2: bytes.fromhex("24 18")}
PATCHED_INSTRUCTIONS = {
    0xD560: "ae ec c0", 0xD577: "ae ec c0", 0xD58D: "ae ec c0",
    0xD5A1: "ae ec c0", 0xD5B6: "ae ec c0",
    0xD574: "99 00 10", 0xD59B: "99 00 10", 0xD5B3: "99 00 10",
    0xDA18: "49 80", 0xDBB9: "91 00",
}


def audit(binary):
    if len(binary) != END - BASE:
        raise ValueError("Native I/O image must contain $1000 bytes")
    with tempfile.TemporaryDirectory(prefix="sundog-io-") as temporary:
        raw, listing = Path(temporary) / "input.bin", Path(temporary) / "output.s"
        raw.write_bytes(binary)
        subprocess.run(["da65", "-i", str(ROOT / "src/native/native_io.info"),
                        "--comments", "4", "-o", str(listing), str(raw)], check=True)
        text = listing.read_text()
    pattern = re.compile(r"^\s*(?:\w+:\s*)?([a-z]{3})\s*.*?; ([0-9A-F]{4}) ((?:[0-9A-F]{2} ?){1,3})", re.M)
    instructions = {}
    for match in pattern.finditer(text):
        address, data = int(match[2], 16), bytes.fromhex(match[3])
        if not any(lo <= address < hi for lo, hi in CODE_SPANS):
            raise ValueError(f"Instruction emitted in declared data at ${address:04X}")
        if binary[address - BASE:address - BASE + len(data)] != data:
            raise ValueError("Listing bytes disagree with input")
        instructions[address] = data
    for lo, hi in CODE_SPANS:
        cursor = lo
        while cursor < hi:
            if cursor not in instructions:
                raise ValueError(f"Undecoded instruction or code gap at ${cursor:04X}")
            cursor += len(instructions[cursor])
        if cursor != hi:
            raise ValueError("Instruction crosses a declared code/data boundary")
    edges = []
    for address, data in instructions.items():
        if data[0] in (0x10, 0x30, 0x50, 0x70, 0x90, 0xB0, 0xD0, 0xF0):
            edges.append((address, address + 2 + struct.unpack("b", data[1:2])[0]))
        elif data[0] in (0x20, 0x4C):
            edges.append((address, int.from_bytes(data[1:3], "little")))
    for address in range(0xDC6B, 0xDC8F, 2):
        edges.append((address, int.from_bytes(binary[address - BASE:address - BASE + 2], "little")))
    for source, target in edges:
        if BASE <= target < END and target not in instructions:
            raise ValueError(f"Target ${target:04X} from ${source:04X} is not an instruction boundary")
    for address, data in OVERLAPS.items():
        if binary[address - BASE:address - BASE + len(data)] != data:
            raise ValueError(f"BIT overlap changed at ${address:04X}")
        if address + 1 not in instructions or address + len(data) not in instructions:
            raise ValueError("Overlapping entry or fall-through is not an instruction boundary")
    for address, encoded in PATCHED_INSTRUCTIONS.items():
        if instructions.get(address) != bytes.fromhex(encoded):
            raise ValueError(f"Original patched instruction changed at ${address:04X}")
    symbols = binary[0x403:0x500:4]
    if len(set(symbols)) != 64 or min(symbols) != 0x96 or max(symbols) != 0xFF:
        raise ValueError("Expected 64 distinct disk symbols in $96-$FF")
    inverse = {symbol: index * 4 for index, symbol in enumerate(symbols)}
    if binary[0x396:0x400] != bytes(inverse.get(i, i) for i in range(0x96, 0x100)):
        raise ValueError("Disk-symbol inverse table mismatch")
    reverse_pair = lambda value: ((value & 1) << 1) | ((value & 2) >> 1)
    table = bytes(value for i, symbol in enumerate(symbols)
                  for value in (reverse_pair(i), reverse_pair(i >> 2), reverse_pair(i >> 4), symbol))
    if table != binary[0x400:0x500]:
        raise ValueError("Bit-pair conversion table mismatch")
    if any(binary[0xC8F:]):
        raise ValueError("Initial state and preserved zero tail changed")
    storage = audit_storage(binary, instructions)
    code_bytes = sum(map(len, instructions.values())) + len(OVERLAPS)
    return {"sha256": sha(binary), "instruction_count_including_overlaps": len(instructions) + len(OVERLAPS),
            "unique_instruction_bytes": code_bytes, "data_bytes": len(binary) - code_bytes,
            "checked_direct_and_vector_targets": len(edges),
            "code_spans_end_exclusive": CODE_SPANS,
            "overlapping_bit_instructions": {f"{a:04X}": b.hex() for a, b in OVERLAPS.items()},
            "patched_instructions": {f"{a:04X}": b for a, b in PATCHED_INSTRUCTIONS.items()},
            "gcr_symbols": symbols.hex(), "derived_bit_pair_entries": 192,
            "external_targets": sorted({t for _, t in edges if not BASE <= t < END}),
            "preservation_data": storage, "unresolved_preservation_ranges": []}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--binary", type=Path, default=ROOT / "build/disks/components/native_io.bin")
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    report = audit(args.binary.read_bytes())
    encoded = json.dumps(report, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(encoded)
    print(encoded, end="")


if __name__ == "__main__":
    main()
