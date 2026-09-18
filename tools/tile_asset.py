#!/usr/bin/env python3
"""Extract the evidenced 16-tile, four-byte-by-32-row image banks."""
import argparse
import json
from pathlib import Path

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha


def unpack_tiles(data, *, height=32, count=16):
    if height not in (24, 32) or count <= 0 or len(data) != count*height*4:
        raise ValueError('Tile bank extent disagrees with its record layout')
    return [[list(data[tile*height*4+row*4:tile*height*4+row*4+4])
             for row in range(height)] for tile in range(count)]


def pack_tiles(tiles, *, height=32, count=16):
    if height not in (24, 32) or count <= 0 or len(tiles) != count or any(len(tile) != height for tile in tiles):
        raise ValueError('Tile records disagree with the specified layout')
    if any(len(row) != 4 for tile in tiles for row in tile):
        raise ValueError('Expected four bytes per row')
    if any(type(value) is not int or not 0 <= value <= 255
           for tile in tiles for row in tile for value in row):
        raise ValueError('Tile values must be bytes')
    return bytes(value for tile in tiles for row in tile for value in row)


def preview(data, output, *, height=32, count=16):
    from PIL import Image, ImageDraw
    tiles = unpack_tiles(data, height=height, count=count)
    cell_height = height*2+18
    image = Image.new('RGB', (8*64, ((count+7)//8)*cell_height), '#17191f')
    draw = ImageDraw.Draw(image)
    for tile, rows in enumerate(tiles):
        x, y = tile % 8 * 64, tile // 8 * cell_height
        draw.text((x, y), f'{tile:02X}', fill='#a0a0a0')
        for row, values in enumerate(rows):
            for col, value in enumerate(values):
                for bit in range(7):
                    if value & (1 << bit):
                        left, top = x+2*(col*7+bit), y+15+2*row
                        draw.rectangle((left,top,left+1,top+1), fill='white')
    image.save(output)


def extract(output):
    if output.exists():
        raise ValueError('Tile output already exists')
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    images = {}
    for disk in manifest['disks']:
        image = (ROOT/'build/disks'/disk['filename']).read_bytes()
        if sha(image) != disk['sha256']:
            raise ValueError('Rebuild baseline before extracting tiles')
        images[disk['id']] = image
    prepared = []
    for bank in range(4):
        origins = [('disk2',9+4*bank)]
        if bank < 2:
            origins.append(('disk1',176+4*bank))
        data, mappings = None, []
        for disk, block in origins:
            raw = block_bytes(images[disk],block,block+4)
            if data is not None and data != raw:
                raise ValueError('Shared tile copies differ')
            data = raw
            mappings.extend(dict(disk=disk,offset=logical_sector_offset(block*2+pos//256),
                                 size=256,input_offset=pos) for pos in range(0,2048,256))
        tiles = unpack_tiles(data)
        if pack_tiles(tiles) != data:
            raise ValueError('Tile layout round trip failed')
        prepared.append((bank,data,tiles,origins,mappings))
    output.mkdir(parents=True)
    reports = []
    for bank, data, tiles, origins, mappings in prepared:
        folder = output/f'bank{bank}'
        folder.mkdir()
        (folder/'tiles.bin').write_bytes(data)
        (folder/'rows.json').write_text(json.dumps(tiles, indent=2)+'\n')
        preview(data,folder/'atlas.png')
        report = dict(bank=bank,format='sundog-32-row-tiles',size=len(data),sha256=sha(data),
            origins=[dict(disk=disk,logical_blocks=[block,block+4]) for disk,block in origins],
            tile_count=16,tile_size=[28,32],bytes_per_row=4,bytes_per_tile=128,
            layout='Tile-major, top-to-bottom rows, four bytes left-to-right; low bits 0-6 are pixels',
            phase_bits='High bits copied by renderer and preserved in raw data and row listing',
            consumer='Library 23 procedure 3, 32-row path',classification_evidence='docs/tile-banks.md',
            preview='atlas.png',preview_note='Monochrome masks; no artifact color or map composition',
            inverse='pack_tiles(rows.json) exactly reproduces tiles.bin')
        (folder/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
        recipe=dict(name=f'tile_bank{bank}',data=str((folder/'tiles.bin').relative_to(ROOT)),
            format=report['format'],classification=report['classification_evidence'],mappings=mappings)
        (folder/'adopt.json').write_text(json.dumps(recipe,indent=2)+'\n')
        reports.append(report)
    return reports


def extract_world(output):
    if output.exists():
        raise ValueError('World tile output already exists')
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    data, origins, mappings = None, [], []
    for disk_id, block in [('disk2',25), ('disk1',184)]:
        disk = next(d for d in manifest['disks'] if d['id'] == disk_id)
        image = (ROOT/'build/disks'/disk['filename']).read_bytes()
        if sha(image) != disk['sha256']:
            raise ValueError('Rebuild baseline before extracting world tiles')
        raw = block_bytes(image,block,block+4)[:2016]
        if data is not None and data != raw:
            raise ValueError('Shared world tile copies differ')
        data = raw
        origins.append(dict(disk=disk_id,block=block,size=2016,excluded_read_tail_bytes=32))
        mappings.extend(dict(disk=disk_id,offset=logical_sector_offset(block*2+pos//256),
                             size=min(256,2016-pos),input_offset=pos) for pos in range(0,2016,256))
    tiles = unpack_tiles(data,height=24,count=21)
    if pack_tiles(tiles,height=24,count=21) != data:
        raise ValueError('World tile row round trip failed')
    output.mkdir(parents=True)
    (output/'tiles.bin').write_bytes(data)
    (output/'rows.json').write_text(json.dumps(tiles,indent=2)+'\n')
    preview(data,output/'atlas.png',height=24,count=21)
    report = dict(format='sundog-24-row-tiles',size=2016,sha256=sha(data),origins=origins,
        tile_count=21,tile_size=[28,24],bytes_per_row=4,bytes_per_tile=96,
        consumer='Library 23 procedure 3, 24-row path; game 21 $1185-$1199 supplies variants 14-20',
        classification_evidence='docs/world-tiles.md',preview='atlas.png',
        preview_note='Monochrome masks; phase bits preserved in raw data and row listing',
        inverse='pack_tiles(rows.json,height=24,count=21) equals tiles.bin')
    (output/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
    recipe=dict(name='world_tiles',data=str((output/'tiles.bin').relative_to(ROOT)),
        format=report['format'],classification=report['classification_evidence'],mappings=mappings)
    (output/'adopt.json').write_text(json.dumps(recipe,indent=2)+'\n')
    return report


if __name__ == '__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    group=parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--extract',type=Path)
    group.add_argument('--extract-world',type=Path)
    args=parser.parse_args()
    if args.extract:
        print(json.dumps(extract(args.extract.resolve()),indent=2))
    else:
        print(json.dumps(extract_world(args.extract_world.resolve()),indent=2))
