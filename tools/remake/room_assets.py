"""Game18 procedures15–19 foot interiors, normalized to a 140×96 window."""
def room_layouts(raw, patterns):
    if len(raw) != 512 or any(len(p) != 12 for p in patterns):
        raise ValueError('Invalid room source')
    layouts = []
    for index in [1, *range(4, 16)]:
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
        fixtures = dict(seats=[], doors=[])
        if 4 <= index <= 7:
            floor = bounds[4]
            for group in range(3):
                left = floor['left'] + group*(floor['right']-floor['left'])//3
                right = floor['left'] + (group+1)*(floor['right']-floor['left'])//3
                fill(dict(left=left+10, right=right-10,
                          top=floor['bottom']-6, bottom=floor['bottom']), 9)
                fixtures['seats'].extend([
                    dict(action=4+2*group, x=left+3, y=floor['bottom']),
                    dict(action=5+2*group, x=right-7, y=floor['bottom'])])
                if group < 2:
                    # Pascal FJP tests the low bit; align an odd boundary up.
                    right += right & 1
                    fill(dict(left=right-1, right=right,
                              top=floor['bottom']-9, bottom=floor['bottom']), 10)
        elif index == 1:
            fixtures['bedrooms'] = dict(left=0, right=139, top=8, bottom=27)
            fixtures['approach'] = dict(left=0, right=139, top=28, bottom=40)
            for i in range(4):
                left = 21+28*i
                fill(dict(left=left, right=left+20, top=8, bottom=27), record[20] >> 4)
                fill(dict(left=left+7, right=left+14, top=8, bottom=36), record[20] >> 4)
                door = dict(left=left+8, right=left+13, top=30, bottom=31)
                fill(door, record[20] & 15)
                fixtures['doors'].append(door)
        layouts.append(dict(index=index, width=140, height=96, rows=rows,
                            spawn=dict(x=bounds[0]['right'], y=bounds[0]['bottom']),
                            exitX=12, bounds=bounds, fixtures=fixtures,
                            floorPattern=[p[record[20] >> 4] for p in patterns],
                            population=dict(bounds=bounds[1],
                                doorway=dict(x=bounds[0]['left'], y=bounds[0]['top']),
                                offset=dict(x=record[22]-128, y=record[23]-128),
                                maximum=max(3, record[24]), activityDivisor=record[25] or 128)))
    return layouts
