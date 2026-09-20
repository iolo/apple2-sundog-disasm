import copy
import json
import unittest

from disk_layout import ROOT, block_bytes, sha
from encoded_bank_completion import audit_symbols, combine, TRACK_EVIDENCE, reference_track
from native_raw_source import analyze
from storage_encoding import transform


class EncodedCompletionTests(unittest.TestCase):
    def test_symbols_require_data_layout_code_constants_and_raw_track(self):
        manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
        track = reference_track(json.loads(TRACK_EVIDENCE.read_text()))
        for variant in ('play','alternate'):
            recipe = json.loads((ROOT/'src/native/evidence'/f'encoded_body_{variant}.json').read_text())
            disk = next(d for d in manifest['disks'] if d['id'] == recipe['origin']['disk'])
            start = recipe['origin']['block']
            stored = block_bytes((ROOT/'build/disks'/disk['filename']).read_bytes(),start,start+4)
            raw = transform(stored,recipe['storage_encoding'],decode=True)
            body = analyze(raw,recipe['base'],recipe,inspect_gaps=True)
            items = audit_symbols(raw,body,track)
            self.assertEqual(sum(i['size'] for i in items),6)
            self.assertTrue(all(i['classification']=='data' for i in items))
            for offset in [0x5F0,0x5F6,0x5F7,0x7F0,0x7F6,0x7F7,
                           0x141,0x142,0x481,0x48A,0x4DD,0x4EC,0x5E8,0x5F1,0x13C]:
                changed = bytearray(raw)
                changed[offset] ^= 1
                with self.subTest(variant=variant,offset=offset),self.assertRaises(ValueError):
                    audit_symbols(changed,dict(body,sha256=sha(changed)),track)
            changed = copy.deepcopy(body)
            next(i for i in changed['items'] if i['offset']==0x5F1)['kind'] = 'unreviewed'
            with self.assertRaises(ValueError):
                audit_symbols(raw,changed,track)
            changed_track = bytearray(track)
            changed_track[0x350] ^= 1
            with self.assertRaises(ValueError):
                audit_symbols(raw,body,changed_track)

    def test_complete_coverage_rejects_gaps_overlaps_and_unknown_classes(self):
        layers = dict(code=[dict(offset=0,size=1475,classification='code')],
                      data=[dict(offset=1475,size=573,classification='data')])
        report = combine(layers)
        self.assertEqual(report['coverage_bytes'],dict(code=1475,data=573))
        self.assertEqual(report['unclassified_bytes'],0)
        for field,value in [('offset',1474),('offset',1476),('classification','unknown'),('size',572)]:
            changed = copy.deepcopy(layers)
            changed['data'][0][field] = value
            with self.subTest(field=field,value=value),self.assertRaises(ValueError):
                combine(changed)


if __name__ == '__main__':
    unittest.main()
