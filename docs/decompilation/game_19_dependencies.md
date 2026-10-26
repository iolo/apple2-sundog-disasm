# Game19 menu and amount dependencies

This group recovers 23 bodies and 1,145 original instructions: all9 library25
bodies (573 instructions), all6 library28 bodies (181), library22:36 (39), and
game19:2–6,8,26 (352). Overall coverage is151 of570 targeted bodies and12,710
instructions. Game19's other19 bodies, including its entry, remain outstanding.

The source was recovered directly from the listings. Component identities,
procedure offsets, and the assembly revision are in the
[inventory](inventory.json). Reassembled inputs match these manifest hashes:

| Component | SHA256 |
| --- | --- |
| library25 | `16048527422b435b2f6e811d3abddade3318f4570746a2e8e5b1419d16c9a4b3` |
| library28 | `c8054603d64cdcafa4cfdee95ab756aeb94ac26545b2a42888edd98e59d0d960` |
| game19 | `9005760c7e42480562e06ce711baa4cd6edd2376bb46d8866af74b8461eb7b2f` |

## Menu storage and interfaces

[Library25](../../src/pascal/library_25/) uses DATASEG30, whose342-byte allocation
is recorded in library header slot9 (`docs/pascal-inventory.json`, kind7).
Its [types](../../src/pascal/library_25/types.pas) retain these exact offsets:

- Words1–64: eight16-byte caption slots (`string[15]`).
- Words65/66: caption count and item count.
- Words67–171:21 five-word items. Word0 has code bits0–7, button bit8,
  caption-index bits9–12, and three spare bits. Words1–4 are a bounds record
  for buttons; sprites use word1 as image code and words3/2 as coordinates.

Procedure2 clears counts only. Procedure3 copies its string argument before
changing counts, saturates the counts at8 and21, and overwrites the last slot
when full. Existing entries referring to the last caption therefore see its
replacement. Procedure4 sets sprite fields without clearing the caption-index
bits, spare bits, or unused last word. Procedure5 tests only the upper bound
and writes the previous code to its VAR output before changing the packed code.
No extra lower-bound validation or table-capacity rejection was added.

Procedure6 copies its bounds value, snapshots the item count, and renders each
entry. Nested9 reads parent slots6/7 for coordinate offsets and writes slots8/9
for caption placement. The recovered parent retains that layout. Nested9 uses
the recorded bounds and caption length for the original integer centering
calculation, including signed division and the two-pixel border.

Procedure7 clears the found-index output before the code output. On a hit it
stores code before index, and its loop rereads the found output. The sprite
path invokes both absolute-value routines before combining their results;
the button path retains inclusive bounds and the two-unit second-coordinate
tolerance. Those stores and rereads remain meaningful when outputs alias.

Procedure8 retains its unused VAR code argument. A button writes input0=1,
then input1=0, draws the button, and returns. A sprite instead copies the area
bounds, captures the item, increments the shared tick, draws, and runs the
original0..70 delay loop. It stores both input calls in order and rereads both
outputs before deciding whether to repeat. Cleanup tests the low bit of the
flash count, not whether that count is nonzero. The busy-loop expression is
still present in compiled p-code; exact wall-clock timing is unverified.

Library25:1 and library28:1 really contain only RNP0. Their empty Pascal entries
are recovered original behavior, not placeholders for missing code.

## Two-word arithmetic

[Library28](../../src/pascal/library_28/) operates on the existing `wordpair`
view: first is the high part and second is the low part. Procedure2 copies the
value argument before any writes to the VAR accumulator, preserving aliases.
It adds low parts, performs MOD1000, explicitly restores the sign, updates the
high part using DIV1000, then executes both sign-normalization branches in
their original order. Procedure3 negates the low word before the high word
and calls2. Procedure4 similarly keeps sign multiplication around MOD1000.

This sign handling follows the supplied interpreter. `$D7F0..$D81C` takes
operand magnitudes for division; MOD at `$D8AA..$D8BF` returns the remainder
without the quotient sign restoration used by DIV at `$D88C..$D89F`.
The source retains those p-code operations and16-bit intermediate arithmetic;
it does not replace them with a host-wide amount or assume host `%` semantics.

Procedure5 preserves the caption/value copies and the original three formatting
paths for zero, positive, and negative high parts. Procedure6 performs a strict
lexicographic comparison of the signed words; equality returns false.

[Library22:36](../../src/pascal/library_22/proc_36.pas) accumulates successive
odd numbers, uses native31 for a shift, and applies the original rounding test.
Its16-bit overflow behavior and termination conditions are retained. No generic
square-root implementation or numerical repair was introduced.

## Game19 helpers

[The game19 sources](../../src/pascal/game_19/) currently include:

| Procedure | Recovered behavior |
| --- | --- |
| 2 | Single-button setup and activation; deliberately supplies parent29 as both input outputs to library25:8. |
| 3 | Menu rendering/input loop, conditional selector1 polling, hit lookup, activation, and ordered VAR result stores. |
| 4 | One/two/three-button layout with the original divisor, endpoints, and copied captions. |
| 5 | Capture a system row, select/copy two-word amounts, then add the current money pair. |
| 6 | Compare the row amount with parent8/9 and transfer/subtract amounts through the original branches. |
| 8 | Copy a selected city/planet/system name using6/8/10-word strides; other selectors leave output unchanged. |
| 26 | Set up bounds, save shared rates, clear the parent amount, and read three system-row nibbles. |

The56-byte parent view preserves slots2–29; wordpairs overlay8/9 and10/11.
System rows are20 bytes, reached through the pointer in DATASEG29 word23.
Their amount occupies words6/7 and nibble fields start at8. These views share
the existing name/table memory, not separate copies. Procedure6's original
four-byte EQU12 comparison is expressed as two word-equality tests with no
intervening effects. MOV2 source/destination directions were reviewed explicitly.

## Validation and next work

All151 recovered bodies compile without diagnostics using the
[existing compiler and commands](game_18.md#validation-and-reproduction).
DATASEG30 is appended to the fixture after29/31, keeping their original fixture
offsets stable. Global storage is now1,254 bytes:760+152+342. DATASEG30 begins
at global slot459, with counts523/524 and entries525.

New compiled procedures are148=library22:36,149–154=library28:1–6,
155–163=library25 (nested9 at161). Game19 parent164 is an explicitly empty
compile-only scope, excluded from recovery counts; its children165–171 map
to2/3/4/5/6/8/26. Parameter sizes and lexical levels agree with original metadata.
Changed leaf-local sizes have no nested consumers; library25:6 retains22 local
bytes and the reviewed nested-variable offsets.

The [receipt](checks/game_18_receipt.json) pins hashes, frames, mapping, and
instruction counts. The [verifier](checks/verify_game_18.py) checks value-copy
prefixes, arithmetic operations, packed stores, table limits, nested access,
both distance calls, ordered aliased outputs, delay-loop instructions, flash
parity, duplicate parent29 addresses, and amount-copy directions. Seven earlier
exact body matches still pass. No new native interfaces were needed.

No runtime execution, complete game19 recovery, or general equivalence proof is
claimed. Next recover game19's location-record/distance routines10/11 and their
callers, then its remaining menus and enclosing entry. Its entry contains
segment load/release operations and a release epilogue that still need review.

The subsequent [completion group](game_19_complete.md) recovers all remaining
game19 bodies and reviews its segment lifecycle. The counts above describe
this earlier dependency checkpoint.
