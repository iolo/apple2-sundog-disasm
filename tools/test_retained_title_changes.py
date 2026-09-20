import random
import unittest

from disk_layout import ROOT, block_bytes
from retained_title_changes import RANGES, classify, decode_symbols, differential_symbols


class RetainedTitleChangesTests(unittest.TestCase):
    def fixture(self):
        donor = (ROOT/'assets/title/title.hgr').read_bytes()
        block = block_bytes((ROOT/'build/disks/sundog-disk1-game.dsk').read_bytes(),83,84)
        return block,donor

    def test_six_and_two_full_byte_round_trip_and_invalid_symbols(self):
        randomizer = random.Random(83)
        fixtures = [bytes(256),bytes([255])*256,bytes(range(256)),
                    bytes(randomizer.randrange(256) for _ in range(256))]
        for raw in fixtures:
            symbols = differential_symbols(raw)
            self.assertEqual(decode_symbols(symbols),raw)
            bad = bytearray(symbols)
            bad[342] ^= 1
            with self.assertRaisesRegex(ValueError,'checksum'):
                decode_symbols(bad)
        with self.assertRaises(ValueError):
            decode_symbols(bytes([64])*343)

    def test_spatial_model_covers_changed_pixels_and_excludes_control(self):
        block,donor = self.fixture()
        records,sectors = classify(block,donor)
        self.assertEqual(len(records),252)
        self.assertEqual(sum(s['changed_symbols'] for s in sectors),16)
        for start,end in RANGES:
            for offset in range(start,end):
                changed = bytearray(block)
                changed[offset] ^= 1
                with self.subTest(offset=offset),self.assertRaises(ValueError):
                    classify(changed,donor)
        changed = bytes(v^255 for v in block[:8])+block[8:]
        self.assertEqual(classify(changed,donor),(records,sectors))
        # Phase is a separate HGR field, not guessed by the differential model.
        changed = bytearray(block)
        changed[88] ^= 128
        actual,_ = classify(changed,donor)
        self.assertEqual(actual[0]['pixels'],records[0]['pixels'])
        self.assertNotEqual(actual[0]['phase'],records[0]['phase'])


if __name__ == '__main__':
    unittest.main()
