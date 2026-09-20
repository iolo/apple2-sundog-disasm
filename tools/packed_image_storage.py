#!/usr/bin/env python3
"""Audit retained zero-run records and storage after two complete RLE images."""
import argparse
import json
import subprocess

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from packed_hgr_asset import decode, encode
from pcode_copies import verify_ownership

EVIDENCE = 'docs/packed-image-storage.md'
LAYOUTS = {
    'ship_section': dict(component='packed_ship_section', block=33, blocks=4,
                         start=0, allocation=2048, payload=1560, stride=1,
                         final_control=58, retained_control=1),
    'flip_disk': dict(component='play_boot_notice', block=0, blocks=2,
                      start=256, allocation=768, payload=576, stride=4,
                      final_control=26, retained_control=120),
}


def classify(raw, kind, payload):
    layout = LAYOUTS[kind]
    size = layout['payload']
    if len(raw) != layout['allocation'] or len(payload) != size or raw[:size] != payload:
        raise ValueError('Allocation or classified image payload differs')
    page, description, consumed = decode(raw)
    if (consumed != size or encode(description) != payload
            or description['stride'] != layout['stride']
            or description['packets'][-1] != dict(control=layout['final_control'], payload='00')):
        raise ValueError('Native image termination or final packet differs')
    # No partial final packet is being moved into the retained-storage category.
    if sum((p['control'] & 127)+1 for p in description['packets']) != len(page):
        raise ValueError('Reviewed image must end on a complete packet boundary')
    tail = raw[size:]
    if tail[:2] != bytes([layout['retained_control'],0]) or any(tail[2:]):
        raise ValueError('Reviewed retained zero-run record or bounded zero storage differs')
    return dict(classification='data', classification_basis='bounded-format-inference',
                payload_bytes=size, allocation_bytes=len(raw), stride=layout['stride'],
                consumed_bytes=consumed, decoded_sha256=sha(page),
                retained_record=dict(offset=size, size=2, control=tail[0], value=0,
                                     format_run_length=tail[0]+1, consumed_by_decoder=False),
                zero_storage=dict(offset=size+2, size=len(tail)-2),
                classified_bytes=len(tail), storage_sha256=sha(tail),
                historical_producer_proved=False)


def run(prepare=False):
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disk = next(d for d in manifest['disks'] if d['id']=='disk2')
    image = (ROOT/'build/disks'/disk['filename']).read_bytes()
    if sha(image) != disk['sha256']:
        raise ValueError('Rebuild exact baseline before storage audit')
    binary, mappings, records = bytearray(), [], []
    for kind, layout in LAYOUTS.items():
        name = layout['component']
        spec = manifest['components'][name]
        payload = (ROOT/spec['path']).read_bytes()
        if spec['kind'] != 'identified-data' or sha(payload) != spec['sha256']:
            raise ValueError('Independently classified payload component differs')
        raw = block_bytes(image,layout['block'],layout['block']+layout['blocks'])[layout['start']:]
        record = classify(raw,kind,payload)
        # Verify location/owner, not just byte equality, for the complete payload.
        for index in range(len(payload)):
            logical = layout['block']*512+layout['start']+index
            offset = logical_sector_offset(logical//256)+logical%256
            owners = [r for r in disk['regions'] if r['offset'] <= offset < r['offset']+r['size']]
            if (len(owners) != 1 or owners[0]['input'] != name
                    or owners[0]['input_offset']+offset-owners[0]['offset'] != index):
                raise ValueError('Classified payload mapping differs')
        position = len(payload)
        while position < len(raw):
            logical = layout['block']*512+layout['start']+position
            size = min(256-logical%256,len(raw)-position)
            mappings.append(dict(disk='disk2',offset=logical_sector_offset(logical//256)+logical%256,
                                 size=size,input_offset=len(binary)+position-len(payload)))
            position += size
        binary.extend(raw[len(payload):])
        records.append(dict(name=kind,block=layout['block'],start=layout['start'],
                            payload_component=name,payload_sha256=sha(payload),**record))
    stem = ROOT/'src/data/packed_image_storage'
    output = ROOT/'build/packed-image-storage'
    output.mkdir(parents=True,exist_ok=True)
    subprocess.run(['ca65',str(stem.with_suffix('.s')),'-o',str(output/'storage.o')],check=True)
    subprocess.run(['ld65','-C',str(stem.with_suffix('.cfg')),str(output/'storage.o'),
                    '-o',str(output/'storage.bin')],check=True)
    if (output/'storage.bin').read_bytes() != binary:
        raise ValueError('Retained record/storage source differs')
    recipe = dict(name='packed_image_storage',source=str(stem.with_suffix('.s').relative_to(ROOT)),
                  config=str(stem.with_suffix('.cfg').relative_to(ROOT)),mappings=mappings)
    report = dict(classification_evidence=EVIDENCE,classified_data_bytes=len(binary),records=records)
    artifacts = {stem.with_suffix('.adopt.json'):json.dumps(recipe,indent=2)+'\n',
                 ROOT/'docs/reference/packed-image-storage.json':json.dumps(report,indent=2)+'\n'}
    for path, value in artifacts.items():
        if prepare:
            path.write_text(value)
        elif path.read_text() != value:
            raise ValueError(f'Storage artifact differs: {path}')
    if not prepare:
        verify_ownership(manifest,[dict(m,input=recipe['name']) for m in mappings])
    print(json.dumps(dict(classified_data_bytes=len(binary),verified=not prepare)))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--prepare',action='store_true')
    run(parser.parse_args().prepare)
