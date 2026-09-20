# Alternate-program graphics glyph bank

Disk 1 logical blocks 174–175 contain 128 eight-byte glyph records. The complete
1,024-byte bank is extracted under `assets/alternate-glyphs/`, with a lossless
display-order row listing and a labeled mask atlas. All stored row bytes have
their high bit set; the renderer ignores that bit, and the extraction retains it.

## Loader and consumer evidence

Alternate segment 7 assigns 171 to data-segment 29 word 32 at `$00C5`–`$00C8`.
It stores `$0800` in word 15 at `$0140`–`$0143`, then calls library 22 procedure
20 at `$014B` with bank index 0, selector 1 and that buffer address. Procedure 20
installs `$0800` as the glyph pointer at word 355 and initially reads the shared
bank-zero font into that buffer.

Immediately afterward, alternate 7 at `$014E`–`$0156` calls library 22 procedure
53 with buffer `$0800`, two blocks, relative block word 32, and read flag 1.
Procedure 53 adds 3 to the relative block and multiplies the count by 512 before
its unit read (`$0B8C`–`$0B98`). This replaces the selected glyph buffer with the
complete bank from absolute blocks 174–175. There is no pointer replacement
between the installation and this read.

The native glyph renderer, library 22 procedure 9, multiplies a glyph index by
eight at `$13E1` and reads row offsets 7 through 0 at `$141B`/`$141D`, masking
with `$7F`. The same documented consumer handles the [shared font](shared-font.md)
and [play graphics banks](play-glyphs.md). The loader, installed pointer and
eight-byte renderer stride establish all 128 records as graphics data. Their
visual resemblance to glyphs is supporting evidence, not the classification basis.

## Reproduction and checks

```sh
python3 tools/alternate_glyph_asset.py --extract build/alternate-glyphs-check
python3 tools/alternate_glyph_asset.py --verify assets/alternate-glyphs
python3 tools/test_glyph_asset.py
```

Extraction checks the rebuilt disk hash and reviewed assembled loader/renderer
component hashes. Reversing each record's display rows reconstructs every stored
byte exactly, including all high bits. The manifest records the loader offsets,
buffer, disk range, hashes and rendering format; adoption maps all four sectors
without incorporating adjacent content. Normal builds consume the extracted
binary bank and do not require original disks or Pillow.

The atlas was visually reviewed: it contains frame fragments, symbols, small
object shapes and several digits. Names and gameplay roles are not assigned to
individual glyphs. The preview shows stored masks without composed screens or
artifact colors. No new live emulator capture of this alternate bank is claimed.
