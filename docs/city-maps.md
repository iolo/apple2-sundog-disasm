# Packed city-map payloads

`assets/city-maps/` contains 60 play-side city payloads from disk-2 blocks
64–78 and four distinct demo payloads from disk-1 block 195. Each 128-byte
record contains an eight-byte prefix followed by a 120-byte map. Only the
payloads are classified and adopted here, replacing 7,680 disk bytes. The
512 prefix bytes are now separately classified in
[map-record-prefixes.md](map-record-prefixes.md); their values remain recorded
in this manifest to make the payload asset's exclusion explicit.

Each payload encodes a 20-column by 12-row grid of four-bit tile indices.
Columns are consecutive, with six bytes per column. Each byte stores the
upper row of its vertical pair in the low nibble and the next row in the high
nibble. In row/column notation the exact relationship is:

```text
tile[y][x] = (payload[6*x + y//2] >> (4*(y % 2))) & 15
```

`maps.bin` preserves all packed payloads in play-then-demo order; `tiles.json`
is a reversible representation as rows. `overview.png` displays these stored
indices using a fixed palette. It does not simulate tile-bank selection,
random variants, or visibility clipping, and assigns no semantic meanings to
the colors.

## Play-side consumer

`src/pcode/startup_and_save.s` sets segment-29 word 28 to `26+16+10+9=61` at
`$0142`–`$015B`, and starts the next allocation 15 blocks later at `$0163`.
Game 21 procedure 26 (`src/pcode/surface_maps.s`) reads a six-bit city identifier
from segment-29 word 37, starting at bit 9. At `$0EB8`–`$0ED2`, it computes:

```text
relative_block = word28 + (city_id - 1) // 4
record_index = (city_id - 1) % 4
```

The one-block read at `$0EF9`–`$0EFE` goes to `$1800`. Library 22 procedure 53
adds three to the relative block, giving physical logical blocks 64–78 for
the stored 60 records. `$0F3C`–`$0F41` selects the record using `IXA 64`:
64 words, or 128 bytes, per record.

The nested loops at `$0F4D`–`$0FC8` cover x=10..29 and y=6..17. The field
read at `$0F65`–`$0F74` advances four words past the record prefix, advances
three words for each x column, and uses `IXP 4,4` plus `LDP` for the y nibble.
The interpreter's `$DA1D` handler divides the index by four, advances the word
address by the quotient, and uses the remainder times four as the bit shift.
`load_packed_field` at `$DA60` loads a little-endian word, shifts it right, and
masks the low four bits. This establishes the column order and nibble order
independently of the visual appearance.

After decoding, `$0F84`–`$0F8F` can add a generated multiple of 16 to select
a tile variant. `$0F97`–`$0F9F` or the clipped path at `$0FB3`–`$0FBB` writes
the result into a 40-column map. The stored 20×12 payload covers the central
rectangle, not the full runtime map. The special city-60 path and clipping
do not change the packed record's field layout. This extraction does not claim
that every city has been visited live.

## Demo consumer

`src/pcode/retained_intro_display.s` sets word 28 to `171+18+2+1=192` at
`$00C5`–`$00E0`. Alternate 9 procedure 3 (`src/pcode/retained_world_tour.s`) reads one
block at `$0089`–`$0091` into `$1400`; with the same bias this is disk-1 block
195. Procedure 2 selects a 128-byte record at `$0013`–`$0017` and uses the
same x/y bounds and field access at `$003C`–`$004A`. Its runtime variant
selection is separate from the base nibbles. The four stored demo records
are not byte-identical copies of the play-side maps, so they are retained as
distinct assets. Block 196 is not included in this classification.

## Validation

```sh
python3 tools/test_city_map_asset.py
python3 tools/city_map_asset.py --verify assets/city-maps
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

The maintenance extractor's `--extract` option requires a new repository-local
output directory. It verifies both rebuilt disk hashes, checks that every
payload belongs wholly to a temporary region, and round-trips every nibble
before writing assets and an adoption recipe. Tests cover explicit column and
nibble ordering, inverse transforms, and invalid shape/value rejection. The
normal build reads only the committed packed asset, never original disks.
This checkpoint reuses existing exact-image emulator baselines; final live
validation in both emulators remains open.
