#!/usr/bin/env python3
"""Bounded donor searches; a negative result establishes no classification.

External corpora are optional research inputs, never reconstruction inputs.
The report records their hashes so a changed corpus cannot masquerade as a
repeat of the same experiment. Run from any directory; see --help for paths.
"""
import argparse
import json
import os
from pathlib import Path
import zipfile

from disk_layout import ROOT, block_bytes, sha
from pascal_inventory import procedure_dictionary, word


def receipt(name, data):
    return dict(path=name, size=len(data), sha256=sha(data))


def windows(data, width):
    return ((i, data[i:i+width]) for i in range(len(data)-width+1))


def bitstreams(raw):
    reverse = bytes(int(f'{b:08b}'[::-1], 2) for b in range(256))
    for rev in (False, True):
        src = raw.translate(reverse) if rev else raw
        for shift in range(1, 8):
            for direction in ('left', 'right'):
                data = bytes((
                    ((a << shift) | (b >> (8-shift))) if direction == 'left'
                    else ((a >> shift) | (b << (8-shift)))
                ) & 255 for a, b in zip(src, src[1:]))
                yield dict(reverse_bits=rev, shift=shift, direction=direction), data


def signature(data, kind):
    if kind == 'raw':
        return data
    if kind == 'xor':
        return bytes(a ^ b for a, b in zip(data, data[1:]))
    if kind == 'sub':
        return bytes((b-a) & 255 for a, b in zip(data, data[1:]))
    raise ValueError(kind)


def probe_disks(root, original, tail):
    result = dict(inputs=[], matches=[])
    lookup = {value: i for i, value in windows(tail, 16)}
    paths = []
    for folder, dirs, files in os.walk(root):
        dirs[:] = sorted(d for d in dirs
                         if d not in ('node_modules', 'target', 'build', '.git')
                         and (Path(folder)/d).resolve() != ROOT.resolve())
        paths.extend(Path(folder)/name for name in files)
    for path in sorted(paths):
        if (path.suffix.lower() not in ('.dsk', '.po', '.do')
                or path.stat().st_size != 143360
                or path.resolve().is_relative_to(ROOT.resolve())):
            continue
        data = path.read_bytes()
        name = path.relative_to(root).as_posix()
        result['inputs'].append(receipt(name, data))
        for kind, needle in (('template', bytes.fromhex('000a0022030100')),
                             ('play_boot_prefix', original[:32])):
            start = 0
            while (at := data.find(needle, start)) >= 0:
                result['matches'].append(dict(path=name, kind=kind, offset=at))
                start = at+1
        for view, ordered in (('file', data), ('dos_to_pascal', block_bytes(data, 0, 280))):
            for at, value in windows(ordered, 16):
                if value in lookup:
                    result['matches'].append(dict(path=name, kind='checksum-tail',
                        view=view, offset=at, target_offset=lookup[value]))
    return result


def probe_bitstreams(tail, rom_root):
    corpus = []
    for folder in ('build/disks/components', 'assets'):
        for path in sorted((ROOT/folder).rglob('*.bin')):
            corpus.append((path.relative_to(ROOT).as_posix(), path.read_bytes()))
    for path in sorted(rom_root.glob('apple2*.zip')):
        with zipfile.ZipFile(path) as archive:
            for name in sorted(archive.namelist()):
                if not name.endswith('/'):
                    corpus.append((path.name+':'+name, archive.read(name)))
    variants = list(bitstreams(tail))
    result = dict(inputs=[receipt(n, d) for n, d in corpus],
                  transforms=len(variants), minimum_original_bytes=16, matches=[])
    for kind in ('raw', 'xor', 'sub'):
        width = 16 if kind == 'raw' else 15
        lookup = {}
        for params, data in variants:
            for at, value in windows(signature(data, kind), width):
                lookup.setdefault(value, []).append((params, at))
        for name, data in corpus:
            for at, value in windows(signature(data, kind), width):
                for params, target_at in lookup.get(value, []):
                    result['matches'].append(dict(path=name, signature=kind,
                        offset=at, target_offset=target_at, **params))
    return result


def probe_footers(root):
    result = dict(inputs=[], valid_segment_occurrences=0, matches=[], main_suffixes=[])
    for path in sorted(root.iterdir()):
        if not path.is_file() or path.suffix == '.json':
            continue
        raw = path.read_bytes()
        result['inputs'].append(receipt(path.name, raw))
        if len(raw) < 64:
            continue
        for slot in range(16):
            start, size = word(raw, slot*4)*512, word(raw, slot*4+2)
            if not start or size < 4 or start+size > len(raw):
                continue
            data = raw[start:start+size]
            try:
                layout = procedure_dictionary(data, data[-2])
            except ValueError:
                continue
            if not layout['valid']:
                continue
            result['valid_segment_occurrences'] += 1
            for proc in layout['procedures']:
                if proc['representation'] != 'p-code':
                    continue
                at = proc['attribute_offset']
                suffix = data[at-5:at+2]
                record = dict(path=path.name, slot=slot, attribute_offset=at,
                              segment_offset=start, suffix=suffix.hex())
                if proc['number'] == 1 and proc['lexical_level'] == 0:
                    result['main_suffixes'].append(record)
                if suffix[:3] == bytes.fromhex('000a00') and suffix[-2:] == bytes.fromhex('0100'):
                    result['matches'].append(record)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--disk-root', type=Path)
    parser.add_argument('--rom-root', type=Path)
    parser.add_argument('--pascal-files', type=Path, help='raw extracted historical Pascal files')
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    if not any((args.disk_root, args.rom_root, args.pascal_files)):
        parser.error('choose at least one research corpus')
    original = (ROOT/'sundog-disk2-util.dsk').read_bytes()
    tail = block_bytes(original, 54, 55)[135:]
    report = dict(schema=1, target=receipt('disk2:block54:135..511', tail),
                  classification_effect='none; negative searches are not code/data evidence')
    if args.disk_root:
        report['disk_donors'] = probe_disks(args.disk_root, original, tail)
    if args.rom_root:
        report['bitstream_donors'] = probe_bitstreams(tail, args.rom_root)
    if args.pascal_files:
        report['pascal_footers'] = probe_footers(args.pascal_files)
    args.output.write_text(json.dumps(report, indent=2)+'\n')
    for key, value in report.items():
        if isinstance(value, dict) and 'matches' in value:
            print(f'{key}: {len(value["inputs"])} inputs, {len(value["matches"])} matches')


if __name__ == '__main__':
    main()
