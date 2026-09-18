#!/usr/bin/env python3
"""P-code boundary tests independent of the original images."""
import struct
import unittest

from pcode_source import analyze, source


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

    def test_unexplained_gap_rejected(self):
        with self.assertRaisesRegex(ValueError, 'Unexplained procedure byte'):
            analyze(segment([0xAD, 0, 0x42, 0], 0), 1)


if __name__ == '__main__':
    unittest.main()
