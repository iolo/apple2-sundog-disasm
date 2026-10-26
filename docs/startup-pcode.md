# Disk-1 startup p-code

`src/pcode/game_dispatch.s` reconstructs the complete 576-byte segment 1 from
disk-1 SYSTEM.STARTUP, starting at logical block 141. The loader capture places
it at `$B2B4`, with procedure 1 entering at `$B49C` and attributes at `$B4E4`.
The rebuilt segment matches every byte of that recorded load, before relocation
changes. This is the first complete p-code segment reconstructed after the
36-byte SYSTEM.PASCAL entry proof.

## Procedure layout

All offsets below are relative to the segment start. Procedure order in the
file differs from procedure-number order.

| Procedure | Entry | Attributes | Lexical level | Local bytes | Parameter bytes |
| --- | --- | --- | --- | --- | --- |
| 2 | `$0000` | `$001E` | 1 | 0 | 0 |
| 3 | `$0020` | `$0090` | 1 | 0 | 0 |
| 5 | `$0092` | `$00CC` | 2 | 0 | 0 |
| 4 | `$00CE` | `$0180` | 1 | 18 | 0 |
| 6 | `$0182` | `$01E6` | 1 | 2 | 0 |
| 1 | `$01E8` | `$0230` | 0 | 0 | 4 |

The dictionary starts at `$0232` and ends with segment/procedure-count bytes
`1,6`. All procedure, exit, branch, and case pointers are assembled from labels.

The decoded source contains 243 instructions whose encodings occupy 447 bytes
(including inline case bounds/padding), eight branch-table words, eighteen
case-table words, three alignment bytes, sixty procedure-attribute bytes, and
fourteen dictionary/trailer bytes. Every segment byte is classified; there are
no unexplained gaps or raw executable payloads in this segment.

## Control flow and supported encodings

`tools/pcode_source.py` follows procedure entry/exit roots, fall-through edges,
conditional and unconditional branches, and case targets. It verifies 263
control-flow edges. Calls are retained as segment/procedure numbers rather than
inventing names for routines in modules still awaiting reconstruction.

- Short constants and short local loads are encoded in the opcode itself.
- Fixed byte operands cover CSP and procedure calls, returns, and packed-array
  indexing. CXP and IXP each have two byte operands.
- LLA/STL use a variable-width big operand; LDE/LAE/STE and LDA/LOD use a
  segment/lexical byte followed by a big operand. The one- or two-byte width is
  preserved explicitly, including non-minimal encodings.
- LDCI uses a little-endian word, displayed as a signed constant.
- FJP/UJP operands below `$80` are forward displacements from the next
  instruction. Negative operands select a pointer word relative to the
  procedure attribute address. The target is word-address minus stored word,
  with 16-bit wrapping, matching the native subtraction.
- XJP makes its instruction pointer odd before reading two aligned signed
  bounds. The next instruction is the default UJP, followed by one pointer word
  per value in the inclusive range. A case word uses the same subtraction rule.

Procedure 3 has an XJP at `$0041`, with bounds 0–9 and no padding. Procedure 4
has an XJP at `$0148`, with bounds 3–10 and one preserved zero padding byte.
Both tables are data within the procedure; they must not be decoded as ordinary
opcodes or treated as a linear instruction stream.

The format decisions are grounded in the reconstructed native handlers:
`$D155` (big operands), `$D2A0/$D2A8` (jumps), `$D5E2`–`$D670` (case tables),
`$D2DE` (integer constants), `$D3C8/$D3EE` (lexical access), and
`$D442/$D467/$D48C` (extended access). The tool checks the dispatch addresses
for every supported opcode and all short-local forms against the built
primitive component. That check protects the selected dialect; it does not
replace the handler analysis establishing operand formats.

## Observed call structure

Procedure 1 loads data segments through CSP 21 and calls procedure 1 in library
segments 22–28 before invoking its local procedure 6. Its exit path releases
segments through CSP 22. Those CSP meanings follow the native acquire/release
handlers at `$E66B/$E675`.

The remaining procedures select external calls based on fields in data segment
29, use the two case tables, and invoke other segments. The source preserves
the numeric calls and field offsets. Full UI/gameplay meanings are deferred
until those callees and data structures are reconstructed; the matching MAME
sessions alone do not assign a semantic name to every branch.

## Reproduce and test

```sh
python3 tools/build_disks.py
python3 tools/pcode_source.py build/disks/components/startup_disk1.bin \
  --segment 1 --source build/startup-review.s --report build/startup-analysis.json
python3 tools/test_pcode_source.py
python3 tools/verify_disks.py
```

The normal build consumes the checked-in source and `encoding.inc`; it does not
invoke the disassembler or read original disks. A fresh generated listing also
assembles back to the same 576 bytes. Seven tests cover non-minimal operands,
signed constants, both case alignments, nonzero case padding, wrapped case
pointers, backward selectors, branches into operands, unsupported/truncated
instructions, and unexplained gaps.

The decoder deliberately supports only the encodings verified so far. It rejects
native procedures, unsupported opcodes, unusual metadata/overlap arrangements,
and unclassified regions. It is not yet a universal decoder for all 597 p-code
procedures in the inventory. Additional instructions, inline data, native
relocations, and segment structures will be added with evidence as needed.

`reference/step06g-pcode-audit.json` records procedure metadata, coverage, calls,
pointer tables, and the loader-capture comparison. The full rebuilt disks and
MAME play/utility comparisons are recorded in
`reference/step06g-build-validation.json`.
