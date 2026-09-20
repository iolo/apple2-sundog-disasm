import unittest

from city_map_asset import pack_tiles, unpack_tiles


class CityMapTests(unittest.TestCase):
    def test_column_order_and_low_nibble_first(self):
        data = bytes.fromhex('10 32 54 76 98 ba dc fe')+bytes(112)
        rows = unpack_tiles(data)
        self.assertEqual([row[0] for row in rows], list(range(12)))
        self.assertEqual([row[1] for row in rows], [12,13,14,15]+[0]*8)
        self.assertEqual(rows[0][2:], [0]*18)

    def test_inverse_preserves_every_nibble(self):
        data = bytes((i*73+19)%256 for i in range(120))
        self.assertEqual(pack_tiles(unpack_tiles(data)), data)
        rows = [[(x+y*3)%16 for x in range(20)] for y in range(12)]
        self.assertEqual(unpack_tiles(pack_tiles(rows)), rows)

    def test_malformed_shape_and_values(self):
        for data in (bytes(119), bytes(121)):
            with self.assertRaises(ValueError):
                unpack_tiles(data)
        for rows in ([[0]*20]*11, [[0]*19]*12, [[16]*20]*12, [[True]*20]*12):
            with self.assertRaises(ValueError):
                pack_tiles(rows)


if __name__ == '__main__':
    unittest.main()
