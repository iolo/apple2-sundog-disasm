# High-memory native services and preserved tail

`src/native/native_high.s` reconstructs the last 2,160 bytes of SYSTEM.APPLE,
at `$F790`–`$FFFF`. The disk mapping starts at disk-1 block 238 byte 400 and
ends at block 242 byte 511. Together with the primitive, I/O, shared, and
initializer components, it makes all 16,384 bytes of SYSTEM.APPLE source-built.
This is a byte-coverage milestone; some preserved data still needs explanation,
and the Pascal executable modules remain separate work.

The region contains 168 decoded instructions occupying 390 bytes, including a
95-byte preserved duplicate fragment, plus one identified instruction-operand
byte. Its other 1,769 bytes are tables, pointers, metadata and zero storage.

## Preserved fragment and records

`$F7A1`–`$F7FF` exactly duplicates original initializer bytes `$F5A1`–`$F5FF`,
corresponding to `$6B11`–`$6B6F` in the copied execution view. The source decodes
this fragment as instructions. It ends with a complete `LDA $80`, but the
following bytes are records rather than the rest of that initializer routine.
No executed path into this duplicate has been established. Its presence is
not evidence of an additional working initialization path.

The [metadata audit](native-high-metadata.md) now identifies `$F790`–`$F79F`
as a native Pascal footer and `$F7A0` as the retained operand of an original
`LDY #$03`. Three linker records at `$F800`–`$F82F` define `THISISIT` and end
the list, followed by zero storage. `$FFF6/$FFF7` hold the stored SYSTEM.APPLE
file-version word. The high-memory audit has no remaining provisional
preservation range; the older step-06f report records the earlier state.

## Runtime entry points

| Range/address | Verified structure |
| --- | --- |
| `$FE80`–`$FEAF` | Sixteen initially unpatched `JMP $0000` slot stubs |
| `$FEB0`–`$FED7` | Twenty device-mapping words, including `$FFFF` sentinels |
| `$FED8` | Compute and push a slot-stub return address, then use RTS to enter it |
| `$FEE6` | Select bank 1 and jump through `$BF16` |
| `$FEEC` | Select bank 1 and jump through `$BF2F` |
| `$FEF2` | Select bank 1 and jump to interpreter entry `$D152` |
| `$FF00`–`$FF41` | Twenty-two `JSR $FF9E` service entries |
| `$FF42` | Call a mapped device using a pushed address |
| `$FF52`–`$FF55` | Device-initialization pointers `$DAA9,$D83D` in bank 2 |
| `$FF58` | Empty service, an RTS |
| `$FF59`–`$FF98` | JMP targets for polling, console, disk, status, and device services |
| `$FF9E` | Save the original return, select bank 2, and invoke a derived target |
| `$FFBB` | Restore the saved return, select bank 1, and return |
| `$FFCB` | Indirect service jump through `$D3/$D4` |
| `$FFCE` | Adjust console columns through the bank-2 text routine |
| `$FFE2`–`$FFE3` | Device reset pointer `$D851` |
| `$FFF8`–`$FFFF` | Boot pointer `$FEF2` and three interrupt/reset pointers `$FEEC` |

The service gateway pulls the service entry's JSR return address and adds
`$5A`. For example, entry `$FF12` supplies return `$FF14`, producing target
`$FF6E`, whose JMP enters bank-2 `read_blocks` at `$D029`. It saves the caller's
return in `$BF1A/$BF1B`, reads `$C083` to select bank 2, and uses the indirect
jump at `$FFCB`. The return path reads `$C08B` to restore bank 1.

The trailing entry at `$FF3F` derives `$FF9B`, a three-NOP run before the gateway.
It is preserved exactly; its intended use is not established. The audit checks
that all 22 derived targets land on decoded instruction boundaries without
claiming that every entry is used or is safe to invoke arbitrarily.

## Keyboard translation

Bank-2 code at `$D754` compares against the nine bytes at `$FFE4`–`$FFEC`, using
an index capped at eight (or two on another path). A match reads the corresponding
byte at `$FFED`–`$FFF5` from `$D76B`. These are two data tables, not opcodes:

| Input | Output |
| --- | --- |
| `$0B` | `$5B` |
| `$0C` | `$0A` |
| `$0F` | `$0B` |
| `$5D` | `$4D` |
| `$5E` | `$4E` |
| `$40` | `$50` |
| `$1D` | `$5D` |
| `$1E` | `$5E` |
| `$00` | `$40` |

## Verification and remaining questions

```sh
python3 tools/build_disks.py
python3 tools/check_native_high.py
python3 tools/verify_disks.py
```

The audit checks every declared code span, 79 direct/vector targets, the 22
derived service targets, slot-stub encodings, bank-switch operands, translation
tables, and duplicate fragment. It validates bank-2 destinations against the
bank-2 source and interpreter entry against bank 1, rather than conflating the
two `$D000` address spaces. Corrupted bank-specific targets, switch operands,
and duplicate bytes are rejected.

`reference/step06f-native-audit.json` records the structural results.
`reference/step06f-build-validation.json` records exact full-disk comparisons,
an isolated build with no original disks, and MAME play/utility comparisons.

The duplicate's runtime use, the trailing service entry, the ten-byte primitive
descriptor's precise semantics, and the initializer's 42-byte payload remain
documented questions. Source-built byte coverage does
not prove their meanings or substitute for reconstructing the remaining
Pascal modules, extracting assets, and completing the final behavior checks.
