# Disk layout: initial verified map

## Reproduce the inventory and container round trip

```sh
python3 tools/disk_layout.py unpack build/disk-layout
python3 tools/disk_layout.py pack build/disk-layout build/repacked
cmp sundog-disk1-game.dsk build/repacked/sundog-disk1-game.dsk
cmp sundog-disk2-util.dsk build/repacked/sundog-disk2-util.dsk
python3 tools/test_disk_layout.py
```

Output directories must not already exist; use new paths for a second run. The
unpacker writes 70 track files and a machine-readable `manifest.json` with all
1,120 sectors (286,720 bytes), hashes, image offsets, physical sectors, logical
blocks, initial classifications, and directory-view references. It also extracts
all candidate directory records and their named file extents. The committed
`disk-layout-summary.json` records directory locations and file hashes; the full
sector map is reproducible under `build/`.

Repacking reads only the extracted track files. It requires complete coverage
without overlap and validates track and whole-image hashes. This preserves every
byte, including uninterpreted code, data, and unused-looking bytes. It is a
**container round trip**, not the PRD's final build from disassembled source.
No executable coverage claim is implied by successful byte comparison.

## Sector and block ordering

Both inputs are 35-track, 16-sector, 256-byte-per-sector DOS-ordered images as
interpreted by the working emulator boots. The boot continuation supplies a
stronger anchor: disk 1 image offsets `$0000`, `$0E00`, `$0D00` load at `$0800`,
`$0900`, `$0A00`. Its reader's table at `$093E` enumerates physical sectors
`0,2,4,6,8,10,12,14,1,3,5,7,9,11,13,15` for Pascal-order reads.

For logical sector `s`, let `t = s // 16` and `i = s % 16`:

```text
DOS image indices in logical order = [0,14,13,12,11,10,9,8,7,6,5,4,3,2,1,15]
image offset = t * 4096 + DOS_image_indices[i] * 256
logical block = s // 2
half within block = s % 2
```

Physical sector IDs are distinct from positions in the image. The conversion
agrees with a2kit 4.4.2's `src/bios/skew.rs`, `src/bios/blocks/apple.rs`, and
`src/img/dsk_do.rs` in the installed source. Upstream:
[a2kit](https://github.com/dfgordon/a2kit).

## Nonstandard Pascal directory views

Disk 1 contains four well-formed one-block Pascal directory records:

| Logical block | Image offsets of the two halves | Interpretation so far |
| --- | --- | --- |
| 79 | `$9100`, `$9F00` | Mutable directory; modified on entry to utilities |
| 80 | `$A000`, `$AE00` | Startup points to utility code at blocks 85–102 |
| 81 | `$AD00`, `$AC00` | Initially identical to block 79; startup points to 140–218 |
| 82 | `$AB00`, `$AA00` | Demo directory; startup points to blocks 157–173 |

All use volume name `SUNDOG`, total blocks 280, and directory end block 3.
Records are 26 bytes, with little-endian block bounds and sizes, matching
a2kit's `src/fs/pascal/directory.rs`. File endpoints are exclusive. Blocks 79,
80, and 81 describe six files; block 82 describes seven. Actual runtime
selection and remapping of directory reads still require tracing in step 04.

The block-79 view describes these extents:

| Blocks, end exclusive | Name | Directory type |
| --- | --- | --- |
| 3–85 | SYSTEM.DATA | 5 (data) |
| 85–103 | SUNDOG.LIBRARY | 2 (code) |
| 103–140 | SYSTEM.LIBRARY | 5 (data) |
| 140–219 | SYSTEM.STARTUP | 2 (code) |
| 219–251 | SYSTEM.APPLE | 5 (data) |
| 251–280 | SYSTEM.PASCAL | 2 (code) |

Directory types are not reliable code/data classifiers here: `SYSTEM.APPLE`
contains native instructions, and different views change names/types for the
same extents. Preserve all views and do not double-count their overlapping bytes.
Disk 2 has no matching directory header; its file boundaries remain to be
established from actual consumers. The map keeps those sectors unresolved.

For independent validation, a disposable DOS-order image was made by copying
block 79 to conventional directory block 2. `a2kit catalog` recognized the
volume, and `a2kit get ... -f SYSTEM.STARTUP -t raw` matched our direct extraction
of blocks 140–218 exactly (40,448 bytes). a2kit's catalog listed five of the six
entries and failed to extract SYSTEM.PASCAL; our parser retains the sixth entry
with bounds 251–280. The original images were not patched. A `.po` version of
the same experiment was not recognized because this a2kit version's Pascal
detector excludes the PO container type.

## Utility-entry writes

The clean reference utility sequence changes 30 bytes, recorded exactly in
`reference/utility-entry-writes.json`. Twenty-six changes are in disk 1 image
sector `$9100` (logical block 79): the two directory entries at blocks 85 and
140 exchange startup/library names and type/date fields, consistent with the
utility directory view. Four more bytes change at `$A902`–`$A905` (logical block
83); the later [disk control audit](disk-control.md) identifies them as a
four-byte persisted-globals field. These observations explain the changed
working-copy hash without assuming that saved characters were modified.

No source rebuild, complete asset classification, allocation interpretation for
disk 2, or p-code dialect identification is claimed at this stage.
