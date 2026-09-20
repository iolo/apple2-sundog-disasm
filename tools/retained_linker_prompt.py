#!/usr/bin/env python3
"""Reconstruct the short block-134 copy from reviewed complete linker context."""
import argparse
import json
import subprocess

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from pcode_copies import verify_ownership
from retained_linker import EVIDENCE_PATH, review

SOURCE = '''; Clipped historical linker procedure 22: docs/retained-linker-code.md
.include "encoding.inc"
.segment "PCODE"
fragment_start:
; Complete donor instruction is LOD 3,3,1 at context offset 45.
; Its opcode is overwritten on these disks; only two operands survive.
    .byte 3                 ; LOD lexical level
    p_big 3, 1              ; LOD variable offset
    p_nop
    p_lsa 8
    .byte "Reading "
    p_sldc 0
.assert * - fragment_start = 14, error, "Linker prompt copy extent"
'''


def prepare(verify=False):
    raw,decoded,_,_=review(json.loads(EVIDENCE_PATH.read_text()))
    items=[i for i in decoded['items'] if i['offset']<60 and i['offset']+i['size']>46]
    boundaries=[(i['offset'],i['size'],i['kind']) for i in items]
    if boundaries != [(45,3,'instruction'),(48,1,'instruction'),(49,2,'instruction'),
                       (51,8,'string-data'),(59,1,'instruction')]:
        raise ValueError('Historical prompt instruction/data boundaries differ')
    if [i['assembly'] for i in items if i['kind']=='instruction'] != [
            'p_lod 3, 3, 1','p_nop','p_lsa 8','p_sldc 0']:
        raise ValueError('Historical prompt instruction context differs')
    binary=raw[46:60]
    manifest=json.loads((ROOT/'reconstruction/manifest.json').read_text())
    mappings=[]
    for disk in manifest['disks']:
        image=(ROOT/'build/disks'/disk['filename']).read_bytes()
        if sha(image)!=disk['sha256'] or block_bytes(image,134,135)[498:]!=binary:
            raise ValueError('Rebuilt disk or short linker copy differs')
        mappings.append(dict(disk=disk['id'],offset=logical_sector_offset(269)+242,
                             size=14,input_offset=0))
    name='retained_linker_prompt'
    stem=ROOT/'src/pcode'/name
    config=('MEMORY { IMAGE: start = 0, size = 14, file = %O; }\n'
            'SEGMENTS { PCODE: load = IMAGE, type = ro; }\n')
    recipe=dict(name=name,source=str(stem.with_suffix('.s').relative_to(ROOT)),
                config=str(stem.with_suffix('.cfg').relative_to(ROOT)),mappings=mappings)
    audit=dict(classification_evidence='docs/retained-linker-code.md',
               source_evidence=str(EVIDENCE_PATH.relative_to(ROOT)),source_bytes=14,
               disk_bytes=28,sha256=sha(binary),donor_context_range=[46,60],
               donor_items=items,clipped_start=dict(instruction_offset=45,omitted_opcode_bytes=1),
               per_copy_classification=dict(code=6,data=8),disk_classification=dict(code=12,data=16))
    artifacts={stem.with_suffix('.s'):SOURCE,stem.with_suffix('.cfg'):config,
               stem.with_suffix('.adopt.json'):json.dumps(recipe,indent=2)+'\n',
               ROOT/'docs/reference/retained-linker-prompt.json':json.dumps(audit,indent=2)+'\n'}
    output=ROOT/'build/retained-linker-prompt'
    output.mkdir(parents=True,exist_ok=True)
    (output/'module.s').write_text(SOURCE)
    (output/'module.cfg').write_text(config)
    subprocess.run(['ca65','-I',str(ROOT/'src/pcode'),str(output/'module.s'),'-o',str(output/'module.o')],check=True)
    subprocess.run(['ld65','-C',str(output/'module.cfg'),str(output/'module.o'),'-o',str(output/'module.bin')],check=True)
    if (output/'module.bin').read_bytes()!=binary:
        raise ValueError('Short linker source does not assemble exactly')
    for path,text in artifacts.items():
        if verify:
            if not path.is_file() or path.read_text()!=text:
                raise ValueError(f'Short linker artifact differs: {path}')
        elif path.exists():
            raise ValueError(f'Short linker artifact already exists: {path}')
    if verify:
        verify_ownership(manifest,[dict(m,input=name) for m in mappings])
    else:
        for path,text in artifacts.items():
            path.write_text(text)
    print(json.dumps(dict(source_bytes=14,disk_bytes=28,classification=audit['disk_classification'],verified=verify)))


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verify',action='store_true')
    prepare(parser.parse_args().verify)
