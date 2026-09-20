#!/usr/bin/env python3
import unittest

from disk_layout import ROOT, block_bytes
from retained_compiler_heap import BASE, classify, verify_constructor


class CompilerHeapTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.raw=block_bytes((ROOT/'build/disks/sundog-disk1-game.dsk').read_bytes(),258,259)

    def test_symbol_and_parameter_links_resolve_to_typed_records(self):
        report=classify(self.raw)
        records={i['offset']:i for i in report['items']}
        self.assertEqual(sum(i['size'] for i in records.values()),460)
        self.assertEqual(report['complete_symbols'],11)
        self.assertEqual(report['complete_parameters'],9)
        self.assertEqual(records[106]['next_parameter'],records[78]['address'])
        self.assertEqual(records[128]['next_parameter'],records[78]['address'])
        self.assertEqual(records[78]['idtype'],records[100]['address'])
        self.assertEqual(records[370]['next_parameter'],records[326]['address'])
        self.assertEqual(records[326]['next_parameter'],records[348]['address'])
        self.assertEqual(records[56]['next_parameter'],BASE+34)
        self.assertEqual(records[52]['missing_prefix_bytes'],18)
        self.assertEqual(records[502]['missing_suffix_bytes'],12)

    def test_changed_names_links_classes_and_pointer_layout_rejected(self):
        for offset,reason in [(56,'symbol name'),(120,'parameter link'),
                              (90,'parameter type'),(354+8,'parameter type'),
                              (100,'pointer-type'),(502,'Clipped compiler')]:
            changed=bytearray(self.raw)
            changed[offset]^=1
            with self.subTest(offset=offset),self.assertRaisesRegex(ValueError,reason):
                classify(changed)

    def test_retained_field_changes_require_review_and_external_file_is_checked(self):
        changed=bytearray(self.raw)
        changed[:52]=bytes(52)
        self.assertEqual(classify(changed),classify(self.raw))
        changed[78]^=1
        with self.assertRaisesRegex(ValueError,'reviewed snapshot'):
            classify(changed)
        with self.assertRaisesRegex(ValueError,'containing block'):
            classify(self.raw[:-1])
        with self.assertRaisesRegex(ValueError,'External compiler allocation'):
            verify_constructor(b'not the reviewed compiler')


if __name__=='__main__':
    unittest.main()
