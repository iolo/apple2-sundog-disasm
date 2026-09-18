#!/usr/bin/env python3
"""Decode/repack the stride-one RLE HGR streams consumed by library 24 procedure 5."""
import argparse
import json
from pathlib import Path

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from hgr_asset import preview


def decode(raw):
    if not raw or raw[0] != 1:
        raise ValueError('Only the evidenced stride-one HGR encoding is supported')
    page, packets, position = bytearray(), [], 1
    while len(page) < 8192:
        if position >= len(raw):
            raise ValueError('Truncated RLE control')
        control = raw[position]
        position += 1
        count = min((control & 127) + 1, 8192 - len(page))
        size = count if control & 128 else 1
        payload = raw[position:position+size]
        if len(payload) != size:
            raise ValueError('Truncated RLE payload')
        position += size
        page.extend(payload if control & 128 else payload * count)
        packets.append(dict(control=control, payload=payload.hex()))
    return bytes(page), dict(stride=1, packets=packets), position


def encode(description):
    if description.get('stride') != 1:
        raise ValueError('Only stride one is supported')
    result = bytearray([1])
    for packet in description['packets']:
        control = packet['control']
        if type(control) is not int or not 0 <= control <= 255:
            raise ValueError('RLE control must be a byte')
        result.append(control)
        result.extend(bytes.fromhex(packet['payload']))
    raw = bytes(result)
    _, actual, consumed = decode(raw)
    if consumed != len(raw) or actual != description:
        raise ValueError('RLE packet boundaries or terminal extent disagree')
    return raw


def extract(output):
    if output.exists():
        raise ValueError('Packed HGR output already exists')
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    images = {}
    for disk in manifest['disks']:
        image = (ROOT/'build/disks'/disk['filename']).read_bytes()
        if sha(image) != disk['sha256']:
            raise ValueError('Rebuild current baseline before extracting packed images')
        images[disk['id']] = image
    assets = [('full_ship', [('disk2',29), ('disk1',188)]),
              ('ship_section', [('disk2',33)])]
    prepared = []
    for name, origins in assets:
        data, mappings, locations = None, [], []
        for disk, block in origins:
            loaded = block_bytes(images[disk], block, block+4)
            page, description, size = decode(loaded)
            raw = loaded[:size]
            if encode(description) != raw or (data is not None and data != raw):
                raise ValueError('RLE round trip or shared-copy comparison failed')
            data = raw
            locations.append(dict(disk=disk, block=block, consumed_bytes=size,
                                  excluded_read_tail_bytes=len(loaded)-size))
            for position in range(0, size, 256):
                mappings.append(dict(disk=disk, offset=logical_sector_offset(block*2+position//256),
                                     size=min(256,size-position), input_offset=position))
        prepared.append((name, data, page, description, locations, mappings))
    output.mkdir(parents=True)
    reports = []
    for name, raw, page, description, locations, mappings in prepared:
        folder = output/name
        folder.mkdir()
        (folder/'image.rle').write_bytes(raw)
        (folder/'packets.json').write_text(json.dumps(description, indent=2)+'\n')
        (folder/'decoded.hgr').write_bytes(page)
        preview(page, folder/'monochrome.png')
        report = dict(format='sundog-stride1-rle-hgr', size=len(raw), sha256=sha(raw),
            origins=locations, decoded_size=8192, decoded_sha256=sha(page),
            packet_count=len(description['packets']), consumer='Library 24 procedure 5 at $1010',
            classification_evidence='docs/packed-ship-images.md',
            preview='monochrome.png', preview_note='Stored artwork without later overlays or artifact color',
            inverse='encode(packets.json) reproduces image.rle exactly')
        (folder/'manifest.json').write_text(json.dumps(report, indent=2)+'\n')
        recipe = dict(name='packed_'+name, data=str((folder/'image.rle').relative_to(ROOT)),
            format=report['format'], classification=report['classification_evidence'], mappings=mappings)
        (folder/'adopt.json').write_text(json.dumps(recipe, indent=2)+'\n')
        reports.append(report)
    return reports


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--extract', type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(extract(args.extract.resolve()), indent=2))
