import copy
import unittest

from disk_layout import ROOT
from packed_hgr_asset import decode, encode
from packed_image_storage import LAYOUTS, classify


class PackedImageStorageTests(unittest.TestCase):
    def fixture(self, kind):
        path = ('assets/ship-images/ship_section/image.rle' if kind=='ship_section'
                else 'assets/play-boot/image.rle')
        payload = (ROOT/path).read_bytes()
        layout = LAYOUTS[kind]
        raw = payload+bytes([layout['retained_control']])+bytes(layout['allocation']-len(payload)-1)
        return payload, raw

    def test_storage_is_not_consumed_or_admitted_to_image_encoder(self):
        for kind in LAYOUTS:
            payload, raw = self.fixture(kind)
            report = classify(raw,kind,payload)
            page, description, consumed = decode(raw)
            self.assertEqual(consumed,len(payload))
            self.assertEqual(report['classified_bytes'],len(raw)-len(payload))
            altered_tail = payload+bytes([255])*(len(raw)-len(payload))
            self.assertEqual(decode(altered_tail),(page,description,consumed))
            extended = copy.deepcopy(description)
            extended['packets'].append(dict(control=raw[consumed],payload='00'))
            with self.assertRaisesRegex(ValueError,'terminal extent'):
                encode(extended)

    def test_boundary_and_storage_changes_require_new_review(self):
        for kind in LAYOUTS:
            payload, raw = self.fixture(kind)
            for changed in (raw[:-1],raw+b'\0',bytes([raw[0]^1])+raw[1:]):
                with self.subTest(kind=kind),self.assertRaises(ValueError):
                    classify(changed,kind,payload)
            for offset in range(len(payload),len(raw)):
                changed = bytearray(raw)
                changed[offset] ^= 1
                with self.subTest(kind=kind,offset=offset),self.assertRaises(ValueError):
                    classify(changed,kind,payload)


if __name__ == '__main__':
    unittest.main()
