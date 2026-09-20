#!/usr/bin/env python3
"""Verify the 96-byte runtime copy retained after the world-default table."""
import argparse
import json
import struct
import subprocess

from adopt_component import source_copy_plan
from build_disks import contained_file
from check_native_high import instructions_for
from check_native_shared import BASE, audit
from disk_layout import ROOT, logical_sector_offset, sha
from native_pascal_source import instruction
from pcode_copies import verify_ownership

NAME = 'native_shared'
START, SIZE = 0x0dbc, 96
EVIDENCE = 'docs/preserved-native-shared-copy.md'
AUDIT = ROOT/'docs/reference/preserved-native-shared-copy.json'


def run(adopt=False, verify=False):
    manifest_path = ROOT/'reconstruction/manifest.json'
    manifest = json.loads(manifest_path.read_text())
    images = {d['id']:(ROOT/'build/disks'/d['filename']).read_bytes() for d in manifest['disks']}
    for disk in manifest['disks']:
        if sha(images[disk['id']]) != disk['sha256']:
            raise ValueError('Rebuild exact baseline before reviewing runtime copy')
    spec = manifest['components'][NAME]
    output = ROOT/'build/native-shared-copy'
    output.mkdir(parents=True,exist_ok=True)
    subprocess.run(['ca65',str(ROOT/spec['source']),'-o',str(output/'module.o')],check=True)
    subprocess.run(['ld65','-C',str(ROOT/spec['config']),str(output/'module.o'),
                    '-o',str(output/'module.bin')],check=True)
    binary = (output/'module.bin').read_bytes()
    if len(binary) != spec['size'] or sha(binary) != spec['sha256']:
        raise ValueError('Reassembled native source differs from reviewed component')
    primitives = (ROOT/'build/disks/components/pcode_primitives.bin').read_bytes()
    if sha(primitives) != manifest['components']['pcode_primitives']['sha256']:
        raise ValueError('Interpreter vectors differ from current baseline')
    source_audit = audit(binary,primitives)
    boundaries = instructions_for(binary,'native_shared')
    if binary[START:START+4] != bytes.fromhex('18ff0000'):
        raise ValueError('Copied input-device vector words differ')
    items = [dict(offset=0,source_offset=START,size=2,address=0xeea1,
                  classification='data',assembly='.addr $FF18',kind='input-device-vector'),
             dict(offset=2,source_offset=START+2,size=2,address=0xeea3,
                  classification='data',assembly='.addr $0000',kind='input-device-vector')]
    cursor = START+4
    while cursor < START+SIZE:
        decoded = instruction(binary,cursor)
        size,assembly = decoded['size'],decoded['assembly']
        if cursor+size > START+SIZE or boundaries.get(BASE+cursor) != binary[cursor:cursor+size]:
            raise ValueError('Copy instruction does not match its audited source boundary')
        if decoded['mode']=='Lb':
            target = BASE+cursor+2+struct.unpack('b',binary[cursor+1:cursor+2])[0]
            assembly = f'{decoded["mnemonic"]} ${target:04X}'
        items.append(dict(offset=cursor-START,source_offset=cursor,size=size,
            address=BASE+cursor,classification='code',assembly=assembly,kind='native-instruction'))
        cursor += size
    mapping = dict(disk='disk1',offset=logical_sector_offset(51)+160,
                   size=SIZE,input=NAME,input_offset=START)
    selected = binary[START:START+SIZE]
    if images['disk1'][mapping['offset']:mapping['offset']+SIZE] != selected:
        raise ValueError('World-default tail differs from reviewed runtime source')
    report = dict(classification_evidence=EVIDENCE,disk='disk1',block=25,byte_offset=416,
        size=SIZE,sha256=sha(selected),source=spec['source'],source_sha256=sha(binary),
        source_address=BASE+START,source_offset=START,source_audit=source_audit,
        instruction_count=len(items)-2,coverage_bytes=dict(code=92,data=4),
        items=items,mappings=[mapping],execution_at_copy_not_established=True)
    content = json.dumps(report,indent=2)+'\n'
    if verify:
        if AUDIT.read_text() != content:
            raise ValueError('Runtime-copy audit differs')
        verify_ownership(manifest,[mapping])
    else:
        planned,files = source_copy_plan(manifest,images,[mapping],{NAME:binary})
        if adopt:
            destinations = {}
            for path,data in files.items():
                target = contained_file(manifest_path.parent,path)
                old = [s for s in manifest['components'].values() if s.get('path')==path]
                if len(old)!=1 or sha(target.read_bytes())!=old[0]['sha256']:
                    raise ValueError('Temporary input changed before copy adoption')
                destinations[target] = data
            for path,data in destinations.items():
                path.write_bytes(data)
            manifest_path.write_text(json.dumps(planned,indent=2)+'\n')
        AUDIT.write_text(content)
    print(json.dumps(dict(instructions=len(items)-2,coverage=report['coverage_bytes'],
                          adopted=adopt,verified=verify)))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--adopt',action='store_true')
    mode.add_argument('--verify',action='store_true')
    args = parser.parse_args()
    run(args.adopt,args.verify)
