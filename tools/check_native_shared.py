#!/usr/bin/env python3
"""Audit common-memory native code, synthetic returns, dispatch, and constants.

This validates declared boundaries and preserved encodings, not full reachability.
"""
import argparse
import json
from pathlib import Path
import re
import struct
import subprocess
import tempfile

from disk_layout import ROOT, sha

BASE, END = 0xE0E5, 0xF290
CODE_SPANS = [(BASE, 0xE189), (0xE18C, 0xEDE6), (0xEEA5, 0xF1CB),
              (0xF1CD, 0xF1F3), (0xF264, 0xF267), (0xF269, END)]


def integer_binary32(value):
    """Round a positive integer to binary32 bits, using integer arithmetic."""
    exponent = value.bit_length() - 1
    if exponent <= 23:
        significand = value << (23 - exponent)
    else:
        unit = 1 << (exponent - 23)
        significand, remainder = divmod(value, unit)
        if remainder * 2 > unit or (remainder * 2 == unit and significand & 1):
            significand += 1
        if significand == 1 << 24:
            significand >>= 1
            exponent += 1
    return ((exponent + 127) << 23) | (significand & 0x7FFFFF)


def audit(binary, primitive_binary=None):
    if len(binary) != END - BASE:
        raise ValueError("Shared native image must contain $11AB bytes")
    with tempfile.TemporaryDirectory(prefix="sundog-shared-") as temporary:
        raw, listing = Path(temporary) / "input.bin", Path(temporary) / "output.s"
        raw.write_bytes(binary)
        subprocess.run(["da65", "-i", str(ROOT / "src/native/native_shared.info"),
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
    word = lambda address: int.from_bytes(binary[address - BASE:address - BASE + 2], "little")
    # These words are explicitly pushed onto the hardware stack before JMP indirect.
    for address in (0xE189, 0xF1CB):
        edges.append((address, word(address) + 1))
    for address in range(0xEE85, 0xEEA5, 2):
        edges.append((address, word(address)))
    incoming = []
    if primitive_binary is not None:
        if len(primitive_binary) != 0x10E5:
            raise ValueError("Incorrect primitive bank size")
        for offset in range(0, 0x152, 2):
            target = int.from_bytes(primitive_binary[offset:offset + 2], "little")
            if BASE <= target < END:
                incoming.append((0xD000 + offset, target))
    for source, target in edges + incoming:
        if BASE <= target < END and target not in instructions:
            raise ValueError(f"Target ${target:04X} from ${source:04X} is not an instruction boundary")
    if instructions.get(0xE687) != bytes.fromhex("6c 00 d1"):
        raise ValueError("Standard-procedure dispatch must retain JMP ($D100)")
    if word(0xE189) != 0xE17D or word(0xF1CB) != 0xF1CC:
        raise ValueError("Synthetic return address changed")
    powers = []
    for exponent in range(39):
        address = 0xEDE6 + exponent * 4
        bits = (word(address) << 16) | word(address + 2)
        nearest = integer_binary32(10 ** exponent)
        expected_delta = 3 if exponent == 38 else 0
        if bits - nearest != expected_delta:
            raise ValueError(f"Power-of-ten entry {exponent} changed")
        powers.append({"exponent": exponent, "stored_bits": f"{bits:08x}",
                       "nearest_bits": f"{nearest:08x}", "ulp_difference": bits - nearest})
    if word(0xF267) != 0xF290 or instructions.get(0xF28D) != bytes.fromhex("4c 00 68"):
        raise ValueError("Initializer source/entry changed")
    if binary[0xF1FF - BASE:0xF23E - BASE] != b'\rInsert boot disk with SYSTEM.PASCAL\r\non it, then press RETURN#':
        raise ValueError("Boot-disk message changed")
    if binary[0xF23E - BASE:0xF260 - BASE] != b'\rSYSTEM.PASCAL is not version 1.2#':
        raise ValueError("System-version message changed")
    return {"sha256": sha(binary), "instruction_count": len(instructions),
            "instruction_bytes": sum(map(len, instructions.values())),
            "data_bytes": len(binary) - sum(map(len, instructions.values())),
            "checked_direct_vector_and_return_targets": len(edges),
            "checked_incoming_primitive_vectors": len(incoming),
            "code_spans_end_exclusive": CODE_SPANS,
            "external_targets": sorted({t for _, t in edges if not BASE <= t < END}),
            "power_of_ten_entries": powers,
            "initializer_source": word(0xF267), "initializer_destination": 0x6800}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--binary", type=Path, default=ROOT / "build/disks/components/native_shared.bin")
    parser.add_argument("--primitives", type=Path, default=ROOT / "build/disks/components/pcode_primitives.bin")
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    report = audit(args.binary.read_bytes(), args.primitives.read_bytes())
    encoded = json.dumps(report, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(encoded)
    print(f"Shared native audit: {report['instruction_count']} instructions, "
          f"{report['checked_direct_vector_and_return_targets']} outgoing/return targets, "
          f"{report['checked_incoming_primitive_vectors']} incoming vectors; "
          "39 power constants preserved")


if __name__ == "__main__":
    main()
