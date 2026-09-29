#!/usr/bin/env python3
"""Independent pixel-grid transcription of Game18 initial population (not a capture)."""
import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TARGET = ROOT/'remake/tests/fixtures/room-population.json'


def reference(index, seed):
    raw = (ROOT/'assets/interaction-records/records.bin').read_bytes()[index*32:(index+1)*32]
    native = (ROOT/'src/pcode/library_22.s').read_text()
    patterns = [[int(v.strip().removeprefix('$'), 16) & 127 for v in
                 re.search(label+r':\s+\.byte ([^;]+)', native)[1].split(',')]
                for label in ['L_164A', 'L_163E']]
    pixels = [[1]*140 for _ in range(96)]
    def fill(rect, style):
        bottom, top, right, left = rect
        for y in range(top, bottom+1):
            for x in range(left, right+1):
                pixels[y][x] = (patterns[x//7 % 2][style] >> (x % 7)) & 1
    fill([93, 2, 137, 2], raw[21])
    for offset, style in [(16, raw[20] >> 4), (12, raw[20] >> 4), (8, raw[20] & 15)]:
        fill(raw[offset:offset+4], style)
    state = seed
    draws = 0
    def random():
        nonlocal state, draws
        for _ in range(7):
            feedback = ((state >> 6) ^ (state >> 30)) & 1
            state = ((state * 2) + feedback) % 2**32
        draws += 1
        return ((state & 255) // 2) * 256 + ((state >> 16) & 255)
    def draw(x, y, glyph):
        for row, mask in enumerate(glyph):
            for bit in range(7):
                if (mask >> bit) & 1:
                    pixels[y-7+row][x+bit] ^= 1
    def clear(x, y):
        return 0 <= x <= 133 and 7 <= y < 96 and not any(
            pixels[yy][xx] for yy in range(y-7, y+1) for xx in range(x, x+7))
    draw(raw[2], raw[0], [0, 0, 12, 30, 30, 12, 0, 0])
    bottom, top, right, left = raw[4:8]
    dx, dy = 5*int(right-left >= 4), 3*int(bottom-top >= 4)
    count = 3 + random() % (max(3, raw[24])-2)
    slot, actors, attempts_log = 2, [], []
    while slot <= count:
        flag, value = int(random() % 8 == 0), random() % 5
        for attempt in range(1, 11):
            x, y = left + random() % (right-left+1), top + random() % (bottom-top+1)
            free = clear(x-dx, y-dy) and clear(x+dx, y+dy)
            if free:
                break
        attempts_log.append(dict(slot=slot, attempts=attempt, clear=free))
        if attempt == 10:
            count -= 1
            continue
        actors.append(dict(slot=slot, words=[y, x, y, x, y, x, 5912, 792+flag, value, 2+random() % 250]))
        draw(x, y, [0, 0, 12, 18, 18, 12, 0, 0])
        slot += 1
    result = dict(index=index, seed=seed, draws=draws, attempts=attempts_log)
    if not actors:
        return dict(**result, error='roomPopulationUnavailable')
    x, y = actors[0]['words'][5]+raw[22]-128, actors[0]['words'][4]+raw[23]-128
    actors.append(dict(slot=0, words=[y, x, y, x, y, x, 5891, 0, 3, 0]))
    return dict(**result, randomState=state, actors=actors)


def fixtures():
    # Includes clear tenth-candidate rejection, trim/retry, all-failed and
    # unsigned high states; the fixture logs preserve independent draw counts.
    return [reference(index, seed) for index in range(8, 16)
            for seed in [0, 1, 2, 17, 128, 12345, 0x80000000, 0xffffffff]]


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    value = fixtures()
    if args.write:
        TARGET.write_text('[\n'+',\n'.join('  '+json.dumps(v) for v in value)+'\n]\n')
    elif json.loads(TARGET.read_text()) != value:
        raise SystemExit('Stale room population reference')
    print(f'{len(value)} room population vectors {"written" if args.write else "verified"}')
