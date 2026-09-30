# Interior fixtures and empty-population repair — R06m

The exporter now composes all thirteen foot-interior backgrounds selected by
Game18: lodging record1, tavern records4–7, and counter records8–15. Five new
external SVGs accompany room-walk data version4. The new fixture geometry is
available to the room controllers; tavern seating traffic and lodging rental
interaction still need integration before those buildings become live.

## Fixture evidence

Coordinates use the existing normalized140×96 room window and inclusive fill
bounds. No original-emulator capture is claimed.

| Source in `src/pcode/game_18.s` | Geometry |
| --- | --- |
| Procedure16 `$0BA8–$0BC5` | Type11 selects record1; the other foot interiors select `4*(type-7)+(tileX+tileY) mod4`. Records0/2/3 are not extra foot lodging variants. |
| Procedure18 `$0CD0–$0D50` | Divide floor width into three groups using integer division. Draw each table from `left+10` to `right-10`, floor bottom−6 through bottom, pattern9. Draw two dividers at the group boundary−1/boundary, bottom−9 through bottom, pattern10. Odd group boundaries are rounded up. |
| Procedure8 `$01AE–$0316` | Six seat targets have actions4–9: each group's left+3 and right−7, at floor bottom. Exported targets are `(16,86)`, `(43,86)`, `(53,86)`, `(80,86)`, `(90,86)`, `(118,86)`. Seat occupancy and selection remain runtime work. |
| Procedure19 `$0D5E–$0DFE` | Four bedrooms start at `x=21+28*i`, span21 pixels, and run y8–27. Their eight-pixel corridors start at bedroom left+7 and continue to y36. Initialize four closed doors. The bedroom interaction band is y8–27; the approach band is y28–40. |
| Procedure15 `$0AC2–$0B1F` | Each door is six pixels wide at `x=29+28*i`, y30–31. Closed uses the record's counter pattern; open uses its floor pattern. |

The odd-boundary test is confirmed by native `false_jump` at `$D2A0–$D2A6`
in `src/native/pcode_primitives.s`: it tests bit0, not numeric nonzero.

`roomDoorGeometry` derives a collision background from the static lodging
layout and four open flags. It preserves the original layout and applies the
same floor pattern that must be rendered when the lodging controller lands.
It does not authorize a room rental or persist door state on its own.

## Live entry repair

Game18 procedure14 `$0A43–$0A68` uses a fallback when every initial visitor
placement fails. The X arguments to library22 procedure40 are reversed:
`range(right,left)`. Y remains `range(top,bottom)`.

The native modulo implementation is now traced: `$D8AA–$D8BF` calls `$D7D9`;
a zero divisor branches from `$D7ED` to runtime error6 at `$D1DF`. For negative
divisors, `$D7F0–$D805` takes the absolute value before computing the remainder.
Consequently records8–11 trap (divisor0), and records12–15 can put staff beyond
the right edge of the counter bounds. This is a source bug, not an alternate
valid range convention.

The browser normalizes the fallback X endpoints to left/right and retains the
source's X-then-Y pair of RNG draws. It spawns only actor0 at that point plus
the record's staff offset. If the staff mask overlaps a wall at the sampled
edge, it uses the closest clear anchor inside the counter bounds (Manhattan
distance, X then Y tie order), with no further RNG draws. Ordinary successful populations are unchanged;
no replacement visitor or retry loop is introduced. Even the zero RNG fixed
point can now enter, receive service, save, leave and reenter.

Version8 retains its state shape. Previously valid saves regenerate unchanged
populations. Version6 migration still rejects a seed whose original population
failed, including when validation has cached a repaired population. Version7/8
already represent staff-only traffic states after visitors depart.

## Validation

- Eighteen exporter tests check source bounds, inclusive fixture fills, all
  thirteen SVGs, six seat targets and four door rectangles.
- Chrome rules check reachable seats, solid tables, independently opened
  bedrooms, geometry ownership, every possible fallback staff anchor and
  version6 migration rejection. All eight live layouts reach dialogue from
  seed0 as well as three existing reference seeds.
- The independent Python pixel reference retains64 population vectors and
  explicitly labels the repaired fallback cases; successful cases are unchanged.
- `room-fallback-validation.json` records19 live Chrome checks: normal UI
  entry into each counter class after all placements fail, walking, staff
  service, IndexedDB save/page reload, exact street return and reentry.
- `room-fixtures-regression.json` records102 existing room UI checks, including
  ordinary populated rooms, moving visitors, legacy imports, both languages
  and rejected saves, with the former fallback-failure expectation corrected.

R06 remains active. Next integrate tavern seating/interaction and lodging
door/rental return state with live controls, localization and versioned saves.
