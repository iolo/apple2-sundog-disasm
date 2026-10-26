# Interaction-window bitmap and position fields

`assets/interaction-window/` extracts a linear 140×96 bitmap from disk-2
blocks 37–40, plus two saved-position bytes in the same allocation. The
bitmap is 1,920 bytes: 96 consecutive rows of twenty bytes, with seven visible
pixels per byte. The monochrome preview was visually reviewed and shows the
framed container/panel shape. No specific gameplay meaning is assigned from
its appearance alone.

The source asset has the bitmap followed immediately by its two position bytes;
the adoption recipe maps those fields back to their noncontiguous disk locations.
All source phase bits are retained. `fields.json` provides reversible row bytes
and the `x_byte`/`y_row` fields.

| Offset in four-block allocation | Classification | Extracted offset |
| --- | --- | --- |
| 0–1919 | Bitmap rows | 0–1919 |
| 1920–1999 | Separately reconstructed zero storage | — |
| 2000 | Saved horizontal position, measured in HGR bytes | 1920 |
| 2001 | Saved vertical row | 1921 |
| 2002–2031 | Separately reconstructed zero storage | — |
| 2032–2047 | Retained Pascal identifier-record prefix | — |

The trailing allocation's `INFILE` record prefix and two bounded zero gaps are
now independently classified in [window-allocation-tail.md](window-allocation-tail.md).
This asset still contains exactly 1,922 bitmap/position bytes; the separate
source component reconstructs the other 126 bytes. All four blocks are classified.

## Load, draw, and restore evidence

Game 18 procedure 20 (`src/pcode/building_interiors.s`) handles a branch where its type
value equals 16. At `$0E18`–`$0E22`, it reads four blocks into `$1800` from
segment-29 word32+8. Play startup sets word 32 to 26, and library 22's block
wrapper adds three, giving disk blocks `26+8+3=37` through 40.

At `$0E25`–`$0E42`, game 18 derives and clamps the display position to byte
columns 1..19 and rows 8..88. `$0E45`–`$0E4F` installs that position and calls
library 22 procedure 15 with mode 1. That native routine is in
`src/pcode/graphics_and_io.s` at segment offset `$0E2E`:

- `$0E4E`–`$0E54` counts 96 rows. The loop visits source rows from the center
  outward (47, 48, 46, 49, ..., 0, 95).
- `$0E77`–`$0E81` obtains a source pointer from tables `$0D00` and `$0D60`.
  The [screen initializer](raw-screen-init.md) builds those tables for
  `$1800 + 20*row`, and the existing runtime capture verifies all 96 pointers.
- `$0E9F` sets the per-row count to twenty bytes. Mode 1 at `$0ED7`–`$0EE7`
  swaps those source bytes with the destination HGR row; mode 0 copies them
  at `$0ECC`–`$0ED4`. Thus drawing the on-disk bitmap also retains the previous
  background in the same buffer. The clamped display positions keep all 96
  rows within the HGR page.

Game 18 writes the chosen byte column to allocation offset 2000 at
`$0E52`–`$0E57`, and the row to offset 2001 at `$0E58`–`$0E5D`. These are
explicit position storage, not inferred image bytes. Library 22 procedure 51
also writes these fields at `$0AF1`–`$0B02`; procedure 52 reads them at
`$0B4E`–`$0B64` and restores the position through procedure 16 when returning
to a previous window. Their initial on-disk values are preserved as zero.

## Validation

```sh
python3 tools/test_window_asset.py
python3 tools/window_asset.py --verify assets/interaction-window
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

Maintenance extraction with `--extract` verifies the current rebuilt disk hash,
exclusive temporary ownership, and complete row/field round trips. Tests cover
row boundaries, phase-bit preservation, position-field separation, and malformed
extents/values. The original four-block allocation cannot be passed as if all
2,048 bytes were identified image data. Normal builds read only committed assets.
The complete rebuilt disks remain exact; no new live window interaction or
completion of final emulator validation is claimed here.
