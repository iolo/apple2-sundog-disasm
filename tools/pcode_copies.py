#!/usr/bin/env python3
"""Verify and adopt reviewed copies of existing fully disassembled p-code ranges.

No discovery or blanket gap classification occurs here. The frozen recipe names
all extents and source hashes. The build reuses existing assembled components.
"""
import argparse
from collections import Counter
import json
import subprocess

from adopt_component import source_copy_plan
from build_disks import contained_file
from disk_layout import ROOT, logical_sector_offset, sha
from pcode_source import analyze, verify_interpreter

RECIPE = ROOT/'src/pcode/evidence/preserved_copies.json'
AUDIT = ROOT/'docs/reference/preserved-pcode-copies.json'


def copy_items(report, start, size):
    if start < 0 or size <= 0 or start+size > report['size']:
        raise ValueError('Copy interval outside audited source')
    items, cursor = [], start
    for original in report['items']:
        left = max(start,original['offset'])
        right = min(start+size,original['offset']+original['size'])
        if right <= left:
            continue
        if left != cursor:
            raise ValueError('Copy interval has an ownership gap or overlap')
        items.append(dict(offset=left-start,size=right-left,source_offset=left,
                          source_item_offset=original['offset'],source_item_size=original['size'],
                          kind=original['kind'],assembly=original['assembly'],
                          classification='code' if original['kind'] in ('instruction','native-instruction') else 'data',
                          clipped_start=left != original['offset'],
                          clipped_end=right != original['offset']+original['size']))
        cursor = right
    if cursor != start+size:
        raise ValueError('Copy interval has unclassified bytes')
    return items


def verify_ownership(manifest, mappings):
    disks = {d['id']:d for d in manifest['disks']}
    for mapping in mappings:
        cursor, end = mapping['offset'], mapping['offset']+mapping['size']
        for region in disks[mapping['disk']]['regions']:
            left,right = max(cursor,region['offset']),min(end,region['offset']+region['size'])
            if right <= left:
                continue
            if (left != cursor or region['input'] != mapping['input']
                    or region['input_offset']+left-region['offset'] != mapping['input_offset']+left-mapping['offset']):
                raise ValueError('Copied disk bytes do not have their reviewed source ownership')
            cursor = right
        if cursor != end:
            raise ValueError('Copied source ownership is incomplete')


def run(adopt=False, verify=False):
    recipe = json.loads(RECIPE.read_text())
    contained_file(ROOT,recipe['classification_evidence'])
    manifest_path = ROOT/'reconstruction/manifest.json'
    manifest = json.loads(manifest_path.read_text())
    images = {d['id']:(ROOT/'build/disks'/d['filename']).read_bytes() for d in manifest['disks']}
    for disk in manifest['disks']:
        if len(images[disk['id']]) != disk['size'] or sha(images[disk['id']]) != disk['sha256']:
            raise ValueError('Rebuild exact disk baseline before reviewing copies')
    interpreter = (ROOT/'build/disks/components/pcode_primitives.bin').read_bytes()
    if sha(interpreter) != manifest['components']['pcode_primitives']['sha256']:
        raise ValueError('Interpreter baseline differs')
    verify_interpreter(interpreter)
    output = ROOT/'build/pcode-copies'
    output.mkdir(parents=True,exist_ok=True)
    binaries, reports, copies, mappings, counts = {}, {}, [], [], Counter()
    for row in recipe['copies']:
        if not row.get('evidence') or row['size'] < 64:
            raise ValueError('Copy needs reviewed evidence and an extended exact match')
        name = row['component']
        spec = manifest['components'][name]
        if spec['kind'] != 'ca65-source' or 'storage_encoding' in spec:
            raise ValueError('Expected an ordinary assembled p-code source')
        summary = json.loads(contained_file(ROOT,row['source_audit']).read_text())
        if summary['sha256'] != spec['sha256']:
            raise ValueError('Source module audit hash differs')
        if name not in binaries:
            source, config = (contained_file(ROOT,spec[k]) for k in ('source','config'))
            obj,binary = output/(name+'.o'),output/(name+'.bin')
            subprocess.run(['ca65','-I',str(source.parent),str(source),'-o',str(obj)],check=True)
            subprocess.run(['ld65','-C',str(config),str(obj),'-o',str(binary)],check=True)
            data = binary.read_bytes()
            if len(data) != spec['size'] or sha(data) != spec['sha256']:
                raise ValueError('Reassembled source differs from reviewed component')
            # This checkpoint uses pure p-code modules. Mixed/native procedures
            # need a separate evidenced decoder, never a fallback byte listing.
            report = analyze(data,summary['segment'],extra_code_roots=summary.get('extra_code_roots',[]))
            if report['coverage_bytes'] != summary['coverage_bytes']:
                raise ValueError('Source classification differs from module audit')
            binaries[name],reports[name] = data,report
        items = copy_items(reports[name],row['input_offset'],row['size'])
        raw = binaries[name][row['input_offset']:row['input_offset']+row['size']]
        if sha(raw) != row['sha256'] or len(set(raw[:64])) < 10:
            raise ValueError('Copy differs from reviewed nontrivial source bytes')
        if not 0 <= row['byte_offset'] < 512 or not 0 <= row['block'] < 280:
            raise ValueError('Copy disk origin is invalid')
        position = 0
        while position < row['size']:
            logical = row['block']*512+row['byte_offset']+position
            length = min(row['size']-position,256-logical%256)
            offset = logical_sector_offset(logical//256)+logical%256
            mapping = dict(disk=row['disk'],offset=offset,size=length,input=name,
                           input_offset=row['input_offset']+position)
            if images[row['disk']][offset:offset+length] != raw[position:position+length]:
                raise ValueError('Disk copy differs from assembled source')
            mappings.append(mapping)
            position += length
        for item in items:
            counts[item['classification']] += item['size']
        copies.append(dict(row,source=spec['source'],items=items))
    # All destinations are unique even when --verify is called after adoption.
    seen = set()
    for mapping in mappings:
        for offset in range(mapping['offset'],mapping['offset']+mapping['size']):
            key = (mapping['disk'],offset)
            if key in seen:
                raise ValueError('Copy destinations overlap')
            seen.add(key)
    audit = dict(recipe_sha256=sha(RECIPE.read_bytes()),classification_evidence=recipe['classification_evidence'],
                 source_components=len(binaries),copy_count=len(copies),coverage_bytes=dict(counts),
                 copies=copies,mappings=mappings)
    content = json.dumps(audit,indent=2)+'\n'
    if verify:
        if AUDIT.read_text() != content:
            raise ValueError('Copy audit differs')
        verify_ownership(manifest,mappings)
    else:
        planned,files = source_copy_plan(manifest,images,mappings,binaries)
        if adopt:
            destinations = {}
            for path,data in files.items():
                target = contained_file(manifest_path.parent,path)
                old = [s for s in manifest['components'].values() if s.get('path')==path]
                if len(old) != 1 or sha(target.read_bytes()) != old[0]['sha256']:
                    raise ValueError('Temporary input changed before copy adoption')
                destinations[target] = data
            for path,data in destinations.items():
                path.write_bytes(data)
            manifest_path.write_text(json.dumps(planned,indent=2)+'\n')
        AUDIT.write_text(content)
    print(json.dumps(dict(copies=len(copies),source_components=len(binaries),coverage=dict(counts),
                          adopted=adopt,verified=verify)))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--adopt',action='store_true')
    mode.add_argument('--verify',action='store_true')
    args = parser.parse_args()
    run(args.adopt,args.verify)
