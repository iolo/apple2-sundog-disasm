# Game12 tactical source recovery

All23 procedures are recovered directly from
[game_12.s](../../src/pcode/game_12.s), covering2,590 original instructions.
The [entry](../../src/pascal/game_12/proc_01.pas) includes all22 children, with16
nested inside15. It supplies game13's tactical dependency as reviewed source.

| Procedures | Reviewed behavior |
| --- | --- |
| 2–5 | Buffer toggling, guarded hull bar, six target glyphs, sensor caption, bounds and drawing modes. |
| 6 | Bounty calculation, captured system row, single-word credit, unconditional cargo chance and ordered packed cargo writes. |
| 7 | Both initial distance calls, disabled-weapon self exit, beam target arguments, hit/damage logic, target destruction, nibble update, bounty call and common charge clear. |
| 8 | Distance self exit, original angle normalization, native coordinate conversion, ordered VAR output writes and glyph draw. |
| 9 | Tactical setup, mode-dependent initialization, two random calls, parent-frame pointer construction, display setup, raw string address45 and coordinate markers. |
| 10/11 | Target movement, mandatory absolute-value calls, native viewscreen drawing, visibility updates and target marker toggling. |
| 12 | Joystick/automatic motion, two input0 polls, firing, cargo separation, marker erasure/redraw, two movement calls, periodic updates and low-bit target-state comparison. |
| 13–16/20 | Caption/bounds changes, conditional menu construction, nested item placement, aliased outputs and both release polls. |
| 17–19/21 | Manual firing, tractor loading, signed shield adjustment, jettison and pod display. |
| 22/23 | Communication transition packet and cloak enablement. |
| 1 | Tactical event loop, all16 menu cases, input priority, mode restoration and exit drawing. |

## Storage and observable order

[Types](../../src/pascal/game_12/types.pas) preserve the entry's94-byte frame,
slots1–47. Raw words share storage with the two-word cargo at34/35 and bounds
at37–40. The native drawing address in43 points at words44–47. Flags use bit0;
unused or conditionally initialized words remain uninitialized where the
original leaves them so. These views reuse established game19 system-row types;
include game19 types before game12 types.

Procedure6 adds bounty to only system-row word6, with16-bit wrap and no carry
into7. The system-row pointer is captured before printing and reused afterward.
The cargo probability call runs whether or not a bounty was granted, and each
packed field's destination is evaluated before its random range call.

Procedure7 computes both absolute distances before testing whether firing is
disabled. Its self exit skips the charge-clear tail. Every other path reaches
that tail, even if no target is present. The destruction loop clears flags41–47
before changing the target state and updating the current system's packed
nibble7. Procedure8 preserves output aliasing and exits before any coordinate
conversion when distance is at least28.

At original `$06FC..$06FD`, procedure9 pushes integer45 and calls library22:48,
whose argument is a string address. The source explicitly casts raw address45
through the otherwise temporary local3 and passes it to that string procedure.
It does not change the call to a glyph draw, invent a literal, or assume the
pointed-to bytes are valid text. A runtime binding must retain this raw memory
access. The original address-of44 operation still calls22:24, followed by22:23
to store the resulting address in parent43, on both setup branches.

Procedure10 reuses its two private value parameters after their motion values
have been consumed, saving both visibility predicates before branching. Thus
both original absolute-value calls run without enlarging its frame. Procedure12
keeps its motion words at local1/2 for the native joystick write and preserves
both separate input polls and movement calls; none are merged into a cached
result. The final target comparison still compiles as typed `NEQ6`.

## Raw overlay contracts

The [native declarations](../../src/pascal/game_12/native_interfaces.pas) describe
three targets of the already reviewed library22:25 trampoline. The original
[viewscreen overlay](../viewscreen-io.md) remains assembly:

- `$0800` consumes one pointer and reads its two mode bytes. The high byte
  suppresses speaker accesses when nonzero; the low byte selects the pattern.
- `$09D6` consumes one address value and reads bytes0/2/4/6 of four words into
  its native drawing parameters. Callers supply the value in parent43.
- `$0A73` consumes one pointer and writes two sign-extended motion words, Y
  first and X second, into the caller's contiguous locals1/2.

All three entry prologues remove the return and argument address, restore only
the return, and produce no Pascal result. The overlay's native input/output
accesses were checked against these contracts, and reassembly reproduces its
manifest hash. These are additional target contracts, not additional inventoried
native procedures. Loading, native effects, external storage and runtime binding
remain unimplemented by the compilation fixture.

## Validation

The initial temporary check reused existing library declarations and placed2–12
inside an empty94-byte parent. That parent (compiled115) was scaffolding and
did not count as entry1. Compiled116–126 mapped to original2–12 in order. All local sizes,
parameter sizes and lexical levels match, and all seven original captions
are retained. Source and emitted bodies were reviewed against every original
instruction path.

The reference compiler revision is
`397cf201ddf22ca25a82d0ad5401e5d70a38f849`, using
`--p-machine=ii.1 -f no-range-check -f no-efj-nfj`. Compilation has no warnings;
output SHA256 is
`714e1930563f2d17bf9a6819adc02c37b8eb1ad4476c65bbfd422eae74fe9e49`.
Focused emitted-code checks confirm the one-word bounty store, cargo argument
order, two self exits, raw beam argument addresses, raw string pointer45, both
parent44 address constructions, mandatory absolute calls, both input polls,
both movement calls and typed comparison. Original game12 and viewscreen-overlay
reassembly match their manifest hashes.

This temporary check is outside the two maintained compilation receipts. Both
existing verifiers still pass; their source and output hashes are unchanged.
No runtime execution or new exact-body equivalence is claimed. Original assembly,
native bodies, reconstruction inputs and disks remain unchanged.

## Complete tactical scope

The remaining12 bodies add1,090 reviewed instructions. Procedure13 always
snapshots the menu origin;14 skips that snapshot when flag35 is set. Procedure15
keeps the conditionally uninitialized shield-item slot and aliases both input
outputs. Its release loop saves both input calls in dead private slots1/2 so
short-circuit evaluation cannot omit either. Child16 retains its lexical access
to menu bounds in15's slots3/4/5 and copies its value caption before effects.

Procedure17 retains the additional input1 call and store immediately before
clearing manual mode. Procedure18 reads cargo kind before testing whether the
index is positive, including index0 at word232 when both pods are occupied.
Range checks must remain disabled for that access. Its tractor loop terminates
only at distance1, without adding a stop-flag test; loading copies both cargo
words before the caption and flag updates. Procedure19 performs signed16-bit
addition before clamping and stores the VAR value before updating its flag.

Procedure21 captures each pod address before sound/printing, preserves all
three packed writes without clearing the second cargo word, and always calls
the random primitive. Its first captured pointer uses private slot6 instead
of5; slot5 saves the random result, then the system-row address, then the display
bound. This changes no shared or address-exposed frame slot and preserves the
original10-byte local frame. Procedure22 retains byte truncation, marker order,
and the silent no-op for a present target with flag47 set.

Entry1 tests counter354's low bit, prioritizes input1, retains the additional
close-path poll, and reaches menu rebuilding only after a positive hit. All16
dispatch cases and cleanup branches were reviewed. It adds no segment loading:
game13 retains responsibility for the enclosing segment/overlay context.

`build/decompile/game_12/check.pas` now includes the actual game12 entry before
the actual game13 entry, replacing the former empty parent. Compiled115–137
map to game12:1–23;138–189 map to game13:1–52. All75 bodies are present, with no
game12 external substitute. All23 game12 local sizes, parameter sizes and lexical
levels match the originals, and all38 game12 literal occurrences are retained.
Source and emitted code for the12 additional bodies were reviewed against every
original path. Focused emitted checks cover aliased outputs, mandatory polls,
the cargo read-before-bound test, MOV2, pointer capture, unconditional random,
the entry's low-bit branch and game13's call to the recovered game12 entry.

With the same compiler revision/options above, the combined check compiles
without warnings. Its output SHA256 is
`7b6754bb163c93feba44c6b8ec360ae4eaedf57b1dbdad49999c5990567e21d9`.
Both maintained verifiers pass unchanged. This completes source recovery of
game12; native/runtime linkage and runtime behavior remain unvalidated.
