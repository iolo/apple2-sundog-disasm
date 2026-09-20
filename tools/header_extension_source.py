#!/usr/bin/env python3
"""Reconstruct evidenced data fields after the Pascal header's first 288 bytes."""
import argparse
import json
import subprocess

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha

EVIDENCE = 'docs/pascal-header-extensions.md'
MANUAL = 'https://markbessey.blog/wp-content/uploads/2025/05/apple_pascal_operating_system_reference_manual_hq_text.pdf#page=276'
PROMPT = b'Command: E(dit, R(un, F(ile, C(omp, L(ink, X(ecute, A(ssem, ? [1.2]'
ORIGINS = [('disk1',84,0x66400000),('disk1',85,0x66400000),('disk1',103,0),
           ('disk1',140,0xffc00000),('disk1',157,0xeec00000),('disk1',251,0x44),
           ('disk2',103,0),('disk2',140,0xffc00000)]


def classify(raw, expected_mask, library=False):
    if len(raw) != 512:
        raise ValueError('Expected a complete Pascal header block')
    mask = int.from_bytes(raw[288:292],'little')
    if mask != expected_mask:
        raise ValueError('Intrinsic-segment mask differs from reviewed header')
    items = [dict(offset=288,size=4,kind='intrinsic-segment-set',value=mask,
                  segments=[bit for bit in range(32) if mask & (1<<bit)])]
    zero_end = 374 if library else 432
    if any(raw[292:zero_end]):
        raise ValueError('Nonzero library storage needs separate classification')
    items.append(dict(offset=292,size=zero_end-292,kind='zero-library-storage'))
    if library:
        start = 418
        if raw[start] != len(PROMPT) or raw[start+1:start+1+len(PROMPT)] != PROMPT:
            raise ValueError('Counted library prompt differs from reviewed string')
        items += [dict(offset=start,size=1,kind='prompt-length',value=len(PROMPT)),
                  dict(offset=start+1,size=len(PROMPT),kind='prompt-text',text=PROMPT.decode('ascii'))]
    else:
        start = 432
        length = raw[start]
        if length > 79 or any(not 32 <= c < 127 for c in raw[start+1:start+1+length]):
            raise ValueError('Invalid bounded header comment')
        items.append(dict(offset=start,size=1,kind='comment-length',value=length))
        if length:
            items.append(dict(offset=start+1,size=length,kind='comment-text',text=raw[start+1:start+1+length].decode('ascii')))
        end = start+1+length
        if any(raw[end:]):
            raise ValueError('Nonzero comment remainder needs separate classification')
        if end < 512:
            items.append(dict(offset=end,size=512-end,kind='zero-comment-storage'))
    owned = {p for item in items for p in range(item['offset'],item['offset']+item['size'])}
    spans = []
    for item in items:
        start,end = item['offset'],item['offset']+item['size']
        if spans and spans[-1][1]==start:
            spans[-1][1]=end
        else:
            spans.append([start,end])
    return dict(items=items,selected_ranges=spans,
                unresolved_offsets=[i for i in range(288,512) if i not in owned])


def declarations(raw, items, label):
    lines = [label+':']
    for item in items:
        lines += [f'; Header +${item["offset"]:03X}: '+item['kind']]
        if item['kind']=='intrinsic-segment-set':
            lines += [f'    .dword ${item["value"]:08X} ; segments '+(','.join(map(str,item['segments'])) or 'none')]
        elif item['kind'].startswith('zero-'):
            lines += [f'    .res {item["size"]}, 0']
        elif item['kind'].endswith('-length'):
            lines += [f'    .byte {item["value"]}']
        else:
            lines += ['; '+item['text']]
            for p in range(item['offset'],item['offset']+item['size'],16):
                data = raw[p:min(p+16,item['offset']+item['size'])]
                lines += ['    .byte '+','.join(f'${b:02X}' for b in data)]
    size = sum(item['size'] for item in items)
    lines += [f'.assert * - {label} = {size}, error, "Header data slice size"']
    return '\n'.join(lines)+'\n'


def prepare(verify=False):
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    table_audit = json.loads((ROOT/'docs/reference/header-tables.json').read_text())
    hashes = {(o['disk'],o['block']):table['sha256'] for table in table_audit['tables'] for o in table['occurrences']}
    images = {d['id']:(ROOT/'build/disks'/d['filename']).read_bytes() for d in manifest['disks']}
    for d in manifest['disks']:
        if sha(images[d['id']]) != d['sha256']:
            raise ValueError('Rebuild exact baseline before header preparation')
    lines = ['; Classified header data. Evidence: '+EVIDENCE,'.segment "HEADER_EXTENSIONS"','']
    binary,groups,mappings,records = bytearray(),{},[],[]
    for disk,block,mask in ORIGINS:
        raw = block_bytes(images[disk],block,block+1)
        if sha(raw[:288]) != hashes[(disk,block)]:
            raise ValueError('Header does not match its independently classified table')
        result = classify(raw,mask,block==103)
        records.append(dict(disk=disk,block=block,header_sha256=sha(raw),**result))
        for start,end in result['selected_ranges']:
            selected = [i for i in result['items'] if start <= i['offset'] < end]
            data = raw[start:end]
            # Reuse only fields with identical bytes and classifications.
            key = (data,tuple((i['offset']-start,i['size'],i['kind']) for i in selected))
            if key not in groups:
                label = f'header_extension_{len(groups)}'
                groups[key] = len(binary)
                lines += [declarations(raw,selected,label)]
                binary.extend(data)
            offset = logical_sector_offset(block*2+start//256)+start%256
            mappings.append(dict(disk=disk,offset=offset,size=end-start,input_offset=groups[key]))
    name = 'pascal_header_extensions'
    stem = ROOT/'src/data'/name
    text = '\n'.join(lines)
    config = (f'MEMORY {{ IMAGE: start = 0, size = {len(binary)}, file = %O; }}\n'
              'SEGMENTS { HEADER_EXTENSIONS: load = IMAGE, type = ro; }\n')
    output = ROOT/'build/header-extensions'
    output.mkdir(parents=True,exist_ok=True)
    (output/'module.s').write_text(text)
    (output/'module.cfg').write_text(config)
    subprocess.run(['ca65',str(output/'module.s'),'-o',str(output/'module.o')],check=True)
    subprocess.run(['ld65','-C',str(output/'module.cfg'),str(output/'module.o'),'-o',str(output/'module.bin')],check=True)
    if (output/'module.bin').read_bytes() != binary:
        raise ValueError('Header data declarations do not assemble exactly')
    recipe = dict(name=name,source=str(stem.with_suffix('.s').relative_to(ROOT)),
                  config=str(stem.with_suffix('.cfg').relative_to(ROOT)),mappings=mappings)
    report = dict(classification='data',classification_evidence=EVIDENCE,primary_format_reference=MANUAL,
                  source_output_bytes=len(binary),disk_output_bytes=sum(m['size'] for m in mappings),
                  sha256=sha(binary),records=records,byte_identical_assembly=True)
    artifacts = {stem.with_suffix('.s'):text,stem.with_suffix('.cfg'):config,
                 stem.with_suffix('.adopt.json'):json.dumps(recipe,indent=2)+'\n',
                 ROOT/'docs/reference/header-extensions.json':json.dumps(report,indent=2)+'\n'}
    for path,content in artifacts.items():
        if verify:
            if not path.is_file() or path.read_text() != content:
                raise ValueError(f'Header extension artifact differs: {path}')
        elif path.exists():
            raise ValueError(f'Header extension artifact already exists: {path}')
    if not verify:
        for path,content in artifacts.items():
            path.write_text(content)
    print(json.dumps(dict(source_bytes=len(binary),disk_bytes=report['disk_output_bytes'],
                          unresolved_header_bytes=sum(len(r['unresolved_offsets']) for r in records),verified=verify)))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verify',action='store_true')
    prepare(parser.parse_args().verify)
