#!/usr/bin/env python3
"""Losslessly split Apple II HGR pages and render monochrome layout previews."""
import argparse
from collections import Counter
import json
from pathlib import Path

from disk_layout import ROOT, block_bytes, sha, logical_sector_offset


def row_offset(y):
    if not 0 <= y < 192:
        raise ValueError('HGR row out of range')
    return (y & 7) * 1024 + ((y >> 3) & 7) * 128 + (y >> 6) * 40


VISIBLE = {row_offset(y) + x for y in range(192) for x in range(40)}
HOLES = [offset for offset in range(8192) if offset not in VISIBLE]


def split_page(data):
    if len(data) != 8192:
        raise ValueError('HGR page must contain exactly 8192 bytes')
    rows = [data[row_offset(y):row_offset(y)+40] for y in range(192)]
    return rows, bytes(data[i] for i in HOLES)


def pack_page(rows, holes):
    if len(rows) != 192 or any(len(row) != 40 for row in rows) or len(holes) != 512:
        raise ValueError('HGR rows or holes have wrong lengths')
    data = bytearray(8192)
    for y, row in enumerate(rows):
        data[row_offset(y):row_offset(y)+40] = row
    for offset, byte in zip(HOLES, holes):
        data[offset] = byte
    return bytes(data)


def preview(data, output):
    from PIL import Image
    rows, _ = split_page(data)
    pixels = bytes(255 if byte & (1 << bit) else 0 for row in rows for byte in row for bit in range(7))
    image = Image.frombytes('L', (280, 192), pixels)
    image.resize((560, 384), Image.Resampling.NEAREST).save(output)


def extract_title(output):
    if output.exists():
        raise ValueError('Asset output already exists; refusing to overwrite')
    source = ROOT / 'build/disks/sundog-disk1-game.dsk'
    data = block_bytes(source.read_bytes(), 203, 219)
    rows, holes = split_page(data)
    if pack_page(rows, holes) != data:
        raise ValueError('HGR row/hole round trip failed')
    output.mkdir(parents=True)
    (output / 'title.hgr').write_bytes(data)
    preview(data, output / 'title-monochrome.png')
    manifest = dict(format='apple2-hgr-page', size=8192, sha256=sha(data),
        disk='disk1', logical_blocks=[203, 219], runtime_address=0x4400,
        displayed_size=[280, 192], visible_bytes=7680, hole_bytes=512,
        hole_value_counts=dict(Counter(holes)),
        non_ff_holes=[dict(offset=i, value=data[i]) for i in HOLES if data[i] != 255],
        consumer='src/native/title_draw.s', classification_evidence='docs/title-bitmap.md',
        preview='title-monochrome.png', preview_note='Layout only; artifact colors and half-pixel phase are not simulated. High bits and holes remain intact in title.hgr.',
        round_trip='pack_page(*split_page(data)) equals original data')
    (output / 'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    recipe = dict(name='title_bitmap', data=str((output / 'title.hgr').relative_to(ROOT)),
                  format='apple2-hgr-page', classification='docs/title-bitmap.md',
                  mappings=[dict(disk='disk1', offset=logical_sector_offset(406+i//256), size=256, input_offset=i)
                            for i in range(0,8192,256)])
    (output / 'adopt.json').write_text(json.dumps(recipe,indent=2)+'\n')
    return manifest


def extract_certificate(output):
    if output.exists():
        raise ValueError('Asset output already exists; refusing to overwrite')
    build_manifest = json.loads((ROOT / 'reconstruction/manifest.json').read_text())
    disk = next(d for d in build_manifest['disks'] if d['id'] == 'disk1')
    image = (ROOT / 'build/disks' / disk['filename']).read_bytes()
    if sha(image) != disk['sha256']:
        raise ValueError('Rebuild current baseline before extracting certificate')
    data = block_bytes(image, 5, 21)
    rows, holes = split_page(data)
    if pack_page(rows, holes) != data or holes != bytes([0x80])*512:
        raise ValueError('Certificate row/padding evidence differs')
    output.mkdir(parents=True)
    (output / 'certificate.hgr').write_bytes(data)
    preview(data, output / 'certificate-monochrome.png')
    manifest = dict(format='apple2-hgr-page', size=8192, sha256=sha(data),
        disk='disk1', logical_blocks=[5,21], runtime_addresses=[0x4000,0x2000],
        displayed_size=[280,192], visible_bytes=7680, hole_bytes=512,
        hole_value_counts=dict(Counter(holes)),
        consumer='src/native/certificate_reveal.s; src/pcode/library_26_body.inc procedure 7',
        classification_evidence='docs/certificate-bitmap.md',
        preview='certificate-monochrome.png',
        preview_note='Layout only; later variable text, artifact colors, and phase shifts are not simulated.',
        round_trip='pack_page(*split_page(data)) equals original data')
    (output / 'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    recipe = dict(name='registration_certificate', data=str((output / 'certificate.hgr').relative_to(ROOT)),
        format='apple2-hgr-page', classification='docs/certificate-bitmap.md',
        mappings=[dict(disk='disk1', offset=logical_sector_offset(10+i//256), size=256, input_offset=i)
                  for i in range(0,8192,256)])
    (output / 'adopt.json').write_text(json.dumps(recipe, indent=2)+'\n')
    return manifest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--extract-title', type=Path)
    parser.add_argument('--extract-certificate', type=Path)
    parser.add_argument('--preview', type=Path)
    parser.add_argument('--input', type=Path)
    args = parser.parse_args()
    if args.extract_title:
        print(json.dumps(extract_title(args.extract_title.resolve()), indent=2))
    elif args.extract_certificate:
        print(json.dumps(extract_certificate(args.extract_certificate.resolve()), indent=2))
    elif args.preview and args.input:
        preview(args.input.read_bytes(), args.preview)
    else:
        parser.error('Choose --extract-title OUTPUT, --extract-certificate OUTPUT, or --input HGR --preview PNG')


if __name__ == '__main__':
    main()
