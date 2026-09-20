#!/usr/bin/env python3
"""Reconstruct native Pascal metadata and evidenced copies in encoded bank tails."""
import argparse
from collections import Counter
import json
import re
import subprocess

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from native_raw_source import analyze
from native_relocations import native_relocations
from pascal_inventory import procedure_dictionary
from storage_encoding import transform

EVIDENCE = 'docs/encoded-native-overlay-tail.md'
COPY_START, COPY_END, SOURCE_START = 0x638, 0x800, 0x438


def audit(raw, body):
    if len(raw) != 2048 or sha(raw) != body['sha256']:
        raise ValueError('Tail input differs from the reviewed full body')
    dictionary = procedure_dictionary(raw[:COPY_START], 1)
    if not dictionary['valid'] or dictionary['procedure_count'] != 1:
        raise ValueError('Expected one valid native procedure')
    proc = dictionary['procedures'][0]
    if (proc['representation'] != 'native-6502' or proc['entry_offset'] != 0
            or proc['attribute_offset'] != 0x632 or proc['lexical_level'] != 0):
        raise ValueError('Native footer does not describe the loader entry')
    relocation = native_relocations(raw[:COPY_START], proc)
    if (relocation['tables_start'] != 0x628 or any(g['count'] for g in relocation['groups'])
            or raw[0x627] != 0):
        raise ValueError('Unexpected native relocation tables or alignment')
    if int.from_bytes(raw[0x5fa:0x5fc], 'little') != body['base']+0x610:
        raise ValueError('Original wipe pointer differs from reviewed loop address')
    if raw[0x7fa:0x7fc] != b'\0\0':
        raise ValueError('Copied wipe pointer is not the reviewed zero initializer')
    differences = [i for i in range(COPY_START,COPY_END) if raw[i] != raw[i-512]]
    if differences != [0x7fa,0x7fb]:
        raise ValueError('Native suffix differs outside the two reviewed pointer bytes')
    fields = [dict(offset=0x627,size=1,kind='native-alignment'),
              *[dict(offset=g['count_offset'],size=2,kind='native-relocation-count-'+g['kind'])
                for g in reversed(relocation['groups'])],
              dict(offset=0x630,size=2,kind='native-entry-displacement'),
              dict(offset=0x632,size=2,kind='native-attributes'),
              dict(offset=0x634,size=2,kind='procedure-dictionary-pointer'),
              dict(offset=0x636,size=2,kind='segment-trailer')]
    for field in fields:
        field.update(classification='data',hex=raw[field['offset']:field['offset']+field['size']].hex())
    copies = []
    for original in body['items']:
        start = max(original['offset'], SOURCE_START)
        end = min(original['offset']+original['size'], COPY_END-512)
        if end <= start:
            continue
        item = dict(offset=start+512,size=end-start,source_offset=start,
                    source_item_offset=original['offset'],source_item_size=original['size'],
                    classification=original['classification'])
        if original['classification'] == 'code':
            item.update(assembly=original['assembly'],mnemonic=original['mnemonic'],mode=original['mode'],
                        source_instruction_hex=raw[original['offset']:original['offset']+original['size']].hex())
            partial = start != original['offset'] or end != original['offset']+original['size']
            if partial:
                if start == 0x438 and end == 0x439 and original['offset'] == 0x437 and original['mnemonic'] == 'bcc':
                    item['fragment'] = 'bcc-displacement-only'
                elif start == 0x5ff and end == 0x600 and original['size'] == 3 and original['assembly'] == 'lda a:$C083':
                    item['fragment'] = 'lda-absolute-opcode-only'
                else:
                    raise ValueError('Unreviewed partial instruction at copy boundary')
        else:
            item.update(kind=original['kind'],evidence=original['evidence'])
            if start <= 0x5fa < end:
                if start != 0x5fa or end != 0x5fc or original['kind'] != 'wipe-start-address':
                    raise ValueError('Copied pointer lacks complete data-field ownership')
                item['evidence'] = 'Copied wipe-start-address field retains a zero initializer; the primary body stores its loop address here.'
        copies.append(item)
    items = fields+copies
    counts, owners, spans = Counter(), set(), []
    for item in items:
        start, end = item['offset'], item['offset']+item['size']
        for p in range(start,end):
            if p in owners:
                raise ValueError('Tail ownership overlaps')
            owners.add(p)
        counts[item['classification']] += item['size']
        # Keep metadata separate: copied instructions retain their source origin.
        if spans and spans[-1][1] == start and start != COPY_START:
            spans[-1][1] = end
        else:
            spans.append([start,end])
    return dict(sha256=sha(raw),base=body['base'],dictionary=dictionary,relocation=relocation,
                copy=dict(start=COPY_START,end=COPY_END,source_start=SOURCE_START,
                          differing_offsets=differences),items=items,selected_ranges=spans,
                coverage_bytes=dict(counts),
                full_instruction_count=sum(i['classification']=='code' and 'fragment' not in i for i in copies),
                partial_instruction_count=sum('fragment' in i for i in copies),
                unresolved_tail_offsets=[p for p in range(0x627,COPY_END) if p not in owners])


def source(raw, report, start, end):
    if sha(raw) != report['sha256'] or not 0x627 <= start < end <= COPY_END:
        raise ValueError('Invalid tail source extent or changed input')
    copied = start >= COPY_START
    origin = report['base']+start-(512 if copied else 0)
    lines = ['; Evidence: '+EVIDENCE, '.setcpu "6502"', '.segment "RAW_NATIVE"',
             f'.org ${origin:04X}', 'component_start:']
    cursor = start
    for item in report['items']:
        if not start <= item['offset'] < end:
            continue
        if item['offset'] != cursor or cursor+item['size'] > end:
            raise ValueError('Tail source range crosses an item or unresolved gap')
        cursor += item['size']
        lines += [f'; Stored bank offset ${item["offset"]:04X}'+
                  (f'; original +${item["source_item_offset"]:04X}' if copied else '')]
        if item['classification'] == 'code':
            asm = re.sub(r'L_([0-9A-F]+)',lambda m:f'${report["base"]+int(m[1],16):04X}',item['assembly'])
            if item.get('fragment') == 'bcc-displacement-only':
                lines += [f'; {asm}: only the displacement survives; missing opcode $90.',
                          f'    .byte (${report["base"]+0x43c:04X} - ${report["base"]+0x439:04X})']
            elif item.get('fragment') == 'lda-absolute-opcode-only':
                lines += [f'; {asm}: only opcode survives; operands $83,$C0 lie beyond the copied extent.',
                          '    .byte $AD ; LDA absolute opcode fragment']
            else:
                lines += ['    '+asm]
        else:
            lines += ['; '+item['kind']]
            data = raw[item['offset']:cursor]
            if item['kind'] in ('native-entry-displacement','procedure-dictionary-pointer') or item['kind'].startswith('native-relocation-count-'):
                lines += [f'    .word ${int.from_bytes(data,"little"):04X}']
            else:
                lines += ['    .byte '+','.join(f'${b:02X}' for b in data)]
    if cursor != end:
        raise ValueError('Tail source range contains unresolved bytes')
    lines += [f'.assert * - component_start = {end-start}, error, "Tail slice size"']
    return '\n'.join(lines)+'\n', origin


def prepare(variant, verify=False):
    if not (ROOT/EVIDENCE).is_file():
        raise ValueError('Missing tail classification evidence')
    recipe = json.loads((ROOT/'src/native/evidence'/f'encoded_body_{variant}.json').read_text())
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    origin = recipe['origin']
    disk = next(d for d in manifest['disks'] if d['id'] == origin['disk'])
    image = (ROOT/'build/disks'/disk['filename']).read_bytes()
    if sha(image) != disk['sha256']:
        raise ValueError('Rebuild exact baseline before tail preparation')
    stored = block_bytes(image,origin['block'],origin['block']+4)
    if sha(stored) != recipe['sha256']:
        raise ValueError('Bank differs from reviewed evidence')
    raw = transform(stored,recipe['storage_encoding'],decode=True)
    body = analyze(raw,recipe['base'],recipe,inspect_gaps=True)
    report = audit(raw,body)
    report.update(origin=origin,storage_sha256=sha(stored),classification_evidence=EVIDENCE)
    artifacts = {}
    output = ROOT/'build/raw-preparation'/('encoded_tail_'+variant)
    output.mkdir(parents=True,exist_ok=True)
    for start,end in report['selected_ranges']:
        name = f'encoded_tail_{variant}_{start:04x}'
        stem = ROOT/'src/native'/name
        text, address = source(raw,report,start,end)
        config = (f'MEMORY {{ IMAGE: start = ${address:04X}, size = {end-start}, file = %O; }}\n'
                  'SEGMENTS { RAW_NATIVE: load = IMAGE, type = ro; }\n')
        work = output/name
        work.with_suffix('.s').write_text(text)
        work.with_suffix('.cfg').write_text(config)
        subprocess.run(['ca65',str(work.with_suffix('.s')),'-o',str(work.with_suffix('.o'))],check=True)
        subprocess.run(['ld65','-C',str(work.with_suffix('.cfg')),str(work.with_suffix('.o')),
                        '-o',str(work.with_suffix('.bin'))],check=True)
        binary = work.with_suffix('.bin').read_bytes()
        encoding = dict(recipe['storage_encoding'],offset=recipe['storage_encoding']['offset']+start,evidence=EVIDENCE)
        if binary != raw[start:end] or transform(binary,encoding) != stored[start:end]:
            raise ValueError('Tail source or storage encoding differs')
        mappings, position = [], start
        while position < end:
            logical = origin['block']*512+position
            length = min(end-position,256-logical%256)
            mappings.append(dict(disk=disk['id'],offset=logical_sector_offset(logical//256)+logical%256,
                                 size=length,input_offset=position-start))
            position += length
        adoption = dict(name=name,source=str(stem.with_suffix('.s').relative_to(ROOT)),
                        config=str(stem.with_suffix('.cfg').relative_to(ROOT)),
                        storage_encoding=encoding,mappings=mappings)
        artifacts[stem.with_suffix('.s')] = text
        artifacts[stem.with_suffix('.cfg')] = config
        artifacts[stem.with_suffix('.adopt.json')] = json.dumps(adoption,indent=2)+'\n'
    report['byte_identical_assembly'] = True
    artifacts[ROOT/'docs/reference/raw-modules'/f'encoded_tail_{variant}.json'] = json.dumps(report,indent=2)+'\n'
    for path,content in artifacts.items():
        if verify:
            if not path.is_file() or path.read_text() != content:
                raise ValueError(f'Tail artifact differs: {path}')
        elif path.exists():
            raise ValueError(f'Tail artifact already exists: {path}')
    if not verify:
        for path,content in artifacts.items():
            path.write_text(content)
    print(json.dumps(dict(variant=variant,coverage=report['coverage_bytes'],
                          full_instructions=report['full_instruction_count'],
                          partial_instructions=report['partial_instruction_count'],
                          unresolved_tail_bytes=len(report['unresolved_tail_offsets']))))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('variant',choices=('play','alternate'))
    parser.add_argument('--verify',action='store_true')
    args = parser.parse_args()
    prepare(args.variant,args.verify)
