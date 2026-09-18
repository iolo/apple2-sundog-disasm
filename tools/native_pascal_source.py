#!/usr/bin/env python3
"""Control-flow-based native Pascal decoding with explicit data evidence.

Relocation lists are parsed separately. Unclaimed bytes remain errors; reviewed
extra code roots and data ranges must come from a per-module evidence recipe.
"""
from collections import Counter
import struct

from native_relocations import native_relocations
from pascal_inventory import word

# NMOS 6502 encoding facts, cross-checked with ca65 by test_native_pascal_source.py.
OPCODES = {
    0x69: ('adc', 'Im'),
    0x65: ('adc', 'Z'),
    0x75: ('adc', 'Zx'),
    0x6D: ('adc', 'Ab'),
    0x7D: ('adc', 'Ax'),
    0x79: ('adc', 'Ay'),
    0x61: ('adc', 'Ix'),
    0x71: ('adc', 'Iy'),
    0x29: ('and', 'Im'),
    0x25: ('and', 'Z'),
    0x35: ('and', 'Zx'),
    0x2D: ('and', 'Ab'),
    0x3D: ('and', 'Ax'),
    0x39: ('and', 'Ay'),
    0x21: ('and', 'Ix'),
    0x31: ('and', 'Iy'),
    0x0A: ('asl', 'A'),
    0x06: ('asl', 'Z'),
    0x16: ('asl', 'Zx'),
    0x0E: ('asl', 'Ab'),
    0x1E: ('asl', 'Ax'),
    0x24: ('bit', 'Z'),
    0x2C: ('bit', 'Ab'),
    0x10: ('bpl', 'Lb'),
    0x30: ('bmi', 'Lb'),
    0x50: ('bvc', 'Lb'),
    0x70: ('bvs', 'Lb'),
    0x90: ('bcc', 'Lb'),
    0xB0: ('bcs', 'Lb'),
    0xD0: ('bne', 'Lb'),
    0xF0: ('beq', 'Lb'),
    0x00: ('brk', 'Ip'),
    0xC9: ('cmp', 'Im'),
    0xC5: ('cmp', 'Z'),
    0xD5: ('cmp', 'Zx'),
    0xCD: ('cmp', 'Ab'),
    0xDD: ('cmp', 'Ax'),
    0xD9: ('cmp', 'Ay'),
    0xC1: ('cmp', 'Ix'),
    0xD1: ('cmp', 'Iy'),
    0xE0: ('cpx', 'Im'),
    0xE4: ('cpx', 'Z'),
    0xEC: ('cpx', 'Ab'),
    0xC0: ('cpy', 'Im'),
    0xC4: ('cpy', 'Z'),
    0xCC: ('cpy', 'Ab'),
    0xC6: ('dec', 'Z'),
    0xD6: ('dec', 'Zx'),
    0xCE: ('dec', 'Ab'),
    0xDE: ('dec', 'Ax'),
    0x49: ('eor', 'Im'),
    0x45: ('eor', 'Z'),
    0x55: ('eor', 'Zx'),
    0x4D: ('eor', 'Ab'),
    0x5D: ('eor', 'Ax'),
    0x59: ('eor', 'Ay'),
    0x41: ('eor', 'Ix'),
    0x51: ('eor', 'Iy'),
    0x18: ('clc', 'Ip'),
    0x38: ('sec', 'Ip'),
    0x58: ('cli', 'Ip'),
    0x78: ('sei', 'Ip'),
    0xB8: ('clv', 'Ip'),
    0xD8: ('cld', 'Ip'),
    0xF8: ('sed', 'Ip'),
    0xE6: ('inc', 'Z'),
    0xF6: ('inc', 'Zx'),
    0xEE: ('inc', 'Ab'),
    0xFE: ('inc', 'Ax'),
    0x4C: ('jmp', 'Ab'),
    0x6C: ('jmp', 'In'),
    0x20: ('jsr', 'Ab'),
    0xA9: ('lda', 'Im'),
    0xA5: ('lda', 'Z'),
    0xB5: ('lda', 'Zx'),
    0xAD: ('lda', 'Ab'),
    0xBD: ('lda', 'Ax'),
    0xB9: ('lda', 'Ay'),
    0xA1: ('lda', 'Ix'),
    0xB1: ('lda', 'Iy'),
    0xA2: ('ldx', 'Im'),
    0xA6: ('ldx', 'Z'),
    0xB6: ('ldx', 'Zy'),
    0xAE: ('ldx', 'Ab'),
    0xBE: ('ldx', 'Ay'),
    0xA0: ('ldy', 'Im'),
    0xA4: ('ldy', 'Z'),
    0xB4: ('ldy', 'Zx'),
    0xAC: ('ldy', 'Ab'),
    0xBC: ('ldy', 'Ax'),
    0x4A: ('lsr', 'A'),
    0x46: ('lsr', 'Z'),
    0x56: ('lsr', 'Zx'),
    0x4E: ('lsr', 'Ab'),
    0x5E: ('lsr', 'Ax'),
    0xEA: ('nop', 'Ip'),
    0x09: ('ora', 'Im'),
    0x05: ('ora', 'Z'),
    0x15: ('ora', 'Zx'),
    0x0D: ('ora', 'Ab'),
    0x1D: ('ora', 'Ax'),
    0x19: ('ora', 'Ay'),
    0x01: ('ora', 'Ix'),
    0x11: ('ora', 'Iy'),
    0xAA: ('tax', 'Ip'),
    0x8A: ('txa', 'Ip'),
    0xCA: ('dex', 'Ip'),
    0xE8: ('inx', 'Ip'),
    0xA8: ('tay', 'Ip'),
    0x98: ('tya', 'Ip'),
    0x88: ('dey', 'Ip'),
    0xC8: ('iny', 'Ip'),
    0x2A: ('rol', 'A'),
    0x26: ('rol', 'Z'),
    0x36: ('rol', 'Zx'),
    0x2E: ('rol', 'Ab'),
    0x3E: ('rol', 'Ax'),
    0x6A: ('ror', 'A'),
    0x66: ('ror', 'Z'),
    0x76: ('ror', 'Zx'),
    0x6E: ('ror', 'Ab'),
    0x7E: ('ror', 'Ax'),
    0x40: ('rti', 'Ip'),
    0x60: ('rts', 'Ip'),
    0xE9: ('sbc', 'Im'),
    0xE5: ('sbc', 'Z'),
    0xF5: ('sbc', 'Zx'),
    0xED: ('sbc', 'Ab'),
    0xFD: ('sbc', 'Ax'),
    0xF9: ('sbc', 'Ay'),
    0xE1: ('sbc', 'Ix'),
    0xF1: ('sbc', 'Iy'),
    0x85: ('sta', 'Z'),
    0x95: ('sta', 'Zx'),
    0x8D: ('sta', 'Ab'),
    0x9D: ('sta', 'Ax'),
    0x99: ('sta', 'Ay'),
    0x81: ('sta', 'Ix'),
    0x91: ('sta', 'Iy'),
    0x9A: ('txs', 'Ip'),
    0xBA: ('tsx', 'Ip'),
    0x48: ('pha', 'Ip'),
    0x68: ('pla', 'Ip'),
    0x08: ('php', 'Ip'),
    0x28: ('plp', 'Ip'),
    0x86: ('stx', 'Z'),
    0x96: ('stx', 'Zy'),
    0x8E: ('stx', 'Ab'),
    0x84: ('sty', 'Z'),
    0x94: ('sty', 'Zx'),
    0x8C: ('sty', 'Ab'),
}

WIDTH = dict(Im=2, Z=2, Zx=2, Zy=2, Ab=3, Ax=3, Ay=3, Ix=2, Iy=2, In=3, Lb=2, A=1, Ip=1)


def label(offset):
    return f'L_{offset:04X}'


def instruction(data, pc):
    if data[pc] not in OPCODES:
        raise ValueError(f'Unsupported native opcode ${data[pc]:02X} at ${pc:04X}')
    name, mode = OPCODES[data[pc]]
    size = WIDTH[mode]
    if pc + size > len(data):
        raise ValueError('Truncated native instruction')
    byte = data[pc + 1] if size > 1 else 0
    value = word(data, pc + 1) if size == 3 else byte
    if mode == 'Lb':
        target = pc + 2 + struct.unpack('b', data[pc + 1:pc + 2])[0]
        operand = label(target)
    else:
        operand = dict(Im=f'#${byte:02X}', Z=f'${byte:02X}', Zx=f'${byte:02X},x',
                       Zy=f'${byte:02X},y', Ab=f'a:${value:04X}', Ax=f'a:${value:04X},x',
                       Ay=f'a:${value:04X},y', Ix=f'(${byte:02X},x)', Iy=f'(${byte:02X}),y',
                       In=f'(${value:04X})', A='a', Ip='')[mode]
    return dict(offset=pc, size=size, mnemonic=name, mode=mode, operand_value=value,
                assembly=name + (' ' + operand if operand else ''))


def analyze_native(data, procedure, evidence=None, *, inspect_gaps=False):
    evidence = evidence or {}
    parsed = native_relocations(data, procedure)
    entry, limit = parsed['entry'], parsed['tables_start']
    items, owners, edges, external_edges = {}, {}, [], []
    reloc = {p['target']: dict(p, relocation_kind=g['kind']) for g in parsed['groups'] for p in g['pointers']}

    def claim(item):
        start, size = item['offset'], item['size']
        if start < entry or size <= 0 or start + size > procedure['attribute_offset'] + 2:
            raise ValueError('Native classification exceeds procedure bounds')
        for offset in range(start, start + size):
            if offset in owners:
                raise ValueError(f'Native code/data overlap at ${offset:04X}')
            owners[offset] = start
        items[start] = item

    for region in evidence.get('data', []):
        start, size = region['offset'], region['size']
        if not region.get('evidence') or start < entry or start + size > limit:
            raise ValueError('Native data requires evidence and body bounds')
        if size:
            raw = data[start:start+size]
            claim(dict(offset=start, size=size, kind=region['kind'],
                       assembly='.byte ' + ', '.join(f'${v:02X}' for v in raw), evidence=region['evidence']))
    pending = [entry, *evidence.get('code_roots', [])]
    while pending:
        pc = pending.pop()
        if pc in items and items[pc]['kind'] == 'native-instruction':
            continue
        if not entry <= pc < limit:
            raise ValueError(f'Native code target ${pc:04X} outside procedure body')
        if pc in owners:
            raise ValueError(f'Native control flow enters data/operand at ${pc:04X}')
        item = instruction(data, pc)
        end = pc + item['size']
        if end > limit:
            raise ValueError('Native instruction enters relocation lists')
        name, mode = item['mnemonic'], item['mode']
        if name == 'brk':
            raise ValueError('Native BRK requires explicit interrupt-signature handling')
        successors = [] if name in ('rts', 'rti', 'brk', 'jmp') else [end]
        if pc in evidence.get('nonfallthrough_branches', []):
            if mode != 'Lb' or not evidence.get('branch_evidence'):
                raise ValueError('Branch fall-through override requires branch evidence')
            successors = []
        if mode == 'Lb':
            successors.append(pc + 2 + struct.unpack('b', data[pc+1:pc+2])[0])
        elif name in ('jmp', 'jsr') and mode == 'Ab':
            operand = reloc.get(pc + 1)
            if operand and operand['relocation_kind'] in ('procedure', 'segment'):
                target = item['operand_value'] + (entry if operand['relocation_kind'] == 'procedure' else 0)
                if entry <= target < limit:
                    successors.append(target)
                else:
                    external_edges.append(dict(source=pc, target=target, kind='segment-code'))
            else:
                external_edges.append(dict(source=pc, target=item['operand_value'],
                                           kind='fixed-address' if not operand else operand['relocation_kind']))
        elif name == 'jmp' and mode == 'In':
            external_edges.append(dict(source=pc, target=item['operand_value'], kind='indirect'))
        for target in evidence.get('extra_successors', {}).get(str(pc), []):
            successors.append(target)
        item.update(kind='native-instruction', procedure=procedure['number'], successors=successors)
        if pc + 1 in reloc:
            item['relocation'] = reloc[pc+1]
            item['assembly'] += f" ; {reloc[pc+1]['relocation_kind']}-relative operand"
        claim(item)
        for target in successors:
            edges.append([pc, target])
            pending.append(target)
    # A single byte before an aligned relocation list is an alignment byte only
    # when the previous instruction ends there and execution does not fall through.
    if limit % 2 == 0 and limit - 1 not in owners and data[limit - 1] == 0:
        previous = items.get(owners.get(limit - 2))
        if previous and previous['kind'] == 'native-instruction' and previous['offset'] + previous['size'] == limit - 1 and previous['mnemonic'] in ('rts', 'rti', 'jmp'):
            claim(dict(offset=limit - 1, size=1, kind='native-alignment', assembly='.byte 0'))
    gaps = []
    for pc in range(entry, limit):
        if pc not in owners:
            if gaps and gaps[-1]['offset'] + gaps[-1]['size'] == pc:
                gaps[-1]['size'] += 1
            else:
                gaps.append(dict(offset=pc, size=1))
    if gaps and not inspect_gaps:
        raise ValueError(f'Unclassified native bytes in procedure {procedure["number"]}: {gaps}')
    # Each relocation pointer refers to a word, often inside an instruction.
    # Use a start label plus byte offset instead of inserting a label into it.
    def reference(offset):
        if offset not in owners:
            if inspect_gaps:
                return f'${offset:04X}'
            raise ValueError('Relocation target lacks code/data owner')
        start = owners[offset]
        if owners.get(offset + 1) != start:
            raise ValueError('Relocation word straddles classified items')
        owner = items[start]
        if owner['kind'] == 'native-instruction' and (offset != start + 1 or owner['size'] != 3):
            raise ValueError('Relocation is not a complete native address operand')
        return label(start) + (f' + {offset-start}' if offset != start else '')
    for group in parsed['groups']:
        claim(dict(offset=group['count_offset'], size=2, kind='relocation-count',
                   assembly=f'.word {group["count"]} ; {group["kind"]} relocations'))
        for pointer in group['pointers']:
            target = pointer['target']
            claim(dict(offset=pointer['offset'], size=2, kind='relocation-pointer',
                       assembly=f'.word * - ({reference(target)})', target=target,
                       relocation_kind=group['kind']))
    attr = procedure['attribute_offset']
    claim(dict(offset=attr-2, size=2, kind='native-entry-pointer', assembly=f'.word * - {label(entry)}'))
    claim(dict(offset=attr, size=2, kind='native-attributes', assembly=f'.byte 0, {procedure["lexical_level"] & 255}'))
    return dict(items=[items[i] for i in sorted(items)], relocation=parsed,
                control_flow_edges=edges, external_edges=external_edges, gaps=gaps)


def mixed_decoder(data, metadata, evidence=None):
    """Discover cross-procedure roots from relocated direct calls before decoding."""
    import copy
    evidence = copy.deepcopy(evidence or {})
    procedures = [p for p in metadata['procedures'] if p['representation'] == 'native-6502']
    bodies = {p['number']: (p['entry_offset'], native_relocations(data, p)['tables_start']) for p in procedures}
    while True:
        changed = False
        for proc in procedures:
            details = evidence.setdefault(str(proc['number']), {})
            partial = analyze_native(data, proc, details, inspect_gaps=True)
            for edge in partial['external_edges']:
                if edge['kind'] != 'segment-code':
                    continue
                matches = [number for number, (lo, hi) in bodies.items() if lo <= edge['target'] < hi]
                if len(matches) != 1:
                    raise ValueError('Relocated native branch has no native procedure owner')
                target_details = evidence.setdefault(str(matches[0]), {})
                roots = target_details.setdefault('code_roots', [])
                if edge['target'] not in roots:
                    roots.append(edge['target'])
                    changed = True
        if not changed:
            break
    return lambda raw, proc: analyze_native(raw, proc, evidence.get(str(proc['number']), {}))
