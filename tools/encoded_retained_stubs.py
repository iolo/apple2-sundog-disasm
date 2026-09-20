#!/usr/bin/env python3
"""Reconstruct disconnected encoded-bank jumps without inventing live flow."""
import argparse
import json
import subprocess

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from native_pascal_source import instruction
from native_raw_source import analyze
from storage_encoding import transform
from pcode_copies import verify_ownership
from encoded_overlay_tail import audit as audit_tail

EVIDENCE = 'docs/encoded-retained-stubs.md'
STUBS = ((0x357, 0x572, 0x35D), (0x35D, 0x5DB, 0x5DD))
POINTERS = ((0x572, 0x35D), (0x5DB, 0x5DD), (0x5E3, 0x352))


def audit(raw, base, body):
    if len(raw) != 2048 or body['base'] != base or body['sha256'] != sha(raw):
        raise ValueError('Retained stub bank differs from body audit')
    owners = {p: item for item in body['items']
              for p in range(item['offset'], item['offset']+item['size'])}
    items = []
    for offset, vector, target in STUBS:
        ins = instruction(raw, offset)
        if (ins['mnemonic'], ins['mode'], ins['size'], ins['operand_value']) != ('jmp', 'In', 3, base+vector):
            raise ValueError('Retained indirect jump differs')
        delimiter = owners.get(offset-1, {})
        if (raw[offset-1] != 0xAD or delimiter.get('kind') != 'obfuscation-delimiter'
                or delimiter.get('size') != 1):
            raise ValueError('Retained jump delimiter context differs')
        following = owners.get(offset+3, {})
        if following.get('kind') != 'jump-vector' or following.get('offset') != offset+3:
            raise ValueError('Retained jump following vector context differs')
        if any(edge.get('target') == offset for edge in body['edges']):
            raise ValueError('Stub unexpectedly entered by the reviewed graph')
        items.append(dict(offset=offset, size=3, classification='code',
                          kind='disconnected-indirect-jump', vector_offset=vector,
                          target_offset=target, assembly=f'jmp (${base+vector:04X})'))
    for offset, target in POINTERS:
        if int.from_bytes(raw[offset:offset+2], 'little') != base+target:
            raise ValueError('Retained pointer target differs')
        for position in (offset, offset+512):
            if raw[position:position+2] != raw[offset:offset+2]:
                raise ValueError('Copied retained pointer differs')
            items.append(dict(offset=position, size=2, classification='data',
                              kind='retained-track-sequence-address' if offset == 0x5E3 else 'retained-jump-vector',
                              target_offset=target, source_offset=offset,
                              assembly=f'.word ${base+target:04X}'))
    # The second stub lands in existing data; preserve that ownership exactly.
    for offset in (0x5DD, 0x5DF, 0x5E1, 0x5E5):
        item = owners.get(offset, {})
        if (item.get('offset'), item.get('size'), item.get('kind')) != (offset, 2, 'jump-vector'):
            raise ValueError('Surrounding pointer-table ownership differs')
    track = owners.get(0x352, {})
    if (track.get('offset') != 0x352 or track.get('size') != 4
            or track.get('classification') != 'data' or raw[0x352:0x356] != bytes.fromhex('22 23 22 ff')):
        raise ValueError('Track pointer does not address the reviewed track data')
    items.sort(key=lambda item: item['offset'])
    selected = set()
    for item in items:
        for p in range(item['offset'], item['offset']+item['size']):
            if p in selected or p in owners:
                raise ValueError('Retained classification overlaps prior ownership')
            selected.add(p)
    tail = audit_tail(raw, body)
    previous = set(range(63)) | set(owners)
    for item in tail['items']:
        previous.update(range(item['offset'], item['offset']+item['size']))
    if previous & selected:
        raise ValueError('Retained slices overlap loader or copied-tail classification')
    remaining = sorted(set(range(2048))-previous-selected)
    if remaining != [0x5F0,0x5F6,0x5F7,0x7F0,0x7F6,0x7F7]:
        raise ValueError('Combined bank coverage differs')
    return dict(base=base, sha256=sha(raw), items=items, code_bytes=6, data_bytes=12,
                target_data_offset=0x5DD, live_execution_established=False,
                remaining_bank_offsets=remaining)


def prepare(verify=False):
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    reports, artifacts, ownership = [], {}, []
    for variant in ('play', 'alternate'):
        recipe = json.loads((ROOT/'src/native/evidence'/f'encoded_body_{variant}.json').read_text())
        origin = recipe['origin']
        disk = next(d for d in manifest['disks'] if d['id'] == origin['disk'])
        image = (ROOT/'build/disks'/disk['filename']).read_bytes()
        if sha(image) != disk['sha256']:
            raise ValueError('Rebuild exact baseline before preparing retained stubs')
        stored = block_bytes(image, origin['block'], origin['block']+4)
        if sha(stored) != recipe['sha256']:
            raise ValueError('Reviewed encoded bank differs')
        raw = transform(stored, recipe['storage_encoding'], decode=True)
        body = analyze(raw, recipe['base'], recipe, inspect_gaps=True)
        report = audit(raw, recipe['base'], body)
        report.update(variant=variant, origin=origin, storage_sha256=sha(stored))
        reports.append(report)
        output = ROOT/'build/raw-preparation'/f'encoded_retained_{variant}'
        output.mkdir(parents=True, exist_ok=True)
        for item in report['items']:
            start, size = item['offset'], item['size']
            name = f'encoded_retained_{variant}_{start:04x}'
            stem = ROOT/'src/native'/name
            text = (f'; Evidence: {EVIDENCE}\n; {item["kind"]}, stored bank offset ${start:04X}\n'
                    '.setcpu "6502"\n.segment "RAW_NATIVE"\ncomponent_start:\n'
                    f'    {item["assembly"]}\n'
                    f'.assert * - component_start = {size}, error, "Retained slice size"\n')
            config = (f'MEMORY {{ IMAGE: start = ${recipe["base"]+start:04X}, size = {size}, file = %O; }}\n'
                      'SEGMENTS { RAW_NATIVE: load = IMAGE, type = ro; }\n')
            work = output/name
            work.with_suffix('.s').write_text(text)
            work.with_suffix('.cfg').write_text(config)
            subprocess.run(['ca65', str(work.with_suffix('.s')), '-o', str(work.with_suffix('.o'))], check=True)
            subprocess.run(['ld65', '-C', str(work.with_suffix('.cfg')), str(work.with_suffix('.o')),
                            '-o', str(work.with_suffix('.bin'))], check=True)
            binary = work.with_suffix('.bin').read_bytes()
            encoding = dict(recipe['storage_encoding'], offset=recipe['storage_encoding']['offset']+start,
                            evidence=EVIDENCE)
            if binary != raw[start:start+size] or transform(binary, encoding) != stored[start:start+size]:
                raise ValueError('Retained slice assembly or encoding differs')
            logical = origin['block']*512+start
            if logical%256+size > 256:
                raise ValueError('Retained mapping crosses a sector')
            mappings = [dict(disk=disk['id'], offset=logical_sector_offset(logical//256)+logical%256,
                             size=size, input_offset=0)]
            adoption = dict(name=name, source=str(stem.with_suffix('.s').relative_to(ROOT)),
                            config=str(stem.with_suffix('.cfg').relative_to(ROOT)),
                            storage_encoding=encoding, mappings=mappings)
            ownership += [dict(m, input=name) for m in mappings]
            artifacts[stem.with_suffix('.s')] = text
            artifacts[stem.with_suffix('.cfg')] = config
            artifacts[stem.with_suffix('.adopt.json')] = json.dumps(adoption, indent=2)+'\n'
    normalized = [{key: value for key, value in item.items() if key != 'assembly'}
                  for item in reports[0]['items']]
    if normalized != [{key: value for key, value in item.items() if key != 'assembly'}
                      for item in reports[1]['items']]:
        raise ValueError('Retained layouts do not agree across relocated banks')
    artifacts[ROOT/'docs/reference/encoded-retained-stubs.json'] = json.dumps(
        dict(classification_evidence=EVIDENCE, code_bytes=12, data_bytes=24, records=reports), indent=2)+'\n'
    for path, content in artifacts.items():
        if verify:
            if not path.is_file() or path.read_text() != content:
                raise ValueError(f'Retained stub artifact differs: {path}')
        elif path.exists():
            raise ValueError(f'Retained stub artifact already exists: {path}')
    if verify:
        verify_ownership(manifest, ownership)
    else:
        for path, content in artifacts.items():
            path.write_text(content)
    print(json.dumps(dict(code_bytes=12, data_bytes=24, verified=verify)))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verify', action='store_true')
    prepare(parser.parse_args().verify)
