#!/usr/bin/env python3
"""Audit dictionary-tail workspace through the shipped supplement-copy consumer."""
import argparse
import json
import subprocess

from disk_layout import ROOT, block_bytes, sha
from dialogue_dictionary_asset import base_offsets, decode_extra, text_bytes
from pcode_copies import verify_ownership

EVIDENCE = 'docs/dialogue-workspace.md'


def simulate(base, supplements):
    if len(base) != 1024:
        raise ValueError('Expected the complete two-block dictionary buffer')
    offsets = base_offsets(base)
    first = 64
    while first and base[first] == base[first-1]:
        first -= 1
    if first != 52 or offsets[first] != 808:
        raise ValueError('Initial supplement index/offset differs')
    if any(base[808:997]):
        raise ValueError('Reviewed workspace initializer differs')
    reports, written = [], set()
    for block,entries in supplements:
        memory = bytearray(base)
        cursor, index, ranges = offsets[first], first, []
        for entry in entries:
            payload = text_bytes(entry)
            end = cursor+len(payload)
            if not payload or index >= 64 or end > 997:
                raise ValueError('Supplement exceeds reviewed workspace or pointer table')
            memory[cursor:end] = payload
            written.update(range(cursor,end))
            ranges.append(dict(entry=index,offset=cursor,size=len(payload)))
            index += 1
            memory[index] = end%256
            cursor = end
        for slot in range(index+1,65):
            memory[slot] = memory[index]
        updated = base_offsets(memory)
        if updated[first] != 808 or updated[-1] != cursor or memory[997:] != base[997:]:
            raise ValueError('Modeled dictionary pointer or excluded tail differs')
        reports.append(dict(block=block,entries=len(entries),write_ranges=ranges,
                            final_offset=cursor,updated_dictionary_sha256=sha(memory)))
    if written != set(range(808,997)):
        raise ValueError('Current supplements do not cover the complete selected workspace')
    return dict(initial_entry_index=first,workspace_range=[808,997],data_bytes=189,
                unused_unclassified_range=[997,1024],supplements=reports)


def run(prepare=False):
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disk = next(d for d in manifest['disks'] if d['id']=='disk2')
    image = (ROOT/'build/disks'/disk['filename']).read_bytes()
    if sha(image) != disk['sha256']:
        raise ValueError('Rebuild exact baseline before workspace audit')
    proof = json.loads((ROOT/'src/data/evidence/dialogue_workspace.json').read_text())
    component = (ROOT/'build/disks/components/game_16.bin').read_bytes()
    if sha(component) != proof['component_sha256'] or sha(component) != manifest['components']['game_16']['sha256']:
        raise ValueError('Reviewed dictionary consumer differs')
    for window in proof['windows']:
        data = component[window['offset']:window['offset']+window['size']]
        if data.hex() != window['hex'] or sha(data) != window['sha256']:
            raise ValueError('Dictionary append consumer window differs')
    asset_spec = manifest['components']['dialogue_dictionary']
    asset = (ROOT/asset_spec['path']).read_bytes()
    if asset_spec['kind'] != 'identified-data' or sha(asset) != asset_spec['sha256']:
        raise ValueError('Independently classified dictionary asset differs')
    asset_manifest = json.loads((ROOT/'assets/dialogue-dictionary/manifest.json').read_text())
    base = block_bytes(image,88,90)
    if base[:808] != asset[:808]:
        raise ValueError('Initial dictionary differs from classified asset')
    supplements = []
    for section in asset_manifest['sections'][1:]:
        start,size = section['input_offset'],section['size']
        raw = asset[start:start+size]
        bank = block_bytes(image,section['block'],section['block']+1)
        disk_bytes = b''.join(bank[lo:hi] for lo,hi in section['bank_ranges'])
        if disk_bytes != raw:
            raise ValueError('Supplement differs from classified on-disk fields')
        supplements.append((section['block'],decode_extra(raw)['entries']))
    report = simulate(base,supplements)
    report.update(classification='data',classification_evidence=EVIDENCE,
                  dictionary_sha256=sha(base),consumer_sha256=sha(component),
                  runtime_execution_claimed=False)
    output = ROOT/'build/dialogue-workspace'
    output.mkdir(parents=True,exist_ok=True)
    subprocess.run(['ca65',str(ROOT/'src/data/dialogue_workspace.s'),'-o',str(output/'workspace.o')],check=True)
    subprocess.run(['ld65','-C',str(ROOT/'src/data/dialogue_workspace.cfg'),str(output/'workspace.o'),
                    '-o',str(output/'workspace.bin')],check=True)
    if (output/'workspace.bin').read_bytes() != base[808:997]:
        raise ValueError('Workspace assembly differs')
    adoption = json.loads((ROOT/'src/data/dialogue_workspace.adopt.json').read_text())
    path = ROOT/'docs/reference/dialogue-workspace.json'
    content = json.dumps(report,indent=2)+'\n'
    if prepare:
        path.write_text(content)
    else:
        verify_ownership(manifest,[dict(m,input=adoption['name']) for m in adoption['mappings']])
        if path.read_text() != content:
            raise ValueError('Workspace report differs')
    print(json.dumps(dict(data_bytes=189,supplements=len(supplements),remaining_tail_bytes=27,verified=not prepare)))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--prepare',action='store_true')
    run(parser.parse_args().prepare)
