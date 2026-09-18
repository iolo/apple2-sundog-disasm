# Disk-1 utility p-code

`src/pcode/utility_disk1.s` reconstructs the complete 8,644-byte UTILITY segment
from disk 1, code header block 85, segment 1, beginning at logical block 86.
Its 50 procedures contain 4,073 instructions (6,628 encoding bytes), 1,239
inline string bytes, 150 branch/case-pointer bytes, 25 alignment bytes, and
602 procedure metadata/dictionary bytes. Source labels use segment-relative
addresses because the loader relocates the complete segment.

The decoder follows each procedure's entry and exit, then every branch and
fall-through edge. Every claimed byte has exactly one owner. Strings are data
because the LSA handler explicitly skips their declared lengths and returns
an address; their contents are never guessed as instructions. Jump and case
words are data because their consumer computes instruction addresses from them.
Metadata locations follow the procedure dictionary and interpreter layout.
No unreachable or unidentified byte sequence is silently emitted as data.

`reference/step06h-pcode-audit.json` records every data region and consumer where
applicable, procedure metadata, calls, and byte totals. Numeric procedure and
field names remain intentionally uninterpreted. The classification does not
claim a full explanation of utility behavior.

## Extended encoding evidence

`tools/pcode_source.py` and `src/pcode/encoding.inc` now cover integer/Boolean
operations, global/intermediate/indirect loads and stores, indexing, block moves,
short global and indirect loads, and the following variable formats:

- LSA `$A6`, handler `$D929`: opcode, byte length, string bytes. The returned
  address includes the length byte; the next instruction follows the payload.
- LPA `$D0`, handler `$D911`: the same extent encoding, but the returned address
  points at the first payload byte. Classified as packed-array data.
- LDC `$B3`, handler `$D4D6`: count byte, optional padding when the opcode address
  is odd, then count little-endian words. The handler rounds its original IP up
  to even and advances by `2 * (count + 1)`. Counts outside 1–126 are rejected
  because the native increment is byte-sized and wraps; no such case is adopted.
- Typed comparisons `$AF/$B0/$B1/$B4/$B5/$B7`, common path `$DE2E`: tags 2, 4,
  6, and 8 consume just the tag; tags 10 and 12 also consume a variable-width
  length. Unknown tags are rejected even though the native default path can
  consume them. Tags and lengths are operands, not inline data payloads.
- CIP `$AE`, handler `$E285`: one procedure-number byte; the callee's lexical
  level determines static-link traversal. BPT `$D5`, handler `$E803`, consumes
  a variable-width operand through `$D155`.
- `$E8`–`$F7` use `$D359` for short global words 1–16. `$F8` uses `$D4AB` and
  `$F9`–`$FF` use `$D4A8` for short indirect word offsets 0–7.

All supported opcode vectors are checked against the source-built interpreter.
Native handler code is the encoding authority, not a generic UCSD version table.
Inline arrays/words have synthetic round-trip tests even though this utility
segment itself uses inline strings only.

## Validation

Eleven decoder tests check malformed boundaries, both constant/case alignments,
signed and nonminimal operands, short loads, typed comparisons, inline payload
classification, and assembly back to the fixture bytes. The complete utility
segment assembles identically. Both full disks still match every original byte.
The prior MAME reference sessions therefore remain applicable; no additional
emulator session was run for this identical-output replacement.
