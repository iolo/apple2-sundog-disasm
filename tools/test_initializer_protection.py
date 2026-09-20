#!/usr/bin/env python3
"""Keep retained patch fragments distinct from adjacent table data."""
import unittest

from check_native_init import audit
from disk_layout import ROOT
from initializer_protection import audit_payload, consumer_evidence


class InitializerProtectionTests(unittest.TestCase):
    def setUp(self):
        folder = ROOT / 'build/disks/components'
        self.initializer = (folder / 'native_init.bin').read_bytes()
        self.io = (folder / 'native_io.bin').read_bytes()

    def test_complete_classification_and_independent_disassembly(self):
        report = audit(self.initializer, self.io)
        self.assertEqual((report['instruction_count'], report['instruction_bytes'],
                          report['instruction_fragment_bytes'], report['data_bytes']),
                         (515, 1064, 1, 215))
        payload = report['fortran_protection']
        self.assertEqual(payload['unresolved_ranges'], [])
        self.assertEqual([i['value'] for i in payload['items'] if i['kind'] == 'patch-site-address'],
                         [0xd2c0, 0xd55c, 0xd37a, 0xd20f])
        fragment = next(i for i in payload['items'] if i['kind'] == 'opcode-fragment')
        self.assertEqual((fragment['offset'], fragment['size']), (13, 1))
        completed = payload['patches'][1]['completed_instructions']
        self.assertEqual([(i['mnemonic'], i['operand_value']) for i in completed],
                         [('lda', 0x46), ('sta', 0xcf)])

    def test_copy_boundaries_templates_and_retained_operand_are_checked(self):
        for offset in (0x163, 0x165, 0x168, 0x16e, 0x173, 0x188, 0x190, 0x195, 0x19c, 0x1b1):
            changed = bytearray(self.initializer)
            changed[offset] ^= 1
            with self.subTest(offset=offset), self.assertRaises(ValueError):
                audit_payload(bytes(changed), self.io)
        changed = bytearray(self.io)
        changed[0x55f] = 0xce
        with self.assertRaisesRegex(ValueError, 'retained STA operand'):
            audit_payload(self.initializer, bytes(changed))

    def test_external_evidence_is_optional_but_not_interchangeable(self):
        self.assertFalse(audit_payload(self.initializer, self.io)['external_file_verified'])
        with self.assertRaisesRegex(ValueError, 'compiler hash or size'):
            consumer_evidence(bytes(46592))


if __name__ == '__main__':
    unittest.main()
