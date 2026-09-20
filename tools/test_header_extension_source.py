#!/usr/bin/env python3
import unittest

from header_extension_source import PROMPT, classify, declarations


class HeaderExtensionTests(unittest.TestCase):
    def test_intrinsic_bits_and_counted_comment(self):
        raw = bytearray(512)
        raw[288:292] = (0x66400000).to_bytes(4,'little')
        raw[432:437] = b'\x04TEST'
        report = classify(raw,0x66400000)
        self.assertEqual(report['selected_ranges'],[[288,512]])
        self.assertEqual(report['unresolved_offsets'],[])
        self.assertEqual(report['items'][0]['segments'],[22,25,26,29,30])
        self.assertEqual(next(i['text'] for i in report['items'] if i['kind']=='comment-text'),'TEST')
        text = declarations(raw,report['items'],'test')
        self.assertIn('.dword $66400000',text)
        self.assertIn('.res 75, 0',text)

    def test_library_prompt_does_not_absorb_surrounding_unresolved_words(self):
        raw = bytearray(512)
        raw[374:418] = b'\xEA'*44
        raw[418:486] = bytes([len(PROMPT)])+PROMPT
        raw[486:] = b'\x60'*26
        report = classify(raw,0,True)
        self.assertEqual(report['selected_ranges'],[[288,374],[418,486]])
        self.assertEqual(len(report['unresolved_offsets']),70)
        self.assertIn(374,report['unresolved_offsets'])
        self.assertIn(511,report['unresolved_offsets'])
        raw[419] ^= 1
        with self.assertRaisesRegex(ValueError,'prompt'):
            classify(raw,0,True)

    def test_unreviewed_nonzero_storage_invalid_comments_and_masks_fail(self):
        for offset,value in [(292,0xea),(432,80),(511,1)]:
            raw = bytearray(512)
            raw[offset] = value
            with self.subTest(offset=offset),self.assertRaises(ValueError):
                classify(raw,0)
        with self.assertRaisesRegex(ValueError,'mask'):
            classify(bytes(512),1)
        with self.assertRaisesRegex(ValueError,'complete'):
            classify(bytes(511),0)
        raw = bytearray(512)
        raw[432:434] = bytes([1,0xff])
        with self.assertRaisesRegex(ValueError,'comment'):
            classify(raw,0)


if __name__=='__main__':
    unittest.main()
