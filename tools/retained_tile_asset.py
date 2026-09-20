#!/usr/bin/env python3
"""Extract exact retained rows from the independently classified tile bank 3."""
import argparse
import json
from pathlib import Path

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from pcode_copies import verify_ownership
from tile_asset import unpack_tiles, pack_tiles

EVIDENCE = 'docs/retained-tile-rows.md'
DONOR_SHA = '6e5d341c0f8e1ad5234b067e848c1755fd59ea0ac8e05df9a226de0c51f8d3ef'
RAW_SHA = '8c11793b90a788cecdb01e0ed01cd5d361bda07b2e8efa02172950aedd660fc7'


def classify(raw, donor):
    if len(donor) != 2048 or sha(donor) != DONOR_SHA:
        raise ValueError('Reviewed tile-bank donor differs')
    tiles = unpack_tiles(donor)
    if pack_tiles(tiles) != donor:
        raise ValueError('Donor tile layout is not reversible')
    rows = tiles[15][24:32]
    expected = bytes(value for row in rows for value in row)
    if len(raw) != 32 or raw != expected or sha(raw) != RAW_SHA:
        raise ValueError('Retained rows differ from the reviewed tile fragment')
    return rows


def extract(output, verify=False):
    output = output.resolve()
    relative = output.relative_to(ROOT)
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    spec = manifest['components']['tile_bank3']
    if spec['kind'] != 'identified-data' or spec['sha256'] != DONOR_SHA:
        raise ValueError('Classified donor component differs')
    donor = (ROOT/spec['path']).read_bytes()
    raw, mappings, origins = None, [], []
    for disk_id, block in [('disk1', 187), ('disk2', 28)]:
        disk = next(d for d in manifest['disks'] if d['id'] == disk_id)
        image = (ROOT/'build/disks'/disk['filename']).read_bytes()
        if sha(image) != disk['sha256']:
            raise ValueError('Rebuild exact baseline before extracting retained rows')
        selected = block_bytes(image, block, block+1)[480:512]
        if raw is not None and selected != raw:
            raise ValueError('Retained copies differ')
        raw = selected
        rows = classify(raw, donor)
        mappings.append(dict(disk=disk_id, offset=logical_sector_offset(block*2+1)+224,
                             size=32, input_offset=0))
        origins.append(dict(disk=disk_id, block=block, byte_offset=480, size=32))
    report = dict(classification='data', format='sundog-retained-tile-rows', size=32,
                  disk_bytes=64, sha256=sha(raw), origins=origins, classification_evidence=EVIDENCE,
                  donor_component='tile_bank3', donor_sha256=DONOR_SHA,
                  donor_offset=2016, donor_tile=15, donor_rows=[24,32], bytes_per_row=4,
                  fragment_size_pixels=[28,8], transform='Exact copy, preserving all eight bits',
                  row_order='Top to bottom, four bytes left to right; low bits 0–6 are pixels',
                  rows='rows.json', preview_context='assets/tiles/bank3/atlas.png, tile 0F, bottom eight rows',
                  direct_rendering_of_copies_established=False)
    recipe = dict(name='retained_tile_rows', data=str(relative/'rows.bin'),
                  format=report['format'], classification=EVIDENCE, mappings=mappings)
    artifacts = {'rows.bin': raw}
    for name, data in [('rows.json', rows), ('manifest.json', report), ('adopt.json', recipe)]:
        artifacts[name] = (json.dumps(data, indent=2)+'\n').encode()
    if verify:
        for name, data in artifacts.items():
            if not (output/name).is_file() or (output/name).read_bytes() != data:
                raise ValueError(f'Retained tile artifact differs: {name}')
        verify_ownership(manifest, [dict(m, input='retained_tile_rows') for m in mappings])
    else:
        if output.exists():
            raise ValueError('Retained tile output already exists')
        output.mkdir(parents=True)
        for name, data in artifacts.items():
            (output/name).write_bytes(data)
    print(json.dumps(dict(source_bytes=32, disk_bytes=64, retained_rows=8, verified=verify)))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--extract', type=Path)
    group.add_argument('--verify', type=Path)
    args = parser.parse_args()
    extract(args.verify or args.extract, bool(args.verify))
