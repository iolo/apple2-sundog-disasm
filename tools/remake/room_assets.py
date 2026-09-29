"""Game18 procedures16/17 room backgrounds, normalized to a 140×96 window.

Only types9/10 (records8–15) are complete static layouts. Types8/11 add
fixtures and are deliberately excluded. Population parameters retain source order.
"""
def room_layouts(raw, patterns):
    if len(raw) != 512 or any(len(p) != 12 for p in patterns):
        raise ValueError('Invalid room source')
    layouts = []
    for index in range(8, 16):
        record = raw[index*32:(index+1)*32]
        # Library22 bounds order is bottom, top, right, left.
        bounds = [dict(zip(['bottom', 'top', 'right', 'left'], record[i:i+4]))
                  for i in range(0, 20, 4)]
        rows = [[127]*20 for _ in range(96)]

        def fill(rect, style):
            for y in range(rect['top'], rect['bottom']+1):
                for x in range(rect['left'], rect['right']+1):
                    byte, bit = x//7, 1 << (x % 7)
                    rows[y][byte] = ((rows[y][byte] & ~bit) |
                                    (patterns[byte % 2][style] & bit))

        # Library22 proc51 window bounds, then game18 proc16 in source order.
        fill(dict(left=2, right=137, top=2, bottom=93), record[21])
        fill(bounds[4], record[20] >> 4)
        fill(bounds[3], record[20] >> 4)
        fill(bounds[2], record[20] & 15)
        layouts.append(dict(index=index, width=140, height=96, rows=rows,
                            spawn=dict(x=bounds[0]['right'], y=bounds[0]['bottom']),
                            exitX=12, bounds=bounds,
                            population=dict(bounds=bounds[1],
                                doorway=dict(x=bounds[0]['left'], y=bounds[0]['top']),
                                offset=dict(x=record[22]-128, y=record[23]-128),
                                maximum=max(3, record[24]), activityDivisor=record[25] or 128)))
    return layouts
