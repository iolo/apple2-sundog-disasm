#!/usr/bin/env python3
"""Read native Pascal relocation lists using the shipped E3FD/E5C7 routines."""
from pascal_inventory import word


def native_relocations(data, procedure):
    if procedure['representation'] != 'native-6502':
        raise ValueError('Expected a native procedure')
    entry, attributes = procedure['entry_offset'], procedure['attribute_offset']
    cursor = attributes - 4
    groups, targets = [], set()
    for kind in ('global', 'segment', 'procedure', 'interpreter'):
        if cursor < entry:
            raise ValueError('Relocation count crosses native entry')
        count = word(data, cursor)
        group = dict(kind=kind, count_offset=cursor, count=count, pointers=[])
        if count > (cursor - entry) // 2:
            raise ValueError('Relocation count exceeds native body')
        cursor -= 2
        for _ in range(count):
            target = (cursor - word(data, cursor)) & 0xFFFF
            if target in targets:
                raise ValueError('Duplicate relocation target')
            targets.add(target)
            group['pointers'].append(dict(offset=cursor, target=target, original_word=word(data, target)))
            cursor -= 2
        groups.append(group)
    start = cursor + 2
    if any(not entry <= target < start - 1 for target in targets):
        raise ValueError('Relocation target is outside native code/data body')
    return dict(entry=entry, attributes=attributes, tables_start=start, groups=groups)
