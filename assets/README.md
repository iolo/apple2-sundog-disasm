# Extracted assets

- [Title bitmap](title/title.hgr): complete 8 KB Apple II HGR page, including phase
  bits and non-display padding. [Monochrome preview](title/title-monochrome.png).
  [Manifest](title/manifest.json) records disk blocks, memory mapping, hash, and
  consumer. [Classification and reproduction](../docs/title-bitmap.md).

- [Shared font and symbols](font/font.bin): 128 seven-by-eight glyphs with
  preserved high bits. [Atlas](font/font.png), [row listing](font/rows.json),
  [manifest](font/manifest.json), and [consumer evidence](../docs/shared-font.md).

- [Registration certificate](certificate/certificate.hgr): 8 KB HGR artwork
  with [preview](certificate/certificate-monochrome.png),
  [manifest](certificate/manifest.json), and
  [consumer evidence](../docs/certificate-bitmap.md).

- [Play graphics banks](play-glyphs/): two 128-glyph banks, with separate
  [bank 1 atlas](play-glyphs/bank1/glyphs.png) and
  [bank 2 atlas](play-glyphs/bank2/glyphs.png), raw data, row listings, and manifests.
  [Consumer and copy evidence](../docs/play-glyphs.md).

The normal disk build reads the raw HGR and glyph assets directly; Pillow is needed only
for preview generation. Other images, glyph banks, maps, sounds, and data still require
classification and extraction. Unidentified executable regions are not assets.
