"""Check the search transformations independently of external research corpora."""
import unittest

from probe_unresolved_tails import bitstreams, signature, windows


class ProbeTests(unittest.TestCase):
    def test_cross_byte_shifts_and_bit_reversal(self):
        variants = list(bitstreams(bytes.fromhex('123456')))
        self.assertEqual(len(variants), 28)
        indexed = {(p['reverse_bits'], p['shift'], p['direction']): d
                   for p, d in variants}
        self.assertEqual(indexed[False, 4, 'left'], bytes.fromhex('2345'))
        self.assertEqual(indexed[False, 4, 'right'], bytes.fromhex('4163'))
        self.assertEqual(indexed[True, 1, 'left'], bytes.fromhex('9058'))

    def test_signatures_preserve_constant_transforms(self):
        raw = bytes.fromhex('fe03a700821f')
        self.assertEqual(signature(raw, 'xor'),
                         signature(bytes(b ^ 173 for b in raw), 'xor'))
        self.assertEqual(signature(raw, 'sub'),
                         signature(bytes((b+253) & 255 for b in raw), 'sub'))
        self.assertNotEqual(signature(raw, 'sub'),
                            signature(bytes(b ^ 173 for b in raw), 'sub'))
        with self.assertRaises(ValueError):
            signature(raw, 'typo')

    def test_window_boundaries_include_last_complete_window(self):
        self.assertEqual(list(windows(b'abc', 2)), [(0, b'ab'), (1, b'bc')])
        self.assertEqual(list(windows(b'abc', 3)), [(0, b'abc')])
        self.assertEqual(list(windows(b'abc', 4)), [])


if __name__ == '__main__':
    unittest.main()
