"""Ensure partial reconstruction cannot silently omit, overlap, or truncate bytes."""
import copy
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from build_disks import build, compose_image, contained_file, temporary_inputs
from disk_layout import sha
from verify_disks import describe_offset, difference


class ReconstructionTests(unittest.TestCase):
    def setUp(self):
        self.components = {"code": bytes.fromhex("01 e0 60"), "remainder": b"abcde"}
        self.disk = {"size": 8, "regions": [
            {"offset": 0, "size": 3, "input": "code", "input_offset": 0},
            {"offset": 3, "size": 5, "input": "remainder", "input_offset": 0}]}

    def test_full_coverage_and_invalid_mapping(self):
        self.assertEqual(compose_image(self.disk, self.components), b"\x01\xe0\x60abcde")
        for field, value in [("offset", 2), ("offset", 4), ("size", 0), ("size", 6),
                             ("input_offset", -1), ("input_offset", 1)]:
            with self.subTest(field=field, value=value):
                bad = copy.deepcopy(self.disk)
                bad["regions"][1][field] = value
                with self.assertRaises(ValueError):
                    compose_image(bad, self.components)
        bad = copy.deepcopy(self.disk)
        bad["regions"].pop()
        with self.assertRaises(ValueError):
            compose_image(bad, self.components)

    def test_mismatch_including_truncation_and_sector_mapping(self):
        self.assertIsNone(difference(b"abc", b"abc"))
        self.assertEqual(difference(b"abc", b"adc"), 1)
        self.assertEqual(difference(b"abc", b"ab"), 2)
        self.assertEqual(difference(b"abc", b"abcd"), 3)
        disk = {"size": 143360, "regions": [
            {"offset": 0xE00, "size": 256, "input": "bootstrap"}]}
        detail = describe_offset(disk, 0xE07)
        self.assertIn("logical block 0, half 1, byte 7", detail)
        self.assertIn("component bootstrap", detail)
        self.assertEqual(describe_offset(disk, 143360), "past expected end of image")

    def test_missing_or_escaping_temporary_input(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            (root / "good.bin").write_bytes(b"ok")
            self.assertEqual(contained_file(root, "good.bin").read_bytes(), b"ok")
            for name in ("missing.bin", "../escape.bin"):
                with self.assertRaises(ValueError):
                    contained_file(root, name)

    def test_temporary_gate_counts_copies_and_rejects_before_writing(self):
        manifest = dict(schema_version=1,status='complete',components={
            'remainder':dict(kind='temporary-unresolved',size=5,path='absent.bin')},
            disks=[dict(id=name,regions=[dict(input='remainder',size=5)])
                   for name in ('disk1','disk2')])
        item, = temporary_inputs(manifest)
        self.assertEqual(item['input_bytes'],5)
        self.assertEqual(item['mapped_disk_bytes'],10)
        self.assertEqual(item['disk_bytes'],dict(disk1=5,disk2=5))
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            path = root/'manifest.json'
            path.write_text(json.dumps(manifest))
            output = root/'output'
            with self.assertRaisesRegex(ValueError,'mapping 10 disk bytes'):
                build(path,output,no_temporary=True)
            self.assertFalse(output.exists())
            # Neither a misleading status nor hiding all mappings bypasses it.
            manifest['disks'] = []
            manifest['components']['remainder']['size'] = 0
            path.write_text(json.dumps(manifest))
            output.mkdir()
            sentinel = output/'existing.dsk'
            sentinel.write_bytes(b'keep')
            with self.assertRaisesRegex(ValueError,'1 temporary input components'):
                build(path,output,no_temporary=True)
            self.assertEqual(sentinel.read_bytes(),b'keep')
            self.assertEqual(list(output.iterdir()),[sentinel])

    def test_strict_build_requires_real_evidence_and_incremental_build_still_works(self):
        data = b'identified data'
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            (root/'asset.bin').write_bytes(data)
            manifest = dict(schema_version=1,status='not a completion claim',components={
                'asset':dict(kind='identified-data',path='asset.bin',size=len(data),
                             sha256=sha(data),format='test-data',classification_evidence='proof.md')},
                disks=[dict(id='disk1',filename='out.dsk',size=len(data),sha256=sha(data),
                            regions=[dict(offset=0,size=len(data),input='asset',input_offset=0)])])
            path = root/'manifest.json'
            path.write_text(json.dumps(manifest))
            with patch('build_disks.ROOT',root):
                with self.assertRaisesRegex(ValueError,'Missing or escaping input'):
                    build(path,root/'missing-evidence',no_temporary=True)
                (root/'proof.md').write_text('Fixture classification evidence.\n')
                report = build(path,root/'strict',no_temporary=True)
                self.assertFalse(report['has_temporary_inputs'])
                self.assertTrue(report['no_temporary_required'])
                self.assertEqual((root/'strict/out.dsk').read_bytes(),data)
                manifest['components']['asset'] = dict(kind='temporary-unresolved',
                    path='asset.bin',size=len(data),sha256=sha(data))
                path.write_text(json.dumps(manifest))
                report = build(path,root/'incremental')
                self.assertTrue(report['has_temporary_inputs'])
                self.assertFalse(report['no_temporary_required'])
                self.assertEqual((root/'incremental/out.dsk').read_bytes(),data)

    def test_user_assumed_data_requires_exact_acceptance_scope(self):
        data = b'abcde'
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            (root/'tail.bin').write_bytes(data)
            (root/'assumption.md').write_text('Explicit fixture user exception.\n')
            spec = dict(kind='user-assumed-data',path='tail.bin',size=5,sha256=sha(data),
                        acceptance_record='acceptance.json',assumption_document='assumption.md')
            manifest = dict(schema_version=1,status='accepted with data assumption',
                components={'tail':spec},disks=[dict(id='disk1',filename='out.dsk',size=5,
                    sha256=sha(data),regions=[dict(offset=0,size=5,input='tail',input_offset=0)])])
            record = dict(basis='explicit-user-instruction',instruction='Treat this tail as data.',
                components={'tail':dict(path='tail.bin',size=5,sha256=sha(data),
                                       regions=[['disk1',0,5,0]])})
            path = root/'manifest.json'
            path.write_text(json.dumps(manifest))
            acceptance = root/'acceptance.json'
            acceptance.write_text(json.dumps(record))
            with patch('build_disks.ROOT',root):
                result = build(path,root/'accepted',no_temporary=True)
                self.assertFalse(result['has_temporary_inputs'])
                self.assertTrue(result['has_assumed_data'])
                self.assertEqual(result['coverage_bytes'],{'user-assumed-data':5})
                self.assertEqual(result['assumed_data_inputs'][0]['mapped_disk_bytes'],5)
                self.assertEqual((root/'accepted/out.dsk').read_bytes(),data)
                for index,change in enumerate(('hash','range','missing-component','basis','instruction')):
                    bad = copy.deepcopy(record)
                    if change == 'hash': bad['components']['tail']['sha256'] = '0'*64
                    elif change == 'range': bad['components']['tail']['regions'][0][2] = 4
                    elif change == 'missing-component': bad['components'] = {}
                    elif change == 'basis': bad['basis'] = 'automatic-guess'
                    else: bad['instruction'] = ''
                    acceptance.write_text(json.dumps(bad))
                    output = root/f'rejected-{index}'
                    with self.subTest(change=change), self.assertRaises(ValueError):
                        build(path,output,no_temporary=True)
                    self.assertFalse(output.exists())
                acceptance.write_text(json.dumps(record))
                # A changed byte also fails despite an unchanged acceptance record.
                (root/'tail.bin').write_bytes(b'abcdX')
                with self.assertRaisesRegex(ValueError,'exact-byte baseline'):
                    build(path,root/'changed-byte',no_temporary=True)
                (root/'tail.bin').write_bytes(data)
                manifest['disks'][0]['regions'].append(
                    dict(offset=5,size=5,input='tail',input_offset=0))
                path.write_text(json.dumps(manifest))
                with self.assertRaisesRegex(ValueError,'accepted scope'):
                    build(path,root/'extra-copy',no_temporary=True)
                self.assertFalse((root/'extra-copy').exists())


if __name__ == "__main__":
    unittest.main()
