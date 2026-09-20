#!/usr/bin/env python3
"""Audit native output-buffer tails against historical assembler behavior."""
import argparse
import json
from pathlib import Path
import subprocess

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from native_relocations import native_relocations
from pascal_inventory import procedure_dictionary
from pcode_source import analyze
from pcode_copies import verify_ownership

EVIDENCE = 'docs/native-output-storage.md'
PROOF = ROOT/'docs/reference/assembler-buffer-evidence.json'
LAYOUTS = {'title_draw': (928, 912), 'viewscreen_transition': (944, 928)}
WINDOW_HASHES = ['abe2a723ff585ad55727d805ab50b0c2be14edb0f9a838b55861f5fc80de2ef3',
                 '562a83b3b1ac0ed9384d72fe4996ae2ec98af8308f73124d9f3276cdcf0d678c']


def check_proof(proof, external=None):
    if [(w['offset'], w['size']) for w in proof['windows']] != [(0x700,59),(0x8A8,26)]:
        raise ValueError('Assembler evidence windows differ')
    for window, digest in zip(proof['windows'], WINDOW_HASHES):
        raw = bytes.fromhex(window['hex'])
        if len(raw) != window['size'] or sha(raw) != digest or window['sha256'] != digest:
            raise ValueError('Assembler allocation/clear/write evidence differs')
    if external is not None:
        if len(external) != proof['file_size'] or sha(external) != proof['file_sha256']:
            raise ValueError('Historical assembler file differs')
        start = proof['relative_file_block']*512
        segment = external[start:start+proof['segment_size']]
        if sha(segment) != proof['segment_sha256']:
            raise ValueError('Historical PROCEND segment differs')
        report = analyze(segment, 9, dialect='apple-pascal-inn')
        if (report['procedure_count'] != proof['segment_procedure_count']
                or report['instruction_count'] != proof['segment_instruction_count']):
            raise ValueError('Historical assembler decoding differs')
        for window in proof['windows']:
            lo, hi = window['offset'], window['offset']+window['size']
            instructions = [dict(offset=i['offset'],size=i['size'],assembly=i['assembly'])
                            for i in report['items'] if lo <= i['offset'] < hi]
            if segment[lo:hi].hex() != window['hex'] or instructions != window['instructions']:
                raise ValueError('Historical evidence window does not match full decoding')
    return dict(buffer_bytes=1024, cleared_bytes=1023, write_block_bytes=512,
                uncleared_offset=1023, external_replayed=external is not None)


def classify_tail(raw, name):
    end, footer = LAYOUTS[name]
    if len(raw) != 1024:
        raise ValueError('Native two-block allocation differs')
    dictionary = procedure_dictionary(raw[:end], 1)
    if not dictionary['valid'] or dictionary['procedure_count'] != 1:
        raise ValueError('Native container dictionary differs')
    proc = dictionary['procedures'][0]
    if (proc['entry_offset'] != 0 or proc['representation'] != 'native-6502'
            or proc['attribute_offset'] != footer+10 or proc['lexical_level'] != 0):
        raise ValueError('Native container attributes differ')
    reloc = native_relocations(raw[:end], proc)
    if reloc['tables_start'] != footer or any(g['count'] for g in reloc['groups']):
        raise ValueError('Native container relocation boundary differs')
    if any(raw[end:1023]) or raw[1023] != 4:
        raise ValueError('Reviewed cleared storage/final retained byte differs')
    return dict(name=name, allocation_size=1024, container_size=end,
                classification='data', zero_range=[end,1023], retained_byte_offset=1023,
                retained_byte_value=4, data_bytes=1024-end,
                historical_producer_identity_proved=False)


def run(verify=False, external=None):
    proof = json.loads(PROOF.read_text())
    check_proof(proof, external.read_bytes() if external else None)
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    records = []
    for name, disk_id, block in [('title_draw','disk1',201),('viewscreen_transition','disk2',86)]:
        disk = next(d for d in manifest['disks'] if d['id'] == disk_id)
        image = (ROOT/'build/disks'/disk['filename']).read_bytes()
        if sha(image) != disk['sha256']:
            raise ValueError('Rebuild exact baseline before output-storage audit')
        raw = block_bytes(image, block, block+2)
        spec = manifest['components'][name]
        output = ROOT/'build/native-output-storage'
        output.mkdir(parents=True, exist_ok=True)
        stem = output/name
        subprocess.run(['ca65',str(ROOT/spec['source']),'-o',str(stem.with_suffix('.o'))],check=True)
        subprocess.run(['ld65','-C',str(ROOT/spec['config']),str(stem.with_suffix('.o')),
                        '-o',str(stem.with_suffix('.bin'))],check=True)
        binary = stem.with_suffix('.bin').read_bytes()
        if sha(binary) != spec['sha256'] or binary != raw[:spec['size']]:
            raise ValueError('Existing native source differs')
        records.append(dict(classify_tail(raw,name), disk=disk_id, block=block, sha256=sha(raw)))
    mapping = dict(disk='disk2',offset=logical_sector_offset(175)+176,size=80,input_offset=0)
    if verify:
        verify_ownership(manifest,[dict(mapping,input='viewscreen_output_storage')])
    report = dict(classification_evidence=EVIDENCE, assembler_evidence=str(PROOF.relative_to(ROOT)),
                  buffer_behavior=check_proof(proof), data_bytes=176,
                  newly_source_built_bytes=80, already_source_built_bytes=96, records=records)
    path = ROOT/'docs/reference/native-output-storage.json'
    content = json.dumps(report,indent=2)+'\n'
    if verify:
        if path.read_text() != content:
            raise ValueError('Native output storage report differs')
    else:
        path.write_text(content)
    print(json.dumps(dict(data_bytes=176, newly_source_built_bytes=80, verified=verify,
                          external_replayed=external is not None)))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verify',action='store_true')
    parser.add_argument('--external-assembler',type=Path)
    args = parser.parse_args()
    run(args.verify,args.external_assembler)
