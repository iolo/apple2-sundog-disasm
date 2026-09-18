# Early title bitmap asset

`assets/title/title.hgr` is the complete 8,192-byte HGR image buffer from disk-1
logical blocks 203–218. The bootstrap loads it at `$4400`–`$63FF`; the recorded
bootstrap capture confirms those bytes and addresses. The native title routine
in `src/native/title_draw.s` copies its display bytes to HGR page 1. See
[title-draw.md](title-draw.md) for the consumer and reveal sequence.

For screen row `y`, the page-relative byte offset is
`(y & 7)*1024 + ((y >> 3) & 7)*128 + (y >> 6)*40`. Columns 0–39 each contain
seven pixel bits plus a high phase bit. All 192 rows therefore account for
7,680 displayed bytes. The address generator and byte-column/row bounds establish
this region as image data; there are no code entry points or native control-flow
transfers into the buffer in the title routine.

The remaining 512 bytes occupy the HGR memory holes: eight bytes at the end of
each 128-byte group. They are preserved image-buffer padding, not discarded or
converted into guessed pixels. Of these, 504 are `$FF`; eight differ. Their
exact offsets and values are recorded in the asset manifest. Their original
values' purpose is unknown, but their location and exclusion from the image
consumer's row address set establish their role as non-display buffer data.
The complete buffer was captured together, so its raw format is the appropriate
lossless build input.

`tools/hgr_asset.py` separates the rows and holes and recombines them exactly,
retaining every high bit and padding byte. Tests independently check known Apple
II row addresses, partition coverage, and a round trip with varying byte values.
The optional PNG preview uses Pillow; Pillow is not required for the disk build.

```sh
python3 tools/hgr_asset.py --extract-title assets/title
python3 tools/hgr_asset.py --input assets/title/title.hgr \
  --preview build/title-monochrome.png
```

Extraction reads the current rebuilt disk and refuses an existing destination.
The committed asset is already extracted. Normal builds read only `title.hgr`;
they do not run extraction or read original disk images.

The preview shows the ship and planet artwork. It is a monochrome layout view,
not an artifact-color simulation: color phase and half-pixel shifts remain in
the original bytes. Visual review agrees with the underlying artwork in the
MAME title reference; that reference also contains subsequently drawn title text
and menu overlays. No claim is made that the uncomposited preview equals the
final menu screenshot.

The adoption recipe maps all 32 sectors as `identified-data`, separate from
`ca65-source` and `temporary-unresolved`. Its evidence and format are required
manifest fields. This does not classify any other unidentified remainder as an
asset. Remaining asset types and provisional native-runtime regions still need
investigation.
