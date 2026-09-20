# Encoded native metadata and copied instruction tails

The [body audit](encoded-native-overlay-body.md) leaves the end of each decoded
2,048-byte bank unresolved. Further structural analysis identifies a complete
native Pascal footer and a bounded copy of earlier code/data. This checkpoint
reconstructs **464 additional bytes per bank**, keeping nine suffix bytes and
15 earlier body bytes unresolved. Both encoded banks therefore now have
**24 unresolved bytes each**. Runtime execution of the bodies remains unproved.

## Native segment footer

The decoded extent $0000–$0637 parses as a single-procedure, segment-1 native
Pascal segment. The existing procedure dictionary and native relocation parsers
independently accept the following structure in both variants:

| Bank offset | Size | Classification and evidence |
| --- | ---: | --- |
| $0627 | 1 | Zero alignment byte after the final three-byte JMP at $0624 |
| $0628–$062F | 8 | Four native relocation counts, all zero |
| $0630 | 2 | Entry displacement $0630, resolving backward to offset zero |
| $0632 | 2 | Native marker zero and lexical level zero |
| $0634 | 2 | Dictionary displacement two, resolving to the native attributes |
| $0636 | 2 | Segment number one and procedure count one |

These 17 bytes are structured data, emitted using explicit byte/word fields.
The footer corroborates the beginning of the loader as the native entry; it does
not make the remaining ambiguous body bytes identifiable automatically.

## Copied native material

The **456 bytes at $0638–$07FF** match offsets **$0438–$05FF** of the same decoded
bank, with exactly two differing bytes: $07FA/$07FB are zero rather than the
primary body's wipe-start pointer ($1210 in play or $1610 in the alternate).
The latter pointer addresses the primary wipe loop at body offset $0610.
The copy retains a zero initializer in the corresponding, independently
identified two-byte data field. No other difference is accepted.

The copy's ownership follows the independently decoded original body items,
not a heuristic disassembly of arbitrary leftover bytes. It contains 140 complete
instructions plus two clipped instruction fragments, totaling 327 code bytes.
The other 120 adopted copy bytes are the corresponding vector words, obfuscation
delimiters, constants, and mutable-state fields. Nine bytes whose originals still
lack classification remain unresolved here as well: $0772–$0773, $07DB–$07DC,
$07E3–$07E4, $07F0, and $07F6–$07F7. Matching an unresolved original does not turn
its copy into identified data.

The beginning and end of the copy intersect established instruction boundaries:

- $0638 contains the $03 displacement of the `BCC` at original offset $0437.
  Its opcode $90 lies before the copied extent. Source emits the displacement
  as `target - next_pc` and names the complete original instruction.
- $07FF contains the $AD opcode of `LDA $C083` at original offset $05FF.
  Its two operands lie beyond the copied extent. Source names that instruction
  and emits only the surviving absolute-LDA opcode.

No missing instruction bytes are invented. The full instructions are assembled
at their provenance addresses, with branches and calls reconstructed from the
original body graph. This does not assert that the suffix was executed at those
addresses, or that execution ever entered the stored tail. The copied native
bytes are nevertheless reconstructed as code rather than hidden in a data blob.

## Preparation and checks

`tools/encoded_overlay_tail.py` reruns the original body analysis from the exact
rebuilt bank, parses and checks the footer, verifies every byte of the copy,
and transfers only proven ownership. It assembles all seven selected intervals
per bank, preserves their original stream encoding phases, and verifies both
plaintext and re-encoded bytes. Every emitted byte is mapped to disk. The full
reports retain all unresolved suffix offsets and identify both partial
instructions and their original full encodings.

```
python3 tools/test_encoded_overlay_tail.py
python3 tools/encoded_overlay_tail.py play --verify
python3 tools/encoded_overlay_tail.py alternate --verify
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

Tests exercise footer displacement/alignment, unexpected copy changes, the
reviewed zero initializer, transfer of unknown-byte gaps, clipped-instruction
context, and exact assembly of the selected ranges. These structural and build
checks do not replace the remaining whole-disk audit or both-emulator validation.
