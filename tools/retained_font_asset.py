#!/usr/bin/env python3
"""Extract the retained 64-glyph variant using the verified shared-font masks."""
import argparse
import json
from pathlib import Path

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from glyph_asset import display_rows, pack_rows, preview
from pcode_copies import verify_ownership

EVIDENCE = 'docs/retained-font-half.md'
FONT_SHA = 'eeadc8615ae25ac5611744c0f32589698d4d3cc4c57808a98df85268d08ca775'
RAW_SHA = 'e26c063faef229917fc2e2374f3ef29661786b501cb75edb283bfe14254c0426'
RENDERER_SHA = '7d52f0e6959d0a8b9ac3f08bc78ced7e7af44ed87a00d80d4d82025ab7735f49'
DONOR_INDICES = [32 if 3<=i<=7 else i for i in range(64)]


def classify(raw,font):
    if len(font)!=1024 or sha(font)!=FONT_SHA:
        raise ValueError('Reviewed shared-font donor differs')
    if len(raw)!=512:
        raise ValueError('Retained half bank must contain 64 eight-byte glyphs')
    expected=bytes(value&127 for i in DONOR_INDICES for value in font[i*8:i*8+8])
    if raw!=expected or sha(raw)!=RAW_SHA:
        raise ValueError('Retained glyph masks differ from reviewed donor mapping')
    rows=display_rows(raw,count=64)
    if pack_rows(rows,count=64)!=raw:
        raise ValueError('Retained glyph row order is not reversible')
    return rows


def extract(output,verify=False):
    output=output.resolve()
    relative=output.relative_to(ROOT)
    manifest=json.loads((ROOT/'reconstruction/manifest.json').read_text())
    donor=manifest['components']['shared_font']
    font=(ROOT/donor['path']).read_bytes()
    if donor['kind']!='identified-data' or donor['sha256']!=FONT_SHA:
        raise ValueError('Shared-font ownership differs')
    renderer=(ROOT/'build/disks/components/library_22.bin').read_bytes()
    if sha(renderer)!=RENDERER_SHA or manifest['components']['library_22']['sha256']!=RENDERER_SHA:
        raise ValueError('Reviewed glyph renderer differs')
    disk=next(d for d in manifest['disks'] if d['id']=='disk2')
    image=(ROOT/'build/disks'/disk['filename']).read_bytes()
    if sha(image)!=disk['sha256']:
        raise ValueError('Rebuild exact baseline before retained-font extraction')
    raw=block_bytes(image,80,81)
    rows=classify(raw,font)
    mappings=[dict(disk='disk2',offset=logical_sector_offset(160+i),size=256,input_offset=256*i) for i in range(2)]
    report=dict(classification='data',format='sundog-retained-glyph-half-bank',size=512,
                sha256=sha(raw),disk='disk2',logical_blocks=[80,81],glyph_count=64,
                stored_bytes_per_glyph=8,glyph_size=[7,8],classification_evidence=EVIDENCE,
                donor_component='shared_font',donor_sha256=FONT_SHA,donor_indices=DONOR_INDICES,
                transform='Select the recorded glyph indices and mask every row with $7F',
                changed_slots=[3,4,5,6,7],replacement_donor_index=32,
                row_order='Stored bottom to top; bit zero is the leftmost pixel',
                renderer_component='library_22',renderer_sha256=RENDERER_SHA,
                renderer_evidence='Procedure 9 scales glyph indices by eight and masks each row with $7F',
                direct_reader_established=False,preview='glyphs.png',rows='rows.json',
                preview_note='All 64 stored masks; no additional glyphs or runtime placement implied')
    recipe=dict(name='retained_font_half',data=str(relative/'glyphs.bin'),format=report['format'],
                classification=EVIDENCE,mappings=mappings)
    artifacts={'glyphs.bin':raw}
    for name,value in [('rows.json',rows),('manifest.json',report),('adopt.json',recipe)]:
        artifacts[name]=(json.dumps(value,indent=2)+'\n').encode()
    if verify:
        for name,data in artifacts.items():
            if not (output/name).is_file() or (output/name).read_bytes()!=data:
                raise ValueError(f'Retained glyph artifact differs: {name}')
        verify_ownership(manifest,[dict(m,input='retained_font_half') for m in mappings])
    else:
        if output.exists():
            raise ValueError('Retained glyph output already exists')
        output.mkdir(parents=True)
        for name,data in artifacts.items():
            (output/name).write_bytes(data)
        preview(raw,output/'glyphs.png',count=64)
    print(json.dumps(dict(classified_bytes=512,glyphs=64,verified=verify)))


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    group=parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--extract',type=Path)
    group.add_argument('--verify',type=Path)
    args=parser.parse_args()
    extract(args.verify or args.extract,bool(args.verify))
