#!/usr/bin/env python3
"""Project named equipment fields from the independent clean-character capture.

The draw tape is a constructed witness for the observed damage, NOT the original
random stream or seed. Neither this fixture nor the captured save is a runtime input.
"""
import argparse
import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
TARGET = ROOT / 'remake/tests/fixtures/equipment-reference.json'
IDS = ['warp-drives','sub-c-engines','ships-guns','tactical-display','force-shields','pilotage']

def reference():
    capture=json.loads((ROOT/'docs/reference/remake-clean-character.json').read_text())
    raw=bytes.fromhex(capture['globalsHex'])
    equipment,draws=[],[]
    for index,identifier in enumerate(IDS):
        record=raw[108+28*index:136+28*index]
        rows=[dict(components=list(record[r*5:r*5+4]),performance=record[r*5+4]) for r in range(4)]
        equipment.append(dict(id=identifier,units=rows,spares=list(record[20:24]),performance=record[24],requiredComponent=record[26],requiredSocket=record[27]))
        for row in rows:
            damaged=[i for i,value in enumerate(row['components']) if value in (0,7,23)]
            if not damaged:
                assert row['performance']==4
                draws.append(1)
            else:
                assert len(damaged)==1
                socket=damaged[0];value=row['components'][socket]
                draws.extend([0,socket,0 if value==23 else 1])
                if value!=23: draws.append(1 if value==0 else 0)
                assert row['performance']==(3 if value==23 else 0)
        draws.append(0)  # Fixed requirements row consumes a draw but is protected.
        assert record[24]==sum(row['performance'] for row in rows)
    return dict(source='docs/reference/remake-clean-character.json',
                scope='Observed equipment with constructed compatible draws; not an observed RNG sequence',
                equipment=equipment,draws=draws)

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--write',action='store_true');args=parser.parse_args()
    value=reference()
    if args.write: TARGET.write_text(json.dumps(value,indent=2)+'\n')
    elif json.loads(TARGET.read_text())!=value: raise SystemExit('Stale equipment reference')
    print(f'6 captured equipment records {"written" if args.write else "verified"}')
