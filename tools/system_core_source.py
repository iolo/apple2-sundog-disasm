#!/usr/bin/env python3
"""Reconstruct the split system segment with capture-supported address mapping."""
import copy

from pascal_inventory import procedure_dictionary
from pcode_source import analyze, source

CORE_SIZE, FRAGMENT_SIZE = 3124, 170
CORE_BASE, FRAGMENT_BASE = 0xF248, 0xBC72


def analyze_system(core, fragment, *, extra_code_roots=()):
    if len(core) != CORE_SIZE or len(fragment) != FRAGMENT_SIZE:
        raise ValueError('System core/fragment sizes differ from captured layout')
    layout = procedure_dictionary(core, 0, load_address=CORE_BASE,
                                  fragments=[('fragment', FRAGMENT_BASE, fragment)])
    if not layout['valid']:
        raise ValueError('Invalid split-system procedure metadata')
    layout['trailer_offset'] = len(core) - 2
    for proc in layout['procedures']:
        if proc['storage'] != 'fragment':
            continue
        if proc['number'] != 38:
            raise ValueError('Unexpected split-system procedure')
        for field in ('entry_offset', 'attribute_offset', 'exit_offset', 'attribute_start'):
            proc[field] += len(core)
        proc['dictionary_address_delta'] = CORE_BASE - FRAGMENT_BASE + len(core)
    report = analyze(core + fragment, 0, layout=layout, extra_code_roots=extra_code_roots)
    report['physical_layout'] = dict(core_size=CORE_SIZE, fragment_size=FRAGMENT_SIZE,
                                   core_load_address=CORE_BASE, fragment_load_address=FRAGMENT_BASE,
                                   reconstructed_prefix_component='system_entry', prefix_size=36)
    return report


def remaining_source(report):
    """Keep procedure 1 owned by the previously reconstructed system_entry."""
    remainder = copy.deepcopy(report)
    remainder['items'] = [i for i in report['items'] if i['offset'] >= 36]
    remainder['size'] -= 36
    text = source(remainder)
    return ('; SYSTEM.PASCAL core plus separately loaded procedure 38.\n'
            '; File output excludes the first 36 bytes, owned by runtime_entry.s.\n'
            '; Link origin 36 keeps all core offsets unchanged.\n'
            '; Procedure-38 dictionary delta follows captured $F248/$BC72 loads.\n'
            'L_0022 = $0022 ; procedure-1 attributes, supplied by runtime_entry.s\n' + text)


def main():
    import argparse
    import json
    from pathlib import Path
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('core', type=Path)
    parser.add_argument('fragment', type=Path)
    parser.add_argument('--source', type=Path)
    parser.add_argument('--report', type=Path)
    args = parser.parse_args()
    # Reviewed dead join after an unconditional transfer; documented separately.
    report = analyze_system(args.core.read_bytes(), args.fragment.read_bytes(), extra_code_roots=[0x3BD])
    if args.source:
        args.source.write_text(remaining_source(report))
    if args.report:
        args.report.write_text(json.dumps(report, indent=2)+'\n')
    print({key: report[key] for key in ('size', 'procedure_count', 'instruction_count', 'coverage_bytes')})


if __name__ == '__main__':
    main()
