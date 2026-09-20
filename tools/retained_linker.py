#!/usr/bin/env python3
"""Reconstruct copied historical linker instructions using complete procedures."""
import argparse
from collections import Counter
import json
from pathlib import Path
import re
import subprocess

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from pascal_inventory import parse_header, procedure_dictionary, word
from pcode_copies import verify_ownership
from pcode_source import analyze_fragment, label, source, verify_interpreter

EVIDENCE_PATH = ROOT/'src/pcode/evidence/retained_linker.json'
EVIDENCE_DOC = 'docs/retained-linker-code.md'
FRAGMENT_SHA = '26568695345b000b70923e1a7bde491b98ead74c7618e45297d187aac3648ab7'


def review(evidence, external=None):
    raw=bytes.fromhex(evidence['fragment_hex'])
    if sha(raw)!=FRAGMENT_SHA or sha(raw)!=evidence['fragment_sha256']:
        raise ValueError('Historical linker fragment hash differs')
    start,end=evidence['fragment_start'],evidence['fragment_end']
    if (start,end,len(raw),evidence['attributes'])!=(3320,4130,810,[586,808]):
        raise ValueError('Historical procedure extent differs')
    header=bytes.fromhex(evidence['header_hex'])
    entry=next(e for e in parse_header(header) if e['slot']==1)
    if (entry['relative_block'],entry['length'],entry['segment_number'])!=(1,11490,1):
        raise ValueError('Historical segment header differs')
    dictionary=bytes.fromhex(evidence['dictionary_hex'])
    if (evidence['dictionary_offset'],len(dictionary),dictionary[-2:])!=(11390,100,b'\x01\x31'):
        raise ValueError('Historical procedure dictionary extent differs')
    decoded=analyze_fragment(raw,1,evidence['attributes'],dialect='apple-pascal-inn')
    for local,original in zip(decoded['procedures'],evidence['procedures'],strict=True):
        number=local['number']
        address=11490-2-2*number
        if (original['number']!=number or original['dictionary_offset']!=address
                or address-word(dictionary,address-11390)!=local['attribute_offset']+start):
            raise ValueError('Historical dictionary pointer differs')
        for field in ('attribute_offset','entry_offset','exit_offset','attribute_start'):
            if local[field]+start!=original[field]:
                raise ValueError('Historical procedure metadata differs')
        for field in ('local_bytes','parameter_bytes','lexical_level','representation'):
            if local[field]!=original[field]:
                raise ValueError('Historical procedure fields differ')
    if external is not None:
        if len(external)!=evidence['allocation_size'] or sha(external)!=evidence['allocation_sha256']:
            raise ValueError('External linker allocation differs')
        segment=external[512:12002]
        if (external[:512]!=header or sha(segment)!=evidence['segment_sha256']
                or segment[start:end]!=raw or segment[11390:]!=dictionary):
            raise ValueError('External linker evidence differs')
        complete=procedure_dictionary(segment,1)
        if not complete['valid'] or [complete['procedures'][n-1] for n in (22,26)]!=evidence['procedures']:
            raise ValueError('External complete procedure dictionary differs')
    if evidence['copy']!=dict(block=126,start=210,end=512,input_offset=454):
        raise ValueError('Reviewed linker copy mapping differs')
    selected=[]
    counts=Counter()
    for item in decoded['items']:
        first,last=max(454,item['offset']),min(756,item['offset']+item['size'])
        if first>=last:
            continue
        kind='code' if item['kind']=='instruction' else 'data'
        counts[kind]+=last-first
        selected.append(dict(source_offset=first,size=last-first,classification=kind,
                             full_item=item,clipped_start=first!=item['offset'],
                             clipped_end=last!=item['offset']+item['size']))
    if dict(counts)!=dict(code=248,data=54):
        raise ValueError('Copied linker classification differs')
    return raw,decoded,selected,dict(counts)


def copied_source(selected):
    """Emit only copied instructions/data, preserving references into context."""
    lines=['; Historical linker fragment: '+EVIDENCE_DOC,
           '.include "encoding.inc"','.segment "PCODE"','segment_start:']
    external={}
    def reference(match):
        offset=int(match.group()[2:],16)
        if 454 <= offset < 756:
            return match.group()
        name='EXT_'+match.group()
        external[name]=offset-454
        return name
    for item in selected:
        offset=item['source_offset']
        assembly=item['full_item']['assembly']
        if item['clipped_start']:
            if offset!=454 or assembly!='p_ldl 295, 2' or item['size']!=2:
                raise ValueError('Unreviewed clipped instruction')
            assembly='p_big 295, 2 ; retained operand of preceding LDL opcode'
        if item['clipped_end']:
            raise ValueError('Unreviewed clipped instruction end')
        lines += [label(offset)+':','    '+re.sub(r'L_[0-9A-F]+',reference,assembly)]
    lines.append('.assert * - segment_start = 302, error, "Linker copy extent"')
    definitions=[f'{name} = segment_start + ({offset})' for name,offset in sorted(external.items())]
    return '\n'.join(definitions+lines)+'\n'


def prepare(verify=False,external_path=None):
    evidence=json.loads(EVIDENCE_PATH.read_text())
    external=Path(external_path).read_bytes() if external_path else None
    raw,decoded,selected,counts=review(evidence,external)
    primitives=(ROOT/'build/disks/components/pcode_primitives.bin').read_bytes()
    verify_interpreter(primitives)
    if word(primitives,(0x8b-128)*2)!=0xd1ef:
        raise ValueError('SunDog unsupported INN dispatch differs')
    manifest=json.loads((ROOT/'reconstruction/manifest.json').read_text())
    mappings=[]
    for disk in manifest['disks']:
        image=(ROOT/'build/disks'/disk['filename']).read_bytes()
        if sha(image)!=disk['sha256'] or block_bytes(image,126,127)[210:]!=raw[454:756]:
            raise ValueError('Rebuilt disk or retained linker copy differs')
        cursor=210
        while cursor<512:
            size=min(256-cursor%256,512-cursor)
            mappings.append(dict(disk=disk['id'],offset=logical_sector_offset(252+cursor//256)+cursor%256,
                                 size=size,input_offset=cursor-210))
            cursor+=size
    name='retained_linker'
    stem=ROOT/'src/pcode'/name
    context='; Historical Apple linker procedures 22 and 26; '+EVIDENCE_DOC+'\n'+source(decoded)
    assembly=copied_source(selected)
    config=('MEMORY { IMAGE: start = 0, size = 302, file = %O; }\n'
            'SEGMENTS { PCODE: load = IMAGE, type = ro; }\n')
    recipe=dict(name=name,source=str(stem.with_suffix('.s').relative_to(ROOT)),
                config=str(stem.with_suffix('.cfg').relative_to(ROOT)),mappings=mappings)
    audit=dict(classification_evidence=EVIDENCE_DOC,source_bytes=302,context_bytes=810,disk_bytes=604,
               source_evidence=str(EVIDENCE_PATH.relative_to(ROOT)),copy_items=selected,
               per_copy_classification=counts,disk_classification={k:v*2 for k,v in counts.items()},
               sundog_inn_dispatch=0xd1ef,live_execution_claimed=False,decoded=decoded)
    artifacts={stem.with_suffix('.s'):assembly,stem.with_suffix('.cfg'):config,
               ROOT/'src/pcode/retained_linker_context.s':context,
               stem.with_suffix('.adopt.json'):json.dumps(recipe,indent=2)+'\n',
               ROOT/'docs/reference/retained-linker.json':json.dumps(audit,indent=2)+'\n'}
    output=ROOT/'build/retained-linker'
    output.mkdir(parents=True,exist_ok=True)
    (output/'context.s').write_text(context)
    (output/'context.cfg').write_text(config.replace('size = 302','size = 810'))
    subprocess.run(['ca65','-I',str(ROOT/'src/pcode'),str(output/'context.s'),'-o',str(output/'context.o')],check=True)
    subprocess.run(['ld65','-C',str(output/'context.cfg'),str(output/'context.o'),'-o',str(output/'context.bin')],check=True)
    if (output/'context.bin').read_bytes()!=raw:
        raise ValueError('Historical complete context does not assemble exactly')
    (output/'module.s').write_text(assembly)
    (output/'module.cfg').write_text(config)
    subprocess.run(['ca65','-I',str(ROOT/'src/pcode'),str(output/'module.s'),'-o',str(output/'module.o')],check=True)
    subprocess.run(['ld65','-C',str(output/'module.cfg'),str(output/'module.o'),'-o',str(output/'module.bin')],check=True)
    if (output/'module.bin').read_bytes()!=raw[454:756]:
        raise ValueError('Historical linker source does not assemble exactly')
    for path,text in artifacts.items():
        if verify:
            if not path.is_file() or path.read_text()!=text:
                raise ValueError(f'Historical linker artifact differs: {path}')
        elif path.exists():
            raise ValueError(f'Historical linker artifact already exists: {path}')
    if verify:
        verify_ownership(manifest,[dict(m,input=name) for m in mappings])
    else:
        for path,text in artifacts.items():
            path.write_text(text)
    print(json.dumps(dict(source_bytes=302,context_bytes=810,disk_bytes=604,classification=audit['disk_classification'],verified=verify)))


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verify',action='store_true')
    parser.add_argument('--external-linker',help='Optional complete 24-block SYSTEM.LINKER allocation')
    args=parser.parse_args()
    prepare(args.verify,args.external_linker)
