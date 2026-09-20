#!/usr/bin/env python3
"""Audit the retained FORTRAN protection table and its patch/code boundaries."""
import json

from disk_layout import ROOT, sha
from native_pascal_source import instruction
from native_relocations import native_relocations
from pascal_inventory import procedure_dictionary

EVIDENCE = ROOT / 'src/native/evidence/initializer_fortran_protection.json'
PAYLOAD = bytes.fromhex(
    'c0d25cd57ad30fd220b3b3a546854cb3b34cb3b30e49ab45cd484a682ac9042a854660a44624004c10d3')


def consumer_evidence(compiler=None):
    """Frozen research excerpts; optionally recheck them against the source file.

    The downloaded compiler is evidence only, never a reconstruction input.
    Window addresses are FILE OFFSETS, not the compiler's load addresses.
    """
    evidence = json.loads(EVIDENCE.read_text())
    if compiler is not None:
        if len(compiler) != evidence['file_size'] or sha(compiler) != evidence['file_sha256']:
            raise ValueError('External FORTRAN compiler hash or size differs')
        start = evidence['segment_file_offset']
        segment = compiler[start:start + evidence['segment_size']]
        dictionary = procedure_dictionary(segment, evidence['segment_number'])
        proc = dictionary['procedures'][3]
        if (sha(segment) != evidence['segment_sha256'] or not dictionary['valid']
                or proc != evidence['native_procedure']
                or native_relocations(segment, proc) != evidence['relocations']):
            raise ValueError('FORTRAN native consumer provenance differs')
    for window in evidence['consumer_windows']:
        data = bytes.fromhex(window['hex'])
        if len(data) != window['size'] or sha(data) != window['sha256']:
            raise ValueError('FORTRAN consumer excerpt differs')
        if compiler is not None:
            start = window['file_offset']
            if compiler[start:start + len(data)] != data:
                raise ValueError('FORTRAN consumer excerpt does not match source')
        cursor = 0
        while cursor < len(data):
            cursor += instruction(data, cursor)['size']
    return evidence


def audit_payload(initializer, io_bank, compiler=None):
    if len(initializer) != 1280 or len(io_bank) != 4096:
        raise ValueError('Initializer or native I/O extent differs')
    # Both the source address and publication of its copied destination matter.
    if initializer[0x162:0x177] != bytes.fromhex(
            'a029b918f49956bf8810f7a9568d23bfa9bf8d24bf'):
        raise ValueError('FORTRAN payload copy or published pointer differs')
    payload = initializer[0x188:0x1b2]
    if payload != PAYLOAD:
        raise ValueError('FORTRAN protection payload differs from reviewed table')
    evidence = consumer_evidence(compiler)
    items = []
    for offset in range(0, 8, 2):
        items.append(dict(offset=offset, size=2, classification='data',
                          kind='patch-site-address', bank=2 if offset < 6 else 1,
                          value=int.from_bytes(payload[offset:offset+2], 'little')))
    for lo, hi in ((8, 13), (14, 20), (21, 42)):
        cursor = lo
        while cursor < hi:
            item = instruction(payload, cursor)
            if cursor + item['size'] > hi:
                raise ValueError('Protection instruction crosses a classified boundary')
            items.append(dict(item, classification='code', kind='complete-instruction'))
            cursor += item['size']
    # Only the STA opcode is copied: its operand is the existing I/O instruction's.
    if io_bank[0x55c:0x560] != bytes.fromhex('a90085cf'):
        raise ValueError('FORTRAN read patch loses its retained STA operand')
    patched_read = payload[11:14] + io_bank[0x55f:0x560]
    read_instructions = [instruction(patched_read, 0), instruction(patched_read, 2)]
    items.append(dict(offset=13, size=1, classification='code', kind='opcode-fragment',
                      assembly='sta $CF ; operand retained at bank-2 $D55F',
                      installed_address=0xd55e, retained_operand_address=0xd55f))
    items.append(dict(offset=20, size=1, classification='data', kind='helper-displacement',
                      value=payload[20]))
    items.sort(key=lambda item: item['offset'])
    if [p for item in items for p in range(item['offset'], item['offset']+item['size'])] != list(range(42)):
        raise ValueError('FORTRAN payload ownership has a gap or overlap')
    checksum_helper = 0xbf56 + 21
    write_helper = checksum_helper + payload[20]
    if write_helper != 0xbf79 or io_bank[0x310:0x313] != bytes.fromhex('201ad3'):
        raise ValueError('FORTRAN write helper or disk continuation differs')
    complete = [item for item in items if item['kind'] == 'complete-instruction']
    return dict(evidence='docs/initializer-fortran-protection.md',
        source_address=0xf418, copied_address=0x6988, installed_address=0xbf56,
        size=42, sha256=sha(payload), instruction_count=len(complete),
        complete_instruction_bytes=sum(item['size'] for item in complete),
        code_fragment_bytes=1,
        data_bytes=sum(item['size'] for item in items if item['classification'] == 'data'), items=items,
        patches=[dict(offset=8, size=3, site=0xd2c0, bank=2, installed_hex='2079bf'),
                 dict(offset=11, size=3, site=0xd55c, bank=2, installed_hex='a54685',
                      completed_instructions=read_instructions),
                 dict(offset=14, size=3, site=0xd37a, bank=2, installed_hex='4c6bbf'),
                 dict(offset=17, size=3, site=0xd20f, bank=1,
                      installed_target='caller-supplied restore buffer, from $BF25/$BF26')],
        checksum_helper=checksum_helper, write_helper=write_helper,
        external_consumer_sha256=evidence['file_sha256'],
        external_file_verified=compiler is not None,
        sundog_activation_observed=False, unresolved_ranges=[])
