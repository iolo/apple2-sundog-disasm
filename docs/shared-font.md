# Shared font and symbol bank

Both disks contain the same 1,024-byte glyph bank in logical blocks 3 and 4.
`assets/font/font.bin` preserves the original bank; `rows.json` lists each
glyph's eight bytes in display order, and `font.png` previews all 128 masks.
The bank contains text characters and symbols; the preview labels glyph indices
in hexadecimal without inventing semantic names for the non-text symbols.

## Classification from the loader and renderer

Library 22 procedure 20 (`$022C`) accepts a bank index, bank-selector flag, and
buffer address. It stores the buffer pointer in data-segment 29 word 355 or 356,
then calls procedure 53 for two blocks starting at relative block `2*index`.
Procedure 53 adds 3, so bank zero is disk blocks 3–4. Startup segment 7 at
`$01B8`–`$01C3` loads bank zero to `$1000` and sets the second pointer.

Native glyph renderer procedure 9 at `$1376` takes the glyph number. At `$13E1`
it multiplies the number by eight, then adds the selected bank pointer to form
the source address. Starting at `$141B`, it reads row offsets 7 down to 0,
masks each byte with `$7F`, and plots the result using the screen-row tables.
The seven low bits represent a horizontal mask, with bit zero on the left.
Thus 128 eight-byte records account for every byte of these two blocks. This
is consumer-backed glyph data, not a classification based on the file name or
on absence of observed execution.

The high bit is ignored by this consumer. Extraction and the display-order
listing nevertheless preserve it, so reversing each glyph's rows recovers the
complete original bank exactly. The preview is a mask atlas, not a screenshot:
the game applies placement, draw modes, and HGR color effects afterward.

## Reproduction

```sh
python3 tools/glyph_asset.py --input assets/font/font.bin --preview build/font.png
python3 tools/test_glyph_asset.py
```

For a fresh extraction directory, `--extract OUTPUT` reads both current rebuilt
disks, checks their baseline hashes and equality of the glyph copies, and writes
the raw bank, row listing, preview, manifest, and adoption recipe. It refuses to
overwrite an existing output directory. Normal disk builds read the committed
raw bank only; neither Pillow nor the original images are build dependencies.

Only bank zero is classified here. Other banks selected by the same routine
may contain tile graphics or different content and require separate inspection.

## Runtime and visual checks

`docs/reference/shared-font-runtime.json` captures the complete bank at `$1000`
in the original apple2ts reference session paused at the title prompt. All 1,024
bytes equal the extracted bank and both disk copies. The atlas was visually
reviewed: indices `$20`–`$7E` contain recognizable punctuation, digits, and upper/
lowercase letters alongside game symbols. The row-order/high-bit tests and
`tools/verify_runtime_evidence.py` verify the lossless listing and memory match.
