#!/usr/bin/env python3
"""Reconstruct the reviewed duplicate of a retained 128K Pascal stack window."""
import argparse
import json
import struct
import subprocess

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from pcode_copies import verify_ownership

BASE = 0xede6
START, END = 20, 512
EXPECTED_SHA = '6bf0f1396813b8016f98f664af037e4c03d716dc6d2215f85244be7581c82c12'
EVIDENCE = 'docs/retained-pascal-stack.md'
DEVICE_TEXT = b'7CONSOLE1:7SYSTERM2:7GRAPHIC3:7PRINTER6:5REMIN7:6REMOUT8'


def node(raw, offset, next_offset, expected_text):
    original, link = struct.unpack_from('<HH', raw, offset)
    length = raw[offset+4]
    end = offset + 4 + ((length+2) & ~1)
    if end > len(raw) or raw[offset+5:offset+5+length] != expected_text:
        raise ValueError('Retained string node length or text differs')
    if link != (BASE+next_offset if next_offset is not None else 0):
        raise ValueError('Retained string link does not resolve in the common memory window')
    if next_offset is not None and end != next_offset:
        raise ValueError('String allocation does not meet its linked successor')
    return dict(offset=offset, size=end-offset, kind='copied-string-node',
                original_pcode_address=original, next_address=link, length=length,
                text=expected_text.decode('ascii'), alignment_bytes=raw[offset+5+length:end].hex())


def frame(raw, offset, expected_parent, expected_top, expected_strings):
    strings, top = struct.unpack_from('<HH',raw,offset-4)
    static, parent, jtab, segment, ipc = struct.unpack_from('<5H',raw,offset)
    if (parent,top,strings) != (expected_parent,expected_top,expected_strings):
        raise ValueError('Retained call-frame links or saved stack bounds differ')
    if static != 0xf5ee or raw[offset+10] != 0xf9:
        raise ValueError('Retained call-frame static link or saved CPU stack differs')
    return dict(offset=offset-4, size=16, kind='call-frame-with-128k-prefix',
                mark_address=BASE+offset, saved_string_head=strings, saved_stack_top=top,
                static_link=static, dynamic_link=parent, saved_jtab=jtab,
                saved_segment=segment, saved_ipc=ipc, saved_cpu_sp=raw[offset+10],
                retained_unused_byte=raw[offset+11],
                local_storage_start=BASE+offset+12, local_storage_end=top)


def classify(raw):
    if len(raw) != 512:
        raise ValueError('Expected a complete containing block')
    items = []
    if raw[20:24] != bytes.fromhex('feed012f'):
        raise ValueError('Clipped leading string node differs')
    items.append(dict(offset=20,size=4,kind='clipped-string-node',next_address=BASE+24,
                      length=1,text='/',missing_original_address_bytes=2))
    for offset,next_offset,text in [(0x18,0x1e,b'/'),(0x1e,0x24,b'.'),
                                    (0x24,0x62,DEVICE_TEXT),(0x62,None,b'/')]:
        items.append(node(raw,offset,next_offset,text))
    child = frame(raw,0x6c,BASE+0x1d0,BASE+0x1cc,0)
    parent = frame(raw,0x1d0,0xf032,0xf02e,0)
    reused = frame(raw,0x1b8,BASE+0x1d0,BASE+0x1c6,BASE+0x1c6)
    items.append(child)
    # Local/parameter storage is bounded by the frame end and its saved KP.
    # Recognizable old string allocations and a reused frame are emitted below
    # as subrecords. They need not have been live simultaneously.
    def locals_region(start,end,owner):
        if not owner['local_storage_start'] <= BASE+start < BASE+end <= owner['local_storage_end']:
            raise ValueError('Retained local storage exceeds its evidenced activation bounds')
        return dict(offset=start,size=end-start,kind='activation-local-storage',
                    frame_address=owner['mark_address'],
                    clipped_at_window_end=BASE+end < owner['local_storage_end'] and end==END)
    items.append(locals_region(0x78,0x142,child))
    for index,text in enumerate((b':',b'/',b'',b':',b':',b'!',b'[',b'',b'')):
        offset=0x142+index*6
        items.append(node(raw,offset,offset+6 if index<8 else None,text))
    items += [locals_region(0x178,0x1b4,child),reused,
              locals_region(0x1c4,0x1c6,reused),node(raw,0x1c6,None,b''),parent,
              locals_region(0x1dc,END,parent)]
    owned=[p for item in items for p in range(item['offset'],item['offset']+item['size'])]
    if owned != list(range(START,END)):
        raise ValueError('Retained stack classification has a gap or overlap')
    # This is one reviewed historical window, not a general license to label
    # arbitrary bytes between pointer-looking words as stack data.
    if sha(raw[START:END]) != EXPECTED_SHA:
        raise ValueError('Retained stack window differs from the reviewed snapshot')
    return dict(classification='data',memory_origin=BASE,window_start=BASE+START,
                window_end_exclusive=BASE+END,sha256=EXPECTED_SHA,items=items,
                frames=[child,reused,parent],complete_string_nodes=14,
                activation_local_semantics='Parameters, local variables and retained earlier stack values; individual fields are not all named',
                live_sundog_activation_claimed=False)


def declarations(raw,report):
    lines=['; Retained stack data: '+EVIDENCE,'.segment "RETAINED_STACK"','snapshot:']
    def words(values):
        lines.append('    .word '+','.join(f'${value:04X}' for value in values))
    def octets(data):
        for offset in range(0,len(data),16):
            lines.append('    .byte '+','.join(f'${value:02X}' for value in data[offset:offset+16]))
    for item in report['items']:
        offset,size,kind=(item[k] for k in ('offset','size','kind'))
        lines += [f'stack_{offset:04x}:',f'; Original memory ${BASE+offset:04X}: {kind}']
        if kind in ('copied-string-node','clipped-string-node'):
            if kind=='copied-string-node':
                words([item['original_pcode_address']])
            words([item['next_address']])
            lines.append(f'    .byte {item["length"]} ; '+repr(item['text']))
            start=offset+(5 if kind=='copied-string-node' else 3)
            octets(raw[start:offset+size])
        elif kind=='call-frame-with-128k-prefix':
            words([item[k] for k in ('saved_string_head','saved_stack_top','static_link',
                                     'dynamic_link','saved_jtab','saved_segment','saved_ipc')])
            octets(bytes([item['saved_cpu_sp'],item['retained_unused_byte']]))
        else:
            lines.append(f'; Parameter/local storage within frame ${item["frame_address"]:04X}.')
            octets(raw[offset:offset+size])
    lines.append(f'.assert * - snapshot = {END-START}, error, "Retained stack extent"')
    return '\n'.join(lines)+'\n'


def prepare(verify=False):
    manifest=json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disk=next(d for d in manifest['disks'] if d['id']=='disk1')
    image=(ROOT/'build/disks'/disk['filename']).read_bytes()
    if sha(image)!=disk['sha256']:
        raise ValueError('Rebuild exact baseline before retained-stack preparation')
    raw=block_bytes(image,260,261)
    report=classify(raw)
    mappings=[]
    for block in (260,263):
        copy=block_bytes(image,block,block+1)
        if classify(copy)!=report or copy[START:]!=raw[START:]:
            raise ValueError('Retained stack copies differ')
        cursor=START
        while cursor<END:
            size=min(256-cursor%256,END-cursor)
            mappings.append(dict(disk='disk1',offset=logical_sector_offset(block*2+cursor//256)+cursor%256,
                                 size=size,input_offset=cursor-START))
            cursor+=size
    name='retained_pascal_stack'
    stem=ROOT/'src/data'/name
    source=declarations(raw,report)
    config=(f'MEMORY {{ IMAGE: start = 0, size = {END-START}, file = %O; }}\n'
            'SEGMENTS { RETAINED_STACK: load = IMAGE, type = ro; }\n')
    recipe=dict(name=name,source=str(stem.with_suffix('.s').relative_to(ROOT)),
                config=str(stem.with_suffix('.cfg').relative_to(ROOT)),mappings=mappings)
    audit=dict(classification_evidence=EVIDENCE,source_output_bytes=END-START,disk_output_bytes=2*(END-START),
               disk='disk1',blocks=[260,263],block_range=[START,END],**report)
    artifacts={stem.with_suffix('.s'):source,stem.with_suffix('.cfg'):config,
               stem.with_suffix('.adopt.json'):json.dumps(recipe,indent=2)+'\n',
               ROOT/'docs/reference/retained-pascal-stack.json':json.dumps(audit,indent=2)+'\n'}
    output=ROOT/'build/retained-pascal-stack'
    output.mkdir(parents=True,exist_ok=True)
    (output/'module.s').write_text(source)
    (output/'module.cfg').write_text(config)
    subprocess.run(['ca65',str(output/'module.s'),'-o',str(output/'module.o')],check=True)
    subprocess.run(['ld65','-C',str(output/'module.cfg'),str(output/'module.o'),'-o',str(output/'module.bin')],check=True)
    if (output/'module.bin').read_bytes()!=raw[START:END]:
        raise ValueError('Retained stack declarations do not assemble exactly')
    for path,text in artifacts.items():
        if verify:
            if not path.is_file() or path.read_text()!=text:
                raise ValueError(f'Retained stack artifact differs: {path}')
        elif path.exists():
            raise ValueError(f'Retained stack artifact already exists: {path}')
    if verify:
        verify_ownership(manifest,[dict(m,input=name) for m in mappings])
    else:
        for path,text in artifacts.items():
            path.write_text(text)
    print(json.dumps(dict(source_bytes=END-START,disk_bytes=2*(END-START),verified=verify)))


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verify',action='store_true')
    prepare(parser.parse_args().verify)
