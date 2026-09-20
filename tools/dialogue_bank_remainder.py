#!/usr/bin/env python3
"""Classify bounded spare script storage and unused, structurally complete messages."""
import argparse
import json
from pathlib import Path

from dialogue_dictionary_asset import text_fields, text_bytes
from dialogue_script import analyze_bank
from disk_layout import ROOT, block_bytes, logical_sector_offset, sha


def inspect(bank):
    audit = analyze_bank(bank)
    script_end = max(record['end'] for record in audit['records'])
    known = {record['offset']:record for record in audit['text_records']}
    text_start = bank[17]*2 if bank[0]==18 else min(known)
    if script_end>text_start or any(bank[script_end:text_start]):
        raise ValueError('Unreviewed nonzero bytes in bounded spare script storage')
    cursor = text_start
    if bank[0]==18:
        for _ in range(bank[16]):
            if cursor>=512:
                raise ValueError('Supplemental length outside bank')
            end = cursor+1+bank[cursor]
            aligned = end+(end&1)
            if aligned>512 or any(bank[end:aligned]):
                raise ValueError('Invalid supplemental extent/alignment')
            cursor = aligned
    message_start = cursor
    messages, extra, visited = [], [], set()
    while cursor<512:
        length = bank[cursor]
        end = cursor+1+length
        aligned = end+(end&1)
        if not length or aligned>512 or any(bank[end:aligned]):
            raise ValueError('Incomplete/unreviewed message record in text area')
        record = dict(offset=cursor,end=aligned,length=length,alignment_bytes=aligned-end)
        if cursor in known:
            if record!=known[cursor]:
                raise ValueError('Sequential message layout differs from script reference')
            visited.add(cursor)
        else:
            extra.append(record)
        messages.append(record)
        cursor = aligned
    if visited!=set(known):
        raise ValueError('Referenced message is not at a sequential record boundary')
    return dict(spare_range=[script_end,text_start],message_start=message_start,
                message_end=cursor,messages=messages,unreferenced_messages=extra)


def extract(output):
    output = output.resolve()
    relative = output.relative_to(ROOT)
    if output.exists():
        raise ValueError('Dialogue remainder output already exists')
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disk = next(d for d in manifest['disks'] if d['id']=='disk2')
    image = (ROOT/'build/disks'/disk['filename']).read_bytes()
    if sha(image)!=disk['sha256']:
        raise ValueError('Rebuild current baseline before extraction')
    data,fields,mappings,audits = bytearray(),[],[],[]
    for block in range(90,103):
        bank = block_bytes(image,block,block+1)
        audit = inspect(bank)
        audits.append(dict(block=block,**audit))
        ranges = [('spare',*audit['spare_range'])]
        ranges += [('message',record['offset'],record['end']) for record in audit['unreferenced_messages']]
        for kind,start,end in ranges:
            base = len(data)
            field = dict(kind=kind,block=block,bank_offset=start,input_offset=base,size=end-start)
            if kind=='message':
                field.update(text_fields(bank[start+1:start+1+bank[start]]))
            else:
                field['fill_byte'] = 0
            fields.append(field)
            cursor = start
            while cursor<end:
                offset = logical_sector_offset(block*2+cursor//256)+cursor%256
                size = min(end-cursor,256-cursor%256)
                owners = [r for r in disk['regions'] if r['offset']<=offset and offset+size<=r['offset']+r['size']]
                if len(owners)!=1 or manifest['components'][owners[0]['input']]['kind']!='temporary-unresolved':
                    raise ValueError('Reviewed bank remainder overlaps reconstructed bytes')
                mappings.append(dict(disk='disk2',offset=offset,size=size,input_offset=base+cursor-start))
                cursor += size
            data.extend(bank[start:end])
    if encode(fields)!=data:
        raise ValueError('Remainder field round trip differs')
    report = dict(classification='data',classification_evidence='docs/dialogue-bank-layout.md',
                  size=len(data),sha256=sha(data),banks=audits,
                  spare_bytes=sum(f['size'] for f in fields if f['kind']=='spare'),
                  message_bytes=sum(f['size'] for f in fields if f['kind']=='message'),
                  unreferenced_message_count=sum(f['kind']=='message' for f in fields))
    recipe = dict(name='dialogue_bank_storage',data=str(relative/'data.bin'),
                  format='Bounded zero-filled script capacity and counted word-aligned unused messages',
                  classification=report['classification_evidence'],mappings=mappings)
    output.mkdir(parents=True)
    (output/'data.bin').write_bytes(data)
    for name,value in [('fields.json',fields),('manifest.json',report),('adopt.json',recipe)]:
        (output/name).write_text(json.dumps(value,indent=2)+'\n')
    print(f'Extracted {len(data)} bytes: {report["spare_bytes"]} spare and {report["message_bytes"]} message bytes')


def encode(fields):
    data = bytearray()
    for field in fields:
        if field['input_offset']!=len(data) or type(field['size']) is not int or field['size']<=0:
            raise ValueError('Invalid remainder extent')
        if field['kind']=='spare' and type(field['fill_byte']) is int and field['fill_byte']==0:
            raw = bytes(field['size'])
        elif field['kind']=='message':
            text = text_bytes(field)
            if not 1<=len(text)<=255:
                raise ValueError('Invalid message length')
            raw = bytes([len(text)])+text+bytes((len(text)+1)&1)
        else:
            raise ValueError('Unknown remainder field classification')
        if len(raw)!=field['size']:
            raise ValueError('Message extent differs')
        data.extend(raw)
    return bytes(data)


def verify(output):
    data = (output/'data.bin').read_bytes()
    fields = json.loads((output/'fields.json').read_text())
    report = json.loads((output/'manifest.json').read_text())
    if encode(fields)!=data or sha(data)!=report['sha256'] or len(data)!=report['size']:
        raise ValueError('Bank remainder encoding differs')
    image = (ROOT/'build/disks/sundog-disk2-util.dsk').read_bytes()
    for audit in report['banks']:
        block = audit['block']
        if dict(block=block,**inspect(block_bytes(image,block,block+1)))!=audit:
            raise ValueError('Bank layout differs from recorded evidence')
    print('Verified all thirteen complete dialogue-bank layouts and 925 extracted bytes')


if __name__=='__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--extract',type=Path)
    group.add_argument('--verify',type=Path)
    args = parser.parse_args()
    extract(args.extract) if args.extract else verify(args.verify)
