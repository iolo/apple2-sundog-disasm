# Pascal header extension data

`src/data/pascal_header_extensions.s` reconstructs **1,652 disk bytes** following
the already classified 288-byte segment-header tables. Six header tails are now
completely classified. The two block-103 library headers retain **70 unresolved
bytes each**, explicitly excluded from the generated source and mappings.

## Format evidence and local checks

Appendix C of Apple's original reference manual places a 32-bit intrinsic-unit
set after the segment-information words, then library information whose detailed
format is unspecified, with optional compiler comment text near the block end.
The set identifies required intrinsic segments by bit number. This supplies the
missing format evidence for the next four bytes of our existing header layout.
[Apple Pascal Operating System Reference Manual, printed pages 267–269](https://markbessey.blog/wp-content/uploads/2025/05/apple_pascal_operating_system_reference_manual_hq_text.pdf#page=274).

The maintenance tool checks the first 288 bytes of every selected block against
its existing [table audit](pascal-header-tables.md), not merely a filename or a
candidate byte pattern. At offsets $0120–$0123, the reviewed little-endian sets
are:

| Header occurrence | Mask | Intrinsic segment numbers |
| --- | --- | --- |
| Disk 1 blocks 84 and 85 | $66400000 | 22, 25, 26, 29, 30 |
| Both block-103 headers | $00000000 | None |
| Both block-140 headers | $FFC00000 | 22–31 |
| Disk 1 block 157 | $EEC00000 | 22, 23, 25, 26, 27, 29, 30, 31 |
| Disk 1 block 251 | $00000044 | 2, 6 |

In the six non-library occurrences, all bytes at $0124–$01AF are zero within
the documented library-information area. Offset $01B0 holds a bounded counted
string: empty in blocks 84/85/157, 73 characters in block 140, and 65 characters
in block 251. The latter two are the stored FTL and Apple copyright notices.
The remainder after each string through $01FF is zero. These exact local
boundaries are verified from the bytes; the manual's general description is
not treated as proof of an arbitrary version's detailed private layout.

The source emits the segment sets as `.dword`, string lengths and characters
explicitly, and checked zero storage as `.res`. Nonzero replacement bytes in a
zero-only field are rejected for further review. Thus classification uses the
established header layout and complete bounded fields, not a blanket zero-run
or lack-of-execution heuristic.

## Library-header exception

Both block-103 copies have zero library storage at $0124–$0175. Their bytes
$0176–$01A1 and $01E6–$01FF contain nonzero word-like values. Those **44+26 bytes
per header remain unresolved**; the unspecified library format alone is not
used to conceal them as a generic binary remainder.

Between those ranges, $01A2 is a count of 67 followed by exactly 67 printable
characters forming the Pascal command prompt with its `[1.2]` suffix. This
self-contained counted text is data inside the documented header-information
storage. It is separately emitted, retaining the original spelling and count.
Its location crosses the comment location observed in the other headers;
therefore this block is not falsely parsed as an ordinary compiler comment.
No particular allocator history or runtime-address meaning is assigned to the
surrounding unresolved words.

## Validation

```
python3 tools/test_header_extension_source.py
python3 tools/header_extension_source.py --verify
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

The tests cover intrinsic bit numbering, counted comments, strict zero-field
checks, malformed text/length rejection, and exclusion of the library words on
both sides of the counted prompt. The tool verifies existing table hashes,
all selected fields, exact assembly, deduplicated copies and generated artifacts.
Its six unique source slices occupy 1,050 bytes and map to 1,652 disk bytes.
Normal builds depend on committed source only, not this extractor or the online
manual. No new emulator-validation completion is claimed.
