import unittest

from dialogue_script import parse_record, analyze_bank


def fixture(raw,offset=18):
    bank = bytearray(512)
    bank[0] = 18
    bank[17] = 100
    bank[offset:offset+len(raw)] = raw
    return bank


class DialogueScriptTests(unittest.TestCase):
    def test_conditional_transfer_exits_before_text(self):
        # Disk 2 block 92 entry zero: two destinations, one predicate.
        record = parse_record(fixture(bytes.fromhex('20 00 0c 80 38 36')),18)
        self.assertTrue(record['early_exit'])
        self.assertEqual(record['end'],24)
        self.assertEqual(record['state_values'],[54,128])
        self.assertEqual(record['text_words'],[])
        self.assertEqual([u['operation'] for u in record['units']],
                         ['begin','state_conditional','test','default'])

    def test_mood_selection_overrides_and_action(self):
        # Block 90 entry zero selects among three texts with a leading condition,
        # one reply override and a four-operand action.
        raw = bytes.fromhex('86 d0 15 59 5c 5f 62 00 14 0a 11 03 10 12 08 09')
        record = parse_record(fixture(raw),18)
        self.assertEqual(record['end'],34)
        self.assertEqual(record['text_words'],[92,95,98])
        self.assertEqual(record['units'][-1]['operation'],'action3')
        self.assertEqual(record['units'][-1]['operands'],[16,18,8,9])
        # A separate record has conditional replacements on each base transition.
        raw = bytes.fromhex('91 01 14 66 6a 70 00 02 13 00 02 13 01 10')
        record = parse_record(fixture(raw),18)
        self.assertEqual(record['end'],32)
        self.assertEqual(record['text_words'],[102,106,112])
        self.assertEqual(sum(u['operation']=='override' for u in record['units']),2)

    def test_entry_inside_record_and_text_overlap_rejected(self):
        bank = fixture(bytes.fromhex('01 00 40 00 00'))
        bank[128:132] = b'\x02hi\x00'
        audit = analyze_bank(bank)
        self.assertEqual(audit['text_records'],[dict(offset=128,end=132,length=2,alignment_bytes=1)])
        bank[1] = 20
        with self.assertRaises(ValueError):
            analyze_bank(bank)
        bank[1] = 0
        bank[20] = 9 # text selector would be read as nine values, crossing metadata/text
        with self.assertRaises(ValueError):
            analyze_bank(bank)

    def test_bad_action_zero_selector_and_alignment_rejected(self):
        for raw in (bytes.fromhex('80 00 40 00 00 08'),bytes.fromhex('01 00 00')):
            with self.assertRaises(ValueError):
                parse_record(fixture(raw),18)
        bank = fixture(bytes.fromhex('01 00 40 00 00'))
        bank[128:132] = b'\x02hi\x01'
        with self.assertRaises(ValueError):
            analyze_bank(bank)


if __name__ == '__main__':
    unittest.main()
