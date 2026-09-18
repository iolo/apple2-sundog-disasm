# P-code reconstruction proof

The native initialization requires segment version 5, and the shipped
interpreter's dispatch and operand readers match the following observed p-code
encodings. This is evidence for the supported subset, not a claim that an
unmodified UCSD II.1 tool can decode every Apple Pascal instruction correctly.

## First procedure rebuilt from source

```sh
python3 tools/build_pcode_probe.py
```

This assembles `src/pcode/system_entry.s` with ca65 and ld65, then compares the
36-byte result with disk-1 block 252 bytes 0–35. The assembler consumes only
project source. Original disk bytes are read afterwards for verification.
The resulting SHA-256 is
`ef70020a699c0a1201d839a50e0cf38a7c8fe4c69971c0a68b621ce38c3cdfc3`.

The procedure contains named instruction macros, labels for control flow,
a backwards jump-table word, and procedure attributes. Its instructions are
not included as a raw binary payload. The local-storage count, zero padding
after XIT, procedure number, and signed lexical level preserve the disk bytes.

The chosen reconstruction approach is **ca65 instruction macros for p-code,
alongside ca65 native 6502 assembly**, with explicit data/relocation structures.
Macros avoid a dependency on a historical Pascal compiler reproducing original
instruction choices. The current include implements only this first procedure's
subset. It must be expanded with evidence for other instructions, constants,
case tables, native-procedure relocation records, and alignment behavior.

## Interpreter evidence

For opcodes `$80`–`$FF`, bank-1 `$D293` dispatches via the word table at `$D000`,
indexed by twice the opcode's low seven bits. Short constants below `$80` use
the direct handler at `$D288`. Relevant table entries are:

| Opcode | Instruction | Native handler |
| --- | --- | --- |
| `$9E` | CSP | `$E67F` |
| `$9F` | LDCN | `$D2D7` |
| `$A1` | FJP | `$D2A0` |
| `$B6` | LOD | `$D3C8` |
| `$B8` | STR | `$D41C` |
| `$B9` | UJP | `$D2A8` |
| `$C2` | CBP | `$E32B` |
| `$C3` | EQUI | `$DFA9` |
| `$CB` | NEQI | `$DF7F` |
| `$CC` | STL | `$D33B` |
| `$CD` | CXP | `$E306` |
| `$CE` | CLP | `$E2D3` |
| `$D6` | XIT | `$D6E4` |

The variable operand reader at `$D155` consumes one byte if its high bit is
clear, otherwise two bytes. The two-byte value is `((first & 127) << 8) | second`;
the handler doubles this to a byte offset for word-addressed storage. The macros
retain an explicit width so they never silently shorten an original encoding.

Forward jump operands are relative to the byte after the operand. Negative
operands select a backwards-pointer word relative to the procedure attribute
address in `$54/$55`. The reconstructed procedure demonstrates both forms:
`$A1 $03` skips the external call, and `$A1 $F6` selects the loop word ten bytes
before the attributes. The word's value 15 points back to the CBP instruction.

Not every nominal UCSD opcode is implemented here. For example, `$81`, `$83`,
`$85`, `$D3`, and `$D4` dispatch to the common `$D1EF` error path. `$D2` shares
the one-byte advance handler at `$D28D` with NOP `$D7`; it must not be assigned
older BYT behavior solely from an opcode-name table. BPT `$D5` uses a variable
operand through `$D155`, not an unconditional one-byte operand.

The external opcode-name/format reference is
[`lib/pcode.h` in the UCSD cross-tool source](https://github.com/jdykstra/ucsd-psystem-xc/blob/397cf201ddf22ca25a82d0ad5401e5d70a38f849/lib/pcode.h).
Handler addresses and encoding decisions above are checked against SunDog's
SYSTEM.APPLE bytes, rather than inferred solely from that reference.

## Dynamic dispatch trace

`reference/pcode-entry-trace.json` contains 16 consecutive stops at bank-1
`$D293`, with CPU stop receipts, p-code pointers, zero-page context, and 16-byte
instruction snapshots. `python3 tools/verify_runtime_evidence.py` compares every
snapshot to the corresponding disk bytes. No emulator memory edits were used.

The first five stops are at `$F248`, `$F249`, `$F24B`, `$F24C`, and `$F24E`,
matching LDCN, STL 5, SLDC 1, CSP 38, and CXP 4,1 in the reconstructed source.
The CXP then enters SYSTEM.PASCAL segment 4 procedure 1 at `$B674`. Its known
entry offset 1,546 and attribute offset 1,974 agree with load base `$B06A` and
observed attribute pointer `$B820`. All eleven subsequent snapshots match that
segment's disk-1 block-264 payload under this mapping. This verifies the sampled
bytes and mapping; it is not a full 1,998-byte memory capture of that segment.

The trace includes LOD/STR operands `01 05` and `01 80 E5`. Their next instruction
pointers advance by three and four bytes respectively, independently confirming
the variable operand widths. A UJP operand -18 at `$B674` selects `$B80E`, whose
word points to `$B805`; operand -20 at `$B808` selects `$B80C` and returns to
`$B676`. The observed stop sequence follows those targets.

To continue the trace, leave breakpoint `$D293` set and resume once per opcode;
read `$58/$59` for the p-code pointer and `$54/$55` for the attribute address.
For coarse overlay tracing, use the segment-load routines near `$E46D`/`$E4E9`
instead of stopping on every interpreted instruction. Their complete call
convention and boot-to-startup sequence remain to be documented before the
step-04 architecture gate is closed.
