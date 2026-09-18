#!/usr/bin/env python3
"""Native encoding round trips and code/data control-flow boundary tests."""
from pathlib import Path
import shutil
import struct
import subprocess
import tempfile
import unittest

from native_pascal_source import OPCODES, WIDTH, instruction, analyze_native


def fixture(body, pointers=()):
    assert len(body) % 2 == 0
    data = bytearray(body) + b'\0\0'  # interpreter count
    for target in pointers:
        data += struct.pack('<H', len(data) - target)
    data += struct.pack('<HHH', len(pointers), 0, 0)  # procedure, segment, global
    data += struct.pack('<H', len(data))  # entry pointer
    attr = len(data)
    data += b'\0\1'
    return data, dict(number=1, representation='native-6502', entry_offset=0,
                      attribute_offset=attr, lexical_level=1)


class NativePascalTests(unittest.TestCase):
    @unittest.skipUnless(shutil.which('ca65') and shutil.which('ld65'), 'cc65 required')
    def test_all_151_nmos_encodings_round_trip_with_ca65(self):
        self.assertEqual(len(OPCODES), 151)
        expected, lines = bytearray(), ['.setcpu "6502"', '.segment "CODE"']
        for opcode, (_, mode) in sorted(OPCODES.items()):
            size = WIDTH[mode]
            raw = bytes([opcode] + ([0] if mode == 'Lb' else [0x33, 0x55])[:size-1])
            pc = len(expected)
            expected += raw
            decoded = instruction(expected, pc)
            text = decoded['assembly']
            if mode == 'Lb':
                text = text.replace(f'L_{pc+2:04X}', '* + 2')
            lines.append(text)
        with tempfile.TemporaryDirectory() as temp:
            base = Path(temp)
            (base / 'test.s').write_text('\n'.join(lines)+'\n')
            (base / 'test.cfg').write_text('MEMORY { M: start = 0, size = 4096, file = %O; }\nSEGMENTS { CODE: load = M, type = ro; }\n')
            subprocess.run(['ca65', str(base/'test.s'), '-o', str(base/'test.o')], check=True, capture_output=True)
            subprocess.run(['ld65', '-C', str(base/'test.cfg'), str(base/'test.o'), '-o', str(base/'test.bin')], check=True, capture_output=True)
            self.assertEqual((base/'test.bin').read_bytes(), expected)

    def test_relocated_jump_and_explicit_data(self):
        data, proc = fixture([0x4C, 6, 0, 0x81, 0x82, 0x83, 0x60, 0], [1])
        with self.assertRaisesRegex(ValueError, 'Unclassified'):
            analyze_native(data, proc)
        recipe = {'data': [dict(offset=3, size=3, kind='native-lookup-table', evidence='Fixture constant table')]}
        report = analyze_native(data, proc, recipe)
        self.assertIn([0, 6], report['control_flow_edges'])
        self.assertEqual(report['gaps'], [])
        self.assertEqual(next(i for i in report['items'] if i['offset']==3)['kind'], 'native-lookup-table')

    def test_branch_into_operand_rejected(self):
        data, proc = fixture([0xD0, 1, 0xA9, 0xEA, 0x60, 0])
        with self.assertRaisesRegex(ValueError, 'overlap|operand'):
            analyze_native(data, proc)

    def test_conditional_branch_data_requires_evidence(self):
        data, proc = fixture([0xA9, 0, 0xF0, 2, 0xAA, 0xBB, 0x60, 0])
        recipe = {'data': [dict(offset=4, size=2, kind='native-lookup-table', evidence='Fixture data')]}
        with self.assertRaisesRegex(ValueError, 'data/operand'):
            analyze_native(data, proc, recipe)
        recipe.update(nonfallthrough_branches=[2], branch_evidence='LDA #0 sets Z before BEQ')
        self.assertEqual(analyze_native(data, proc, recipe)['gaps'], [])

    def test_brk_requires_interrupt_signature_model(self):
        data, proc = fixture([0, 0])
        with self.assertRaisesRegex(ValueError, 'interrupt-signature'):
            analyze_native(data, proc)

    def test_external_tail_jump_allows_one_alignment_byte(self):
        data, proc = fixture([0x4C, 0, 0xC6, 0])
        report = analyze_native(data, proc)
        self.assertEqual(report['external_edges'], [dict(source=0, target=0xC600, kind='fixed-address')])
        self.assertEqual(report['gaps'], [])


if __name__ == '__main__':
    unittest.main()
