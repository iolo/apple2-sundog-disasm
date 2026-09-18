#!/usr/bin/env python3
"""Raw overlays must not hide bytes behind unsupported code/data assumptions."""
import unittest
from pathlib import Path
import subprocess
import tempfile

from native_raw_source import analyze, source


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
        partial = analyze(bytes.fromhex('60 41 42'), 0x2000, roots(), inspect_gaps=True)
        self.assertEqual(partial['unclassified_offsets'], [1,2])
        with self.assertRaisesRegex(ValueError, 'unclassified'):
            source(bytes.fromhex('60 41 42'), partial)
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

    def test_reviewed_bit_overlap_keeps_both_instruction_entries(self):
        # Branch enters SBC; the other path BIT-skips those same two bytes.
        raw = bytes.fromhex('b0 01 2c e9 38 60')
        recipe = roots()
        with self.assertRaisesRegex(ValueError, 'overlap|operand'):
            analyze(raw, 0x2000, recipe)
        recipe['bit_overlaps'] = [dict(offset=2, hex='2ce938', evidence='Two evidenced control-flow paths')]
        report = analyze(raw, 0x2000, recipe)
        self.assertEqual(report['coverage_bytes'], {'code': 6})
        self.assertEqual(report['instruction_count'], 4)
        self.assertEqual(next(i for i in report['items'] if i['offset']==2)['instruction_size'], 3)
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root/'test.s').write_text(source(raw, report))
            (root/'test.cfg').write_text('MEMORY { M: start = $2000, size = 6, file = %O; }\nSEGMENTS { RAW_NATIVE: load = M, type = ro; }\n')
            subprocess.run(['ca65', str(root/'test.s'), '-o', str(root/'test.o')], check=True)
            subprocess.run(['ld65', '-C', str(root/'test.cfg'), str(root/'test.o'), '-o', str(root/'test.bin')], check=True)
            self.assertEqual((root/'test.bin').read_bytes(), raw)
        recipe['bit_overlaps'][0]['hex'] = '2ce939'
        with self.assertRaisesRegex(ValueError, 'bytes or evidence'):
            analyze(raw, 0x2000, recipe)


if __name__ == '__main__':
    unittest.main()
