#!/usr/bin/env python3
"""Audit native instruction coverage and direct targets using the da65 recipe.

This checks declared code/table boundaries; it is not a reachability proof for
every routine or a substitute for the full disk-byte comparison.
"""
import argparse
import json
from pathlib import Path
import re
import struct
import subprocess
import tempfile

from disk_layout import ROOT, sha
from interpreter_linkage import audit_linkage

BASE = 0xD000
END = 0xE0E5
CODE_SPANS = [(0xD152, 0xD1AD), (0xD1B7, 0xDCF6), (0xDCFE, 0xDDD6),
              (0xDE18, 0xDEA4), (0xDEA8, END)]
BRANCHES = {0x10, 0x30, 0x50, 0x70, 0x90, 0xB0, 0xD0, 0xF0}


def audit(binary):
    if len(binary) != END - BASE:
        raise ValueError("Native primitive image must contain $10E5 bytes")
    with tempfile.TemporaryDirectory(prefix="sundog-native-") as temporary:
        raw, listing = Path(temporary) / "input.bin", Path(temporary) / "output.s"
        raw.write_bytes(binary)
        subprocess.run(["da65", "-i", str(ROOT / "src/native/pcode_primitives.info"),
                        "--comments", "4", "-o", str(listing), str(raw)], check=True)
        text = listing.read_text()
    instructions = {}
    pattern = re.compile(r"^\s*(?:[A-Za-z_][A-Za-z_0-9]*:\s*)?([a-z]{3})\s*.*?; ([0-9A-F]{4}) ((?:[0-9A-F]{2} ?){1,3})", re.M)
    for match in pattern.finditer(text):
        address = int(match[2], 16)
        data = bytes.fromhex(match[3])
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
        if data[0] in BRANCHES:
            edges.append((address, address + 2 + struct.unpack("b", data[1:2])[0]))
        elif data[0] in (0x20, 0x4C):
            edges.append((address, int.from_bytes(data[1:3], "little")))
    for offset in range(0, 0x152, 2):
        edges.append((BASE + offset, int.from_bytes(binary[offset:offset + 2], "little")))
    for source, target in edges:
        if BASE <= target < END and target not in instructions:
            raise ValueError(f"Target ${target:04X} from ${source:04X} is not an instruction boundary")
    if binary[0xFFF:0x1001] != bytes.fromhex("85 88"):
        raise ValueError("Cross-bank STA $88 instruction is not intact")
    if binary[0x29D:0x2A0] != bytes.fromhex("6c 00 d0"):
        raise ValueError("Dispatch vector operand must retain its original, unpatched bytes")
    return {"sha256": sha(binary), "instruction_count": len(instructions),
            "instruction_bytes": sum(len(data) for data in instructions.values()),
            "data_bytes": len(binary) - sum(len(data) for data in instructions.values()),
            "checked_direct_and_vector_targets": len(edges),
            "external_targets": sorted({target for _, target in edges if not BASE <= target < END}),
            "code_spans_end_exclusive": CODE_SPANS,
            "cross_bank_instruction": {"address": 0xDFFF, "bytes": "8588", "instruction": "STA $88"}}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--binary", type=Path, default=ROOT / "build/disks/components/pcode_primitives.bin")
    parser.add_argument("--output", type=Path)
    parser.add_argument("--components", type=Path, default=ROOT / "build/disks/components")
    args = parser.parse_args()
    report = audit(args.binary.read_bytes())
    report['interpreter_linkage'] = audit_linkage(args.binary.read_bytes(),
        (args.components/'native_shared.bin').read_bytes(),
        (args.components/'native_high.bin').read_bytes())
    formatted = json.dumps(report, indent=2) + "\n"
    if args.output:
        args.output.write_text(formatted)
    print(formatted, end="")


if __name__ == "__main__":
    main()
