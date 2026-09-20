#!/usr/bin/env python3
"""Reconstruct a reviewed compiler identifier/parameter heap window."""
import argparse
import json
from pathlib import Path
import struct
import subprocess

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from pascal_inventory import procedure_dictionary
from pcode_copies import verify_ownership

BASE, START, END = 0x2540, 52, 512
EXPECTED_SHA = 'ab3caa2d14b9706d58b0ef2cc56e5abbaa771bf98cdbea2274f55c534e2f478f'
EVIDENCE = 'docs/retained-compiler-heap.md'
CONSTRUCTOR = ROOT/'src/data/evidence/retained_compiler_heap.json'
SYMBOLS = [(56,'ROUND   ',6,24,34),(106,'MARK    ',5,32,78),
           (128,'RELEASE ',5,33,78),(150,'IORESULT',6,34,None),
           (194,'UNITBUSY',6,35,172),(216,'PWROFTEN',6,36,172),
           (238,'UNITWAIT',5,37,172),(260,'UNITCLEA',5,38,172),
           (282,'HALT    ',5,39,None),(304,'MEMAVAIL',6,40,None),
           (370,'STRTONUM',6,41,326)]
PARAMETERS = [(78,0x25a4,None,2),(172,0x1f0a,None,3),
              (326,0x1f3a,348,2),(348,0x1f0a,None,3),
              (392,0x1f10,414,3),(414,0x1f20,436,3),
              (436,0x1f0a,458,3),(458,0x1f3a,480,2),(480,0x1f0a,None,2)]


def classify(raw):
    if len(raw)!=512:
        raise ValueError('Expected complete containing block')
    items=[dict(offset=52,size=4,kind='clipped-parameter-variable-fields',
                record_address=BASE+34,fields=['VLEV','VADDR'],missing_prefix_bytes=18)]
    for offset,name,klass,number,param in SYMBOLS:
        values=list(struct.unpack_from('<7H',raw,offset+8))
        left,right,idtype,nxt,stored_class,decl,intrinsic=values
        if raw[offset:offset+8]!=name.encode() or (stored_class,decl,intrinsic)!=(klass,0,number):
            raise ValueError('Compiler symbol name, class or intrinsic number differs')
        if nxt!=(BASE+param if param is not None else 0):
            raise ValueError('Compiler symbol parameter link differs')
        items.append(dict(offset=offset,size=22,kind='standard-identifier',name=name,
                          address=BASE+offset,left_link=left,right_link=right,idtype=idtype,
                          next_parameter=nxt,klass=klass,declaration_kind=decl,csp_number=intrinsic,
                          words=values))
    for offset,idtype,nxt,klass in PARAMETERS:
        values=list(struct.unpack_from('<3H',raw,offset+12))
        if values != [idtype,BASE+nxt if nxt is not None else 0,klass]:
            raise ValueError('Compiler parameter type, link or class differs')
        items.append(dict(offset=offset,size=22,kind='standard-parameter',address=BASE+offset,
                          idtype=idtype,next_parameter=values[1],klass=klass,words=values,
                          retained_fields=['NAME','LLINK','RLINK','VLEV','VADDR']))
    if raw[100:106]!=bytes.fromhex('010002000000'):
        raise ValueError('Compiler pointer-type size/form/element differs')
    items.append(dict(offset=100,size=6,kind='pointer-type',address=BASE+100,
                      words=[1,2,0],fields=['SIZE','FORM','ELTYPE']))
    if raw[502:512]!=b'NUMTOSTR\0\0':
        raise ValueError('Clipped compiler symbol differs')
    items.append(dict(offset=502,size=10,kind='clipped-identifier',name='NUMTOSTR',
                      address=BASE+502,missing_suffix_bytes=12))
    items.sort(key=lambda i:i['offset'])
    if [p for i in items for p in range(i['offset'],i['offset']+i['size'])]!=list(range(START,END)):
        raise ValueError('Compiler heap ownership has a gap or overlap')
    if sha(raw[START:END])!=EXPECTED_SHA:
        raise ValueError('Compiler heap differs from reviewed snapshot')
    return dict(classification='data',memory_origin=BASE,window_start=BASE+START,
                window_end_exclusive=BASE+END,sha256=EXPECTED_SHA,items=items,
                complete_symbols=11,complete_parameters=9,pointer_types=1,
                preserved_native_patterns='Retained contents of unused parameter-record fields',
                live_compiler_heap_claimed=False)


def verify_constructor(external=None):
    evidence=json.loads(CONSTRUCTOR.read_text())
    expected=[(205,'c6010b9e01c604039e01dbcc0be2019ae2a201029ae2a2029f9ad8cc0be2a206db9ae2a208029a'),
              (336,'dda107c6020b9e01b905c6020b9e01d9cc0be2c607a804e2a209009adc05c9a109e2a20adc14829ab907e2a20adc1b829adda107e2a208059ab905e2a208069ad89fcba105d8a2079f9ae2a206da9ae2a207d89ad9cd0105')]
    if [(w['procedure_offset'],w['hex']) for w in evidence['windows']]!=expected:
        raise ValueError('Reviewed compiler allocation/write evidence differs')
    if external is not None:
        if len(external)!=evidence['allocation_size'] or sha(external)!=evidence['allocation_sha256']:
            raise ValueError('External compiler allocation differs')
        segment=external[5632:9032]
        if sha(segment)!=evidence['segment_sha256']:
            raise ValueError('External compiler initialization segment differs')
        dictionary=procedure_dictionary(segment,7)
        proc=dictionary['procedures'][7]
        if not dictionary['valid'] or proc!=evidence['procedure']:
            raise ValueError('External compiler constructor metadata differs')
        body=segment[proc['entry_offset']:proc['attribute_offset']+2]
        if sha(body)!=evidence['procedure_sha256']:
            raise ValueError('External compiler constructor differs')
        for row in evidence['windows']:
            if body[row['procedure_offset']:row['procedure_offset']+row['size']].hex()!=row['hex']:
                raise ValueError('External compiler constructor window differs')
    return evidence


def declarations(raw,report):
    lines=['; Classified compiler heap data: '+EVIDENCE,'.segment "COMPILER_HEAP"','snapshot:']
    def words(values):
        lines.append('    .word '+','.join(f'${v:04X}' for v in values))
    def octets(data):
        lines.append('    .byte '+','.join(f'${v:02X}' for v in data))
    for item in report['items']:
        offset,size,kind=(item[k] for k in ('offset','size','kind'))
        lines += [f'heap_{offset:04x}:',f'; Memory ${BASE+offset:04X}: {kind}']
        if kind=='standard-identifier':
            lines.append('; NAME, LLINK, RLINK, IDTYPE, NEXT, KLASS, PFDECKIND, CSPNUM')
            lines.append('    .byte "'+item['name']+'"')
            words(item['words'])
        elif kind=='standard-parameter':
            lines.append('; Uninitialized NAME, LLINK and RLINK; retained earlier memory contents.')
            octets(raw[offset:offset+12])
            lines.append('; IDTYPE, NEXT, KLASS')
            words(item['words'])
            lines.append('; Uninitialized VLEV and VADDR storage.')
            octets(raw[offset+18:offset+22])
        elif kind=='pointer-type':
            lines.append('; SIZE (words), FORM (POINTER), ELTYPE (nil)')
            words(item['words'])
        else:
            lines.append('; Only surviving record fields; missing fields are excluded.')
            octets(raw[offset:offset+size])
    lines.append('.assert * - snapshot = 460, error, "Compiler heap extent"')
    return '\n'.join(lines)+'\n'


def prepare(verify=False,external_path=None):
    verify_constructor(Path(external_path).read_bytes() if external_path else None)
    manifest=json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disk=next(d for d in manifest['disks'] if d['id']=='disk1')
    image=(ROOT/'build/disks'/disk['filename']).read_bytes()
    if sha(image)!=disk['sha256']:
        raise ValueError('Rebuild exact baseline before compiler heap preparation')
    raw=block_bytes(image,258,259)
    report=classify(raw)
    mappings=[]
    cursor=START
    while cursor<END:
        size=min(256-cursor%256,END-cursor)
        mappings.append(dict(disk='disk1',offset=logical_sector_offset(516+cursor//256)+cursor%256,
                             size=size,input_offset=cursor-START))
        cursor+=size
    name='retained_compiler_heap'
    stem=ROOT/'src/data'/name
    source=declarations(raw,report)
    config=('MEMORY { IMAGE: start = 0, size = 460, file = %O; }\n'
            'SEGMENTS { COMPILER_HEAP: load = IMAGE, type = ro; }\n')
    recipe=dict(name=name,source=str(stem.with_suffix('.s').relative_to(ROOT)),
                config=str(stem.with_suffix('.cfg').relative_to(ROOT)),mappings=mappings)
    audit=dict(classification_evidence=EVIDENCE,constructor_evidence=str(CONSTRUCTOR.relative_to(ROOT)),
               source_bytes=460,disk_bytes=460,mappings=mappings,**report)
    artifacts={stem.with_suffix('.s'):source,stem.with_suffix('.cfg'):config,
               stem.with_suffix('.adopt.json'):json.dumps(recipe,indent=2)+'\n',
               ROOT/'docs/reference/retained-compiler-heap.json':json.dumps(audit,indent=2)+'\n'}
    output=ROOT/'build/retained-compiler-heap'
    output.mkdir(parents=True,exist_ok=True)
    (output/'module.s').write_text(source)
    (output/'module.cfg').write_text(config)
    subprocess.run(['ca65',str(output/'module.s'),'-o',str(output/'module.o')],check=True)
    subprocess.run(['ld65','-C',str(output/'module.cfg'),str(output/'module.o'),'-o',str(output/'module.bin')],check=True)
    if (output/'module.bin').read_bytes()!=raw[START:END]:
        raise ValueError('Compiler heap declarations do not assemble exactly')
    for path,text in artifacts.items():
        if verify:
            if not path.is_file() or path.read_text()!=text:
                raise ValueError(f'Compiler heap artifact differs: {path}')
        elif path.exists():
            raise ValueError(f'Compiler heap artifact already exists: {path}')
    if verify:
        verify_ownership(manifest,[dict(m,input=name) for m in mappings])
    else:
        for path,text in artifacts.items():
            path.write_text(text)
    print(json.dumps(dict(source_bytes=460,disk_bytes=460,verified=verify)))


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verify',action='store_true')
    parser.add_argument('--external-compiler',help='Optional complete SYSTEM.COMPILER allocation')
    args=parser.parse_args()
    prepare(args.verify,args.external_compiler)
