"""Check the retained reader's complete CFG and reversible stored encoding."""
import json
from pathlib import Path
import subprocess
import tempfile
import unittest

from disk_layout import ROOT, sha
from native_raw_source import analyze
from storage_encoding import transform
from encoded_reader_alignment import classify, check_evidence, PROOF


class EncodedDiskReaderTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.recipe = json.loads((ROOT/'src/native/evidence/encoded_disk_reader.json').read_text())
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory)
            subprocess.run(['ca65', str(ROOT/'src/native/encoded_disk_reader.s'),
                            '-o', str(output/'reader.o')], check=True)
            subprocess.run(['ld65', '-C', str(ROOT/'src/native/encoded_disk_reader.cfg'),
                            str(output/'reader.o'), '-o', str(output/'reader.bin')], check=True)
            cls.raw = (output/'reader.bin').read_bytes()

    def test_complete_single_entry_graph_and_encoding(self):
        recipe, raw = self.recipe, self.raw
        self.assertEqual(len(raw), 127)
        self.assertEqual(sha(raw), 'ba80707d73a36488cb30ef1d0b06dc09e3141a2129463738bc1a9a2df5935326')
        stored = transform(raw, recipe['storage_encoding'])
        self.assertEqual(sha(stored), recipe['sha256'])
        self.assertEqual(transform(stored, recipe['storage_encoding'], decode=True), raw)
        report = analyze(raw, recipe['base'], recipe)
        saved = json.loads((ROOT/'docs/reference/raw-modules/encoded_disk_reader.json').read_text())
        for key, value in report.items():
            self.assertEqual(value, saved[key], key)
        self.assertEqual(report['coverage_bytes'], {'code': 127})
        self.assertEqual(report['instruction_count'], 66)
        self.assertEqual(report['unclassified_offsets'], [])
        calls = [item for item in report['items'] if item['mnemonic'] == 'jsr']
        self.assertEqual([item['operand_value'] for item in calls],
                         [0xe07a]+[0xe074]*6+[0xe070]*5)
        self.assertTrue(all('external_address' not in edge for edge in report['edges']))

    def test_changed_control_flow_is_rejected(self):
        raw = bytearray(self.raw)
        raw[0x18] = 0x47  # BEQ now enters STA's operand at offset $60.
        with self.assertRaisesRegex(ValueError, 'operand|overlap|Unsupported native opcode'):
            analyze(bytes(raw), self.recipe['base'], self.recipe)
        raw = bytearray(self.raw)
        raw[0x35] = 0xaf  # JSR outside the established local routine.
        with self.assertRaisesRegex(ValueError, 'External'):
            analyze(bytes(raw), self.recipe['base'], self.recipe)

    def test_trailing_byte_is_not_implicitly_classified(self):
        with self.assertRaisesRegex(ValueError, 'Unclassified'):
            analyze(self.raw+b'\0', self.recipe['base'], self.recipe)

    def test_explicit_alignment_and_independent_record_boundary(self):
        records = (ROOT/'assets/interaction-records/records.bin').read_bytes()
        block = transform(self.raw+b'\0',self.recipe['storage_encoding'])+records[128:]
        report = classify(block,records,self.recipe)
        self.assertEqual(report['classification'],'data')
        self.assertEqual((report['offset'],report['decoded_value'],report['stored_value']),(127,0,165))
        for offset in (126,127,128,511):
            changed = bytearray(block)
            changed[offset] ^= 1
            with self.subTest(offset=offset),self.assertRaises(ValueError):
                classify(changed,records,self.recipe)
        with self.assertRaises(ValueError):
            classify(block[:-1],records,self.recipe)
        proof = json.loads(PROOF.read_text())
        check_evidence(proof)
        for window in proof['windows']:
            original = window['hex']
            data = bytearray.fromhex(original)
            for offset in range(len(data)):
                changed = bytearray(data)
                changed[offset] ^= 1
                window['hex'] = changed.hex()
                with self.subTest(evidence=offset),self.assertRaises(ValueError):
                    check_evidence(proof)
            window['hex'] = original


if __name__ == '__main__':
    unittest.main()
