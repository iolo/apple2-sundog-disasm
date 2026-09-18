# Extracted assets

- [Title bitmap](title/title.hgr): complete 8 KB Apple II HGR page, including phase
  bits and non-display padding. [Monochrome preview](title/title-monochrome.png).
  [Manifest](title/manifest.json) records disk blocks, memory mapping, hash, and
  consumer. [Classification and reproduction](../docs/title-bitmap.md).

The normal disk build reads the raw HGR asset directly; Pillow is needed only
for preview generation. Other images, fonts, maps, sounds, and data still require
classification and extraction. Unidentified executable regions are not assets.
