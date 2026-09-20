#!/usr/bin/env python3
"""Keep bounded zero storage separate from changed payloads and nonzero tails."""
import unittest

from asset_block_storage import LAYOUTS, classify
from disk_layout import ROOT


class StorageTests(unittest.TestCase):
    def payload(self, kind):
        path = ('assets/ship-images/full_ship/image.rle' if kind == 'full_ship'
                else 'assets/save-states/slots.bin')
        return (ROOT/path).read_bytes()

    def test_reviewed_boundaries_and_payloads(self):
        for kind,layout in LAYOUTS.items():
            payload = self.payload(kind)
            raw = payload+bytes(layout['allocation']-len(payload))
            item = classify(raw,kind,payload)
            self.assertEqual(item['offset'],len(payload))
            self.assertEqual(item['size'],layout['allocation']-len(payload))
            for changed in (raw[:-1], raw+b'\0',bytes([raw[0]^1])+raw[1:],
                            raw[:len(payload)]+b'\1'+raw[len(payload)+1:],raw[:-1]+b'\x80'):
                with self.assertRaises(ValueError):
                    classify(changed,kind,payload)

    def test_section_image_tail_is_not_accepted(self):
        payload = (ROOT/'assets/ship-images/ship_section/image.rle').read_bytes()
        raw = payload+b'\1'+bytes(2048-len(payload)-1)
        with self.assertRaises(ValueError):
            classify(raw,'full_ship',payload)


if __name__ == '__main__':
    unittest.main()
