#!/usr/bin/env python3
"""Prepare only fully classified slices of a reviewed encoded native bank.

The complete audit preserves unresolved offsets. Each separate component has its
own encoding phase and maps every assembled byte; no omitted byte is emitted.
"""
import argparse
import json
import re
import subprocess

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from native_raw_source import analyze, source_slice
from storage_encoding import transform


def prepare(recipe_path, verify=False):
    recipe = json.loads(recipe_path.read_text())
    name, origin = recipe['name'], recipe['origin']
    if not re.fullmatch('[a-z0-9_]+', name):
        raise ValueError('Invalid overlay name')
    if not (ROOT/recipe['classification_evidence']).is_file():
        raise ValueError('Missing overlay evidence')
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disk = next(d for d in manifest['disks'] if d['id'] == origin['disk'])
    image = (ROOT/'build/disks'/disk['filename']).read_bytes()
    if sha(image) != disk['sha256']:
        raise ValueError('Rebuild exact baseline before preparing overlay')
    size = recipe['size']
    if size % 512:
        raise ValueError('Overlay bank must contain complete blocks')
    stored = block_bytes(image, origin['block'], origin['block']+size//512)
    if sha(stored) != recipe['sha256']:
        raise ValueError('Overlay differs from reviewed stored bytes')
    raw = transform(stored, recipe['storage_encoding'], decode=True)
    report = analyze(raw, recipe['base'], recipe, inspect_gaps=True)
    report.update(origin=origin, storage_sha256=sha(stored),
                  storage_encoding=recipe['storage_encoding'],
                  classification_evidence=recipe['classification_evidence'],
                  selected_ranges=recipe['selected_ranges'])
    output = ROOT/'build/raw-preparation'/name
    output.mkdir(parents=True, exist_ok=True)
    artifacts, previous, total = {}, 0, 0
    for start, end in recipe['selected_ranges']:
        if start < previous:
            raise ValueError('Selected overlay ranges overlap or are unsorted')
        previous = end
        part = f'{name}_{start:04x}'
        stem = ROOT/'src/native'/part
        text = '; Evidence: '+recipe['classification_evidence']+'\n'+source_slice(raw, report, start, end)
        config = (f'MEMORY {{ IMAGE: start = ${recipe["base"]+start:04X}, size = {end-start}, file = %O; }}\n'
                  'SEGMENTS { RAW_NATIVE: load = IMAGE, type = ro; }\n')
        source, cfg, obj, binary = (output/(part+suffix) for suffix in ('.s','.cfg','.o','.bin'))
        source.write_text(text)
        cfg.write_text(config)
        subprocess.run(['ca65',str(source),'-o',str(obj)],check=True)
        subprocess.run(['ld65','-C',str(cfg),str(obj),'-o',str(binary)],check=True)
        plain = binary.read_bytes()
        encoding = dict(recipe['storage_encoding'], offset=recipe['storage_encoding']['offset']+start)
        if plain != raw[start:end] or transform(plain,encoding) != stored[start:end]:
            raise ValueError('Overlay slice does not assemble/re-encode exactly')
        mappings, position = [], start
        while position < end:
            logical = origin['block']*512+position
            length = min(end-position,256-logical%256)
            mappings.append(dict(disk=disk['id'],offset=logical_sector_offset(logical//256)+logical%256,
                                 size=length,input_offset=position-start))
            position += length
        adoption = dict(name=part,source=str(stem.with_suffix('.s').relative_to(ROOT)),
                        config=str(stem.with_suffix('.cfg').relative_to(ROOT)),
                        storage_encoding=encoding,mappings=mappings)
        artifacts[stem.with_suffix('.s')] = text
        artifacts[stem.with_suffix('.cfg')] = config
        artifacts[stem.with_suffix('.adopt.json')] = json.dumps(adoption,indent=2)+'\n'
        total += end-start
    classified = sum(report['coverage_bytes'].values())
    if total != classified:
        raise ValueError('Every classified byte must have exactly one selected output range')
    report.update(disk_output_bytes=total,byte_identical_assembly=True)
    artifacts[ROOT/'docs/reference/raw-modules'/f'{name}.json'] = json.dumps(report,indent=2)+'\n'
    for path, content in artifacts.items():
        if verify:
            if not path.is_file() or path.read_text() != content:
                raise ValueError(f'Prepared overlay artifact differs: {path}')
        elif path.exists():
            raise ValueError(f'Overlay artifact already exists: {path}')
    if not verify:
        for path, content in artifacts.items():
            path.write_text(content)
    print(json.dumps(dict(name=name,code=report['coverage_bytes'].get('code',0),
                          data=report['coverage_bytes'].get('data',0),
                          output=total,unclassified=len(report['unclassified_offsets']),verified=verify)))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('recipe',type=lambda p:ROOT/p)
    parser.add_argument('--verify',action='store_true')
    args = parser.parse_args()
    prepare(args.recipe,args.verify)
