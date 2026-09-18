#!/usr/bin/env python3
"""Verify tile record/row boundaries and lossless phase-bit preservation."""
import unittest
from tile_asset import unpack_tiles, pack_tiles


class TileTests(unittest.TestCase):
    def test_layout_and_all_bits(self):
        raw=bytes((tile*13+row*7+col*65)&255
                  for tile in range(16) for row in range(32) for col in range(4))
        tiles=unpack_tiles(raw)
        self.assertEqual(tiles[0][0],list(raw[:4]))
        self.assertEqual(tiles[1][0],list(raw[128:132]))
        self.assertEqual(tiles[15][31],list(raw[-4:]))
        self.assertEqual(pack_tiles(tiles),raw)

    def test_world_tiles_have_96_byte_records(self):
        raw=bytes((i*67+i//96)&255 for i in range(2016))
        rows=unpack_tiles(raw,height=24,count=21)
        self.assertEqual(rows[1][0],list(raw[96:100]))
        self.assertEqual(rows[20][23],list(raw[-4:]))
        self.assertEqual(pack_tiles(rows,height=24,count=21),raw)
        with self.assertRaises(ValueError):
            unpack_tiles(raw+bytes(32),height=24,count=21)

    def test_bad_shapes_and_values(self):
        with self.assertRaises(ValueError):
            unpack_tiles(bytes(2047))
        rows=unpack_tiles(bytes(2048))
        with self.assertRaises(ValueError):
            pack_tiles(rows[:-1])
        rows[0][0][0]=256
        with self.assertRaises(ValueError):
            pack_tiles(rows)


if __name__ == '__main__':
    unittest.main()
