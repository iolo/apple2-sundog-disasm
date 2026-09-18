#!/usr/bin/env python3
"""Protect HGR row order, phase bits, and non-display bytes during extraction."""
import unittest

from hgr_asset import row_offset, split_page, pack_page, VISIBLE, HOLES


class HgrAssetTests(unittest.TestCase):
    def test_known_row_addresses_and_complete_partition(self):
        for y, offset in ((0,0), (1,0x400), (7,0x1C00), (8,0x80), (63,0x1F80),
                          (64,0x28), (127,0x1FA8), (128,0x50), (191,0x1FD0)):
            self.assertEqual(row_offset(y), offset)
        self.assertEqual(len(VISIBLE), 7680)
        self.assertEqual(len(HOLES), 512)
        self.assertEqual(HOLES[:8], list(range(0x78,0x80)))
        self.assertEqual(VISIBLE | set(HOLES), set(range(8192)))
        self.assertFalse(VISIBLE & set(HOLES))

    def test_round_trip_preserves_high_bits_and_holes(self):
        data = bytes((i * 73 + (i >> 7)) & 255 for i in range(8192))
        rows, holes = split_page(data)
        self.assertEqual(rows[64], data[0x28:0x50])
        self.assertEqual(holes[:8], data[0x78:0x80])
        self.assertEqual(pack_page(rows, holes), data)

    def test_invalid_shapes_rejected(self):
        for length in (8191,8193):
            with self.assertRaises(ValueError):
                split_page(bytes(length))
        rows, holes = split_page(bytes(8192))
        for bad_rows, bad_holes in ((rows[:-1], holes), (rows, holes[:-1]), ([b'']+rows[1:], holes)):
            with self.assertRaises(ValueError):
                pack_page(bad_rows, bad_holes)


if __name__ == '__main__':
    unittest.main()
