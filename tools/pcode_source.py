#!/usr/bin/env python3
"""Decode supported Apple Pascal p-code into ca65 source with explicit tables.

Only formats checked against the shipped interpreter are accepted.
Unknown instructions and unexplained gaps
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
    0x80: ('abi', '', 0xD6FF),
    0x82: ('adi', '', 0xD71D),
    0x84: ('land', '', 0xD5AF),
    0x86: ('dvi', '', 0xD87D),
    0x88: ('chk', '', 0xD8C2),
    0x8D: ('lor', '', 0xD5C2),
    0x8E: ('modi', '', 0xD8AA),
    0x8F: ('mpi', '', 0xD786),
    0x91: ('ngi', '', 0xD735),
    0x93: ('lnot', '', 0xD5D5),
    0x95: ('sbi', '', 0xD747),
    0x98: ('sqi', '', 0xD7CD),
    0x9A: ('sto', '', 0xD4BC),
    0x9B: ('ixs', '', 0xD98C),
    0x9D: ('lde', 'ub', 0xD442),
    0x9E: ('csp', 'u', 0xE67F),
    0x9F: ('ldcn', '', 0xD2D7),
    0xA1: ('fjp', 'jump', 0xD2A0),
    0xA2: ('inc', 'b', 0xD9CB),
    0xA3: ('ind', 'b', 0xD9AF),
    0xA4: ('ixa', 'b', 0xD9DE),
    0xA5: ('lao', 'b', 0xD384),
    0xA6: ('lsa', 'inline', 0xD929),
    0xA7: ('lae', 'ub', 0xD48C),
    0xA8: ('mov', 'b', 0xD59B),
    0xA9: ('ldo', 'b', 0xD366),
    0xAA: ('sas', 'u', 0xD94B),
    0xAB: ('sro', 'b', 0xD3AA),
    0xAC: ('xjp', 'case', 0xD5E2),
    0xAD: ('rnp', 'u', 0xE371),
    0xAE: ('cip', 'u', 0xE285),
    0xAF: ('equ', 'typed', 0xDE2C),
    0xB0: ('geq', 'typed', 0xDE24),
    0xB1: ('grt', 'typed', 0xDE1C),
    0xB2: ('lda', 'ub', 0xD3EE),
    0xB3: ('ldc', 'words', 0xD4D6),
    0xB4: ('leq', 'typed', 0xDE28),
    0xB5: ('les', 'typed', 0xDE20),
    0xB6: ('lod', 'ub', 0xD3C8),
    0xB7: ('neq', 'typed', 0xDE18),
    0xB8: ('str', 'ub', 0xD41C),
    0xB9: ('ujp', 'jump', 0xD2A8),
    0xBA: ('ldp', '', 0xDA60),
    0xBB: ('stp', '', 0xDAB6),
    0xBC: ('ldm', 'u', 0xD50A),
    0xBD: ('stm', 'u', 0xD539),
    0xBE: ('ldb', '', 0xD567),
    0xBF: ('stb', '', 0xD581),
    0xC0: ('ixp', 'uu', 0xDA1D),
    0xC1: ('rbp', 'u', 0xE35C),
    0xC2: ('cbp', 'u', 0xE32B),
    0xC3: ('equi', '', 0xDFA9),
    0xC4: ('geqi', '', 0xDF7B),
    0xC5: ('gtri', '', 0xDF73),
    0xC6: ('lla', 'b', 0xD315),
    0xC7: ('ldci', 'w', 0xD2DE),
    0xC8: ('leqi', '', 0xDF77),
    0xC9: ('lesi', '', 0xDF6F),
    0xCA: ('ldl', 'b', 0xD2F7),
    0xCB: ('neqi', '', 0xDF7F),
    0xCC: ('stl', 'b', 0xD33B),
    0xCD: ('cxp', 'uu', 0xE306),
    0xCE: ('clp', 'u', 0xE2D3),
    0xCF: ('cgp', 'u', 0xE2EF),
    0xD0: ('lpa', 'inline', 0xD911),
    0xD1: ('ste', 'ub', 0xD467),
    0xD5: ('bpt', 'b', 0xE803),
    0xD6: ('xit', '', 0xD6E4),
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
    for first, last, target in ((0xD8, 0xE8, 0xD2EA), (0xE8, 0xF8, 0xD359),
                                (0xF8, 0xF9, 0xD4AB), (0xF9, 0x100, 0xD4A8)):
        for opcode in range(first, last):
            if word(binary, (opcode - 128) * 2) != target:
                raise ValueError('Short load dispatch differs from verified encoding')


def analyze(data, segment, *, extra_code_roots=()):
    metadata = procedure_dictionary(data, segment)
    if not metadata['valid']:
        raise ValueError('Segment has unresolved procedure metadata')
    items, instructions, calls, branch_edges = {}, {}, [], []
    occupied = {}
    procedures = sorted(metadata['procedures'], key=lambda p: p['entry_offset'])
    unmatched_roots = set(extra_code_roots)

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
        reviewed_roots = [pc for pc in extra_code_roots if entry <= pc < limit]
        unmatched_roots.difference_update(reviewed_roots)
        pending = [entry, proc['exit_offset'], *reviewed_roots]
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
            elif 0xE8 <= op <= 0xF7:
                name, form, args = 'sldo', '', [op - 0xE7]
            elif 0xF8 <= op <= 0xFF:
                name, form, args = 'sind', '', [op - 0xF8]
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
            instruction_end = None
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
            elif form in ('inline', 'words'):
                count = byte()
                if form == 'words':
                    # D4D6 reads count, rounds IP up to even, then skips
                    # 2 * (count + 1). The byte-sized increment must not wrap.
                    if not 1 <= count <= 126:
                        raise ValueError('Unsupported constant-word count')
                    padding = byte() if pc & 1 else 0
                    instruction_end = cursor
                    assembly = f'p_ldc {count}, {pc & 1}, ${padding:02X}'
                    size, kind = count * 2, 'constant-words'
                else:
                    instruction_end = cursor
                    assembly = f'p_{name} {count}'
                    size = count
                    kind = 'string-data' if name == 'lsa' else 'packed-array-data'
                if cursor + size > limit:
                    raise ValueError('Inline data exceeds procedure bounds')
                if size:
                    if form == 'words':
                        values = [f'${word(data, i):04X}' for i in range(cursor, cursor + size, 2)]
                        directive = '.word '
                    else:
                        values = [f'${v:02X}' for v in data[cursor:cursor + size]]
                        directive = '.byte '
                    claim(cursor, size, kind, directive + ', '.join(values), consumer=pc)
                cursor += size
                successors = [cursor]
            else:
                if form == 'typed':
                    tag = byte()
                    if tag not in (2, 4, 6, 8, 10, 12):
                        raise ValueError(f'Unsupported comparison type {tag}')
                    args.append(tag)
                    form = 'b' if tag in (10, 12) else ''
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
                if name in ('cxp', 'clp', 'cgp', 'cip', 'cbp', 'csp'):
                    calls.append(dict(offset=pc, instruction=name, operands=args))
            if cursor > limit:
                raise ValueError('Instruction overlaps procedure attributes')
            claim(pc, (instruction_end or cursor) - pc, 'instruction', assembly, opcode=op,
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
    if unmatched_roots:
        raise ValueError('Extra code root is outside procedure code areas')
    for proc in metadata['procedures']:
        claim(proc['dictionary_offset'], 2, 'dictionary-pointer', f'.word * - {label(proc["attribute_offset"])}')
    claim(len(data) - 2, 2, 'segment-trailer', f'.byte {segment}, {metadata["procedure_count"]}')
    for call in calls:
        if call['instruction'] in ('clp', 'cgp', 'cip') and not 1 <= call['operands'][0] <= metadata['procedure_count']:
            raise ValueError('In-segment call names a nonexistent procedure')
    if len(occupied) != len(data):
        missing = next(i for i in range(len(data)) if i not in occupied)
        raise ValueError(f'Unclassified segment byte at ${missing:04X}')
    return {'sha256': sha(data), 'size': len(data), 'segment': segment,
            'procedure_count': metadata['procedure_count'], 'procedures': metadata['procedures'],
            'extra_code_roots': sorted(set(extra_code_roots)),
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
        if offset in report.get('extra_code_roots', []):
            lines.append('; Statically reviewed code root; runtime reachability is not established.')
        if offset in entries:
            lines.extend(['', f'; Procedure {entries[offset]}, segment-relative offset ${offset:04X}.'])
        lines.extend([label(offset) + ':', '    ' + item['assembly'] + f' ; {item["kind"]}'])
    lines.append(f'.assert * - segment_start = {report["size"]}, error, "P-code segment size changed"')
    return '\n'.join(lines) + '\n'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('binary', type=Path)
    parser.add_argument('--segment', type=int, required=True)
    parser.add_argument('--code-root', type=lambda value: int(value, 0), action='append', default=[],
                        help='Explicit statically reviewed instruction entry; never inferred from gaps')
    parser.add_argument('--source', type=Path)
    parser.add_argument('--report', type=Path)
    parser.add_argument('--interpreter', type=Path, default=ROOT / 'build/disks/components/pcode_primitives.bin')
    args = parser.parse_args()
    verify_interpreter(args.interpreter.read_bytes())
    report = analyze(args.binary.read_bytes(), args.segment, extra_code_roots=args.code_root)
    report['verified_native_handlers'] = {f'{op:02X}': f'{spec[2]:04X}' for op, spec in SPECS.items()}
    if args.source:
        args.source.write_text(source(report))
    if args.report:
        args.report.write_text(json.dumps(report, indent=2) + '\n')
    print(f"Decoded {report['procedure_count']} procedures, {report['instruction_count']} instructions: {report['coverage_bytes']}")


if __name__ == '__main__':
    main()
