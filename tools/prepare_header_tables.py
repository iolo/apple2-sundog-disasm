#!/usr/bin/env python3
"""Prepare reviewed Pascal header tables; leave the unreviewed block tails alone.

Maintenance only. Reads the current rebuilt disks and recorded inventory, then
proves generated ca65 data declarations before writing source/adoption artifacts.
"""
import json
from pathlib import Path
import subprocess

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from pascal_inventory import parse_header, word


TABLE_SIZE = 288
REVIEWED_HEADERS = [('disk1', n) for n in (84, 85, 103, 140, 157, 251)] + [
    ('disk2', 103), ('disk2', 140)]


def declarations(data, label):
    if len(data) != TABLE_SIZE:
        raise ValueError('Expected only the 288-byte table region')
    # The parser uses only these tables; the actual tail is deliberately excluded.
    parse_header(data + bytes(512 - TABLE_SIZE))
    lines = [f'{label}:', '; Sixteen relative-block / byte-length pairs.']
    for slot in range(16):
        lines.append(f'    .word {word(data, slot*4)}, {word(data, slot*4+2)} ; slot {slot}')
    lines += [f'.assert * - {label} = $40, error, "Extent table size"',
              '; Sixteen eight-byte names; stripped names retain their zero bytes.']
    for slot in range(16):
        name = data[64+slot*8:72+slot*8]
        lines.append('    .byte ' + ','.join(f'${b:02X}' for b in name) + f' ; slot {slot}')
    for offset, title in ((192, 'Segment kinds'), (224, 'Text-block pointers'),
                          (256, 'Packed segment / machine / version words')):
        lines += [f'.assert * - {label} = ${offset:02X}, error, "Table offset"', '; '+title]
        for slot in range(16):
            value = word(data, offset+slot*2)
            comment = f'slot {slot}'
            if offset == 256 and value:
                comment += f', segment {value & 255}, machine {(value >> 8) & 15}, version {value >> 13}'
            lines.append(f'    .word ${value:04X} ; {comment}')
    lines += [f'.assert * - {label} = $120, error, "Header table size"']
    return '\n'.join(lines)


def prepare():
    stem = ROOT / 'src/data/pascal_header_tables'
    paths = [stem.with_suffix(suffix) for suffix in ('.s', '.cfg', '.adopt.json')]
    audit_path = ROOT / 'docs/reference/header-tables.json'
    if any(path.exists() for path in paths + [audit_path]):
        raise ValueError('Prepared header artifacts already exist')
    manifest = json.loads((ROOT / 'reconstruction/manifest.json').read_text())
    inventory = json.loads((ROOT / 'docs/pascal-inventory.json').read_text())
    disks = {d['id']: d for d in manifest['disks']}
    images = {key: (ROOT / 'build/disks' / disk['filename']).read_bytes()
              for key, disk in disks.items()}
    if any(sha(images[key]) != disk['sha256'] for key, disk in disks.items()):
        raise ValueError('Rebuild current baseline before preparing headers')
    binary, groups, mappings = b'', {}, []
    for disk_id, block in REVIEWED_HEADERS:
        original = block_bytes(images[disk_id], block, block+1)
        recorded = next(h for h in inventory['headers'] if (h['disk'], h['block']) == (disk_id, block))
        if sha(original) != recorded['sha256']:
            raise ValueError('Header differs from recorded inventory')
        data = original[:TABLE_SIZE]
        if data not in groups:
            label = f'{disk_id}_header_{block}'
            groups[data] = dict(label=label, input_offset=len(binary), sha256=sha(data),
                                declarations=declarations(data, label), occurrences=[])
            binary += data
        group = groups[data]
        group['occurrences'].append(dict(disk=disk_id, block=block,
            table_range=[0, TABLE_SIZE], remaining_tail_range=[TABLE_SIZE, 512],
            segment_statuses=[dict(slot=e['slot'], status=e['status']) for e in recorded['entries']]))
        for position in range(0, TABLE_SIZE, 256):
            offset = logical_sector_offset(block*2 + position//256)
            size = min(256, TABLE_SIZE-position)
            owners = [r for r in disks[disk_id]['regions'] if r['offset'] <= offset
                      and offset+size <= r['offset']+r['size']]
            if len(owners) != 1 or manifest['components'][owners[0]['input']]['kind'] != 'temporary-unresolved':
                raise ValueError('Header table overlaps reconstructed bytes')
            mappings.append(dict(disk=disk_id, offset=offset, size=size,
                                 input_offset=group['input_offset']+position))
    source = ('; Classified data only. Evidence: docs/pascal-header-tables.md\n'
              '; The remaining 224 bytes of each header block are not included.\n'
              '.segment "HEADER_TABLES"\n\n' +
              '\n\n'.join(group['declarations'] for group in groups.values()) + '\n')
    config = (f'MEMORY {{ IMAGE: start = 0, size = {len(binary)}, file = %O; }}\n'
              'SEGMENTS { HEADER_TABLES: load = IMAGE, type = ro; }\n')
    output = ROOT / 'build/header-preparation'
    output.mkdir(parents=True, exist_ok=True)
    (output / 'tables.s').write_text(source)
    (output / 'tables.cfg').write_text(config)
    subprocess.run(['ca65', str(output / 'tables.s'), '-o', str(output / 'tables.o')], check=True)
    subprocess.run(['ld65', '-C', str(output / 'tables.cfg'), str(output / 'tables.o'),
                    '-o', str(output / 'tables.bin')], check=True)
    if (output / 'tables.bin').read_bytes() != binary:
        raise ValueError('Header declarations failed exact round trip')
    recipe = dict(name=stem.name, source=str(paths[0].relative_to(ROOT)),
                  config=str(paths[1].relative_to(ROOT)), mappings=mappings)
    report = dict(classification='data', classification_evidence='docs/pascal-header-tables.md',
        header_occurrences=len(REVIEWED_HEADERS), unique_tables=len(groups),
        source_output_bytes=len(binary), disk_output_bytes=sum(m['size'] for m in mappings),
        sha256=sha(binary), table_regions=[dict(offset=a, size=b, kind=k) for a,b,k in
            [(0,64,'relative-block-and-length'), (64,128,'segment-names'),
             (192,32,'segment-kind'), (224,32,'text-block'), (256,32,'segment-info')]],
        tables=[{k:v for k,v in g.items() if k != 'declarations'} for g in groups.values()],
        byte_identical_assembly=True,
        scope_limit='Tables only; does not classify header tails or validate orphan segment references')
    stem.parent.mkdir(parents=True, exist_ok=True)
    for path, content in zip(paths, (source, config, json.dumps(recipe, indent=2)+'\n')):
        path.write_text(content)
    audit_path.write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps({k: report[k] for k in ('header_occurrences', 'unique_tables', 'disk_output_bytes')}))


if __name__ == '__main__':
    prepare()
