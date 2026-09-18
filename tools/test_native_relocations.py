#!/usr/bin/env python3
"""Native relocation bounds tests independent of original disk images."""
import struct
import unittest

from native_relocations import native_relocations


class NativeRelocationsTests(unittest.TestCase):
    def fixture(self):
        body = bytearray(8)
        struct.pack_into('<H', body, 1, 0x1234)
        # From low addresses: interpreter count, procedure pointer/count,
        # segment count, global count, entry pointer, native attributes.
        data = body + struct.pack('<HHHHHH', 0, 9, 1, 0, 0, 18) + bytes([0, 1])
        proc = dict(representation='native-6502', entry_offset=0, attribute_offset=20)
        return data, proc

    def test_four_lists_and_backward_pointer(self):
        data, proc = self.fixture()
        report = native_relocations(data, proc)
        self.assertEqual(report['tables_start'], 8)
        self.assertEqual([g['kind'] for g in report['groups']], ['global', 'segment', 'procedure', 'interpreter'])
        self.assertEqual(report['groups'][2]['pointers'], [dict(offset=10, target=1, original_word=0x1234)])

    def test_count_cannot_consume_code_before_entry(self):
        data, proc = self.fixture()
        struct.pack_into('<H', data, 16, 100)
        with self.assertRaisesRegex(ValueError, 'count exceeds'):
            native_relocations(data, proc)

    def test_target_cannot_enter_relocation_metadata(self):
        data, proc = self.fixture()
        struct.pack_into('<H', data, 10, 0)
        with self.assertRaisesRegex(ValueError, 'outside native'):
            native_relocations(data, proc)


if __name__ == '__main__':
    unittest.main()
