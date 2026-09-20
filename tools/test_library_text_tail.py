import unittest

from disk_layout import ROOT
from library_text_tail import TEXT, classify


class LibraryTextTailTests(unittest.TestCase):
    def test_complete_module_boundary_and_exact_text_fill_are_required(self):
        module = (ROOT/'build/disks/components/library_22.bin').read_bytes()
        allocation = module+TEXT+bytes(14)
        report = classify(allocation,module)
        self.assertEqual(report['dictionary_start'],5998)
        self.assertEqual(report['text']['offset'],len(module))
        for offset in (0,len(module)-1,*range(len(module),len(allocation))):
            changed = bytearray(allocation)
            changed[offset] ^= 1
            with self.subTest(offset=offset),self.assertRaises(ValueError):
                classify(changed,module)
        for changed in (allocation[:-1],allocation+b'\0'):
            with self.assertRaises(ValueError):
                classify(changed,module)


if __name__ == '__main__':
    unittest.main()
