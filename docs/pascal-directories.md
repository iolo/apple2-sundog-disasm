# Pascal directory data

`src/data/pascal_directories.s` reconstructs all 2,048 bytes of disk-1 blocks
79–82 as typed directory data. Blocks 79 and 81 initially match, so three
512-byte source tables supply four disk blocks. The mappings and field audit
are in `src/data/pascal_directories.adopt.json` and
`docs/reference/directory-tables.json`.

Each block begins with a 26-byte volume record followed by 26-byte file records.
The field layout agrees with the locally installed a2kit 4.4.2
`src/fs/pascal/directory.rs` (`VolDirHeader` and `DirectoryEntry`), previously
validated by the catalog/extraction experiment in [disk-layout.md](disk-layout.md).
The source preserves the full fixed-width name fields, including bytes beyond
the name length, raw dates, reserved bytes, and inactive records.

| Block | Active records | Startup extent (end exclusive) | Spare storage |
| --- | --- | --- | --- |
| 79 | 6 | 140–219 | 330 zero bytes after offset 182 |
| 80 | 6 | 85–103 | 330 zero bytes after offset 182 |
| 81 | 6 | 140–219 | Identical to block 79 |
| 82 | 7 | 157–174 | Three inactive records at offsets 208–285; 226 zero bytes from 286 |

The three inactive records in block 82 each duplicate its final active
`SYSTEM.PASCAL` record, except their name-length byte is zero. Their block
bounds (251–280), type, fixed-width name storage, final-block byte count, and
date all match. They are directory residue, not additional active files; the
volume's active-file count remains seven. The subsequent all-zero storage is
unused directory-record capacity and the remainder of the directory block.
This classification uses the surrounding record structure and the matched
directory buffers, rather than zero contents alone. It does not generalize to
zero or nonzero tails of executable files elsewhere on the disks.

## Consumers and independent evidence

- `src/native/native_init.s` at `$69EB` requests block `$4F` (79). The existing
  apple2ts capture in `docs/reference/runtime-init.json` verifies the complete
  512-byte buffer at `$6000` before its use. The initializer reads header byte
  25 at `$6A02`, steps through records by `$1A` at `$6A43`, compares counted names
  at `$6A97`–`$6AA2`, and reads the matched file's first-block word at
  `$6AAF`–`$6AB8`. Thus even the reserved header byte is preserved explicitly.
- `src/pcode/library_26_body.inc`, procedure 6, chooses relative directory block
  77 or 78 at `$032D`/`$0335`. At `$06A4`–`$06AA` it reads one block into `$1400`
  and at `$06AD`–`$06B3` writes that buffer to the selected destination.
  Library 22 procedure 53 adds three to block numbers and multiplies the count
  by 512, so those source blocks are 80 and 81, not 77 and 78.
- Applying the 30 recorded changes in `docs/reference/utility-entry-writes.json`
  to the clean rebuilt image makes the entire block-79 directory identical to
  block 80. Twenty-six changes select the utility directory; four changes are
  outside these directories in block 83, in the four-byte persisted-globals
  field of the [disk control record](disk-control.md).
- Block 82 has the same validated directory structure and coherent demo file
  extents. Its classification is structural evidence; this checkpoint does not
  claim a new live trace selecting that view.

Directory file-type values describe the filesystem view, not the executable
classification of the referenced files. For example `SYSTEM.APPLE` is marked
as data here but contains the reconstructed native runtime.

## Reproduction and limits

`tools/prepare_directory_tables.py` is a maintenance generator. It checks the
current rebuilt image hash, parses the active directory extents, rejects
unreviewed nonzero spare records, checks exclusive temporary ownership, and
assembles the generated declarations for an exact comparison before emitting
artifacts. It refuses to overwrite existing artifacts. Normal builds read only
the committed ca65 source and linker configuration, with no original-image input.

The full disk comparison after adoption must remain exact. Existing recorded
boot and utility observations therefore remain applicable; no new emulator run
or completion of final behavioral validation is claimed by this checkpoint.
