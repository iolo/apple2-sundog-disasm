#!/usr/bin/env python3
"""Extract bounded title-image copies with identical pixels and retained phases."""
import argparse
import json
from pathlib import Path

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from hgr_asset import VISIBLE, row_offset
from pcode_copies import verify_ownership

RANGES = ((8, 0x58), (0x5A, 0xA5), (0x100, 0x161))
DONOR_SHA = '2b21fb1fc35477e73882e6f4003788631aa28e32d7cc6ed7991cdbaa317d17c1'
RAW_SHA = 'e11d3928139623d4c98c6b36ffb6b41cb18eae5d4e95305610ff9c76fb5e8bcc'
EVIDENCE = 'docs/retained-title-fragments.md'


def classify(raw, donor):
    if len(donor) != 8192 or sha(donor) != DONOR_SHA:
        raise ValueError('Reviewed title donor differs')
    if len(raw) != 252:
        raise ValueError('Retained title fragment length differs')
    coordinates = {row_offset(y)+x: (y, x) for y in range(192) for x in range(40)}
    records = []
    for start, end in RANGES:
        for offset in range(start, end):
            value = raw[len(records)]
            source_offset = 0x1000 + offset
            source = donor[source_offset]
            if source_offset in VISIBLE:
                if value & 127 != source & 127:
                    raise ValueError('Retained title pixel bits differ')
                y, x = coordinates[source_offset]
                record = dict(kind='pixels', row=y, byte_column=x,
                              pixels=value & 127, phase=value >> 7,
                              donor_phase=source >> 7)
            else:
                if value != source:
                    raise ValueError('Retained title hole differs')
                record = dict(kind='hgr-hole', value=value)
            records.append(dict(block_offset=offset, donor_offset=source_offset, **record))
    rebuilt = bytes(r['pixels'] | r['phase'] << 7 if r['kind'] == 'pixels'
                    else r['value'] for r in records)
    if rebuilt != raw or sha(raw) != RAW_SHA:
        raise ValueError('Reviewed title bytes/phases differ')
    return records


def extract(output, verify=False):
    output = output.resolve()
    relative = output.relative_to(ROOT)
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    spec = manifest['components']['title_bitmap']
    if spec['kind'] != 'identified-data' or spec['sha256'] != DONOR_SHA:
        raise ValueError('Classified title donor differs')
    donor = (ROOT/spec['path']).read_bytes()
    disk = next(d for d in manifest['disks'] if d['id'] == 'disk1')
    image = (ROOT/'build/disks'/disk['filename']).read_bytes()
    if sha(image) != disk['sha256']:
        raise ValueError('Rebuild exact baseline before extracting title fragments')
    block = block_bytes(image, 83, 84)
    raw = b''.join(block[start:end] for start, end in RANGES)
    records = classify(raw, donor)
    mappings, cursor = [], 0
    for start, end in RANGES:
        mappings.append(dict(disk='disk1', offset=logical_sector_offset(166+start//256)+start%256,
                             size=end-start, input_offset=cursor))
        cursor += end-start
    report = dict(classification='data', format='apple2-hgr-retained-fragments',
                  size=len(raw), sha256=sha(raw), disk='disk1', logical_block=83,
                  block_ranges=[list(r) for r in RANGES], donor_component='title_bitmap',
                  donor_sha256=DONOR_SHA, donor_offset_bias=4096,
                  pixel_bytes=244, hole_bytes=8, phase_differences=61, exact_bytes=191,
                  classification_evidence=EVIDENCE, records='pixels.json',
                  comparison='All seven pixel bits match; hole bytes match all eight bits.',
                  direct_rendering_of_copies_established=False,
                  excluded_block_ranges=[[0,8],[88,90],[165,256],[353,512]])
    recipe = dict(name='retained_title_fragments', data=str(relative/'fragments.bin'),
                  format=report['format'], classification=EVIDENCE, mappings=mappings)
    artifacts = {'fragments.bin': raw}
    for name, data in [('pixels.json', records), ('manifest.json', report), ('adopt.json', recipe)]:
        artifacts[name] = (json.dumps(data, indent=2)+'\n').encode()
    if verify:
        for name, data in artifacts.items():
            if not (output/name).is_file() or (output/name).read_bytes() != data:
                raise ValueError(f'Retained title artifact differs: {name}')
        verify_ownership(manifest, [dict(m, input='retained_title_fragments') for m in mappings])
    else:
        if output.exists():
            raise ValueError('Retained title output already exists')
        output.mkdir(parents=True)
        for name, data in artifacts.items():
            (output/name).write_bytes(data)
    print(json.dumps(dict(disk_bytes=252, pixel_bytes=244, hole_bytes=8, verified=verify)))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--extract', type=Path)
    group.add_argument('--verify', type=Path)
    args = parser.parse_args()
    extract(args.verify or args.extract, bool(args.verify))
