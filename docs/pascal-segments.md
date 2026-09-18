# Pascal segment and procedure inventory

`pascal-inventory.json` records the version-5 header candidates found by scanning
every logical block of both supplied disks. Regenerate and validate it with:

```sh
python3 tools/pascal_inventory.py build/pascal-inventory.json
cmp build/pascal-inventory.json docs/pascal-inventory.json
python3 tools/test_pascal_inventory.py
```

This is a structural inventory, **not a completed disassembly or a complete code
coverage claim**. In particular, standalone loaders and SYSTEM.APPLE are outside
these Pascal procedure counts. Instruction decoding, native relocation records,
inline data boundaries, and runtime overlay selection still need analysis.

## Findings

| Disk | Header block | Directory context | Locally valid segments | Procedures |
| --- | ---: | --- | ---: | ---: |
| 1 | 84 | Within SYSTEM.DATA; role unresolved | 0 | 0 |
| 1 | 85 | SUNDOG.LIBRARY / utility startup view | 1 | 50 |
| 1 | 103 | SYSTEM.LIBRARY | 7 | 132 |
| 1 | 140 | SYSTEM.STARTUP | 2 | 14 |
| 1 | 157 | Alternate/demo SYSTEM.STARTUP view | 5 | 30 |
| 1 | 251 | SYSTEM.PASCAL | 7 | 81 |
| 2 | 103 | Same header bytes as disk 1 block 103 | 7 | 132 |
| 2 | 140 | Same header bytes as disk 1 block 140 | 13 | 327 |

There are 42 valid segment occurrences, representing 34 distinct byte strings.
Those distinct segments contain 597 p-code procedure entries and 41 native 6502
procedure entries. Counts deduplicate whole segment payloads by SHA-256; they
do not deduplicate individual procedures shared by differing segments.

Native procedures occur in library segments 22, 23, 24, and 26, and segment 1
of the alternate/demo startup. The JSON records each procedure number, entry,
attribute pointer, lexical level, and representation. File type 5 in the Pascal
directory therefore cannot be interpreted as proof that a file is non-executable.

The block-103 library also declares three zero-disk-address DATASEG allocations:
segments 29, 30, and 31, requiring 760, 342, and 152 bytes respectively. These
are not disk extents starting at block zero. The scanner retains them separately.

## Two disks, one startup dictionary

The block-140 headers are byte-identical on both disks. They describe segments
1, 7, 8, and 12–21. The first two have valid copies on both disks. The remaining
eleven have valid procedure dictionaries on disk 2, at header block 140 plus
the recorded relative block number. The corresponding disk-1 bytes do not pass
the segment-number trailer check. Each failed local record links to its valid
counterpart, without treating that match as a runtime disk-selection trace.

For example, segment 21 starts at block `140 + 116 = 256` and occupies 8,132
bytes through block 271 on disk 2. A conventional extractor constrained to the
disk-1 SYSTEM.STARTUP extent (blocks 140–218) cannot recover it correctly.
The JSON includes exact DOS-image byte ranges for each candidate payload,
including the partial last sector.

The twelfth unresolved local entry is the block-84 header's slot 0. It describes
8,188 bytes starting at block 85, but the pointed-to payload has an invalid
segment trailer. Its purpose remains unknown. It is retained as a candidate,
not promoted to an executable segment or silently discarded.

## Split SYSTEM.PASCAL procedure 38

The trace in [bootstrap.md](bootstrap.md) establishes that header slot 0 loads
at `$F248` and slot 15 loads 170 bytes at `$BC72`. Slot 15 is a **procedure
fragment**, not a second conventional segment with its own procedure dictionary.

Slot 0's procedure-38 dictionary word lies at segment offset 3,046 (`$FE2E`
in memory). Its unsigned backwards displacement is 16,660 (`$4114`), so the
attribute pointer is `$FE2E - $4114 = $BD1A`. That is offset 168 in the captured
slot-15 fragment. Its final bytes are procedure number 38 and lexical level 1,
and its entry displacement points to offset zero, `$BC72`.

The parser resolves this reference only through the demonstrated memory mapping.
Without that mapping it reports an out-of-segment reference. It does not apply
arbitrary modulo wrapping to manufacture an in-file procedure. All other
identified procedure references stay within their segment payloads.

## Format and bounds

The 512-byte headers have 16 four-byte disk-address/byte-length records at offset
0, eight-byte names at 64, two-byte kind fields at 192, text addresses at 224,
and segment info words at 256. SunDog strips names to zero bytes and leaves
version metadata in some otherwise unused slots. Both features are preserved.
The three high bits of an info word contain version 5; its low byte is the
segment number, and bits 8–11 specify the machine representation.

A normal segment ends in its segment-number byte and procedure-count byte.
Procedure `p` has a backwards pointer at `length - 2 - 2*p`; that pointer locates
the two-byte procedure-number/lexical-level pair. A procedure-number byte of zero
marks native code. P-code entries also have local and parameter byte counts and
backwards entry/exit pointers. Native relocation tables remain undecoded.

The structural reference is the [UCSD cross-tool source](https://github.com/jdykstra/ucsd-psystem-xc/tree/397cf201ddf22ca25a82d0ad5401e5d70a38f849/lib):
`codefile/file/ii_1.h`, `segment/disassemble.cc`, and `disassembler.cc`.
The parser is local code, with checks against the supplied disks and the emulator
capture. It rejects truncated headers, odd segment lengths, bad trailers,
out-of-buffer dictionaries, unaligned attribute pointers, incorrect procedure
numbers, and invalid entry/exit pointers. Accepting a dictionary does not yet
establish that every byte in its procedures has been correctly decoded.

## Raw executable components outside this inventory

The screen initializer at disk-1 block 2 is loaded with block I/O and called
through library 22 procedure 25. It has no Pascal segment dictionary. See
[raw-screen-init.md](raw-screen-init.md) for its reconstructed code/table boundary
and additional raw-overlay leads. Complete segment ownership must not be used
as a claim that all executable content has been found.
