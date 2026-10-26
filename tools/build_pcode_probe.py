#!/usr/bin/env python3
"""Assemble one confirmed p-code procedure, then compare with its disk source.

This is the step-04 toolchain proof, not a full image build. Assembly consumes
only src/pcode files; the original disk is read afterwards for verification.
"""
import argparse
from pathlib import Path
import subprocess

from disk_layout import ROOT, INPUTS, block_bytes, sha
from verify_inputs import main as verify_inputs


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=ROOT / "build/pcode-probe")
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    source = ROOT / "src/pcode"
    obj, binary = output / "system_entry.o", output / "system_entry.bin"
    subprocess.run(["ca65", "-I", str(source), "-o", str(obj),
                    "-l", str(output / "system_entry.lst"), str(source / "runtime_entry.s")], check=True)
    subprocess.run(["ld65", "-C", str(source / "runtime_entry.cfg"), "-o", str(binary),
                    "-m", str(output / "system_entry.map"), str(obj)], check=True)
    verify_inputs()
    expected = block_bytes((ROOT / INPUTS["disk1"]).read_bytes(), 252, 253)[:36]
    actual = binary.read_bytes()
    if actual != expected:
        raise ValueError("Rebuilt SYSTEM.PASCAL entry differs from disk bytes")
    print(f"Exact p-code procedure: {len(actual)} bytes, SHA-256 {sha(actual)}")


if __name__ == "__main__":
    main()
