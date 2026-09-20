#!/usr/bin/env python3
"""Extract the 32-byte interaction records consumed by game 18 procedure 16."""
import argparse
import json
from pathlib import Path

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha


def decode(data):
    if len(data) != 512:
        raise ValueError('Expected sixteen 32-byte interaction records')
    records = []
    for start in range(0,512,32):
        row = data[start:start+32]
        if row[26:] != bytes(6):
            raise ValueError('Nonzero unreviewed record padding')
        records.append(dict(bounds=[list(row[i:i+4]) for i in range(0,20,4)],
                            style_nibbles=[row[20]&15,row[20]>>4],
                            drawing_value=row[21],relative_offsets=[row[22]-128,row[23]-128],
                            parameters=list(row[24:26]),padding=list(row[26:])))
    return records


def encode(records):
    if len(records) != 16:
        raise ValueError('Expected sixteen interaction records')
    data = bytearray()
    for record in records:
        bounds, styles = record['bounds'], record['style_nibbles']
        offsets, parameters, padding = record['relative_offsets'], record['parameters'], record['padding']
        if (len(bounds) != 5 or any(len(group) != 4 for group in bounds) or len(styles) != 2
                or len(offsets) != 2 or len(parameters) != 2 or len(padding) != 6):
            raise ValueError('Invalid interaction record field dimensions')
        if any(type(n) is not int or not 0 <= n <= 15 for n in styles):
            raise ValueError('Style fields must be nibbles')
        if any(type(n) is not int or not -128 <= n <= 127 for n in offsets):
            raise ValueError('Relative offsets must be signed bytes')
        values = ([n for group in bounds for n in group]+[styles[0]+16*styles[1],record['drawing_value']]
                  +[n+128 for n in offsets]+parameters+padding)
        if any(type(n) is not int or not 0 <= n <= 255 for n in values):
            raise ValueError('Stored fields must be byte values')
        if any(padding):
            raise ValueError('Nonzero unreviewed record padding')
        data.extend(values)
    return bytes(data)


def extract(output):
    output = output.resolve()
    relative = output.relative_to(ROOT)
    if output.exists():
        raise ValueError('Interaction-record output already exists')
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disks = {d['id']:d for d in manifest['disks']}
    images = {}
    for disk in disks.values():
        image = (ROOT/'build/disks'/disk['filename']).read_bytes()
        if sha(image) != disk['sha256']:
            raise ValueError('Rebuild current baseline before extraction')
        images[disk['id']] = image
    data = block_bytes(images['disk2'],79,80)
    records = decode(data)
    if encode(records) != data or block_bytes(images['disk1'],196,197)[128:] != data[128:]:
        raise ValueError('Interaction fields or stored record copies differ')
    mappings = []
    for disk_id,block,start,size in [('disk2',79,0,512),('disk1',196,128,384)]:
        position = start
        while position < start+size:
            offset = logical_sector_offset(block*2+position//256)+position%256
            length = min(start+size-position,256-position%256)
            owners = [r for r in disks[disk_id]['regions'] if r['offset'] <= offset
                      and offset+length <= r['offset']+r['size']]
            if len(owners) != 1 or manifest['components'][owners[0]['input']]['kind'] != 'temporary-unresolved':
                raise ValueError('Interaction records overlap reconstructed bytes')
            mappings.append(dict(disk=disk_id,offset=offset,size=length,input_offset=position))
            position += length
    report = dict(classification='data',classification_evidence='docs/interaction-records.md',
                  size=len(data),sha256=sha(data),record_count=16,record_size=32,
                  fields_per_record_bytes=26,zero_padding_per_record_bytes=6,disk_output_bytes=896,
                  origins=[dict(disk='disk2',block=79,byte_range=[0,512],record_indices=[0,16]),
                           dict(disk='disk1',block=196,byte_range=[128,512],record_indices=[4,16])],
                  excluded='Disk 1 block 196 bytes 0–127 and disk 2 block 80 remain unresolved')
    recipe = dict(name='interaction_records',data=str(relative/'records.bin'),
                  format='Sixteen 32-byte interaction bounds/style/parameter records with six-byte zero padding',
                  classification=report['classification_evidence'],mappings=mappings)
    output.mkdir(parents=True)
    (output/'records.bin').write_bytes(data)
    for name,value in [('fields.json',records),('manifest.json',report),('adopt.json',recipe)]:
        (output/name).write_text(json.dumps(value,indent=2)+'\n')
    print('Extracted sixteen records and twelve stored copies: 896 disk bytes')


def verify(output):
    data = (output/'records.bin').read_bytes()
    fields = json.loads((output/'fields.json').read_text())
    report = json.loads((output/'manifest.json').read_text())
    if sha(data) != report['sha256'] or decode(data) != fields or encode(fields) != data:
        raise ValueError('Interaction record bytes/fields differ')
    print('Verified sixteen records, all field boundaries, and six-byte zero padding')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--extract',type=Path)
    group.add_argument('--verify',type=Path)
    args = parser.parse_args()
    extract(args.extract) if args.extract else verify(args.verify)
