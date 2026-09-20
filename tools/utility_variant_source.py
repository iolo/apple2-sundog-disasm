#!/usr/bin/env python3
"""Reconstruct 15 complete procedures in the retained utility-program variant."""
import argparse
from collections import Counter
import json
import subprocess

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from pcode_source import analyze_fragment, source, verify_interpreter

NAME = 'utility_variant_procedures'
EVIDENCE = 'docs/utility-variant-procedures.md'
START, END = 0x42, 0x89c  # Relative to disk-1 block 151.
# Each footer is supported by the neighboring long exact utility-source copies,
# its stored entry/exit displacements, and exhaustive control-flow decoding.
ATTRIBUTES = [0x13a,0x186,0x1a8,0x216,0x408,0x4de,0x500,0x514,
              0x618,0x642,0x742,0x7b8,0x7d4,0x7fa,0x89a]
NUMBERS = [32,33,34,35,36,37,38,30,39,2,6,40,41,5,42]


def prepare(verify=False):
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disk = next(d for d in manifest['disks'] if d['id']=='disk1')
    image = (ROOT/'build/disks'/disk['filename']).read_bytes()
    if sha(image) != disk['sha256']:
        raise ValueError('Rebuild exact baseline before variant preparation')
    interpreter = (ROOT/'build/disks/components/pcode_primitives.bin').read_bytes()
    if sha(interpreter) != manifest['components']['pcode_primitives']['sha256']:
        raise ValueError('Rebuilt interpreter differs')
    verify_interpreter(interpreter)
    raw = block_bytes(image,151,156)[START:END]
    if [raw[p-START] for p in ATTRIBUTES] != NUMBERS:
        raise ValueError('Reviewed variant procedure identities differ')
    report = analyze_fragment(raw,1,[p-START for p in ATTRIBUTES])
    if report['instruction_count'] != 785:
        raise ValueError('Variant instruction graph differs from reviewed procedures')
    text = '; Complete retained procedure fragment. Evidence: '+EVIDENCE+'\n'+source(report)
    config = (f'MEMORY {{ IMAGE: start = 0, size = {len(raw)}, file = %O; }}\n'
              'SEGMENTS { PCODE: load = IMAGE, type = ro; }\n')
    output = ROOT/'build/utility-variant'
    output.mkdir(parents=True,exist_ok=True)
    (output/'module.s').write_text(text)
    (output/'module.cfg').write_text(config)
    subprocess.run(['ca65','-I',str(ROOT/'src/pcode'),str(output/'module.s'),
                    '-o',str(output/'module.o')],check=True)
    subprocess.run(['ld65','-C',str(output/'module.cfg'),str(output/'module.o'),
                    '-o',str(output/'module.bin')],check=True)
    if (output/'module.bin').read_bytes() != raw:
        raise ValueError('Variant source does not reproduce every stored byte')
    stem = ROOT/'src/pcode'/NAME
    recipe_path = stem.with_suffix('.adopt.json')
    if verify:
        recipe = json.loads(recipe_path.read_text())
    else:
        recipe = dict(name=NAME,source=str(stem.with_suffix('.s').relative_to(ROOT)),
            config=str(stem.with_suffix('.cfg').relative_to(ROOT)),
            context_evidence=EVIDENCE,mappings=[],context_mappings=[])
        position = 0
        while position < len(raw):
            logical = 151*512+START+position
            offset = logical_sector_offset(logical//256)+logical%256
            owner = next(r for r in disk['regions'] if r['offset'] <= offset < r['offset']+r['size'])
            size = min(len(raw)-position,256-logical%256,owner['offset']+owner['size']-offset)
            mapping = dict(disk='disk1',offset=offset,size=size,input_offset=position)
            if manifest['components'][owner['input']]['kind']=='temporary-unresolved':
                recipe['mappings'].append(mapping)
            else:
                if owner['input'] != 'utility_disk1':
                    raise ValueError('Variant context is not the reviewed utility copy')
                mapping.update(existing_input=owner['input'],
                    existing_input_offset=owner['input_offset']+offset-owner['offset'])
                recipe['context_mappings'].append(mapping)
            position += size
    # Preserve prior exact-copy provenance, including classification at every
    # byte. The full variant graph must agree with every existing context item.
    from pcode_source import analyze
    primary = (ROOT/'build/disks/components/utility_disk1.bin').read_bytes()
    summary = json.loads((ROOT/'docs/reference/step06h-pcode-audit.json').read_text())
    if sha(primary) != summary['sha256']:
        raise ValueError('Primary utility context differs')
    primary_report = analyze(primary,summary['segment'],extra_code_roots=summary.get('extra_code_roots',[]))
    def ownership(result):
        return {p:('code' if item['kind']=='instruction' else 'data')
                for item in result['items'] for p in range(item['offset'],item['offset']+item['size'])}
    current, earlier = ownership(report),ownership(primary_report)
    covered = set()
    for context,rows in [(False,recipe['mappings']),(True,recipe['context_mappings'])]:
        for row in rows:
            p,size = row['input_offset'],row['size']
            if row['disk'] != 'disk1' or p < 0 or size <= 0 or p+size > len(raw):
                raise ValueError('Variant mapping is outside reviewed source')
            logical = 151*512+START+p
            offset = logical_sector_offset(logical//256)+logical%256
            if row['offset'] != offset or logical%256+size > 256:
                raise ValueError('Variant disk mapping differs from reviewed location')
            if covered.intersection(range(p,p+size)):
                raise ValueError('Variant source mappings overlap')
            covered.update(range(p,p+size))
            if context:
                q = row['existing_input_offset']
                if (row['existing_input'] != 'utility_disk1' or raw[p:p+size] != primary[q:q+size]
                        or any(current[p+i] != earlier[q+i] for i in range(size))):
                    raise ValueError('Variant graph contradicts previous copy classification')
            if verify:
                expected = row['existing_input'] if context else NAME
                expected_offset = row['existing_input_offset'] if context else p
                owners = [r for r in disk['regions'] if r['offset'] <= offset
                          and offset+size <= r['offset']+r['size']]
                if (len(owners)!=1 or owners[0]['input']!=expected
                        or owners[0]['input_offset']+offset-owners[0]['offset']!=expected_offset):
                    raise ValueError('Variant disk ownership differs')
    if len(covered) != len(raw):
        raise ValueError('Variant source bytes lack disk provenance')
    counts = Counter(current[p] for row in recipe['mappings']
                     for p in range(row['input_offset'],row['input_offset']+row['size']))
    report.update(classification_evidence=EVIDENCE,disk='disk1',first_block=151,
                  block_relative_start=START,block_relative_end=END,
                  newly_classified_bytes=dict(counts),
                  existing_context_bytes=sum(r['size'] for r in recipe['context_mappings']))
    artifacts = {stem.with_suffix('.s'):text,stem.with_suffix('.cfg'):config,
                 recipe_path:json.dumps(recipe,indent=2)+'\n',
                 ROOT/'docs/reference/utility-variant-procedures.json':json.dumps(report,indent=2)+'\n'}
    for path,content in artifacts.items():
        if verify:
            if not path.is_file() or path.read_text() != content:
                raise ValueError(f'Variant artifact differs: {path}')
        elif path.exists():
            raise ValueError(f'Variant artifact already exists: {path}')
    if not verify:
        for path,content in artifacts.items():
            path.write_text(content)
    print(json.dumps(dict(procedures=len(NUMBERS),instructions=report['instruction_count'],
                          source_bytes=len(raw),new_bytes=dict(counts),verified=verify)))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verify',action='store_true')
    prepare(parser.parse_args().verify)
