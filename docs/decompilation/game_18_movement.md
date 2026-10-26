# Movement and initialization recovery

This group recovers five more Pascal bodies directly from the listings. It uses
the component hashes and assembly revision in the [first group](game_18.md).
Native procedure 22 receives an interface declaration; its assembly body is
preserved. No decompiler, replacement movement engine, or emulator was built.

| Procedure | Entry through return | Attributes | Instructions | Pascal |
| --- | --- | --- | ---: | --- |
| game 18:12 | `$0498..$075D` | `$0778` | 508 | [proc_12.pas](../../src/pascal/game_18/proc_12.pas) |
| game 18:13 | `$077A..$08FA` | `$0906` | 290 | [proc_13.pas](../../src/pascal/game_18/proc_13.pas) |
| game 18:14 | `$0908..$0AB3` | `$0AC0` | 288 | [proc_14.pas](../../src/pascal/game_18/proc_14.pas) |
| library 22:35 | `$05A8..$05B6` | `$05C0` | 11 | [proc_35.pas](../../src/pascal/library_22/proc_35.pas) |
| library 22:41 | `$06FA..$070E` | `$0718` | 14 | [proc_41.pas](../../src/pascal/library_22/proc_41.pas) |

## Library dependencies

Library 22:35 compares its signed argument with zero and conditionally negates
it. The source retains these operations rather than introducing host absolute
value semantics or saturation. Its result is in slot 1, its argument in slot 3,
and its parameter area is six bytes including reserved result storage.

Library 22:41 takes two integers, selects mode 1, sets the position to
`firstpos - 3, secondpos + 3`, calls native 9 using external word 374, and
selects mode 0. The load of word 374 remains after the position call, which can
invoke native drawing. No saved-mode restoration is added.

Native 22:22 at `$14FE..$1507` pops 14 bytes: the return address and six words.
The last two words are pointers in `$18/$19` and `$1A/$1B`. The preceding step
words occupy `$1C..$1F`, and the two code words occupy `$20..$23`. This agrees
with game 18:12's argument construction at `$0511..$0525`: code bytes from
entry word 6, two scalar steps, then addresses of entry words 5 and 4.

The native body reads and writes through those pointers at `$1551`, `$1559`,
and `$1583..$1594`. It updates only the low byte through the second-position
pointer and both bytes through the first-position pointer; the declaration's
VAR integer types preserve the storage addresses, without replacing the native
implementation with full-word arithmetic. It calls native 9 and changes
external storage. `$1542..$1548` restores the return address without a result.

## Procedure 12: movement and arrival paths

The WITH pointer at `$0498..$049E` is retained across all calls. The first test
compares current entry words 5/4 with target words 1/0. If they differ, the
routine derives signed steps by signum, doubling, and conditional reduction
using procedure 35. Arithmetic order and signed comparisons are retained,
including their 16-bit overflow behavior; no distance clamp was substituted.

Index 1 receives an initial call to 41, a movement attempt, then another attempt
using zero steps for coordinates already changed and signum for the others.
Other entries retry only when neither coordinate changed. Calls to 41 surround
that second movement attempt. Coordinate comparisons and code-byte loads stay
after intervening calls where the assembly rereads them.

If both attempts leave another entry unchanged, type 3 plus a successful bounds
test copies the current position to both target pairs. The bounds function is
called on either type value; it only reads its copied arguments. Otherwise,
the random function's **low bit** chooses between offset updates and calls to
procedures 10/11. Interpreter `false_jump` at `$D2A0..$D2A6` explicitly masks
with 1. A nonzero test would misread even random values. The flag deciding
whether to call 11 is reread after 10.

All moving paths join `$0643` and return. The stationary path at `$0645` either
copies the secondary target into the primary target or handles arrival. Arrival
clears bit 5 and at most one parent reference (slot 124 takes precedence over
123). The high-byte cases retain their separate effects:

- 1 copies entry 1's coordinates to the secondary target and sets bit 5.
- 2 removes the entry through procedure 6 and immediately reaches the return.
- 3 changes flags, clears entry byte 18, increments parent slot 125, and clears
  the high byte.
- Values at least 4 set bit 2, optionally inspect the neighboring packed
  reference, set parent slots 116/141 and external byte 550, then clear the
  high byte. Values 0 and unhandled values receive no invented action.

The eight jump-table words at `$0760..$076E` were checked against their targets;
they are not additional executable instructions.

## Procedure 13: placement and early exits

The interface is `(VAR index: integer; initially_placed: boolean)`: slot 1 holds
the Boolean, and slot 2 holds the index address. The entry pointer is captured
after the initial upper-limit check. If the check fails, the routine stores -1
and exits without initializing an entry.

Random calls remain separate and ordered. The initially-placed path invokes
procedure 9, exits on a zero counter, and otherwise initializes both coordinate
pairs, flags, and a random byte. The other path tries procedure 8 conditionally,
then 9 on failure, then 8 again on failure. It always performs the final
collision call, even when the counter is already zero. Explicit Boolean
temporaries prevent the reference compiler's short-circuit OR from suppressing
that call and preserve the failed-counter predicate evaluated before it.

Failure-store order differs between the two paths and is retained. Both paths
keep their CSP EXIT operations. Successful placement alone reaches the common
tail at `$08E8`, sets word 6's two code bytes, and calls procedure 4. No inferred
repair of failed placement or cleanup of previous random effects was added.

## Procedure 14: initialization and fill

CSP selector 10 dispatches through `$D114` to the fill routine at `$E68A`.
That handler consumes a fill byte, byte count, byte offset, and base pointer.
The recovered `fillchar(g18items, 180, 0)` recompiles to the original argument
sequence, clearing exactly nine 20-byte records starting at parent slot 5.

A new variant view exposes external word 45's bits 12 and 13. Initialization
copies bit 13 to bit 12, then clears bit 13 without disturbing other bits. In
the compile fixture, external word 45 maps to global slot 47 because stand-in
storage begins at slot 3. The compiled packed operations use that address and
the original bit offsets; total DATASEG29 storage remains 760 bytes.

After drawing entry 1, parent flag 142 is reread. The early-exit path sets the
maximum to 1 and clears reference 124. Otherwise, the initialization loop
rereads the maximum each iteration. Failed procedure-13 placement decreases the
maximum without advancing the cursor; success advances the cursor. A Pascal
FOR loop with a captured limit would change this behavior.

Entry 0 uses entry 2's position when available. Otherwise it makes two ordered
range calls with the exact original argument order. In particular, the first
call passes parent slots 109 then 110; these are named `upper_first` and
`lower_first` by the bounds-test storage view. They are not silently reordered
to satisfy a guessed range invariant. Flag/code stores and the final draw are
retained in both cases.

## Verification and limits

The [compile fixture](checks/game_18_compile.pas) now includes 25 recovered
bodies and five native interfaces. Compilation succeeds without diagnostics.
All 25 parameter byte counts and lexical levels match the original metadata.
The parent still has 298 local bytes; entry stride and global storage sizes
remain unchanged. Local temporary sizes differ where explicit evaluation-order
temporaries were introduced. Names and full game meanings remain provisional.

Library 22:35 reproduces 16 exact body bytes, `$05A8..$05B7`, including the
RNP operand, with SHA-256
`2b548a520df530c9e2150f59bb51147e6acdaad336737e454bd214cd062a4479`.
The previous exact body matches for 22:34 and 22:58 still pass. These comparisons
exclude procedure attributes and dictionaries.

The [receipt](checks/game_18_receipt.json) records current source/output hashes,
frames, and procedure mappings. The [focused verifier](checks/verify_game_18.py)
checks the existing two-call regression, the new unconditional collision call,
low-bit random branch, 180-byte fill, and all five CSP EXIT sites in recovered
procedures 10, 13, and 14. Reproduction commands remain in the
[first group](game_18.md#validation-and-reproduction).

Static review assumes valid caller storage and the evidenced native interfaces.
The fixture is compile-only, with unlinked native declarations and an empty
parent body. Runtime behavior, arbitrary invalid indices, and whole-module or
gameplay equivalence have not been validated.
