# Four banks of 32-row map tiles

`assets/tiles/bank0/` through `bank3/` each contain sixteen 28×32-pixel tiles,
encoded as four bytes per row and 128 bytes per tile. Four complete banks
account for disk-2 blocks 9–24. Banks 0 and 1 also occur byte-for-byte at disk-1
blocks 176–179 and 180–183, so the extracted assets replace 12,288 disk bytes.
The bank numbers here are the map-image loader's indices, not glyph-bank indices.

## Load and rendering evidence

Game 21 procedure 4 at `$002B`–`$0033` reads four blocks to a supplied buffer,
starting at relative block `6 + 4*index`. Library 22 procedure 53 adds 3,
yielding absolute `9 + 4*index`. Procedure 3 calls this loader for the `$4000`
and `$4800` buffers at `$0056`–`$006C`. The indices are assigned modulo four
at `$0FD1`–`$0FEC`, establishing banks 0 through 3 and two adjacent 2 KB buffers.

Game 21 procedure 9 calls library 23 procedure 3 at `$02C4`, passing a tile
height of 32 and six tile rows. That native renderer reads each map cell and
masks its tile index with `$1F` at segment offsets `$00EC/$00EE`. The 32-row
path at `$0123`–`$0133` multiplies the index by 128 and adds `$4000`, selecting
one of 32 tiles across the two loaded banks. For each screen row, `$014D`–`$0171`
reads four consecutive source bytes, copies them into HGR screen memory, and
advances the source by four. Its bounded row loop accounts for all 32 rows.

This gives a complete layout for every byte in each 2 KB bank: sixteen records,
32 rows, four bytes. The high bit is copied to the screen and may affect HGR
phase/color; it is retained in the raw data and reversible row listing. The
monochrome previews show the seven low pixel bits, bit zero at the left.

The identical disk-1 copies inherit classification through whole-bank equality
to the confirmed play-side assets. Their demo-specific load path has not been
separately traced. These findings do not classify neighboring graphics or maps.

## Scope and reproduction

Atlases were visually reviewed: they contain terrain dots and building-like
walls, frames, and connected shapes. Labels retain numeric indices rather than
inventing gameplay names. Each bank includes its raw bytes, a row listing,
atlas, provenance/hash manifest, and adoption recipe.

```sh
python3 tools/test_tile_asset.py
python3 tools/tile_asset.py --extract build/tiles-check
```

The extractor validates both rebuilt input hashes and all shared copies before
writing, then checks the inverse row encoder against every source byte. Tests
check record/row boundaries, all eight bits, and malformed input rejection.
Normal builds consume only committed `tiles.bin` files; originals and Pillow
are not build dependencies. Complete disk comparisons remain exact.

The fifth bank at disk-2 blocks 25–28 uses the renderer's other, 24-row path.
Its complete format and tail boundaries remain separate work and are not
silently interpreted as another sixteen-tile 32-row bank. No new emulator
trace or rendered-map comparison is claimed for these extracted atlases.
