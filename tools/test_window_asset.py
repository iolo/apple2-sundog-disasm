import unittest

from window_asset import decode, encode


class WindowTests(unittest.TestCase):
    def test_row_order_phase_and_position_fields(self):
        data = bytearray(1922)
        data[:3] = bytes([1,128,255])
        data[20] = 73
        data[1919:] = bytes([42,19,88])
        fields = decode(data)
        self.assertEqual(fields['rows'][0][:3],[1,128,255])
        self.assertEqual(fields['rows'][1][0],73)
        self.assertEqual(fields['rows'][95][19],42)
        self.assertEqual((fields['x_byte'],fields['y_row']),(19,88))
        self.assertEqual(encode(fields),data)

    def test_unreviewed_tail_and_bad_fields_are_rejected(self):
        with self.assertRaises(ValueError):
            decode(bytes(2048))
        fields = decode(bytes(1922))
        fields['rows'][0].pop()
        with self.assertRaises(ValueError):
            encode(fields)
        fields = decode(bytes(1922))
        fields['x_byte'] = 256
        with self.assertRaises(ValueError):
            encode(fields)


if __name__ == '__main__':
    unittest.main()
