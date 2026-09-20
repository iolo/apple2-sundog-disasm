#!/usr/bin/env python3
"""Reconstruct four reviewed changes inside complete utility instruction/footer contexts."""
import argparse
import json
import subprocess

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from pcode_source import analyze, analyze_fragment

NAME = 'utility_variant_edges'
EVIDENCE = 'docs/short-pcode-copies.md'
CONTEXTS = [
    dict(block=151,byte_offset=56,size=10,primary_offset=0x124e,changed_offset=8,
         expected='1a00080008007e001f02',original='1a00080008007e002002',kind='procedure-footer'),
    dict(block=155,byte_offset=207,size=2,primary_offset=0x1c1f,changed_offset=1,
         expected='a50b',original='a50c',kind='instruction',assembly='p_lao 11, 1'),
    dict(block=155,byte_offset=252,size=2,primary_offset=0x1c4c,changed_offset=1,
         expected='a50b',original='a50c',kind='instruction',assembly='p_lao 11, 1'),
    dict(block=155,byte_offset=289,size=2,primary_offset=0x1c71,changed_offset=1,
         expected='cf2a',original='cf2c',kind='instruction',assembly='p_cgp 42'),
]
SOURCE = '''; Reviewed contexts at the clipped edges of the retained utility variant.
; Evidence: docs/short-pcode-copies.md. Disk mappings select four changed bytes.
.include "encoding.inc"
.segment "PCODE"
fragment_start:
; Disk 1 block 151 bytes 56-65. The procedure entry is outside the retained area.
clipped_procedure_footer:
    .word 26, 8                ; local bytes, parameter bytes
    .word 8, 126               ; stored exit and entry backward displacements
    .byte 31, 2                ; variant procedure number and lexical level
; Disk 1 block 155 bytes 207-208, 252-253 and 289-290.
first_global_address:
    p_lao 11, 1
second_global_address:
    p_lao 11, 1
call_variant_procedure:
    p_cgp 42
.assert * - fragment_start = 16, error, "Variant edge contexts changed size"
'''


def prepare(verify=False):
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disk = next(d for d in manifest['disks'] if d['id']=='disk1')
    image = (ROOT/'build/disks'/disk['filename']).read_bytes()
    if sha(image) != disk['sha256']:
        raise ValueError('Rebuild exact baseline before edge preparation')
    def component(name):
        raw = (ROOT/'build/disks/components'/f'{name}.bin').read_bytes()
        spec = manifest['components'][name]
        if len(raw) != spec['size'] or sha(raw) != spec['sha256']:
            raise ValueError('Reviewed context component differs')
        return raw
    primary = component('utility_disk1')
    summary = json.loads((ROOT/'docs/reference/step06h-pcode-audit.json').read_text())
    if sha(primary) != summary['sha256']:
        raise ValueError('Primary utility audit differs')
    primary_report = analyze(primary,summary['segment'],extra_code_roots=summary.get('extra_code_roots',[]))
    primary_items = {i['offset']:i for i in primary_report['items']}
    variant = component('utility_variant_procedures')
    variant_audit = json.loads((ROOT/'docs/reference/utility-variant-procedures.json').read_text())
    if sha(variant) != variant_audit['sha256']:
        raise ValueError('Variant procedure audit differs')
    decoded_variant = analyze_fragment(variant,1,[p['attribute_offset'] for p in variant_audit['procedures']])
    target = next(p for p in decoded_variant['procedures'] if p['number']==42)
    if target['entry_offset']+0x42 != 0x7fc:
        raise ValueError('Changed CGP does not name the reviewed variant procedure')
    stem = ROOT/'src/pcode'/NAME
    recipe_path = stem.with_suffix('.adopt.json')
    recipe = dict(name=NAME,
        source=str(stem.with_suffix('.s').relative_to(ROOT)),
        config=str(stem.with_suffix('.cfg').relative_to(ROOT)),context_evidence=EVIDENCE,
        mappings=[],context_mappings=[])
    binary,records = bytearray(),[]
    for context in CONTEXTS:
        block,position,size,q = (context[k] for k in ('block','byte_offset','size','primary_offset'))
        raw = block_bytes(image,block,block+1)[position:position+size]
        if raw.hex()!=context['expected'] or primary[q:q+size].hex()!=context['original']:
            raise ValueError('Reviewed instruction/footer difference changed')
        if [i for i,(a,b) in enumerate(zip(raw,primary[q:q+size])) if a!=b] != [context['changed_offset']]:
            raise ValueError('Context has unreviewed changes')
        item = primary_items[q]
        if context['kind']=='instruction':
            if item['kind']!='instruction' or item['size']!=size or item['mnemonic'] not in ('lao','cgp'):
                raise ValueError('Primary instruction boundary differs')
        else:
            expected_kinds = ['local-size','parameter-size','exit-pointer','entry-pointer','attributes']
            if [primary_items[q+i]['kind'] for i in range(0,10,2)] != expected_kinds:
                raise ValueError('Primary footer boundaries differ')
        records.append(dict(context,input_offset=len(binary),classification='code' if context['kind']=='instruction' else 'data'))
        for i in range(size):
            logical = block*512+position+i
            offset = logical_sector_offset(logical//256)+logical%256
            owner = next(r for r in disk['regions'] if r['offset'] <= offset < r['offset']+r['size'])
            mapping = dict(disk='disk1',offset=offset,size=1,input_offset=len(binary)+i)
            if i==context['changed_offset']:
                if not verify and manifest['components'][owner['input']]['kind']!='temporary-unresolved':
                    raise ValueError('Changed operand is already owned')
                recipe['mappings'].append(mapping)
            else:
                if owner['input']!='utility_disk1' or owner['input_offset']+offset-owner['offset']!=q+i:
                    raise ValueError('Surrounding source context differs')
                mapping.update(existing_input='utility_disk1',existing_input_offset=q+i)
                recipe['context_mappings'].append(mapping)
        binary.extend(raw)
    config = 'MEMORY { IMAGE: start = 0, size = 16, file = %O; }\nSEGMENTS { PCODE: load = IMAGE, type = ro; }\n'
    output = ROOT/'build/utility-variant-edges'
    output.mkdir(parents=True,exist_ok=True)
    (output/'module.s').write_text(SOURCE)
    (output/'module.cfg').write_text(config)
    subprocess.run(['ca65','-I',str(ROOT/'src/pcode'),str(output/'module.s'),'-o',str(output/'module.o')],check=True)
    subprocess.run(['ld65','-C',str(output/'module.cfg'),str(output/'module.o'),'-o',str(output/'module.bin')],check=True)
    if (output/'module.bin').read_bytes()!=binary:
        raise ValueError('Complete contexts do not assemble exactly')
    if verify:
        for is_context,rows in [(False,recipe['mappings']),(True,recipe['context_mappings'])]:
            for row in rows:
                expected = row['existing_input'] if is_context else NAME
                start = row['existing_input_offset'] if is_context else row['input_offset']
                owners = [r for r in disk['regions'] if r['offset']<=row['offset']
                          and row['offset']+row['size']<=r['offset']+r['size']]
                if (len(owners)!=1 or owners[0]['input']!=expected
                        or owners[0]['input_offset']+row['offset']-owners[0]['offset']!=start):
                    raise ValueError('Edge source ownership differs')
    report = dict(classification_evidence=EVIDENCE,source_bytes=16,new_bytes=dict(code=3,data=1),
                  existing_context_bytes=12,sha256=sha(binary),records=records,
                  variant_call_target=target)
    artifacts = {stem.with_suffix('.s'):SOURCE,stem.with_suffix('.cfg'):config,
        recipe_path:json.dumps(recipe,indent=2)+'\n',
        ROOT/'docs/reference/utility-variant-edges.json':json.dumps(report,indent=2)+'\n'}
    for path,content in artifacts.items():
        if verify:
            if not path.is_file() or path.read_text()!=content:
                raise ValueError(f'Variant edge artifact differs: {path}')
        elif path.exists():
            raise ValueError(f'Variant edge artifact already exists: {path}')
    if not verify:
        for path,content in artifacts.items():
            path.write_text(content)
    print(json.dumps(dict(new_bytes=report['new_bytes'],verified=verify)))


if __name__=='__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verify',action='store_true')
    prepare(parser.parse_args().verify)
