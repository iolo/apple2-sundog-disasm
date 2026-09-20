# Altered retained title-image data

The remaining **252 bytes** in disk-1 block 83 are classified as altered HGR
image data by their sparse relationship to the independently identified title.
Together with the [earlier 252-byte fragments](retained-title-fragments.md),
they complete the image correspondence at block offsets 8–511. The initial
eight bytes remain the separately classified disk-control record.

The new ranges are `[88,90)`, `[165,256)` and `[353,512)`. Every byte corresponds
to title offset `4096 + block offset`, including interleaved scanlines and HGR
memory holes. The new asset preserves 228 visible pixel/phase bytes and 24 hole
bytes. No title byte is substituted for an altered stored byte.

## Positive format evidence

The earlier fragments already established the same spatial correspondence for
252 bytes, including an exact HGR hole and 244 identical seven-bit pixel values.
The remaining changes form long constant-XOR runs, mostly in bits 2–6, rather
than independently varying replacement content. Apple's differential 6-and-2
sector representation explains how very few symbol differences can produce
exactly these long runs: each six-bit value is XORed with the preceding value.

The audit separately preserves the HGR phase bit and compares the seven pixel
bits. It packs the low two bits in the standard 86-value arrangement, appends
256 upper-bit values and applies differential XOR with a zero seed and final
checksum. The one-to-one GCR translation of six-bit values to disk bytes is
unnecessary for counting differences; the reported indexes are **pre-translation
symbols**, not byte offsets in an archived nibble image.

Only **eight of 343 symbols differ in each sector**: 670 of 686 symbols match.
The 16 frozen XOR changes reproduce every low-seven-bit value across both
sectors, including all previously unexplained pixels and holes. The final
checksum symbols are included in that count. Before the comparison, the
separately owned eight-byte control record is excluded by restoring the donor
values in a comparison buffer only. It is never adopted as image data or changed
on disk. Phase bits remain explicit fields in the extracted representation.

| Sector | Changed pre-translation symbol indexes |
| --- | --- |
| 0 | 3, 4, 174, 175, 251, 301, 307, 342 |
| 1 | 45, 46, 47, 48, 183, 305, 306, 342 |

The symbol packing was checked against the locally installed a2kit 4.4.2
`src/img/tracks/gcr/woz_nibbles.rs`, `encode_sector_62_256`: reversed low-bit
packing order, two-bit reversal within each pair, upper six bits, differential
XOR and final checksum. The audit includes an inverse and checks complete
256-byte sectors with all eight bits, separately from phase-normalized analysis.

This sparse encoded relationship, continuous spatial alignment, independently
classified surrounding fragments and HGR structure support **retained altered
image data**. Arbitrary code bytes are not classified by merely being drawable.
The comparison does not prove historical disk corruption, identify which image
was copied first, recover the writer, or assert that SunDog displays this copy.
It also does not claim that only 16 physical nibble bytes changed: phase was
separated and the control record excluded. The cause of alterations is open;
the code/data classification is now supported without that historical claim.

## Artifacts and verification

`assets/retained-title-changes/` contains the exact stored fragment bytes,
per-byte coordinates or hole markers, pixel and phase fields, provenance,
frozen symbol edits and an adoption recipe. Normal builds read the exact
252-byte asset; neither the title donor nor a hypothetical disk repair is a
build-time replacement for these bytes.

```sh
python3 tools/test_retained_title_changes.py
python3 tools/retained_title_changes.py --verify assets/retained-title-changes
python3 tools/retained_title_asset.py --verify assets/retained-title
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

Tests exercise full-byte sector round trips and checksum rejection, every
new byte's pixel-model constraint, exclusion of the control record, and separate
phase preservation. Verification also checks the original title hash, earlier
fragment classification and ownership, exact stored asset bytes and new disk
ownership. Both original disk images remain unchanged.
