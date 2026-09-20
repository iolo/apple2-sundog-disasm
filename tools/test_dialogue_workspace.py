import copy
import json
import unittest

from disk_layout import ROOT
from dialogue_workspace import simulate


class DialogueWorkspaceTests(unittest.TestCase):
    def fixture(self):
        raw = (ROOT/'assets/dialogue-dictionary/dictionary.bin').read_bytes()[:808]
        base = raw+bytes(215)+bytes([0xA0])
        fields = json.loads((ROOT/'assets/dialogue-dictionary/fields.json').read_text())
        supplements = [(s['block'],s['fields']['entries']) for s in fields[1:]]
        return base,supplements

    def test_current_supplements_cover_workspace_and_stop_before_unknown_tail(self):
        base,supplements = self.fixture()
        result = simulate(base,supplements)
        self.assertEqual(result['initial_entry_index'],52)
        self.assertEqual(result['workspace_range'],[808,997])
        self.assertEqual(result['unused_unclassified_range'],[997,1024])
        largest = max(result['supplements'],key=lambda s:s['final_offset'])
        self.assertEqual((largest['block'],largest['entries'],largest['final_offset']),(95,9,997))
        self.assertEqual(sum(r['size'] for r in largest['write_ranges']),189)
        # The excluded range does not need guessed fill values for this proof.
        alternate_tail = base[:997]+bytes(range(27))
        changed = simulate(alternate_tail,supplements)
        self.assertEqual(changed['workspace_range'],result['workspace_range'])
        self.assertNotEqual(changed['supplements'][0]['updated_dictionary_sha256'],
                            result['supplements'][0]['updated_dictionary_sha256'])

    def test_bad_boundaries_initializer_and_missing_write_evidence_are_rejected(self):
        base,supplements = self.fixture()
        for offset in (64,808,996):
            changed = bytearray(base)
            changed[offset] ^= 1
            with self.subTest(offset=offset),self.assertRaises(ValueError):
                simulate(changed,supplements)
        with self.assertRaises(ValueError):
            simulate(base[:-1],supplements)
        with self.assertRaisesRegex(ValueError,'complete selected workspace'):
            simulate(base,[(b,e) for b,e in supplements if b!=95])
        changed = copy.deepcopy(supplements)
        entries = next(e for b,e in changed if b==95)
        entries[0]['stored_characters'] += 'X'
        with self.assertRaisesRegex(ValueError,'exceeds reviewed workspace'):
            simulate(base,changed)


if __name__ == '__main__':
    unittest.main()
