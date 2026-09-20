#!/usr/bin/env python3
"""Extract the six groups of padded 28x24 startup-animation frames."""
import argparse
import json
from pathlib import Path

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from tile_asset import unpack_tiles, pack_tiles, preview


def unpack_frames(data):
    if len(data) != 6144:
        raise ValueError('Expected six groups of eight 128-byte frame records')
    if any(any(data[i+96:i+128]) for i in range(0,6144,128)):
        raise ValueError('Unreviewed nonzero frame padding')
    pixels = b''.join(data[i:i+96] for i in range(0,6144,128))
    return unpack_tiles(pixels,height=24,count=48)


def pack_frames(frames):
    pixels = pack_tiles(frames,height=24,count=48)
    return b''.join(pixels[i:i+96]+bytes(32) for i in range(0,len(pixels),96))


def extract(output):
    output = output.resolve()
    relative = output.relative_to(ROOT)
    if output.exists():
        raise ValueError('Logo-frame output already exists')
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disk = next(d for d in manifest['disks'] if d['id'] == 'disk1')
    image = (ROOT/'build/disks'/disk['filename']).read_bytes()
    if sha(image) != disk['sha256']:
        raise ValueError('Rebuild current baseline before extracting frames')
    raw = block_bytes(image,67,79)
    frames = unpack_frames(raw)
    if pack_frames(frames) != raw:
        raise ValueError('Frame record round trip differs')
    mappings = []
    for pos in range(0,6144,256):
        offset = logical_sector_offset(67*2+pos//256)
        owners = [r for r in disk['regions'] if r['offset'] <= offset and offset+256 <= r['offset']+r['size']]
        if len(owners) != 1 or manifest['components'][owners[0]['input']]['kind'] != 'temporary-unresolved':
            raise ValueError('Frame record overlaps reconstructed bytes')
        mappings.append(dict(disk='disk1',offset=offset,size=256,input_offset=pos))
    report = dict(classification='data',classification_evidence='docs/logo-frames.md',
                  size=len(raw),sha256=sha(raw),disk='disk1',blocks=[67,79],
                  groups=6,frames_per_group=8,record_stride=128,image_bytes=96,
                  width=28,height=24,row_bytes=4,zero_padding_bytes_per_frame=32,
                  bitmap_bytes=4608,padding_bytes=1536,
                  frames=[dict(group=i//8,frame=i%8,input_offset=i*128,
                               sha256=sha(raw[i*128:(i+1)*128])) for i in range(48)],
                  preview_note='Monochrome source bits 0–6; renderer forces bit 7 high')
    recipe = dict(name='logo_frames',data=str(relative/'frames.bin'),
                  format='6 x 8 row-major 28x24 bitmaps; 96 bitmap bytes and 32 zero padding bytes per record',
                  classification='docs/logo-frames.md',mappings=mappings)
    output.mkdir(parents=True)
    (output/'frames.bin').write_bytes(raw)
    for name,value in [('rows.json',frames),('manifest.json',report),('adopt.json',recipe)]:
        (output/name).write_text(json.dumps(value,indent=2)+'\n')
    preview(pack_tiles(frames,height=24,count=48),output/'atlas.png',height=24,count=48)
    print('Extracted 48 bitmap frames with explicit zero padding: 6,144 bytes')


def verify(output):
    raw = (output/'frames.bin').read_bytes()
    frames = json.loads((output/'rows.json').read_text())
    report = json.loads((output/'manifest.json').read_text())
    if sha(raw) != report['sha256'] or unpack_frames(raw) != frames or pack_frames(frames) != raw:
        raise ValueError('Logo frame bytes/fields differ')
    print('Verified all 48 frames and their zero padding')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--extract',type=Path)
    group.add_argument('--verify',type=Path)
    args = parser.parse_args()
    extract(args.extract) if args.extract else verify(args.verify)
