import copy
import json
import unittest

from native_output_storage import LAYOUTS, PROOF, check_proof, classify_tail


class NativeOutputStorageTests(unittest.TestCase):
    def test_complete_container_and_exact_tail_boundaries(self):
        for name,(end,footer) in LAYOUTS.items():
            raw = bytearray(1024)
            raw[footer+8:footer+16] = (footer+8).to_bytes(2,'little')+bytes.fromhex('000002000101')
            raw[1023] = 4
            report = classify_tail(raw,name)
            self.assertEqual(report['zero_range'],[end,1023])
            self.assertEqual(report['data_bytes'],1024-end)
            self.assertFalse(report['historical_producer_identity_proved'])
            for offset in list(range(footer,footer+16))+list(range(end,1024)):
                changed = bytearray(raw)
                changed[offset] ^= 1
                with self.subTest(name=name,offset=offset),self.assertRaises(ValueError):
                    classify_tail(changed,name)
            with self.assertRaises(ValueError):
                classify_tail(raw[:-1],name)

    def test_historical_clear_and_block_write_evidence(self):
        proof = json.loads(PROOF.read_text())
        self.assertEqual(check_proof(proof)['uncleared_offset'],1023)
        for index,window in enumerate(proof['windows']):
            raw = bytes.fromhex(window['hex'])
            for offset in range(len(raw)):
                changed = copy.deepcopy(proof)
                data = bytearray(raw)
                data[offset] ^= 1
                changed['windows'][index]['hex'] = data.hex()
                with self.subTest(window=index,offset=offset),self.assertRaises(ValueError):
                    check_proof(changed)
        with self.assertRaises(ValueError):
            check_proof(proof,b'wrong assembler')


if __name__ == '__main__':
    unittest.main()
