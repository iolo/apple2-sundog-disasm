#!/usr/bin/env python3
"""Run the reconstructed library22 RNG loop on sim65, with a cc65 ABI wrapper."""
import argparse
import json
from pathlib import Path
import re
import subprocess
import tempfile
ROOT = Path(__file__).resolve().parents[2]
TARGET = ROOT / 'remake/tests/fixtures/random-reference.json'

def reference():
    source = (ROOT / 'src/pcode/library_22.s').read_text()
    loop = source[source.index('L_0C00:'):source.index('L_0C1F:')]
    loop = re.sub(r' ;.*', '', loop)
    for offset in range(4):
        loop = loop.replace(f'a:${0x28+offset:04X}', f'a:_random_state+{offset}')
    asm = '.export _random_next, _random_state\n.segment "BSS"\n_random_state: .res 4\n.segment "CODE"\n_random_next:\n' + loop
    # Original Pascal ABI pushes high result byte then low; cc65 returns A/X.
    asm += 'lda _random_state\nlsr a\ntax\nlda _random_state+2\nrts\n'
    with tempfile.TemporaryDirectory(prefix='sundog-rng-') as folder:
        folder = Path(folder)
        (folder/'rng.s').write_text(asm)
        (folder/'driver.c').write_text((ROOT/'tools/remake/random_reference.c').read_text())
        subprocess.run(['cl65','-t','sim6502','-o',str(folder/'rng'),str(folder/'driver.c'),str(folder/'rng.s')],check=True,cwd=folder)
        return json.loads(subprocess.check_output(['sim65',str(folder/'rng')],text=True))

if __name__ == '__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--write',action='store_true');args=parser.parse_args()
    values=reference()
    if args.write: TARGET.write_text(json.dumps(values,indent=2)+'\n')
    elif json.loads(TARGET.read_text())!=values: raise SystemExit('Stale native RNG reference')
    print(f'{sum(len(v["draws"]) for v in values)} native RNG transitions {"written" if args.write else "verified"}')
