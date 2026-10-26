# Game19 transport, banking, depot, and entry

All 26 game19 p-code bodies are now recovered directly from the assembly,
covering 2,483 original instructions. This group adds 19 bodies and 2,131
instructions to the [seven reviewed helpers](game_19_dependencies.md).
Overall coverage at this checkpoint is 170 of 570 targeted bodies and 14,841
instructions. Runtime execution remains untested.

The [entry](../../src/pascal/game_19/proc_01.pas) supplies the enclosing frame
and includes every child. The component remains SHA-256
`9005760c7e42480562e06ce711baa4cd6edd2376bb46d8866af74b8461eb7b2f`.
The [inventory](inventory.json) records procedure offsets, assembly revision,
source paths, and validation status.

| Procedures | Recovered behavior |
| --- | --- |
| 7 | Amount selection, available-balance updates, clear, and commit. |
| 9 | Two-column location menu with six-entry paging and excluded entry. |
| 10–11 | Six-word location construction and three distance calculations. |
| 12–15 | Destination display, cost/arrival time, transport, and station menu. |
| 16–17 | Inter-system transfers and bank deposit/withdrawal menu. |
| 18–19 | Unit purchase loop and nested quantity/cash display. |
| 20–23 | Refuelling and repair prices, including nested integer scaling. |
| 24–25 | Auxiliary fuel purchase and depot menu. |
| 1 | Segment loads, setup, menu dispatch, normal cleanup, and releases. |

## Storage and control flow

Procedure10 copies all six location words before selective packed writes.
Table lookups use the stored packed indices, including their truncation, rather
than the original integer argument. System, planet, and city row strides remain
10, 8, and 6 words. Spare bits, word4, and the two bytes of word5 remain distinct.
Procedure11 keeps 16-bit squared differences and addition. Its planet-coordinate
wrap correction is strictly greater than128; other selectors use three system
nibbles and the existing integer square-root routine.

Procedure7 commits the selected amount even when its menu is cancelled. CLEAR
reloads the available VAR argument rather than an invented initial snapshot.
Procedure9 toggles columns only for included entries and retains its original
exit predicate: zero can end selection. Procedure15 dispatches the selected
code before testing its cancel flag, and only invokes transport for a positive
destination. No additional validation or rollback was introduced.

Procedure12 retains shared slots8..28 for its nested display and price helpers.
It snapshots timeout before calling both input selectors0 and1 unconditionally,
including the timeout iteration. Its travel loop advances time at least once,
then checks the arrival time. The final six-word copy follows the arrival flag
updates. Procedure14 computes the delay base before the random call and retains
the original MOD60 expression.

The bank retains the system-row address captured at entry through its final
balance store. Transfer16 captures its target row after the amount picker,
then retains that address through the addition and writeback. Withdraw and
transfer buttons share the same positive-bank-balance gate.

Bank17 and depot25 build headings using the original capacity9 name append.
SYSTEM_CORE23 at `$05F2..$0615` skips an entire append when the combined length
exceeds capacity. The Pascal therefore copies the name only if its length is
at most9, then appends the suffix. Longer names yield just ` Bank` or ` Depot`;
they are not truncated. The resulting lengths fit the original second capacities
14 and15. The reference compiler uses a larger temporary for `concat`; the
guard guarantees the same visible string content.

Purchase18 preserves both input polling sites. The inner stop predicate is
captured before the input call; the outer input call executes even when another
exit condition already holds. Nested19 always compares price and cash after
capturing the zero-quantity predicate. Uppercasing subtracts32 from each byte;
it does not use a character-class conversion. The quantity cap occurs after
charging and before decrementing the remaining count, as in the listing.

The four value-string copies in18 occupy slots7..38. The reference compiler
orders them as all-text7, item15, verb23, unit31, unlike the original order.
All generated uses, including nested19's unit-name access, follow those copies;
shared cost/quantity/display slots39..46 remain unchanged. There is no evidenced
physical-frame dependency on these string offsets. Extra polling temporaries
follow the original locals.

Repair scaling23 retains the `32767 div factor <= value` threshold and both
division orders, with no widened arithmetic or invented divisor guards.
Repair21 reads and writes byte192 relative to DATASEG29 word90 (absolute
byte370). Fuel20 keeps the original post-call MOD16 and upper-only clamp.
Auxiliary fuel24 scans two stock entries, fills only empty ones, writes the
caption then category bits5..7, origin byte, and kind bits0..4 in that order,
and leaves the second stock word untouched.

## Entry and validation limits

The recovered parent has the original56 local bytes and one scalar parameter.
It loads25 then28, calls setup26, and dispatches station15, bank17, or depot25.
Its normal path restores globals353/351, invokes cleanup22:52, and releases28
then25. The original exit attribute points to `$13FB`, the release epilogue.
The compilation fixture's exit points to RNP; its external segment operations
still require runtime bindings that preserve nonlocal-exit release behavior.

All 170 recovered bodies compile without diagnostics using the pinned compiler
and options in [the reproduction instructions](game_18.md). The existing
verifier passes source/output hashes, parameter sizes and lexical levels,
seven previously established exact bodies, and focused regressions. New checks
cover location copies/packed writes, timeout polling, random-call order,
captured bank writeback, purchase polling and stores, nested display access,
stock writes, and segment lifecycle order. They do not establish general
semantic equivalence or runtime behavior. Existing assembly, native source,
reconstruction inputs, and decoder tools were not changed.

Next: game20 and the dependencies required by its callers. The full inventory
still has 400 outstanding p-code bodies and 22 unreviewed native interfaces.
