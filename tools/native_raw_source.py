#!/usr/bin/env python3
"""Decode fixed-address raw 6502 components from evidenced roots and data spans.

Unlike native Pascal procedures these components have no relocation dictionary.
Never turn unreachable bytes into data automatically: every byte must be owned.
"""
from collections import Counter
import re

from disk_layout import sha
from native_pascal_source import instruction, label


def analyze(data, base, recipe, *, inspect_gaps=False):
    if not data or not 0 <= base < base + len(data) <= 65536:
        raise ValueError('Invalid raw component extent')
    owners, items, edges = {}, {}, []

    def claim(item):
        start, size = item['offset'], item['size']
        if size <= 0 or not 0 <= start < start + size <= len(data):
            raise ValueError('Classification outside raw component')
        for offset in range(start, start+size):
            if offset in owners:
                raise ValueError(f'Raw code/data overlap or target inside operand at +${offset:04X}, owner +${owners[offset]:04X}, new +${start:04X}')
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
    indirect = {entry['offset']: entry for entry in recipe.get('indirect_jumps', [])}
    if len(indirect) != len(recipe.get('indirect_jumps', [])):
        raise ValueError('Duplicate indirect raw jump model')
    used_indirect = set()
    overlaps = {entry['offset']: entry for entry in recipe.get('bit_overlaps', [])}
    if len(overlaps) != len(recipe.get('bit_overlaps', [])):
        raise ValueError('Duplicate raw BIT overlap')
    while pending:
        pc = pending.pop()
        if pc in items and items[pc]['classification'] == 'code':
            continue
        if pc in owners:
            raise ValueError(f'Raw code target enters data or instruction operand at +${pc:04X}')
        if not 0 <= pc < len(data):
            raise ValueError('Raw control flow leaves component without an explicit transfer')
        item = instruction(data, pc)
        name, mode, end = item['mnemonic'], item['mode'], pc + item['size']
        if name == 'brk':
            raise ValueError('BRK needs an interrupt/signature model')
        if pc in overlaps:
            overlap = overlaps[pc]
            if (name != 'bit' or mode not in ('Z', 'Ab') or not overlap.get('evidence')
                    or data[pc:end].hex() != overlap.get('hex')):
                raise ValueError('Raw BIT overlap bytes or evidence disagree')
            claim(dict(item, size=1, instruction_size=item['size'], classification='code',
                       overlap_evidence=overlap['evidence']))
        else:
            claim(dict(item, classification='code'))
        successors = [] if name in ('rts', 'rti', 'jmp') else [end]
        target = None
        if mode == 'Lb':
            target = end + int.from_bytes(data[pc+1:pc+2], 'little', signed=True)
        elif name in ('jsr', 'jmp') and mode == 'Ab':
            target = item['operand_value'] - base
        elif name == 'jmp' and mode == 'In':
            model = indirect.get(pc)
            if not model or not model.get('evidence'):
                raise ValueError('Indirect raw jump requires a reviewed target model')
            vector = item['operand_value']
            # NMOS 6502 wraps the high-byte fetch within the vector's page.
            positions = [vector-base, ((vector & 0xFF00) | ((vector+1) & 255))-base]
            if any(p not in owners or items[owners[p]]['classification'] != 'data'
                   for p in positions):
                raise ValueError('Indirect vector bytes require explicit data ownership')
            address = data[positions[0]] | data[positions[1]] << 8
            if (model.get('vector_address') != vector
                    or model.get('target_address') != address):
                raise ValueError('Indirect vector differs from reviewed addresses')
            target = address-base
            used_indirect.add(pc)
            items[pc]['indirect_evidence'] = model['evidence']
            items[pc]['indirect_vector_offsets'] = positions
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
    if used_indirect != set(indirect):
        raise ValueError('Unused indirect raw jump model')
    missing = [offset for offset in range(len(data)) if offset not in owners]
    if missing and not inspect_gaps:
        raise ValueError(f'Unclassified raw byte at +${missing[0]:04X} ({len(missing)} total)')
    for pc in overlaps:
        item, embedded = items.get(pc, {}), items.get(pc+1, {})
        end = pc + item.get('instruction_size', 0)
        if (not item.get('overlap_evidence') or embedded.get('classification') != 'code'
                or embedded.get('size') != item['instruction_size']-1
                or items.get(end, {}).get('classification') != 'code'):
            raise ValueError('Raw BIT overlap needs independently decoded embedded and following instructions')
    ordered = [items[offset] for offset in sorted(items)]
    counts = Counter()
    for item in ordered:
        counts[item['classification']] += item['size']
    return dict(base=base, size=len(data), sha256=sha(data), roots=roots,
                coverage_bytes=dict(counts), instruction_count=sum(i['classification']=='code' for i in ordered),
                items=ordered, edges=edges, unclassified_offsets=missing)


def source(data, report):
    if sha(data) != report['sha256']:
        raise ValueError('Raw source input differs from analysis')
    if report.get('unclassified_offsets'):
        raise ValueError('Cannot emit raw source with unclassified bytes')
    lines = ['.setcpu "6502"']
    if any('overlap_evidence' in item for item in report['items']):
        lines += ['; BIT operand bytes are emitted by the independently reachable next instruction.',
                  '.macro bit_abs_overlap', '    .byte $2C', '.endmacro',
                  '.macro bit_zp_overlap', '    .byte $24', '.endmacro']
    lines += ['.segment "RAW_NATIVE"', 'component_start:']
    for item in report['items']:
        offset = item['offset']
        lines += [label(offset) + ':']
        if item['classification'] == 'code':
            assembly = item['assembly']
            if 'overlap_evidence' in item:
                macro = 'bit_abs_overlap' if item['mode'] == 'Ab' else 'bit_zp_overlap'
                assembly = macro+' ; '+assembly
            lines += ['    '+assembly+f' ; ${report["base"]+offset:04X}']
        else:
            lines += ['; '+item['kind']+' — '+item['evidence']]
            for start in range(offset, offset+item['size'], 16):
                raw = data[start:min(start+16, offset+item['size'])]
                lines += ['    .byte '+','.join(f'${b:02X}' for b in raw)]
    lines += [f'.assert * - component_start = {len(data)}, error, "Raw component size"']
    return '\n'.join(lines)+'\n'


def source_slice(data, report, start, end):
    """Emit a fully classified interval of a larger, possibly incomplete audit.

    Omitted bytes are not emitted as padding or silently called data. The caller
    must map only this interval and retain the complete audit separately.
    """
    if sha(data) != report['sha256'] or not 0 <= start < end <= len(data):
        raise ValueError('Invalid raw source slice or changed analysis input')
    selected, cursor, constants = [], start, {}

    def reference(match):
        offset = int(match.group()[2:], 16)
        if start <= offset < end:
            return label(offset-start)
        name = 'EXT_'+label(offset)
        constants[name] = offset-start
        return name

    for item in report['items']:
        if item['offset'] < end and item['offset']+item['size'] > start:
            if item['offset'] != cursor or cursor+item['size'] > end:
                raise ValueError('Raw source slice crosses a gap or item boundary')
            copied = dict(item, offset=cursor-start)
            if copied['classification'] == 'code':
                copied['assembly'] = re.sub(r'L_[0-9A-F]+', reference, copied['assembly'])
            selected.append(copied)
            cursor += item['size']
    if cursor != end:
        raise ValueError('Raw source slice contains unclassified bytes')
    fragment = data[start:end]
    sliced = dict(report, base=report['base']+start, size=len(fragment), sha256=sha(fragment),
                  items=selected, unclassified_offsets=[])
    definitions = ''.join(f'{name} = component_start + ({offset})\n'
                          for name, offset in sorted(constants.items()))
    return definitions+source(fragment, sliced)
