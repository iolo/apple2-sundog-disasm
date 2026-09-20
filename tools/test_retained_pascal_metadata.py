#!/usr/bin/env python3
"""Check structural metadata boundaries without claiming overwritten prefixes."""
import unittest

from disk_layout import ROOT, block_bytes
from retained_pascal_metadata import directory_fragment, header_fragment, declarations


class RetainedMetadataTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        image = (ROOT/'build/disks/sundog-disk1-game.dsk').read_bytes()
        cls.directory = block_bytes(image,117,118)
        cls.header = block_bytes(image,259,260)

    def test_directory_records_include_cleared_names_and_clipped_date(self):
        report = directory_fragment(self.directory)
        self.assertEqual(sum(i['size'] for i in report['items']),418)
        self.assertEqual([r['name_length'] for r in report['records']], [14,13,13,10,0,0,0,0,0])
        self.assertEqual(report['records'][4]['type_storage'],0xa762)
        self.assertIn('.word $00FE,$0140,$A762', declarations(self.directory,report,'test'))
        changed = bytearray(self.directory)
        changed[:94] = bytes([0xea])*94
        self.assertEqual(directory_fragment(changed),report)

    def test_header_origin_and_clipped_comment_capacity(self):
        report = header_fragment(self.header)
        self.assertEqual((report['start'],report['end']), (170,512))
        self.assertEqual(report['missing_prefix_bytes'],158)
        self.assertEqual(report['missing_suffix_bytes'],12)
        self.assertEqual(report['intrinsic_segments'],[2,6])
        self.assertEqual(sum(i['size'] for i in report['items']),342)
        self.assertIn('.dword $00000044',declarations(self.header,report,'test'))
        changed = bytearray(self.header)
        changed[:170] = bytes([0xea])*170
        self.assertEqual(header_fragment(changed),report)

    def test_signatures_lengths_and_zero_storage_are_not_generalized(self):
        for original,parser,offsets in [(self.directory,directory_fragment,[94,102,103,206,327,330,511]),
                                        (self.header,header_fragment,[170,204,236,268,300,304,444,511])]:
            for offset in offsets:
                changed = bytearray(original)
                changed[offset] ^= 1
                with self.subTest(parser=parser.__name__,offset=offset),self.assertRaises(ValueError):
                    parser(changed)
            with self.assertRaises(ValueError):
                parser(original[:-1])


if __name__ == '__main__':
    unittest.main()
