import unittest

from dialogue_dictionary_asset import (base_offsets,decode_base,encode_base,decode_extra,
                                       encode_extra,text_fields,text_bytes)


class DictionaryTests(unittest.TestCase):
    def test_pointer_wraps_empty_entries_and_high_bits(self):
        rows = [b'a'*200,b'ye\xd3',b'',b'b'*255]+[b'']*60
        fields = dict(entries=[text_fields(row) for row in rows])
        raw = encode_base(fields)
        self.assertEqual(list(raw[:5]),[65,9,12,12,11])
        self.assertEqual(base_offsets(raw)[:5],[65,265,268,268,523])
        self.assertEqual(decode_base(raw),fields)
        self.assertEqual(text_bytes(text_fields(bytes(range(256)))),bytes(range(256)))
        with self.assertRaises(ValueError):
            decode_base(raw+b'\x00')

    def test_counted_records_and_word_alignment(self):
        # Both source records start even: odd/even character lengths need
        # respectively zero/one alignment bytes after their length prefix.
        raw = b'\x12\x02\x32'+b'\x03a\xe2C'+b'\x02~|\x00'
        fields = decode_extra(raw)
        self.assertEqual(fields['entries'][0],dict(stored_characters='abC',high_bit_positions=[1]))
        self.assertEqual(encode_extra(fields),raw)
        for bad in (raw[:-1],raw[:-1]+b'\x01',raw+b'\x00',b'\x10'+raw[1:],raw[:2]+b'\xff'+raw[3:]):
            with self.assertRaises(ValueError):
                decode_extra(bad)

    def test_invalid_text_or_pointer_span(self):
        for fields in [dict(stored_characters='x',high_bit_positions=[0,0]),
                       dict(stored_characters='x',high_bit_positions=[1]),
                       dict(stored_characters='é',high_bit_positions=[])]:
            with self.assertRaises(ValueError):
                text_bytes(fields)
        with self.assertRaises(ValueError):
            encode_base(dict(entries=[text_fields(b'a'*256)]+[text_fields(b'')]*63))
        with self.assertRaises(ValueError):
            base_offsets(b'\x41'+b'\xff'*64)


if __name__ == '__main__':
    unittest.main()
