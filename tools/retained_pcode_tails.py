#!/usr/bin/env python3
"""Review three fixed short tails against their complete decoded source modules."""
import argparse
from collections import Counter
import json
import subprocess

from adopt_component import source_copy_plan
from build_disks import contained_file
from disk_layout import ROOT, logical_sector_offset, sha
from pcode_copies import copy_items, verify_ownership
from pcode_source import analyze, verify_interpreter

EVIDENCE = 'docs/retained-short-tails.md'
AUDIT = ROOT/'docs/reference/retained-short-tails.json'
# Explicit reviewed copies, not a general lower match-length threshold.
COPIES = [
    dict(disk='disk1', block=173, byte_offset=368, size=28, component='alternate_10',
         input_offset=922, sha256='95c721ad7392dad4bfb482607b7216788daa6622e98ef2e0a620400fadfb0b99'),
    dict(disk='disk2', block=173, byte_offset=486, size=26, component='game_13',
         input_offset=9702, sha256='cb38654efe3233a17586c8faa3c49655f5b3a612357605cd58034b21358ecbc9'),
    dict(disk='disk2', block=189, byte_offset=496, size=16, component='game_14',
         input_offset=2032, sha256='5144b2d83940c22f77e26c9433f881d4c47e24fb5dc8a7ccfaeb4adf18a5e3d3'),
]


def run(adopt=False, verify=False):
    manifest_path = ROOT/'reconstruction/manifest.json'
    manifest = json.loads(manifest_path.read_text())
    images = {d['id']: (ROOT/'build/disks'/d['filename']).read_bytes() for d in manifest['disks']}
    for disk in manifest['disks']:
        if sha(images[disk['id']]) != disk['sha256']:
            raise ValueError('Rebuild exact baseline before reviewing tails')
    interpreter = (ROOT/'build/disks/components/pcode_primitives.bin').read_bytes()
    if sha(interpreter) != manifest['components']['pcode_primitives']['sha256']:
        raise ValueError('Interpreter baseline differs')
    verify_interpreter(interpreter)
    output = ROOT/'build/retained-short-tails'
    output.mkdir(parents=True, exist_ok=True)
    binaries, records, mappings, counts = {}, [], [], Counter()
    for row in COPIES:
        name = row['component']
        spec = manifest['components'][name]
        if spec['kind'] != 'ca65-source' or 'storage_encoding' in spec:
            raise ValueError('Expected an ordinary p-code source component')
        source, config = (contained_file(ROOT, spec[k]) for k in ('source', 'config'))
        obj, binary = output/(name+'.o'), output/(name+'.bin')
        subprocess.run(['ca65', '-I', str(source.parent), str(source), '-o', str(obj)], check=True)
        subprocess.run(['ld65', '-C', str(config), str(obj), '-o', str(binary)], check=True)
        raw = binary.read_bytes()
        summary_path = ROOT/'docs/reference/pcode-modules'/f'{name}.json'
        summary = json.loads(summary_path.read_text())
        if len(raw) != spec['size'] or sha(raw) != spec['sha256'] or sha(raw) != summary['sha256']:
            raise ValueError('Source or complete module audit differs')
        report = analyze(raw, summary['segment'], extra_code_roots=summary.get('extra_code_roots', []))
        if (any(report[key] != summary[key] for key in ('coverage_bytes',
                'instruction_count', 'procedure_count', 'instructions_by_mnemonic'))
                or len(report['control_flow_edges']) != summary['control_flow_edges']):
            raise ValueError('Complete source classification differs')
        start, size = row['input_offset'], row['size']
        selected = raw[start:start+size]
        if len(selected) != size or sha(selected) != row['sha256']:
            raise ValueError('Reviewed tail differs')
        items = copy_items(report, start, size)
        if name == 'alternate_10':
            expected = ['instruction']*6 + ['alignment', 'jump-pointer', 'local-size',
                        'parameter-size', 'exit-pointer', 'entry-pointer', 'attributes',
                        'dictionary-pointer', 'segment-trailer']
            if [i['kind'] for i in items] != expected or start+size != len(raw):
                raise ValueError('Alternate-program return/footer context differs')
        else:
            first = 'p_ixp 16, 1' if name == 'game_13' else 'p_cxp 22, 2'
            if (items[0]['assembly'] != first or not items[0]['clipped_start']
                    or items[0]['source_item_offset'] != start-1
                    or any(i['classification'] != 'code' for i in items)
                    or items[-1]['clipped_end'] or (start+size) % 512):
                raise ValueError('Previous-block instruction-tail context differs')
        offset = logical_sector_offset(row['block']*2+row['byte_offset']//256)+row['byte_offset']%256
        if images[row['disk']][offset:offset+size] != selected:
            raise ValueError('Stored tail differs from the assembled source')
        mappings.append(dict(disk=row['disk'], offset=offset, size=size,
                             input=name, input_offset=start))
        for item in items:
            counts[item['classification']] += item['size']
        records.append(dict(row, source=spec['source'], source_sha256=sha(raw),
                            source_audit=str(summary_path.relative_to(ROOT)), items=items))
        binaries[name] = raw
    audit = dict(classification_evidence=EVIDENCE, coverage_bytes=dict(counts),
                 copies=records, mappings=mappings, execution_at_copies_not_established=True)
    text = json.dumps(audit, indent=2)+'\n'
    if verify:
        if AUDIT.read_text() != text:
            raise ValueError('Short-tail audit differs')
        verify_ownership(manifest, mappings)
    else:
        planned, files = source_copy_plan(manifest, images, mappings, binaries)
        destinations = {}
        for path, data in files.items():
            target = contained_file(manifest_path.parent, path)
            previous = [s for s in manifest['components'].values() if s.get('path') == path]
            if len(previous) != 1 or sha(target.read_bytes()) != previous[0]['sha256']:
                raise ValueError('Temporary input changed before adoption')
            destinations[target] = data
        if adopt:
            for path, data in destinations.items():
                path.write_bytes(data)
            manifest_path.write_text(json.dumps(planned, indent=2)+'\n')
        AUDIT.write_text(text)
    print(json.dumps(dict(copies=len(records), coverage=dict(counts), adopted=adopt, verified=verify)))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--adopt', action='store_true')
    mode.add_argument('--verify', action='store_true')
    args = parser.parse_args()
    run(args.adopt, args.verify)
