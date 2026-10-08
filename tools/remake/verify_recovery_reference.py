#!/usr/bin/env python3
"""Verify retained R10p native damage/restart evidence and its declared scope."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REFERENCE = ROOT / 'docs/reference'


def verify():
    metadata = json.loads((REFERENCE / 'remake-recovery-reference.json').read_text())
    files = metadata['artifacts']
    assert len(files) == 26 and len({a['file'] for a in files}) == 26
    for artifact in files:
        path = REFERENCE / artifact['file']
        assert path.parent == REFERENCE
        assert hashlib.sha256(path.read_bytes()).hexdigest() == artifact['sha256'], path

    def read(name):
        return json.loads((REFERENCE / f'remake-recovery-{name}.json').read_text())

    setup = read('fatal-setup')
    prepared = setup['after']
    assert prepared['source']['vm']['ip'] - prepared['source']['vm']['segment'] + 0x10d0 == 0x084c
    assert prepared['state']['hull'] == 1
    assert prepared['state']['words']['217'] == 5
    assert prepared['state']['words']['225'] == 0
    assert prepared['state']['flags']['45'] is True
    assert prepared['source']['randomBytes'] == [28, 0, 0, 0]

    fatal, death, restored, continued = (read(n) for n in ['fatal', 'death-dispatch', 'restored', 'continued'])
    assert fatal['source']['status']['debugger'] == 'stop'
    assert fatal['source']['vm']['ip'] - fatal['source']['vm']['segment'] + 0x10d0 == 0x096a
    assert fatal['state']['words']['347'] == 1 and (fatal['state']['words']['45'] >> 8) & 15 == 12
    assert fatal['state']['hull'] == 1  # Stop precedes the final hull store.
    assert fatal['source']['randomBytes'] == [220, 15, 135, 195]
    assert death['source']['status']['debugger'] == 'stop'
    assert death['source']['vm']['ip'] - death['source']['vm']['segment'] + 0x074a == 0x04b2
    assert death['state']['hull'] == 0 and death['state']['words']['347'] == 1
    assert death['state']['condition'] == prepared['state']['condition']
    assert fatal['state']['words']['352'] == 2 and death['state']['words']['352'] == 3
    assert fatal['state']['clock'] == death['state']['clock'] == [18, 21, 0, 0]
    assert fatal['source']['randomBytes'] == death['source']['randomBytes']
    assert restored['state']['hull'] == continued['state']['hull'] == 16
    assert restored['state']['words']['347'] == continued['state']['words']['347'] == 0
    assert restored['state']['clock'] == [48, 16, 0, 0]
    assert restored['state']['condition'] == [227, 255, 255, 243]
    assert continued['state']['clock'] == [45, 17, 0, 0]
    assert restored['state']['location'] == continued['state']['location']
    assert restored['state']['equipment'] == continued['state']['equipment']

    receipts = json.loads((REFERENCE / 'remake-recovery-receipts.json').read_text())
    assert receipts['terminal'] == metadata['terminal']
    assert metadata['terminal']['live'] is False and metadata['terminal']['exitCode'] == 0
    for operation in receipts['operations'].values():
        assert operation['ok'] is True
    assert receipts['operations']['fatal-save']['result']['offset'] == 0x096a
    assert receipts['operations']['death-save']['result']['offset'] == 0x04b2
    assert receipts['operations']['release-final']['result']['released'] is True
    return {'status': 'pass', 'artifacts': len(files), 'nativeContexts': len(metadata['contexts']),
            'scope': 'declared fatal fixture; native death dispatch and saved-point continuation',
            'milestoneStatus': 'in progress'}


if __name__ == '__main__':
    print(json.dumps(verify(), indent=2))
