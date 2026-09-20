#!/usr/bin/env python3
import unittest

from map_prefix_asset import WORLD_SPECIAL, expected_prefix, pack, unpack


class MapPrefixTests(unittest.TestCase):
    def test_all_reviewed_record_identities_round_trip(self):
        count,size = 0,0
        for kind,variant,number,width in [('world','play',18,16),('world','demo',2,16),('city','play',60,8),('city','demo',4,8)]:
            for index in range(number):
                raw = expected_prefix(kind,variant,index)
                self.assertEqual(pack(unpack(raw,kind,variant,index),width),raw)
                count += 1
                size += width
        self.assertEqual((count,size),(84,832))
        self.assertEqual(expected_prefix('world','play',1),b'\x08\x07'+WORLD_SPECIAL)
        self.assertEqual(expected_prefix('city','play',59),b'\x11'*8)

    def test_changed_patterns_and_unreviewed_identities_are_rejected(self):
        for raw in (b'\x08\x07'+bytes(13)+b'\x01', b'\x08\x07'+bytes(13)):
            with self.assertRaisesRegex(ValueError,'reviewed'):
                unpack(raw,'world','play',0)
        for args in [('world','demo',2),('city','play',60),('world','play',-1),('other','play',0)]:
            with self.assertRaisesRegex(ValueError,'identity'):
                expected_prefix(*args)
        with self.assertRaisesRegex(ValueError,'pattern'):
            unpack(expected_prefix('city','play',0),'city','play',1)

    def test_field_widths_and_byte_bounds_are_checked(self):
        for fields,size in [(dict(first_word=-1,remaining_bytes=[0]*6),8),
                            (dict(first_word=65536,remaining_bytes=[0]*6),8),
                            (dict(first_word=1,remaining_bytes=[0]*5),8),
                            (dict(first_word=1,remaining_bytes=[0]*5+[256]),8),
                            (dict(first_word=1,remaining_bytes=[0]*6),16)]:
            with self.assertRaisesRegex(ValueError,'Invalid'):
                pack(fields,size)


if __name__ == '__main__':
    unittest.main()
