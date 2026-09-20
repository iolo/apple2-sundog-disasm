# Classified Pascal segment-header tables

The first 288 bytes of each inventoried header are data: sixteen segment extent
pairs, sixteen eight-byte names, sixteen kinds, sixteen text-block pointers, and
sixteen packed segment-information words. `src/data/pascal_header_tables.s`
reconstructs these tables with explicit declarations and offset assertions.
Equal tables share one assembled copy, with separate disk mappings.

| Header-relative range | Data classification |
| --- | --- |
| `$000`–`$03F` | Sixteen little-endian relative-block / byte-length pairs |
| `$040`–`$0BF` | Sixteen fixed-width names, including stripped or unused names |
| `$0C0`–`$0DF` | Sixteen segment-kind words |
| `$0E0`–`$0FF` | Sixteen text-block pointers |
| `$100`–`$11F` | Sixteen packed segment / machine / version words |

The format is recorded in `tools/pascal_inventory.py`. Beyond structural
consistency, the shipped initializer supplies a concrete consumer: `$6B34`–`$6B7A`
walks sixteen four-byte extent records in the header buffer at `$6000`. It adds
the file's starting block to each relative block and copies the length into the
six-byte runtime segment records. `$6B11` reads a version byte at `$6103` and
`$6B15`–`$6B17` checks its version bits. The header read is captured in
`docs/reference/runtime-init.json`. The resulting segment extents independently
agree with the disassembled modules and recorded overlay loads.

These fields have the same layout at disk-1 blocks 84, 85, 103, 140, 157, and
251, and disk-2 blocks 103 and 140. Block 84 retains the name `UTILITY ` and
space-filled unused names; the other headers have stripped names. Block 84's
declared segment is **not** valid at its indicated location: its extent starts
at block 85, which itself contains a different header. This does not turn the
table into executable code. Its provenance and intended segment reference remain
open; no additional executable region is claimed from that reference.

The remaining 224 bytes of every header block are excluded from this table
component. The subsequent [header-extension audit](pascal-header-extensions.md)
uses Apple's format reference and local field boundaries to classify 1,652 of
those disk bytes separately. Six tails are complete; both block-103 copies
retain 70 unresolved bytes surrounding an independently identified counted
prompt. Merely being adjacent to a header is not used to classify those words.

`tools/prepare_header_tables.py` is a one-time maintenance generator that reads
the rebuilt disks, checks the inventory hashes and current ownership, generates
source, and assembles it for an exact comparison before writing review artifacts.
Normal builds use only the committed source and linker configuration. The
adoption recipe includes only the 288 reviewed bytes per header. The detailed
table/occurrence report is `docs/reference/header-tables.json`.
