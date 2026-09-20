import unittest

from disk_layout import ROOT
from window_allocation_tail import classify, PREFIX


class WindowTailTests(unittest.TestCase):
    def test_reversible_record_fields_and_bounded_storage(self):
        asset = (ROOT/'assets/interaction-window/window.bin').read_bytes()
        bank = asset[:1920]+bytes(80)+asset[1920:]+bytes(30)+PREFIX
        report = classify(bank,asset)
        self.assertEqual(report['zero_storage_bytes'],110)
        self.assertEqual([f['value'] for f in report['record_fields']],
                         ['INFILE  ',0x484E,0x4822,0x4806,0x333C])
        self.assertTrue(report['missing_variant_fields'])
        for offset in list(range(1920,2000))+list(range(2002,2048))+[1919,2000,2001]:
            changed = bytearray(bank)
            changed[offset] ^= 1
            with self.subTest(offset=offset),self.assertRaises(ValueError):
                classify(changed,asset)
        for changed in (bank[:-1],bank+b'\0'):
            with self.assertRaises(ValueError):
                classify(changed,asset)
        with self.assertRaises(ValueError):
            classify(bank,asset[:-1])


if __name__ == '__main__':
    unittest.main()
