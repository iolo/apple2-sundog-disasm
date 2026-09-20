#!/usr/bin/env python3
"""One-time preparation of the four reviewed disk-1 Pascal directory blocks.

Reads rebuilt disks, never originals. Normal builds use the emitted ca65 source.
Unknown nonzero spare records are rejected rather than labelled as padding.
"""
import json
import struct
import subprocess

from disk_layout import ROOT, block_bytes, directory, logical_sector_offset, sha


def declarations(data, label):
    if len(data) != 512:
        raise ValueError('Expected a single directory block')
    word = lambda offset: struct.unpack_from('<H', data, offset)[0]
    count = word(16)
    if data[:7] != bytes.fromhex('00000300000006') or data[7:13] != b'SUNDOG' or word(14) != 280 or count not in (6, 7):
        raise ValueError('Unreviewed volume header')
    lines = [f'{label}:']

    def words(offset, number, comment):
        lines.append('    .word ' + ', '.join(f'${word(offset+i*2):04X}' for i in range(number)) + ' ; ' + comment)

    def octets(offset, size, comment):
        lines.append('    .byte ' + ', '.join(f'${v:02X}' for v in data[offset:offset+size]) + ' ; ' + comment)

    words(0, 3, 'directory start/end blocks and type')
    octets(6, 1, 'volume-name length')
    octets(7, 7, 'fixed-width volume-name storage')
    words(14, 4, 'volume blocks, active-file count, access/set dates')
    octets(22, 4, 'reserved header bytes; byte 25 is read by initializer $6A02')
    last = count
    inactive = []
    for index in range(1, 19):
        offset = index * 26
        record = data[offset:offset+26]
        if index > count and not any(record):
            break
        if index > count:
            # The only reviewed nonzero spare entries repeat SYSTEM.PASCAL
            # with a cleared name length, beyond the active-file count.
            expected = bytearray(data[count*26:(count+1)*26])
            expected[6] = 0
            if count != 7 or index > 10 or record != expected or record[7:20] != b'SYSTEM.PASCAL':
                raise ValueError('Unreviewed inactive directory record')
            inactive.append(index)
        lines += [f'{label}_entry_{index}:',
                  '; ' + ('Active file record' if index <= count else 'Inactive SYSTEM.PASCAL record: cleared name length')]
        words(offset, 3, 'first block, exclusive end block, file type')
        octets(offset+6, 1, 'name length')
        octets(offset+7, 15, 'fixed-width name storage, including residual bytes')
        words(offset+22, 2, 'bytes in final block, modification date')
        lines.append(f'.assert * - {label}_entry_{index} = 26, error, "Directory record size"')
        last = index
    spare = (last+1)*26
    if any(data[spare:]):
        raise ValueError('Unreviewed nonzero directory spare space')
    lines += [f'{label}_spare:',
              f'    .res {512-spare}, 0 ; zero-filled unused record storage and block remainder',
              f'.assert * - {label} = 512, error, "Directory block size"']
    return '\n'.join(lines), dict(active_entries=count, inactive_entries=inactive,
                                  zero_spare_offset=spare, zero_spare_size=512-spare)


def prepare():
    stem = ROOT / 'src/data/pascal_directories'
    paths = [stem.with_suffix(suffix) for suffix in ('.s', '.cfg', '.adopt.json')]
    report_path = ROOT / 'docs/reference/directory-tables.json'
    if any(p.exists() for p in paths + [report_path]):
        raise ValueError('Directory artifacts already exist')
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disk = next(d for d in manifest['disks'] if d['id'] == 'disk1')
    image = (ROOT/'build/disks'/disk['filename']).read_bytes()
    if sha(image) != disk['sha256']:
        raise ValueError('Rebuild current baseline before preparation')
    binary, groups, mappings = b'', {}, []
    for block in (79, 80, 81, 82):
        parsed = directory(image, block)
        data = block_bytes(image, block, block+1)
        if data not in groups:
            label = f'directory_{block}'
            source, fields = declarations(data, label)
            groups[data] = dict(label=label, input_offset=len(binary), sha256=sha(data),
                                source=source, fields=fields, files=parsed['files'], blocks=[])
            binary += data
        group = groups[data]
        group['blocks'].append(block)
        for half in range(2):
            offset = logical_sector_offset(block*2+half)
            owners = [r for r in disk['regions'] if r['offset'] <= offset and offset+256 <= r['offset']+r['size']]
            if len(owners) != 1 or manifest['components'][owners[0]['input']]['kind'] != 'temporary-unresolved':
                raise ValueError('Directory overlaps reconstructed bytes')
            mappings.append(dict(disk='disk1', offset=offset, size=256,
                                 input_offset=group['input_offset']+half*256))
    source = ('; Classified data. Evidence: docs/pascal-directories.md\n'
              '.segment "DIRECTORIES"\n\n' + '\n\n'.join(g['source'] for g in groups.values())+'\n')
    config = (f'MEMORY {{ IMAGE: start = 0, size = {len(binary)}, file = %O; }}\n'
              'SEGMENTS { DIRECTORIES: load = IMAGE, type = ro; }\n')
    output = ROOT/'build/directory-preparation'
    output.mkdir(parents=True, exist_ok=True)
    (output/'tables.s').write_text(source)
    (output/'tables.cfg').write_text(config)
    subprocess.run(['ca65', str(output/'tables.s'), '-o', str(output/'tables.o')], check=True)
    subprocess.run(['ld65', '-C', str(output/'tables.cfg'), str(output/'tables.o'), '-o', str(output/'tables.bin')], check=True)
    if (output/'tables.bin').read_bytes() != binary:
        raise ValueError('Directory declarations failed exact assembly comparison')
    recipe = dict(name=stem.name, source=str(paths[0].relative_to(ROOT)),
                  config=str(paths[1].relative_to(ROOT)), mappings=mappings)
    report = dict(classification='data', classification_evidence='docs/pascal-directories.md',
                  disk_output_bytes=2048, source_output_bytes=len(binary), sha256=sha(binary),
                  byte_identical_assembly=True,
                  directories=[{k:v for k,v in g.items() if k != 'source'} for g in groups.values()])
    for path, content in zip(paths, (source, config, json.dumps(recipe, indent=2)+'\n')):
        path.write_text(content)
    report_path.write_text(json.dumps(report, indent=2)+'\n')
    print(f'Prepared {len(binary)} source bytes for 2,048 directory disk bytes')


if __name__ == '__main__':
    prepare()
