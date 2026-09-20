#!/usr/bin/env python3
"""Extract the base dialogue dictionary and evidenced supplemental text records."""
import argparse
import json
from pathlib import Path

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha


def text_fields(raw):
    return dict(stored_characters=''.join(chr(n & 127) for n in raw),
                high_bit_positions=[i for i,n in enumerate(raw) if n & 128])


def text_bytes(fields):
    text, positions = fields['stored_characters'], fields['high_bit_positions']
    if (not isinstance(text,str) or any(ord(c)>127 for c in text)
            or any(type(i) is not int or not 0 <= i < len(text) for i in positions)
            or positions != sorted(set(positions))):
        raise ValueError('Invalid stored text or high-bit positions')
    marked = set(positions)
    return bytes(ord(c)+(128 if i in marked else 0) for i,c in enumerate(text))


def base_offsets(raw):
    if not 65 <= len(raw) <= 1024 or raw[0] != 65:
        raise ValueError('Expected 65 low-byte dictionary offsets')
    page, previous, offsets = 0, 0, []
    for value in raw[:65]:
        if value < previous:
            page += 256
        offsets.append(page+value)
        previous = value
    if offsets[-1] > len(raw):
        raise ValueError('Dictionary pointers exceed available text')
    return offsets


def decode_base(raw):
    offsets = base_offsets(raw)
    if offsets[-1] != len(raw):
        raise ValueError('Unreviewed dictionary allocation tail')
    return dict(entries=[text_fields(raw[a:b]) for a,b in zip(offsets,offsets[1:])])


def encode_base(fields):
    entries = fields['entries']
    if len(entries) != 64:
        raise ValueError('Expected 64 dictionary entries')
    rows = [text_bytes(entry) for entry in entries]
    if any(len(row)>255 for row in rows):
        raise ValueError('Entry crosses an unrepresentable full pointer page')
    offsets, cursor = [65], 65
    for row in rows:
        cursor += len(row)
        offsets.append(cursor)
    if cursor > 1024:
        raise ValueError('Base dictionary exceeds its two-block allocation')
    raw = bytes(n%256 for n in offsets)+b''.join(rows)
    if base_offsets(raw) != offsets:
        raise ValueError('Low-byte pointer reconstruction disagrees')
    return raw


def decode_extra(raw):
    if len(raw)<3 or raw[0]!=18 or raw[2]*2<18:
        raise ValueError('Expected supplemental dictionary metadata')
    cursor, entries = 3, []
    for _ in range(raw[1]):
        if cursor >= len(raw):
            raise ValueError('Truncated supplemental length')
        size = raw[cursor]
        end = cursor+1+size
        if end > len(raw):
            raise ValueError('Truncated supplemental text')
        entries.append(text_fields(raw[cursor+1:end]))
        cursor = end
        # The source begins on an even address; virtual prefix is three bytes.
        if (cursor-3)&1:
            if cursor >= len(raw) or raw[cursor] != 0:
                raise ValueError('Missing/nonzero unreviewed word alignment')
            cursor += 1
    if cursor != len(raw) or raw[2]*2+cursor-3 > 512:
        raise ValueError('Supplement extent or allocation boundary disagrees')
    return dict(marker=raw[0],start_word=raw[2],entries=entries)


def encode_extra(fields):
    marker,start,entries = fields['marker'],fields['start_word'],fields['entries']
    if (any(type(n) is not int or not 0 <= n <= 255 for n in (marker,start))
            or marker!=18 or start<9 or len(entries)>255):
        raise ValueError('Invalid supplemental metadata')
    raw = bytearray([marker,len(entries),start])
    for entry in entries:
        row = text_bytes(entry)
        if len(row)>255:
            raise ValueError('Supplemental text exceeds byte length')
        raw.append(len(row))
        raw.extend(row)
        if (len(raw)-3)&1:
            raw.append(0)
    raw = bytes(raw)
    if decode_extra(raw) != fields:
        raise ValueError('Supplemental fields do not round trip')
    return raw


def extract(output):
    output = output.resolve()
    relative = output.relative_to(ROOT)
    if output.exists():
        raise ValueError('Dialogue dictionary output already exists')
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disk = next(d for d in manifest['disks'] if d['id']=='disk2')
    image = (ROOT/'build/disks'/disk['filename']).read_bytes()
    if sha(image) != disk['sha256']:
        raise ValueError('Rebuild current baseline before extraction')
    loaded = block_bytes(image,88,90)
    end = base_offsets(loaded)[-1]
    prepared = [('base',88,loaded[:end],decode_base(loaded[:end]),[(0,end,0)])]
    for block in range(90,103):
        bank = block_bytes(image,block,block+1)
        if bank[0]==16:
            continue
        start = cursor = bank[17]*2
        for _ in range(bank[16]):
            if cursor >= 512:
                raise ValueError('Supplement length lies outside its block')
            cursor += bank[cursor]+1
            cursor += cursor&1
        if cursor > 512:
            raise ValueError('Supplement text lies outside its block')
        raw = bank[:1]+bank[16:18]+bank[start:cursor]
        fields = decode_extra(raw)
        prepared.append(('supplement',block,raw,fields,[(0,1,0),(16,2,1),(start,cursor-start,3)]))
    data, mappings, sections, fields = bytearray(), [], [], []
    for kind,block,raw,entry,ranges in prepared:
        encoded = encode_base(entry) if kind=='base' else encode_extra(entry)
        if encoded != raw:
            raise ValueError('Dictionary text round trip differs')
        input_base = len(data)
        for start,size,input_offset in ranges:
            position = 0
            while position<size:
                address = block*512+start+position
                offset = logical_sector_offset(address//256)+address%256
                length = min(size-position,256-address%256)
                owners = [r for r in disk['regions'] if r['offset']<=offset and offset+length<=r['offset']+r['size']]
                if len(owners)!=1 or manifest['components'][owners[0]['input']]['kind']!='temporary-unresolved':
                    raise ValueError('Dictionary overlaps reconstructed bytes')
                mappings.append(dict(disk='disk2',offset=offset,size=length,input_offset=input_base+input_offset+position))
                position += length
        sections.append(dict(kind=kind,block=block,input_offset=input_base,size=len(raw),
                             bank_ranges=[[start,start+size] for start,size,_ in ranges]))
        fields.append(dict(kind=kind,block=block,fields=entry))
        data.extend(raw)
    report = dict(classification='data',classification_evidence='docs/dialogue-dictionary.md',
                  size=len(data),sha256=sha(data),base_consumed_bytes=end,
                  supplemental_banks=len(prepared)-1,sections=sections,
                  excluded='Script ranges, base bytes 808–1023, bank 98, and all other block tails')
    recipe = dict(name='dialogue_dictionary',data=str(relative/'dictionary.bin'),
                  format='Low-byte indexed dialogue text and counted word-aligned supplemental text',
                  classification=report['classification_evidence'],mappings=mappings)
    output.mkdir(parents=True)
    (output/'dictionary.bin').write_bytes(data)
    for name,value in [('fields.json',fields),('manifest.json',report),('adopt.json',recipe)]:
        (output/name).write_text(json.dumps(value,indent=2)+'\n')
    print(f'Extracted {len(data)} dictionary bytes from the base and {len(prepared)-1} supplemental banks')


def verify(output):
    data = (output/'dictionary.bin').read_bytes()
    report = json.loads((output/'manifest.json').read_text())
    fields = json.loads((output/'fields.json').read_text())
    if len(data)!=report['size'] or sha(data)!=report['sha256'] or len(fields)!=len(report['sections']):
        raise ValueError('Dictionary manifest differs')
    cursor = 0
    for section,entry in zip(report['sections'],fields):
        if section['input_offset']!=cursor or (section['kind'],section['block'])!=(entry['kind'],entry['block']):
            raise ValueError('Dictionary section mapping differs')
        raw = data[cursor:cursor+section['size']]
        decode,encode = (decode_base,encode_base) if section['kind']=='base' else (decode_extra,encode_extra)
        if decode(raw)!=entry['fields'] or encode(entry['fields'])!=raw:
            raise ValueError('Dictionary text/encoding differs')
        cursor += section['size']
    if cursor!=len(data):
        raise ValueError('Unaccounted dictionary bytes')
    print(f'Verified {len(data)} dictionary bytes and all reversible text fields')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--extract',type=Path)
    group.add_argument('--verify',type=Path)
    args = parser.parse_args()
    extract(args.extract) if args.extract else verify(args.verify)
