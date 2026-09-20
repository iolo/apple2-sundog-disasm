#!/usr/bin/env python3
"""Check retained native/footer/linker evidence against mutation and clipping."""
import unittest

from disk_layout import ROOT
from native_high_metadata import audit_metadata


class HighMetadataTests(unittest.TestCase):
    def setUp(self):
        self.parts = [(ROOT/'build/disks/components'/f'{name}.bin').read_bytes()
                      for name in ('native_high','native_init','native_io','pcode_primitives','native_shared')]

    def test_stored_records_and_clipped_instruction(self):
        report = audit_metadata(*self.parts)
        self.assertEqual(report['native_container']['procedure']['entry_offset'],0)
        self.assertEqual([r['kind'] for r in report['linker_records']],['SEPPROC','GLOBDEF','EOFMARK'])
        self.assertEqual(report['instruction_fragment']['original_instruction_hex'],'a003')
        self.assertEqual(report['file_version']['value'],3)
        self.assertEqual(report['unresolved_preservation_ranges'],[])

    def test_changed_footers_symbols_version_or_provenance_are_rejected(self):
        for offset in (0,8,10,12,14,16,0x70,0x78,0x7a,0x7e,0x88,0x90,0x98,0xa0,0x26f,0x866):
            changed = self.parts.copy()
            high = bytearray(changed[0]);high[offset] ^= 1;changed[0] = bytes(high)
            with self.subTest(offset=offset),self.assertRaises(ValueError):
                audit_metadata(*changed)
        changed = self.parts.copy()
        init = bytearray(changed[1]);init[0x30f] ^= 1;changed[1] = bytes(init)
        with self.assertRaisesRegex(ValueError,'LDY'):
            audit_metadata(*changed)
        changed = self.parts.copy();changed[-1] = changed[-1][:-1]
        with self.assertRaisesRegex(ValueError,'extents'):
            audit_metadata(*changed)


if __name__ == '__main__':
    unittest.main()
