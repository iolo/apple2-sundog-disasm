#!/usr/bin/env python3
"""Retain and verify the declared native reward224 zero-divisor observation."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[2]
REF = ROOT / 'docs/reference'
PREFIX = 'remake-reward-'
CONTEXTS = {
    'main': (12, 0x1388), 'comm-store': (12, 0x1320),
    'reward-entry': (16, 0x1252), 'rare': (16, 0x1368),
    'requested': (16, 0x137b), 'bank-read': (16, 0x115c),
    'bank-loaded': (16, 0x115f), 'header-test': (16, 0x0ee0),
    'header-return': (16, 0x0f69), 'record': (16, 0x1163),
    'record-mode': (16, 0x0d7c), 'zero-selector': (16, 0x0a34),
    'zero-modulus': (16, 0x0a36), 'zero-error': (16, 0x0a36),
}
SIZES = {12: 0x15a8, 16: 0x1d14}


def check(read, operations, terminal):
    assert terminal['clean'] is True and terminal['exitCode'] == 0
    assert all(r['ok'] for r in operations)
    by_id = {r['id']: r for r in operations}
    assert len(by_id) == len(operations)
    assert by_id['release']['result']['released'] is True
    assert by_id['exit']['result']['scheduled'] == 'exit'
    owned = {r['result']['id'] for r in operations if r['id'].endswith('-bp')}
    cleared = {by_id[r['id'].removesuffix('-clear') + '-bp']['result']['id']
               for r in operations if r['id'].endswith('-clear') and r['result']['cleared']}
    assert owned == cleared
    values = {name: read(name) for name in CONTEXTS}
    for name, (segment, offset) in CONTEXTS.items():
        src = values[name]['source']
        assert src['vm']['ip'] - src['vm']['segment'] + SIZES[segment] == offset, name
        assert src['status']['driver'] == 'apple2e' and src['status']['version'] == '0.285'
        assert src['status']['debugger'] == 'stop' and src['status']['paused'] is True
        assert src['cpu']['PC'] == (0xd7ed if name == 'zero-error' else 0xd293)
    assert read('comm-entry')['commandOffset'] == 0x1458
    setup = read('reward-setup')['after']
    assert setup['mainLocals']['1'] == 18 and setup['colonyProgress'] == 2
    assert setup['flag125'] is False and setup['source']['randomBytes'] == [23, 0, 0, 0]
    rare = values['rare']
    assert rare['flag125'] is False and rare['source']['randomBytes'] == [151, 11, 0, 0]
    bank = next(b for b in json.loads((ROOT / 'docs/remake/r10f-reward-bank-audit.json').read_text())['banks'] if b['block'] == 103)
    assert values['bank-loaded']['entryPrefix'][:32] == bank['first32Bytes']
    assert values['bank-read']['mainLocals']['39'] == 13
    assert values['header-return']['source']['frames'][0]['locals']['4'] == 76
    assert values['header-return']['dictionaryPrefix'] != values['header-test']['dictionaryPrefix']
    assert values['record-mode']['source']['frames'][0]['locals']['10'] == 0
    assert values['record-mode']['mainLocals']['38'] == 1
    assert values['zero-selector']['source']['frames'][0]['locals']['6'] == 0
    assert values['zero-modulus']['evaluationStack']['bytes'][:4] == [0, 0, 5, 75]
    # MODI pops divisor0 and dividend19205, then reaches the actual zero trap.
    for name in ['requested', 'bank-read', 'bank-loaded', 'header-test',
                 'header-return', 'record', 'record-mode', 'zero-selector',
                 'zero-modulus', 'zero-error']:
        d = values[name]
        assert d['flag125'] is True
        assert [d['mainLocals'][str(n)] for n in [100, 101, 106, 107]] == [10, 0, 10, 0]
        assert [d['mainLocals'][str(n)] for n in [104, 105]] == [20, 580]
        assert d['state']['clock'] == rare['state']['clock'] == [18, 21, 0, 0]
        for key in ['condition', 'equipment', 'attributes', 'carried', 'location']:
            assert d['state'][key] == rare['state'][key]
        assert d['source']['randomBytes'] == ([151, 203, 5, 0] if name.startswith('zero-') else [151, 11, 0, 0])
    error = read('error')['source']
    assert error['status']['paused'] is True
    assert error['randomBytes'] == [151, 203, 5, 0]
    assert error['vm']['segment'] != values['zero-error']['source']['vm']['segment']
    return {'status': 'pass', 'nativeContexts': len(values), 'milestoneStatus': 'in progress',
            'observation': 'Declared kind18 rare branch reaches original zero-divisor trap; no dialogue return or cash award proven'}


def retain(directory):
    read = lambda n: json.loads((directory / (n + '.json')).read_text())
    operations, terminal = read('receipts'), read('terminal')
    check(read, operations, terminal)
    names = ['comm-entry.json', 'reward-setup.json', 'error.json', 'error.png'] + [n + ext for n in CONTEXTS for ext in ['.json', '.png']]
    for name in names:
        shutil.copyfile(directory / name, REF / (PREFIX + name))
    (REF / (PREFIX + 'receipts.json')).write_text(json.dumps({'operations': operations, 'terminal': terminal}, indent=2) + '\n')
    names = [PREFIX + n for n in names] + [PREFIX + 'receipts.json']
    meta = {'date': '2026-10-08', 'checkpoint': 'R10x',
            'emulator': 'MAME0.285 / unenhanced apple2e / owned Qt debugger',
            'scope': 'Existing original Comm activation; declared kind18, colony progress2, flag125false and RNG23 at Game16 proc39 entry. No ordinary reward reachability.',
            'runner': 'tools/remake/capture_reward_reference.py', 'terminal': terminal,
            'contexts': [{'file': PREFIX + n + '.json', 'segment': seg, 'offset': hex(offset)} for n, (seg, offset) in CONTEXTS.items()],
            'notProven': ['Ordinary rare-branch reachability', 'Successful reward dialogue return', '10000Cr award', 'Final playable browser exception handling'],
            'artifacts': [{'file': n, 'sha256': hashlib.sha256((REF / n).read_bytes()).hexdigest()} for n in names]}
    (REF / (PREFIX + 'reference.json')).write_text(json.dumps(meta, indent=2) + '\n')


def verify():
    meta = json.loads((REF / (PREFIX + 'reference.json')).read_text())
    assert len(meta['artifacts']) == len({a['file'] for a in meta['artifacts']}) == 33
    for artifact in meta['artifacts']:
        path = REF / artifact['file']
        assert path.parent == REF
        assert hashlib.sha256(path.read_bytes()).hexdigest() == artifact['sha256']
    receipts = json.loads((REF / (PREFIX + 'receipts.json')).read_text())
    assert receipts['terminal'] == meta['terminal']
    result = check(lambda n: json.loads((REF / (PREFIX + n + '.json')).read_text()), receipts['operations'], receipts['terminal'])
    result['artifacts'] = len(meta['artifacts'])
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--retain', type=Path)
    args = parser.parse_args()
    if args.retain:
        retain(args.retain.resolve())
    print(json.dumps(verify(), indent=2))
