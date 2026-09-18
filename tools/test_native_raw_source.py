#!/usr/bin/env python3
"""Raw overlays must not hide bytes behind unsupported code/data assumptions."""
import unittest

from native_raw_source import analyze


def roots(offset=0):
    return dict(roots=[dict(offset=offset, evidence='Test caller')])


class RawNativeTests(unittest.TestCase):
    def test_fixed_address_call_and_backward_branch(self):
        # JSR $2006; BNE back to entry; RTS; helper RTS.
        result = analyze(bytes.fromhex('20 06 20 d0 fb 60 60'), 0x2000, roots())
        self.assertEqual(result['instruction_count'], 4)
        self.assertEqual(result['coverage_bytes'], {'code': 7})

    def test_unreachable_bytes_are_not_automatically_data(self):
        with self.assertRaisesRegex(ValueError, 'Unclassified'):
            analyze(bytes.fromhex('60 41 42'), 0x2000, roots())
        recipe = roots()
        recipe['data'] = [dict(offset=1, size=2, kind='table', evidence='Test table consumer')]
        self.assertEqual(analyze(bytes.fromhex('60 41 42'), 0x2000, recipe)['coverage_bytes'],
                         {'code': 1, 'data': 2})

    def test_branch_into_operand_or_declared_data_is_rejected(self):
        with self.assertRaisesRegex(ValueError, 'overlap|operand'):
            analyze(bytes.fromhex('d0 01 a9 ea 60'), 0x2000, roots())
        recipe = roots()
        recipe['data'] = [dict(offset=4, size=1, kind='table', evidence='Test data')]
        with self.assertRaisesRegex(ValueError, 'data'):
            analyze(bytes.fromhex('d0 02 ea 60 60'), 0x2000, recipe)

    def test_external_transfers_and_code_roots_require_evidence(self):
        with self.assertRaisesRegex(ValueError, 'requires evidence'):
            analyze(bytes.fromhex('4c 00 c6'), 0x2000, roots())
        recipe = roots()
        recipe['external_targets'] = {str(0xC600): 'Test firmware entry'}
        self.assertEqual(analyze(bytes.fromhex('4c 00 c6'), 0x2000, recipe)['coverage_bytes'], {'code': 3})
        with self.assertRaisesRegex(ValueError, 'roots require evidence'):
            analyze(b'\x60', 0x2000, dict(roots=[dict(offset=0)]))
        with self.assertRaisesRegex(ValueError, 'Indirect'):
            analyze(bytes.fromhex('6c 00 20'), 0x2000, roots())


if __name__ == '__main__':
    unittest.main()
