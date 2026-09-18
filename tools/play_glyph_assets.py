#!/usr/bin/env python3
"""Extract the two evidenced play-side glyph banks with lossless row listings."""
import argparse
import json
from pathlib import Path

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from glyph_asset import display_rows, pack_rows, preview


def extract(output):
    if output.exists():
        raise ValueError('Play glyph output already exists')
    manifest = json.loads((ROOT / 'reconstruction/manifest.json').read_text())
    disk = next(d for d in manifest['disks'] if d['id'] == 'disk2')
    image = (ROOT / 'build/disks' / disk['filename']).read_bytes()
    if sha(image) != disk['sha256']:
        raise ValueError('Rebuild current baseline before extracting glyphs')
    reviewed = []
    for bank in (1, 2):
        start = 3 + 2 * bank
        raw = block_bytes(image, start, start + 2)
        rows = display_rows(raw)
        if pack_rows(rows) != raw:
            raise ValueError('Glyph row-order round trip failed')
        omitted = [raw[offset+120:offset+128].hex() for offset in range(0, 1024, 128)]
        if bank == 2 and omitted != [('00' if group % 2 == 0 else '80') * 8 for group in range(8)]:
            raise ValueError('Bank-2 copy gaps differ from reviewed blank glyph patterns')
        reviewed.append((bank, start, raw, rows, omitted))
    output.mkdir(parents=True)
    reports = []
    for bank, start, raw, rows, omitted in reviewed:
        folder = output / f'bank{bank}'
        folder.mkdir()
        (folder/'glyphs.bin').write_bytes(raw)
        (folder/'rows.json').write_text(json.dumps(rows, indent=2)+'\n')
        preview(raw, folder/'glyphs.png')
        report = dict(bank=bank, format='sundog-glyph-bank', size=1024,
            sha256=sha(raw), disk='disk2', logical_blocks=[start, start+2],
            glyph_count=128, glyph_size=[7,8], stored_bytes_per_glyph=8,
            row_order='Stored bottom to top; bit 0 is the leftmost pixel',
            high_bit='Preserved in raw data and row listing; renderer masks it out',
            classification_evidence='docs/play-glyphs.md',
            consumer='Library 22 procedures 20/21 (bank pointers) and 9 (glyph renderer)',
            preview='glyphs.png', rows='rows.json',
            preview_note='Stored masks; no artifact color, placement, or runtime mutation simulated')
        if bank == 2:
            report['runtime_copy'] = dict(source=4096, destination=1024,
                groups=8, stride=128, bytes_per_group=120,
                omitted_glyph_indices=[15+16*i for i in range(8)],
                omitted_stored_hex=omitted,
                evidence='Startup 7 $0355-$0388; game 12 $04E1 selects the $0400 bank')
        (folder/'manifest.json').write_text(json.dumps(report, indent=2)+'\n')
        recipe = dict(name=f'play_glyph_bank{bank}', data=str((folder/'glyphs.bin').relative_to(ROOT)),
            format='sundog-glyph-bank', classification='docs/play-glyphs.md',
            mappings=[dict(disk='disk2', offset=logical_sector_offset(start*2+position//256),
                           size=256, input_offset=position) for position in range(0,1024,256)])
        (folder/'adopt.json').write_text(json.dumps(recipe, indent=2)+'\n')
        reports.append(report)
    return reports


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--extract', required=True, type=Path)
    args = parser.parse_args()
    print(json.dumps(extract(args.extract.resolve()), indent=2))
