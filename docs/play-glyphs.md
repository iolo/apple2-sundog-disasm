# Play-side graphics glyph banks

`assets/play-glyphs/bank1/` and `bank2/` preserve the two additional 1,024-byte
banks from disk-2 blocks 5–6 and 7–8 respectively. Each includes raw bytes, a
128-glyph mask atlas, a display-order row listing, a manifest, and its adoption
recipe. These are separate assets from the shared bank-zero text font.

## Loader and renderer evidence

Library 22 procedure 20 loads two blocks from absolute `3 + 2*bank` and installs
the buffer address as a glyph-bank pointer (data-segment 29 word 355 or 356).
Its native renderer, procedure 9, multiplies the glyph index by eight at `$13E1`
and reads row offsets 7 down to 0 at `$141B/$141D`, masking with `$7F`. The same
layout underlies the [shared font](shared-font.md). Seven low bits form the row
mask, with bit zero at the left; extraction retains the ignored high bit.

Startup 7 loads bank 1 to the `$0800` buffer through the call at `$0352`.
Game 13 reloads bank 1 to `$0800` at `$272E`, replacing the raw viewscreen I/O
overlay when returning to the glyph bank. This explains why sharing a memory
address does not make the on-disk bank executable code.

Startup 7 loads bank 2 to `$1000` at `$035A`. Its loop at `$0362`–`$0388` copies
120 bytes from each 128-byte group to the corresponding group at `$0400`, using
library 26 procedure 4's byte-copy wrapper. Game 12 at `$04E1` passes `$0400`
and selector 1 to library 22 procedure 21, installing that copied glyph bank
for the renderer. This establishes the copied bytes as graphics, not merely
an arbitrary buffer that happens to look like pictures.

The eight omitted records are glyph indices `$0F,$1F,...,$7F`, each eight stored
bytes. Their values alternate between all `$00` and all `$80` by group, so each
is blank under the renderer's `$7F` mask. These align with the eight-byte gaps between the 120-byte copy
ranges. All remain explicit blank records in the extracted source bank and
are checked by the extractor. The atlas previews stored records; runtime
contents of the skipped destination gaps are not claimed to match those records.

## Validation and previews

Bank 1's atlas shows multi-tile shapes, frames, and symbols; bank 2 includes
reticle-like masks, digits, frames, and small object shapes. Glyph indices are
retained as labels rather than assigning unverified gameplay names. The previews
show masks, not composed screens or Apple II artifact colors. Both atlases were
visually reviewed.

The existing glyph conversion reverses each record's row order without losing
any bit, and packing the row listings reproduces both complete banks exactly.
Run `python3 tools/test_glyph_asset.py` for the row-order/high-bit checks. Fresh
extraction from rebuilt disks uses:

```sh
python3 tools/play_glyph_assets.py --extract build/play-glyphs-check
```

The extractor verifies the baseline image hash and refuses to overwrite its
output directory. Normal builds consume only the committed raw glyph banks;
Pillow is needed for preview generation, not for building disks. Adoption and
full-disk comparison verify all 2,048 bytes. No fresh live-memory capture of
these two banks is claimed; the earlier capture covers bank zero only.
