#!/usr/bin/env python3
"""Check disk projection without conflating source representation and meaning."""
import copy
import unittest

from classification_ledger import (CODE, DATA, TEMPORARY, PENDING, ASSUMED, complete,
                                   counts, from_items, pcode_classes, project, runs,
                                   early_native_classes)
from disk_layout import ROOT, sha


class LedgerTests(unittest.TestCase):
    def test_exact_classification_partition(self):
        items = [dict(offset=0,size=3,classification='code'),
                 dict(offset=3,size=2,classification='data')]
        owners = from_items(5,items)
        self.assertEqual(runs(owners),[[0,3,'code'],[3,2,'data']])
        self.assertTrue(complete(counts(owners)))
        for broken in [items[:1], items+[items[0]],
                       [dict(items[0],size=6)],
                       [dict(items[0],offset=-1)],
                       [dict(items[0],size=0)],
                       [dict(items[0],classification='unknown')],
                       [dict(items[0],offset=True)]]:
            with self.subTest(broken=broken), self.assertRaises(ValueError):
                from_items(5,broken)

    def test_pcode_data_is_not_an_instruction(self):
        report = dict(size=6,items=[
            dict(offset=0,size=2,kind='instruction'),
            dict(offset=2,size=2,kind='string-data'),
            dict(offset=4,size=2,kind='native-instruction')])
        self.assertEqual(pcode_classes(report),bytes([CODE,CODE,DATA,DATA,CODE,CODE]))
        report['items'][1]['kind'] = 'unreviewed-blob'
        with self.assertRaises(ValueError):
            pcode_classes(report)

    def fixture(self):
        # Copy the last operand byte of an instruction, then a metadata byte,
        # twice. These slices are intentionally not independently decodable.
        binary = bytes.fromhex('ad 34 12 99')
        disk = dict(id='fixture',filename='fixture.dsk',size=7,
            sha256=sha(bytes.fromhex('12 99 12 99 aa bb cc')),regions=[
                dict(offset=0,size=2,input='mixed',input_offset=2),
                dict(offset=2,size=2,input='mixed',input_offset=2),
                dict(offset=4,size=1,input='temporary',input_offset=0),
                dict(offset=5,size=2,input='pending',input_offset=0)])
        binaries = dict(mixed=binary,temporary=b'\xaa',pending=b'\xbb\xcc')
        owners = dict(mixed=bytes([CODE,CODE,CODE,DATA]),
                      temporary=bytes([TEMPORARY]),pending=bytes([PENDING,PENDING]))
        return disk,binaries,owners

    def test_copy_and_clipped_operand_projection(self):
        disk,binaries,owners = self.fixture()
        result = project(disk,binaries,owners)
        self.assertEqual(result['coverage_bytes'],dict(code=2,data=2,
            **{'temporary-unresolved':1,'audit-not-integrated':2,'user-assumed-data':0}))
        self.assertEqual(result['component_coverage']['mixed'],dict(code=2,data=2))
        self.assertEqual([(r['offset'],r['size']) for r in result['unfinished_regions']],
                         [(4,1),(5,2)])
        self.assertFalse(complete(result['coverage_bytes']))

    def test_bad_disk_ownership_and_hash_rejected(self):
        disk,binaries,owners = self.fixture()
        for field,value in [('offset',1),('size',3),('input_offset',3)]:
            changed = copy.deepcopy(disk)
            changed['regions'][0][field] = value
            with self.subTest(field=field), self.assertRaises(ValueError):
                project(changed,binaries,owners)
        with self.assertRaises(ValueError):
            project(dict(disk,sha256='0'*64),binaries,owners)
        with self.assertRaises(ValueError):
            project(disk,binaries,dict(owners,mixed=bytes([CODE])))

    def test_both_unfinished_categories_prevent_completion(self):
        for unfinished in (TEMPORARY,PENDING):
            self.assertFalse(complete(counts(bytes([CODE,DATA,unfinished]))))
        self.assertTrue(complete(counts(bytes([CODE,DATA]))))

    def test_user_assumption_stays_separate_from_proven_data(self):
        disk,binaries,owners = self.fixture()
        owners['temporary'] = bytes([ASSUMED])
        owners['pending'] = bytes([ASSUMED,ASSUMED])
        result = project(disk,binaries,owners)
        self.assertTrue(complete(result['coverage_bytes']))
        self.assertEqual(result['coverage_bytes']['data'],2)
        self.assertEqual(result['coverage_bytes']['user-assumed-data'],3)
        self.assertEqual(result['unfinished_regions'],[])
        self.assertEqual([(r['offset'],r['size']) for r in result['assumed_data_regions']],
                         [(4,1),(5,2)])

    def test_early_native_boundaries_and_retained_nops(self):
        raw = (ROOT/'build/disks/components/bootstrap.bin').read_bytes()
        owners = early_native_classes(raw,'bootstrap')
        self.assertEqual(owners.count(CODE),627)
        self.assertEqual(owners[0xCF:0xFD],bytes([DATA])*46)
        self.assertEqual(owners[0xFD:0x100],bytes([CODE])*3)
        # A changed table/storage byte, destroyed NOP prefix, BRK, or branch
        # into the count byte cannot be silently inherited as existing code.
        for offset,value in [(0xCF,1),(0xFD,0x60),(0x13E,1),(0x2C8,0),
                             (1,0),(4,0xFB)]:
            changed = bytearray(raw)
            changed[offset] = value
            with self.subTest(offset=offset), self.assertRaises(ValueError):
                early_native_classes(bytes(changed),'bootstrap')

    def test_title_tables_and_footer_are_data(self):
        raw = (ROOT/'build/disks/components/title_draw.bin').read_bytes()
        owners = early_native_classes(raw,'title_draw')
        self.assertEqual(owners.count(CODE),528)
        self.assertEqual(owners[0x210:],bytes([DATA])*496)
        for offset in (0x210,0x38F,0x390,0x3FF):
            changed = bytearray(raw)
            changed[offset] ^= 1
            with self.subTest(offset=offset), self.assertRaises(ValueError):
                early_native_classes(bytes(changed),'title_draw')


if __name__ == '__main__':
    unittest.main()
