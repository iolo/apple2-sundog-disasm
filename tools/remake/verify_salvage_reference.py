#!/usr/bin/env python3
"""Verify or retain the declared R10s native Tractor continuation evidence."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[2]
REFERENCE = ROOT / 'docs/reference'
PREFIX = 'remake-salvage-'
OFFSETS = {'main': 0x1388, 'entry': 0x0fca,
           **{'loop-' + str(n): 0x1048 for n in range(1, 6)},
           'copied': 0x1072, 'complete': 0x1096,
           'menu-before': 0x0f19, 'menu-after': 0x0f2b, 'returned': 0x1388}


def verify_contexts(read, receipts, terminal):
    assert terminal['exitCode'] == 0 and terminal['clean'] is True
    assert all(r['ok'] is True for r in receipts)
    operations = {r['id']: r for r in receipts}
    assert len(operations) == len(receipts)
    assert operations['release']['result']['released'] is True
    assert operations['exit']['result']['scheduled'] == 'exit'
    owned = {r['result']['id'] for r in receipts if r['id'].endswith('-bp')}
    cleared = {int(r['id'].removeprefix('clear-')) for r in receipts
               if r['id'].startswith('clear-') and r['result']['cleared'] is True}
    assert operations['loop-clear']['result']['cleared'] is True
    cleared.add(operations['loop-bp']['result']['id'])
    assert owned == cleared
    setup = read('setup')
    assert setup['scope'] == 'declared wreck/empty-slot/source-command-entry fixture'
    assert setup['commandOffset'] == 0x148e and setup['slot2'] == [0]*4
    assert setup['localEdits'] == {'4': 3, '14': 0, '27': 1, '28': 0, '29': 0,
                                 '31': 0, '32': 0, '33': 0, '34': 217, '35': 0}
    prepared = setup['after']
    assert prepared['context']['source']['vm']['ip'] - prepared['context']['segmentBase'] == 0x148e
    captures = {name: read(name) for name in OFFSETS}
    for name, value in captures.items():
        source = value['source']
        assert source['vm']['ip'] - value['segmentBase'] == OFFSETS[name], name
        assert source['vm']['segment'] - value['segmentBase'] == 0x15a8, name
        assert source['status']['driver'] == 'apple2e'
        assert source['status']['version'] == '0.285'
        assert source['status']['debugger'] == 'stop' and source['status']['paused'] is True
        assert source['cpu']['PC'] == 0xd293
    entry = captures['entry']
    assert entry['podRecords'][4:] == [0]*4 and entry['state']['words']['217'] == 21
    random_bytes = entry['source']['randomBytes']
    clock = entry['state']['clock']
    assert random_bytes == [209, 34, 130, 18] and clock == [18, 21, 0, 0]
    initial_phase = entry['state']['words']['352']
    assert initial_phase == 1 and entry['state']['words']['226'] == 68
    for n, expected_range in enumerate([17, 13, 9, 5, 1], 1):
        value = captures['loop-' + str(n)]
        assert value['state']['words']['217'] == expected_range
        assert value['state']['words']['207'] == 65532
        assert value['state']['words']['354'] == n
        assert value['state']['words']['352'] == (1 if n < 5 else 2)
        assert value['state']['words']['226'] == 68
        assert value['source']['frames'][0]['locals']['1'] == 2
        assert value['podRecords'] == entry['podRecords']
        assert value['state']['flags']['36'] is True
    copied, complete, before, after, returned = (captures[n] for n in
                                                ['copied', 'complete', 'menu-before', 'menu-after', 'returned'])
    for value in [copied, complete, before, after, returned]:
        assert value['podRecords'] == entry['podRecords'][:4] + [217, 0, 0, 0]
        assert value['state']['words']['217'] == 1 and value['state']['words']['354'] == 5
    assert copied['state']['flags']['36'] is True
    for value in [complete, before, after, returned]:
        assert value['state']['flags']['36'] is False
        parent = next(frame for frame in value['source']['frames'] if frame['localBytes'] == 94)
        assert parent['locals']['27'] == 0 and parent['locals']['4'] == 3
    assert before['state']['words']['352'] == 2 and before['state']['words']['226'] == 68
    for value in [after, returned]:
        assert value['state']['words']['352'] == 3 and value['state']['words']['226'] == 60
    for value in captures.values():
        if value is captures['main']:
            continue  # Before the declared fixture, actual cargo/contact differ.
        assert value['source']['randomBytes'] == random_bytes
        assert value['state']['clock'] == clock
        for owner in ['condition', 'attributes', 'carried', 'location', 'equipment', 'hull']:
            assert value['state'][owner] == entry['state'][owner]
    return {'status': 'pass', 'nativeContexts': len(captures),
            'scope': 'declared Tractor entry; full native pull, copy, release-menu poll and main return',
            'milestoneStatus': 'in progress'}


def retain(directory):
    read = lambda name: json.loads((directory / (name + '.json')).read_text())
    receipts = read('receipts')
    terminal = read('terminal')
    verify_contexts(read, receipts, terminal)
    names = ['setup.json'] + [name + ext for name in OFFSETS for ext in ['.json', '.png']]
    for name in names:
        shutil.copyfile(directory / name, REFERENCE / (PREFIX + name))
    receipt_name = PREFIX + 'receipts.json'
    (REFERENCE / receipt_name).write_text(json.dumps({'operations': receipts, 'terminal': terminal}, indent=2) + '\n')
    names = [PREFIX + name for name in names] + [receipt_name]
    metadata = {
        'date': '2026-10-08', 'checkpoint': 'R10s',
        'emulator': 'MAME0.285 / unenhanced apple2e / joystick / owned Qt debugger',
        'scope': 'Declared wreck, empty pod slot2 and original Tractor case-entry fixture. Not native menu selection, a new kill or ordinary fresh-character acceptance.',
        'bootstrapSequence': 'docs/reference/game-play.json through frame18000 on disposable media',
        'helpers': ['tools/remake/' + name for name in ['encounter_reference.lua', 'ground_reference.lua',
                    'tactical_reference.lua', 'tactical_input_reference.lua', 'salvage_reference.lua']],
        'runner': 'tools/remake/capture_salvage_reference.py',
        'terminal': terminal,
        'contexts': [{'file': PREFIX + name + '.json', 'game12Offset': f'0x{offset:04x}'}
                     for name, offset in OFFSETS.items()],
        'observed': ['Five pulls21->17->13->9->5->1; drift-4 and source counter1..5.',
                     'Slot2 selected; slot1 retained; copy217/0 follows the due phase1->2.',
                     'Copy precedes inhibition/parent-wreck clearing.',
                     'Proc15 release poll calls proc12 without incrementing354; phase2->3 and gun68->60 before main returns.',
                     'RNG, clock, equipment, condition and carried inventory unchanged in this prepared vector.'],
        'notProven': ['Native menu reachability by this probe; the command entry is explicitly redirected.',
                      'Naturally won kill, ordinary fresh-character space encounter, reward224, fatal startup or Comm return.'],
        'artifacts': [{'file': name, 'sha256': hashlib.sha256((REFERENCE / name).read_bytes()).hexdigest()}
                      for name in names],
    }
    (REFERENCE / (PREFIX + 'reference.json')).write_text(json.dumps(metadata, indent=2) + '\n')


def verify():
    metadata = json.loads((REFERENCE / (PREFIX + 'reference.json')).read_text())
    files = metadata['artifacts']
    assert len(files) == 26 and len({a['file'] for a in files}) == 26
    for artifact in files:
        path = REFERENCE / artifact['file']
        assert path.parent == REFERENCE
        assert hashlib.sha256(path.read_bytes()).hexdigest() == artifact['sha256'], path
    receipt = json.loads((REFERENCE / (PREFIX + 'receipts.json')).read_text())
    assert receipt['terminal'] == metadata['terminal']
    read = lambda name: json.loads((REFERENCE / (PREFIX + name + '.json')).read_text())
    result = verify_contexts(read, receipt['operations'], receipt['terminal'])
    result['artifacts'] = len(files)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--retain', type=Path, help='retain a completed owned capture directory')
    args = parser.parse_args()
    if args.retain:
        retain(args.retain.resolve())
    print(json.dumps(verify(), indent=2))
