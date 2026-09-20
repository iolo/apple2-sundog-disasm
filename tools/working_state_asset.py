#!/usr/bin/env python3
"""Extract traced record templates, world defaults, and play-side working state."""
import argparse
import json
from pathlib import Path
import struct

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha

# Sizes and word strides come from the consumers documented in working-state.md.
LAYOUTS = {
    'record_templates': [('templates',504,14), ('selector',1,0)],
    'world_defaults': [('table_23',240,120), ('table_24',288,144), ('table_25',912,456)],
    'working_records': [('records16',1024,8), ('records32',2048,16)],
}
ORIGINS = {'record_templates': [('disk1',22),('disk2',2),('disk2',45)],
           'world_defaults': [('disk1',23)], 'working_records': [('disk2',48)]}


def decode(data, kind):
    layout = LAYOUTS[kind]
    if len(data) != sum(size for _,size,_ in layout):
        raise ValueError('Data extends beyond the reviewed layout')
    fields, offset = {}, 0
    for name,size,width in layout:
        if width:
            words = list(struct.unpack(f'<{size//2}H',data[offset:offset+size]))
            fields[name] = [words[i:i+width] for i in range(0,len(words),width)]
        else:
            fields[name] = data[offset]
        offset += size
    return fields


def encode(fields, kind):
    if set(fields) != {name for name,_,_ in LAYOUTS[kind]}:
        raise ValueError('Unexpected data fields')
    data = bytearray()
    for name,size,width in LAYOUTS[kind]:
        value = fields[name]
        if width:
            if len(value) != size//2//width or any(len(row) != width for row in value):
                raise ValueError('Unexpected record dimensions')
            words = [word for row in value for word in row]
            if any(type(word) is not int or not 0 <= word <= 65535 for word in words):
                raise ValueError('Expected unsigned 16-bit words')
            data.extend(struct.pack(f'<{len(words)}H',*words))
        else:
            if type(value) is not int or not 0 <= value <= 255:
                raise ValueError('Expected selector byte')
            data.append(value)
    return bytes(data)


def extract(output):
    output = output.resolve()
    relative = output.relative_to(ROOT)
    if output.exists():
        raise ValueError('Working-state output already exists')
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disks = {d['id']:d for d in manifest['disks']}
    images = {key:(ROOT/'build/disks'/d['filename']).read_bytes() for key,d in disks.items()}
    if any(sha(images[key]) != d['sha256'] for key,d in disks.items()):
        raise ValueError('Rebuild current baseline before extraction')
    data, groups, fields, mappings = bytearray(), [], {}, []
    for kind, layout in LAYOUTS.items():
        size = sum(length for _,length,_ in layout)
        disk_id, block = ORIGINS[kind][0]
        raw = block_bytes(images[disk_id],block,block+(size+511)//512)[:size]
        fields[kind] = decode(raw,kind)
        if encode(fields[kind],kind) != raw:
            raise ValueError('Structured record round trip differs')
        for disk_id,block in ORIGINS[kind]:
            if block_bytes(images[disk_id],block,block+(size+511)//512)[:size] != raw:
                raise ValueError('Recorded template copy differs')
            for pos in range(0,size,256):
                offset = logical_sector_offset(block*2+pos//256)
                length = min(256,size-pos)
                owners = [r for r in disks[disk_id]['regions'] if r['offset'] <= offset
                          and offset+length <= r['offset']+r['size']]
                if len(owners) != 1 or manifest['components'][owners[0]['input']]['kind'] != 'temporary-unresolved':
                    raise ValueError('Working data overlaps reconstructed bytes')
                mappings.append(dict(disk=disk_id,offset=offset,size=length,input_offset=len(data)+pos))
        groups.append(dict(kind=kind,input_offset=len(data),size=size,sha256=sha(raw),
                           origins=[dict(disk=disk,block=block) for disk,block in ORIGINS[kind]],
                           layout=[dict(name=name,size=length,words_per_record=width) for name,length,width in layout]))
        data.extend(raw)
    recipe = dict(name='working_state_data', data=str(relative/'data.bin'),
                  format='Traced gameplay record templates, world defaults, and working data; see manifest',
                  classification='docs/working-state.md', mappings=mappings)
    report = dict(classification='data', classification_evidence='docs/working-state.md',
                  source_bytes=len(data),disk_bytes=sum(m['size'] for m in mappings),
                  sha256=sha(data),groups=groups)
    output.mkdir(parents=True)
    (output/'data.bin').write_bytes(data)
    for name,value in [('fields.json',fields),('manifest.json',report),('adopt.json',recipe)]:
        (output/name).write_text(json.dumps(value,indent=2)+'\n')
    print('Extracted 5,017 source bytes mapping to 6,027 classified disk bytes')


def verify(output):
    data = (output/'data.bin').read_bytes()
    report = json.loads((output/'manifest.json').read_text())
    fields = json.loads((output/'fields.json').read_text())
    if len(data) != 5017 or sha(data) != report['sha256'] or set(fields) != set(LAYOUTS):
        raise ValueError('Working data size/hash/fields differ')
    offset = 0
    for kind,layout in LAYOUTS.items():
        size = sum(length for _,length,_ in layout)
        raw = data[offset:offset+size]
        if decode(raw,kind) != fields[kind] or encode(fields[kind],kind) != raw:
            raise ValueError('Working data round trip differs')
        offset += size
    print('Verified all working-state fields and 5,017 source bytes')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--extract',type=Path)
    group.add_argument('--verify',type=Path)
    args = parser.parse_args()
    extract(args.extract) if args.extract else verify(args.verify)
