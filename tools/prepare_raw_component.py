#!/usr/bin/env python3
"""Prepare an evidenced raw native overlay from current rebuilt disk extents."""
import argparse
import json
import re
import subprocess

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from native_raw_source import analyze, source
from storage_encoding import transform


def prepare(recipe_path):
    recipe = json.loads(recipe_path.read_text())
    name, size = recipe['name'], recipe['size']
    if not re.fullmatch('[a-z0-9_]+', name) or size <= 0:
        raise ValueError('Invalid raw component name or size')
    if not (ROOT / recipe['classification_evidence']).is_file():
        raise ValueError('Missing raw component evidence document')
    stem = ROOT / 'src/native' / name
    paths = [stem.with_suffix(suffix) for suffix in ('.s', '.cfg', '.adopt.json')]
    audit = ROOT / 'docs/reference/raw-modules' / (name+'.json')
    if any(path.exists() for path in paths + [audit]):
        raise ValueError('Prepared raw artifacts already exist')
    manifest = json.loads((ROOT / 'reconstruction/manifest.json').read_text())
    if name in manifest['components']:
        raise ValueError('Raw component already adopted')
    data, mappings = None, []
    for origin in recipe['origins']:
        disk = next(d for d in manifest['disks'] if d['id'] == origin['disk'])
        image = (ROOT / 'build/disks' / disk['filename']).read_bytes()
        if sha(image) != disk['sha256']:
            raise ValueError('Rebuild baseline before preparing raw component')
        start, offset = origin['block'], origin.get('byte_offset', 0)
        if not 0 <= start < 280 or not 0 <= offset < 512 or start*512+offset+size > 143360:
            raise ValueError('Raw origin exceeds disk bounds')
        raw = block_bytes(image, start, start+(offset+size+511)//512)[offset:offset+size]
        if sha(raw) != recipe['sha256'] or (data is not None and data != raw):
            raise ValueError('Raw component differs from reviewed bytes or another copy')
        data = raw
        position = 0
        while position < size:
            logical = start*512+offset+position
            image_offset = logical_sector_offset(logical//256) + logical%256
            length = min(size-position, 256-logical%256)
            owners = [r for r in disk['regions'] if r['offset'] <= image_offset
                      and image_offset+length <= r['offset']+r['size']]
            if len(owners) != 1 or manifest['components'][owners[0]['input']]['kind'] != 'temporary-unresolved':
                raise ValueError('Raw component overlaps reconstructed bytes')
            mappings.append(dict(disk=disk['id'], offset=image_offset, size=length, input_offset=position))
            position += length
    if data is None:
        raise ValueError('Raw component needs at least one origin')
    storage_sha256 = sha(data)
    if 'storage_encoding' in recipe:
        encoding = recipe['storage_encoding']
        if not (ROOT/encoding['evidence']).is_file():
            raise ValueError('Missing storage encoding evidence')
        data = transform(data,encoding,decode=True)
    report = analyze(data, recipe['base'], recipe)
    text = '; Evidence: '+recipe['classification_evidence']+'\n'+source(data, report)
    config = (f'MEMORY {{ IMAGE: start = ${recipe["base"]:04X}, size = {size}, file = %O; }}\n'
              'SEGMENTS { RAW_NATIVE: load = IMAGE, type = ro; }\n')
    output = ROOT / 'build/raw-preparation' / name
    output.mkdir(parents=True, exist_ok=True)
    (output/'module.s').write_text(text)
    (output/'module.cfg').write_text(config)
    subprocess.run(['ca65', str(output/'module.s'), '-o', str(output/'module.o')], check=True)
    subprocess.run(['ld65', '-C', str(output/'module.cfg'), str(output/'module.o'),
                    '-o', str(output/'module.bin')], check=True)
    if (output/'module.bin').read_bytes() != data:
        raise ValueError('Raw source does not assemble exactly')
    adoption = dict(name=name, source=str(paths[0].relative_to(ROOT)),
                    config=str(paths[1].relative_to(ROOT)), mappings=mappings)
    if 'storage_encoding' in recipe:
        adoption['storage_encoding'] = recipe['storage_encoding']
        report.update(storage_encoding=recipe['storage_encoding'],storage_sha256=storage_sha256)
    report.update(origins=recipe['origins'], classification_evidence=recipe['classification_evidence'],
                  disk_output_bytes=sum(m['size'] for m in mappings), byte_identical_assembly=True)
    for path, content in zip(paths, (text, config, json.dumps(adoption, indent=2)+'\n')):
        path.write_text(content)
    audit.parent.mkdir(parents=True, exist_ok=True)
    audit.write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps({key: report[key] for key in ('size','instruction_count','coverage_bytes','disk_output_bytes')}))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('recipe', type=lambda path: ROOT / path)
    prepare(parser.parse_args().recipe)
