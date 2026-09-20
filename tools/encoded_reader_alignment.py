#!/usr/bin/env python3
"""Verify the retained reader's single native alignment byte and its boundaries."""
import argparse
import json
from pathlib import Path

from disk_layout import ROOT, block_bytes, sha
from native_raw_source import analyze
from pcode_source import analyze as analyze_pcode
from storage_encoding import transform
from pcode_copies import verify_ownership

PROOF = ROOT/'src/native/evidence/encoded_reader_alignment.json'
EXPECTED_WINDOWS = ('a935a10400cd010c','a948a935d8bfa9350182ab35')


def check_evidence(proof, external=None):
    if len(proof['windows']) != 2:
        raise ValueError('Alignment evidence windows differ')
    for window,expected in zip(proof['windows'],EXPECTED_WINDOWS):
        raw = bytes.fromhex(window['hex'])
        if raw.hex() != expected or sha(raw) != window['sha256']:
            raise ValueError('Reviewed conditional alignment/byte writer differs')
        if external is not None:
            reference = json.loads((ROOT/proof['assembler_reference']).read_text())
            if sha(external) != reference['file_sha256']:
                raise ValueError('Historical assembler file differs')
            start = window['file_block']*512
            segment = external[start:start+window['segment_size']]
            if sha(segment) != window['segment_sha256']:
                raise ValueError('Historical assembler segment differs')
            audit = analyze_pcode(segment,window['segment'],dialect='apple-pascal-inn')
            lo,hi = window['offset'],window['offset']+window['size']
            items = [dict(offset=i['offset'],assembly=i['assembly'])
                     for i in audit['items'] if lo<=i['offset']<hi]
            if segment[lo:hi] != raw or items != window['instructions']:
                raise ValueError('Alignment excerpt differs from full instruction audit')


def classify(block, records, recipe):
    if len(block) != 512 or len(records) != 512 or block[128:] != records[128:]:
        raise ValueError('Independent interaction-record boundary differs')
    stored = block[:127]
    if sha(stored) != recipe['sha256']:
        raise ValueError('Retained reader prefix differs')
    raw = transform(block[:128],recipe['storage_encoding'],decode=True)
    audit = analyze(raw[:127],recipe['base'],recipe)
    if (audit['coverage_bytes'] != {'code':127} or audit['instruction_count'] != 66
            or audit['items'][-1]['mnemonic'] != 'rts' or raw[127] != 0):
        raise ValueError('Native procedure end/alignment differs')
    return dict(disk='disk1',block=196,offset=127,size=1,classification='data',
                kind='retained-native-word-alignment',decoded_value=0,stored_value=165,
                preceding_instruction_bytes=127,following_record_offset=128,
                historical_producer_identity_proved=False)


def run(external=None):
    check_evidence(json.loads(PROOF.read_text()),external.read_bytes() if external else None)
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disk = next(d for d in manifest['disks'] if d['id']=='disk1')
    image = (ROOT/'build/disks'/disk['filename']).read_bytes()
    if sha(image) != disk['sha256']:
        raise ValueError('Rebuild exact baseline before alignment audit')
    spec = manifest['components']['interaction_records']
    records = (ROOT/spec['path']).read_bytes()
    if spec['kind'] != 'identified-data' or sha(records) != spec['sha256']:
        raise ValueError('Classified interaction-record donor differs')
    recipe = json.loads((ROOT/'src/native/evidence/encoded_disk_reader.json').read_text())
    report = classify(block_bytes(image,196,197),records,recipe)
    adoption = json.loads((ROOT/'src/native/encoded_reader_alignment.adopt.json').read_text())
    verify_ownership(manifest,[dict(m,input=adoption['name']) for m in adoption['mappings']])
    print(json.dumps(dict(report,external_replayed=external is not None)))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--external-assembler',type=Path)
    run(parser.parse_args().external_assembler)
