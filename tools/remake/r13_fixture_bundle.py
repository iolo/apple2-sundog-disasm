#!/usr/bin/env python3
"""Verify or restore small compressed checkpoints from the ordinary R11 campaign."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BUNDLE = ROOT / 'tools/remake/fixtures/r13'
OUTPUT = ROOT / 'output/playwright/remake'
STAGES = {
    'r11-phase-one-checkpoint.json': (2, 4, 'colony'),
    'r11-phase-two-complete.json': (3, 10, 'colony'),
    'r11-phase-five-complete.json': (6, 30, 'colony'),
    'r11-phase-eight-complete.json': (9, 53, 'colony'),
    'r11-phase-nine-cryo57-loaded.json': (9, 60, 'exchange'),
    'r11-phase-nine-cryo57-delivered.json': (10, 61, 'colony'),
}


def inspect(name, raw):
    value = json.loads(raw)
    state = value['state']
    phase, receipts, scene = STAGES[name]
    assert value['format'] == 'sundog-campaign' and value['version'] == 30
    assert value['scope'] == 'colony-contract-1' and state['travel']['scene'] == scene
    assert state['colony']['activePhase'] == phase and len(state['colony']['receipts']) == receipts
    return {'sha256': hashlib.sha256(raw).hexdigest(), 'bytes': len(raw),
            'activePhase': phase, 'receipts': receipts, 'scene': scene}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--pack', action='store_true', help='Build the bundle from local R11 output')
    parser.add_argument('--restore', action='store_true', help='Restore missing fixture files to output/playwright/remake')
    args = parser.parse_args()
    if args.pack:
        BUNDLE.mkdir(parents=True, exist_ok=True)
        manifest = {}
        for name in STAGES:
            raw = (OUTPUT / name).read_bytes()
            manifest[name] = inspect(name, raw)
            (BUNDLE / f'{name}.gz').write_bytes(gzip.compress(raw, compresslevel=9, mtime=0))
        (BUNDLE / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    manifest = json.loads((BUNDLE / 'manifest.json').read_text())
    assert set(manifest) == set(STAGES)
    restored = 0
    for name in STAGES:
        raw = gzip.decompress((BUNDLE / f'{name}.gz').read_bytes())
        assert inspect(name, raw) == manifest[name], f'Fixture mismatch: {name}'
        if args.restore:
            OUTPUT.mkdir(parents=True, exist_ok=True)
            path = OUTPUT / name
            if path.exists():
                assert path.read_bytes() == raw, f'Existing checkpoint differs; preserved: {path}'
            else:
                path.write_bytes(raw)
                restored += 1
    print(json.dumps({'fixtures': len(STAGES), 'restored': restored, 'status': 'pass'}))


if __name__ == '__main__':
    main()
