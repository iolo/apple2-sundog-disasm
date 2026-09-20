#!/usr/bin/env python3
"""Reconstruct the reviewed retained Pascal command-prompt activation stack."""
import argparse
import json
import struct
import subprocess

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from pcode_copies import verify_ownership

BASE, START, END = 0xb58c, 328, 512
EXPECTED_SHA = '544f86ba1b65bb684cbee59560a913362cd5e6a21ccd81157e181a89c3b3f4db'
EVIDENCE = 'docs/retained-command-stack.md'
PROMPT = b'Command: E(dit, R(un, F(ile, C(omp, L(ink, X(ecute, A(ssem, ? [1.2]'


def classify(raw):
    if len(raw) != 512:
        raise ValueError('Expected complete containing block')
    items, frames = [], []
    # Four full frames plus the surviving last ten bytes of a fifth frame.
    clipped = list(struct.unpack_from('<4H', raw, START))
    if clipped != [BASE+0x162, 0xfd26, 0xfdfa, 0xfd1c] or raw[0x150] != 0xef:
        raise ValueError('Clipped frame fields or dynamic link differ')
    items.append(dict(offset=START, size=10, kind='clipped-call-frame',
                      mark_address=BASE+0x146, missing_prefix_and_static_bytes=6,
                      words=clipped, saved_cpu_sp=raw[0x150], unused_byte=raw[0x151]))
    # Its saved KP is overwritten. The parent link bounds surviving interframe
    # activation storage; do not claim to recover that missing KP field.
    items.append(dict(offset=0x152, size=12, kind='interframe-activation-storage',
                      child_mark=BASE+0x146, parent_prefix=BASE+0x15e))
    for offset,parent,top,head,sp in [
        (0x162,0x178,0x174,None,0xf1),
        (0x178,0x18e,0x18a,None,0xf3),
        (0x18e,0x1ea,0x19e,0x19e,0xf5),
        (0x1ea,None,0x202,0x202,0xf7),
    ]:
        values = list(struct.unpack_from('<7H',raw,offset-4))
        strings,kp,static,dynamic,jtab,segment,ipc = values
        expected_parent = BASE+parent if parent is not None else 0xb798
        if (strings,kp,static,dynamic,raw[offset+10]) != (
            BASE+head if head is not None else 0, BASE+top, 0xb7ca, expected_parent, sp
        ):
            raise ValueError('Call-frame string head, stack bound or link differs')
        item = dict(offset=offset-4,size=16,kind='call-frame-with-128k-prefix',
                    mark_address=BASE+offset,words=values,saved_string_head=strings,
                    saved_stack_top=kp,static_link=static,dynamic_link=dynamic,
                    saved_jtab=jtab,saved_segment=segment,saved_ipc=ipc,
                    saved_cpu_sp=raw[offset+10],unused_byte=raw[offset+11])
        frames.append(item)
        items.append(item)
        local_start,local_end = offset+12,min(top,END)
        if local_start >= local_end:
            raise ValueError('Invalid local storage bounds')
        items.append(dict(offset=local_start,size=local_end-local_start,
                          kind='activation-local-storage',frame_address=BASE+offset,
                          saved_stack_top=kp,clipped_at_end=top>END))
        if offset == 0x18e:
            original,link,length = struct.unpack_from('<HHB',raw,0x19e)
            if original != 0x9faf or link != 0 or length != len(PROMPT) or raw[0x1a3:0x1e6] != PROMPT:
                raise ValueError('Copied command string header, length or text differs')
            if 0x19e+4+((length+2)&~1) != 0x1e6:
                raise ValueError('Copied string allocation does not meet parent prefix')
            items.append(dict(offset=0x19e,size=72,kind='copied-string-node',
                              original_pcode_address=original,next_address=link,
                              length=length,text=PROMPT.decode()))
    owned = [p for item in items for p in range(item['offset'],item['offset']+item['size'])]
    if owned != list(range(START,END)):
        raise ValueError('Stack data ownership has a gap or overlap')
    if sha(raw[START:END]) != EXPECTED_SHA:
        raise ValueError('Stack bytes differ from reviewed snapshot')
    return dict(classification='data',memory_origin=BASE,window_start=BASE+START,
                window_end_exclusive=BASE+END,sha256=EXPECTED_SHA,items=items,
                complete_frames=frames,live_sundog_activation_claimed=False)


def declarations(raw,report):
    lines=['; Retained stack data: '+EVIDENCE,'.segment "COMMAND_STACK"','snapshot:']
    def words(values):
        lines.append('    .word '+','.join(f'${v:04X}' for v in values))
    def octets(data):
        for offset in range(0,len(data),16):
            lines.append('    .byte '+','.join(f'${v:02X}' for v in data[offset:offset+16]))
    for item in report['items']:
        offset,size,kind=(item[k] for k in ('offset','size','kind'))
        lines += [f'stack_{offset:04x}:',f'; Memory ${BASE+offset:04X}: {kind}']
        if 'words' in item:
            words(item['words'])
            octets(bytes([item['saved_cpu_sp'],item['unused_byte']]))
        elif kind=='copied-string-node':
            words([item['original_pcode_address'],item['next_address']])
            lines.append(f'    .byte {item["length"]} ; '+repr(item['text']))
            octets(raw[offset+5:offset+size])
        else:
            lines.append('; Activation storage; bounds and owner recorded in the audit.')
            octets(raw[offset:offset+size])
    lines.append('.assert * - snapshot = 184, error, "Command stack extent"')
    return '\n'.join(lines)+'\n'


def prepare(verify=False):
    manifest=json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disks={d['id']:d for d in manifest['disks']}
    images={key:(ROOT/'build/disks'/d['filename']).read_bytes() for key,d in disks.items()}
    if any(sha(images[key])!=d['sha256'] for key,d in disks.items()):
        raise ValueError('Rebuild exact baseline before command-stack preparation')
    raw=block_bytes(images['disk1'],139,140)
    report=classify(raw)
    mappings=[]
    for disk,image in images.items():
        if classify(block_bytes(image,139,140)) != report:
            raise ValueError('Command stack copy differs')
        if block_bytes(image,103,104)[374:] != raw[374:]:
            raise ValueError('Library-header stack residue differs')
        # The 68-byte counted prompt in block 103 already has source ownership.
        # Preserve that mapping; only its newly classified neighbors are adopted.
        for block,start,end in [(139,START,END),(103,374,418),(103,486,512)]:
            cursor=start
            while cursor<end:
                size=min(256-cursor%256,end-cursor)
                mappings.append(dict(disk=disk,offset=logical_sector_offset(block*2+cursor//256)+cursor%256,
                                     size=size,input_offset=cursor-START))
                cursor+=size
    name='retained_command_stack'
    stem=ROOT/'src/data'/name
    source=declarations(raw,report)
    config=('MEMORY { IMAGE: start = 0, size = 184, file = %O; }\n'
            'SEGMENTS { COMMAND_STACK: load = IMAGE, type = ro; }\n')
    recipe=dict(name=name,source=str(stem.with_suffix('.s').relative_to(ROOT)),
                config=str(stem.with_suffix('.cfg').relative_to(ROOT)),mappings=mappings)
    audit=dict(classification_evidence=EVIDENCE,source_output_bytes=184,disk_output_bytes=508,
               mappings=mappings,existing_counted_prompt_bytes_preserved=68*2,**report)
    artifacts={stem.with_suffix('.s'):source,stem.with_suffix('.cfg'):config,
               stem.with_suffix('.adopt.json'):json.dumps(recipe,indent=2)+'\n',
               ROOT/'docs/reference/retained-command-stack.json':json.dumps(audit,indent=2)+'\n'}
    output=ROOT/'build/retained-command-stack'
    output.mkdir(parents=True,exist_ok=True)
    (output/'module.s').write_text(source)
    (output/'module.cfg').write_text(config)
    subprocess.run(['ca65',str(output/'module.s'),'-o',str(output/'module.o')],check=True)
    subprocess.run(['ld65','-C',str(output/'module.cfg'),str(output/'module.o'),'-o',str(output/'module.bin')],check=True)
    if (output/'module.bin').read_bytes()!=raw[START:END]:
        raise ValueError('Command stack declarations do not assemble exactly')
    for path,text in artifacts.items():
        if verify:
            if not path.is_file() or path.read_text()!=text:
                raise ValueError(f'Command stack artifact differs: {path}')
        elif path.exists():
            raise ValueError(f'Command stack artifact already exists: {path}')
    if verify:
        verify_ownership(manifest,[dict(m,input=name) for m in mappings])
    else:
        for path,text in artifacts.items():
            path.write_text(text)
    print(json.dumps(dict(source_bytes=184,disk_bytes=508,verified=verify)))


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verify',action='store_true')
    prepare(parser.parse_args().verify)
