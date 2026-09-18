#!/usr/bin/env python3
"""Decode supported Apple Pascal p-code into ca65 source with explicit tables.

Only formats checked against the shipped interpreter are accepted. This initial
module supports the startup segment; unknown instructions and unexplained gaps
fail instead of becoming executable byte blobs. Segment origins must be even.
"""
import argparse
from collections import Counter
import json
from pathlib import Path
import struct

from disk_layout import ROOT, sha
from pascal_inventory import procedure_dictionary, word

# opcode: mnemonic, operand format, native dispatch target. Format b is the
# interpreter's one/two-byte big value; u is a fixed byte, w a little-endian word.
SPECS = {
    0x8D: ('lor', '', 0xD5C2), 0x95: ('sbi', '', 0xD747),
    0x9D: ('lde', 'ub', 0xD442), 0x9E: ('csp', 'u', 0xE67F),
    0x9F: ('ldcn', '', 0xD2D7), 0xA1: ('fjp', 'jump', 0xD2A0),
    0xA7: ('lae', 'ub', 0xD48C), 0xAC: ('xjp', 'case', 0xD5E2),
    0xAD: ('rnp', 'u', 0xE371), 0xB2: ('lda', 'ub', 0xD3EE),
    0xB6: ('lod', 'ub', 0xD3C8), 0xB9: ('ujp', 'jump', 0xD2A8),
    0xBA: ('ldp', '', 0xDA60), 0xBB: ('stp', '', 0xDAB6),
    0xBE: ('ldb', '', 0xD567), 0xC0: ('ixp', 'uu', 0xDA1D),
    0xC1: ('rbp', 'u', 0xE35C), 0xC2: ('cbp', 'u', 0xE32B),
    0xC3: ('equi', '', 0xDFA9), 0xC4: ('geqi', '', 0xDF7B),
    0xC6: ('lla', 'b', 0xD315), 0xC7: ('ldci', 'w', 0xD2DE),
    0xC8: ('leqi', '', 0xDF77), 0xCB: ('neqi', '', 0xDF7F),
    0xCC: ('stl', 'b', 0xD33B), 0xCD: ('cxp', 'uu', 0xE306),
    0xCE: ('clp', 'u', 0xE2D3), 0xCF: ('cgp', 'u', 0xE2EF),
    0xD1: ('ste', 'ub', 0xD467), 0xD6: ('xit', '', 0xD6E4),
    0xD7: ('nop', '', 0xD28D),
}


def label(offset):
    return f'L_{offset:04X}'


def verify_interpreter(binary):
    if len(binary) != 0x10E5:
        raise ValueError('Expected the complete native primitive component')
    for opcode, (name, _, expected) in SPECS.items():
        if word(binary, (opcode - 128) * 2) != expected:
            raise ValueError(f'Interpreter handler for {name} differs from verified encoding')
    for opcode in range(0xD8, 0xE8):
        if word(binary, (opcode - 128) * 2) != 0xD2EA:
            raise ValueError('Short local dispatch differs from verified encoding')


def analyze(data, segment):
    metadata = procedure_dictionary(data, segment)
    if not metadata['valid']:
        raise ValueError('Segment has unresolved procedure metadata')
    items, instructions, calls, branch_edges = {}, {}, [], []
    occupied = {}
    procedures = sorted(metadata['procedures'], key=lambda p: p['entry_offset'])

    def claim(offset, size, kind, assembly, **details):
        if offset < 0 or size <= 0 or offset + size > len(data):
            raise ValueError(f'{kind} exceeds segment bounds at {offset}')
        item = dict(offset=offset, size=size, kind=kind, assembly=assembly, **details)
        if offset in items and items[offset] == item:
            return
        for i in range(offset, offset + size):
            if i in occupied:
                raise ValueError(f'Overlapping code/data at ${i:04X}')
        items[offset] = item
        for i in range(offset, offset + size):
            occupied[i] = offset

    for proc in procedures:
        if proc['representation'] != 'p-code':
            raise ValueError('Native procedures require a separate reconstruction recipe')
        entry, attr, limit = proc['entry_offset'], proc['attribute_offset'], proc['attribute_start']
        claim(limit, 2, 'local-size', f'.word {proc["local_bytes"]}')
        claim(limit + 2, 2, 'parameter-size', f'.word {proc["parameter_bytes"]}')
        claim(limit + 4, 2, 'exit-pointer', f'.word * - {label(proc["exit_offset"])}')
        claim(limit + 6, 2, 'entry-pointer', f'.word * - {label(entry)}')
        claim(attr, 2, 'attributes', f'.byte {proc["number"]}, ${proc["lexical_level"] & 255:02X}')
        pending = [entry, proc['exit_offset']]
        targets = set(pending)
        while pending:
            pc = pending.pop()
            if not entry <= pc < limit:
                raise ValueError(f'Procedure {proc["number"]} target ${pc:04X} is outside code area')
            if pc in instructions:
                continue
            if pc in occupied:
                raise ValueError(f'Control flow enters data or an operand at ${pc:04X}')
            op, cursor, args = data[pc], pc + 1, []
            if op < 0x80:
                name, form, args = 'sldc', '', [op]
            elif 0xD8 <= op <= 0xE7:
                name, form, args = 'sldl', '', [op - 0xD7]
            elif op in SPECS:
                name, form, _ = SPECS[op]
            else:
                raise ValueError(f'Unsupported opcode ${op:02X} at ${pc:04X}')

            def byte():
                nonlocal cursor
                if cursor >= limit:
                    raise ValueError(f'Truncated operand at ${pc:04X}')
                value = data[cursor]
                cursor += 1
                return value

            successors = []
            if form == 'jump':
                operand = byte()
                if operand < 128:
                    target = cursor + operand
                    assembly = f'p_{name}_direct {label(target)}'
                else:
                    pointer = attr + operand - 256
                    if not entry <= pointer <= limit - 2 or pointer % 2:
                        raise ValueError(f'Invalid jump-table selector at ${pc:04X}')
                    target = (pointer - word(data, pointer)) & 0xFFFF
                    claim(pointer, 2, 'jump-pointer', f'.word (* - {label(target)}) & $FFFF', target=target)
                    assembly = f'p_{name}_table {label(pointer)}, {label(attr)}'
                successors = [target] + ([cursor] if name == 'fjp' else [])
            elif form == 'case':
                aligned = (pc | 1) + 1
                padding = data[pc + 1] if aligned - pc == 2 else 0
                if aligned + 6 > limit:
                    raise ValueError('Truncated case header')
                low, high = struct.unpack_from('<hh', data, aligned)
                count = high - low + 1
                default = aligned + 4
                table = default + 2
                if count <= 0 or table + 2 * count > limit or data[default] != 0xB9:
                    raise ValueError('Unsupported or out-of-bounds case table')
                for index in range(count):
                    pointer = table + index * 2
                    target = (pointer - word(data, pointer)) & 0xFFFF
                    claim(pointer, 2, 'case-pointer', f'.word (* - {label(target)}) & $FFFF', target=target)
                    successors.append(target)
                successors.append(default)
                cursor = default
                assembly = f'p_xjp {low}, {high}, {aligned - pc - 1}, ${padding:02X}'
            else:
                for operand in form:
                    first = byte()
                    if operand == 'u':
                        args.append(first)
                    elif operand == 'b':
                        args.extend([((first & 127) << 8) | byte(), 2] if first & 128 else [first, 1])
                    elif operand == 'w':
                        value = first | (byte() << 8)
                        args.append(value if value < 32768 else value - 65536)
                assembly = f'p_{name}' + (' ' + ', '.join(map(str, args)) if args else '')
                if name not in ('rnp', 'rbp', 'xit'):
                    successors = [cursor]
                if name in ('cxp', 'clp', 'cgp', 'cbp', 'csp'):
                    calls.append(dict(offset=pc, instruction=name, operands=args))
            if cursor > limit:
                raise ValueError('Instruction overlaps procedure attributes')
            claim(pc, cursor - pc, 'instruction', assembly, opcode=op,
                  mnemonic=name, successors=successors, procedure=proc['number'])
            instructions[pc] = items[pc]
            for target in successors:
                branch_edges.append((pc, target))
                targets.add(target)
                pending.append(target)
        for target in targets:
            if target not in instructions:
                raise ValueError(f'Target ${target:04X} is not an instruction boundary')
        # Only a single zero before an aligned metadata/table word is accepted
        # as unreachable alignment. Other gaps require evidence and new support.
        for pc in range(entry, limit):
            if pc not in occupied:
                if data[pc] or pc % 2 != 1 or pc + 1 not in occupied or occupied.get(pc - 1) is None or items[occupied[pc + 1]]['kind'] not in ('jump-pointer', 'local-size'):
                    raise ValueError(f'Unexplained procedure byte at ${pc:04X}')
                claim(pc, 1, 'alignment', '.byte 0')
    for proc in metadata['procedures']:
        claim(proc['dictionary_offset'], 2, 'dictionary-pointer', f'.word * - {label(proc["attribute_offset"])}')
    claim(len(data) - 2, 2, 'segment-trailer', f'.byte {segment}, {metadata["procedure_count"]}')
    for call in calls:
        if call['instruction'] in ('clp', 'cgp') and not 1 <= call['operands'][0] <= metadata['procedure_count']:
            raise ValueError('In-segment call names a nonexistent procedure')
    if len(occupied) != len(data):
        missing = next(i for i in range(len(data)) if i not in occupied)
        raise ValueError(f'Unclassified segment byte at ${missing:04X}')
    return {'sha256': sha(data), 'size': len(data), 'segment': segment,
            'procedure_count': metadata['procedure_count'], 'procedures': metadata['procedures'],
            'instruction_count': len(instructions), 'coverage_bytes': dict(sum_counts(items)),
            'instructions_by_mnemonic': dict(Counter(i['mnemonic'] for i in instructions.values())),
            'control_flow_edges': branch_edges, 'calls': calls, 'items': [items[i] for i in sorted(items)]}


def sum_counts(items):
    result = Counter()
    for item in items.values():
        result[item['kind']] += item['size']
    return result


def source(report):
    lines = ['; Reconstructed Apple Pascal segment; generated by tools/pcode_source.py.',
             '; See the module documentation for provenance and unresolved call names.',
             '.include "encoding.inc"', '.segment "PCODE"', 'segment_start:']
    entries = {p['entry_offset']: p['number'] for p in report['procedures']}
    for item in report['items']:
        offset = item['offset']
        if offset in entries:
            lines.extend(['', f'; Procedure {entries[offset]}, segment-relative offset ${offset:04X}.'])
        lines.extend([label(offset) + ':', '    ' + item['assembly'] + f' ; {item["kind"]}'])
    lines.append(f'.assert * - segment_start = {report["size"]}, error, "P-code segment size changed"')
    return '\n'.join(lines) + '\n'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('binary', type=Path)
    parser.add_argument('--segment', type=int, required=True)
    parser.add_argument('--source', type=Path)
    parser.add_argument('--report', type=Path)
    parser.add_argument('--interpreter', type=Path, default=ROOT / 'build/disks/components/pcode_primitives.bin')
    args = parser.parse_args()
    verify_interpreter(args.interpreter.read_bytes())
    report = analyze(args.binary.read_bytes(), args.segment)
    report['verified_native_handlers'] = {f'{op:02X}': f'{spec[2]:04X}' for op, spec in SPECS.items()}
    if args.source:
        args.source.write_text(source(report))
    if args.report:
        args.report.write_text(json.dumps(report, indent=2) + '\n')
    print(f"Decoded {report['procedure_count']} procedures, {report['instruction_count']} instructions: {report['coverage_bytes']}")


if __name__ == '__main__':
    main()
