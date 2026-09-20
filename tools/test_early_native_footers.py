import unittest

from early_native_footers import classify, LAYOUTS


class EarlyFooterTests(unittest.TestCase):
    def fixture(self, name):
        layout = LAYOUTS[name]
        raw = bytearray(layout['size'])
        start = layout['footer_start']
        raw[start+8:start+16] = (start+8).to_bytes(2, 'little')+bytes.fromhex('000002000101')
        if name == 'title_draw':
            raw[-1] = 4
        return bytes(raw)

    def test_metadata_and_remaining_storage_are_distinguished(self):
        boot = classify(self.fixture('bootstrap'), 'bootstrap')
        title = classify(self.fixture('title_draw'), 'title_draw')
        self.assertEqual(boot['newly_classified_data_bytes'], 32)
        self.assertEqual(boot['remaining_provisional_ranges'], [])
        self.assertEqual(title['newly_classified_data_bytes'], 16)
        self.assertEqual([(r['offset'], r['size']) for r in title['remaining_provisional_ranges']], [(928,96)])
        for record in (boot, title):
            self.assertTrue(all(i['classification'] == 'data' for i in record['items']))
            self.assertEqual(record['dictionary']['procedures'][0]['entry_offset'], 0)

    def test_damaged_metadata_and_nonzero_boot_storage_are_rejected(self):
        for name, layout in LAYOUTS.items():
            for relative in (0, 8, 10, 11, 12, 14, 15):
                raw = bytearray(self.fixture(name))
                raw[layout['footer_start']+relative] ^= 1
                with self.subTest(name=name, relative=relative), self.assertRaises(ValueError):
                    classify(bytes(raw), name)
        raw = bytearray(self.fixture('bootstrap'))
        raw[-1] = 1
        with self.assertRaisesRegex(ValueError, 'Nonzero bootstrap'):
            classify(bytes(raw), 'bootstrap')


if __name__ == '__main__':
    unittest.main()
