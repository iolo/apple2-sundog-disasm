#!/usr/bin/env python3
"""Reconstruct native-container footers, bounded zero storage and a dead transfer."""
import argparse
import json
import subprocess

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from native_pascal_source import instruction
from native_relocations import native_relocations
from pascal_inventory import procedure_dictionary

EVIDENCE = 'docs/native-block-tails.md'
LAYOUTS = {
    'raw_screen_init':dict(block=2,prefix_size=297,segment_size=314,base=0xe80,table_start=298),
    'raw_buffer_transform':dict(block=156,prefix_size=93,segment_size=112,base=0xf40,table_start=96)}


def classify(raw, name):
    layout = LAYOUTS[name]
    if len(raw) != 512:
        raise ValueError('Native block must contain 512 bytes')
    end = layout['segment_size']
    dictionary = procedure_dictionary(raw[:end],1)
    if not dictionary['valid'] or dictionary['procedure_count'] != 1:
        raise ValueError('Expected one valid native procedure')
    proc = dictionary['procedures'][0]
    if proc['representation'] != 'native-6502' or proc['entry_offset'] != 0 or proc['lexical_level'] != 0:
        raise ValueError('Native block footer disagrees with reviewed structure')
    relocation = native_relocations(raw[:end],proc)
    if relocation['tables_start'] != layout['table_start'] or any(g['count'] for g in relocation['groups']):
        raise ValueError('Unexpected native relocation fields')
    items = []
    if name=='raw_buffer_transform':
        item = instruction(raw,93)
        if item['mnemonic'] != 'jmp' or item['mode'] != 'In' or item['operand_value'] != 4:
            raise ValueError('Unused transfer differs from JMP ($0004)')
        items.append(dict(offset=93,size=3,classification='code',assembly=item['assembly'],
                          kind='unused-indirect-transfer',runtime_address=layout['base']+93,
                          evidence='Pointer $04/$05 is the restored transformed-buffer start; preceding RTS bypasses this retained instruction.'))
    else:
        if raw[297] != 0:
            raise ValueError('Nonzero native alignment needs review')
        items.append(dict(offset=297,size=1,classification='data',kind='native-alignment'))
    for group in reversed(relocation['groups']):
        items.append(dict(offset=group['count_offset'],size=2,classification='data',
                          kind='native-relocation-count-'+group['kind'],value=0))
    attributes = proc['attribute_offset']
    items += [dict(offset=attributes-2,size=2,classification='data',kind='native-entry-displacement',value=attributes-2),
              dict(offset=attributes,size=2,classification='data',kind='native-attributes'),
              dict(offset=proc['dictionary_offset'],size=2,classification='data',kind='procedure-dictionary-pointer',value=2),
              dict(offset=end-2,size=2,classification='data',kind='segment-trailer')]
    if any(raw[end:]):
        raise ValueError('Nonzero bytes after native container require separate classification')
    items.append(dict(offset=end,size=512-end,classification='data',kind='zero-block-storage'))
    cursor = layout['prefix_size']
    for item in items:
        if item['offset'] != cursor:
            raise ValueError('Native tail ownership gap or overlap')
        cursor += item['size']
    if cursor != 512:
        raise ValueError('Native tail is incomplete')
    return dict(name=name,**layout,dictionary=dictionary,relocation=relocation,items=items,
                code_bytes=sum(i['size'] for i in items if i['classification']=='code'),
                data_bytes=sum(i['size'] for i in items if i['classification']=='data'))


def declarations(raw, report):
    label = report['name']+'_tail'
    lines = [label+':']
    for item in report['items']:
        lines += [f'; Bank +${item["offset"]:04X}: '+item['kind']]
        if item['classification']=='code':
            lines += ['; '+item['evidence'],'    '+item['assembly']]
        elif item['kind']=='zero-block-storage':
            lines += [f'    .res {item["size"]}, 0']
        elif 'value' in item:
            lines += [f'    .word ${item["value"]:04X}']
        else:
            data = raw[item['offset']:item['offset']+item['size']]
            lines += ['    .byte '+','.join(f'${b:02X}' for b in data)]
    lines += [f'.assert * - {label} = {512-report["prefix_size"]}, error, "Native tail size"']
    return '\n'.join(lines)+'\n'


def prepare(verify=False):
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disk = next(d for d in manifest['disks'] if d['id']=='disk1')
    image = (ROOT/'build/disks'/disk['filename']).read_bytes()
    if sha(image) != disk['sha256']:
        raise ValueError('Rebuild exact disk baseline before native tail preparation')
    binary,records,mappings = bytearray(),[],[]
    lines = ['; Evidence: '+EVIDENCE,'.setcpu "6502"','.segment "NATIVE_TAILS"','']
    for name,layout in LAYOUTS.items():
        raw = block_bytes(image,layout['block'],layout['block']+1)
        spec = manifest['components'][name]
        prefix = (ROOT/'build/disks/components'/(name+'.bin')).read_bytes()
        if (spec['kind']!='ca65-source' or len(prefix)!=layout['prefix_size'] or sha(prefix)!=spec['sha256']
                or raw[:len(prefix)]!=prefix):
            raise ValueError('Native prefix differs from existing source reconstruction')
        report = classify(raw,name)
        report.update(block_sha256=sha(raw),prefix_component_sha256=sha(prefix))
        records.append(report)
        lines.append(declarations(raw,report))
        start = layout['prefix_size']
        position = start
        while position < 512:
            length = min(512-position,256-position%256)
            mappings.append(dict(disk='disk1',offset=logical_sector_offset(layout['block']*2+position//256)+position%256,
                                 size=length,input_offset=len(binary)+position-start))
            position += length
        binary.extend(raw[start:])
    name = 'native_block_tails'
    stem = ROOT/'src/native'/name
    text = '\n'.join(lines)
    config = (f'MEMORY {{ IMAGE: start = 0, size = {len(binary)}, file = %O; }}\n'
              'SEGMENTS { NATIVE_TAILS: load = IMAGE, type = ro; }\n')
    output = ROOT/'build/raw-preparation'/name
    output.mkdir(parents=True,exist_ok=True)
    (output/'module.s').write_text(text)
    (output/'module.cfg').write_text(config)
    subprocess.run(['ca65',str(output/'module.s'),'-o',str(output/'module.o')],check=True)
    subprocess.run(['ld65','-C',str(output/'module.cfg'),str(output/'module.o'),'-o',str(output/'module.bin')],check=True)
    if (output/'module.bin').read_bytes() != binary:
        raise ValueError('Native tail assembly differs')
    recipe = dict(name=name,source=str(stem.with_suffix('.s').relative_to(ROOT)),
                  config=str(stem.with_suffix('.cfg').relative_to(ROOT)),mappings=mappings)
    report = dict(classification_evidence=EVIDENCE,source_bytes=len(binary),sha256=sha(binary),
                  records=records,byte_identical_assembly=True,
                  code_bytes=sum(r['code_bytes'] for r in records),data_bytes=sum(r['data_bytes'] for r in records))
    artifacts = {stem.with_suffix('.s'):text,stem.with_suffix('.cfg'):config,
                 stem.with_suffix('.adopt.json'):json.dumps(recipe,indent=2)+'\n',
                 ROOT/'docs/reference/raw-modules/native_block_tails.json':json.dumps(report,indent=2)+'\n'}
    for path,content in artifacts.items():
        if verify:
            if not path.is_file() or path.read_text()!=content:
                raise ValueError(f'Native tail artifact differs: {path}')
        elif path.exists():
            raise ValueError(f'Native tail artifact already exists: {path}')
    if not verify:
        for path,content in artifacts.items():
            path.write_text(content)
    print(json.dumps({k:report[k] for k in ('source_bytes','code_bytes','data_bytes')}))


if __name__=='__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verify',action='store_true')
    prepare(parser.parse_args().verify)
