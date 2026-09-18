#!/usr/bin/env python3
"""Extract the evidenced 16-tile, four-byte-by-32-row image banks."""
import argparse
import json
from pathlib import Path

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha


def unpack_tiles(data):
    if len(data) != 2048:
        raise ValueError('Expected a 2048-byte tile bank')
    return [[list(data[tile*128+row*4:tile*128+row*4+4])
             for row in range(32)] for tile in range(16)]


def pack_tiles(tiles):
    if len(tiles) != 16 or any(len(tile) != 32 for tile in tiles):
        raise ValueError('Expected sixteen 32-row tiles')
    if any(len(row) != 4 for tile in tiles for row in tile):
        raise ValueError('Expected four bytes per row')
    if any(type(value) is not int or not 0 <= value <= 255
           for tile in tiles for row in tile for value in row):
        raise ValueError('Tile values must be bytes')
    return bytes(value for tile in tiles for row in tile for value in row)


def preview(data, output):
    from PIL import Image, ImageDraw
    tiles = unpack_tiles(data)
    image = Image.new('RGB', (8*64, 2*82), '#17191f')
    draw = ImageDraw.Draw(image)
    for tile, rows in enumerate(tiles):
        x, y = tile % 8 * 64, tile // 8 * 82
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


if __name__ == '__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--extract',type=Path,required=True)
    args=parser.parse_args()
    print(json.dumps(extract(args.extract.resolve()),indent=2))
