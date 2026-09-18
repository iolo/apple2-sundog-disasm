#!/usr/bin/env python3
"""Validate mixed library segment 23 and its native relocation/data boundaries."""
import argparse
import json
from pathlib import Path
import re
import struct
import subprocess
import tempfile

from disk_layout import ROOT, sha
from native_relocations import native_relocations
from pascal_inventory import procedure_dictionary, word

CODE = [(0xC, 0x6B), (0xB6, 0x19D), (0x1AC, 0x248)]
DATA = [(0x6B, 0x6F, 'two-bit-mask-table'), (0x6F, 0xA7, 'state-transition-table'),
        (0xA7, 0xA8, 'alignment'), (0x19D, 0x19E, 'alignment')]


def audit(binary):
    if len(binary) != 606:
        raise ValueError('Expected 606-byte library segment 23')
    metadata = procedure_dictionary(binary, 23)
    if not metadata['valid'] or metadata['procedure_count'] != 4:
        raise ValueError('Unexpected procedure dictionary')
    instructions = {}
    with tempfile.TemporaryDirectory() as temp:
        raw, out = Path(temp) / 'native.bin', Path(temp) / 'native.s'
        for start, end in CODE:
            raw.write_bytes(binary[start:end])
            subprocess.run(['da65', '--start-addr', str(0x4000 + start), '--comments', '4',
                            '--cpu', '6502', '-o', str(out), str(raw)], check=True)
            pattern = r'^\s*(?:\w+:\s*)?([a-z]{3})\s*.*?; ([0-9A-F]{4}) ((?:[0-9A-F]{2} ?){1,3})'
            for match in re.finditer(pattern, out.read_text(), re.M):
                instructions[int(match[2], 16) - 0x4000] = bytes.fromhex(match[3])
            cursor = start
            while cursor < end:
                encoded = instructions.get(cursor)
                if not encoded or binary[cursor:cursor + len(encoded)] != encoded:
                    raise ValueError('Unclassified or incorrectly decoded native instruction')
                cursor += len(encoded)
            if cursor != end:
                raise ValueError('Native instruction crosses code/data boundary')
    owners = {}
    regions = []

    def claim(start, end, kind):
        if not 0 <= start < end <= len(binary):
            raise ValueError('Classification range out of bounds')
        for offset in range(start, end):
            if offset in owners:
                raise ValueError('Overlapping classification')
            owners[offset] = kind
        regions.append(dict(offset=start, size=end-start, kind=kind))

    p1 = metadata['procedures'][0]
    if p1['entry_offset'] != 0 or p1['attribute_offset'] != 10 or binary[:2] != b'\xad\0':
        raise ValueError('Unexpected p-code entry')
    claim(0, 2, 'p-code-instruction')
    claim(2, 12, 'p-code-metadata')
    relocations = []
    reloc_targets = {}
    for proc, (start, end) in zip(metadata['procedures'][1:], CODE):
        parsed = native_relocations(binary, proc)
        if parsed['entry'] != start:
            raise ValueError('Native entry differs from code classification')
        claim(start, end, 'native-instructions')
        claim(parsed['tables_start'], proc['attribute_offset'] - 2, 'relocation-lists')
        claim(proc['attribute_offset'] - 2, proc['attribute_offset'] + 2, 'native-metadata')
        for group in parsed['groups']:
            for pointer in group['pointers']:
                if group['kind'] != 'procedure':
                    raise ValueError('Unexpected relocation class in segment 23')
                reloc_targets[pointer['target']] = start + pointer['original_word']
        relocations.append(parsed)
    for start, end, kind in DATA:
        claim(start, end, kind)
    claim(metadata['dictionary_start'], len(binary), 'procedure-dictionary-and-trailer')
    if len(owners) != len(binary):
        raise ValueError('Unclassified segment bytes')
    if reloc_targets != {0x50: 0x6F, 0x194: 0xE8}:
        raise ValueError('Relocation operands do not target the verified table/loop')
    if instructions.get(0x4F) != b'\xbd\x63\0' or instructions.get(0x193) != b'\x4c\x32\0':
        raise ValueError('Relocation target is not the expected instruction operand')
    edges = []
    for offset, encoded in instructions.items():
        op = encoded[0]
        if op in (0x10, 0x30, 0x50, 0x70, 0x90, 0xB0, 0xD0, 0xF0):
            target = offset + 2 + struct.unpack('b', encoded[1:2])[0]
        elif op in (0x20, 0x4C):
            target = reloc_targets.get(offset + 1, word(encoded, 1))
        else:
            continue
        if target not in instructions:
            raise ValueError('Native control flow enters data or an operand')
        edges.append([offset, target])
    if binary[0x6B:0x6F] != bytes([3 << (2*i) for i in range(4)]):
        raise ValueError('Two-bit masks changed')
    if max(binary[0x6F:0xA7]) > 13 or binary[0xA7] or binary[0x19D]:
        raise ValueError('State-table bound or alignment changed')
    return dict(sha256=sha(binary), size=len(binary), segment=23, procedure_count=4,
                instruction_count=len(instructions)+1, native_instruction_count=len(instructions),
                coverage_bytes=dict(native_instructions=sum(map(len, instructions.values())),
                                    pcode_instructions=2, data=122),
                code_data_regions=regions, relocations=relocations, control_flow_edges=edges)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('binary', nargs='?', type=Path, default=ROOT / 'build/disks/components/library_23.bin')
    parser.add_argument('--report', type=Path)
    args = parser.parse_args()
    report = audit(args.binary.read_bytes())
    if args.report:
        args.report.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({key: report[key] for key in ('size', 'instruction_count', 'coverage_bytes')}))


if __name__ == '__main__':
    main()
