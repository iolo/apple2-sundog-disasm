# Starship registration certificate bitmap

`assets/certificate/certificate.hgr` is the 8,192-byte HGR image in disk-1
logical blocks 5–20. Its fixed artwork reads “STELLAR AUTHORITY / Certificate
of Starship Registration,” names Rithian Legal Associates, and includes the
SunDog ship designation, Merchant Cargo class, border, and seal. The recipient
line is blank in this source image; the caller adds variable text afterward.

The [reveal routine](certificate-reveal.md) establishes the code/data boundary
and both ways the image is loaded. The animated path loads it at `$4000` and
copies 192 rows of 40 bytes to `$2000`. The other path directly loads the image
to `$2000`. The byte following the image at `$6000` is native code and belongs
to a separate source component; it is not included in this extracted asset.

All 7,680 display bytes are addressed by the standard HGR row formula. The 512
non-display memory holes are uniformly `$80` and preserved as image-buffer
padding. Every phase bit is preserved as well. The existing row/hole splitter
and inverse encoder reproduce all 8,192 bytes exactly. Extraction rejects an
unexpected hole pattern instead of silently extending this classification.

The monochrome preview was visually inspected and shows the registration
certificate artwork. It does not simulate HGR artifact color, later text
overlays, or the reveal animation; no final-screen pixel equality is claimed.
The raw image is the normal build input and the complete disk comparison still
checks it in context.

```sh
python3 tools/hgr_asset.py --input assets/certificate/certificate.hgr \
  --preview build/certificate-monochrome.png
python3 tools/test_hgr_asset.py
```

For a fresh output directory, `--extract-certificate OUTPUT` reads the current
rebuilt disk, verifies its baseline hash, and writes the image, preview, manifest,
and adoption recipe. It refuses an existing directory. Normal builds use only
the committed image; extraction, Pillow, and the originals are not build inputs.
