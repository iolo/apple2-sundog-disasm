import copy
import json
import unittest

from disk_layout import ROOT, sha, block_bytes
from encoded_retained_stubs import audit
from native_raw_source import analyze
from storage_encoding import transform


class RetainedStubTests(unittest.TestCase):
    def fixture(self, variant):
        recipe = json.loads((ROOT/'src/native/evidence'/f'encoded_body_{variant}.json').read_text())
        manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
        disk = next(d for d in manifest['disks'] if d['id'] == recipe['origin']['disk'])
        block = recipe['origin']['block']
        stored = block_bytes((ROOT/'build/disks'/disk['filename']).read_bytes(), block, block+4)
        raw = transform(stored, recipe['storage_encoding'], decode=True)
        return raw, recipe, analyze(raw, recipe['base'], recipe, inspect_gaps=True)

    def test_both_relocations_and_all_new_bytes(self):
        for variant in ('play', 'alternate'):
            raw, recipe, body = self.fixture(variant)
            report = audit(raw, recipe['base'], body)
            self.assertEqual((report['code_bytes'], report['data_bytes']), (6,12))
            self.assertEqual(report['remaining_bank_offsets'], [1520,1526,1527,2032,2038,2039])
            for item in report['items']:
                for offset in range(item['offset'], item['offset']+item['size']):
                    changed = bytearray(raw)
                    changed[offset] ^= 1
                    edited_body = dict(body, sha256=sha(changed))
                    with self.subTest(variant=variant, offset=offset), self.assertRaises(ValueError):
                        audit(changed, recipe['base'], edited_body)
            with self.assertRaises(ValueError):
                audit(raw[:-1], recipe['base'], body)

    def test_existing_data_and_strict_graph_are_preserved(self):
        raw, recipe, body = self.fixture('play')
        for offset in (0x356,0x35A,0x35C,0x360,0x5DD,0x5DF,0x5E1,0x5E5,0x352):
            changed = copy.deepcopy(body)
            item = next(item for item in changed['items'] if item['offset'] == offset)
            item['kind'] = 'unreviewed'
            if offset == 0x352:
                item['classification'] = 'code'
            with self.subTest(offset=offset), self.assertRaises(ValueError):
                audit(raw, recipe['base'], changed)
        changed = copy.deepcopy(body)
        changed['edges'].append(dict(source=0, target=0x357))
        with self.assertRaisesRegex(ValueError, 'unexpectedly entered'):
            audit(raw, recipe['base'], changed)
        changed = copy.deepcopy(recipe)
        changed['roots'].append(dict(offset=0x357, evidence='Test only: force retained chain into live graph'))
        changed['indirect_jumps'] += [
            dict(offset=0x357, vector_address=recipe['base']+0x572, target_address=recipe['base']+0x35D, evidence='test'),
            dict(offset=0x35D, vector_address=recipe['base']+0x5DB, target_address=recipe['base']+0x5DD, evidence='test')]
        with self.assertRaises(ValueError):
            analyze(raw, recipe['base'], changed, inspect_gaps=True)


if __name__ == '__main__':
    unittest.main()
