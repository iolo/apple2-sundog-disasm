#!/usr/bin/env python3
"""Copied-code classification must retain gaps and explain clipped instructions."""
import copy
from pathlib import Path
import subprocess
import tempfile
import unittest

from disk_layout import sha
from encoded_overlay_tail import audit, source


def fixture():
    raw = bytearray(2048)
    raw[0x437:0x43a] = bytes.fromhex('90 03 60')
    raw[0x5fa:0x5fc] = bytes.fromhex('10 12')
    raw[0x5ff:0x602] = bytes.fromhex('ad 83 c0')
    raw[0x630:0x638] = bytes.fromhex('30 06 00 00 02 00 01 01')
    raw[0x638:0x800] = raw[0x438:0x600]
    raw[0x7fa:0x7fc] = b'\0\0'
    body = dict(base=0xc00,sha256=sha(raw),items=[
        dict(offset=0x437,size=2,classification='code',mnemonic='bcc',mode='Lb',assembly='bcc L_043C'),
        dict(offset=0x439,size=1,classification='code',mnemonic='rts',mode='Ip',assembly='rts'),
        dict(offset=0x5fa,size=2,classification='data',kind='wipe-start-address',evidence='fixture consumer'),
        dict(offset=0x5ff,size=3,classification='code',mnemonic='lda',mode='Ab',assembly='lda a:$C083')])
    return raw,body


class EncodedTailTests(unittest.TestCase):
    def test_metadata_copy_gaps_and_partial_instruction_ownership(self):
        raw,body = fixture()
        report = audit(raw,body)
        self.assertEqual(report['coverage_bytes'],{'data':19,'code':3})
        self.assertEqual(report['full_instruction_count'],1)
        self.assertEqual(report['partial_instruction_count'],2)
        self.assertIn(0x700,report['unresolved_tail_offsets'])
        self.assertEqual(report['dictionary']['procedures'][0]['entry_offset'],0)
        self.assertEqual(report['relocation']['tables_start'],0x628)
        with tempfile.TemporaryDirectory() as directory:
            stem = Path(directory)/'slice'
            for start,end in report['selected_ranges']:
                text,base = source(raw,report,start,end)
                stem.with_suffix('.s').write_text(text)
                stem.with_suffix('.cfg').write_text(f'MEMORY {{ M: start = ${base:04X}, size = {end-start}, file = %O; }}\nSEGMENTS {{ RAW_NATIVE: load = M, type = ro; }}\n')
                subprocess.run(['ca65',str(stem.with_suffix('.s')),'-o',str(stem.with_suffix('.o'))],check=True)
                subprocess.run(['ld65','-C',str(stem.with_suffix('.cfg')),str(stem.with_suffix('.o')),'-o',str(stem.with_suffix('.bin'))],check=True)
                self.assertEqual(stem.with_suffix('.bin').read_bytes(),raw[start:end])
        with self.assertRaisesRegex(ValueError,'gap|unresolved'):
            source(raw,report,0x638,0x800)

    def test_copy_changes_and_unreviewed_initializers_are_rejected(self):
        for offset,pattern in [(0x700,'differs outside'),(0x7fa,'zero initializer'),(0x630,'valid native procedure'),(0x627,'alignment')]:
            raw,body = fixture()
            raw[offset] ^= 1
            body['sha256'] = sha(raw)
            with self.subTest(offset=offset),self.assertRaisesRegex(ValueError,pattern):
                audit(raw,body)

    def test_partial_instruction_requires_reviewed_source_context(self):
        raw,body = fixture()
        altered = copy.deepcopy(body)
        altered['items'][0]['mnemonic'] = 'bcs'
        with self.assertRaisesRegex(ValueError,'Unreviewed partial'):
            audit(raw,altered)
        altered = copy.deepcopy(body)
        altered['items'][2]['kind'] = 'unknown'
        with self.assertRaisesRegex(ValueError,'data-field ownership'):
            audit(raw,altered)
        raw[0] ^= 1
        with self.assertRaisesRegex(ValueError,'reviewed full body'):
            audit(raw,body)


if __name__ == '__main__':
    unittest.main()
