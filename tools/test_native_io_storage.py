import unittest

from check_native_high import instructions_for
from disk_layout import ROOT
from native_io_storage import audit_storage


class NativeIOStorageTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.raw = (ROOT/'build/disks/components/native_io.bin').read_bytes()
        cls.instructions = instructions_for(cls.raw, 'native_io')

    def test_record_gap_and_bank_tail_have_distinct_evidence(self):
        report = audit_storage(self.raw, self.instructions)
        self.assertEqual(report['state_size'], 6)
        self.assertEqual(report['unused_track_high_byte']['address'], 0xdc91)
        self.assertEqual(report['zero_bank_storage']['size'], 875)
        self.assertEqual(report['historical_consumer_bytes'], 148)
        self.assertEqual(len(report['checked_state_references']), 19)
        self.assertEqual(report['unresolved_preservation_ranges'], [])

    def test_changed_storage_consumers_and_missing_reference_are_rejected(self):
        for offset in (0xc91, 0xc95, 0xfff, 0x26b, 0x27f, 0xf4):
            raw = bytearray(self.raw)
            raw[offset] ^= 1
            with self.subTest(offset=offset), self.assertRaises(ValueError):
                audit_storage(bytes(raw), self.instructions)
        changed = dict(self.instructions)
        del changed[0xd27e]
        with self.assertRaisesRegex(ValueError, 'references'):
            audit_storage(self.raw, changed)
        with self.assertRaises(ValueError):
            audit_storage(self.raw[:-1], self.instructions)


if __name__ == '__main__':
    unittest.main()
