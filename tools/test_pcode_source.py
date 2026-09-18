#!/usr/bin/env python3
"""P-code boundary tests independent of the original images."""
import struct
import copy
import shutil
import subprocess
import tempfile
from pathlib import Path
import unittest

from pcode_source import analyze, source
from pascal_inventory import procedure_dictionary


def segment(body, exit_offset):
    assert len(body) % 2 == 0
    n = len(body)
    return bytes(body) + struct.pack('<HHHH', 0, 0, n + 4 - exit_offset, n + 6) + bytes([1, 0, 2, 0, 1, 1])


class PcodeSourceTests(unittest.TestCase):
    def test_nonminimal_big_operand_and_signed_word(self):
        data = segment([0xCC, 0x80, 5, 0xC7, 0xFF, 0xFF, 0xAD, 0], 6)
        listing = source(analyze(data, 1))
        self.assertIn('p_stl 5, 2', listing)
        self.assertIn('p_ldci -1', listing)

    def test_case_alignment_and_signed_bounds(self):
        for prefix, padding in (([0, 0xAD, 0], []), ([0, 0, 0xAD, 0], [0xA5])):
            pc = len(prefix)
            default = pc + 1 + len(padding) + 4
            target = pc - 2
            pointers = b''.join(struct.pack('<H', default + 2 + i * 2 - target) for i in range(3))
            body = bytes(prefix + [0xAC] + padding) + struct.pack('<hh', -1, 1) + bytes([0xB9, 6]) + pointers + bytes([0xAD, 0])
            report = analyze(segment(body, pc), 1)
            self.assertEqual(report['coverage_bytes']['case-pointer'], 6)
            self.assertIn(f'p_xjp -1, 1, {len(padding)}, ${padding[0] if padding else 0:02X}', source(report))

    def test_branch_into_operand_rejected(self):
        data = segment([0xA1, 1, 0xC7, 1, 0, 0xAD, 0, 0], 5)
        with self.assertRaisesRegex(ValueError, 'operand'):
            analyze(data, 1)

    def test_case_pointer_subtraction_wraps_at_16_bits(self):
        # XJP at 3; default and every case reach RNP at 16. Case words therefore
        # store wrapped negative differences rather than backward distances.
        body = bytes([0, 0xAD, 0, 0xAC]) + struct.pack('<hh', 0, 2) + bytes([0xB9, 6])
        body += b''.join(struct.pack('<H', (p - 16) & 0xFFFF) for p in (10, 12, 14))
        body += bytes([0xAD, 0])
        report = analyze(segment(body, 3), 1)
        self.assertEqual([i['target'] for i in report['items'] if i['kind'] == 'case-pointer'], [16, 16, 16])

    def test_backward_pointer_and_selector_validation(self):
        body = [0, 0xA1, 0xF6, 0xAD, 0, 0, 6, 0]
        report = analyze(segment(body, 3), 1)
        self.assertEqual(report['coverage_bytes']['jump-pointer'], 2)
        self.assertIn((1, 0), report['control_flow_edges'])
        body[2] = 0xF7
        with self.assertRaisesRegex(ValueError, 'jump-table selector'):
            analyze(segment(body, 3), 1)

    def test_unsupported_and_truncated_encodings_rejected(self):
        for body, exit_offset, message in (([0x81, 0xAD, 0, 0], 1, 'Unsupported opcode'),
                                           ([0xCC, 0x80], 0, 'Truncated operand')):
            with self.subTest(body=body), self.assertRaisesRegex(ValueError, message):
                analyze(segment(body, exit_offset), 1)

    def test_inline_bytes_are_data_not_instructions(self):
        for opcode, kind in ((0xA6, 'string-data'), (0xD0, 'packed-array-data')):
            body = [opcode, 4, 0x81, 0xAD, 0, 0xFF, 0xAD, 0]
            report = analyze(segment(body, 6), 1)
            self.assertEqual(report['instruction_count'], 2)
            self.assertEqual(report['coverage_bytes'][kind], 4)
            self.assertEqual(report['control_flow_edges'], [(0, 6)])
        # Forward branch targets a byte owned by the LSA payload.
        with self.assertRaisesRegex(ValueError, 'Overlapping|operand'):
            analyze(segment([0xA1, 3, 0xA6, 2, 0x81, 0, 0xAD, 0], 6), 1)
        with self.assertRaisesRegex(ValueError, 'Inline data'):
            analyze(segment([0xA6, 4, 0xAD, 0], 2), 1)

    def test_constant_words_align_after_count(self):
        for prefix in ([], [0]):
            padding = [0xA5] if prefix else []
            body = prefix + [0xB3, 2] + padding + [0x81, 0xFF, 0x34, 0x12, 0xAD, 0]
            report = analyze(segment(body, len(body) - 2), 1)
            self.assertEqual(report['coverage_bytes']['constant-words'], 4)
            self.assertIn('.word $FF81, $1234', source(report))
            self.assertIn(f'p_ldc 2, {len(prefix)}, ${0xA5 if prefix else 0:02X}', source(report))
        for count in (0, 127, 255):
            with self.assertRaisesRegex(ValueError, 'constant-word count'):
                analyze(segment([0xB3, count, 0xAD, 0], 2), 1)

    def test_typed_comparisons_and_short_loads(self):
        body = [0xAF, 4, 0xB7, 10, 0x80, 3, 0xE8, 0xF7, 0xF8, 0xFF, 0xAD, 0]
        listing = source(analyze(segment(body, 10), 1))
        for expected in ('p_equ 4', 'p_neq 10, 3, 2', 'p_sldo 1', 'p_sldo 16', 'p_sind 0', 'p_sind 7'):
            self.assertIn(expected, listing)
        with self.assertRaisesRegex(ValueError, 'comparison type'):
            analyze(segment([0xAF, 3, 0xAD, 0], 2), 1)

    @unittest.skipUnless(shutil.which('ca65') and shutil.which('ld65'), 'cc65 required')
    def test_extended_formats_assemble_to_original_bytes(self):
        bodies = [
            [0xA6, 4, 0x81, 0xAD, 0, 0xFF, 0xAD, 0],
            [0xD0, 4, 0x81, 0xAD, 0, 0xFF, 0xAD, 0],
            [0xB3, 2, 0x81, 0xFF, 0x34, 0x12, 0xAD, 0],
            [0, 0xB3, 2, 0xA5, 0x81, 0xFF, 0x34, 0x12, 0xAD, 0],
            [0xAF, 4, 0xB7, 10, 0x80, 3, 0xE8, 0xF7, 0xF8, 0xFF, 0xAD, 0],
        ]
        include = Path(__file__).resolve().parents[1] / 'src/pcode'
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp)
            for body in bodies:
                data = segment(body, len(body) - 2)
                (path / 'test.s').write_text(source(analyze(data, 1)))
                (path / 'test.cfg').write_text(
                    f'MEMORY {{ IMAGE: start = 0, size = {len(data)}, file = %O; }}\n'
                    'SEGMENTS { PCODE: load = IMAGE, type = ro; }\n')
                subprocess.run(['ca65', '-I', str(include), str(path / 'test.s'), '-o', str(path / 'test.o')], check=True, capture_output=True)
                subprocess.run(['ld65', '-C', str(path / 'test.cfg'), str(path / 'test.o'), '-o', str(path / 'test.bin')], check=True, capture_output=True)
                self.assertEqual((path / 'test.bin').read_bytes(), data)

    def test_reviewed_unreachable_code_is_explicit(self):
        data = segment([0xB9, 2, 0xB9, 0, 0xAD, 0], 4)
        with self.assertRaisesRegex(ValueError, 'Unexplained'):
            analyze(data, 1)
        report = analyze(data, 1, extra_code_roots=[2])
        self.assertEqual(report['instruction_count'], 3)
        self.assertIn('Statically reviewed code root', source(report))
        with self.assertRaisesRegex(ValueError, 'outside procedure'):
            analyze(data, 1, extra_code_roots=[2, 6])
        with self.assertRaisesRegex(ValueError, 'operand|Overlapping'):
            analyze(data, 1, extra_code_roots=[1, 2])

    def test_split_dictionary_uses_distinct_load_addresses(self):
        # Core at $8000, procedure 2 at $4000. The fragment has no dictionary.
        proc1 = bytes([0xAD, 0]) + struct.pack('<HHHHBB', 0, 0, 6, 8, 1, 0)
        fragment = bytes([0xAD, 0]) + struct.pack('<HHHHBB', 0, 0, 6, 8, 2, 0)
        core = proc1 + struct.pack('<HHBB', 0x4002, 4, 1, 2)
        layout = procedure_dictionary(core, 1, load_address=0x8000, fragments=[('fragment', 0x4000, fragment)])
        self.assertTrue(layout['valid'])
        layout['trailer_offset'] = len(core) - 2
        split = layout['procedures'][1]
        for key in ('entry_offset', 'attribute_offset', 'exit_offset', 'attribute_start'):
            split[key] += len(core)
        split['dictionary_address_delta'] = 0x4000 + len(core)
        report = analyze(core + fragment, 1, layout=layout)
        self.assertEqual(sum(report['coverage_bytes'].values()), len(core + fragment))
        self.assertIn('.word (* - L_001C + $4012) & $FFFF', source(report))
        wrong = copy.deepcopy(layout)
        wrong['procedures'][1]['dictionary_address_delta'] += 1
        with self.assertRaisesRegex(ValueError, 'Dictionary address mapping'):
            analyze(core + fragment, 1, layout=wrong)

    def test_unexplained_gap_rejected(self):
        with self.assertRaisesRegex(ValueError, 'Unexplained procedure byte'):
            analyze(segment([0xAD, 0, 0x42, 0], 0), 1)


if __name__ == '__main__':
    unittest.main()
