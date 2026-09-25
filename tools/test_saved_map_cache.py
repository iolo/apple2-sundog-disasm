import copy
import json
import unittest

from disk_layout import ROOT, block_bytes
from saved_map_cache import PROOF, check_proof, classify, modeled_tail
from save_state_asset import PAYLOAD_SIZE


class SavedMapCacheTests(unittest.TestCase):
    def fixture(self):
        payload = (ROOT/'assets/save-states/payloads.bin').read_bytes()[3*PAYLOAD_SIZE:]
        maps = (ROOT/'assets/world-maps/maps.bin').read_bytes()
        bank = block_bytes((ROOT/'build/disks/sundog-disk1-game.dsk').read_bytes(),57,67)
        return bank,payload,maps

    def test_shipped_producers_reproduce_all_tail_bytes(self):
        bank,payload,maps = self.fixture()
        tail,result = modeled_tail(payload,maps)
        self.assertEqual(tail,bytes([12])*32+bytes(40)+b'\1'+bytes(23))
        self.assertEqual(tail,bank[5024:])
        self.assertEqual(result['retained_memory_range'],[0x53A0,0x5400])
        self.assertEqual([c['cache_offset'] for c in result['city_overlays']],
                         [292,368,398,225,771,312])
        self.assertFalse(any(c['affects_saved_tail'] for c in result['city_overlays']))
        self.assertEqual(classify(bank,payload,maps)['classified_bytes'],96)

    def test_changed_cache_content_and_missing_random_state_are_rejected(self):
        bank,payload,maps = self.fixture()
        for offset in range(5024,5120):
            changed = bytearray(bank)
            changed[offset] ^= 1
            with self.subTest(offset=offset),self.assertRaises(ValueError):
                classify(changed,payload,maps)
        changed = bytearray(payload)
        # Put city 1 in the retained map row; the model must apply that write.
        changed[4112+10:4112+12] = (23*64+8).to_bytes(2,'little')
        tail,result = modeled_tail(changed,maps)
        self.assertEqual(tail[0],13)
        with self.assertRaises(ValueError):
            classify(bytes(changed)+bank[5024:],bytes(changed),maps)
        changed = bytearray(payload)
        changed[(82-36)*2+14] |= 1
        with self.assertRaisesRegex(ValueError,'random placement'):
            modeled_tail(changed,maps)
        for altered in (bank[:-1],bank+b'\0'):
            with self.assertRaises(ValueError):
                classify(altered,payload,maps)

    def test_frozen_producer_evidence_is_required(self):
        proof = json.loads(PROOF.read_text())
        manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
        components = {p['name']:(ROOT/'build/disks/components'/f"{p['name']}.bin").read_bytes()
                      for p in proof['components']}
        check_proof(proof,components,manifest)
        changed = copy.deepcopy(proof)
        changed['components'][0]['windows'][0]['hex'] = '00'
        with self.assertRaises(ValueError):
            check_proof(changed,components,manifest)


if __name__ == '__main__':
    unittest.main()
