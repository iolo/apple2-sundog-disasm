#!/usr/bin/env python3
"""Source reuse must preserve classification, ownership and exact disk bytes."""
import copy
import unittest

from adopt_component import source_copy_plan
from build_disks import compose_image
from disk_layout import sha
from pcode_copies import copy_items, verify_ownership, validate_copy_match


class SourceCopyTests(unittest.TestCase):
    def test_short_match_requires_explicit_review_and_nontrivial_bytes(self):
        raw = bytes(range(40))
        row = dict(size=len(raw),sha256=sha(raw),evidence='Reviewed complete tail with source-item boundaries')
        validate_copy_match(row,raw,32)
        with self.assertRaises(ValueError):
            validate_copy_match(row,raw)
        for minimum in (0,16,33):
            with self.assertRaises(ValueError):
                validate_copy_match(row,raw,minimum)
        for changed in (raw[:-1],raw[:-1]+b'X'):
            with self.assertRaises(ValueError):
                validate_copy_match(row,changed,32)
        for replacement in (dict(row,evidence=''),dict(row,size=31)):
            with self.assertRaises(ValueError):
                validate_copy_match(replacement,raw,32)
        with self.assertRaises(ValueError):
            validate_copy_match(dict(row,sha256=sha(bytes(40))),bytes(40),32)

    def setUp(self):
        self.image = b'ABCDEFABCDEF'
        self.binary = b'ABCDEF'
        self.manifest = dict(components=dict(code=dict(kind='ca65-source',size=6,sha256=sha(self.binary)),
                                            raw=dict(kind='temporary-unresolved',path='raw.bin',size=6,sha256=sha(self.binary))),
                             disks=[dict(id='disk1',size=12,sha256=sha(self.image),regions=[
                                 dict(offset=0,size=6,input='code',input_offset=0),
                                 dict(offset=6,size=6,input='raw',input_offset=0)])])
        self.mappings = [dict(disk='disk1',offset=7,size=4,input='code',input_offset=1)]

    def test_existing_source_slice_reuse_preserves_original_and_image(self):
        original = copy.deepcopy(self.manifest)
        result,files = source_copy_plan(self.manifest,{'disk1':self.image},self.mappings,{'code':self.binary})
        self.assertEqual(original,self.manifest)
        self.assertEqual(result['components']['code'],self.manifest['components']['code'])
        self.assertEqual(files['raw.bin'],b'AF')
        self.assertEqual(compose_image(result['disks'][0],{'code':self.binary,'raw':files['raw.bin']}),self.image)
        verify_ownership(result,self.mappings)
        with self.assertRaisesRegex(ValueError,'ownership'):
            verify_ownership(original,self.mappings)

    def test_copy_rejects_overlap_wrong_bytes_bounds_and_existing_ownership(self):
        for field,value in [('offset',0),('offset',12),('size',0),('input_offset',0),('input_offset',6)]:
            mappings = copy.deepcopy(self.mappings)
            mappings[0][field] = value
            with self.subTest(field=field,value=value),self.assertRaises(ValueError):
                source_copy_plan(self.manifest,{'disk1':self.image},mappings,{'code':self.binary})
        with self.assertRaisesRegex(ValueError,'overlap'):
            source_copy_plan(self.manifest,{'disk1':self.image},self.mappings*2,{'code':self.binary})
        with self.assertRaisesRegex(ValueError,'verified assembled'):
            source_copy_plan(self.manifest,{'disk1':self.image},self.mappings,{'code':b'ABXDEF'})
        with self.assertRaisesRegex(ValueError,'Stale'):
            source_copy_plan(self.manifest,{'disk1':b'ABCDEFABCDEX'},self.mappings,{'code':self.binary})

    def test_code_data_and_clipped_boundaries_are_preserved(self):
        report = dict(size=6,items=[dict(offset=0,size=3,kind='instruction',assembly='p_ldci 42'),
                                   dict(offset=3,size=2,kind='string-data',assembly='.byte $41,$42'),
                                   dict(offset=5,size=1,kind='instruction',assembly='p_nop')])
        items = copy_items(report,1,4)
        self.assertEqual([(i['classification'],i['size']) for i in items],[('code',2),('data',2)])
        self.assertTrue(items[0]['clipped_start'])
        self.assertFalse(items[1]['clipped_end'])
        self.assertEqual(items[0]['source_item_offset'],0)
        report['items'].pop(1)
        with self.assertRaisesRegex(ValueError,'unclassified|gap'):
            copy_items(report,1,4)
        with self.assertRaisesRegex(ValueError,'outside'):
            copy_items(report,0,7)


if __name__ == '__main__':
    unittest.main()
