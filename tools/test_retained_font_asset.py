#!/usr/bin/env python3
import unittest

from disk_layout import ROOT,block_bytes
from retained_font_asset import classify


class RetainedFontTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.font=(ROOT/'assets/font/font.bin').read_bytes()
        cls.raw=block_bytes((ROOT/'build/disks/sundog-disk2-util.dsk').read_bytes(),80,81)

    def test_full_record_relation_and_blank_slots(self):
        rows=classify(self.raw,self.font)
        self.assertEqual(len(rows),64)
        self.assertTrue(all(row==[0]*8 for row in rows[3:8]))
        for i in list(range(3))+list(range(8,64)):
            self.assertEqual(rows[i],[v&127 for v in reversed(self.font[i*8:i*8+8])])

    def test_unreviewed_pixels_high_bits_and_donor_changes_rejected(self):
        for offset,mask in [(0,1),(3*8,1),(63*8,128)]:
            changed=bytearray(self.raw)
            changed[offset]^=mask
            with self.subTest(offset=offset),self.assertRaisesRegex(ValueError,'donor mapping'):
                classify(changed,self.font)
        with self.assertRaisesRegex(ValueError,'64 eight-byte'):
            classify(self.raw[:-1],self.font)
        changed=bytearray(self.font)
        changed[0]^=128
        with self.assertRaisesRegex(ValueError,'donor differs'):
            classify(self.raw,changed)


if __name__=='__main__':
    unittest.main()
