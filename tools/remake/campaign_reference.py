#!/usr/bin/env python3
"""Named start fields from the independent clean-character capture; test-only."""
import argparse
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
TARGET=ROOT/'remake/tests/fixtures/campaign-reference.json'


def reference():
    capture=json.loads((ROOT/'docs/reference/remake-clean-character.json').read_text())
    raw=bytes.fromhex(capture['globalsHex'])
    def location(offset):
        words=[int.from_bytes(raw[i:i+2],'little') for i in range(offset,offset+12,2)]
        return dict(systemId=f'system-{words[1]&15:02}',worldId=f'world-{(words[1]>>4)&31:02}',
                    cityId=f'city-{(words[1]>>9)&63:02}',
                    orbit=dict(angle=words[0]&255,radius=words[0]>>8),
                    surfacePosition=dict(x=words[2]&63,y=words[3]&31),
                    cityPosition=dict(x=words[2]>>8,y=words[3]>>8),
                    position=dict(x=words[4],y=words[5]&255))
    return dict(source='docs/reference/remake-clean-character.json',
                playerLocation=location(0),shipLocation=location(72),
                gameplayRandomState=int.from_bytes(raw[56:60],'little'),
                credits=1000*int.from_bytes(raw[20:22],'little')+int.from_bytes(raw[22:24],'little'))


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write',action='store_true');args=parser.parse_args()
    value=reference()
    if args.write: TARGET.write_text(json.dumps(value,indent=2)+'\n')
    elif json.loads(TARGET.read_text())!=value: raise SystemExit('Stale campaign reference')
    print(f'Player/ship locations, saved RNG and cash {"written" if args.write else "verified"}')
