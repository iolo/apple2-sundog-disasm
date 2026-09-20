#!/usr/bin/env python3
"""Extract evidenced save-state data, excluding separately audited bank tails."""
import argparse
import json
from pathlib import Path
import struct

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha

SECTIONS = [('globals', 512, 256), ('records16', 1024, 8),
            ('records32', 2048, 16), ('world_table_23', 240, 120),
            ('world_table_24', 288, 144), ('world_table_25', 912, 456)]
PAYLOAD_SIZE = sum(size for _, size, _ in SECTIONS)


def checksum(data):
    if len(data) != 5120:
        raise ValueError('Save checksum requires the full ten-block bank')
    return (sum(data[::2]) & 255) | ((sum(data[1::2]) & 255) << 8)


def decode_payload(data):
    if len(data) != PAYLOAD_SIZE:
        raise ValueError('Expected precisely 5,024 reviewed state bytes')
    result, offset = {}, 0
    for name, size, width in SECTIONS:
        words = list(struct.unpack(f'<{size//2}H', data[offset:offset+size]))
        result[name] = [words[i:i+width] for i in range(0,len(words),width)]
        offset += size
    return result


def encode_payload(fields):
    if set(fields) != {name for name, _, _ in SECTIONS}:
        raise ValueError('State sections differ from reviewed layout')
    result = bytearray()
    for name, size, width in SECTIONS:
        rows = fields[name]
        if len(rows) != size//2//width or any(len(row) != width for row in rows):
            raise ValueError(f'Incorrect record dimensions: {name}')
        words = [word for row in rows for word in row]
        if any(type(word) is not int or not 0 <= word <= 65535 for word in words):
            raise ValueError('State words must be unsigned 16-bit integers')
        result.extend(struct.pack(f'<{len(words)}H', *words))
    return bytes(result)


def decode_slot(data):
    if len(data) != 64 or data[0] > 15 or any(b < 32 or b > 126 for b in data[1:1+data[0]]):
        raise ValueError('Invalid 64-byte save descriptor')
    return dict(name=data[1:1+data[0]].decode('ascii'),
                name_residual_hex=data[1+data[0]:16].hex(),
                words=list(struct.unpack('<24H',data[16:])))


def encode_slot(record):
    name = record['name'].encode('ascii')
    residual = bytes.fromhex(record['name_residual_hex'])
    if len(name)+len(residual) != 15 or any(b < 32 or b > 126 for b in name) or len(record['words']) != 24:
        raise ValueError('Incorrect descriptor fields')
    return bytes([len(name)])+name+residual+struct.pack('<24H',*record['words'])


def extract(output):
    output = output.resolve()
    relative = output.relative_to(ROOT)
    if output.exists():
        raise ValueError('Save-state output already exists')
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disk = next(d for d in manifest['disks'] if d['id'] == 'disk1')
    image = (ROOT/'build/disks'/disk['filename']).read_bytes()
    if sha(image) != disk['sha256']:
        raise ValueError('Rebuild current baseline before extraction')
    slots = block_bytes(image,26,27)[:256]
    payloads, records, audits, mappings = bytearray(), [], [], []

    def mapping(block, position, size, source):
        offset = logical_sector_offset(block*2+position//256)+position%256
        owners = [r for r in disk['regions'] if r['offset'] <= offset
                  and offset+size <= r['offset']+r['size']]
        if len(owners) != 1 or manifest['components'][owners[0]['input']]['kind'] != 'temporary-unresolved':
            raise ValueError('State bytes overlap reconstructed data')
        return dict(disk='disk1', offset=offset, size=size, input_offset=source)

    for slot in range(4):
        first = 27+slot*10
        bank = block_bytes(image,first,first+10)
        descriptor = decode_slot(slots[slot*64:(slot+1)*64])
        stored = descriptor['words'][7]  # Record offset 30.
        if checksum(bank) != stored:
            raise ValueError(f'Save checksum differs for slot {slot}')
        fields = decode_payload(bank[:PAYLOAD_SIZE])
        if encode_payload(fields) != bank[:PAYLOAD_SIZE] or encode_slot(descriptor) != slots[slot*64:(slot+1)*64]:
            raise ValueError('State record round trip differs')
        for pos in range(0,PAYLOAD_SIZE,256):
            mappings.append(mapping(first,pos,min(256,PAYLOAD_SIZE-pos),len(payloads)+pos))
        records.append(dict(slot=slot, descriptor=descriptor, state=fields))
        audits.append(dict(slot=slot, name=descriptor['name'], block=first,
                           input_offset=len(payloads), payload_size=PAYLOAD_SIZE,
                           payload_sha256=sha(bank[:PAYLOAD_SIZE]), full_bank_sha256=sha(bank),
                           stored_checksum=stored, computed_checksum=checksum(bank),
                           unresolved_tail=dict(offset=PAYLOAD_SIZE, size=96, sha256=sha(bank[PAYLOAD_SIZE:]))))
        payloads.extend(bank[:PAYLOAD_SIZE])
    slot_mappings = [mapping(26,0,256,0)]
    sections, offset = [], 0
    for name, size, width in SECTIONS:
        sections.append(dict(name=name, offset=offset, size=size, words_per_record=width,
                             record_count=size//2//width))
        offset += size
    report = dict(classification='data', classification_evidence='docs/save-state-banks.md',
                  payload_bytes=len(payloads), slot_bytes=len(slots),
                  payload_sha256=sha(payloads), slot_sha256=sha(slots),
                  sections=sections, banks=audits)
    output.mkdir(parents=True)
    (output/'payloads.bin').write_bytes(payloads)
    (output/'slots.bin').write_bytes(slots)
    for name, value in [('records.json',records), ('manifest.json',report)]:
        (output/name).write_text(json.dumps(value,indent=2)+'\n')
    for name, filename, locations in [('save_state_payloads','payloads.bin',mappings),
                                       ('save_slot_records','slots.bin',slot_mappings)]:
        recipe = dict(name=name, data=str(relative/filename),
                      format='Saved-game data records; field layout in manifest.json',
                      classification='docs/save-state-banks.md', mappings=locations)
        (output/(name+'.adopt.json')).write_text(json.dumps(recipe,indent=2)+'\n')
    print('Extracted four reviewed state payloads and four descriptors: 20,352 bytes')


def verify(output):
    payloads, slots = ((output/name).read_bytes() for name in ('payloads.bin','slots.bin'))
    report = json.loads((output/'manifest.json').read_text())
    records = json.loads((output/'records.json').read_text())
    if (len(payloads),len(slots),len(records)) != (20096,256,4) or sha(payloads) != report['payload_sha256'] or sha(slots) != report['slot_sha256']:
        raise ValueError('State asset size/hash differs')
    for slot, record in enumerate(records):
        data = payloads[slot*PAYLOAD_SIZE:(slot+1)*PAYLOAD_SIZE]
        descriptor = slots[slot*64:(slot+1)*64]
        if record['slot'] != slot or decode_payload(data) != record['state'] or encode_payload(record['state']) != data:
            raise ValueError('State field round trip differs')
        if decode_slot(descriptor) != record['descriptor'] or encode_slot(record['descriptor']) != descriptor:
            raise ValueError('State descriptor round trip differs')
    print('Verified 20,352 classified state/descriptor bytes; bank tails are outside this asset')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--extract', type=Path)
    group.add_argument('--verify', type=Path)
    args = parser.parse_args()
    extract(args.extract) if args.extract else verify(args.verify)
