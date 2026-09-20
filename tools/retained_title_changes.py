#!/usr/bin/env python3
"""Audit altered title pixels through a sparse differential 6-and-2 model."""
import argparse
import json
from pathlib import Path

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from hgr_asset import row_offset
from pcode_copies import verify_ownership
from retained_title_asset import DONOR_SHA, RANGES as EARLIER_RANGES, classify as earlier_classify

RANGES = ((88,90),(165,256),(353,512))
EVIDENCE = 'docs/retained-title-changes.md'
# Pre-GCR-translation six-bit differential symbols, including final checksum.
# HGR phase bits are represented separately; offsets 0..7 are disk-control data.
EDITS = (
    ((3,8),(4,8),(174,16),(175,16),(251,6),(301,20),(307,12),(342,30)),
    ((45,32),(46,32),(47,16),(48,16),(183,23),(305,7),(306,7),(342,23)),
)


def differential_symbols(data):
    if len(data) != 256:
        raise ValueError('6-and-2 sector must have 256 bytes')
    twos = [0]*86
    for i,value in enumerate(data):
        twos[i%86] |= (((value&1)<<1)|((value&2)>>1)) << (2*(i//86))
    values = twos+[value>>2 for value in data]
    return bytes(a^b for a,b in zip(values+[0],[0]+values))


def decode_symbols(symbols):
    if len(symbols) != 343 or any(v>63 for v in symbols):
        raise ValueError('Expected 343 six-bit symbols')
    values, previous = [], 0
    for symbol in symbols:
        previous ^= symbol
        values.append(previous)
    if values[-1] != 0:
        raise ValueError('Differential checksum differs')
    twos, top = values[:86], values[86:342]
    if twos[84]&48 or twos[85]&48:
        raise ValueError('Unused low-bit packing positions differ')
    data = bytes((top[i]<<2)|(((twos[i%86]>>(2*(i//86)))&2)>>1)
                 |(((twos[i%86]>>(2*(i//86)))&1)<<1) for i in range(256))
    if differential_symbols(data) != symbols:
        raise ValueError('6-and-2 symbol round trip differs')
    return data


def classify(block, donor):
    if len(block) != 512 or len(donor) != 8192 or sha(donor) != DONOR_SHA:
        raise ValueError('Reviewed title allocation or donor differs')
    earlier = b''.join(block[a:b] for a,b in EARLIER_RANGES)
    earlier_classify(earlier,donor)
    source = donor[4096:4608]
    normalized = bytearray(v&127 for v in block)
    # Exclude, rather than classify, the independently owned disk-control record.
    normalized[:8] = bytes(v&127 for v in source[:8])
    reports = []
    for sector, edits in enumerate(EDITS):
        offset = sector*256
        original = bytes(v&127 for v in source[offset:offset+256])
        expected = bytearray(differential_symbols(original))
        for index,delta in edits:
            expected[index] ^= delta
        decoded = decode_symbols(bytes(expected))
        if decoded != normalized[offset:offset+256]:
            raise ValueError('Retained pixels differ from reviewed sparse symbol changes')
        actual = differential_symbols(normalized[offset:offset+256])
        if actual != expected:
            raise ValueError('Retained pixel symbols differ')
        reports.append(dict(sector=sector,symbols=343,changed_symbols=len(edits),
                            unchanged_symbols=343-len(edits),
                            xor_edits=[dict(index=i,xor=delta) for i,delta in edits],
                            normalized_pixel_sha256=sha(decoded)))
    coordinates = {row_offset(y)+x:(y,x) for y in range(192) for x in range(40)}
    records = []
    for start,end in RANGES:
        for offset in range(start,end):
            absolute = 4096+offset
            common = dict(block_offset=offset,donor_offset=absolute,
                          value=block[offset],donor_value=source[offset])
            if absolute in coordinates:
                y,x = coordinates[absolute]
                common.update(kind='pixels',row=y,byte_column=x,pixels=block[offset]&127,
                              phase=block[offset]>>7)
            else:
                common.update(kind='hgr-hole')
            records.append(common)
    return records,reports


def extract(output,verify=False):
    output = output.resolve()
    relative = output.relative_to(ROOT)
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disk = next(d for d in manifest['disks'] if d['id']=='disk1')
    image = (ROOT/'build/disks'/disk['filename']).read_bytes()
    if sha(image) != disk['sha256']:
        raise ValueError('Rebuild exact baseline before title-change audit')
    spec = manifest['components']['title_bitmap']
    if spec['kind'] != 'identified-data' or spec['sha256'] != DONOR_SHA:
        raise ValueError('Independently classified title donor differs')
    donor = (ROOT/spec['path']).read_bytes()
    block = block_bytes(image,83,84)
    records,sectors = classify(block,donor)
    raw = bytes(r['value'] for r in records)
    mappings,cursor = [],0
    for start,end in RANGES:
        mappings.append(dict(disk='disk1',offset=logical_sector_offset(166+start//256)+start%256,
                             size=end-start,input_offset=cursor))
        cursor += end-start
    # The new ranges extend the existing spatial correspondence, whose owner
    # and input offsets must remain intact.
    previous = json.loads((ROOT/'assets/retained-title/adopt.json').read_text())
    verify_ownership(manifest,[dict(m,input=previous['name']) for m in previous['mappings']])
    report = dict(classification='data',classification_basis='sparse-encoded-image-correspondence',
                  classification_evidence=EVIDENCE,format='apple2-hgr-altered-retained-fragments',
                  size=len(raw),sha256=sha(raw),disk='disk1',logical_block=83,
                  block_ranges=[list(r) for r in RANGES],donor_component='title_bitmap',
                  donor_sha256=DONOR_SHA,donor_offset_bias=4096,
                  pixel_bytes=sum(r['kind']=='pixels' for r in records),
                  hole_bytes=sum(r['kind']=='hgr-hole' for r in records),
                  sectors=sectors,phase_bits_preserved=True,excluded_control_range=[0,8],
                  historical_corruption_proved=False,direct_rendering_established=False)
    recipe = dict(name='retained_title_changes',data=str(relative/'fragments.bin'),
                  format=report['format'],classification=EVIDENCE,mappings=mappings)
    artifacts = {'fragments.bin':raw}
    for name,data in [('pixels.json',records),('manifest.json',report),('adopt.json',recipe)]:
        artifacts[name] = (json.dumps(data,indent=2)+'\n').encode()
    if verify:
        for name,data in artifacts.items():
            if (output/name).read_bytes() != data:
                raise ValueError(f'Title-change artifact differs: {name}')
        verify_ownership(manifest,[dict(m,input=recipe['name']) for m in mappings])
    else:
        if output.exists():
            raise ValueError('Title-change output already exists')
        output.mkdir(parents=True)
        for name,data in artifacts.items():
            (output/name).write_bytes(data)
    print(json.dumps(dict(classified_data_bytes=len(raw),pixel_bytes=report['pixel_bytes'],
                         hole_bytes=report['hole_bytes'],changed_symbols=16,verified=verify)))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--extract',type=Path)
    group.add_argument('--verify',type=Path)
    args = parser.parse_args()
    extract(args.verify or args.extract,bool(args.verify))
