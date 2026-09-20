#!/usr/bin/env python3
import unittest

from native_block_tail import classify, declarations


def fixture(name):
    raw = bytearray(512)
    if name=='raw_screen_init':
        raw[306:314]=bytes.fromhex('32 01 00 00 02 00 01 01')
    else:
        raw[93:96]=bytes.fromhex('6c 04 00')
        raw[104:112]=bytes.fromhex('68 00 00 00 02 00 01 01')
    return raw


class NativeBlockTailTests(unittest.TestCase):
    def test_native_containers_and_unused_transfer_are_distinguished(self):
        raw = fixture('raw_screen_init')
        report = classify(raw,'raw_screen_init')
        self.assertEqual((report['code_bytes'],report['data_bytes']),(0,215))
        self.assertEqual(report['relocation']['tables_start'],298)
        raw = fixture('raw_buffer_transform')
        report = classify(raw,'raw_buffer_transform')
        self.assertEqual((report['code_bytes'],report['data_bytes']),(3,416))
        self.assertIn('jmp ($0004)',declarations(raw,report))
        self.assertEqual(report['items'][-1]['offset'],112)
        self.assertEqual(report['items'][-1]['size'],400)

    def test_nonzero_tail_and_alignment_are_never_absorbed_as_padding(self):
        for name,offset in [('raw_screen_init',297),('raw_screen_init',314),('raw_buffer_transform',112),('raw_buffer_transform',511)]:
            raw=fixture(name);raw[offset]=0x60
            with self.subTest(name=name,offset=offset),self.assertRaisesRegex(ValueError,'Nonzero'):
                classify(raw,name)

    def test_changed_transfer_and_footer_are_rejected(self):
        for offset,value in [(93,0x4c),(94,6),(104,0x67),(108,4),(96,1)]:
            raw=fixture('raw_buffer_transform');raw[offset]=value
            with self.subTest(offset=offset),self.assertRaises(ValueError):
                classify(raw,'raw_buffer_transform')


if __name__=='__main__':
    unittest.main()
