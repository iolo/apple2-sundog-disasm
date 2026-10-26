# Game 8 setup/restoration and clock dependencies

This group recovers game8:8/9/18 and library22:26–29/49/59/60. It adds ten
bodies and 714 original instructions, bringing coverage to 85 of 570 bodies
and 5,725 instructions. Native interface coverage remains 14 of 38.
Game8:1/3/4/10–17 and the full recovery inventory remain outstanding.

Component identities and assembly revision are unchanged from the
[condition-display group](game_8_condition.md) and [first group](game_18.md).
The source is recovered directly from the listings, without a new translator.

| Procedure | Entry through return | Attributes | Instructions | Source |
| --- | --- | --- | ---: | --- |
| 22:26 | `$028E..$02C1` | `$02CC` | 47 | [add_clock_minutes.pas](../../src/pascal/graphics_and_io/add_clock_minutes.pas) |
| 22:27 | `$02CE..$033B` | `$0346` | 76 | [clock_has_reached.pas](../../src/pascal/graphics_and_io/clock_has_reached.pas) |
| 22:28 | `$0362..$0394` | `$039E` | 38 | [draw_clock.pas](../../src/pascal/graphics_and_io/draw_clock.pas) |
| 22:29 | `$0450..$0572` | `$0582` | 180 | [advance_clock_and_conditions.pas](../../src/pascal/graphics_and_io/advance_clock_and_conditions.pas) |
| 22:49 | `$09DC..$0A27` | `$0A34` | 47 | [write_integer.pas](../../src/pascal/graphics_and_io/write_integer.pas) |
| 22:59 | `$0348..$0356` | `$0360` | 13 | [draw_two_digits.pas](../../src/pascal/graphics_and_io/draw_two_digits.pas) |
| 22:60 | `$03A0..$0443` | `$044E` | 109 | [update_hourly_condition.pas](../../src/pascal/graphics_and_io/update_hourly_condition.pas) |
| 8:8 | `$025A..$0368` | `$0376` | 139 | [setup_personal_panel.pas](../../src/pascal/personal_panel/setup_personal_panel.pas) |
| 8:9 | `$0378..$039E` | `$03A8` | 19 | [lift_inventory_item.pas](../../src/pascal/personal_panel/lift_inventory_item.pas) |
| 8:18 | `$0AF4..$0B48` | `$0B52` | 46 | [close_personal_panel.pas](../../src/pascal/personal_panel/close_personal_panel.pas) |

## Packed time and comparison

The new `clock4` view in [shared_game_state.pas](../../src/pascal/shared_game_state.pas) occupies
two words. Word0 holds minute in bits0..5, two untouched bits, and hour in
bits8..15; word1 holds day in bits0..13 and two untouched bits. DATASEG29 words
42/43 overlap this view. Bounds at word327 are another overlapping view within
the existing 760-byte allocation; no global storage was enlarged.

Procedure26 adds its signed elapsed argument to the minute field, stores
`carry MOD 60`, adds `carry DIV 60` to the hour, stores `carry MOD 24`, then
adds `carry DIV 24` to the day field. The original order, field widths, and
spare-bit preservation remain intact. No new range check, calendar library,
or alternate treatment of negative/overflowing arithmetic is introduced.

Procedure27 first copies its two-word value argument. It defaults to false,
exits on an earlier day/hour/minute, and returns true on a later or equal
timestamp. Each early EXIT remains a CSP4 targeting this function in the
checking fixture. It compares fields in order, not a synthesized scalar date.

Procedure28 also copies the incoming value before effects. It selects mode 3,
draws the day modulo 1000, a tilde, the hour, a colon, and the minute. Nested59
draws two decimal characters using DIV/MOD 10; it adds no validity checks for
out-of-range packed values. The caller's drawing mode is not restored.

## Hour and condition updates

Procedure29 resets external word 354, captures the current hour, and advances
the clock by external word 351. If word 329 is positive it draws the updated time
in bounds327. Only then does it compare the captured hour with the current hour.
Its update loop advances that captured value modulo 24 until the hour fields
match. It does not count elapsed days: an exact 24-hour advance with the same
hour field performs no condition iterations. This original behavior is retained.

Each iteration initializes parent slots 2/3/6, then calls nested60 three times
with the exact four-byte tables `4234`, `1000`, and `1123`. Nested60 copies its
table before reading external storage. It applies the indexed rate unless
selector 1 and flag 59 suppress it, applies selector 2's extra change only above
128, clamps to 0..255, and updates the original state nibbles/word 347 on exhausted
selector 1. It then stores the byte and updates the parent's adjustment and sum.
The nested call order and parent slots 2/3/6 are preserved.

The outer body adjusts condition byte 0, sets nibble2 to 12 and word 347 to 1 if it
is exhausted, and updates five attribute bytes toward their respective targets
with signed per-byte steps. Both absolute-value calls execute before comparing
step size. It then increments the old hour modulo 24 and sets flag 60. Loads and
stores remain in their original order; no early exit is added after exhaustion.

Procedure49 supports game8's later attribute display. It formats a number
through38, chooses a one-character prefix, captures the original string length
and requested width, prepends in a counted loop, and sends the result through48.
This differs from39's repeated length comparison. Capacity 15 and the original
string-assignment failure behavior remain unchanged; width is not clamped.

## Game 8 state

Procedure8 copies the current bounds into parent slots30..33, saves external
351/353 in parent21/20, then sets those globals to 1/15. In mode 2 it derives the
parent's two scalar arguments from word40 and word41's low byte. It preserves
the separate decrement/increment loops bounding the first argument to 11..19,
then rounds an even value upward using a low-bit test.

The routine opens the window, derives DATASEG31 origins, builds library27's
item table, initializes the parent's display/button bounds, draws the condition
display, obtains input coordinates, and clears parent19. Bound calculations and
all calls retain their original order. It is a recovered child of the still
unrecovered game8 entry, not a standalone initialized screen.

Procedure9 draws the selected marker, swaps drawing state, writes parent5/4,
calls library27:7 with the original parent VAR addresses, then swaps state again.
Procedure18 redraws the input marker, closes the window, updates state nibbles
in order, restores the saved bounds with MOV4, and restores external351/353.
Its nibble reads remain after the preceding writes and effectful calls.

## Verification and next work

All 85 bodies compile without diagnostics. All parameter widths and lexical
levels match source metadata. The clock updater and nested60 retain 16/12-byte
local frames; formatter49 retains 42 bytes. Procedure26 omits the redundant
local VAR-address copy (two locals instead of four bytes);27 omits an unused
word (four instead of six); game8:8 omits an unused word (two instead of four).
Game8's lexical parent remains 118 bytes. The global fixture remains 912 bytes.

At this group's checkpoint, the [fixture](checks/game_18_compile.pas) placed game8 after its recovered
library27 dependencies. Current IDs are in the [receipt](checks/game_18_receipt.json):
native interfaces 68–70, new clock/text bodies 88–94, game8 wrapper 95 and children
96–102. Earlier game18 IDs are unchanged. The five substantive exact body
matches and library27:1's two-byte return match still pass.

The [verifier](checks/verify_game_18.py) checks packed store widths/offsets,
value-copy prefixes, all three rate tables, nested-frame accesses, clock-loop
increment/flag order, three function EXITs, and game8 bounds save/restore and
low-bit rounding. These checks supplement direct path review; they do not prove
general equivalence or execute the game. Use the existing
[reproduction commands](game_18.md#validation-and-reproduction).

Game8:3 depends on library24:9, whose callers lead into the larger condition and
world-update routines24:12/13/15. Those bodies and their required declarations
are the next dependency group. No placeholder library24 implementation has
been supplied to make game8's unrecovered callers compile.

Later groups move game8 after library24: its entry is now107, the earlier
children are108–114, and new3/4 are115/116. Use the current receipt for mappings.

The [completion group](game_8_complete.md) replaces the empty game8 parent with
its recovered body and adds the remaining children at117–124.
