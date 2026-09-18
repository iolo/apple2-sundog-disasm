#!/usr/bin/env python3
"""Audit high-memory services, bank-specific targets, and preserved fragments."""
import argparse
import json
from pathlib import Path
import re
import struct
import subprocess
import tempfile

from disk_layout import ROOT, sha

BASE, END = 0xF790, 0x10000
CODE_SPANS = [(0xF7A1, 0xF800), (0xFE80, 0xFEB0), (0xFED8, 0xFEF8),
              (0xFF00, 0xFF4F), (0xFF58, 0xFFE0)]


def instructions_for(binary, recipe):
    with tempfile.TemporaryDirectory(prefix="sundog-high-") as temporary:
        raw, listing = Path(temporary) / "input.bin", Path(temporary) / "output.s"
        raw.write_bytes(binary)
        subprocess.run(["da65", "-i", str(ROOT / f"src/native/{recipe}.info"),
                        "--comments", "4", "-o", str(listing), str(raw)], check=True)
        text = listing.read_text()
    pattern = re.compile(r"^\s*(?:\w+:\s*)?([a-z]{3})\s*.*?; ([0-9A-F]{4}) ((?:[0-9A-F]{2} ?){1,3})", re.M)
    return {int(m[2], 16): bytes.fromhex(m[3]) for m in pattern.finditer(text)}


def audit(binary, initializer, io_bank, primitives):
    if len(binary) != END - BASE:
        raise ValueError("High native region must contain $0870 bytes")
    instructions = instructions_for(binary, "native_high")
    for address, data in instructions.items():
        if not any(lo <= address < hi for lo, hi in CODE_SPANS):
            raise ValueError(f"Instruction emitted in declared data at ${address:04X}")
        if binary[address - BASE:address - BASE + len(data)] != data:
            raise ValueError("Listing bytes disagree with input")
    for lo, hi in CODE_SPANS:
        cursor = lo
        while cursor < hi:
            if cursor not in instructions:
                raise ValueError(f"Undecoded instruction or code gap at ${cursor:04X}")
            cursor += len(instructions[cursor])
        if cursor != hi:
            raise ValueError("Instruction crosses a declared code/data boundary")
    bank1 = instructions_for(primitives, "pcode_primitives")
    bank2 = instructions_for(io_bank, "native_io")
    edges = []
    for address, data in instructions.items():
        if data[0] in (0x10, 0x30, 0x50, 0x70, 0x90, 0xB0, 0xD0, 0xF0):
            edges.append((address, address + 2 + struct.unpack("b", data[1:2])[0]))
        elif data[0] in (0x20, 0x4C):
            edges.append((address, int.from_bytes(data[1:3], "little")))
    word = lambda a: int.from_bytes(binary[a - BASE:a - BASE + 2], "little")
    for a in (0xFF52, 0xFF54, 0xFFE2, 0xFFF8, 0xFFFA, 0xFFFC, 0xFFFE):
        edges.append((a, word(a)))
    for source, target in edges:
        if BASE <= target < END and target not in instructions:
            raise ValueError(f"Target ${target:04X} from ${source:04X} is not an instruction boundary")
        if 0xD000 <= target < 0xE000:
            bank = bank1 if source == 0xFEF5 else bank2
            if target not in bank:
                raise ValueError(f"Target ${target:04X} is not an instruction boundary in the selected bank")
    for a in range(0xFE80, 0xFEB0, 3):
        if instructions.get(a) != bytes.fromhex("4c 00 00"):
            raise ValueError("Initial slot JMP operand changed")
    dispatch = []
    for a in range(0xFF00, 0xFF42, 3):
        if instructions.get(a) != bytes.fromhex("20 9e ff"):
            raise ValueError("Service JSR entry changed")
        target = a + 2 + 0x5A
        if target not in instructions:
            raise ValueError("Derived service target is not an instruction boundary")
        dispatch.append({"entry": a, "derived_target": target})
    required = {0xFFA2: "69 5a", 0xFFB3: "ad 83 c0", 0xFFC5: "ad 8b c0",
                0xFEF2: "ad 8b c0", 0xFFCB: "6c d3 00"}
    for a, encoded in required.items():
        if instructions.get(a) != bytes.fromhex(encoded):
            raise ValueError(f"Bank/service dispatch instruction changed at ${a:04X}")
    fragment = binary[0xF7A1 - BASE:0xF800 - BASE]
    if fragment != initializer[0x311:0x370]:
        raise ValueError("Preserved initializer fragment differs from its original copy")
    if any(binary[0xF828 - BASE:0xFE80 - BASE]):
        raise ValueError("Preserved zero area changed")
    if binary[0xFFE4 - BASE:0xFFF6 - BASE] != bytes.fromhex("0b 0c 0f 5d 5e 40 1d 1e 00 5b 0a 0b 4d 4e 50 5d 5e 40"):
        raise ValueError("Keyboard translation tables changed")
    return {"sha256": sha(binary), "instruction_count": len(instructions),
            "instruction_bytes": sum(map(len, instructions.values())),
            "data_bytes": len(binary) - sum(map(len, instructions.values())),
            "checked_direct_and_vector_targets": len(edges),
            "code_spans_end_exclusive": CODE_SPANS, "service_dispatch": dispatch,
            "preserved_duplicate_fragment": {"address": 0xF7A1, "size": 95,
                "original_initializer_address": 0xF5A1, "copied_initializer_address": 0x6B11,
                "sha256": sha(fragment), "execution_not_established": True},
            "unresolved_preservation_ranges": [[0xF790, 0xF7A1], [0xF800, 0xF828], [0xFFF6, 0xFFF8]],
            "bank1_entry": 0xD152, "bank2_targets": sorted({t for a, t in edges if 0xD000 <= t < 0xE000 and a != 0xFEF5})}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--binary", type=Path, default=ROOT / "build/disks/components/native_high.bin")
    parser.add_argument("--components", type=Path, default=ROOT / "build/disks/components")
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    report = audit(args.binary.read_bytes(), *((args.components / f"{name}.bin").read_bytes()
                   for name in ("native_init", "native_io", "pcode_primitives")))
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(report, indent=2) + "\n")
    print(f"High-memory audit: {report['instruction_count']} instructions; "
          f"{report['checked_direct_and_vector_targets']} targets; 22 service entries; duplicate fragment verified")


if __name__ == "__main__":
    main()
