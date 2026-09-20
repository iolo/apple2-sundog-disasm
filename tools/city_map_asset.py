#!/usr/bin/env python3
"""Extract the evidenced 20-column, 12-row nibble city-map payloads."""
import argparse
import json
from pathlib import Path

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha


def unpack_tiles(data):
    if len(data) != 120:
        raise ValueError('City payload must contain 120 bytes')
    # Each column occupies six bytes; packed fields run low nibble first.
    return [[(data[x*6+y//2] >> (4*(y%2))) & 15 for x in range(20)]
            for y in range(12)]


def pack_tiles(rows):
    if len(rows) != 12 or any(len(row) != 20 for row in rows):
        raise ValueError('City map must contain 12 rows of 20 tiles')
    if any(type(tile) is not int or not 0 <= tile <= 15 for row in rows for tile in row):
        raise ValueError('City tiles must be four-bit integers')
    return bytes(rows[y][x] | rows[y+1][x] << 4 for x in range(20) for y in range(0,12,2))


def preview(maps, output):
    from PIL import Image, ImageDraw
    colors = ['#142538','#227093','#34ace0','#706fd3','#474787','#33d9b2','#218c74',
              '#ffb142','#cc8e35','#ff5252','#b33939','#f7f1e3','#84817a','#9bcb67',
              '#f8a5c2','#786fa6']
    image = Image.new('RGB', (8*92,8*70), '#121820')
    draw = ImageDraw.Draw(image)
    for index, entry in enumerate(maps):
        ox, oy = index%8*92, index//8*70
        draw.text((ox+2,oy+2), f"{entry['variant']} {entry['index']:02d}", fill='white')
        for y, row in enumerate(entry['tiles']):
            for x, tile in enumerate(row):
                left, top = ox+x*4, oy+18+y*4
                draw.rectangle((left,top,left+3,top+3), fill=colors[tile])
    image.save(output)


def extract(output):
    output = output.resolve()
    relative = output.relative_to(ROOT)
    if output.exists():
        raise ValueError('City-map output already exists')
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disks = {disk['id']:disk for disk in manifest['disks']}
    images = {}
    for disk_id, disk in disks.items():
        image = (ROOT/'build/disks'/disk['filename']).read_bytes()
        if sha(image) != disk['sha256']:
            raise ValueError('Rebuild current baseline before extraction')
        images[disk_id] = image
    binary, maps, records, mappings = bytearray(), [], [], []
    for variant, disk_id, first, count in [('play','disk2',64,60), ('demo','disk1',195,4)]:
        bank = block_bytes(images[disk_id], first, first+count//4)
        for index in range(count):
            payload = bank[index*128+8:(index+1)*128]
            rows = unpack_tiles(payload)
            if pack_tiles(rows) != payload:
                raise ValueError('City packing round trip differs')
            block, within = first+index//4, index%4*128+8
            offset = logical_sector_offset(block*2+within//256)+within%256
            owners = [r for r in disks[disk_id]['regions'] if r['offset'] <= offset
                      and offset+120 <= r['offset']+r['size']]
            if len(owners) != 1 or manifest['components'][owners[0]['input']]['kind'] != 'temporary-unresolved':
                raise ValueError('City payload overlaps reconstructed bytes')
            mappings.append(dict(disk=disk_id, offset=offset, size=120, input_offset=len(binary)))
            records.append(dict(variant=variant, index=index, disk=disk_id, block=block,
                                byte_offset=within, input_offset=len(binary), size=120,
                                sha256=sha(payload), excluded_prefix=bank[index*128:index*128+8].hex()))
            maps.append(dict(variant=variant, index=index, tiles=rows))
            binary.extend(payload)
    recipe = dict(name='city_maps', data=str(relative/'maps.bin'),
                  format='64 city maps: 20 columns x 12 rows, low-nibble-first, column-major',
                  classification='docs/city-maps.md', mappings=mappings)
    report = dict(classification='data', classification_evidence='docs/city-maps.md',
                  payload_size=120, record_stride=128, payload_offset=8,
                  source_bytes=len(binary), disk_bytes=sum(m['size'] for m in mappings),
                  sha256=sha(binary), maps=records)
    output.mkdir(parents=True)
    (output/'maps.bin').write_bytes(binary)
    for name, value in [('tiles.json',maps), ('manifest.json',report), ('adopt.json',recipe)]:
        (output/name).write_text(json.dumps(value, indent=2)+'\n')
    preview(maps, output/'overview.png')
    print(f'Extracted {len(maps)} city payloads, {len(binary)} classified disk bytes')


def verify(output):
    binary = (output/'maps.bin').read_bytes()
    report = json.loads((output/'manifest.json').read_text())
    maps = json.loads((output/'tiles.json').read_text())
    if len(binary) != 7680 or sha(binary) != report['sha256'] or len(maps) != 64 or len(report['maps']) != 64:
        raise ValueError('City asset size/hash differs')
    for i, (entry, record) in enumerate(zip(maps, report['maps'])):
        expected = ('play',i) if i < 60 else ('demo',i-60)
        if (entry['variant'],entry['index']) != expected or (record['variant'],record['index']) != expected or record['input_offset'] != i*120:
            raise ValueError('City asset ordering differs')
        raw = binary[i*120:(i+1)*120]
        if sha(raw) != record['sha256'] or unpack_tiles(raw) != entry['tiles'] or pack_tiles(entry['tiles']) != raw:
            raise ValueError('City payload round trip differs')
    print('Verified 64 city maps and all 7,680 payload bytes')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--extract', type=Path)
    group.add_argument('--verify', type=Path)
    args = parser.parse_args()
    extract(args.extract) if args.extract else verify(args.verify)
