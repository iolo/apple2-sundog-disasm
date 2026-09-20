#!/usr/bin/env python3
"""Reconstruct reviewed zero storage after complete, bounded data payloads."""
import argparse
import json
import subprocess

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from packed_hgr_asset import decode, encode
from save_state_asset import decode_slot, encode_slot

EVIDENCE = 'docs/asset-block-storage.md'
LAYOUTS = {
    'full_ship': dict(component='packed_full_ship', payload_size=1687, allocation=2048,
                      origins=[('disk2',29),('disk1',188)]),
    'save_descriptors': dict(component='save_slot_records', payload_size=256, allocation=512,
                             origins=[('disk1',26)]),
}


def classify(raw, kind, payload):
    layout = LAYOUTS[kind]
    size = layout['payload_size']
    if len(raw) != layout['allocation'] or len(payload) != size or raw[:size] != payload:
        raise ValueError('Allocation or independently classified payload differs')
    if kind == 'full_ship':
        _, packets, consumed = decode(raw)
        if consumed != size or encode(packets) != payload:
            raise ValueError('Ship image does not end at the reviewed packet boundary')
        last = packets['packets'][-1]
        if last != dict(control=55,payload='00'):
            raise ValueError('Final ship image packet differs')
    else:
        for start in range(0,size,64):
            record = payload[start:start+64]
            if encode_slot(decode_slot(record)) != record:
                raise ValueError('Save descriptor record differs')
    if any(raw[size:]):
        raise ValueError('Nonzero allocation tail requires independent classification')
    return dict(offset=size,size=len(raw)-size,classification='data',
                kind='zero-storage-after-'+kind,sha256=sha(raw[size:]))


def prepare(verify=False):
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disks = {d['id']:d for d in manifest['disks']}
    images = {key:(ROOT/'build/disks'/d['filename']).read_bytes() for key,d in disks.items()}
    for key,disk in disks.items():
        if sha(images[key]) != disk['sha256']:
            raise ValueError('Rebuild exact baseline before storage preparation')
    lines = ['; Classified data storage: '+EVIDENCE,'.segment "ASSET_STORAGE"']
    mappings, records, binary = [], [], bytearray()
    for kind,layout in LAYOUTS.items():
        name = layout['component']
        spec = manifest['components'][name]
        payload = (ROOT/spec['path']).read_bytes()
        if (spec['kind'] != 'identified-data' or len(payload) != spec['size']
                or sha(payload) != spec['sha256']):
            raise ValueError('Existing payload component differs')
        size = layout['allocation']-layout['payload_size']
        lines += [f'{kind}_zero_storage:',f'    .res {size}, 0',
                  f'.assert * - {kind}_zero_storage = {size}, error, "Storage extent"']
        for disk,block in layout['origins']:
            raw = block_bytes(images[disk],block,block+layout['allocation']//512)
            item = classify(raw,kind,payload)
            # Establish adjacency to the actual classified payload mappings,
            # rather than trusting matching bytes alone (especially zeroes).
            for position in range(layout['payload_size']):
                offset = logical_sector_offset(block*2+position//256)+position%256
                owners = [r for r in disks[disk]['regions'] if r['offset'] <= offset < r['offset']+r['size']]
                if (len(owners) != 1 or owners[0]['input'] != name
                        or owners[0]['input_offset']+offset-owners[0]['offset'] != position):
                    raise ValueError('Bounded payload ownership differs')
            position = item['offset']
            while position < len(raw):
                count = min(256-position%256,len(raw)-position)
                mappings.append(dict(disk=disk,
                    offset=logical_sector_offset(block*2+position//256)+position%256,
                    size=count,input_offset=len(binary)+position-item['offset']))
                position += count
            records.append(dict(disk=disk,block=block,allocation_size=len(raw),
                allocation_sha256=sha(raw),payload_component=name,payload_sha256=sha(payload),**item))
        binary.extend(bytes(size))
    name = 'asset_block_storage'
    source = '\n'.join(lines)+'\n'
    config = (f'MEMORY {{ IMAGE: start = 0, size = {len(binary)}, file = %O; }}\n'
              'SEGMENTS { ASSET_STORAGE: load = IMAGE, type = ro; }\n')
    output = ROOT/'build/asset-block-storage'
    output.mkdir(parents=True,exist_ok=True)
    (output/'module.s').write_text(source)
    (output/'module.cfg').write_text(config)
    subprocess.run(['ca65',str(output/'module.s'),'-o',str(output/'module.o')],check=True)
    subprocess.run(['ld65','-C',str(output/'module.cfg'),str(output/'module.o'),'-o',str(output/'module.bin')],check=True)
    if (output/'module.bin').read_bytes() != binary:
        raise ValueError('Storage declarations do not assemble exactly')
    stem = ROOT/'src/data'/name
    recipe = dict(name=name,source=str(stem.with_suffix('.s').relative_to(ROOT)),
                  config=str(stem.with_suffix('.cfg').relative_to(ROOT)),mappings=mappings)
    report = dict(classification='data',classification_evidence=EVIDENCE,
                  source_output_bytes=len(binary),disk_output_bytes=sum(m['size'] for m in mappings),
                  records=records)
    artifacts = {stem.with_suffix('.s'):source,stem.with_suffix('.cfg'):config,
                 stem.with_suffix('.adopt.json'):json.dumps(recipe,indent=2)+'\n',
                 ROOT/'docs/reference/asset-block-storage.json':json.dumps(report,indent=2)+'\n'}
    for path,data in artifacts.items():
        if verify:
            if not path.is_file() or path.read_text() != data:
                raise ValueError(f'Storage artifact differs: {path}')
        elif path.exists():
            raise ValueError(f'Storage artifact already exists: {path}')
    if not verify:
        for path,data in artifacts.items():
            path.write_text(data)
    print(json.dumps(dict(source_bytes=len(binary),disk_bytes=report['disk_output_bytes'],verified=verify)))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verify',action='store_true')
    prepare(parser.parse_args().verify)
