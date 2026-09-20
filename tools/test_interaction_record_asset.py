import unittest

from interaction_record_asset import decode, encode


class InteractionRecordTests(unittest.TestCase):
    def test_fields_and_record_boundaries(self):
        raw = b''.join(bytes((i*31+j)%256 for j in range(26))+bytes(6) for i in range(16))
        fields = decode(raw)
        self.assertEqual(fields[0]['bounds'],[list(range(i,i+4)) for i in range(0,20,4)])
        self.assertEqual(fields[0]['style_nibbles'],[4,1])
        self.assertEqual(fields[0]['drawing_value'],21)
        self.assertEqual(fields[0]['relative_offsets'],[-106,-105])
        self.assertEqual(fields[-1]['parameters'],[233,234])
        self.assertEqual(encode(fields),raw)

    def test_signed_offset_and_nibble_updates(self):
        fields = decode(bytes(512))
        fields[15]['relative_offsets'] = [-128,127]
        fields[15]['style_nibbles'] = [15,10]
        raw = encode(fields)
        self.assertEqual(raw[500:504],bytes([0xAF,0,0,255]))
        self.assertEqual(raw[:480],bytes(480))

    def test_unreviewed_bytes_and_invalid_fields_rejected(self):
        for raw in (bytes(511),bytes(513),bytes(31)+b'\x01'+bytes(480)):
            with self.assertRaises(ValueError):
                decode(raw)
        for key,value in [('bounds',[[0]*4]*4),('style_nibbles',[16,0]),
                          ('relative_offsets',[-129,0]),('drawing_value',True),
                          ('padding',[0,0,0,0,0,1])]:
            fields = decode(bytes(512))
            fields[0][key] = value
            with self.assertRaises(ValueError):
                encode(fields)


if __name__ == '__main__':
    unittest.main()
