# World-map tiles and seven terrain variants

`assets/world-tiles/` contains 21 tiles of 28×24 pixels: four bytes per row,
96 bytes per record, and 2,016 bytes total. The stream starts at disk-2 block
25 and has an identical copy at disk-1 block 184. Both copies are adopted;
the additional 32 bytes fetched by each four-block load are separately
classified as [retained rows from graphics bank 3](retained-tile-rows.md).

Game 21 procedure 3's non-city path at `$0070` selects image bank 4. Procedure
4 reads four blocks from `6+4*4` plus the library's block bias 3, hence absolute
block 25, into `$4000`. The draw call at `$02D6` supplies tile height 24 and
eight map rows to library 23 procedure 3. Native offsets `$00FF`–`$0133`
compute `tile_index*3*32 + $4000`; the row copier at `$014D`–`$0171` reads four
consecutive bytes and increments the source by four. Thus this path uses 96-byte
records, unlike the other banks' 128-byte records.

The packed-map decoder, library 23 procedure 2, produces indices 0–13 through
its 56-byte state-transition table. Game 21 then scans the 40×24 decoded map
at `$1167`–`$11A6`. At `$1185`–`$1199`, each cell with index 13 is replaced by
`14 + (generated_value mod 7)`, selecting indices 14 through 20. City positions
are later restored to index 13 at `$11E7`–`$11F9`. These consumers establish all
21 records, including the seven variants that are absent from the raw map's
state table. The precise appearance of a composed map also depends on the
runtime generator and subsequent overlays.

The atlas was visually reviewed as terrain-like patterns. It previews the low
seven pixel bits of each byte; raw data and row listings preserve the high HGR
phase bit. The disk-1 copy inherits classification through complete equality;
its separate demo load sequence is not newly traced. No runtime rendering of
this atlas is claimed.

```sh
python3 tools/test_tile_asset.py
python3 tools/tile_asset.py --extract-world build/world-tiles-check
```

Extraction validates the baseline images, shared-copy equality, and exact
24-row packing. It writes raw data, display-order rows, an atlas, manifest, and
adoption recipe. The extent test explicitly rejects appending the separate
32-byte tail as another world-tile record. The retained-row asset now owns that
tail separately. Normal builds use only the raw assets and retain every stored bit.
