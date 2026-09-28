#!/usr/bin/env python3
"""Named start fields from the independent clean-character capture; test-only."""
import argparse
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
TARGET=ROOT/'remake/tests/fixtures/campaign-reference.json'


def decode_globals(raw):
    if len(raw)!=512: raise ValueError('Expected 512 globals bytes')
    def word(index):
        offset=(index-36)*2
        return int.from_bytes(raw[offset:offset+2],'little')
    flags=word(82)
    def location(offset):
        words=[int.from_bytes(raw[i:i+2],'little') for i in range(offset,offset+12,2)]
        return dict(systemId=f'system-{words[1]&15:02}',worldId=f'world-{(words[1]>>4)&31:02}',
                    cityId=f'city-{(words[1]>>9)&63:02}',
                    orbit=dict(angle=words[0]&255,radius=words[0]>>8),
                    surfacePosition=dict(x=words[2]&63,y=words[3]&31),
                    cityPosition=dict(x=words[2]>>8,y=words[3]>>8),
                    position=dict(x=words[4],y=words[5]&255))
    return dict(playerLocation=location(0),shipLocation=location(72),
                destinationLocation=location(60),podLocation=location(384),
                podAttached=bool(flags & (1<<7)),
                shipResources=dict(hull=raw[300],fuel=word(227),
                    warp=dict(charge=word(223),targetCharge=word(222),
                              targetSystemId=f'system-{word(221):02}' if word(221) else None,
                              charging=bool(flags & 1)),
                    shields=dict(charge=word(225),targetCharge=word(224)),
                    guns=dict(charge=word(226),powered=bool(flags & 4)),
                    enginesPowered=bool(flags & 2)),
                gameplayRandomState=int.from_bytes(raw[56:60],'little'),
                credits=1000*int.from_bytes(raw[20:22],'little')+int.from_bytes(raw[22:24],'little'))


def reference():
    capture=json.loads((ROOT/'docs/reference/remake-clean-character.json').read_text())
    return dict(source='docs/reference/remake-clean-character.json',
                **decode_globals(bytes.fromhex(capture['globalsHex'])))


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write',action='store_true');args=parser.parse_args()
    value=reference()
    if args.write: TARGET.write_text(json.dumps(value,indent=2)+'\n')
    elif json.loads(TARGET.read_text())!=value: raise SystemExit('Stale campaign reference')
    print(f'Four locations, ship resources, saved RNG and cash {"written" if args.write else "verified"}')
