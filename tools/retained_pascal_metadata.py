#!/usr/bin/env python3
"""Reconstruct two reviewed fragments of retained Pascal metadata."""
import argparse
import json
import struct
import subprocess

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from pcode_copies import verify_ownership

EVIDENCE = 'docs/retained-pascal-metadata.md'
DIRECTORY_NAMES = [b'MAINB.LIB.TEXT', b'GRND.LIB.TEXT', b'SHIP.LIB.TEXT',
                   b'DUMMY.CODE', b'DUMMY.CODE', b'SETPRINT.TEXT',
                   b'SHIP.RDMAP.TEXT', b'CHAIN.LIBRARY', b'WCHAR.ASM.TEXT']
INFO_WORDS = [0xa200, 0xa201, 0xa203, 0xa204, 0xa205] + [0xa200] * 11


def directory_fragment(raw):
    if len(raw) != 512:
        raise ValueError('Expected a complete containing block')
    items = [dict(offset=94, size=2, kind='clipped-directory-date', values=[0xa9f7])]
    if raw[94:96] != bytes.fromhex('f7a9'):
        raise ValueError('Leading retained date differs')
    records = []
    for index, name in enumerate(DIRECTORY_NAMES):
        offset = 96 + index * 26
        record = raw[offset:offset+26]
        first, end, kind, length = struct.unpack_from('<HHHB', record)
        remaining, date = struct.unpack_from('<HH', record, 22)
        if (record[7:7+len(name)] != name or length != (len(name) if index < 4 else 0)
                or remaining != 512):
            raise ValueError('Retained directory name, length or final-block count differs')
        if index < 4 and (not 0 < first < end <= 320 or kind != (3 if index < 3 else 2)
                          or date != 0xa868):
            raise ValueError('Named directory record fields differ')
        # Cleared-name records retain overwritten numeric fields. Do not accept
        # them as valid file allocations or try to repair their stored values.
        records.append(dict(offset=offset, first_block=first, end_block=end,
                            type_storage=kind, name_length=length, retained_name=name.decode(),
                            final_block_bytes=remaining, date_storage=date))
        items += [dict(offset=offset, size=6, kind='directory-extent-and-type', values=[first,end,kind]),
                  dict(offset=offset+6, size=1, kind='directory-name-length', values=[length]),
                  dict(offset=offset+7, size=15, kind='directory-name-storage', text=name.decode()),
                  dict(offset=offset+22, size=4, kind='directory-size-and-date', values=[remaining,date])]
    if any(raw[330:]):
        raise ValueError('Nonzero retained directory spare storage requires review')
    items.append(dict(offset=330, size=182, kind='zero-directory-storage'))
    return dict(start=94, end=512, items=items, records=records,
                interpretation='Directory residue; no enclosing volume header or current allocation claimed')


def header_fragment(raw):
    if len(raw) != 512:
        raise ValueError('Expected a complete containing block')
    # The old header starts at containing-block offset 12. Its earlier fields
    # are overwritten by the current SYSTEM.PASCAL fragment and are excluded.
    if raw[170:204] != b' ' * 34:
        raise ValueError('Retained header name storage differs')
    kinds = list(struct.unpack_from('<16H', raw, 204))
    texts = list(struct.unpack_from('<16H', raw, 236))
    info = list(struct.unpack_from('<16H', raw, 268))
    if any(kinds + texts) or info != INFO_WORDS:
        raise ValueError('Retained header table layout differs')
    if int.from_bytes(raw[300:304], 'little') != 0x44:
        raise ValueError('Retained header intrinsic set differs')
    if any(raw[304:]):
        raise ValueError('Nonzero retained header extension requires review')
    items = [dict(offset=170, size=34, kind='clipped-header-name-storage', text=' ' * 34),
             dict(offset=204, size=32, kind='segment-kind-words', values=kinds),
             dict(offset=236, size=32, kind='segment-text-address-words', values=texts),
             dict(offset=268, size=32, kind='segment-information-words', values=info),
             dict(offset=300, size=4, kind='intrinsic-segment-set', values=[0x44]),
             dict(offset=304, size=140, kind='zero-library-information'),
             dict(offset=444, size=1, kind='comment-length', values=[0]),
             dict(offset=445, size=67, kind='zero-clipped-comment-storage')]
    return dict(start=170, end=512, header_origin_in_containing_block=12,
                missing_prefix_bytes=158, missing_suffix_bytes=12, items=items,
                intrinsic_segments=[2,6])


def declarations(raw, report, label):
    cursor, lines = report['start'], [label + ':']
    for item in report['items']:
        offset, size, kind = (item[k] for k in ('offset','size','kind'))
        if offset != cursor:
            raise ValueError('Metadata ownership gap or overlap')
        lines.append(f'; Block +${offset:03X}: {kind}')
        data = raw[offset:offset+size]
        if kind.startswith('zero-'):
            lines.append(f'    .res {size}, 0')
        elif kind == 'intrinsic-segment-set':
            lines.append(f'    .dword ${item["values"][0]:08X} ; segments 2 and 6')
        elif 'values' in item:
            width = size // len(item['values'])
            if width not in (1,2):
                raise ValueError('Unexpected metadata field width')
            directive = '.byte' if width == 1 else '.word'
            lines.append('    ' + directive + ' ' + ','.join(f'${v:0{2*width}X}' for v in item['values']))
        else:
            lines.append('; Retained name storage: ' + repr(item['text']))
            lines.append('    .byte ' + ','.join(f'${value:02X}' for value in data))
        cursor += size
    if cursor != report['end']:
        raise ValueError('Metadata ownership does not reach the reviewed end')
    lines.append(f'.assert * - {label} = {cursor-report["start"]}, error, "Metadata fragment extent"')
    return '\n'.join(lines)


def prepare(verify=False):
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disks = {d['id']:d for d in manifest['disks']}
    images = {key:(ROOT/'build/disks'/d['filename']).read_bytes() for key,d in disks.items()}
    if any(sha(images[key]) != d['sha256'] for key,d in disks.items()):
        raise ValueError('Rebuild exact baseline before metadata preparation')
    name = 'retained_pascal_metadata'
    lines = ['; Classified data: ' + EVIDENCE, '.segment "RETAINED_METADATA"']
    records, mappings, binary = [], [], bytearray()
    for label, parser, origins in [('directory_tail', directory_fragment, [('disk1',117),('disk2',117)]),
                                   ('header_tail', header_fragment, [('disk1',259)])]:
        first_raw = block_bytes(images[origins[0][0]], origins[0][1], origins[0][1]+1)
        report = parser(first_raw)
        start,end = report['start'],report['end']
        selected = first_raw[start:end]
        lines.append(declarations(first_raw, report, label))
        for disk,block in origins:
            raw = block_bytes(images[disk], block, block+1)
            if parser(raw) != report or raw[start:end] != selected:
                raise ValueError('Retained metadata copy differs')
            records.append(dict(disk=disk, block=block, sha256=sha(selected), **report))
            cursor = start
            while cursor < end:
                size = min(256-cursor%256, end-cursor)
                mappings.append(dict(disk=disk, offset=logical_sector_offset(block*2+cursor//256)+cursor%256,
                                     size=size, input_offset=len(binary)+cursor-start))
                cursor += size
        binary.extend(selected)
    source = '\n\n'.join(lines)+'\n'
    config = (f'MEMORY {{ IMAGE: start = 0, size = {len(binary)}, file = %O; }}\n'
              'SEGMENTS { RETAINED_METADATA: load = IMAGE, type = ro; }\n')
    stem = ROOT/'src/data'/name
    recipe = dict(name=name, source=str(stem.with_suffix('.s').relative_to(ROOT)),
                  config=str(stem.with_suffix('.cfg').relative_to(ROOT)), mappings=mappings)
    audit = dict(classification='data', classification_evidence=EVIDENCE,
                 source_output_bytes=len(binary), disk_output_bytes=sum(m['size'] for m in mappings),
                 records=records)
    artifacts = {stem.with_suffix('.s'):source, stem.with_suffix('.cfg'):config,
                 stem.with_suffix('.adopt.json'):json.dumps(recipe,indent=2)+'\n',
                 ROOT/'docs/reference/retained-pascal-metadata.json':json.dumps(audit,indent=2)+'\n'}
    output = ROOT/'build/retained-pascal-metadata'
    output.mkdir(parents=True,exist_ok=True)
    (output/'module.s').write_text(source)
    (output/'module.cfg').write_text(config)
    subprocess.run(['ca65',str(output/'module.s'),'-o',str(output/'module.o')],check=True)
    subprocess.run(['ld65','-C',str(output/'module.cfg'),str(output/'module.o'),'-o',str(output/'module.bin')],check=True)
    if (output/'module.bin').read_bytes() != binary:
        raise ValueError('Metadata declarations do not assemble exactly')
    for path,text in artifacts.items():
        if verify:
            if not path.is_file() or path.read_text() != text:
                raise ValueError(f'Metadata artifact differs: {path}')
        elif path.exists():
            raise ValueError(f'Metadata artifact already exists: {path}')
    if verify:
        verify_ownership(manifest, [dict(m,input=name) for m in mappings])
    else:
        for path,text in artifacts.items():
            path.write_text(text)
    print(json.dumps(dict(source_bytes=len(binary),disk_bytes=audit['disk_output_bytes'],verified=verify)))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verify',action='store_true')
    prepare(parser.parse_args().verify)
