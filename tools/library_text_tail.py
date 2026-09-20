#!/usr/bin/env python3
"""Audit a retained CR-terminated text suffix after both library-22 copies."""
import argparse
import json
import subprocess

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from pascal_inventory import procedure_dictionary
from pcode_copies import verify_ownership

EVIDENCE = 'docs/library-text-tail.md'
MODULE_SHA = '7d52f0e6959d0a8b9ac3f08bc78ced7e7af44ed87a00d80d4d82025ab7735f49'
TEXT = b'an;\r'


def classify(allocation, module):
    if len(allocation) != 6144 or len(module) != 6126 or sha(module) != MODULE_SHA:
        raise ValueError('Reviewed library allocation or module differs')
    if allocation[:len(module)] != module:
        raise ValueError('Library payload differs')
    dictionary = procedure_dictionary(module,22)
    if not dictionary['valid'] or dictionary['procedure_count'] != 63:
        raise ValueError('Library procedure dictionary differs')
    tail = allocation[len(module):]
    if tail[:4] != TEXT or any(tail[4:]):
        raise ValueError('Reviewed retained text suffix or NUL fill differs')
    return dict(classification='data',classification_basis='retained-text-format-inference',
                allocation_bytes=len(allocation),module_bytes=len(module),
                dictionary_start=dictionary['dictionary_start'],procedure_count=63,
                text=dict(offset=6126,ascii_suffix='an;',line_ending=13,size=4),
                nul_fill=dict(offset=6130,size=14),classified_bytes=18,
                missing_prefix_recovered=False,historical_producer_proved=False,
                storage_sha256=sha(tail))


def run(prepare=False):
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    module = (ROOT/'build/disks/components/library_22.bin').read_bytes()
    spec = manifest['components']['library_22']
    if spec['kind'] != 'ca65-source' or spec['sha256'] != MODULE_SHA:
        raise ValueError('Classified library component differs')
    mappings,records = [],[]
    for disk in manifest['disks']:
        image = (ROOT/'build/disks'/disk['filename']).read_bytes()
        if sha(image) != disk['sha256']:
            raise ValueError('Rebuild exact baseline before library-tail audit')
        allocation = block_bytes(image,104,116)
        report = classify(allocation,module)
        for position in range(0,len(module),256):
            size = min(256,len(module)-position)
            verify_ownership(manifest,[dict(disk=disk['id'],
                offset=logical_sector_offset(208+position//256),size=size,
                input='library_22',input_offset=position)])
        mappings.append(dict(disk=disk['id'],offset=logical_sector_offset(231)+238,
                             size=18,input_offset=0))
        records.append(dict(disk=disk['id'],block=115,block_offset=494,**report))
    output = ROOT/'build/library-text-tail'
    output.mkdir(parents=True,exist_ok=True)
    stem = ROOT/'src/data/library_text_tail'
    subprocess.run(['ca65',str(stem.with_suffix('.s')),'-o',str(output/'tail.o')],check=True)
    subprocess.run(['ld65','-C',str(stem.with_suffix('.cfg')),str(output/'tail.o'),
                    '-o',str(output/'tail.bin')],check=True)
    if (output/'tail.bin').read_bytes() != TEXT+bytes(14):
        raise ValueError('Text/fill source differs')
    recipe = dict(name='library_text_tail',source=str(stem.with_suffix('.s').relative_to(ROOT)),
                  config=str(stem.with_suffix('.cfg').relative_to(ROOT)),mappings=mappings)
    report = dict(classification_evidence=EVIDENCE,source_bytes=18,disk_data_bytes=36,
                  module_sha256=MODULE_SHA,records=records)
    artifacts = {stem.with_suffix('.adopt.json'):json.dumps(recipe,indent=2)+'\n',
                 ROOT/'docs/reference/library-text-tail.json':json.dumps(report,indent=2)+'\n'}
    for path,text in artifacts.items():
        if prepare:
            path.write_text(text)
        elif path.read_text() != text:
            raise ValueError(f'Library text-tail artifact differs: {path}')
    if not prepare:
        verify_ownership(manifest,[dict(m,input=recipe['name']) for m in mappings])
    print(json.dumps(dict(classified_disk_data_bytes=36,verified=not prepare)))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--prepare',action='store_true')
    run(parser.parse_args().prepare)
