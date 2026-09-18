# Raw warp animation

Disk-2 blocks 83–85 contain a 1,536-byte native overlay executed at `$1800`.
It is reconstructed in `src/native/warp_animation.s`. This routine is loaded
with block I/O and called through a raw address, outside the Pascal segment
inventory.

## Load and entry evidence

Startup segment 7 procedure 5 sets data-segment 29 word 27 to
`26 + 16 + 10 + 9 + 15 = 76`. Game segment 13 procedure 35 at `$1760` calls
its enclosing procedure 31 with values `118, 3, 4, 1, 0`. Procedure 31 at
`$15DC` tests the first flag, then reads three blocks into `$1800`, starting
at relative block `word27 + 4`. Library 22 procedure 53's +3 bias therefore
selects absolute block 83. The caller displays “Engaging warp engines” and
subsequently invokes the raw `$1800` entry through library 22 procedure 25.
Other calls to this entry exist at game-13 offsets `$18A9`, `$194D`, and `$1F60`.

The overlay updates indexed position/state arrays, plots pixels through the HGR
row tables, polls its supplied parameters, and optionally toggles the speaker.
This establishes its animation role; detailed gameplay mechanics remain outside
this reconstruction checkpoint. A fresh runtime trace of this overlay is not
claimed.

## Complete classification

All 1,536 bytes are owned: 1,216 distinct instruction bytes, represented by 586
instructions including the two overlapping BIT paths below, and 320 data bytes.

| Memory range | Data and consumer evidence |
| --- | --- |
| `$1C02`–`$1C08` | Seven pixel masks `$01,$02,$04,$08,$10,$20,$40`; `$1BD0`–`$1BD9` reduces the pixel coordinate modulo seven before `$1BDA` indexes them |
| `$1C0D`–`$1C10` | Two arithmetic scratch words initialized at `$1C13/$1C18/$1C1D/$1C22` and shifted/added at `$1C27`–`$1C41` |
| `$1C62`–`$1CA7` | Seventy bitmap bytes; `$1CEC` reads `$1C61+X` for X=70 down to 1, drawing seven rows of ten bytes |
| `$1D11`–`$1DFF` | Initial zero workspace: four 54-byte arrays at `$1D11,$1D47,$1D7D,$1DB3` and the first 23 bytes of the array at `$1DE9` |

The workspace classification follows indexed reads/writes, including the array
copy at `$1A13`–`$1A3A` and initialization beginning at `$1AB8`. The live routine
also uses workspace beyond `$1DFF`; those runtime addresses are not additional
bytes in this three-block input. The remaining bytes through `$1D10` are all
instructions reachable through the entry's native control flow.

## Overlapping instructions and runtime patches

At `$1AEE`, `BIT $46E9` consumes bytes also decoded as `SBC #$46` at `$1AEF`.
The branch at `$1AE1` enters that SBC directly. Likewise `BIT $38E9` at `$1B0D`
overlaps `SBC #$38` at `$1B0E`, selected by the branch at `$1AFD`. These are two
intentional ways through the same bytes. Source uses an explicit BIT-prefix
macro followed by the SBC instruction; the audit checks exact bytes, both entry
points, and the following instruction. Other code/data overlaps remain errors.

The shipped bytes also contain two patchable instructions:

- `$181B` can replace the first byte of `BIT $C030` at `$1C09` with RTS (`$60`),
  disabling the speaker routine without changing the stored image.
- `$183A` installs BIT zero-page (`$24`) at `$1CEF`; `$1CC0` can replace it with
  EOR indirect-Y (`$51`). Both encodings use the existing `$0C` operand byte.

These alternate forms are documented code transformations, not unidentified
data. The source preserves the original BIT instructions. The analysis records
the complete original control flow, including both overlapping entries; it does
not pretend that a single straight-line listing covers every path.

`tools/test_native_raw_source.py` includes a real ca65 round trip of the BIT/SBC
overlap and rejects altered overlap bytes and unexplained overlaps. Diagnostic
gap inspection cannot emit adoptable source: any unclassified byte still causes
normal preparation to fail. Full preparation/adoption and disk comparison prove
that the reconstructed overlay retains all original bytes.
