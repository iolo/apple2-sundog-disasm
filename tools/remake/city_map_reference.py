#!/usr/bin/env python3
"""Independent byte-oriented city composition reference; not an emulator capture."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TARGET = ROOT / 'remake/tests/fixtures/city-map-reference.json'


def draws(city):
    # Game21 proc26 installs two little-endian words into library22's RNG.
    state = list((3*city+39).to_bytes(2, 'little') + (11*city+51).to_bytes(2, 'little'))
    for _ in range(240):
        for _ in range(7):
            carry = ((state[0] >> 6) ^ (state[3] >> 6)) & 1
            for byte in range(4):
                value = state[byte]*2 + carry
                state[byte], carry = value & 255, value >> 8
        yield state[2] + (state[0] >> 1)*256


def reference():
    payload = (ROOT / 'assets/city-maps/maps.bin').read_bytes()
    defaults = (ROOT / 'assets/working-state/data.bin').read_bytes()[505:1945]
    systems = {}
    for index in range(12):
        member = int.from_bytes(defaults[index*20+10:index*20+12], 'little')
        for world in range((member >> 2) & 31, ((member >> 2) & 31)+(member & 3)):
            systems[world] = index+1
    records = []
    for world in range(1,19):
        member = int.from_bytes(defaults[240+(world-1)*16+14:256+(world-1)*16], 'little')
        first, count = (member >> 9) & 63, member & 7
        for city in range(first, first+count):
            cells = bytearray(960)
            for index, value in enumerate(draws(city)):
                byte = payload[(city-1)*120+index//2]
                tile = (byte >> ((index%2)*4)) & 15
                x, y = divmod(index, 12)
                cells[(y+6)*40+x+10] = tile+16*(value%2)
            records.append(dict(cityId=f'city-{city:02}',
                                banks=[(systems[world]-1)%4,(world-1)%4],
                                sha256=hashlib.sha256(cells).hexdigest()))
    assert [r['cityId'] for r in records] == [f'city-{i:02}' for i in range(1,58)]
    return dict(source='Independent packed-byte / byte-carry translation of game21 procedure26; no live capture',
                records=records)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    result = reference()
    if args.write:
        TARGET.write_text(json.dumps(result, indent=2)+'\n')
    elif json.loads(TARGET.read_text()) != result:
        raise SystemExit('Stale city map reference')
    print(f'57 ordinary city composition references {"written" if args.write else "verified"}')
