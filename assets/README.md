# Extracted assets

- [Title bitmap](title/title.hgr): complete 8 KB Apple II HGR page, including phase
  bits and non-display padding. [Monochrome preview](title/title-monochrome.png).
  [Manifest](title/manifest.json) records disk blocks, memory mapping, hash, and
  consumer. [Classification and reproduction](../docs/title-bitmap.md).

- [Shared font and symbols](font/font.bin): 128 seven-by-eight glyphs with
  preserved high bits. [Atlas](font/font.png), [row listing](font/rows.json),
  [manifest](font/manifest.json), and [consumer evidence](../docs/shared-font.md).

The normal disk build reads the raw HGR and glyph assets directly; Pillow is needed only
for preview generation. Other images, glyph banks, maps, sounds, and data still require
classification and extraction. Unidentified executable regions are not assets.
