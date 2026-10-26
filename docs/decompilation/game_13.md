# Game13 complete source recovery

All52 procedures are recovered directly from
[game_13.s](../../src/pcode/game_13.s), covering4,854 original instructions.
The [entry](../../src/pascal/game_13/proc_01.pas) includes the complete systems,
map, travel and menu scopes. Tactical game12's [complete recovery](game_12.md)
now supplies its dependency; a combined compilation includes both actual scopes.
No decompiler or new translation tooling was added.

| Procedures | Reviewed behavior |
| --- | --- |
| 1 | Load12/25, setup, shared menu frame, tactical call, mode/flag writes, screen restoration, and release25/12 epilogue. |
| 2 | Save four random-state bytes, install system-derived seed bytes, fill256 bytes at2816, and restore the saved state. Destination/index evaluation precedes each random call. |
| 3/6/11 | Setup, display, polling, cleanup in order; preserve the42-byte parent frame, rates, bounds, packed modes and flags. Child10's self EXIT still returns to cleanup11. |
| 4/5 | Clear with spaces until word18 changes; position and draw using packed coordinates and native24:4. The glyph code is reread after positioning. |
| 7 | Seven status bars from28-byte rows, independent upper/lower fills, gaps after indices2/5, and original bounds restoration. |
| 8/9 | Packed location rendering, captured name pointer, original20/16-byte name strides, exact captions and spaces, charge/engine/rescue display state. |
| 10 | Conditional clock update, two input1 polls, low-bit comparisons, charge transitions and display erasure. The first poll can exit before updates; the second executes before the final stop test. |
| 12/13 | Map dispatcher, shared selection frame, saved flag21, two self exits, raw redraw flag, location comparisons and temporary warp flag during redraw. |
| 14–17 | System, planet and city rendering, complete location/planet copies, shared selection ranges, captured row pointers, conditional markers and original coordinate conversions. |
| 18/19 | Selection shortcuts, mandatory planet-count read, cursor polling/toggling, caption dispatch, confirmation timeout and cursor restoration. |
| 20–23 | Exact system/planet/city captions, coordinate order, current-location/destination annotations, and retained row addresses across display calls. |
| 24–26 | Full location clear, packed index truncation and rereads, planet/orbit selection, city access decisions, ordered random calls and retained writes after rejection. |
| 27–34 | Complete travel dispatcher, value-caption copies, reason-code messages, overlay caching, warp cost/failure priority and cancellation. Location copies run after child errors and unknown action values. |
| 35 | Warp probability and random-call order, packed native arguments, success/failure animations, location fill, shared cleanup and display restoration. |
| 36–38 | In-system names and movement setup, two early self exits, unconditional mask call, signed coordinate wrap, ETA and engine stop. |
| 39–41 | Planetary travel, copied system-row words6/7, four early self exits, shield/cloaker changes, nested native arguments, transition and final time/location copies. |
| 42–44 | Value-caption copies, parent menu bounds,15-unit title strip shifts, and two library25:8 output parameters aliased to the same parent word4. |
| 45 | Copy bounds, install cursor, retain the discarded initial input1 poll, update/poll/select in order, handle word350's low bit, write outputs and erase cursor. |
| 46–49 | Nested map menus, title/pop order, raw stop-word complements, mandatory city-count read, navigation actions, distinct result/input flags and final redraw. |
| 50/51 | Unsigned row-byte condition lookup; fixed menu spacing even for absent entries. Capture the city predicate before the unconditional third condition call. |
| 52 | Ordered display and flag changes, complete two-word time copy, conditional random delay, and original `Refuel ETA:  ` caption. |

The word66 location view aliases existing DATASEG29 storage; its760-byte size
does not change. Procedure8's reference compilation uses the stable VAR address
directly instead of copying it to a private local. Its name pointer occupies
slot4 rather than5, reducing local storage from4 to2 bytes. No callee receives
the parameter slot's address or observes these private offsets. The name length
is still read after drawing through the captured pointer. Other local sizes,
all parameter sizes, and all lexical levels match the original metadata.

The [existing fixture](checks/game_21_compile.pas) compiles procedures2–11 as
226–235:226 is2,227 is3, and228–235 are4–11. Its enclosing `scope13` (225) is a
compile-only scaffold; the recovered entry1 is checked separately below. Source and emitted
disassembly were reviewed against the original paths. The
[receipt](checks/game_21_receipt.json) and [verifier](checks/verify_game_21.py)
record interfaces, frames, hashes, random-state copies, call ordering, two polls,
self EXIT, caption spacing and the word66 address.

Procedures42–45 and50–52 use the entry's eight-word `raw13` frame; their sibling
declarations are included inside the recovered entry. Their dependencies
are the already reviewed libraries22/24/25. Procedure45's bounds occupy local
slots6–9 and scalar locals10–16 retain their roles. Procedure51 uses its formerly
unused local1 to capture the city predicate before calling50, preventing Boolean
short-circuiting from dropping that call.

These seven bodies received a temporary compilation/disassembly check in
`build/decompile/game_13/menu_check.pas`, reusing the first fixture's type and
library declarations through library25:8, omitting unrelated game bodies, and
adding an empty16-byte parent with these seven includes. Compilation had no
warnings. Compiled procedures102–108 correspond to42/43/44/45/50/51/52; local
sizes16/16/0/22/0/2/2, parameter sizes4/2/0/10/8/0/0 and lexical level2 all match.
The reference compiler revision is `397cf201ddf22ca25a82d0ad5401e5d70a38f849`,
with `--p-machine=ii.1 -f no-range-check -f no-efj-nfj`. The resulting code hash
is `e378417a54dccc3fd456ba95f2ae1d0f826ffccb7e8ab8d1d8a9a394a207f7f5`.
This temporary check is outside the two maintained compilation receipts. Review
also confirmed the repeated VAR address in43, discarded poll in45, unconditional
condition call in51 and complete time copy in52. No additional maintained
fixture or checking framework was added.

## Map rendering and selection

[Procedure12](../../src/pascal/game_13/proc_12.pas) includes the full map scope,
procedures13–26. These15 bodies account for1,917 original instructions. Its
six-word `mapstate` preserves slots6–11: rendering writes the selection ranges,
and selection uses the saved flag21 in slot11. Procedure13 retains its44-byte
frame; the redraw word23 contains -1/-2 because the original `LNOT` complements
all16 bits. Tests of that word use its low bit.

Rendering preserves the12-system loop, planet range,16 warp points, optional
city60, selection codes, drawing modes and call order. Procedure16 copies all
12 location bytes before calling helpers, then copies all16 planet-row bytes
after the initial calls. The new address views reuse game19's established row
layouts; include game19 types before game13 types. The packed city count is the
low three bits of the planet row's last word, expressed as `low9 mod 8`.

Procedure18 reads that count before testing the compound shortcut condition,
including when another predicate could decide the result. Its otherwise unused
local5 holds the temporary address/count, then serves as19's hit output.
Procedure19 retains the discarded first input1 poll, cursor toggles around
periodic updates, five-update confirmation timeout, and the input0 result store
before calling24:9. It also retains the result test when no item is hit.
Procedure26 writes city, coordinates and defaults before an access rejection;
those writes are not rolled back. Its random selector is called once, followed
by the range call in the selected arm, with original signed arithmetic.

The stable VAR location address in24–26 is used directly. Original private
pointer slots remain allocated and, in25/26, supply temporary table addresses.
Procedures15/16 likewise reuse their original row-pointer slot for initial table
reads. No nested/raw observer relies on the overwritten private values, and
every local/parameter size and lexical level matches the original. Raw table
pointers are reread where the original reloads them; captured pointers remain
captured across drawing calls.

The temporary `build/decompile/game_13/map_check.pas` reuses the existing library
declarations, adds the reviewed circle-drawing dependency, and includes12 in an
empty16-byte entry1 scaffold. Using the compiler revision/options above, it
compiles without warnings. Compiled procedures110–124 correspond to12–26 in
order;109 is the excluded entry scaffold. Source and emitted bodies were
reviewed against every original path. Checks confirmed all15 frame interfaces,
every original caption, both self exits, discarded poll, selection store/update
order, mandatory table read, saved flag access and random-call sites. Exhaustive
packed-count and redraw-expression checks cover their input bit patterns.
Output SHA256 is
`49e8c6fdf31d10033e3ec1074ac6c129bb1676f5645fd81d5ff992031094b719`.
This temporary check is outside the maintained receipts and supplies no runtime
execution evidence. The added type declarations leave both maintained fixtures'
compiled output unchanged.

## Travel scope and native calls

[Procedure27](../../src/pascal/game_13/proc_27.pas) includes all14 children in
its travel scope. Its six local bytes hold saved flag22 in slot3 and a four-byte
packet in slots4/5. Procedure35 writes a fifth byte at parent slot6 despite that
slot being outside the declared allocation. Original `$1853..$1858` and
`$191A..$191F` write this byte; the warp overlay reads it at `$182D..$1836`.
The Pascal keeps the six-byte parent frame and uses an otherwise unused child
local for dynamic index4 with range checks disabled. Enlarging the packet would
change this memory access relative to the caller. A runtime binding must retain
the original physical caller/frame context; compilation does not prove that
binding. No out-of-bounds behavior has been silently repaired.

The packet's sound byte is255/254: interpreter `LNOT` at `$D5D5..$D5DF`
complements both bytes, and the subsequent byte store keeps the low byte.
Procedure35 therefore writes `255 - ord(flag122)`. The overlay tests bit0, but
the recovered source also preserves the actual stored byte.

The [native declarations](../../src/pascal/game_13/native_interfaces.pas) specify
two targets of the already reviewed library22:25 trampoline. Both receive one
VAR address followed by target6144. The [warp overlay](../warp-animation.md)
reads five bytes; the [viewscreen transition](../viewscreen-transition.md) reads
four and writes byte3 on return. The loader retains the distinct block counts,
offsets and flags118/119. Their native bodies remain assembly. Reassembly matched
both component hashes; prologues, parameter reads and return handling were
checked. These add target contracts, not additional native procedure coverage.

Procedure36 captures the height predicate before the native mask call, which
must run even when the predicate is false. Its two self exits and procedure39's
four self exits return to27's common location-copy tail. Procedure39 copies raw
system-row words6/7 before displaying names; these overlap the caption view,
so substituting the record's trailing words8/9 would be incorrect. Its two
clock copies retain all packed spare bits. The new `clock80` storage view does
not enlarge DATASEG29.

The temporary `build/decompile/game_13/travel_check.pas` extends the menu check
with game13 types/native declarations, existing library24:6, and procedures2/27
inside the same empty parent. Using the compiler revision/options above, it
compiles without warnings. Compiled procedures106–120 map to27–41 in order;
all local sizes, parameter sizes and lexical levels match the original metadata.
Procedure28's private first/third string copies exchange slots4/20, with no
nested or raw observer. Every emitted body was reviewed against the source;
all original string literals are retained. Focused checks confirm the packet
overrun, 255/254 byte expression, both warp calls, six self exits, grandparent
packet access and post-transition time copy. Output SHA256 is
`ac501e4ee6848fee2cf984db30e8f0376e053532e11674291278236c511a16cd`.
This check remains outside the maintained receipts and does not execute the game.

## Entry and navigation menus

Procedures1 and46–49 add the final612 original instructions. Procedure46 keeps
three nested map levels and pops their titles in the original order. After
returning from a deeper level it stores the full complement of stop word347,
using `-1 - word347`; its loop tests still use bit0.

Procedure47 retains its28-byte frame, including location9..14, result6 and
input7. The action9 redraw resets result6 through12's early return before47
decides whether to call27. The outer navigation loop continues according to
input7, independently of result6. Procedure48 uses originally unused parent
slots2–4 to preserve the flag21 read followed by the mandatory planet city-count
read, including when flag21 is false. Its own frame remains empty. Procedure49
passes the original parent location/result addresses to12.

Entry1 retains the eight-word `raw13` frame. It loads segments12/25 before
setup, preserves all mode/flag and display writes around the tactical call,
restores the screen, then releases25/12. Its original exit attribute points at
`$275A`, the release epilogue, while ordinary execution reaches it after screen
restoration. The Pascal records the normal path; runtime binding must route
nonlocal exits to that original release epilogue. Plain compiler `EXTERNAL`
calls to the segment operations do not implement that behavior.

The tactical call is game12:1 with no arguments/result, corroborated by its
call site `$269A` and game12 attributes `$1578` (zero parameter bytes, lexical
level1). The production source calls the recovered `proc12_1`. The earlier
`build/decompile/game_13/complete_check.pas` used a compile-only interface for
that dependency; its receipt below predates game12's recovery. The newer combined
check described in the [game12 notes](game_12.md) includes both actual entries
and all their children. Neither check supplies a runnable runtime binding.

That check includes the actual game13 entry and all51 children, together with
the existing library declarations and library22:20 screen-restore dependency.
Using the compiler revision/options above, it compiles without warnings.
Compiled procedures111–162 correspond to original1–52 in order. All parameter
sizes and lexical levels match; every local size matches except procedure8's
previously documented private-pointer optimization. All91 original captions
remain present. Source and emitted code for the five new bodies were reviewed
against every original path. Focused checks verify load12/25 and release25/12,
the original exit-attribute target, raw complements, mandatory table read,
grandparent menu access, parent VAR arguments and the navigation result/input
split. Output SHA256 is
`d700e1690b3385d855aef19cd9443a964a3f80c061402ab51b3380e39d242e5e`.
This is temporary compilation evidence outside the two maintained receipts;
no new exact-body or runtime-equivalence claim is made.

Both existing verifiers pass. Both maintained fixtures' output is unchanged by
the storage/type additions. Compilation retains the documented game21 `goto` warning and
the first fixture's game20 string-capacity warning. No runtime execution or new
exact-byte equivalence is claimed; external storage/native/runtime bindings
remain unlinked. Assembly and reconstruction inputs are unchanged.

Build the original component before running the
[existing compile/check commands](game_21_map.md#continuation-checks):

```sh
ca65 -I src/pcode -o build/decompile/game_21/game_13.o src/pcode/game_13.s
ld65 -C src/pcode/game_13.cfg -o build/decompile/game_21/game_13.bin \
  build/decompile/game_21/game_13.o
```

Continue with game13's remaining connected scopes and entry. Current full-scope
totals are maintained in the [progress index](README.md).
