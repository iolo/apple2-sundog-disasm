# Retained tile rows after the world graphics

The 32 bytes at disk-1 block 187 offsets 480–511 and disk-2 block 28 offsets
480–511 are identical copies of graphics bank 3 offsets 2016–2047. That
independently classified asset uses sixteen 128-byte tile records, so the
copied range is precisely **tile 15, rows 24–31**, four bytes per row.
All 64 disk bytes are image data, including their high HGR phase bits.

The source donor is `assets/tiles/bank3/tiles.bin`, SHA-256
`6e5d341c0f8e1ad5234b067e848c1755fd59ea0ac8e05df9a226de0c51f8d3ef`.
Its four-block loader and 32-row renderer are traced in
[tile-banks.md](tile-banks.md). The two retained copies match every byte of the
eight complete donor rows, without masking, shifting, filling or changing them.
Bank 1 has a similar final fragment but differs in its first two bytes; it is
not the exact donor used for this classification.

The enclosing four-block world-image loads fetch these bytes after the 2,016
bytes consumed as 21 world tiles. They are retained **32-row tile fragments**,
not an extra 24-row world tile. No direct rendering of the copies, historical
write sequence or new runtime observation is asserted.

`assets/retained-tile-rows/` stores the exact 32 bytes and a reversible eight-row
listing. Its manifest maps both copies and gives their donor record coordinates.
The existing [bank-3 atlas](../assets/tiles/bank3/atlas.png) provides visual
context: tile `0F`, bottom eight rows. No missing rows are invented for this
partial tile. The fragment hash is
`8c11793b90a788cecdb01e0ed01cd5d361bda07b2e8efa02172950aedd660fc7`.

```sh
python3 tools/test_retained_tile_asset.py
python3 tools/retained_tile_asset.py --verify assets/retained-tile-rows
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

Extraction checks both current disk hashes, the independently classified donor
and every row byte before writing artifacts. Adoption checks prior temporary
ownership. Verification regenerates the records/manifests and checks their
final ownership. Tests reject altered pixel bits, phase bits, lengths and the
similar but nonidentical bank-1 donor. Normal builds read only the committed
fragment and retain exact disk output.
