# Mixed Pascal/native module reconstruction

`tools/native_pascal_source.py` follows 6502 control flow from native procedure
entries, using the four relocation lists described in [native-pascal.md](native-pascal.md).
It resolves procedure-relative and segment-relative direct calls/jumps before
following them. Calls into another native procedure contribute additional roots
to that procedure, and the final module check requires every such destination
to be an instruction boundary.

`tools/pcode_source.py` accepts this native decoder alongside its p-code decoder.
Both feed the same byte-ownership map, so code, inline data, relocation records,
and procedure metadata cannot overlap or leave unclassified gaps. No raw-byte
fallback is used for undecoded instructions. Native relocation pointers must
name a complete address operand or a word inside a classified data item.

Data outside the control-flow paths is accepted only through a reviewed recipe
under `src/pcode/evidence/`, recording its consumer or other classification
proof. Explicit additional code roots and proven unconditional outcomes of
conditional branches also require recorded evidence. The decoder does not
assume every unvisited byte is data. A lone zero after a terminating native
instruction and before an aligned relocation list is recorded as alignment.
BRK is rejected until its interrupt-signature behavior is explicitly modeled.

The opcode table describes the 151 standard NMOS 6502 encodings. Tests assemble
one instance of each through ca65 and compare the complete output byte for byte.
Further tests exercise relocated jumps, data ownership, branches into operands,
evidence-backed branch outcomes, and alignment after a tail jump. This verifies
tool behavior; module recipes still require evidence from the shipped code.

## Alternate startup segment 1

The 880-byte segment at disk-1 block 172 has five p-code and three native
procedures, totaling 413 instructions. Its native procedures contain 525 code
bytes. Four tables occupy `$028D`–`$02AB`: seven masks, eight address high bytes,
eight address low bytes, and eight masks. The procedure-relative loads at
`$0251`, `$027D`, `$0278`, and `$0282` are their consumers. The first index is
bounded by a comparison with 7; the others share a countdown loop from 7 to 0.
Two native alignment bytes and all relocation/attribute/dictionary records are
classified separately. Numeric procedure and field names remain uninterpreted.

## Shared library segment 24

The reviewed recipe identifies three 12-byte tables after procedure 3 at
`$0F23`, `$0F2F`, and `$0F3B`, consumed by procedure-relative indexed loads
with an index bounded by 12. A single alignment byte follows them. Procedure 4
has a 33-byte lookup table at `$0FDD`, accessed after folding its index to 0–32.
Procedure 5 has a single zero alignment byte after its terminal loop jump.
The recipe describes data boundaries independently of the p-code procedures.
Adoption status is recorded in PROGRESS.md and the reconstruction manifest.

## Library segment 26 variants

Both 3,058-byte copies contain the same instructions and native lookup data.
Only 13 bytes in the inline string at `$03F7` (20 bytes total) differ. The source
uses a shared `library_26_body.inc` with an explicit disk selector for this data.
Each variant remains independently mapped and compared to its disk bytes.

Procedure 18's loads at `$0A8C` and `$0A90` address a 280-byte table at `$0A94`.
All entries are exactly `floor(index / 7)`, now expressed as an assembly-time
formula. The following code at `$0BAC` is a helper reached by relocated direct
JSRs in procedures 9–12. The decoder discovers this entry from those callers;
it does not classify the helper as part of the table. Remaining native procedures
are completely covered by entry/branch/call traversal and alignment rules.
