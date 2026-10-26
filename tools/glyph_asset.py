#!/usr/bin/env python3
"""Extract the shared 128-glyph bank and preserve its eight-byte glyph records."""
import argparse
import json
from pathlib import Path

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha


def display_rows(data, *, count=128):
    if count not in (64,128) or len(data) != count*8:
        raise ValueError(f'Glyph bank must contain exactly {count} eight-byte records')
    return [list(reversed(data[index*8:index*8+8])) for index in range(count)]


def pack_rows(glyphs, *, count=128):
    if count not in (64,128) or len(glyphs) != count or any(len(rows) != 8 for rows in glyphs):
        raise ValueError(f'Expected {count} glyphs of eight rows each')
    if any(not isinstance(value, int) or not 0 <= value <= 255 for rows in glyphs for value in rows):
        raise ValueError('Glyph row must be a byte')
    return bytes(value for rows in glyphs for value in reversed(rows))


def preview(data, output, *, count=128):
    from PIL import Image, ImageDraw
    glyphs = display_rows(data,count=count)
    cell_width, cell_height, scale = 30, 44, 3
    image = Image.new('RGB', (16*cell_width, (count//16)*cell_height), '#16191d')
    draw = ImageDraw.Draw(image)
    for index, rows in enumerate(glyphs):
        x, y = (index % 16)*cell_width, (index//16)*cell_height
        draw.text((x+2, y+1), f'{index:02X}', fill='#8f9ba8')
        for row, byte in enumerate(rows):
            for bit in range(7):
                if byte & (1 << bit):
                    left, top = x+3+bit*scale, y+16+row*scale
                    draw.rectangle((left, top, left+scale-1, top+scale-1), fill='#f4f0dc')
    image.save(output)


def extract(output):
    if output.exists():
        raise ValueError('Glyph output already exists')
    manifest = json.loads((ROOT / 'reconstruction/manifest.json').read_text())
    copies, data, mappings = [], None, []
    for disk in manifest['disks']:
        image = (ROOT / 'build/disks' / disk['filename']).read_bytes()
        if sha(image) != disk['sha256']:
            raise ValueError('Rebuild current baseline before extracting glyphs')
        raw = block_bytes(image, 3, 5)
        if data is not None and data != raw:
            raise ValueError('Shared glyph copies differ')
        data = raw
        copies.append(dict(disk=disk['id'], logical_blocks=[3, 5]))
        for position in range(0, 1024, 256):
            mappings.append(dict(disk=disk['id'], offset=logical_sector_offset(6+position//256),
                                 size=256, input_offset=position))
    rows = display_rows(data)
    if pack_rows(rows) != data:
        raise ValueError('Glyph row-order round trip failed')
    output.mkdir(parents=True)
    (output/'font.bin').write_bytes(data)
    (output/'rows.json').write_text(json.dumps(rows, indent=2)+'\n')
    preview(data, output/'font.png')
    description = dict(format='sundog-glyph-bank', size=1024, sha256=sha(data),
        glyph_count=128, glyph_size=[7,8], stored_bytes_per_glyph=8,
        row_order='Stored bottom to top; bit 0 is the leftmost pixel',
        high_bit='Ignored by the glyph consumer; preserved in font.bin and rows.json',
        origins=copies, consumer='src/pcode/graphics_and_io.s, procedures 20 and 9',
        classification_evidence='docs/shared-font.md', preview='font.png',
        preview_note='Raw glyph masks; does not simulate positioning, draw modes, or artifact color',
        rows='rows.json uses top-to-bottom display order with all eight bits preserved')
    (output/'manifest.json').write_text(json.dumps(description, indent=2)+'\n')
    recipe = dict(name='shared_font', data=str((output/'font.bin').relative_to(ROOT)),
                  format='sundog-glyph-bank', classification='docs/shared-font.md', mappings=mappings)
    (output/'adopt.json').write_text(json.dumps(recipe, indent=2)+'\n')
    return description


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--extract', type=Path)
    parser.add_argument('--input', type=Path)
    parser.add_argument('--preview', type=Path)
    args = parser.parse_args()
    if args.extract:
        print(json.dumps(extract(args.extract.resolve()), indent=2))
    elif args.input and args.preview:
        preview(args.input.read_bytes(), args.preview)
    else:
        parser.error('Choose --extract OUTPUT or --input BIN --preview PNG')
