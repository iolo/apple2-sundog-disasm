#!/usr/bin/env python3
"""Check native RLE packet semantics, termination, and lossless preservation."""
import unittest
from packed_hgr_asset import decode, encode


class PackedHgrTests(unittest.TestCase):
    def test_literal_repeat_and_high_bits(self):
        literals = bytes(range(128,256))
        raw = b'\x01\xff' + literals + b'\x7f\x80' * 63
        page, packets, consumed = decode(raw + b'ignored tail')
        self.assertEqual(page, literals + b'\x80' * 8064)
        self.assertEqual(consumed, len(raw))
        self.assertEqual(encode(packets), raw)

    def test_native_stops_mid_packet_at_page_end(self):
        for final in (b'\x7f\xa5', b'\xff\xa5'):
            raw = b'\x01' + b'\x7f\x00' * 63 + b'\x7e\x55' + final
            page, packets, consumed = decode(raw)
            self.assertEqual(page, b'\x00'*8064 + b'\x55'*127 + b'\xa5')
            self.assertEqual(consumed, len(raw))
            self.assertEqual(encode(packets), raw)

    def test_malformed_or_extra_packets_rejected(self):
        for raw in (b'', b'\x02', b'\x01', b'\x01\x7f', b'\x01\xff\x00'):
            with self.assertRaises(ValueError):
                decode(raw)
        _, packets, _ = decode(b'\x01' + b'\x7f\x00' * 64)
        packets['packets'].append(dict(control=0, payload='00'))
        with self.assertRaises(ValueError):
            encode(packets)


if __name__ == '__main__':
    unittest.main()
