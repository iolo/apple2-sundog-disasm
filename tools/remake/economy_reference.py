#!/usr/bin/env python3
"""Decode named economy fields from the independent clean-character capture.

Test evidence only. No captured records are runtime defaults or recovered RNG.
"""
import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TARGET = ROOT / 'remake/tests/fixtures/economy-reference.json'


def reference():
    capture = json.loads((ROOT/'docs/reference/remake-clean-character.json').read_text())
    markets_raw = bytes.fromhex(capture['records32Hex'])
    warehouses_raw = bytes.fromhex(capture['records16Hex'])
    markets, warehouses, phases = [], [], []
    # Independent word/field traversal, including each word's unused high bit.
    def unpack(raw, width, per_word):
        result = []
        for offset in range(0,len(raw),2):
            word = raw[offset] + 256*raw[offset+1]
            for _ in range(per_word):
                result.append(word % (1 << width))
                word >>= width
        return result
    for city in [*range(1,58),60]:
        record = markets_raw[(city-1)*32:city*32]
        markets.append(dict(cityId=f'city-{city:02}', demand=unpack(record[:14],3,5)[:31],
                            supply=unpack(record[14:28],3,5)[:31],
                            lastUpdateDay=int.from_bytes(record[28:30],'little',signed=True)))
        slots = []
        record = warehouses_raw[(city-1)*16:city*16]
        for offset in range(0,16,4):
            kind = record[offset] & 31
            slots.append(dict(commodityId=f'cargo-{kind:02}',quality=record[offset] >> 5,
                              originCity=f'city-{record[offset+1]:02}',
                              pricePaid=100*int.from_bytes(record[offset+2:offset+4],'little')) if kind else None)
        warehouses.append(dict(cityId=f'city-{city:02}',slots=slots))
    recipes = markets_raw[57*32:57*32+54]
    for offset in range(0,54,6):
        fields = unpack(recipes[offset:offset+6],5,3)[:8]
        phases.append([fields.count(i) for i in range(1,32)])
    return dict(source='docs/reference/remake-clean-character.json',
                selector=bytes.fromhex(capture['globalsHex'])[473],
                markets=markets,warehouses=warehouses,colonyRequirements=phases)


if __name__ == '__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write',action='store_true')
    args=parser.parse_args()
    value=reference()
    if args.write:
        TARGET.write_text(json.dumps(value,indent=2)+'\n')
    elif json.loads(TARGET.read_text()) != value:
        raise SystemExit('Stale economy reference')
    print(f'58 markets/warehouses and 9 colony recipes {"written" if args.write else "verified"}')
