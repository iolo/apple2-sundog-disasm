#!/usr/bin/env python3
"""Extract the evidenced linear window bitmap and saved-position fields."""
import argparse
import json
from pathlib import Path

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha


def decode(data):
    if len(data) != 1922:
        raise ValueError('Expected 1,920 pixel bytes and two position bytes')
    return dict(rows=[list(data[y*20:(y+1)*20]) for y in range(96)],
                x_byte=data[1920],y_row=data[1921])


def encode(fields):
    rows = fields['rows']
    if len(rows) != 96 or any(len(row) != 20 for row in rows):
        raise ValueError('Expected 96 rows of twenty source bytes')
    values = [value for row in rows for value in row]+[fields['x_byte'],fields['y_row']]
    if any(type(value) is not int or not 0 <= value <= 255 for value in values):
        raise ValueError('Window fields must contain byte values')
    return bytes(values)


def preview(fields, output):
    from PIL import Image
    pixels = bytes(255 if value & (1<<bit) else 0 for row in fields['rows'] for value in row for bit in range(7))
    image = Image.frombytes('L',(140,96),pixels)
    image.resize((560,384),Image.Resampling.NEAREST).save(output)


def extract(output):
    output = output.resolve()
    relative = output.relative_to(ROOT)
    if output.exists():
        raise ValueError('Window output already exists')
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disk = next(d for d in manifest['disks'] if d['id'] == 'disk2')
    image = (ROOT/'build/disks'/disk['filename']).read_bytes()
    if sha(image) != disk['sha256']:
        raise ValueError('Rebuild current baseline before extraction')
    bank = block_bytes(image,37,41)
    data = bank[:1920]+bank[2000:2002]
    fields = decode(data)
    if encode(fields) != data:
        raise ValueError('Window field round trip differs')
    mappings = []
    for start,size,source in [(0,1920,0),(2000,2,1920)]:
        pos = 0
        while pos < size:
            address = start+pos
            offset = logical_sector_offset(37*2+address//256)+address%256
            length = min(size-pos,256-address%256)
            owners = [r for r in disk['regions'] if r['offset'] <= offset and offset+length <= r['offset']+r['size']]
            if len(owners) != 1 or manifest['components'][owners[0]['input']]['kind'] != 'temporary-unresolved':
                raise ValueError('Window bytes overlap reconstructed data')
            mappings.append(dict(disk='disk2',offset=offset,size=length,input_offset=source+pos))
            pos += length
    report = dict(classification='data',classification_evidence='docs/interaction-window.md',
                  size=len(data),sha256=sha(data),disk='disk2',blocks=[37,41],
                  width=140,height=96,row_bytes=20,bitmap_bytes=1920,
                  position_fields=[dict(name='x_byte',bank_offset=2000,input_offset=1920),
                                   dict(name='y_row',bank_offset=2001,input_offset=1921)],
                  excluded_bank_ranges=[[1920,2000],[2002,2048]],
                  preview_note='Monochrome lower seven bits; raw bytes retain video phase bits')
    recipe = dict(name='interaction_window',data=str(relative/'window.bin'),
                  format='Linear 20-byte x 96-row bitmap followed by two saved-position bytes',
                  classification='docs/interaction-window.md',mappings=mappings)
    output.mkdir(parents=True)
    (output/'window.bin').write_bytes(data)
    for name,value in [('fields.json',fields),('manifest.json',report),('adopt.json',recipe)]:
        (output/name).write_text(json.dumps(value,indent=2)+'\n')
    preview(fields,output/'monochrome.png')
    print('Extracted 1,920 bitmap bytes and two saved-position bytes')


def verify(output):
    data = (output/'window.bin').read_bytes()
    fields = json.loads((output/'fields.json').read_text())
    report = json.loads((output/'manifest.json').read_text())
    if sha(data) != report['sha256'] or decode(data) != fields or encode(fields) != data:
        raise ValueError('Window asset bytes/fields differ')
    print('Verified 1,922 window bytes; allocation tail is audited by window_allocation_tail.py')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--extract',type=Path)
    group.add_argument('--verify',type=Path)
    args = parser.parse_args()
    extract(args.extract) if args.extract else verify(args.verify)
