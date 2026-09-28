import json
from pathlib import Path
import sys
import unittest
import xml.etree.ElementTree as ET

sys.path.insert(0, str(Path(__file__).parent))
from export_assets import build, pixel_rows, svg, navigation_defaults
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


if __name__ == '__main__':
    unittest.main()
