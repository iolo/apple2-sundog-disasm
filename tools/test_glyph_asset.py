#!/usr/bin/env python3
"""Check glyph row direction, index boundaries, and preserved high bits."""
import unittest

from glyph_asset import display_rows, pack_rows


class GlyphTests(unittest.TestCase):
    def test_display_order_and_high_bits_round_trip(self):
        raw = bytes((i*53+(i//8)*19) & 255 for i in range(1024))
        rows = display_rows(raw)
        self.assertEqual(rows[0], list(raw[7::-1]))
        self.assertEqual(rows[65], list(raw[520:528][::-1]))
        self.assertEqual(rows[127], list(raw[1016:1024][::-1]))
        self.assertEqual(pack_rows(rows), raw)

    def test_bad_shapes_and_values_rejected(self):
        for size in (1023,1025):
            with self.assertRaises(ValueError):
                display_rows(bytes(size))
        rows = display_rows(bytes(1024))
        with self.assertRaises(ValueError):
            pack_rows(rows[:-1])
        rows[0][0] = 256
        with self.assertRaises(ValueError):
            pack_rows(rows)

    def test_explicit_half_bank_keeps_all_rows_without_inventing_glyphs(self):
        raw=bytes((i*53+(i//8)*19)&255 for i in range(512))
        rows=display_rows(raw,count=64)
        self.assertEqual(len(rows),64)
        self.assertEqual(rows[63],list(raw[504:512][::-1]))
        self.assertEqual(pack_rows(rows,count=64),raw)
        with self.assertRaises(ValueError):
            display_rows(raw)
        with self.assertRaises(ValueError):
            pack_rows(rows)


if __name__ == '__main__':
    unittest.main()
