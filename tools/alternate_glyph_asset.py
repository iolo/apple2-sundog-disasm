#!/usr/bin/env python3
"""Extract the alternate program's directly loaded 128-glyph graphics bank."""
import argparse
import json
from pathlib import Path

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from glyph_asset import display_rows, pack_rows, preview

EVIDENCE = 'docs/alternate-glyphs.md'
CONSUMERS = {
    'alternate_7': '0a7751ec039e806dba479877bac1818f18ef7b623d2ef1047d8cd3249cd1f45c',
    'library_22': '7d52f0e6959d0a8b9ac3f08bc78ced7e7af44ed87a00d80d4d82025ab7735f49',
}


def extract(output, verify=False):
    output = output.resolve()
    relative = output.relative_to(ROOT)
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disk = next(d for d in manifest['disks'] if d['id'] == 'disk1')
    image = (ROOT/'build/disks'/disk['filename']).read_bytes()
    if sha(image) != disk['sha256']:
        raise ValueError('Rebuild exact baseline before extracting alternate glyphs')
    for name, digest in CONSUMERS.items():
        spec = manifest['components'][name]
        binary = (ROOT/'build/disks/components'/f'{name}.bin').read_bytes()
        if (spec['kind'] != 'ca65-source' or spec['sha256'] != digest
                or len(binary) != spec['size'] or sha(binary) != digest):
            raise ValueError(f'Reviewed loader/renderer differs: {name}')
    raw = block_bytes(image, 174, 176)
    rows = display_rows(raw)
    if pack_rows(rows) != raw:
        raise ValueError('Glyph row listing does not reconstruct the source bank')
    report = dict(format='sundog-glyph-bank', classification='data', size=len(raw),
        sha256=sha(raw), disk='disk1', logical_blocks=[174,176],
        glyph_count=128, glyph_size=[7,8], stored_bytes_per_glyph=8,
        row_order='Stored bottom to top; bit 0 is the leftmost pixel',
        high_bit='Preserved in raw data and row listing; renderer masks it out',
        classification_evidence=EVIDENCE, consumer_component_hashes=CONSUMERS,
        loader=dict(component='alternate_7', relative_block_assignment=0x00c5,
                    relative_block=171, pointer_install_call=0x014b,
                    direct_read_call=0x0156, blocks_read=2, buffer_address=0x0800),
        renderer='Library 22 procedure 9, bank pointer at data-segment 29 word 355',
        preview='glyphs.png', rows='rows.json',
        preview_note='Stored glyph masks, without runtime placement, mutation or artifact colors')
    recipe = dict(name='alternate_glyph_bank', data=str(relative/'glyphs.bin'),
        format=report['format'], classification=EVIDENCE,
        mappings=[dict(disk='disk1',offset=logical_sector_offset(348+position//256),
                       size=256,input_offset=position) for position in range(0,1024,256)])
    artifacts = {'glyphs.bin':raw}
    for name, value in [('rows.json',rows),('manifest.json',report),('adopt.json',recipe)]:
        artifacts[name] = (json.dumps(value,indent=2)+'\n').encode()
    if verify:
        for name, data in artifacts.items():
            if not (output/name).is_file() or (output/name).read_bytes() != data:
                raise ValueError(f'Alternate glyph artifact differs: {name}')
    else:
        if output.exists():
            raise ValueError('Alternate glyph output already exists')
        output.mkdir(parents=True)
        for name, data in artifacts.items():
            (output/name).write_bytes(data)
        preview(raw,output/'glyphs.png')
    print(json.dumps(dict(classified_bytes=len(raw),glyphs=len(rows),verified=verify)))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--extract',type=Path)
    group.add_argument('--verify',type=Path)
    args = parser.parse_args()
    extract(args.verify or args.extract,bool(args.verify))
