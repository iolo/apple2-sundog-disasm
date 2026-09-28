import json
from pathlib import Path
import sys
import unittest
import xml.etree.ElementTree as ET

sys.path.insert(0, str(Path(__file__).parent))
from export_assets import build, pixel_rows, svg, navigation_defaults, packed_quantities, economy_defaults
from economy_reference import reference as economy_reference
from campaign_reference import reference as campaign_reference, decode_globals
from hgr_asset import split_page, row_offset


class ExportTests(unittest.TestCase):
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

    def test_live_content_and_vector_only(self):
        files = build()
        maps = json.loads(files['data/maps.json'])
        self.assertEqual(len(maps['cities']), 60)
        self.assertEqual(len(maps['worlds']), 18)
        self.assertEqual(maps['cities'][-1]['id'], 'city-60')
        for name, data in files.items():
            if name.endswith('.svg'):
                root = ET.fromstring(data)
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

    def test_item_quadrants_and_phase_mask(self):
        files = build()
        root = Path(__file__).resolve().parents[2]
        raw = (root / 'assets/play-glyphs/bank1/glyphs.bin').read_bytes()
        # Shunt23 uses glyphs78/79 above110/111, at the native renderer's anchors.
        expected = []
        for left, right in [(78, 79), (110, 111)]:
            for row in range(7, -1, -1):
                expected.append([int(bool(raw[glyph * 8 + row] & (1 << bit))) for glyph in [left, right] for bit in range(7)])
        self.assertEqual(files['assets/svg/items/item-23.svg'], svg(expected))

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
