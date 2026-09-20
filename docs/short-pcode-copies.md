# Short retained p-code copies and utility edge changes

Eight reviewed exact matches account for 396 additional disk bytes. These are
shorter than the earlier search's 64-byte discovery cutoff, but retain explicit
provenance to complete, independently decoded source modules. Five fill complete
block tails; three extend the retained utility variant's clipped last procedure.

| Disk | Block | Byte offset | Length | Source component and offset |
| --- | ---: | ---: | ---: | --- |
| 1 | 102 | 452 | 60 | utility_disk1 `$1FC4` |
| 1 | 155 | 156 | 52 | utility_disk1 `$1BEC` |
| 1 | 155 | 209 | 44 | utility_disk1 `$1C21` |
| 1 | 155 | 254 | 36 | utility_disk1 `$1C4E` |
| 1 | 173 | 470 | 42 | alternate_9 `$0400` |
| 1 | 267 | 462 | 50 | system_4 `$05CE` |
| 2 | 217 | 460 | 52 | game_17 `$0BCC` |
| 2 | 271 | 452 | 60 | game_21 `$1DC4` |

The block-102 copy contains the counted `Certificate` string and procedure
metadata; block 173 contains the complete forty-byte pirate warning between
clipped instruction bytes. The system-4 copy begins within `SYSTERM:` and ends
after a return/alignment sequence. The game-21 copy contains a procedure footer.
These mixed regions remain source-built code and explicit data; strings do not
cause their surrounding opcodes to be classified as assets.

The frozen recipe explicitly requests a 32-byte minimum for this reviewed set;
the default remains 64. All eight matches contain at least ten distinct bytes
and pass exact source/disk hashes. No automatic discovery occurs during adoption.
Every copied byte inherits its original decoded item, full instruction/data
extent and clipping flags. Missing instruction bytes, strings or branch tables
outside a retained copy are not fabricated. Original source addresses describe
provenance; execution from the copied locations is not asserted.

## Four changed utility bytes

Independent review of the [complete variant procedures](utility-variant-procedures.md)
and the eight copies above leaves four differing bytes in blocks 151–155:

| Location | Complete stored context | Change from primary utility |
| --- | --- | --- |
| Block 151 byte 64 | Ten-byte footer at bytes 56–65 | Procedure marker 32 becomes 31 |
| Block 155 byte 208 | `LAO 11` at bytes 207–208 | One-byte address operand 12 becomes 11 |
| Block 155 byte 253 | `LAO 11` at bytes 252–253 | One-byte address operand 12 becomes 11 |
| Block 155 byte 290 | `CGP 42` at bytes 289–290 | Call operand 44 becomes 42 |

All four changes retain the primary source's item boundaries and operand widths.
The caller's target 42 is present in the independently decoded variant at
block-151-relative `$07FC`. The preceding footer's other nine bytes exactly
match the primary procedure: local size 26, parameter size 8, exit displacement
8, entry displacement 126 and lexical level 2. Its entry is clipped off the
front of this retained area; no missing body is supplied.

`src/pcode/utility_variant_edges.s` emits the complete ten-byte footer and three
complete two-byte instructions, totaling sixteen bytes. Its four new mappings
select the changed bytes; twelve verified context bytes retain their existing
utility-source mappings. Both LAO opcodes and the CGP opcode are therefore
visible in source, rather than represented by unexplained operand literals.

## Verification

The source-copy workflow freshly assembles the five referenced source components
and reruns their complete p-code audits. `docs/reference/short-pcode-copies.json`
records every copied item and code/data classification. The edge verifier checks
complete stored instruction/footer contexts, their exact primary-source
counterparts, the variant's procedure-42 entry, and each context/new mapping.

```sh
python3 tools/pcode_copies.py --verify --recipe src/pcode/evidence/short_copies.json --audit docs/reference/short-pcode-copies.json
python3 tools/utility_variant_edges.py --verify
python3 tools/test_pcode_copies.py
python3 tools/test_adopt_component.py
```

The full five-block utility residue is now classified as code/data with source
ownership. This does not recover its missing original segment dictionary or
prove it executes. Other disk regions and provisional runtime bytes remain open.

A later [three-tail audit](retained-short-tails.md) resolves another 70 bytes
below this checkpoint's 32-byte cutoff, using fixed matches and complete donor
procedure contexts. It leaves the general discovery thresholds unchanged.
