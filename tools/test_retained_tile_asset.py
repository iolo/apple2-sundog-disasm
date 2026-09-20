import unittest

from disk_layout import ROOT
from retained_tile_asset import classify


class RetainedTileTests(unittest.TestCase):
    def test_complete_row_relationship_and_mutation_rejection(self):
        donor = (ROOT/'assets/tiles/bank3/tiles.bin').read_bytes()
        raw = donor[2016:2048]
        rows = classify(raw, donor)
        self.assertEqual(len(rows), 8)
        self.assertTrue(all(len(row) == 4 for row in rows))
        self.assertEqual(bytes(value for row in rows for value in row), raw)
        for bit in (1, 128):
            for position in range(32):
                changed = bytearray(raw)
                changed[position] ^= bit
                with self.subTest(bit=bit, position=position), self.assertRaises(ValueError):
                    classify(bytes(changed), donor)
        for changed in (raw[:-1], raw+b'\x80'):
            with self.assertRaises(ValueError):
                classify(changed, donor)
        other_bank = (ROOT/'assets/tiles/bank1/tiles.bin').read_bytes()
        self.assertNotEqual(raw, other_bank[2016:2048])
        with self.assertRaises(ValueError):
            classify(raw, other_bank)


if __name__ == '__main__':
    unittest.main()
