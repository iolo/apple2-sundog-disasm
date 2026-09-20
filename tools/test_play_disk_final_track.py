#!/usr/bin/env python3
"""Keep final-track evidence bounded to the reviewed container and references."""
import copy
import json
import unittest

from disk_layout import ROOT, logical_sector_offset, sha
from play_disk_final_track import EVIDENCE, classify, reference_track


class FinalTrackTests(unittest.TestCase):
    def test_boundaries_and_neighbor(self):
        evidence = json.loads(EVIDENCE.read_text())
        image = (ROOT/'build/disks/sundog-disk2-util.dsk').read_bytes()
        self.assertEqual(classify(image,evidence)['size'],4096)
        for changed in (image[:-1],image+b'\0'):
            with self.assertRaises(ValueError):
                classify(changed,evidence)
        # Both ends of the claimed fill, its neighbor, and the header length.
        for offset in (139264,143359,139263,logical_sector_offset(280)+15*4+2):
            changed = bytearray(image)
            changed[offset] ^= 1
            with self.assertRaises(ValueError):
                classify(changed,evidence)
        longer = bytearray(image)
        longer[logical_sector_offset(280)+15*4+3] += 2  # +512 bytes, still even
        with self.assertRaises(ValueError):
            classify(longer,evidence)

    def test_raw_track_circular_markers_and_sparse_integrity(self):
        evidence = json.loads(EVIDENCE.read_text())
        self.assertEqual(len(reference_track(evidence)),6656)
        duplicate = copy.deepcopy(evidence)
        duplicate['nibble_reference']['nonfill_bytes'].append(
            duplicate['nibble_reference']['nonfill_bytes'][0])
        with self.assertRaises(ValueError):
            reference_track(duplicate)
        # A marker straddling the track seam must be rejected even with a
        # corresponding updated hash; simple non-circular searches miss it.
        for marker in (bytes.fromhex('d5aa96'),bytes.fromhex('d5aaad')):
            changed = copy.deepcopy(evidence)
            track = bytearray(reference_track(evidence))
            track[-1],track[0],track[1] = marker
            ref = changed['nibble_reference']
            ref['nonfill_bytes'] = [dict(offset=i,value=v) for i,v in enumerate(track) if v != 255]
            ref['track_sha256'] = sha(track)
            with self.assertRaises(ValueError):
                reference_track(changed)


if __name__ == '__main__':
    unittest.main()
