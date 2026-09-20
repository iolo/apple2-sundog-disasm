#!/usr/bin/env python3
import unittest

from disk_layout import ROOT, block_bytes
from retained_command_stack import BASE, classify


class CommandStackTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.raw=block_bytes((ROOT/'build/disks/sundog-disk1-game.dsk').read_bytes(),139,140)

    def test_chain_string_pointer_and_clipped_bounds(self):
        report=classify(self.raw)
        frames=report['complete_frames']
        self.assertEqual(len(frames),4)
        self.assertEqual(report['items'][0]['words'][0],frames[0]['mark_address'])
        for child,parent in zip(frames,frames[1:]):
            self.assertEqual(child['dynamic_link'],parent['mark_address'])
        self.assertEqual(frames[2]['saved_string_head'],BASE+0x19e)
        self.assertEqual(frames[2]['saved_stack_top'],BASE+0x19e)
        self.assertEqual(sum(i['size'] for i in report['items']),184)
        self.assertTrue(report['items'][-1]['clipped_at_end'])

    def test_structure_mutations_fail_before_snapshot_hash(self):
        for offset,reason in [(0x148,'dynamic link'),(0x164,'link'),(0x176,'bound'),
                              (0x18a,'string head'),(0x19e,'header'),(0x1a2,'length'),
                              (0x1a3,'text'),(0x1f4,'link')]:
            changed=bytearray(self.raw)
            changed[offset]^=1
            with self.subTest(offset=offset),self.assertRaisesRegex(ValueError,reason):
                classify(changed)

    def test_prefix_exclusion_and_unreviewed_storage(self):
        changed=bytearray(self.raw)
        changed[:328]=bytes(328)
        self.assertEqual(classify(changed),classify(self.raw))
        changed[0x154]^=1
        with self.assertRaisesRegex(ValueError,'reviewed snapshot'):
            classify(changed)
        with self.assertRaisesRegex(ValueError,'containing block'):
            classify(self.raw[:-1])


if __name__=='__main__':
    unittest.main()
