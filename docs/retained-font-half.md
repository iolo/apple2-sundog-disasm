# Retained half-font in play-disk block 80

Disk 2 block 80 is a complete **64-glyph, 512-byte data bank**. It is a variant
of the first half of the independently classified [shared font](shared-font.md):
all stored high bits are clear, glyph slots 3–7 are blank, and every other glyph
has exactly the shared font's seven-bit row masks at the same index.

This identifies the data by a complete, indexed record relationship to a
consumer-backed glyph bank. It does not depend on its visual resemblance to
letters or on assuming that a nearby disk read includes this block. A direct
SunDog reader of this retained half-bank has not been established.

## Complete byte relationship

The shared bank is `assets/font/font.bin`, SHA-256
`eeadc8615ae25ac5611744c0f32589698d4d3cc4c57808a98df85268d08ca775`.
Library 22 procedure 9 establishes eight-byte glyph records: it multiplies
the index by eight at `$13E1`, reads rows 7 through 0 starting at `$141B`, and
masks each stored row with `$7F`. The shared-font audit records its loader and
matching live memory capture.

For each retained glyph index `i` from 0 to 63, and stored row `r` from 0 to 7:

```
donor_index = 32 if 3 <= i <= 7 else i
retained[8*i + r] = shared_font[8*donor_index + r] & $7F
```

Shared glyph 32 is the blank space. Thus the forty bytes in the five blank slots
also match a verified glyph record; no bytes are left outside the relationship.
The first three and final fifty-six glyphs preserve their indices. The resulting
512 bytes have SHA-256
`e26c063faef229917fc2e2374f3ef29661786b501cb75edb283bfe14254c0426`.
This establishes a glyph variant, without inferring which version was created
first or why those slots were blanked.

## Extracted representations

`assets/retained-font-half/glyphs.bin` preserves all stored bytes. `rows.json`
lists exactly 64 glyphs in display order; reversing each eight-row list
reconstructs the binary exactly. `manifest.json` records the donor index for
every glyph, the mask transformation, source hashes, disk range and consumer
provenance. No absent upper half of the font is invented.

The labeled `glyphs.png` atlas shows the 64 stored masks. It was visually
reviewed for symbols, blank slots, punctuation and digits. It is a mask preview,
without live placement, draw modes or artifact color. The converter now accepts
an explicit 64-glyph count while retaining 128 as its default; existing full-bank
extraction and previews keep their previous behavior.

## Verification

```sh
python3 -m unittest discover -s tools -p test_glyph_asset.py
python3 -m unittest discover -s tools -p test_retained_font_asset.py
python3 tools/retained_font_asset.py --verify assets/retained-font-half
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

Extraction checks the exact rebuilt disk, shared-font ownership/hash, renderer
hash, all 512 transformed donor bytes and reversible row order. Verification
regenerates the binary/listing/metadata and checks complete manifest ownership.
Tests reject changed pixels, high bits, blank slots, shapes and donor variants.
Normal builds use the extracted binary; neither original disks nor Pillow are
build dependencies. No new emulator run or live use of this variant is claimed.
