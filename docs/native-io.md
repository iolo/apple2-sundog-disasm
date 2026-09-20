# Native disk, device, and console services

`src/native/native_io.s` reconstructs all 4,096 bytes of SYSTEM.APPLE's
language-card bank 2 at `$D000`–`$DFFF`. Disk 1 logical blocks 219–226 supply
this bank; the following blocks supply common memory above `$E000`. The
[bootstrap trace](bootstrap.md) establishes this load and the separate bank-1
load. The two banks have different code at the same CPU addresses.

The module contains 1,393 instructions when its three overlapping BIT
instructions are counted, occupying 2,778 distinct bytes. Its remaining 1,318
bytes are tables, initial state, and preserved zero fill. This checkpoint does
not imply that every device path or peripheral configuration has been exercised.

## Entry points and evidence

| Address | Role supported by the instructions |
| --- | --- |
| `$D000` | Save status/A, apply saved status from `$FF`, and call device polling during disk operations |
| `$D00E` | Initialize disk state, default slot offset `$60`, and drive state |
| `$D026`, `$D029` | Write/read block wrappers; set command 2/1 at `$03AC`, unpack stack arguments, and transfer track-sized groups |
| `$D0EC` | Transfer a track group, including retry state and drive/slot selection |
| `$D28C` | Write a data field, including `$D5,$AA,$AD` prefix, encoded payload, checksum, and epilogue |
| `$D324` | Find an address field and decode/check its paired bytes |
| `$D502` | Read a data field; patch the disk-latch and destination operands before entering the timed loops |
| `$D5DA` | Seek using phase switches and delay tables; maintain the half-track position at `$DC90` |
| `$D658` | Split data at `($3E),Y` into six-bit and packed low-bit buffers |
| `$D6A5` | Poll configured input devices, including keyboard `$C000/$C010`, and maintain a buffered input queue |
| `$D8B8` | Route console output according to the configured device |
| `$D9A0`, `$D9B6`, `$D9C3` | Wait for, consume, and check buffered keyboard input |
| `$D9CA`, `$DA1D` | Interpret console characters and dispatch recognized control characters |
| `$DB44`, `$DB67` | Compute text-row pointers and shift text columns |

Common-memory jump entries at `$FF6B/$FF6E` target the write/read wrappers.
Other entries in `$FF59`–`$FF92` target polling, console, and device routines.
The common-memory code is source-built and checked with the other
[resident runtime components](runtime-classification.md). Those static
cross-references do not establish that every entry executes.

The source retains address-based labels for routines whose full conventions
remain unresolved. External calls into `$C800/$C84D/$C9AA` are retained without
claiming a particular installed peripheral's behavior.

## Instruction overlaps and runtime patching

Three BIT instructions intentionally consume bytes that also form an instruction
entered through another path:

| Prefix | Bytes | Effect |
| --- | --- | --- |
| `$D028` | `2C A0 01` | Skip `LDY #1` on the write path, retaining Y=2 |
| `$D258` | `24 38` | Skip `SEC` on the successful transfer path, retaining carry clear |
| `$D5D2` | `24 18` | Skip `CLC` on the failed data-read path, retaining carry set |

The source emits each one-byte prefix explicitly with a comment and assembles
the overlapped instruction normally. The structural audit verifies both the
prefix encoding and the alternative entry/fall-through boundaries.

`$D507`–`$D513` patch the low operand byte of five `LDX $C0EC` latch reads at
`$D560/$D577/$D58D/$D5A1/$D5B6`, using the selected slot offset OR `$8C`.
`$D51A`–`$D535` patch both operand bytes of three `STA $1000,Y` instructions at
`$D574/$D59B/$D5B3` from the destination pointer and group offsets. The two
console patch sites are the immediate operand of `EOR #$80` at `$DA18` and the
zero-page operand of `STA ($00),Y` at `$DBB9`.

The disassembly recipe gives these instructions explicit sizes. The accepted
source refers to their operands as `label+1` or `label+2`, preserving the initial
disk bytes. Polling-loop branches, delays, and instruction choices remain exact.

## Data boundaries

- `$D395`–`$D3FF`: preserved leading zero and inverse disk-symbol lookup tail.
  The lookup base `$D300` lies inside earlier code, but valid encoded symbols
  `$96`–`$FF` index the tail. For each of the 64 symbols, the entry is its index
  times four. Other entries in this tail retain their numeric index. No claim
  is made that arbitrary invalid disk symbols are safely decoded.
- `$D400`–`$D4FF`: 64 four-byte rows. Each holds three reversed bit pairs and
  one disk symbol. The source derives the 192 bit-pair entries from the row
  index and keeps the 64 disk symbols explicit. Writes use `$D403,X`; reads
  use `$D400,X`, `$D401,X`, and `$D402,X`.
- `$D648`–`$D657`: phase-on and phase-off delays, eight bytes each.
- `$D680`–`$D682`: disk slot offsets `$60,$50,$40`, indexed at `$D06C`.
  In particular, `$D680` is a table byte, not an RTS instruction.
- `$DC3B`: mutable shift-register byte used by the status routine.
- `$DC59`–`$DC6A`: 18 control-character values; `$DC6B`–`$DC8E`: the matching
  18 handler addresses consumed by `$DA1D`–`$DA37`.
- `$DC8F`–`$DC94`: the six-byte disk-state record. The historical two-byte
  track field accounts for the unused byte at `$DC91`; see the
  [state/storage audit](native-io-storage.md).
- `$DC95`–`$DFFF`: 875 zero bytes of spare fixed-bank storage after that
  complete state record, emitted with `.res` and checked by the same audit.

## Reproduction and validation

The analysis input is the first 4 KB of the verified SYSTEM.APPLE load. To
regenerate an exploratory listing from the accepted component:

```sh
python3 tools/build_disks.py
da65 -i src/native/native_io.info --comments 4 \
  -o build/native-io-review.s build/disks/components/native_io.bin
python3 tools/check_native_io.py
python3 tools/verify_disks.py
```

The accepted source additionally supplies comments, formula-generated table
entries, zero fill, and a size assertion. The audit checks code boundaries,
372 direct/vector targets, all overlaps, ten patched instructions, and both
disk conversion tables. It rejects deliberately corrupted vector targets,
overlap prefixes, patched operands, and conversion entries.

`reference/step06c-native-audit.json` records the structural results.
`reference/step06c-build-validation.json` records the exact disk hashes and
MAME play/utility comparisons. The latter cover reads, a disk swap, console
display, and the observed utility writes; exhaustive peripheral behavior and
the final two-emulator/save-load validation remain future work.
