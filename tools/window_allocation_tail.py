#!/usr/bin/env python3
"""Audit zero storage and a retained Pascal record after the window bitmap."""
import argparse
import json
import subprocess

from disk_layout import ROOT, block_bytes, sha
from pcode_copies import verify_ownership

EVIDENCE = 'docs/window-allocation-tail.md'
FIELDS = [('name',0,8),('left_link',8,2),('right_link',10,2),('type_pointer',12,2),('next_pointer',14,2)]
PREFIX = bytes.fromhex('494e46494c4520204e48224806483c33')
ASSET_SHA = '722424db50f38fdd7aa84efeed868ec4513a4570850c92a6301184641be99dc6'


def classify(bank, asset):
    if len(bank) != 2048 or len(asset) != 1922 or sha(asset) != ASSET_SHA:
        raise ValueError('Window allocation or independently classified asset differs')
    if bank[:1920]+bank[2000:2002] != asset:
        raise ValueError('Bitmap or saved-position boundaries differ')
    if any(bank[1920:2000]) or any(bank[2002:2032]):
        raise ValueError('Bounded window zero storage differs')
    prefix = bank[2032:]
    if prefix != PREFIX:
        raise ValueError('Reviewed retained identifier prefix differs')
    fields = []
    for name, offset, size in FIELDS:
        value = prefix[offset:offset+size]
        if name == 'name':
            decoded = value.decode('ascii')
            if decoded.rstrip() != 'INFILE' or decoded != decoded.rstrip().ljust(8):
                raise ValueError('Identifier name is not the reviewed padded ALPHA')
        else:
            decoded = int.from_bytes(value,'little')
            if decoded & 1 or not 0x0200 <= decoded < 0xC000:
                raise ValueError('Retained pointer is outside aligned main RAM')
        fields.append(dict(name=name,offset=offset,size=size,value=decoded))
    rebuilt = fields[0]['value'].encode('ascii')+b''.join(f['value'].to_bytes(2,'little') for f in fields[1:])
    if rebuilt != prefix:
        raise ValueError('Identifier field representation is not reversible')
    return dict(classification='data',disk='disk2',blocks=[37,41],
                zero_storage_ranges=[[1920,2000],[2002,2032]],zero_storage_bytes=110,
                retained_record_offset=2032,retained_record_bytes=16,record_fields=fields,
                record_prefix_sha256=sha(prefix),missing_variant_fields=True,
                pointer_targets_recovered=False,historical_producer_identity_proved=False,
                newly_classified_bytes=126,full_allocation_classified_bytes=2048)


def run(prepare=False):
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disk = next(d for d in manifest['disks'] if d['id']=='disk2')
    image = (ROOT/'build/disks'/disk['filename']).read_bytes()
    if sha(image) != disk['sha256']:
        raise ValueError('Rebuild exact baseline before window-tail audit')
    spec = manifest['components']['interaction_window']
    if spec['kind'] != 'identified-data' or spec['sha256'] != ASSET_SHA:
        raise ValueError('Window donor classification differs')
    asset = (ROOT/spec['path']).read_bytes()
    bank = block_bytes(image,37,41)
    report = classify(bank,asset)
    report.update(classification_evidence=EVIDENCE,allocation_sha256=sha(bank),asset_sha256=sha(asset))
    output = ROOT/'build/window-allocation-tail'
    output.mkdir(parents=True,exist_ok=True)
    subprocess.run(['ca65',str(ROOT/'src/data/window_allocation_tail.s'),'-o',str(output/'tail.o')],check=True)
    subprocess.run(['ld65','-C',str(ROOT/'src/data/window_allocation_tail.cfg'),str(output/'tail.o'),
                    '-o',str(output/'tail.bin')],check=True)
    if (output/'tail.bin').read_bytes() != bank[1920:2000]+bank[2002:]:
        raise ValueError('Named tail source does not reproduce reviewed fields/storage')
    adoption = json.loads((ROOT/'src/data/window_allocation_tail.adopt.json').read_text())
    path = ROOT/'docs/reference/window-allocation-tail.json'
    text = json.dumps(report,indent=2)+'\n'
    if prepare:
        path.write_text(text)
    else:
        verify_ownership(manifest,[dict(m,input=adoption['name']) for m in adoption['mappings']])
        if path.read_text() != text:
            raise ValueError('Window-tail audit report differs')
    print(json.dumps(dict(new_data_bytes=126,full_allocation_bytes=2048,verified=not prepare)))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--prepare',action='store_true')
    run(parser.parse_args().prepare)
