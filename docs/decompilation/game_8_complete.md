# Game 8: selection, status displays, pause, and rest

All 18 game8 procedures now have reviewed Pascal bodies, covering 1,503 original
instructions. This group adds procedures1/10–17: nine bodies and 996 instructions.
Overall recovery at this checkpoint was106 of 570 targeted bodies, 8,694 instructions, and 16 of38
native interfaces. Other modules remain incomplete.

The source component is `game_8`, SHA-256
`49588749543660839355c65b1acaacc2cb5679ae726d914ed1c1c2a5be92d89d`, assembly
revision `5c64227e095e86ba1e8c79b8e4425986cf9ae58f`. Physical extents are recorded
in `src/pcode/game_8.adopt.json`. All validation in this group is static.

| Procedure | Entry through return | Attributes | Instructions | Source |
| --- | --- | --- | ---: | --- |
| 8:1 | `$0B54..$0C05` | `$0C12` | 104 | [proc_01.pas](../../src/pascal/game_8/proc_01.pas) |
| 8:10 | `$03AA..$04C1` | `$04CE` | 142 | [proc_10.pas](../../src/pascal/game_8/proc_10.pas) |
| 8:11 | `$04D0..$0502` | `$050E` | 28 | [proc_11.pas](../../src/pascal/game_8/proc_11.pas) |
| 8:12 | `$0510..$0545` | `$0550` | 24 | [proc_12.pas](../../src/pascal/game_8/proc_12.pas) |
| 8:13 | `$0552..$05BF` | `$05CA` | 46 | [proc_13.pas](../../src/pascal/game_8/proc_13.pas) |
| 8:14 | `$05CC..$0687` | `$0694` | 90 | [proc_14.pas](../../src/pascal/game_8/proc_14.pas) |
| 8:15 | `$0696..$07B7` | `$07C2` | 124 | [proc_15.pas](../../src/pascal/game_8/proc_15.pas) |
| 8:16 | `$07C4..$0934` | `$0942` | 190 | [proc_16.pas](../../src/pascal/game_8/proc_16.pas) |
| 8:17 | `$0944..$0ADC` | `$0AF2` | 248 | [proc_17.pas](../../src/pascal/game_8/proc_17.pas) |

## Complete scope and input behavior

`proc_01.pas` includes the local declarations and all children in dependency
order. The entry performs setup, periodic updates, pointer/input handling, and
the original ordered dispatch. Normal return calls18; child3's failure path
and child16's save path call22:52 and exit the enclosing entry directly, skipping
that normal cleanup. This checkpoint compiled the actual parent body at107. The later
[game18 completion group](game_18_complete.md) moves it to83 and also replaces
the empty game18 parent with its recovered body.

Procedure10 keeps the selection value/VAR alias in calls27:7, redraws using
the original live coordinates, and always polls input selector1 before testing
the exit flags. Word347 is tested by its low bit. The cleanup's zero-item branch
reads local4, which is only initialized by a preceding hit-test call. No default
is inserted: a path reaching that read without a hit test retains the original
uninitialized-state limitation. Its local4 position is preserved, but this is
not a claim that arbitrary uninitialized contents match at runtime.

Procedure11 calls random once per iteration, increments the update counter
only when MOD8 is zero, invokes3 on the threshold, then polls selector4 even
when the external exit flag is already set. It exits on the input result's
low bit becoming clear or word347's low bit becoming set.

## Status displays and storage

Procedure12 copies DATASEG31 bounds6 to DATASEG29 bounds327 for the clock display,
waits through11, then clears the bounds. Procedure13 retains the two-word money
format and exact text, including the nonpositive test and width/zero-padding
choices. Neither invents a scalar currency representation.

Procedure14 preserves the paired attribute labels, substring call0:25, byte
accesses at94+index and94+index+5, and the hidden fifth current value. The original
argument58 at `$0631` denotes a character to SAS, not a pointer dereference:
the supplied handler at `$D94B..$D96E` turns a zero-high-byte source into a
one-character string. The reference compiler's LSA1 `":"` is equivalent for
this call. The substring temporary needs four bytes for its two-character
result; the original reserved sixteen bytes. Both capacity/range behavior
and the actual two-character payload remain intact.

Procedure15's name tables use pointers at words25/24/23 and six/eight/ten-word
strides. New storage views retain those strides and the source's packed
location fields. The system record's final four bytes remain separate from
its leading string. The views describe indexed access windows, not allocation
or proof that every pointer/index is valid. City/planet/system meanings are
supported by the literal display labels and branch strings in this routine.

## Pause and timed rest

Procedure16 preserves the two nested input loops: sound toggles repeat the outer
menu, while save/cancel leave it. The save hit test executes before the saved
enable flag is combined with its result. The VAR output is represented as a
one-word integer to match raw parent slot19; writes are0/1 and tests use the low
bit. Save updates the original mode nibbles and exits the parent. Cancel redraws
the bars and restores the saved bounds through22:50.

Procedure17 retains the two-word clock snapshot and the every-second-update
increment of byte119, including the `(work+1) MOD8` flag update. Input selector1
is always polled before checking the current state. On the later timed path,
the encounter threshold comes from the existing ten-word table's nibble3.
The random call precedes the money comparison. Interpreter NEQ type12 uses a
byte comparison over the supplied word count (`$DE62..$DE99`); comparing the two
words individually gives the same inequality here. The clear remains MOV2.

The fallback item search starts with random MOD3 but advances with AND3, so it
can visit all four byte slots. It retains local5's change from a rest value to
an item index and the original draw/swap call order. The timestamp advances
by60 after every timed iteration, regardless of whether anything was removed.
No new random filtering, termination guard, or division guard is introduced.

## Verification

At this checkpoint all106 bodies compiled without diagnostics using the existing
[fixture commands](game_18.md#validation-and-reproduction). The current fixture has83 for8:1 and93–100 for8:10–17;
the receipt records the current mapping. Parameter widths and lexical levels match the original
metadata. Local byte sizes (original -> recovered) are1:118->118,10:12->14,
11:0->4,12:0->0,13:16->0,14:44->32,15:8->8,16:18->20,17:18->22. Changes are
explicit call-order temporaries or omitted unused/oversized temporary storage;
none of these changed child frames has nested lexical consumers. The globals
remain912 bytes and parent storage remains at its original slots.

The [verifier](checks/verify_game_18.py) checks input-call ordering, aliased
arguments, bounds copies, substring call arguments, all three name-table
strides, save-hit ordering, both ancestor EXIT targets, money/clock copies,
the MOD3/AND3 search, and the complete parent entry/cleanup. All seven earlier
exact body matches still pass. No new exact-body or runtime-equivalence claim
is made. External data binding and native interfaces remain compile-only stand-ins.

Next: game18:23 and its remaining callers/dependencies. Assembly and disk-build
inputs are unchanged.
