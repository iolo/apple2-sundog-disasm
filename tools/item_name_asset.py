#!/usr/bin/env python3
"""Lossless inventory/cargo name records; maintenance extraction from rebuilt disks."""
import argparse
import json
from pathlib import Path

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha


def decode(data):
    if len(data) != 1024:
        raise ValueError('Expected two blocks of 64 sixteen-byte records')
    records = []
    for index in range(64):
        record = data[index*16:(index+1)*16]
        length = record[0]
        if length > 14 or any(b < 32 or b > 126 for b in record[1:1+length]):
            raise ValueError('Invalid counted ASCII name')
        records.append(dict(index=index, name=record[1:1+length].decode('ascii'),
                            residual_hex=record[1+length:15].hex(), value_byte=record[15]))
    return records


def encode(records):
    if len(records) != 64:
        raise ValueError('Expected 64 records')
    result = bytearray()
    for index, record in enumerate(records):
        name = record['name'].encode('ascii')
        residual = bytes.fromhex(record['residual_hex'])
        if record['index'] != index or len(name) > 14 or len(name)+len(residual) != 14:
            raise ValueError('Invalid record index or field widths')
        if any(b < 32 or b > 126 for b in name):
            raise ValueError('Invalid counted ASCII name')
        result.extend(bytes([len(name)])+name+residual+bytes([record['value_byte']]))
    return bytes(result)


def extract(output):
    output = output.resolve()
    relative = output.relative_to(ROOT)
    if output.exists():
        raise ValueError('Extraction directory already exists')
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    prepared = []
    for disk_id, block, variant in [('disk1', 192, 'demo'), ('disk2', 46, 'play')]:
        disk = next(d for d in manifest['disks'] if d['id'] == disk_id)
        image = (ROOT/'build/disks'/disk['filename']).read_bytes()
        if sha(image) != disk['sha256']:
            raise ValueError('Rebuild current baseline before extraction')
        data = block_bytes(image, block, block+2)
        records = decode(data)
        if encode(records) != data:
            raise ValueError('Record round trip differs')
        mappings = [dict(disk=disk_id, offset=logical_sector_offset(block*2+i),
                         size=256, input_offset=i*256) for i in range(4)]
        for mapping in mappings:
            start = mapping['offset']
            owners = [r for r in disk['regions'] if r['offset'] <= start and start+256 <= r['offset']+r['size']]
            if len(owners) != 1 or manifest['components'][owners[0]['input']]['kind'] != 'temporary-unresolved':
                raise ValueError('Name table overlaps reconstructed bytes')
        recipe = dict(name=f'item_names_{variant}', data=str(relative/variant/'records.bin'),
                      format='64 records: counted ASCII name, residual string storage, value byte',
                      classification='docs/item-names.md', mappings=mappings)
        report = dict(disk=disk_id, block=block, size=len(data), sha256=sha(data),
                      record_size=16, record_count=64, inventory_records=[0,32], cargo_records=[32,64],
                      classification='data', classification_evidence='docs/item-names.md')
        prepared.append((variant, data, records, recipe, report))
    for variant, data, records, recipe, report in prepared:
        folder = output/variant
        folder.mkdir(parents=True)
        (folder/'records.bin').write_bytes(data)
        for filename, value in [('records.json', records), ('adopt.json', recipe), ('manifest.json', report)]:
            (folder/filename).write_text(json.dumps(value, indent=2)+'\n')
    print('Extracted 128 typed inventory/cargo records, 2,048 disk bytes')


def verify(output):
    for variant in ('demo', 'play'):
        folder = output/variant
        data = (folder/'records.bin').read_bytes()
        report = json.loads((folder/'manifest.json').read_text())
        records = json.loads((folder/'records.json').read_text())
        if sha(data) != report['sha256'] or decode(data) != records or encode(records) != data:
            raise ValueError(f'Record asset differs: {variant}')
        print(f'Verified {variant}: 64 reversible records')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--extract', type=Path)
    parser.add_argument('--verify', type=Path)
    args = parser.parse_args()
    if bool(args.extract) == bool(args.verify):
        parser.error('Choose exactly one of --extract and --verify')
    extract(args.extract) if args.extract else verify(args.verify)
