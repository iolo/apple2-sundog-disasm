#!/usr/bin/env python3
import copy
import json
import unittest

from pcode_source import analyze_fragment
from retained_linker import EVIDENCE_PATH, review


class RetainedLinkerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.evidence=json.loads(EVIDENCE_PATH.read_text())

    def test_complete_procedures_bound_clipped_copy(self):
        raw,decoded,items,counts=review(self.evidence)
        self.assertEqual(len(raw),810)
        self.assertEqual(decoded['instruction_count'],443)
        self.assertEqual([p['number'] for p in decoded['procedures']],[22,26])
        self.assertEqual(counts,dict(code=248,data=54))
        self.assertTrue(items[0]['clipped_start'])
        self.assertEqual(items[0]['full_item']['assembly'],'p_ldl 295, 2')
        self.assertEqual(items[0]['size'],2)
        self.assertFalse(items[-1]['clipped_end'])
        self.assertEqual(items[-1]['full_item']['assembly'],'p_ldci 20000')

    def test_historical_opcode_requires_explicit_dialect(self):
        raw=bytes.fromhex(self.evidence['fragment_hex'])
        with self.assertRaisesRegex(ValueError,'Unsupported opcode'):
            analyze_fragment(raw,1,[586,808])
        with self.assertRaisesRegex(ValueError,'Unknown p-code dialect'):
            analyze_fragment(raw,1,[586,808],dialect='guessed')
        decoded=analyze_fragment(raw,1,[586,808],dialect='apple-pascal-inn')
        inn=[i for i in decoded['items'] if i.get('mnemonic')=='inn']
        self.assertEqual(len(inn),5)
        self.assertTrue(all(i['size']==1 and i['successors']==[i['offset']+1] for i in inn))

    def test_modified_dictionary_context_and_external_inputs_rejected(self):
        changed=copy.deepcopy(self.evidence)
        changed['procedures'][0]['dictionary_offset']+=2
        with self.assertRaisesRegex(ValueError,'dictionary pointer'):
            review(changed)
        changed=copy.deepcopy(self.evidence)
        raw=bytearray.fromhex(changed['fragment_hex'])
        raw[0]^=1
        changed['fragment_hex']=raw.hex()
        with self.assertRaisesRegex(ValueError,'fragment hash'):
            review(changed)
        changed=copy.deepcopy(self.evidence)
        changed['copy']['input_offset']+=1
        with self.assertRaisesRegex(ValueError,'copy mapping'):
            review(changed)
        with self.assertRaisesRegex(ValueError,'External linker allocation'):
            review(self.evidence,b'not the historical linker')


if __name__=='__main__':
    unittest.main()
