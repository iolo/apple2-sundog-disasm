#!/usr/bin/env python3
"""Audit retained disk symbols and complete byte ownership of encoded banks."""
import argparse
from collections import Counter
import json
import subprocess

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from encoded_overlay_tail import audit as audit_tail
from encoded_retained_stubs import audit as audit_stubs
from native_raw_source import analyze
from play_disk_final_track import reference_track, EVIDENCE as TRACK_EVIDENCE
from pcode_copies import verify_ownership
from storage_encoding import transform

EVIDENCE = 'docs/encoded-bank-completion.md'
SYMBOLS = ((0x5F0,b'\xff','retained-disk-fill-symbol'),
           (0x5F6,b'\xd5\xd7','retained-disk-marker'))


def audit_symbols(raw, body, track):
    if len(raw) != 2048 or sha(raw) != body['sha256']:
        raise ValueError('Symbol bank differs from reviewed body')
    items = {i['offset']: i for i in body['items']}
    for offset, size, kind in [(0x5E8,8,'disk-symbol-table'),(0x5F1,5,'disk-read-buffer'),
                               (0x5F8,1,'track-sequence-index')]:
        item = items.get(offset,{})
        if (item.get('classification'),item.get('size'),item.get('kind')) != ('data',size,kind):
            raise ValueError('Surrounding symbol/buffer data differs')
    if raw[0x5E8:0x5F0] != bytes.fromhex('af ab d5 ea f5 fa fd fe'):
        raise ValueError('Reviewed searched symbol table differs')
    if raw[0x5F1:0x5F6] != bytes(5):
        raise ValueError('Reviewed read-buffer initializer differs')
    comparisons = [(0x141,255),(0x480,213),(0x489,215),(0x4DC,213),(0x4EB,215)]
    for offset, value in comparisons:
        item = items.get(offset,{})
        if (item.get('classification'),item.get('mnemonic'),item.get('mode'),item.get('operand_value')) != ('code','cmp','Im',value):
            raise ValueError('Disk-format comparison evidence differs')
        if raw[offset:offset+2] != bytes([0xC9,value]):
            raise ValueError('Disk-format immediate bytes differ')
    for offset in (0x13C,0x47B,0x484,0x4D7,0x4E6):
        item = items.get(offset,{})
        if item.get('assembly') != 'lda a:$C08C,x' or raw[offset:offset+3] != bytes.fromhex('bd 8c c0'):
            raise ValueError('Comparison no longer follows a reviewed disk-latch read')
    if (len(track) != 6656 or sha(track) != '98ebd274cb813d4a9020d696fcf7a9d120277d0181da7cb2b8bc5d605ce67788'
            or track[0x350:0x352] != bytes.fromhex('d5d7') or track[0x352] != 255):
        raise ValueError('Independent raw-track marker/fill evidence differs')
    result = []
    for start, expected, kind in SYMBOLS:
        for offset in (start,start+512):
            if raw[offset:offset+len(expected)] != expected:
                raise ValueError('Retained disk symbol or copied symbol differs')
            if offset in items:
                raise ValueError('Symbol already has body ownership')
            result.append(dict(offset=offset,size=len(expected),classification='data',kind=kind,
                               source_offset=start,hex=expected.hex()))
    return sorted(result,key=lambda i:i['offset'])


def combine(layers):
    owners = [None]*2048
    counts = Counter()
    layer_counts = {}
    for name,items in layers.items():
        subtotal = Counter()
        for item in items:
            kind = item['classification']
            if kind not in ('code','data'):
                raise ValueError('Unexpected byte classification')
            lo,hi = item['offset'],item['offset']+item['size']
            if not 0 <= lo < hi <= 2048:
                raise ValueError('Combined classification exceeds bank')
            for offset in range(lo,hi):
                if owners[offset] is not None:
                    raise ValueError('Combined bank classification overlaps')
                owners[offset] = kind
            subtotal[kind] += item['size']
        layer_counts[name] = dict(subtotal)
        counts.update(subtotal)
    if any(owner is None for owner in owners):
        raise ValueError('Combined bank classification has gaps')
    runs = []
    for offset,kind in enumerate(owners):
        if runs and runs[-1]['classification'] == kind:
            runs[-1]['size'] += 1
        else:
            runs.append(dict(offset=offset,size=1,classification=kind))
    return dict(coverage_bytes=dict(counts),layers=layer_counts,byte_classification_runs=runs,
                unclassified_bytes=0)


def prepare(verify=False):
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    track = reference_track(json.loads(TRACK_EVIDENCE.read_text()))
    artifacts, reports, ownership = {}, [], []
    for variant in ('play','alternate'):
        recipe = json.loads((ROOT/'src/native/evidence'/f'encoded_body_{variant}.json').read_text())
        loader_recipe = json.loads((ROOT/'src/native/evidence'/f'encoded_loader_{variant}.json').read_text())
        origin = recipe['origin']
        disk = next(d for d in manifest['disks'] if d['id'] == origin['disk'])
        image = (ROOT/'build/disks'/disk['filename']).read_bytes()
        if sha(image) != disk['sha256']:
            raise ValueError('Rebuild exact baseline before bank completion audit')
        stored = block_bytes(image,origin['block'],origin['block']+4)
        if sha(stored) != recipe['sha256']:
            raise ValueError('Reviewed encoded bank differs')
        raw = transform(stored,recipe['storage_encoding'],decode=True)
        loader = analyze(raw[:63],loader_recipe['base'],loader_recipe)
        body = analyze(raw,recipe['base'],recipe,inspect_gaps=True)
        tail = audit_tail(raw,body)
        stubs = audit_stubs(raw,recipe['base'],body)
        symbols = audit_symbols(raw,body,track)
        report = combine(dict(loader=loader['items'],body=body['items'],
                              footer_and_copies=tail['items'],retained_stubs=stubs['items'],symbols=symbols))
        report.update(variant=variant,origin=origin,sha256=sha(raw),storage_sha256=sha(stored),
                      symbol_items=symbols,live_body_execution_established=False,
                      raw_track_sha256=sha(track),raw_marker_offset=0x350)
        if verify:
            for position in range(2048):
                logical = origin['block']*512+position
                offset = logical_sector_offset(logical//256)+logical%256
                region = next(r for r in disk['regions'] if r['offset'] <= offset < r['offset']+r['size'])
                spec = manifest['components'][region['input']]
                encoding = spec.get('storage_encoding',{})
                if (spec['kind'] != 'ca65-source' or encoding.get('kind') != 'additive-byte-sequence'
                        or encoding.get('seed') != recipe['storage_encoding']['seed']
                        or encoding.get('step') != recipe['storage_encoding']['step']
                        or encoding.get('offset',-1)+region['input_offset']+offset-region['offset'] != position):
                    raise ValueError('Complete bank lacks correctly phased source ownership')
        reports.append(report)
        output = ROOT/'build/raw-preparation'/f'encoded_symbols_{variant}'
        output.mkdir(parents=True,exist_ok=True)
        for item in symbols:
            start,size = item['offset'],item['size']
            name = f'encoded_symbols_{variant}_{start:04x}'
            stem = ROOT/'src/native'/name
            text = (f'; Evidence: {EVIDENCE}\n; {item["kind"]}; no live read of this stored field is claimed.\n'
                    '.segment "SYMBOL_DATA"\n'
                    '    .byte '+','.join(f'${b:02X}' for b in raw[start:start+size])+'\n')
            config = (f'MEMORY {{ IMAGE: start = 0, size = {size}, file = %O; }}\n'
                      'SEGMENTS { SYMBOL_DATA: load = IMAGE, type = ro; }\n')
            work = output/name
            work.with_suffix('.s').write_text(text)
            work.with_suffix('.cfg').write_text(config)
            subprocess.run(['ca65',str(work.with_suffix('.s')),'-o',str(work.with_suffix('.o'))],check=True)
            subprocess.run(['ld65','-C',str(work.with_suffix('.cfg')),str(work.with_suffix('.o')),
                            '-o',str(work.with_suffix('.bin'))],check=True)
            encoding = dict(recipe['storage_encoding'],offset=start,evidence=EVIDENCE)
            binary = work.with_suffix('.bin').read_bytes()
            if binary != raw[start:start+size] or transform(binary,encoding) != stored[start:start+size]:
                raise ValueError('Disk-symbol assembly or encoding differs')
            logical = origin['block']*512+start
            mappings = [dict(disk=disk['id'],offset=logical_sector_offset(logical//256)+logical%256,
                             size=size,input_offset=0)]
            adoption = dict(name=name,source=str(stem.with_suffix('.s').relative_to(ROOT)),
                            config=str(stem.with_suffix('.cfg').relative_to(ROOT)),
                            storage_encoding=encoding,mappings=mappings)
            ownership += [dict(m,input=name) for m in mappings]
            artifacts[stem.with_suffix('.s')] = text
            artifacts[stem.with_suffix('.cfg')] = config
            artifacts[stem.with_suffix('.adopt.json')] = json.dumps(adoption,indent=2)+'\n'
    artifacts[ROOT/'docs/reference/encoded-bank-completion.json'] = json.dumps(
        dict(classification_evidence=EVIDENCE,records=reports),indent=2)+'\n'
    for path,content in artifacts.items():
        if verify:
            if not path.is_file() or path.read_text() != content:
                raise ValueError(f'Encoded completion artifact differs: {path}')
        elif path.exists():
            raise ValueError(f'Encoded completion artifact already exists: {path}')
    if verify:
        verify_ownership(manifest,ownership)
    else:
        for path,content in artifacts.items():
            path.write_text(content)
    print(json.dumps(dict(banks=2,bytes_classified=4096,new_data_bytes=12,
                          coverage_each=reports[0]['coverage_bytes'],verified=verify)))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verify',action='store_true')
    prepare(parser.parse_args().verify)
