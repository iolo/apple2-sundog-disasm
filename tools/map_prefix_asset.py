#!/usr/bin/env python3
"""Extract the bounded data prefixes of the already decoded map records."""
import argparse
import json
from pathlib import Path

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha

WORLD_SPECIAL = bytes.fromhex('33c4fffffffffeffffef7fc0ffff')
EVIDENCE = 'docs/map-record-prefixes.md'


def expected_prefix(kind, variant, index):
    if kind == 'world' and variant in ('play','demo') and 0 <= index < (18 if variant=='play' else 2):
        tail = WORLD_SPECIAL if index==1 else bytes.fromhex('d5aa')*7 if 2<=index<=9 else bytes(14)
        return bytes.fromhex('0807')+tail
    if kind == 'city' and variant in ('play','demo') and 0 <= index < (60 if variant=='play' else 4):
        if variant=='play' and index==0:
            return bytes.fromhex('0100000000000000')
        if variant=='play' and index==59:
            return bytes([0x11])*8
        return bytes.fromhex('0605000000000000')
    raise ValueError('Unreviewed map record identity')


def unpack(raw, kind, variant, index):
    expected = expected_prefix(kind,variant,index)
    if raw != expected:
        raise ValueError('Map prefix differs from reviewed record pattern')
    return dict(first_word=int.from_bytes(raw[:2],'little'),remaining_bytes=list(raw[2:]))


def pack(fields, size):
    word,tail = fields['first_word'],fields['remaining_bytes']
    if (size not in (8,16) or type(word) is not int or not 0 <= word <= 65535
            or len(tail) != size-2 or any(type(b) is not int or not 0 <= b < 256 for b in tail)):
        raise ValueError('Invalid prefix fields')
    return word.to_bytes(2,'little')+bytes(tail)


def collect(output):
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disks = {d['id']:d for d in manifest['disks']}
    images = {d['id']:(ROOT/'build/disks'/d['filename']).read_bytes() for d in manifest['disks']}
    for disk_id,image in images.items():
        if sha(image) != disks[disk_id]['sha256']:
            raise ValueError('Rebuild exact baseline before prefix extraction')
    payloads = {}
    for name in ('world_maps','city_maps'):
        spec = manifest['components'][name]
        data = (ROOT/spec['path']).read_bytes()
        if spec['kind'] != 'identified-data' or len(data) != spec['size'] or sha(data) != spec['sha256']:
            raise ValueError('Existing map payload source differs')
        payloads[name] = data
    binary,records,fields,mappings = bytearray(),[],[],[]
    layouts = [('world','play','disk2',55,18,256,16),('world','demo','disk1',194,2,256,16),
               ('city','play','disk2',64,60,128,8),('city','demo','disk1',195,4,128,8)]
    for kind,variant,disk_id,first,count,stride,prefix_size in layouts:
        records_per_block = 512//stride
        bank = block_bytes(images[disk_id],first,first+(count+records_per_block-1)//records_per_block)
        for index in range(count):
            start = index*stride
            raw = bank[start:start+prefix_size]
            values = unpack(raw,kind,variant,index)
            if pack(values,prefix_size) != raw:
                raise ValueError('Prefix field inversion differs')
            payload_name = kind+'_maps'
            payload_index = index+(60 if kind=='city' and variant=='demo' else 0)
            payload_size = stride-prefix_size
            payload_offset = payload_index*payload_size
            payload = bank[start+prefix_size:start+stride]
            if payload != payloads[payload_name][payload_offset:payload_offset+payload_size]:
                raise ValueError('Prefix is not followed by its reviewed map payload')
            block,within = first+index//records_per_block,index%records_per_block*stride
            logical = block*512+within
            offset = logical_sector_offset(logical//256)+logical%256
            # Verify that the whole following payload still belongs to the
            # independently classified map asset, including its source offset.
            owners = [r for r in disks[disk_id]['regions'] if r['offset'] <= offset+prefix_size
                      and offset+stride <= r['offset']+r['size']]
            if (len(owners) != 1 or owners[0]['input'] != payload_name
                    or owners[0]['input_offset']+offset+prefix_size-owners[0]['offset'] != payload_offset):
                raise ValueError('Map record payload ownership differs')
            mappings.append(dict(disk=disk_id,offset=offset,size=prefix_size,input_offset=len(binary)))
            records.append(dict(kind=kind,variant=variant,index=index,disk=disk_id,block=block,
                                byte_offset=within,size=prefix_size,input_offset=len(binary),sha256=sha(raw),
                                payload_component=payload_name,payload_input_offset=payload_offset,
                                payload_size=payload_size,payload_sha256=sha(payload)))
            fields.append(dict(kind=kind,variant=variant,index=index,**values))
            binary.extend(raw)
    relative = output.relative_to(ROOT)
    recipe = dict(name='map_record_prefixes',data=str(relative/'prefixes.bin'),
                  format='Fixed data prefixes: twenty 16-byte world records and sixty-four 8-byte city records',
                  classification=EVIDENCE,mappings=mappings)
    report = dict(classification='data',classification_evidence=EVIDENCE,size=len(binary),sha256=sha(binary),
                  record_count=len(records),records=records,
                  field_note='First word and remaining prefix bytes are lossless fields; their precise game meaning is not asserted.')
    return bytes(binary),fields,report,recipe


def run(output, verify=False):
    output = output.resolve()
    output.relative_to(ROOT)
    binary,fields,report,recipe = collect(output)
    artifacts = {output/'prefixes.bin':binary}
    for name,value in [('fields.json',fields),('manifest.json',report),('adopt.json',recipe)]:
        artifacts[output/name] = (json.dumps(value,indent=2)+'\n').encode()
    if verify:
        for path,data in artifacts.items():
            if not path.is_file() or path.read_bytes() != data:
                raise ValueError(f'Prefix asset differs: {path}')
    else:
        if output.exists():
            raise ValueError('Prefix output already exists')
        output.mkdir(parents=True)
        for path,data in artifacts.items():
            path.write_bytes(data)
    print(json.dumps(dict(records=report['record_count'],classified_bytes=len(binary),verified=verify)))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--extract',type=Path)
    group.add_argument('--verify',type=Path)
    args = parser.parse_args()
    run(args.verify or args.extract,bool(args.verify))
