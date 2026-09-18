#!/usr/bin/env python3
"""Prepare a fully classified p-code module for review and later adoption.

Maintenance only: read an inventory and the current rebuilt disks, never the
original images. Matching segment copies share a single source component.
Reject any overlap with an already reconstructed component. This command does
not mutate the reconstruction manifest or temporary inputs.
"""
import argparse
import json
from pathlib import Path
import re
import subprocess

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from pcode_source import analyze, source, verify_interpreter


def prepare(name, disk_id, header_block, segment_number, *, code_roots=(), root_evidence=None, native_evidence=None):
    if not re.fullmatch(r'[a-z0-9_]+', name):
        raise ValueError('Invalid component name')
    if code_roots and (not root_evidence or not (ROOT / root_evidence).is_file()):
        raise ValueError('Additional code roots require an existing evidence document')
    manifest = json.loads((ROOT / 'reconstruction/manifest.json').read_text())
    if name in manifest['components']:
        raise ValueError('Component already exists')
    inventory = json.loads((ROOT / 'docs/pascal-inventory.json').read_text())
    entries = [(h, e) for h in inventory['headers'] for e in h['entries']
               if e['status'] == 'valid-procedure-dictionary']
    candidates = [(h, e) for h, e in entries if h['disk'] == disk_id and
                  h['block'] == header_block and e['segment_number'] == segment_number]
    if len(candidates) != 1:
        raise ValueError('No unique valid inventory entry')
    _, selected = candidates[0]
    copies = [(h, e) for h, e in entries if e['sha256'] == selected['sha256']]
    verify_interpreter((ROOT / 'build/disks/components/pcode_primitives.bin').read_bytes())
    mappings, origins, data = [], [], None
    seen = set()
    for header, entry in copies:
        key = (header['disk'], entry['start_block'])
        if key in seen:
            continue
        seen.add(key)
        disk = next(d for d in manifest['disks'] if d['id'] == header['disk'])
        image = (ROOT / 'build/disks' / disk['filename']).read_bytes()
        if sha(image) != disk['sha256']:
            raise ValueError('Rebuild current baseline before preparing modules')
        raw = block_bytes(image, entry['start_block'], entry['end_block'])[:entry['length']]
        if sha(raw) != entry['sha256'] or (data is not None and data != raw):
            raise ValueError('Inventory or matching segment copy differs')
        data = raw
        origins.append(dict(disk=disk['id'], header_block=header['block'],
                            segment=entry['segment_number'], start_block=entry['start_block']))
        for position in range(0, len(data), 256):
            offset = logical_sector_offset(entry['start_block'] * 2 + position // 256)
            size = min(256, len(data) - position)
            owners = [r for r in disk['regions'] if r['offset'] <= offset and
                      offset + size <= r['offset'] + r['size']]
            if len(owners) != 1 or manifest['components'][owners[0]['input']]['kind'] != 'temporary-unresolved':
                raise ValueError('Module copy overlaps reconstructed content')
            mappings.append(dict(disk=disk['id'], offset=offset, size=size, input_offset=position))
    native_decoder = None
    if native_evidence:
        from native_pascal_source import mixed_decoder
        from pascal_inventory import procedure_dictionary
        native_recipe = json.loads((ROOT / native_evidence).read_text())
        native_decoder = mixed_decoder(data, procedure_dictionary(data, segment_number), native_recipe['procedures'])
    report = analyze(data, segment_number, extra_code_roots=code_roots, native_decoder=native_decoder)
    stem = Path('src/pcode') / name
    audit_path = Path('docs/reference/pcode-modules') / (name + '.json')
    paths = [stem.with_suffix(suffix) for suffix in ('.s', '.cfg', '.adopt.json')] + [audit_path]
    if any((ROOT / path).exists() for path in paths):
        raise ValueError('Prepared output already exists')
    config = f'MEMORY {{ IMAGE: start = $0000, size = ${len(data):04X}, file = %O; }}\nSEGMENTS {{ PCODE: load = IMAGE, type = ro; }}\n'
    text = '; Origin and code/data evidence: ' + str(audit_path) + '\n' + source(report)
    # Prove the generated source before placing it in the tracked source tree.
    output = ROOT / 'build/pcode-preparation' / name
    output.mkdir(parents=True, exist_ok=True)
    (output / 'module.s').write_text(text)
    (output / 'module.cfg').write_text(config)
    subprocess.run(['ca65', '-I', str(ROOT / 'src/pcode'), str(output / 'module.s'), '-o', str(output / 'module.o')], check=True)
    subprocess.run(['ld65', '-C', str(output / 'module.cfg'), str(output / 'module.o'), '-o', str(output / 'module.bin')], check=True)
    if (output / 'module.bin').read_bytes() != data:
        raise ValueError('Generated source does not round-trip')
    recipe = dict(name=name, source=str(paths[0]), config=str(paths[1]), mappings=mappings)
    summary = {key: report[key] for key in ('sha256', 'size', 'segment', 'procedure_count',
               'instruction_count', 'coverage_bytes', 'instructions_by_mnemonic')}
    summary.update(native_evidence=native_evidence, native_reports=report.get('native_reports', []), origins=origins, extra_code_roots=list(code_roots), root_evidence=root_evidence, control_flow_edges=len(report['control_flow_edges']),
                   classification_evidence='docs/utility-pcode.md',
                   data_regions=[{k: i[k] for k in ('offset', 'size', 'kind', 'consumer', 'target') if k in i}
                                 for i in report['items'] if i['kind'] not in ('instruction', 'native-instruction')])
    (output / 'analysis.json').write_text(json.dumps(report, indent=2) + '\n')
    (ROOT / paths[0]).write_text(text)
    (ROOT / paths[1]).write_text(config)
    (ROOT / paths[2]).write_text(json.dumps(recipe, indent=2) + '\n')
    (ROOT / audit_path).parent.mkdir(parents=True, exist_ok=True)
    (ROOT / audit_path).write_text(json.dumps(summary, indent=2) + '\n')
    return dict(name=name, size=len(data), output_bytes=len(data) * len(origins),
                procedures=report['procedure_count'], instructions=report['instruction_count'],
                origins=origins, recipe=str(paths[2]))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('name')
    parser.add_argument('disk', choices=('disk1', 'disk2'))
    parser.add_argument('header', type=int)
    parser.add_argument('segment', type=int)
    parser.add_argument('--code-root', type=lambda value: int(value, 0), action='append', default=[])
    parser.add_argument('--root-evidence', help='Repository-relative evidence document for additional code roots')
    parser.add_argument('--native-evidence', help='Repository-relative native code/data evidence recipe')
    args = parser.parse_args()
    print(json.dumps(prepare(args.name, args.disk, args.header, args.segment, code_roots=args.code_root, root_evidence=args.root_evidence, native_evidence=args.native_evidence)))


if __name__ == '__main__':
    main()
