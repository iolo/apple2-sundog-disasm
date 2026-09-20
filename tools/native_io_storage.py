"""Check the relocated native disk-state record and bounded bank storage."""
import argparse
import json
from pathlib import Path

from disk_layout import ROOT, sha

EVIDENCE = ROOT/'src/native/evidence/native_io_storage.json'
STATE = 0xdc8f
END = 0xe000


def audit_storage(binary, instructions):
    evidence = json.loads(EVIDENCE.read_text())
    if len(binary) != 4096:
        raise ValueError('Expected the full fixed-size native I/O bank')
    fields = evidence['fields']
    if [(f['offset'], f['size']) for f in fields] != [(0,1),(1,2),(3,1),(4,1),(5,1)]:
        raise ValueError('Historical six-byte disk-state layout differs')
    references = []
    for address, data in sorted(instructions.items()):
        if len(data) == 3 and STATE <= int.from_bytes(data[1:], 'little') < STATE+6:
            if binary[address-0xd000:address-0xd000+3] != data:
                raise ValueError('State reference listing differs from current bytes')
            references.append(dict(address=address, hex=data.hex(),
                                   field_offset=int.from_bytes(data[1:], 'little')-STATE))
    if references != evidence['current_state_references']:
        raise ValueError('Reviewed native disk-state references differ')
    for row in evidence['windows']:
        start, size = row['offset'], row['size']
        original = bytearray.fromhex(row['original_hex'])
        if len(original) != size:
            raise ValueError('Historical consumer window extent differs')
        for change in row['state_operand_changes']:
            pc = change['instruction_offset']
            relative = pc-start
            old, new = change['old_address'], change['new_address']
            if (int.from_bytes(original[relative+1:relative+3], 'little') != old
                    or new-STATE != old-evidence['historical_state_address']
                    or instructions.get(0xd000+pc) != bytes([original[relative]])+new.to_bytes(2,'little')):
                raise ValueError('State operand does not preserve the historical field offset')
            original[relative+1:relative+3] = new.to_bytes(2, 'little')
        if bytes(original) != binary[start:start+size]:
            raise ValueError('Historical consumer differs beyond reviewed state relocation')
    if any(binary[STATE-0xd000:STATE-0xd000+6]):
        raise ValueError('Initial disk-state record differs')
    if any(binary[STATE-0xd000+6:]):
        raise ValueError('Nonzero bank storage needs separate classification')
    return dict(classification_evidence='docs/native-io-storage.md',
                source_evidence=str(EVIDENCE.relative_to(ROOT)),
                state_address=STATE, state_size=6,
                fields=[dict(f, address=STATE+f['offset'], classification='data') for f in fields],
                checked_state_references=references,
                historical_consumer_bytes=sum(w['size'] for w in evidence['windows']),
                historical_state_address=evidence['historical_state_address'],
                unused_track_high_byte=dict(address=STATE+2,size=1,classification='data'),
                zero_bank_storage=dict(address=STATE+6,size=END-(STATE+6),classification='data'),
                unresolved_preservation_ranges=[])


def verify_external(path):
    evidence = json.loads(EVIDENCE.read_text())
    raw = path.read_bytes()
    if len(raw) != evidence['file_size'] or sha(raw) != evidence['file_sha256']:
        raise ValueError('Historical SYSTEM.APPLE differs')
    for row in evidence['windows']:
        if raw[row['offset']:row['offset']+row['size']].hex() != row['original_hex']:
            raise ValueError('Historical consumer excerpt differs')
    if any(raw[evidence['historical_state_address']-0xd000:0x1000]):
        raise ValueError('Historical initial state/bank storage differs')
    print('Historical SYSTEM.APPLE hash, consumer windows and bank storage verified')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--external-apple', type=Path, required=True)
    verify_external(parser.parse_args().external_apple)
