import unittest

from dialogue_bank_remainder import inspect


def bank_fixture():
    bank = bytearray(512)
    bank[0] = 18
    bank[16:18] = bytes([1,16])
    bank[18:23] = bytes.fromhex('01 00 40 00 00')
    bank[32:128] = bytes([95])+b'a'*95
    bank[128:384] = bytes([255])+b'b'*255
    bank[384:512] = bytes([127])+b'c'*127
    return bank


class DialogueBankTests(unittest.TestCase):
    def test_complete_record_walk_finds_unused_message(self):
        result = inspect(bank_fixture())
        self.assertEqual(result['spare_range'],[23,32])
        self.assertEqual(result['message_start'],128)
        self.assertEqual(result['message_end'],512)
        self.assertEqual(result['unreferenced_messages'],
                         [dict(offset=384,end=512,length=127,alignment_bytes=0)])

    def test_nonzero_gap_incomplete_text_and_wrong_reference_rejected(self):
        for offset,value in [(24,1),(384,128),(384,0),(20,65)]:
            with self.subTest(offset=offset,value=value):
                bank = bank_fixture()
                bank[offset] = value
                with self.assertRaises(ValueError):
                    inspect(bank)


if __name__=='__main__':
    unittest.main()
