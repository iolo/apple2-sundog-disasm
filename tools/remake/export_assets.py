#!/usr/bin/env python3
"""Export source-backed browser data and standalone monochrome vector artwork."""
import argparse
import hashlib
import json
import re
from room_assets import room_layouts
from dialogue_assets import dialogue_records, dialogue_text, dialogue_systems
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from hgr_asset import split_page
from tile_asset import pack_tiles


def pixel_rows(rows):
    return [[int(bool(byte & (1 << bit))) for byte in row for bit in range(7)] for row in rows]


def svg(rows):
    """Merge horizontal runs; each path remains a real vector, with no raster payload."""
    width, height = len(rows[0]), len(rows)
    if any(len(row) != width for row in rows):
        raise ValueError('Ragged pixel rows')
    paths = []
    for y, row in enumerate(rows):
        x = 0
        while x < width:
            if not row[x]:
                x += 1
                continue
            start = x
            while x < width and row[x]:
                x += 1
            paths.append(f'M{start} {y}h{x-start}v1h{start-x}z')
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}">'
            f'<path fill="#e6e1ce" d="{"".join(paths)}"/></svg>\n').encode()


def encode(value):
    return (json.dumps(value, ensure_ascii=False, separators=(',', ':')) + '\n').encode()


def navigation_defaults(raw):
    """Named static navigation fields only, from the utility default tables."""
    if len(raw) != 1440:
        raise ValueError('Expected 1440 world-default bytes')
    def name(record):
        if not 0 < record[0] <= 9:
            raise ValueError('Invalid navigation name')
        return record[1:1 + record[0]].decode('ascii')
    systems, worlds = [], []
    for i in range(12):
        record = raw[i * 20:(i + 1) * 20]
        membership = int.from_bytes(record[10:12], 'little')
        first, count = (membership >> 2) & 31, membership & 3
        systems.append(dict(id=f'system-{i+1:02}', name=name(record),
                            position=dict(x=record[16] & 15, y=record[16] >> 4, z=record[17] & 15),
                            worldIds=[f'world-{n:02}' for n in range(first, first + count)]))
    for i in range(18):
        record = raw[240 + i * 16:256 + i * 16]
        worlds.append(dict(id=f'world-{i+1:02}', name=name(record), orbitalRadius=record[13]))
    if [world for system in systems for world in system['worldIds']] != [world['id'] for world in worlds]:
        raise ValueError('Invalid system/world membership')
    return dict(version=1, systems=systems, worlds=worlds,
                source='utility_disk1 procedures11/12/13; game13 procedures14/15; library24 procedures4/6')


def packed_quantities(raw):
    """31 commodity quantities: five 3-bit fields per word, skipping bit15."""
    if len(raw) != 14:
        raise ValueError('Expected 14 packed quantity bytes')
    words = [int.from_bytes(raw[i:i+2], 'little') for i in range(0, 14, 2)]
    return [(words[i // 5] >> (3 * (i % 5))) & 7 for i in range(31)]


def starting_location(raw):
    """Utility18's static starting location, excluding the generated orbit angle."""
    if len(raw) != 1440:
        raise ValueError('Expected 1440 world-default bytes')
    world = raw[240:256]  # Utility21 selects system1/world1.
    city = (int.from_bytes(world[14:16], 'little') >> 3) & 63
    if not 1 <= city <= 57:
        raise ValueError('Invalid starting city')
    city_position = int.from_bytes(raw[528+(city-1)*12+10:540+(city-1)*12], 'little')
    return dict(version=1, systemId='system-01', worldId='world-01', cityId=f'city-{city:02}',
                orbitalRadius=world[13], surfacePosition=dict(x=10+world[10]%20,y=6+world[10]//20),
                cityPosition=dict(x=city_position & 63,y=(city_position >> 6) & 31),
                playerPosition=dict(x=54,y=110), shipPosition=dict(x=147,y=115),
                source='utility_disk1 procedures18/21; game15 procedure11; game21 procedures6/9')


def economy_defaults(raw, worlds, utility):
    """Only utility templates, city metadata and recipes; never working records."""
    if len(raw) != 505 or len(worlds) != 1440:
        raise ValueError('Invalid economy defaults size')
    templates = [dict(demand=packed_quantities(raw[i:i+14]),
                      supply=packed_quantities(raw[i+14:i+28])) for i in range(0, 504, 28)]
    cities = []
    for i in range(18):
        membership = int.from_bytes(worlds[254+i*16:256+i*16], 'little')
        first, count = (membership >> 9) & 63, membership & 7
        for city in range(first, first+count):
            record = worlds[528+(city-1)*12:540+(city-1)*12]
            if not 0 < record[0] <= 9:
                raise ValueError('Invalid city name')
            cities.append(dict(id=f'city-{city:02}', worldId=f'world-{i+1:02}',
                               name=record[1:1+record[0]].decode('ascii')))
    if [c['id'] for c in cities] != [f'city-{i:02}' for i in range(1,58)]:
        raise ValueError('Invalid city membership')
    phases = []
    for address in ['04D3','04DF','04ED','04F9','0507','0513','0521','052D','053B']:
        match = re.search(rf'L_{address}:\s+\.byte ([^;]+); string-data', utility)
        if match is None:
            raise ValueError('Missing colony recipe')
        values = [int(v.strip().removeprefix('$'),16)-64 for v in match[1].split(',')]
        if len(values) != 8 or any(v < 0 or v > 31 for v in values):
            raise ValueError('Invalid colony recipe')
        phases.append([values.count(i) for i in range(1,32)])
    return dict(version=1, selector=raw[504], templates=templates, cities=cities,
                colonyCityId='city-60', colonyRequirements=phases,
                source='utility_disk1 procedures14/15/16; game20 procedures4/5/6/19/23')


def build():
    outputs, sources = {}, {}

    def read(name):
        raw = (ROOT / name).read_bytes()
        sources[name] = hashlib.sha256(raw).hexdigest()
        return raw

    read('src/pcode/game_16.s')
    outputs['data/dialogue.json'] = encode(dialogue_records(json.loads(read('docs/reference/dialogue-scripts.json'))))
    outputs['data/dialogue-text.json'] = encode(dialogue_text(
        json.loads(read('assets/dialogue-dictionary/fields.json')),
        json.loads(read('assets/dialogue-messages/fields.json')),
        json.loads(read('assets/dialogue-bank-storage/fields.json'))))

    images, ship_collision = {}, {}
    for name, source in [('ship', 'assets/ship-images/full_ship/decoded.hgr'),
                         ('ship-section', 'assets/ship-images/ship_section/decoded.hgr'),
                         ('title', 'assets/title/title.hgr')]:
        rows, _ = split_page(read(source))
        path = f'assets/svg/{name}.svg'
        outputs[path] = svg(pixel_rows(rows))
        images[name] = path
        if name in ('ship', 'ship-section'):
            # Library22 native procedure9 tests the same low seven HGR bits.
            # Keep collision data independent of presentation SVGs.
            ship_collision[name] = [[value & 127 for value in row] for row in rows]

    font = read('assets/font/font.bin')
    glyph = lambda index: [value & 127 for value in reversed(font[index * 8:index * 8 + 8])]
    outputs['assets/svg/player.svg'] = svg(pixel_rows([[value] for value in glyph(12)]))
    images['player'] = 'assets/svg/player.svg'
    outputs['assets/svg/city-player.svg'] = svg(pixel_rows([[value] for value in glyph(10)]))
    images['city-player'] = 'assets/svg/city-player.svg'
    exterior = [[left, right ^ pod] for left, right, pod in zip(glyph(36), glyph(37), glyph(16))]
    outputs['assets/svg/landed-ship.svg'] = svg(pixel_rows(exterior))
    images['landed-ship'] = 'assets/svg/landed-ship.svg'
    outputs['data/ship-walk.json'] = encode(dict(
        version=1, width=280, height=192, spawn=dict(x=54, y=110),
        spriteRows=glyph(12), collisionRows=glyph(13), backgrounds=ship_collision,
        source='game_15 procedures 11/13; library_22 procedures 9/22; shared font glyphs 12/13'))

    # Library27 procedures3/4 compose four bank1 glyphs for each item.
    item_font = read('assets/play-glyphs/bank1/glyphs.bin')
    item_glyph = lambda index: pixel_rows([[v & 127] for v in reversed(item_font[index * 8:index * 8 + 8])])
    item_images = {}
    for index in [7, *range(8, 14), *range(15, 32)]:
        base = index * 2 + (32 if index >= 16 else 0)
        quadrants = [item_glyph(base + offset) for offset in [0, 1, 32, 33]]
        rows = [a + b for a, b in zip(quadrants[0], quadrants[1])]
        rows += [a + b for a, b in zip(quadrants[2], quadrants[3])]
        path = f'assets/svg/items/item-{index:02}.svg'
        outputs[path] = svg(rows)
        item_images[str(index)] = path
    # Only deterministic, named inventory fields; no generated campaign data.
    for source in ['src/pcode/utility_disk1.s', 'src/pcode/game_14.s', 'src/pcode/library_27.s']:
        read(source)  # Pin the traced rules along with the graphics bytes.
    outputs['data/ship-inventory.json'] = encode(dict(
        version=1, carried=[0] * 4, locker=[0] * 15 + [23] * 5,
        stores=[10] * 5 + [8] * 5 + [235, 12] + [0] * 8,
        condition=dict(vigor=255, rest=255, health=255, nourishment=255),
        source='utility_disk1 procedures20/21; game14 procedures3/4/8; library27 procedures7/11/13/14/15; game8 procedures2/7'))

    # Do not export saved balances, discovery flags, orbital angles, or working
    # gameplay records as new-game defaults. These positions seed utility12 jitter.
    initial_data = read('assets/working-state/data.bin')
    defaults = initial_data[505:1945]
    outputs['data/dialogue-systems.json'] = encode(dialogue_systems(defaults))
    for source in ['src/pcode/library_22.s', 'src/pcode/library_24.s', 'src/pcode/library_28.s',
                   'src/pcode/game_13.s', 'src/native/pcode_primitives.s']:
        read(source)
    outputs['data/initial-navigation.json'] = encode(navigation_defaults(defaults))
    outputs['data/initial-location.json'] = encode(starting_location(defaults))
    for source in ['src/pcode/startup_7.s', 'src/pcode/game_8.s', 'src/pcode/game_15.s', 'src/pcode/game_21.s']:
        read(source)
    read('src/pcode/game_20.s')
    outputs['data/initial-economy.json'] = encode(economy_defaults(
        initial_data[:505], defaults, read('src/pcode/utility_disk1.s').decode()))

    tile_banks = {}
    for bank, source, height, count in [
        *((f'city-{n}', f'assets/tiles/bank{n}/rows.json', 32, 16) for n in range(4)),
        ('world', 'assets/world-tiles/rows.json', 24, 21),
    ]:
        tiles = json.loads(read(source))
        pack_tiles(tiles, height=height, count=count)  # Reuse the evidenced shape validator.
        paths = []
        for i, rows in enumerate(tiles):
            path = f'assets/svg/tiles/{bank}-{i:02}.svg'
            outputs[path] = svg(pixel_rows(rows))
            paths.append(path)
        tile_banks[bank] = paths

    outputs['data/city-walk.json'] = encode(dict(version=1,
        banks=[[[[byte & 127 for byte in row] for row in tile] for tile in
                json.loads(read(f'assets/tiles/bank{i}/rows.json'))] for i in range(4)],
        spriteRows=glyph(10), collisionRows=glyph(11), shipRows=exterior,
        collisionByteMasks=[0x55,0x2a],
        source='game21 procedures7/15/23/25; library22 procedures9/11, pattern9'))
    native = read('src/pcode/library_22.s').decode()
    patterns = [[int(v.strip().removeprefix('$'), 16) & 127 for v in
                 re.search(label+r':\s+\.byte ([^;]+)', native)[1].split(',')]
                for label in ['L_164A', 'L_163E']]
    read('src/pcode/game_18.s')
    rooms = room_layouts(read('assets/interaction-records/records.bin'), patterns)
    for room in rooms:
        path = f'assets/svg/room-{room["index"]:02}.svg'
        outputs[path] = svg(pixel_rows(room['rows']))
        images[f'room-{room["index"]:02}'] = path
    outputs['assets/svg/room-player.svg'] = svg(pixel_rows([[v] for v in glyph(22)]))
    images['room-player'] = 'assets/svg/room-player.svg'
    outputs['assets/svg/room-npc.svg'] = svg(pixel_rows([[v] for v in glyph(23)]))
    images['room-npc'] = 'assets/svg/room-npc.svg'
    outputs['data/room-walk.json'] = encode(dict(version=3, layouts=rooms,
        spriteRows=glyph(22), npcRows=glyph(23), collisionRows=glyph(24), counterCollisionRows=glyph(3),
        source='game18 procedures9/13/14/16/17/26; library22 procedures7/9/18/19/51; interaction records8–15'))
    cities = json.loads(read('assets/city-maps/tiles.json'))
    cities = [dict(id=f'city-{r["index"]+1:02}', sourceIndex=r['index'], tiles=r['tiles'])
              for r in cities if r['variant'] == 'play']
    worlds = [dict(id=f'world-{i+1:02}', sourceIndex=i, tiles=rows)
              for i, rows in enumerate(json.loads(read('assets/world-maps/tiles.json')))]
    for records, count, width, height, limit in [(cities, 60, 20, 12, 15), (worlds, 18, 40, 24, 13)]:
        if len(records) != count or len({r['id'] for r in records}) != count:
            raise ValueError('Unexpected live map inventory')
        for record in records:
            rows = record['tiles']
            if len(rows) != height or any(len(row) != width for row in rows):
                raise ValueError('Invalid map dimensions')
            if any(type(v) is not int or not 0 <= v <= limit for row in rows for v in row):
                raise ValueError('Invalid map index')
    outputs['data/maps.json'] = encode(dict(cities=cities, worlds=worlds))
    names = json.loads(read('assets/item-names/play/records.json'))
    if len(names) != 64:
        raise ValueError('Expected two 32-record name banks')
    outputs['data/items.json'] = encode([
        dict(id=f'{"item" if i < 32 else "cargo"}-{i%32:02}', sourceIndex=i,
             name=r['name'], valueByte=r['value_byte']) for i, r in enumerate(names)])
    catalog = dict(version=1, images=images, tileBanks=tile_banks, maps='data/maps.json',
                   items='data/items.json', shipWalk='data/ship-walk.json',
                   itemImages=item_images, shipInventory='data/ship-inventory.json',
                   presentation='monochrome low-seven-bit vectors; raw maps without runtime overlays')
    outputs['data/catalog.json'] = encode(catalog)
    outputs['data/provenance.json'] = encode(dict(
        generator='tools/remake/export_assets.py', sources=sources,
        outputs={path: hashlib.sha256(data).hexdigest() for path, data in sorted(outputs.items())}))
    return outputs


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    outputs = build()
    for name, data in outputs.items():
        target = ROOT / 'remake' / name
        if args.check:
            if not target.exists() or target.read_bytes() != data:
                raise SystemExit(f'Stale export: {name}')
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
    print(f'{len(outputs)} deterministic artifacts {"verified" if args.check else "written"}')
