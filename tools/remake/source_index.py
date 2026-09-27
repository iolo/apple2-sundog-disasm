#!/usr/bin/env python3
"""Index explicitly classified strings, not speculative text in arbitrary bytes."""
import argparse
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / 'docs/remake/source-strings.json'


def collect():
    records = []
    for path in sorted((ROOT / 'src/pcode').glob('*')):
        if path.suffix not in ('.s', '.inc'):
            continue
        procedure = None
        offset = None
        for number, line in enumerate(path.read_text().splitlines(), 1):
            match = re.match(r'; Procedure (\d+),', line)
            if match:
                procedure = int(match[1])
            match = re.match(r'L_([0-9A-F]+):', line)
            if match:
                offset = match[1]
            if '; string-data' not in line:
                continue
            data = bytes(int(value, 16) for value in re.findall(r'\$([0-9A-F]{2})', line))
            records.append(dict(source=str(path.relative_to(ROOT)), line=number,
                                procedure=procedure, offset=offset,
                                text=data.decode('ascii'), hex=data.hex()))
    return records


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    records = collect()
    result = json.dumps(records, ensure_ascii=False, indent=2) + '\n'
    if args.check:
        if not OUTPUT.exists() or OUTPUT.read_text() != result:
            raise SystemExit('Source string index is stale; regenerate it.')
    else:
        OUTPUT.parent.mkdir(parents=True, exist_ok=True)
        OUTPUT.write_text(result)
    print(f'{len(records)} classified string records; {"verified" if args.check else "written"}')
