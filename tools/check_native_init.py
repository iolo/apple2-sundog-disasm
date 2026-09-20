#!/usr/bin/env python3
"""Audit the initializer at its copied address, retaining original-image aliases."""
import argparse
import json
from pathlib import Path
import re
import struct
import subprocess
import tempfile

from disk_layout import ROOT, sha
from initializer_protection import audit_payload

BASE, END, STORAGE_DELTA = 0x6800, 0x6D00, 0x8A90
CODE_SPANS = [(BASE, 0x68CC), (0x68D0, 0x6988), (0x6990, 0x6995),
              (0x6996, 0x699C), (0x699D, 0x6C18), (0x6C28, 0x6C46)]


def audit(binary, io_bank, compiler=None):
    if len(binary) != END - BASE:
        raise ValueError("Initializer must contain five pages")
    with tempfile.TemporaryDirectory(prefix="sundog-init-") as temporary:
        raw, listing = Path(temporary) / "input.bin", Path(temporary) / "output.s"
        raw.write_bytes(binary)
        subprocess.run(["da65", "-i", str(ROOT / "src/native/native_init.info"),
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
    edges, aliases = [], []
    for address, data in instructions.items():
        target = None
        if data[0] in (0x10, 0x30, 0x50, 0x70, 0x90, 0xB0, 0xD0, 0xF0):
            target = address + 2 + struct.unpack("b", data[1:2])[0]
        elif data[0] in (0x20, 0x4C):
            target = int.from_bytes(data[1:3], "little")
        if target is not None:
            if BASE + STORAGE_DELTA <= target < END + STORAGE_DELTA:
                aliases.append({"call": address, "original_target": target,
                                "copied_target": target - STORAGE_DELTA})
                target -= STORAGE_DELTA
            edges.append((address, target))
    for address in (0x68CC, 0x68CE):
        edges.append((address, int.from_bytes(binary[address - BASE:address - BASE + 2], "little") + 1))
    for source, target in edges:
        if BASE <= target < END and target not in instructions:
            raise ValueError(f"Target ${target:04X} from ${source:04X} is not an instruction boundary")
    expected_calls = [(0x6824, 0xF69A), (0x682B, 0xF69A)]
    if [(a["call"], a["original_target"]) for a in aliases] != expected_calls:
        raise ValueError("Original-address checksum calls changed")
    if binary[0xCC:0xD0] != bytes.fromhex("b8 68 c3 68"):
        raise ValueError("Synthetic device-initialization return addresses changed")
    if instructions.get(0x6B15) != bytes.fromhex("29 e0") or instructions.get(0x6B17) != bytes.fromhex("c9 a0"):
        raise ValueError("System version-mask check changed")
    if instructions.get(0x6C43) != bytes.fromhex("4c 93 d2"):
        raise ValueError("Final p-code dispatch changed")
    if any(binary[0x479:]):
        raise ValueError("Preserved zero tail changed")
    protection = audit_payload(binary, io_bank, compiler)
    return {"sha256": sha(binary), "instruction_count": len(instructions),
            "instruction_bytes": sum(map(len, instructions.values())),
            "instruction_fragment_bytes": protection['code_fragment_bytes'],
            "data_bytes": len(binary) - sum(map(len, instructions.values())) - protection['code_fragment_bytes'],
            "checked_direct_and_return_targets": len(edges),
            "code_spans_end_exclusive": CODE_SPANS, "original_address_calls": aliases,
            "original_load_address": BASE + STORAGE_DELTA, "execution_address": BASE,
            "fortran_protection": protection, "unresolved_payload": None,
            "external_targets": sorted({t for _, t in edges if not BASE <= t < END})}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--binary", type=Path, default=ROOT / "build/disks/components/native_init.bin")
    parser.add_argument("--output", type=Path)
    parser.add_argument("--io-binary", type=Path, default=ROOT / "build/disks/components/native_io.bin")
    parser.add_argument("--fortran-compiler", type=Path,
                        help="Optionally verify external consumer evidence against extracted SYSTEM.COMPILER")
    args = parser.parse_args()
    binary = args.binary.read_bytes()
    report = audit(binary, args.io_binary.read_bytes(),
                   args.fortran_compiler.read_bytes() if args.fortran_compiler else None)
    evidence = json.loads((ROOT / "docs/reference/runtime-init.json").read_text())
    capture = next(item["capture"] for item in evidence["observations"] if item["id"] == "relocated-init")
    if capture["address"] != BASE or capture["length"] != len(binary) or bytes.fromhex(capture["hex"]) != binary:
        raise ValueError("Assembled initializer differs from the complete emulator capture")
    report["byte_identical_to_recorded_emulator_capture"] = True
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(report, indent=2) + "\n")
    print(f"Initializer audit: {report['instruction_count']} instructions, "
          f"{report['checked_direct_and_return_targets']} targets; all 1280 bytes match captured memory")


if __name__ == "__main__":
    main()
