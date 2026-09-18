#!/usr/bin/env python3
"""Decode fixed-address raw 6502 components from evidenced roots and data spans.

Unlike native Pascal procedures these components have no relocation dictionary.
Never turn unreachable bytes into data automatically: every byte must be owned.
"""
from collections import Counter

from disk_layout import sha
from native_pascal_source import instruction, label


def analyze(data, base, recipe):
    if not data or not 0 <= base < base + len(data) <= 65536:
        raise ValueError('Invalid raw component extent')
    owners, items, edges = {}, {}, []

    def claim(item):
        start, size = item['offset'], item['size']
        if size <= 0 or not 0 <= start < start + size <= len(data):
            raise ValueError('Classification outside raw component')
        for offset in range(start, start+size):
            if offset in owners:
                raise ValueError('Raw code/data overlap or target inside operand')
            owners[offset] = start
        items[start] = item

    for region in recipe.get('data', []):
        if not region.get('evidence') or not region.get('kind'):
            raise ValueError('Raw data requires classification evidence')
        claim(dict(region, classification='data'))
    roots = recipe.get('roots', [])
    if not roots or any(not root.get('evidence') for root in roots):
        raise ValueError('Raw code roots require evidence')
    pending = [root['offset'] for root in roots]
    external = recipe.get('external_targets', {})
    while pending:
        pc = pending.pop()
        if pc in items and items[pc]['classification'] == 'code':
            continue
        if pc in owners:
            raise ValueError('Raw code target enters data or instruction operand')
        if not 0 <= pc < len(data):
            raise ValueError('Raw control flow leaves component without an explicit transfer')
        item = instruction(data, pc)
        name, mode, end = item['mnemonic'], item['mode'], pc + item['size']
        if name == 'brk':
            raise ValueError('BRK needs an interrupt/signature model')
        claim(dict(item, classification='code'))
        successors = [] if name in ('rts', 'rti', 'jmp') else [end]
        target = None
        if mode == 'Lb':
            target = end + int.from_bytes(data[pc+1:pc+2], 'little', signed=True)
        elif name in ('jsr', 'jmp') and mode == 'Ab':
            target = item['operand_value'] - base
        elif name == 'jmp' and mode == 'In':
            raise ValueError('Indirect raw jump requires a reviewed target model')
        if target is not None:
            if 0 <= target < len(data):
                successors.append(target)
                if mode == 'Ab':
                    items[pc]['assembly'] = name + ' ' + label(target)
            else:
                address = base + target
                if not external.get(str(address)):
                    raise ValueError(f'External raw target ${address:04X} requires evidence')
                edges.append(dict(source=pc, external_address=address, evidence=external[str(address)]))
        for destination in successors:
            edges.append(dict(source=pc, target=destination))
            pending.append(destination)
    missing = [offset for offset in range(len(data)) if offset not in owners]
    if missing:
        raise ValueError(f'Unclassified raw byte at +${missing[0]:04X} ({len(missing)} total)')
    ordered = [items[offset] for offset in sorted(items)]
    counts = Counter()
    for item in ordered:
        counts[item['classification']] += item['size']
    return dict(base=base, size=len(data), sha256=sha(data), roots=roots,
                coverage_bytes=dict(counts), instruction_count=sum(i['classification']=='code' for i in ordered),
                items=ordered, edges=edges)


def source(data, report):
    if sha(data) != report['sha256']:
        raise ValueError('Raw source input differs from analysis')
    lines = ['.setcpu "6502"', '.segment "RAW_NATIVE"', 'component_start:']
    for item in report['items']:
        offset = item['offset']
        lines += [label(offset) + ':']
        if item['classification'] == 'code':
            lines += ['    '+item['assembly']+f' ; ${report["base"]+offset:04X}']
        else:
            lines += ['; '+item['kind']+' — '+item['evidence']]
            for start in range(offset, offset+item['size'], 16):
                raw = data[start:min(start+16, offset+item['size'])]
                lines += ['    .byte '+','.join(f'${b:02X}' for b in raw)]
    lines += [f'.assert * - component_start = {len(data)}, error, "Raw component size"']
    return '\n'.join(lines)+'\n'
