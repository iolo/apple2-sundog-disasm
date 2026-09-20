import unittest

from disk_layout import ROOT
from retained_title_asset import RANGES, classify


class RetainedTitleTests(unittest.TestCase):
    def test_pixels_phase_holes_and_boundaries(self):
        donor = (ROOT/'assets/title/title.hgr').read_bytes()
        raw = (ROOT/'assets/retained-title/fragments.bin').read_bytes()
        records = classify(raw, donor)
        self.assertEqual(sum(r['kind'] == 'pixels' for r in records), 244)
        self.assertEqual(sum(r['kind'] == 'hgr-hole' for r in records), 8)
        self.assertEqual(sum(r.get('phase') != r.get('donor_phase') for r in records), 61)
        offsets = {r['block_offset'] for r in records}
        self.assertEqual(offsets, set(range(8,88)) | set(range(90,165)) | set(range(256,353)))
        self.assertEqual(RANGES, ((8,88),(90,165),(256,353)))
        for bit in (1,128):
            for position in range(len(raw)):
                changed = bytearray(raw)
                changed[position] ^= bit
                with self.subTest(bit=bit, position=position), self.assertRaises(ValueError):
                    classify(bytes(changed), donor)
        for changed in (raw[:-1], raw+b'\x00'):
            with self.assertRaises(ValueError):
                classify(changed, donor)
        with self.assertRaises(ValueError):
            classify(raw, donor[:4096]+donor[:4096])


if __name__ == '__main__':
    unittest.main()
