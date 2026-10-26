# Entry management, placement, and library dependencies

This extends the [first recovery group](game_18.md) using the same component
hashes and assembly revision. Fourteen additional p-code bodies are recovered
directly from assembly, plus native interfaces 22:3, 22:9, and 22:56. Together
the two groups contain 20 recovered bodies and 1,016 original instructions.

| Procedure | Entry through return | Attributes | Instructions | Source |
| --- | --- | --- | ---: | --- |
| game 18:3 | `$0022..$0034` | `$003E` | 10 | [proc_03.pas](../../src/pascal/game_18/proc_03.pas) |
| game 18:4 | `$0040..$005C` | `$0066` | 18 | [proc_04.pas](../../src/pascal/game_18/proc_04.pas) |
| game 18:6 | `$0122..$019F` | `$01AC` | 67 | [proc_06.pas](../../src/pascal/game_18/proc_06.pas) |
| game 18:7 | `$00F2..$0115` | `$0120` | 26 | [proc_07.pas](../../src/pascal/game_18/proc_07.pas) |
| game 18:8 | `$01AE..$0316` | `$0328` | 250 | [proc_08.pas](../../src/pascal/game_18/proc_08.pas) |
| game 18:9 | `$032A..$03A9` | `$03B6` | 93 | [proc_09.pas](../../src/pascal/game_18/proc_09.pas) |
| game 18:10 | `$03B8..$040D` | `$0418` | 62 | [proc_10.pas](../../src/pascal/game_18/proc_10.pas) |
| game 18:11 | `$041A..$048C` | `$0496` | 82 | [proc_11.pas](../../src/pascal/game_18/proc_11.pas) |
| library 22:11 | `$0052..$007C` | `$0086` | 19 | [proc_11.pas](../../src/pascal/library_22/proc_11.pas) |
| library 22:12 | `$016C..$018A` | `$0194` | 14 | [proc_12.pas](../../src/pascal/library_22/proc_12.pas) |
| library 22:34 | `$0584..$059C` | `$05A6` | 18 | [proc_34.pas](../../src/pascal/library_22/proc_34.pas) |
| library 22:40 | `$06C0..$06CE` | `$06D8` | 13 | [proc_40.pas](../../src/pascal/library_22/proc_40.pas) |
| library 22:57 | `$00F4..$015F` | `$016A` | 80 | [proc_57.pas](../../src/pascal/library_22/proc_57.pas) |
| library 22:58 | `$00BE..$00E8` | `$00F2` | 23 | [proc_58.pas](../../src/pascal/library_22/proc_58.pas) |

## Library calls and native interfaces

Library 22:11 stores its argument in external word 367 and selects word 357:
mode 3 gives 63, mode 0 gives 255, other modes give zero. Procedure 12 calls
57 on the old/new coordinate pairs only if external word 366 is positive,
then stores its own arguments in words 365 and 364. Those stores stay after
the effectful drawing call.

Procedure 57 subtracts the start/end coordinates, conditionally negates each
difference, chooses a major axis using a strict greater-than comparison, and
selects each step from the original start/end ordering. Its nested procedure
58 sets parent slots 5..12. Those slots become the first eight arguments to
native 56; the ninth word is the axis Boolean. The signed operations are kept
in their original order, including the two subtractions used to form the
diagonal increment. The unused parent slot 15 is retained to keep lexical
offsets exact. There is no replacement native plotting loop.

Procedure 34 implements signed signum. Procedure 40 returns
`lower + random mod ((upper - lower) + 1)`, retaining the original order of
subtraction, addition, and modulo. No invalid-range behavior is repaired or
silently clamped. The compiler needs a separate assignment to call a bare
parameterless external function before MOD; otherwise it diagnoses a function
value rather than an integer. The temporary in the recovered source captures
one random call before the divisor calculation. The native call only modifies
its external seed storage, not the scalar bounds parameters.

The [native interface declarations](../../src/pascal/library_22/native_interfaces.pas)
are supported by these stack operations:

- **22:3**, entry `$0BF6`: removes the return address and four reserved result
  bytes. It updates global-relative `$0028..$002B` (external words 21..22), then
  `$0C1F..$0C27` pushes a high byte shifted right once and a low byte. It returns
  one nonnegative integer and has no explicit arguments. Calls must remain
  ordered and cannot be folded or reused.
- **22:9**, entry `$1376`: removes a return address and one argument word,
  retaining the low argument byte. No result is pushed. In mode 2 the path
  `$1470..$14BC` clears both bytes of external word 1 and sets its low byte
  once on the first hit; its result flag is canonical 0/1. Other modes perform
  drawing and position updates. The original native body is preserved.
- **22:56**, entry `$112A`: a 20-byte pop loop consumes its return address and
  nine argument words into zero page `$10..$23`. The final argument is the
  axis flag. It calls the existing native drawing code and restores only the
  return address before RTS. There is no Pascal result.

## Entry removal and nested reference adjustment

Game 18:3 selects mode 2, sets the position through 22:12, calls native 22:9,
and returns external word 1 as Boolean. `odd` states the intended Boolean view;
the compiler emits a direct word load/store, matching the original result path.
Game 18:4 selects mode 1 and uses entry words 5/4 and word 6's upper byte.

Game 18:6 calls 4 before reading external byte 550. That address is
`2*(271-1)+10`, exactly the original `LAE 29,271; SLDC 10; LDB/STB`.
It clears/decrements this byte according to its comparison with the removed
index, and rereads it into parent slot 147. It captures parent slot 132 as a
loop limit, copies successive 10-word entries left with MOV 10, and calls
procedure 5 after each copy. Pascal record assignment recompiles to MOV 10,
preserving all variant views and unused bits. The copied records are adjacent,
non-overlapping 20-byte records in the ordinary valid caller context.

Nested procedure 7 retains lexical level 3. Its VAR argument is set to zero
if it equals the removed index or exceeds the parent's old maximum; otherwise
it is decremented if greater than the removed index. Procedure 6 calls it on
parent slots 124 and 123, in that order, before decrementing slot 132. The
compiler still emits `LOD 1,1` and `LOD 2,132` in the nested body.

## Placement paths and effect ordering

Procedure 8 has one scalar argument and three VAR words. It initializes the
result to zero, respects parent flag 139, selects a row/column from either
entry 1 or two separate random calls, and searches the packed reference grid.
The original `available >= 0` condition and decrement-before-advance order
remain intact. A candidate region receives up to two collision trials, with
the same first/second coordinate stores and column toggle on a hit. On success
it stores the encoded row/column, updates the reference grid, and conditionally
sets entry flags/word-8 bytes. Its unused constant local at `$01BA` is omitted.

Procedure 9 initializes a ten-attempt counter through a VAR argument. It derives
offsets using 22:34, chooses coordinates using two ordered calls to 22:40,
decrements the counter, and performs **both** calls to 18:3 in each trial.
Boolean temporaries force those two calls to occur before OR/NOT; the second
call rereads VAR arguments after the first call. Short-circuiting the calls
would change native effects and was deliberately avoided. The loop stops on
no hits or an exhausted counter. The final entry-byte update only occurs while
the counter is still positive, as in `$0397..$03A8`.

Procedure 10 captures the entry pointer, chooses procedure 8 or 9 using bit 3,
and exits if the returned counter is zero. CSP 4 dispatches through `$D108`
to `$E75C`; its handler selects the exit of the given segment/procedure.
`exit(proc18_10)` recompiles to that operation with the fixture's segment and
procedure numbers. The remaining word updates and call to procedure 5 preserve
their order. Procedure 11 likewise retains its flag/word stores, conditional
parent-counter update, and final call to 5.

The added storage overlays expose entry word 6 and 8 as packed byte pairs and
DATASEG29 as 760 bytes. They do not allocate separate copies. The compiler still
allocates 20 bytes per entry, 298 parent-local bytes, and 760 external-data
stand-in bytes. Original record names and full game meanings remain unknown.

## Verification

Use the [existing compile commands](game_18.md#validation-and-reproduction) and
the expanded [fixture](checks/game_18_compile.pas). All 20 bodies compile without
diagnostics. The [current receipt](checks/game_18_receipt.json) identifies every
compiled procedure and source hash. All 20 parameter byte counts and lexical
levels were compared with original procedure metadata. The original local sizes
are retained where needed for nested access; elsewhere unused locals are omitted
or explicit temporaries added.

Two comparisons achieved exact body bytes, from entry through RNP's operand:

| Original body | Bytes | SHA-256 |
| --- | ---: | --- |
| Library 22:58 `$00BE..$00E9` | 44 | `f8f09a229401d75200426872614280eb5b9d97e99c61305e0f6bf596cefa95b8` |
| Library 22:34 `$0584..$059D` | 26 | `8638c2a3b681369f190052c4c8116a7e461ebd24a53ca8a5e57f472ca3edd8ec` |

These comparisons exclude attributes, dictionary entries, and wrapper layout.
They are not exact module/disk rebuild claims. For other bodies, reviewed
differences include fixture call/global addresses, index multiplication before
IXA 1 instead of IXA 10, pure-test short-circuiting, unused locals, and the
explicit random/result temporaries. Both collision calls, packed fields,
MOV 10, lexical accesses, and the CSP EXIT target were checked in disassembly.
There has been no Pascal runtime execution or gameplay-equivalence validation.
