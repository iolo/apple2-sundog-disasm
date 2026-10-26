# Game 18: selection, entry updates, and enclosing scope

All 28 game18 bodies are now recovered, covering 3,669 original instructions.
This group adds1/23/26–28: five bodies and800 instructions. Overall coverage is
111 of570 targeted p-code bodies and9,494 instructions. Sixteen of38 native
interfaces are reviewed; two explicit runtime-operation interfaces are also
documented here, separately from native procedure-dictionary coverage.

The component is `game_18`, SHA-256
`452d8de86b4fc68e6c9827200418b67ca0f8a8c9fea1a86964baa667fafb37e4`, assembly
revision `5c64227e095e86ba1e8c79b8e4425986cf9ae58f`. Physical extents remain in
`src/pcode/game_18.adopt.json`. Findings are static; the full plan is incomplete.

| Procedure | Entry through return | Attributes | Instructions | Source |
| --- | --- | --- | ---: | --- |
| 18:1 | `$17F2..$183D` | `$184C` | 35 | [proc_01.pas](../../src/pascal/game_18/proc_01.pas) |
| 18:23 | `$114A..$1363` | `$1370` | 270 | [proc_23.pas](../../src/pascal/game_18/proc_23.pas) |
| 18:26 | `$149A..$1605` | `$1614` | 223 | [proc_26.pas](../../src/pascal/game_18/proc_26.pas) |
| 18:27 | `$1616..$1711` | `$171E` | 169 | [proc_27.pas](../../src/pascal/game_18/proc_27.pas) |
| 18:28 | `$1720..$17E1` | `$17F0` | 103 | [proc_28.pas](../../src/pascal/game_18/proc_28.pas) |

## Interfaces and selection

The enclosing procedure retains four raw argument words. Arguments4/3/2 contain
addresses of caller-owned words; argument1 is a selector. The caller in
`startup_disk1.s:$0130..$0137` pushes local addresses4/3/1 and the value of local2,
confirming that distinction. The raw address representation keeps existing
child source and the original eight parameter bytes consistent. The complete
parent includes its298-byte local declaration and all children.

Procedure23 saves the pointed-to coordinates, clamps them in order, derives a
direction using22:34, and preserves both CASE tables and their no-op defaults.
It adjusts even first coordinates using the original low-bit test. Since the
coordinate outputs can alias, sequential stores and later rereads are retained.

Its chosen path writes the selector result and bytes548–552 from the selected
entry. Its other path saves bounds, passes the current dereferenced coordinates
to game8:1, reinitializes input, restores bounds, and updates parent flag143
from the returned mode. The game8 callee now has its full recovered scope.

## Entry updates

Procedure26 captures entry1 before its calls and retains both selector4 polls.
The state-change comparison is Boolean NEQ, whose interpreter handler at
`$DF5A..$DF6C` compares only the low bits. The source uses `odd` on both operands;
the compiler emits the original typed Boolean comparison. Packed-flag writes,
ordered coordinate tests, child24/25 calls, and the final selector1 poll retain
their original order.

Procedure27 captures entry0 across movement calls. When it updates another
entry's byte9, the destination is selected before the random call. The small
`pair9` overlay gives that byte pair a record view for a captured `WITH` address;
it does not enlarge the20-byte entry. The availability path captures parent125's
predicate and calls random even when that predicate is false. It scans entries
in ascending order and preserves the original parent/entry updates.

Procedure28 preserves its two active-entry updates and the random selection
path. Both MOD divisors are read after their preceding random calls. It adds
no zero-divisor guard. The final choice retains a random call even when the
parent flag alone could determine the result. The unused computed entry address
in original local2 has no observable consumer and is omitted.

## Runtime bindings and exit metadata

The parent loads segments8 then27, initializes once through21, and repeats
26/27/28 plus the clock/input checks. Normal completion redraws, calls22, then
releases27 followed by8.

[runtime_interfaces.pas](../../src/pascal/runtime_interfaces.pas) declares the
two required operations without replacement bodies. CSP21's vector at `$D12A`
targets `$E66B`; CSP22's vector at `$D12C` targets `$E675`. Each pops one word,
uses the low byte as the segment number, invokes the existing load/release
handler, and returns no result. These bindings are not implemented by the
compile fixture: it emits calls to unlinked EXTERNAL declarations.

The original parent's exit attribute targets `$182D`, the release epilogue,
rather than its final RNP at `$183D`. This matters for any nonlocal EXIT into
the parent. The source marks that requirement at the release calls, and the
verifier pins the original epilogue bytes. The fixture's exit attribute points
to RNP and therefore does **not** validate this runtime cleanup contract.
Rebinding/recompiling a runnable module must preserve the original exit target;
source recovery does not imply that this work has been done.

## Verification

All111 recovered bodies compile without diagnostics. Parameter byte counts and
lexical levels match their original metadata. Local sizes (original -> recovered)
are1:298->298,23:12->18,26:16->4,27:4->10,28:4->4. Child changes reflect explicit
pointer/random temporaries or omitted unused slots; no nested procedure consumes
those changed child layouts. Existing frame copies and parent offsets remain
unchanged.

The [fixture](checks/game_18_compile.pas) now puts game8 before game18 to satisfy
their actual dependency. Current mapping: game8 entry83, game18 entry103,
game18's newly recovered23/26/27/28 at127–130. Runtime declarations occupy101/102.
Native interfaces are2–12,44–46,71,79. The [receipt](checks/game_18_receipt.json)
is authoritative for all mappings; earlier notes contain historical numbering.

The [verifier](checks/verify_game_18.py) checks CASE defaults, pointer loads,
bounds around game8, both selector4 polls, Boolean NEQ, destination capture and
unconditional random calls, parent load/update/release ordering, and the original
exit-epilogue requirement. EXIT constants above127 are checked as LDCI operands.
All seven earlier exact body matches still pass. No new exact-body, whole-module,
runtime, or disk-rebuild equivalence claim is made.

Next: follow the startup dispatcher into the remaining active game modules,
starting with game17 and its required dependencies. Original assembly and disk
reconstruction inputs remain unchanged.
