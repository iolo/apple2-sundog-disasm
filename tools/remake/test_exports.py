import json
import hashlib
from pathlib import Path
import sys
import unittest
import xml.etree.ElementTree as ET

sys.path.insert(0, str(Path(__file__).parent))
from export_assets import build, pixel_rows, color_rows, HGR_COLORS, HGR_WHITE, svg, navigation_defaults, packed_quantities, economy_defaults
from room_assets import room_layouts, lodging_door_rows
from economy_reference import reference as economy_reference
from campaign_reference import reference as campaign_reference, decode_globals
from hgr_asset import split_page, row_offset
from dialogue_dictionary_asset import encode_base, encode_extra, text_bytes


class ExportTests(unittest.TestCase):
    def test_ground_chase_draws_the_native_clear_window_and_full_collision_glyph(self):
        root = Path(__file__).resolve().parents[2]
        data = json.loads(build()['data/ground-chase.json'])
        font = (root / 'assets/font/font.bin').read_bytes()
        for index in [22, 23, 24]:
            self.assertEqual(data['glyphs'][str(index)], [n & 127 for n in reversed(font[index*8:index*8+8])])
        self.assertEqual(data['glyphs']['24'], [127]*8)
        # Library22 $163E/$164A retain the native colour phase in bit7;
        # collision and monochrome rendering use their low seven bits.
        self.assertEqual(data['patterns'], [
            [0,127,0,0,0,42,85,127,0,42,85,127],
            [0,127,0,0,0,85,42,127,0,85,42,127]])

    def test_flight_starports_match_independent_clean_character_records(self):
        root = Path(__file__).resolve().parents[2]
        captured = json.loads((root / 'docs/reference/remake-clean-character.json').read_text())
        raw = bytes.fromhex(captured['worldTablesHex'])
        data = json.loads(build()['data/flight-defaults.json'])
        self.assertEqual(len(data['worlds']), 18)
        for i, world in enumerate(data['worlds']):
            tile = raw[250+i*16]
            self.assertEqual(world['landingTile'], tile)
            self.assertEqual(world['landingPosition'], dict(x=10+tile%20, y=6+tile//20))
        self.assertEqual(data['shipPosition'], dict(x=150, y=115))

    def test_surface_assets_and_city_coordinates_match_capture(self):
        root = Path(__file__).resolve().parents[2]
        data = json.loads(build()['data/surface-walk.json'])
        font = (root / 'assets/font/font.bin').read_bytes()
        for key, index in [('footRows',10),('podRows',26),('podAlternateRows',29),('collisionRows',15)]:
            self.assertEqual(data[key], [n & 127 for n in reversed(font[index*8:index*8+8])])
        tiles = json.loads((root / 'assets/world-tiles/rows.json').read_text())
        self.assertEqual(data['tiles'], [[[b & 127 for b in row] for row in tile] for tile in tiles])
        captured = json.loads((root / 'docs/reference/remake-clean-character.json').read_text())
        raw = bytes.fromhex(captured['worldTablesHex'])
        self.assertEqual(len(data['cities']),57)
        for city in data['cities']:
            index = int(city['cityId'][5:])-1
            packed = int.from_bytes(raw[538+index*12:540+index*12],'little')
            self.assertEqual(city['position'],dict(x=packed & 63,y=(packed >> 6) & 31))
            self.assertLess(city['position']['x'],40)
            self.assertLess(city['position']['y'],24)

    def test_exchange_defaults_match_clean_character_geography_and_price_nibbles(self):
        root = Path(__file__).resolve().parents[2]
        captured = json.loads((root / 'docs/reference/remake-clean-character.json').read_text())
        raw = bytes.fromhex(captured['worldTablesHex'])
        data = json.loads(build()['data/exchange-defaults.json'])
        self.assertEqual(len(data['systems']), 12)
        self.assertEqual(len(data['worlds']), 18)
        for i, system in enumerate(data['systems']):
            self.assertEqual(system, dict(id=f'system-{i+1:02}',
                priceLevel=raw[i*20+18] & 15, technologyLevel=raw[i*20+18] >> 4))
        for i, world in enumerate(data['worlds']):
            word = int.from_bytes(raw[254+i*16:256+i*16], 'little')
            first, count = (word >> 9) & 63, word & 7
            self.assertEqual(world['capitalCityId'], f'city-{(word >> 3) & 63:02}')
            self.assertEqual(world['cityIds'], [f'city-{n:02}' for n in range(first, first+count)])
            system = int(world['systemId'][7:])-1
            membership = int.from_bytes(raw[system*20+10:system*20+12], 'little')
            self.assertTrue((membership >> 2) & 31 <= i+1 < ((membership >> 2) & 31)+(membership & 3))

    def test_dialogue_system_defaults_match_clean_character_capture(self):
        root = Path(__file__).resolve().parents[2]
        captured = json.loads((root / 'docs/reference/remake-clean-character.json').read_text())
        raw = bytes.fromhex(captured['worldTablesHex'])
        systems = json.loads(build()['data/dialogue-systems.json'])['systems']
        self.assertEqual(len(systems), 12)
        for i, system in enumerate(systems):
            row = raw[i * 20:(i + 1) * 20]
            self.assertEqual(system, dict(id=f'system-{i+1:02}', local16=bool(row[10] & 128),
                local29=row[19] >> 4, local30=row[18] & 15, local31=row[18] >> 4, local32=row[17] >> 4))
            self.assertFalse(system['local16'])
            self.assertEqual(system['local29'], 0)

    def test_native_reward_exception_is_separate_from_normal_dialogue_banks(self):
        root = Path(__file__).resolve().parents[2]
        data = json.loads(build()['data/dialogue.json'])
        self.assertEqual([bank['block'] for bank in data['banks']], list(range(90, 103)))
        self.assertEqual(data['exceptions'], {'224': dict(block=103, kind='zeroRandomSelector',
            runtimeError=6, source='docs/reference/remake-reward-reference.json')})
        native = json.loads((root / 'docs/reference/remake-reward-zero-modulus.json').read_text())
        self.assertEqual(native['evaluationStack']['bytes'][:4], [0, 0, 5, 75])
        trap = json.loads((root / 'docs/reference/remake-reward-zero-error.json').read_text())
        self.assertEqual(trap['source']['cpu']['PC'], 0xd7ed)
        self.assertEqual(trap['source']['randomBytes'], [151, 203, 5, 0])

    def test_dialogue_text_round_trips_dictionary_and_every_message(self):
        root = Path(__file__).resolve().parents[2]
        content = json.loads(build()['data/dialogue-text.json'])
        field = lambda value: dict(stored_characters=value['text'], high_bit_positions=value['spaces'])
        dictionary = json.loads((root / 'assets/dialogue-dictionary/fields.json').read_text())
        packed = bytearray(encode_base(dict(entries=[field(e) for e in content['base']])))
        for supplement in dictionary[1:]:
            fields = dict(supplement['fields'], entries=[field(e) for e in content['supplements'][str(supplement['block'])]])
            packed.extend(encode_extra(fields))
        self.assertEqual(len(packed), 1930)
        self.assertEqual(packed, (root / 'assets/dialogue-dictionary/dictionary.bin').read_bytes())
        count = 0
        for folder, filename in [('dialogue-messages', 'messages.bin'), ('dialogue-bank-storage', 'data.bin')]:
            original = (root / 'assets' / folder / filename).read_bytes()
            for record in json.loads((root / 'assets' / folder / 'fields.json').read_text()):
                if record.get('kind', 'message') != 'message':
                    continue
                value = content['messages'][str(record['block'])][str(record['bank_offset'] // 2)]
                raw = text_bytes(field(value))
                offset = record['input_offset']
                self.assertEqual(original[offset], len(raw))
                self.assertEqual(original[offset + 1:offset + 1 + len(raw)], raw)
                count += 1
        self.assertEqual(count, 165)

    def test_dialogue_round_trips_all_source_script_bytes(self):
        data = json.loads(build()['data/dialogue.json'])
        root = Path(__file__).resolve().parents[2]
        audit = json.loads((root / 'docs/reference/dialogue-scripts.json').read_text())
        packed = bytearray()
        count = 0
        for bank in data['banks']:
            packed.extend(bank['entries'][1 if bank['entries'][0] == 18 else 0:])
            for record in bank['records']:
                count += 1
                raw = [record['mode'] * 16 + len(record['replies']) * 4 + record['delayUnits'] // 2,
                       record['controls']]
                selection = record['selection']
                if selection['kind'] == 'literal':
                    raw.append(selection['value'])
                elif selection['kind'] == 'random':
                    raw.extend([len(selection['values']), *selection['values']])
                elif selection['kind'] == 'conditional':
                    raw.append(11 + len(selection['choices']))
                    for choice in selection['choices']:
                        raw.extend([choice['value'], choice['predicate']])
                    raw.append(selection['fallback'])
                elif selection['kind'] == 'mood':
                    raw.append(selection['code'])
                    if selection['code'] == 21:
                        raw.append(selection['fallback'])
                    raw.extend(selection['values'])
                else:
                    self.fail('Unknown selector')
                def transition(value, conditional):
                    raw.append(value['state'])
                    if conditional:
                        override = value['unless']
                        raw.extend([override['predicate'], override['state']] if override else [0])
                for value in record['transitions']:
                    transition(value, record['mode'] & 1)
                for reply in record['replies']:
                    raw.append(reply['caption'])
                    transition(reply['transition'], record['mode'] & 2)
                if record['action']:
                    raw.extend([record['action']['opcode'], *record['action']['operands']])
                self.assertEqual(len(raw), record['end'] - record['offset'])
                packed.extend(raw)
        self.assertEqual(count, 96)
        self.assertEqual(len(packed), 1175)
        self.assertEqual(hashlib.sha256(packed).hexdigest(), audit['source_sha256'])

    def test_dialogue_message_candidates_include_mood21_fallbacks(self):
        root = Path(__file__).resolve().parents[2]
        fields = json.loads((root / 'assets/dialogue-messages/fields.json').read_text())
        fields += [f for f in json.loads((root / 'assets/dialogue-bank-storage/fields.json').read_text())
                   if f['kind'] == 'message']
        messages = {(f['block'], f['bank_offset'] // 2) for f in fields}
        fallbacks = set()
        for bank in json.loads(build()['data/dialogue.json'])['banks']:
            for record in bank['records']:
                if record['redirect']:
                    continue
                selection = record['selection']
                kind = selection['kind']
                if kind == 'literal':
                    values = [selection['value']]
                elif kind == 'conditional':
                    values = [c['value'] for c in selection['choices']] + [selection['fallback']]
                else:
                    values = selection['values'][:]
                    if kind == 'mood' and selection['code'] == 21:
                        values.append(selection['fallback'])
                        fallbacks.add((bank['block'], selection['fallback']))
                for value in values:
                    self.assertIn((bank['block'], value), messages)
        self.assertEqual(fallbacks, {(90, 89), (94, 147), (95, 180)})

    def test_room_records_bounds_and_drawing_order(self):
        files = build()
        data = json.loads(files['data/room-walk.json'])
        raw = (Path(__file__).resolve().parents[2] / 'assets/interaction-records/records.bin').read_bytes()
        self.assertEqual(data['collisionRows'], [127]*8)
        self.assertEqual(data['spriteRows'], [0, 0, 12, 30, 30, 12, 0, 0])
        self.assertEqual(data['npcRows'], [0, 0, 12, 18, 18, 12, 0, 0])
        self.assertEqual(data['counterCollisionRows'], [0, 30, 30, 30, 30, 30, 30, 0])
        self.assertEqual(files['assets/svg/room-npc.svg'], svg(pixel_rows([[v] for v in data['npcRows']])))
        self.assertEqual([r['index'] for r in data['layouts']], [1, *range(4, 16)])
        for r in data['layouts']:
            source = raw[r['index']*32:(r['index']+1)*32]
            self.assertEqual(r['spawn'], dict(x=source[2], y=source[0]))
            self.assertEqual(r['exitX'], 12)
            self.assertEqual(r['population'], dict(bounds=r['bounds'][1],
                doorway=dict(x=source[3], y=source[1]),
                offset=dict(x=source[22]-128, y=source[23]-128),
                maximum=max(3, source[24]), activityDivisor=source[25] or 128))
            rows = pixel_rows(r['rows'])
            # The left corridor is cleared AFTER the outer wall; all seven
            # player columns/eight rows must fit the entrance, not just its center.
            spawn = r['spawn']
            self.assertTrue(all(rows[y][x] == 0 for y in range(spawn['y']-7, spawn['y']+1)
                                for x in range(spawn['x'], spawn['x']+7)))
            self.assertTrue(any(rows[4][x] for x in range(2, 138)))
            counter = r['bounds'][2]
            self.assertTrue(any(rows[counter['top']][counter['left']:counter['right']+1]))
            drawing = ET.fromstring(files[f'assets/svg/room-{r["index"]:02}.svg'])
            self.assertEqual(drawing.attrib['viewBox'], '0 0 140 96')
            self.assertTrue(all(path.attrib['fill'] in (*HGR_COLORS, HGR_WHITE) for path in drawing))

    def test_tavern_tables_and_lodging_doors(self):
        data = json.loads(build()['data/room-walk.json'])
        layouts = {r['index']: r for r in data['layouts']}
        for index in range(4, 8):
            room = layouts[index]
            self.assertEqual(room['fixtures']['seats'], [dict(action=4+i, x=x, y=86)
                for i, x in enumerate([16, 43, 53, 80, 90, 118])])
            pixels = pixel_rows(room['rows'])
            for left, right in [(23, 40), (60, 77), (97, 115)]:
                self.assertTrue(any(pixels[83][left:right+1]))
            for left in [49, 87]:
                self.assertTrue(any(pixels[y][x] for y in range(77, 87) for x in [left, left+1]))
        room = layouts[1]
        self.assertEqual(room['fixtures']['doors'], [dict(left=x, right=x+5, top=30, bottom=31)
            for x in [29, 57, 85, 113]])
        pixels = pixel_rows(room['rows'])
        for i in range(4):
            self.assertTrue(all(pixels[y][x] == 0 for y in range(8, 28) for x in range(21+28*i, 42+28*i)))
            self.assertTrue(any(pixels[y][x] for y in [30, 31] for x in range(29+28*i, 35+28*i)))

    def test_hgr_rows_and_phase_bits(self):
        page = bytearray(8192)
        page[row_offset(65)] = 0x81
        page[120] = 0xFF  # Memory hole must never become a displayed pixel.
        rows, _ = split_page(page)
        pixels = pixel_rows(rows)
        self.assertEqual(sum(map(sum, pixels)), 1)
        self.assertEqual(pixels[65][:7], [1, 0, 0, 0, 0, 0, 0])

    def test_svg_runs_keep_gaps(self):
        root = ET.fromstring(svg([[1, 1, 0, 1], [0, 0, 0, 0]]))
        self.assertEqual(root.attrib['viewBox'], '0 0 4 2')
        self.assertEqual(root[0].attrib['d'], 'M0 0h2v1h-2zM3 0h1v1h-1z')

    def test_hgr_color_phase_parity_and_white_runs(self):
        magenta, green, cyan, orange = HGR_COLORS
        rows = [[1], [2], [129], [130], [3], [0x55], [128]]
        original = [row[:] for row in rows]
        colored = color_rows(rows)
        self.assertEqual([colored[y][x] for y, x in [(0,0),(1,1),(2,0),(3,1)]],
                         [magenta, green, cyan, orange])
        self.assertEqual(colored[4][:3], [HGR_WHITE, HGR_WHITE, 0])
        self.assertEqual(colored[5], [magenta]*7)
        self.assertEqual(colored[6], [0]*7)  # Phase alone is never a pixel.
        self.assertEqual(color_rows([[0, 1]])[0][7], green)  # Global, not byte-local parity.
        self.assertEqual(color_rows([[64, 1]])[0][6:8], [HGR_WHITE]*2)
        self.assertEqual(color_rows([[0xaa, 0xd5]])[0], [orange]*14)
        self.assertEqual(color_rows([[0xd5, 0xaa]])[0], [cyan]*14)
        self.assertEqual(rows, original)

    def test_room_color_phase_does_not_change_collision_bits(self):
        raw = (Path(__file__).resolve().parents[2] / 'assets/interaction-records/records.bin').read_bytes()
        patterns = [[0,127,0,0,0,42,85,127,0,42,85,127],
                    [0,127,0,0,0,85,42,127,0,85,42,127]]
        mono = room_layouts(raw, patterns)
        colored = room_layouts(raw, [[value | 128 for value in row] for row in patterns])
        for before, after in zip(mono, colored):
            self.assertEqual(pixel_rows(before['rows']), pixel_rows(after['rows']))
        for mask in range(16):
            self.assertEqual(pixel_rows(lodging_door_rows(mono[0], mask)),
                             pixel_rows(lodging_door_rows(colored[0], mask)))

    def test_live_content_and_vector_only(self):
        files = build()
        maps = json.loads(files['data/maps.json'])
        self.assertEqual(len(maps['cities']), 60)
        self.assertEqual(len(maps['worlds']), 18)
        self.assertEqual(maps['cities'][-1]['id'], 'city-60')
        for name, data in files.items():
            if name.endswith('.svg'):
                root = ET.fromstring(data)
                if name in ('assets/svg/ship.svg', 'assets/svg/ship-section.svg'):
                    self.assertEqual((root.attrib['width'], root.attrib['height']), ('280', '192'))
                    self.assertEqual(root.attrib['preserveAspectRatio'], 'none')
                if name.startswith('assets/svg/tiles/'):
                    height = '24' if '/world-' in name else '32'
                    self.assertEqual((root.attrib['width'], root.attrib['height']), ('28', height))
                    self.assertEqual(root.attrib['preserveAspectRatio'], 'none')
                self.assertTrue(all(e.tag.rsplit('}', 1)[-1] in ('svg', 'path') for e in root.iter()))
        items = json.loads(files['data/items.json'])
        self.assertEqual(items[63]['name'], 'cryogens')
        self.assertEqual(items[0]['name'], '')  # Never expose discarded residual string bytes.

    def test_source_backed_collision_and_player(self):
        data = json.loads(build()['data/ship-walk.json'])
        self.assertEqual(data['spawn'], {'x': 54, 'y': 110})
        self.assertEqual(data['spriteRows'], [0, 0, 8, 28, 28, 8, 0, 0])
        self.assertEqual(data['collisionRows'], [0, 0, 62, 62, 62, 62, 0, 0])
        for rows in data['backgrounds'].values():
            self.assertEqual(len(rows), 192)
            self.assertTrue(all(len(row) == 40 and all(0 <= byte < 128 for byte in row) for row in rows))

    def test_inventory_matches_independent_clean_character_capture(self):
        root = Path(__file__).resolve().parents[2]
        captured = json.loads((root / 'docs/reference/remake-clean-character.json').read_text())
        raw = bytes.fromhex(captured['globalsHex'])
        data = json.loads(build()['data/ship-inventory.json'])
        for name, offset, size in [('carried', 52, 4), ('locker', 276, 20), ('stores', 304, 20)]:
            self.assertEqual(data[name], list(raw[offset:offset + size]))
        self.assertEqual([data['condition'][key] for key in ['vigor', 'rest', 'health', 'nourishment']], list(raw[48:52]))
        self.assertEqual(raw[12:16], bytes(4))  # Fresh clock at segment29 word42.

    def test_city_collision_and_exterior_glyphs(self):
        data = json.loads(build()['data/city-walk.json'])
        root = Path(__file__).resolve().parents[2]
        font = (root / 'assets/font/font.bin').read_bytes()
        glyph = lambda i: [n & 127 for n in reversed(font[i*8:i*8+8])]
        self.assertEqual(data['spriteRows'], glyph(10))
        self.assertEqual(data['collisionRows'], glyph(11))
        self.assertEqual(data['shipRows'], [[a, b ^ c] for a, b, c in zip(glyph(36), glyph(37), glyph(16))])
        self.assertEqual(data['detachedShipRows'], [[a, b] for a, b in zip(glyph(36), glyph(37))])
        self.assertEqual(data['podGlyphs'], {str(i): glyph(i) for i in range(14,22)})
        source = (root / 'src/pcode/library_22.s').read_text()
        import re
        patterns = [re.search(label+r':\s+\.byte ([^;]+)', source)[1] for label in ['L_164A','L_163E']]
        self.assertEqual(data['collisionByteMasks'], [(int(p.split(',')[9].strip().removeprefix('$'),16)^255)&127 for p in patterns])
        for i, bank in enumerate(data['banks']):
            original = json.loads((root / f'assets/tiles/bank{i}/rows.json').read_text())
            self.assertEqual(bank, [[[b & 127 for b in row] for row in tile] for tile in original])

    def test_navigation_static_fields_match_clean_capture(self):
        root = Path(__file__).resolve().parents[2]
        captured = json.loads((root / 'docs/reference/remake-clean-character.json').read_text())
        observed = navigation_defaults(bytes.fromhex(captured['worldTablesHex']))
        exported = json.loads(build()['data/initial-navigation.json'])
        self.assertEqual(exported['worlds'], observed['worlds'])
        for default, clean in zip(exported['systems'], observed['systems']):
            self.assertEqual(default['id'], clean['id'])
            self.assertEqual(default['name'], clean['name'])
            self.assertEqual(default['worldIds'], clean['worldIds'])
            self.assertEqual(set(default), {'id', 'name', 'position', 'worldIds'})
        with self.assertRaises(ValueError):
            navigation_defaults(bytes(1536))  # Exclude the unrelated tail.
        with self.assertRaises(ValueError):
            navigation_defaults(bytes(1440))

    def test_item_quadrants_and_color_phase(self):
        files = build()
        root = Path(__file__).resolve().parents[2]
        raw = (root / 'assets/play-glyphs/bank1/glyphs.bin').read_bytes()
        # Shunt23 uses glyphs78/79 above110/111, at the native renderer's anchors.
        expected = []
        for left, right in [(78, 79), (110, 111)]:
            for row in range(7, -1, -1):
                expected.append([raw[glyph * 8 + row] for glyph in [left, right]])
        self.assertEqual(files['assets/svg/items/item-23.svg'], svg(color_rows(expected)))

    def test_economy_matches_independent_clean_capture(self):
        data = json.loads(build()['data/initial-economy.json'])
        observed = economy_reference()
        self.assertEqual((data['selector']+5)%18, observed['selector'])
        for city, market in zip(data['cities'], observed['markets']):
            template = data['templates'][(observed['selector']+int(city['worldId'][6:])-1)%18]
            self.assertEqual(market, dict(cityId=city['id'], **template, lastUpdateDay=-16))
        self.assertEqual(data['colonyRequirements'], observed['colonyRequirements'])
        self.assertEqual(sum(phase[30] for phase in data['colonyRequirements']),17)
        self.assertEqual(observed['markets'][-1],dict(cityId='city-60',demand=[0]*31,supply=[0]*31,lastUpdateDay=-16))
        self.assertEqual(len(data['cities']),57)
        root = Path(__file__).resolve().parents[2]
        capture = json.loads((root/'docs/reference/remake-clean-character.json').read_text())
        world_bytes = bytes.fromhex(capture['worldTablesHex'])
        for i, city in enumerate(data['cities']):
            record = world_bytes[528+i*12:540+i*12]
            self.assertEqual(city['name'],record[1:1+record[0]].decode('ascii'))

    def test_economy_packing_skips_word_padding_and_saved_records(self):
        raw = b'\x00\x80' + b'\x01\x80'*6
        expected = [0]*31
        for i in range(5,31,5):
            expected[i]=1
        self.assertEqual(packed_quantities(raw),expected)
        with self.assertRaises(ValueError):
            packed_quantities(bytes(12))
        with self.assertRaises(ValueError):
            economy_defaults(bytes(5017),bytes(1440),'')

    def test_starting_location_matches_clean_capture(self):
        data=json.loads(build()['data/initial-location.json'])
        observed=campaign_reference()
        for role in ['player','ship']:
            location=observed[role+'Location']
            for key in ['systemId','worldId','cityId','surfacePosition','cityPosition']:
                self.assertEqual(data[key],location[key])
            self.assertEqual(data['orbitalRadius'],location['orbit']['radius'])
            self.assertEqual(data[role+'Position'],location['position'])
        self.assertNotIn('angle',data)
        self.assertEqual(observed['credits'],720)
        self.assertEqual(observed['gameplayRandomState'],0x3ef2d937)

    def test_ship_resource_decoder_uses_distinct_words_and_power_bits(self):
        raw=bytearray(512)
        for index,value in [(221,12),(222,200),(223,99),(224,255),(225,31),(226,78),(227,1234),(82,135)]:
            raw[(index-36)*2:(index-35)*2]=value.to_bytes(2,'little')
        raw[300]=15
        data=decode_globals(raw)
        self.assertEqual(data['shipResources'],dict(hull=15,fuel=1234,
            warp=dict(charge=99,targetCharge=200,targetSystemId='system-12',charging=True),
            shields=dict(charge=31,targetCharge=255),guns=dict(charge=78,powered=True),enginesPowered=True))
        self.assertTrue(data['podAttached'])
        raw[92]=0
        raw[19]=32  # Scene word45 bit13 is NOT the pod-attached flag.
        self.assertFalse(decode_globals(raw)['podAttached'])
        self.assertEqual(campaign_reference()['shipResources']['hull'],16)


if __name__ == '__main__':
    unittest.main()
