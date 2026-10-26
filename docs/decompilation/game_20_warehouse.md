# Game20 setup, inventory, and warehouse

This group recovers game20 procedures2–15 and32 directly from the p-code
listings: 15 bodies and 1,370 original instructions. At this checkpoint, coverage was
185 of 570 targeted bodies, covering 16,211 instructions. The remaining17 bodies are now covered by the
[game20 completion group](game_20_complete.md); runtime execution is untested.

The [source directory](../../src/pascal/cargo_exchange/) contains maintained Pascal.
The component hash is
`f93e6492e63ad109ab1f4484b1fe9e61bc6de7c63b67dc7c69abf976f07aecdf`;
the [inventory](inventory.json) pins procedure identities, offsets, and revision.
No new native interfaces were required.

| Procedures | Recovered behavior |
| --- | --- |
| 2 | Bounded wait with both input calls on every iteration. |
| 3 | Block read, selected forward copy, and conditional block write. |
| 4 | Contract-phase scan, bonus/display, and next phase's packed requirements. |
| 5–6 | Inventory load, initialization/replenishment, and bank balance transfer. |
| 7 | Warehouse/inventory disk writes and final cash/bank reconciliation. |
| 8–10 | Timer-aware input, button rows, and title-button flash. |
| 11–15 | Empty-slot search, item selection, and warehouse store/fetch/swap. |
| 32 | Amount zeroing, display setup, and saved global state. |

At this checkpoint the compile-only parent190 retained the original328 local bytes, slots2..165,
and one parameter. It was empty and excluded from coverage; the completion group replaces it
with the recovered entry. Pointer words18–21
retain their original addresses. Each levels record at22/29/38/45 spans seven
words, while ordinary item updates visit only30 three-bit entries. Whole-record
comparisons include padding; the source uses record comparisons that compile
to the original seven-word comparison operation. Warehouse52 contains four
two-word items. Zero160, bonus162, and cash164 are distinct overlapping views
of the raw frame, with names distinct in the compiler's first eight characters.

Procedure3 reads a block before calculating the copy offset. Operation2 still
performs that read. Operation1 may copy54 bytes from buffer offset288 before
the inventory copy; operation3 writes the modified block afterwards. Copies
starting at parent22 and38 retain caller-supplied lengths32 and28, spanning
adjacent declared fields. They use forward MOVELEFT rather than a new buffer
format or a shortened record assignment.

Procedure4 retains CSP11 SCAN with count14, non-equality selector1, and byte0.
The supplied handler at `native_shared.s:$E6CF..$E74C` compares the byte before
its bound check; keeping the actual SCAN call also preserves that behavior.
Only a return value of14 proceeds to the phase logic. Phase9 sets the completion
selectors and exits before changing the phase bytes or copying requirements.
Other paths copy54 bytes of phase data and increment the indicated packed fields.
The bonus addition precedes procedure5's later cash snapshot; the translation
does not reorder those operations to fit an inferred intent.

Procedure5 preserves fixed buffer addresses5120/22528/23552 and the name-cache
test against `cryogens`. Each random call precedes the corresponding packed
value read. Replenishment copies the seven-word target before updating30 entries
and uses the enclosing growth value at slot3. The selected system row stays
captured through bank addition and zeroing. Procedure7 performs its disk writes
before cash reconciliation and re-evaluates the system-row pointer for the final
bank store, as the original does.

Procedure8 increments the global timer before cursor/input polling and calls
the time update at a threshold of10. Input1 is polled only on the original
input0-false branch. VAR output stores and the duplicated output address in
procedure10 retain alias-sensitive ordering. Procedure12 builds its labels once
and retries selection of empty entries; no artificial initialization of its
empty flag is introduced. A zero selection exits without requiring that flag.

Warehouse13 retains two-word moves and a four-byte cleared swap temporary.
Its row/column remain slots6/7 for nested14/15. Procedure15's two scalar
parameters are evidenced but unused; its nested drawing helper reads the
enclosing coordinates. A positive pod index triggers caption refresh even
after a failed store. Cancellation exits13 itself, and Store/Fetch/Swap retain
their differing empty-slot and selected-item paths.

At this checkpoint all185 recovered bodies compiled without diagnostics. The
[existing verifier](checks/verify_game_18.py) passes hashes, interfaces, the
seven earlier exact-body matches, and focused regressions. New checks cover
the amount offsets, SCAN operands, copy directions, padding comparisons,
random/input sites, menu timing, nested coordinates, and warehouse moves.
The [reproduction instructions](game_18.md) include game20 assembly. These checks
do not execute disk I/O or establish runtime equivalence. Original assembly,
native source, decoder tools, and reconstruction inputs are unchanged.

See the [completion notes](game_20_complete.md) for pricing, trading,
interaction, and entry recovery.
