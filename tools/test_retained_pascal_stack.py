#!/usr/bin/env python3
"""Reject inconsistent string links, activation bounds and unreviewed windows."""
import unittest

from disk_layout import ROOT, block_bytes
from retained_pascal_stack import BASE, classify


class RetainedStackTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.raw=block_bytes((ROOT/'build/disks/sundog-disk1-game.dsk').read_bytes(),260,261)

    def test_independent_chains_and_activation_bounds_share_one_origin(self):
        report=classify(self.raw)
        self.assertEqual(report['window_start'],0xedfa)
        self.assertEqual(report['window_end_exclusive'],0xefe6)
        self.assertEqual(sum(i['size'] for i in report['items']),492)
        nodes=[i for i in report['items'] if i['kind']=='copied-string-node']
        self.assertEqual(len(nodes),14)
        self.assertEqual(nodes[2]['length'],56)
        self.assertEqual(nodes[2]['alignment_bytes'],'ef')
        child,reused,parent=report['frames']
        self.assertEqual(child['dynamic_link'],parent['mark_address'])
        self.assertEqual(reused['dynamic_link'],parent['mark_address'])
        self.assertEqual(child['local_storage_end'],parent['mark_address']-4)
        self.assertEqual(reused['saved_string_head'],BASE+0x1c6)
        self.assertTrue(report['items'][-1]['clipped_at_window_end'])

    def test_changed_links_lengths_and_frame_bounds_fail_structural_checks(self):
        for offset,reason in [(0x1a,'link'),(0x28,'length'),(0x144,'link'),
                              (0x6a,'bounds'),(0x6e,'links'),(0x1b4,'links')]:
            changed=bytearray(self.raw)
            changed[offset]^=1
            with self.subTest(offset=offset),self.assertRaisesRegex(ValueError,reason):
                classify(changed)

    def test_prefix_is_excluded_and_unknown_snapshot_variants_are_rejected(self):
        changed=bytearray(self.raw)
        changed[:20]=bytes([0xea])*20
        self.assertEqual(classify(changed),classify(self.raw))
        changed[0x80]^=1
        with self.assertRaisesRegex(ValueError,'reviewed snapshot'):
            classify(changed)
        with self.assertRaisesRegex(ValueError,'containing block'):
            classify(self.raw[:-1])


if __name__=='__main__':
    unittest.main()
