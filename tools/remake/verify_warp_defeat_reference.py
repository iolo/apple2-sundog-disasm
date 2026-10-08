#!/usr/bin/env python3
"""Retain and verify declared native Warp death and healthy-control captures."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
from verify_startup_defeat_reference import REF, SIZES

PREFIX = 'remake-warp-defeat-'
SIZES = {**SIZES, 13: 0x27e4}
CONTEXTS = {
    'main': (12, 0x1388), 'ship-main': (13, 0x269d),
    'nav-poll': (13, 0x2368), 'action-first-call': (13, 0x1f94),
    'fire-before': (24, 0x084c), 'fatal': (24, 0x096a),
    'action-first-after': (13, 0x1f97), 'warp-entry': (13, 0x1760),
    'warp-post-call': (13, 0x18da), 'warp-post-return': (13, 0x18dd),
    'nav-return': (13, 0x1fd4), 'nav-action-return': (13, 0x241a),
    'nav-not': (13, 0x241b), 'nav-test': (13, 0x241c),
    'nav-exit': (13, 0x2442), 'ship-nav-return': (13, 0x2685),
    'death': (7, 0x04b2),
}
RECTANGLE = [13, 0, 4, 0, 9, 1, 245, 0]


def check(read, operations, terminal, healthy):
    assert terminal['clean'] and terminal['exitCode'] == 0
    assert all(r['ok'] for r in operations)
    by_id = {r['id']: r for r in operations}
    assert len(by_id) == len(operations)
    assert by_id['release']['result']['released']
    assert by_id['exit']['result']['scheduled'] == 'exit'
    owned = {r['result']['id'] for r in operations if r['id'].endswith('-bp')}
    cleared = {by_id[{'action-first-clear':'action-first-call-bp'}.get(r['id'],r['id'].removesuffix('-clear') + '-bp')]['result']['id']
               for r in operations if r['id'].endswith('-clear') and r['result']['cleared']}
    cleared.update(int(r['id'].removeprefix('clear-')) for r in operations
                   if r['id'].startswith('clear-') and r['result']['cleared'])
    assert owned == cleared
    names = [n for n in CONTEXTS if n != 'death' or not healthy]
    values = {n: read(n) for n in names}
    for name in names:
        segment, offset = CONTEXTS[name]
        src = values[name]['source']
        assert src['vm']['ip'] - src['vm']['segment'] + SIZES[segment] == offset, name
        assert src['status']['driver'] == 'apple2e' and src['status']['version'] == '0.285'
        assert src['status']['paused'] and src['status']['debugger'] == 'stop'
        assert src['cpu']['PC'] == 0xd293
    assert read('exit-setup')['before']['context']['source']['vm']['ip'] - read('exit-setup')['before']['context']['segmentBase'] == 0x1388
    choice = read('choice-setup')
    assert choice['after']['frames'][0]['locals']['8'] == 7
    assert choice['after']['frames'][0]['locals']['6'] == 1
    assert choice['after']['frames'][0]['locals']['7'] == 0
    prepared = read('fatal-setup')['after']
    assert prepared['source']['randomBytes'] == [28, 0, 0, 0]
    assert prepared['state']['hull'] == 1 and prepared['state']['flags']['45']
    if healthy:
        control = read('healthy-setup')
        assert control['before']['hull'] == 1 and control['after']['hull'] == 100
        assert control['before']['words'] == control['after']['words']
        assert control['before']['equipment'] == control['after']['equipment']
    expected_hull = 91 if healthy else 0
    before_jump = [220, 19, 249, 195] if healthy else [220, 15, 135, 195]
    after_jump = [31, 238, 137, 252] if healthy else [31, 238, 135, 195]
    vector = values['action-first-call']['opcodeVector']
    for name in names[names.index('action-first-call'):]:
        d = values[name]
        assert d['statusRectangle307'] == RECTANGLE, name
        assert d['opcodeVector'] == vector, name
        assert d['state']['clock'] == [18, 21, 0, 0]
        assert d['state']['condition'] == [237, 235, 255, 228]
    for name in ['action-first-after', 'warp-entry', 'warp-post-call', 'warp-post-return',
                 'nav-return', 'nav-action-return', 'nav-not', 'nav-test',
                 'nav-exit', 'ship-nav-return'] + ([] if healthy else ['death']):
        d = values[name]; w = d['state']['words']
        jumped = name not in ['action-first-after', 'warp-entry']
        phase = 2 if name in ['action-first-after', 'warp-entry', 'warp-post-call'] else 4 if name in ['nav-exit', 'ship-nav-return', 'death'] else 3
        assert tuple(w[k] for k in ['352', '226', '215', '217', '354', '347']) == (
            phase, 68 if phase == 2 else 60, 40, 5, 6 if jumped else 3, 0 if healthy else 1), name
        assert d['state']['hull'] == expected_hull
        assert d['source']['randomBytes'] == (after_jump if jumped else before_jump)
        assert d['state']['flags']['40'] == (not jumped)
        if jumped:
            assert d['currentLocation'] == [16, 43, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        for key in ['equipment', 'attributes', 'carried', 'condition']:
            assert d['state'][key] == values['warp-entry']['state'][key]
    assert values['nav-exit']['selectedLocation'] == values['nav-exit']['currentLocation']
    if not healthy:
        assert values['death']['state']['flags']['0'] is False
        assert values['death']['state']['words']['222'] == values['death']['state']['words']['223'] == 0
    return len(names)


def retain(directory, healthy):
    read = lambda n: json.loads((directory / (n + '.json')).read_text())
    operations, terminal = read('receipts'), read('terminal')
    count = check(read, operations, terminal, healthy)
    tag = 'healthy-' if healthy else 'fatal-'
    names = ['exit-setup.json', 'nav-setup.json', 'choice-setup.json', 'fatal-setup.json']
    if healthy: names.append('healthy-setup.json')
    contexts = {n: v for n, v in CONTEXTS.items() if n != 'death' or not healthy}
    names += [n + ext for n in contexts for ext in ['.json', '.png']]
    for name in names: shutil.copyfile(directory / name, REF / (PREFIX + tag + name))
    receipts = PREFIX + tag + 'receipts.json'
    (REF / receipts).write_text(json.dumps({'operations': operations, 'terminal': terminal}, indent=2) + '\n')
    retained = [PREFIX + tag + n for n in names] + [receipts]
    meta = {
        'date': '2026-10-08', 'checkpoint': 'R10aa', 'healthyControl': healthy,
        'emulator': 'MAME0.285 / unenhanced apple2e / owned Qt debugger',
        'scope': 'Declared Game12 exit, original Nav call/command7 re-entry, source Game15 status-window geometry, charged target11 and prepared pending hit; original Warp and return code. No ordinary reachability.',
        'runner': 'tools/remake/capture_warp_defeat_reference.py', 'terminal': terminal,
        'nativeContexts': count,
        'contexts': [{'file': PREFIX + tag + n + '.json', 'segment': seg, 'offset': hex(offset)} for n, (seg, offset) in contexts.items()],
        'notProven': ['Browser fatal Warp host integration', 'Fatal gravity-failure return', 'Ordinary campaign Warp defeat reachability'],
        'artifacts': [{'file': n, 'sha256': hashlib.sha256((REF / n).read_bytes()).hexdigest()} for n in retained],
    }
    (REF / (PREFIX + tag + 'reference.json')).write_text(json.dumps(meta, indent=2) + '\n')


def verify():
    contexts = artifacts = 0
    for healthy, tag in [(True, 'healthy-'), (False, 'fatal-')]:
        meta = json.loads((REF / (PREFIX + tag + 'reference.json')).read_text())
        assert meta['healthyControl'] == healthy
        assert len(meta['artifacts']) == len({a['file'] for a in meta['artifacts']})
        for a in meta['artifacts']:
            p = REF / a['file']; assert p.parent == REF
            assert hashlib.sha256(p.read_bytes()).hexdigest() == a['sha256']
        receipts = json.loads((REF / (PREFIX + tag + 'receipts.json')).read_text())
        assert receipts['terminal'] == meta['terminal']
        count = check(lambda n: json.loads((REF / (PREFIX + tag + n + '.json')).read_text()), receipts['operations'], receipts['terminal'], healthy)
        assert count == meta['nativeContexts']
        contexts += count; artifacts += len(meta['artifacts'])
    return {'status': 'pass', 'nativeContexts': contexts, 'artifacts': artifacts, 'milestoneStatus': 'in progress'}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--retain-healthy', type=Path)
    parser.add_argument('--retain-fatal', type=Path)
    args = parser.parse_args()
    if args.retain_healthy: retain(args.retain_healthy.resolve(), True)
    if args.retain_fatal: retain(args.retain_fatal.resolve(), False)
    print(json.dumps(verify(), indent=2))
