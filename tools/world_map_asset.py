#!/usr/bin/env python3
"""Extract world-map two-bit payloads and decode the native 14-state format."""
import argparse
import json
from pathlib import Path

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha

STATE_TABLE = bytes.fromhex(
    '0102090d00070a0a03040b0b0102090d0506080c03040b0b00070a0a'
    '0506080c0102090d0506080c00070a0a03040b0b0506080c0102090d')


def unpack_symbols(raw):
    if len(raw) != 240:
        raise ValueError('World-map payload must contain 240 bytes')
    symbols = [(byte >> shift) & 3 for byte in raw for shift in (0,2,4,6)]
    return [symbols[start:start+40] for start in range(0,960,40)]


def pack_symbols(rows):
    if len(rows) != 24 or any(len(row) != 40 for row in rows):
        raise ValueError('World map must contain 24 rows of 40 symbols')
    symbols = [symbol for row in rows for symbol in row]
    if any(type(symbol) is not int or not 0 <= symbol <= 3 for symbol in symbols):
        raise ValueError('World-map symbols must be two-bit values')
    return bytes(sum(symbols[start+i] << (2*i) for i in range(4))
                 for start in range(0,960,4))


def decode_tiles(rows):
    pack_symbols(rows)  # Validate shape and symbol bounds.
    result = []
    for row in rows:
        state, decoded = 12, []
        for symbol in row:
            state = STATE_TABLE[state*4+symbol]
            decoded.append(state)
        result.append(decoded)
    return result


def preview(maps, output):
    from PIL import Image, ImageDraw
    colors = ['#142538','#227093','#34ace0','#706fd3','#474787','#33d9b2','#218c74',
              '#ffb142','#cc8e35','#ff5252','#b33939','#f7f1e3','#84817a','#9bcb67']
    width, height, scale = 40,24,4
    cell_w,cell_h = width*scale+12,height*scale+24
    image = Image.new('RGB',(3*cell_w,6*cell_h),'#121820')
    draw=ImageDraw.Draw(image)
    for index,rows in enumerate(maps):
        ox,oy=index%3*cell_w,index//3*cell_h
        draw.text((ox+3,oy+2),f'Map {index:02d}',fill='white')
        for y,row in enumerate(rows):
            for x,tile in enumerate(row):
                left,top=ox+x*scale,oy+18+y*scale
                draw.rectangle((left,top,left+scale-1,top+scale-1),fill=colors[tile])
    image.save(output)


def extract(output):
    if output.exists():
        raise ValueError('World-map output already exists')
    manifest=json.loads((ROOT/'reconstruction/manifest.json').read_text())
    images={}
    for disk in manifest['disks']:
        image=(ROOT/'build/disks'/disk['filename']).read_bytes()
        if sha(image)!=disk['sha256']:
            raise ValueError('Rebuild baseline before extracting maps')
        images[disk['id']]=image
    library=(ROOT/'build/disks/components/library_23.bin').read_bytes()
    if library[0x6f:0xa7]!=STATE_TABLE:
        raise ValueError('State table differs from the reconstructed native consumer')
    bank=block_bytes(images['disk2'],55,64)
    duplicate=block_bytes(images['disk1'],194,195)
    data,records,symbols,maps,mappings=bytearray(),[],[],[],[]
    for index in range(18):
        raw=bank[index*256+16:(index+1)*256]
        rows=unpack_symbols(raw)
        if pack_symbols(rows)!=raw:
            raise ValueError('World-map symbol packing failed')
        data.extend(raw)
        symbols.append(rows)
        maps.append(decode_tiles(rows))
        origins=[dict(disk='disk2',block=55+index//2,byte_offset=(index%2)*256+16)]
        if index<2:
            if duplicate[index*256+16:(index+1)*256]!=raw:
                raise ValueError('Disk-1 map payload differs')
            origins.append(dict(disk='disk1',block=194,byte_offset=index*256+16))
        for origin in origins:
            logical=origin['block']*512+origin['byte_offset']
            mappings.append(dict(disk=origin['disk'],offset=logical_sector_offset(logical//256)+16,
                                 size=240,input_offset=index*240))
        records.append(dict(index=index,offset=index*240,size=240,sha256=sha(raw),origins=origins))
    output.mkdir(parents=True)
    (output/'maps.bin').write_bytes(data)
    # One map row per line keeps the integer arrays easy to review.
    for filename,content in [('symbols.json',symbols),('tiles.json',maps)]:
        text='[\n'+',\n'.join('  [\n'+',\n'.join('    '+json.dumps(row) for row in rows)+'\n  ]' for rows in content)+'\n]\n'
        (output/filename).write_text(text)
    preview(maps,output/'overview.png')
    report=dict(format='sundog-world-map-two-bit',size=len(data),sha256=sha(data),
        map_count=18,map_size=[40,24],bytes_per_map=240,records=records,
        consumer='Library 23 procedure 2; game 21 $1114-$1133',
        state_table_offset=0x6f,state_table_hex=STATE_TABLE.hex(),
        classification_evidence='docs/world-maps.md',
        excluded_prefix_bytes=16,preview='overview.png',
        preview_note='Colors distinguish decoded tile indices; no gameplay terrain labels, random variants, or city overlays',
        inverse='pack_symbols() reproduces every 240-byte payload; tile decoding alone is not injective')
    (output/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
    recipe=dict(name='world_maps',data=str((output/'maps.bin').relative_to(ROOT)),
        format=report['format'],classification=report['classification_evidence'],mappings=mappings)
    (output/'adopt.json').write_text(json.dumps(recipe,indent=2)+'\n')
    return dict(size=len(data),map_count=18,disk_output_bytes=sum(m['size'] for m in mappings))


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--extract',type=Path,required=True)
    args=parser.parse_args()
    print(json.dumps(extract(args.extract.resolve())))
