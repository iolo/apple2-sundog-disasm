import unittest

from item_name_asset import decode, encode


class ItemNameTests(unittest.TestCase):
    def test_counted_name_preserves_nontext_residue_and_value(self):
        record = bytes([4])+b'food'+bytes(range(128,138))+bytes([255])
        data = record*64
        records = decode(data)
        self.assertEqual(records[0]['name'], 'food')
        self.assertEqual(records[0]['value_byte'], 255)
        self.assertEqual(encode(records), data)

    def test_zero_length_is_not_inferred_from_stale_text(self):
        data = (b'\0'+b'(nothing)'+b'\0'*5+b'\x01')*64
        records = decode(data)
        self.assertEqual(records[0]['name'], '')
        self.assertEqual(encode(records), data)

    def test_malformed_record_or_edit_is_rejected(self):
        for data in (bytes(1023), bytes([15])+bytes(1023), b'\x01\xff'+bytes(1022)):
            with self.assertRaises(ValueError):
                decode(data)
        records = decode(bytes(1024))
        records[0]['name'] = 'longer'
        with self.assertRaises(ValueError):
            encode(records)
        records = decode(bytes(1024))
        records[1]['index'] = 0
        with self.assertRaises(ValueError):
            encode(records)


if __name__ == '__main__':
    unittest.main()
