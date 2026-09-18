#!/usr/bin/env python3
"""Check packed symbol order, row state reset, and lossless map representation."""
import unittest
from world_map_asset import unpack_symbols, pack_symbols, decode_tiles


class WorldMapTests(unittest.TestCase):
    def test_low_pair_first_and_exact_inverse(self):
        raw=bytes([0xe4])+bytes((i*79)&255 for i in range(239))
        rows=unpack_symbols(raw)
        self.assertEqual(rows[0][:4],[0,1,2,3])
        self.assertEqual(pack_symbols(rows),raw)

    def test_state_resets_each_row(self):
        decoded=decode_tiles(unpack_symbols(bytes(240)))
        self.assertEqual(decoded[0][:6],[5,3,1,0,1,0])
        self.assertTrue(all(row==decoded[0] for row in decoded))
        self.assertEqual(decode_tiles(unpack_symbols(b'\xff'*240)),[[12]*40 for _ in range(24)])

    def test_bad_shape_and_symbol_rejected(self):
        with self.assertRaises(ValueError):
            unpack_symbols(bytes(256))
        rows=unpack_symbols(bytes(240))
        rows[0][0]=4
        with self.assertRaises(ValueError):
            pack_symbols(rows)
        with self.assertRaises(ValueError):
            decode_tiles(rows[:-1])


if __name__=='__main__':
    unittest.main()
