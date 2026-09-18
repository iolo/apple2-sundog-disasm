#!/usr/bin/env python3
"""Report source ownership of inventoried executable segments, without guessing gaps."""
import argparse
from collections import Counter
import json
from pathlib import Path

from disk_layout import ROOT


def report():
    manifest = json.loads((ROOT / 'reconstruction/manifest.json').read_text())
    inventory = json.loads((ROOT / 'docs/pascal-inventory.json').read_text())
    disks = {d['id']: d for d in manifest['disks']}
    segments = {}
    for header in inventory['headers']:
        for entry in header['entries']:
            if entry['status'] != 'valid-procedure-dictionary':
                continue
            row = segments.setdefault(entry['sha256'], dict(
                sha256=entry['sha256'], size=entry['length'], segment=entry['segment_number'],
                occurrences=[]))
            counts, components = Counter(), set()
            for extent in entry['image_ranges']:
                start, end = extent['offset'], extent['offset'] + extent['length']
                for region in disks[header['disk']]['regions']:
                    overlap = min(end, region['offset'] + region['size']) - max(start, region['offset'])
                    if overlap > 0:
                        counts[manifest['components'][region['input']]['kind']] += overlap
                        components.add(region['input'])
            if sum(counts.values()) != entry['length']:
                raise ValueError('Segment coverage disagrees with inventory')
            row['occurrences'].append(dict(disk=header['disk'], header=header['block'],
                start_block=entry['start_block'], coverage_bytes=dict(counts),
                components=sorted(components), complete_source=counts['ca65-source'] == entry['length']))
    rows = list(segments.values())
    for row in rows:
        row['all_copies_source_built'] = all(o['complete_source'] for o in row['occurrences'])
    return dict(scope='Source ownership of valid inventoried segments only; not a complete disk classification or semantic audit',
                unique_segments=len(rows), fully_source_built_segments=sum(r['all_copies_source_built'] for r in rows),
                remaining_unique_segments=sum(not r['all_copies_source_built'] for r in rows),
                original_inventory_status_counts=inventory['summary']['entry_status_counts'],
                remaining_work_outside_valid_segments=['Split system fragment', 'Orphan/header candidates',
                    'Assets and other data', 'Unallocated/preserved disk regions',
                    'Review provisional native-runtime data classifications'], segments=rows)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    result = report()
    if args.output:
        args.output.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k: result[k] for k in ('unique_segments', 'fully_source_built_segments', 'remaining_unique_segments')}))
    for row in result['segments']:
        if not row['all_copies_source_built']:
            print('Remaining:', row['segment'], row['size'], [(o['disk'], o['header'], o['start_block'], o['coverage_bytes']) for o in row['occurrences']])


if __name__ == '__main__':
    main()
