#!/usr/bin/env python3
"""Check the native block-54 byte-pair checksum table against a rebuilt play disk."""
import argparse
import json
from pathlib import Path

from disk_layout import ROOT, block_bytes, sha


def inspect(image):
    table = block_bytes(image, 54, 55)[:64]
    groups = []
    for block in range(0, 256, 8):
        raw = block_bytes(image, block, block + 8)
        computed = bytes((sum(raw[::2]) & 255, sum(raw[1::2]) & 255))
        stored = table[block // 4:block // 4 + 2]
        groups.append(dict(start_block=block, size=4096, stored=stored.hex(),
                           computed=computed.hex(), matches=stored == computed,
                           skipped_by_caller=block == 48))
    return dict(disk_sha256=sha(image), table_block=54, table_size=64,
                algorithm='Separate even/odd byte sums modulo 256',
                caller_evidence='docs/disk-checksum.md', groups=groups)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--image', type=Path, default=ROOT / 'build/disks/sundog-disk2-util.dsk')
    parser.add_argument('--report', type=Path)
    args = parser.parse_args()
    report = inspect(args.image.read_bytes())
    failed = [g['start_block'] for g in report['groups']
              if not g['skipped_by_caller'] and not g['matches']]
    if failed:
        raise SystemExit(f'Block checksum mismatch for groups {failed}')
    if args.report:
        args.report.write_text(json.dumps(report, indent=2) + '\n')
    print('31 checked block groups match; group 48 is explicitly skipped by the caller')


if __name__ == '__main__':
    main()
