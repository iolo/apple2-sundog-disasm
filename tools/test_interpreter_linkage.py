#!/usr/bin/env python3
"""Reject broken linkage fields and consumers despite unchanged component sizes."""
import unittest

from disk_layout import ROOT
from interpreter_linkage import audit_linkage


class LinkageTests(unittest.TestCase):
    def components(self):
        return [(ROOT/'build/disks/components'/f'{name}.bin').read_bytes()
                for name in ('pcode_primitives','native_shared','native_high')]

    def test_fields_and_consumer(self):
        components = self.components()
        report = audit_linkage(*components)
        self.assertEqual(report['unresolved_descriptor_bytes'],0)
        self.assertEqual(len(report['fields']),5)
        for offset in range(0x1ad,0x1b7):
            altered = bytearray(components[0])
            altered[offset] ^= 1
            with self.assertRaises(ValueError):
                audit_linkage(altered,*components[1:])
        # A wrong source pointer, zero-page destination, call operand, or ADC
        # base invalidates the relocation consumer even with an intact table.
        for address in (0xe627,0xe62a,0xe62c,0xe62f,0xe631,0xe420,0xe427):
            altered = bytearray(components[1])
            altered[address-0xe0e5] ^= 1
            with self.assertRaises(ValueError):
                audit_linkage(components[0],altered,components[2])

    def test_targets_and_extents(self):
        components = self.components()
        for index,offset in ((0,0x202),(0,0x2bc),(2,0xff00-0xf790)):
            altered = list(components)
            altered[index] = bytearray(altered[index])
            altered[index][offset] ^= 1
            with self.assertRaises(ValueError):
                audit_linkage(*altered)
        for index in range(3):
            altered = list(components)
            altered[index] = altered[index][:-1]
            with self.assertRaises(ValueError):
                audit_linkage(*altered)


if __name__ == '__main__':
    unittest.main()
