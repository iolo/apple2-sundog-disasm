import unittest

from save_state_asset import checksum, decode_payload, encode_payload, decode_slot, encode_slot


class SaveStateTests(unittest.TestCase):
    def test_checksum_uses_independent_byte_lanes(self):
        data = bytearray(5120)
        data[:6] = bytes([255,254,1,3,7,8])
        self.assertEqual(checksum(data), 0x0907)
        data[5100] += 1
        self.assertEqual(checksum(data), 0x0908)
        with self.assertRaises(ValueError):
            checksum(data[:-1])

    def test_section_boundaries_and_lossless_words(self):
        data = bytes((i*73+19)%256 for i in range(5024))
        fields = decode_payload(data)
        self.assertEqual(len(fields['records16']),64)
        self.assertEqual(len(fields['records32']),64)
        self.assertEqual(fields['records32'][0][0], int.from_bytes(data[1536:1538],'little'))
        self.assertEqual(fields['world_table_25'][0][0], int.from_bytes(data[4112:4114],'little'))
        self.assertEqual(encode_payload(fields),data)
        with self.assertRaises(ValueError):
            decode_payload(data+bytes(96))
        fields['records16'][0].pop()
        with self.assertRaises(ValueError):
            encode_payload(fields)

    def test_descriptor_preserves_residue_and_checksum_word(self):
        data = bytearray(b'\x04Test'+bytes(range(11))+bytes(range(48)))
        data[30:32] = b'\x29\xee'
        fields = decode_slot(data)
        self.assertEqual(fields['name'],'Test')
        self.assertEqual(fields['words'][7],0xee29)
        self.assertEqual(encode_slot(fields),data)
        data[0] = 16
        with self.assertRaises(ValueError):
            decode_slot(data)


if __name__ == '__main__':
    unittest.main()
