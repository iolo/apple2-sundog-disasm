#!/usr/bin/env python3
"""Keep a reviewable receipt for a journey that emits full diagnostic states."""
import argparse
import hashlib
import json
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('full', type=Path)
    parser.add_argument('summary', type=Path)
    args = parser.parse_args()
    result = json.loads(args.full.read_text())
    assert not result.get('errors') and not result.get('failures') and result.get('checks')
    states = result['states']
    digest = {name: (state.get('stateHash') if isinstance(state, dict) else None) or
              hashlib.sha256(json.dumps(state, sort_keys=True).encode()).hexdigest()
              for name, state in states.items()}
    final = next((states[key] for key in ('collected', 'peaceful', 'escaped') if key in states), next(reversed(states.values())))
    omitted = {'states', 'pose'} | {key for key in result if key.lower().endswith('samples')}
    compact = {key: value for key, value in result.items() if key not in omitted}
    compact['stageHashes'] = digest
    compact['diagnosticCounts'] = {key: len(result[key]) for key in omitted - {'states'} if key in result}
    if 'resources' in final:
        compact['final'] = {
            'hull': final['resources']['hull'], 'fuel': final['resources']['fuel'],
            'homeBank': final['accounts'][0]['balance'], 'podCargo': final['pod']['cargo'],
            'bounties': final['space']['bounties'], 'losses': final['space']['losses'],
        }
    else:
        compact['final'] = {
            'cash': final['cash'], 'homeBank': final['accounts'][0]['balance'],
            'rewards': final['combat']['rewards'], 'defeat': final['combat']['defeat'],
        }
    args.summary.write_text(json.dumps(compact, ensure_ascii=False, indent=2) + '\n')
    checks = len(result['checks']) if isinstance(result['checks'], list) else result['checks']
    print(json.dumps({'checks': checks, 'stages': len(digest), 'status': 'pass'}))


if __name__ == '__main__':
    main()
