# Dialogue controls and conversation runner — R06j

`remake/js/core/dialogue-effects.js` and `dialogue-runner.js` combine the existing
catalogue, text expansion, setup and predicates into a pure conversation runner.
Both counter entries now execute the actual source greeting, item-quote,
information, continuation and exit branches in browser rule tests. This is an
interpreter checkpoint; live room dialogue and campaign transactions are pending.

## Source and execution order

The implementation follows `src/pcode/game_16.s`:

| Procedures | Ported behavior |
| --- | --- |
| 7 ($01C2), 11 ($04AA) | Item-list presentation, item choice and valuation setup |
| 26 ($0AA4) | Packed control byte |
| 27 ($0B4C), 28 ($0BDE) | Reply slots and script actions |
| 23 ($0D62) | Record execution and ordering |
| 33 ($0F7C), 34 ($111A) | Builtins and redirect loop |
| 47 ($1AC6), 48 ($1B90) | Working return amounts/workspace and item-choice branch |

A record runs controls, selector, message expansion, cancel/timeout predicates,
reply predicates/captions, then its action. Redirect records instead run their
selector and action before entering the selected state. All operations share one
continuing RNG. Loading block98 preserves the preceding dictionary supplement.

Each predicate's returned state becomes current before the next operation.
Transition targets are assigned after evaluation: evaluation clones working
locals, so retaining an earlier array reference would silently lose the write.
A regression test distinguishes that failure from correct predicate/RNG order.
Unused reply slots become −1; replies occupy the final one, two or three slots.
Actions may replace these targets, and the returned presentation reflects that.

## Controls and actions

Control bits0/1 set the persistent selector gate and one-shot random reuse.
Bits2–3 leave mood unchanged, increment it, decrement it or set4, with a0..4
clamp. Bit4 clears the chosen item and selling mode before bit5's item/price
selection. The top two bits leave money unchanged, subtract local100 from104,
add100 to104, or copy102 into100. The copy follows the source MOV operand order.

Random item selection follows procedure11's flag acceptance/rejection loop.
For kinds17 and above, valuation draws precede both predicate30 and predicate166;
both predicates run even when the selected item is below15. Selling reverses the
valuation direction. Kind15 applies the source zero-amount refresh. Repeating
rejected RNG states fail instead of hanging.

Actions0–7 supply:

- An offer panel with decimal increase/decrease controls and a randomized amount.
- A chosen-item display, including the224 charge bits on exact items11/13.
- Selling choices from carried items or buying lists using setup thresholds.
- The source no-op and three continuation-slot assignments.

These handlers operate on prepared interpreter state. Only counter kinds13/14
have a public fresh-setup path; tests prepare other kinds explicitly to verify
shared handlers. This does not establish complete encounter/shop setup for them.

## API and browser adaptations

`startCounterConversation(content, setup, {places})` returns a frame containing
owned dialogue state, RNG, dictionary, message/replies, item or offer panel and
an `ended` flag. `content` contains `scripts`, `text` and `items` from the existing
exports. `setup` is the result of `setupCounterDialogue`. Dynamic place messages
require the existing text renderer's explicit current place/name context.

`advanceDialogue(content, frame, input)` accepts:

- `reply` with a currently visible `slot`.
- `item` with a listed item while the selection action is active.
- `offer` with `direction` and a step of1,10,100,1000 or10000.
- `cancel` or `timeout` as explicit caller events.

Native pointer columns become explicit offer steps. Timeout is a logical expiry
event, not a claim about native CPU-loop duration. Offer steps increase local43
as the source does; the host will own elapsed time. New records clear active
offer controls even if earlier presentation remains in the panel.

Builtins0–8 handle the source offer/exit flags and selected-item workspace;
9–11 redirect through continuation slots;12–15 are source no-ops. Offer decreases
below zero copy baseline102 into100. On exit, the supported part of procedure47
raises104 to102 if necessary and writes mood/gate back to the owned workspace.
This gate write follows builtin4's earlier clear, as in the source. Returning
the frame does not commit cash, inventory, attributes or flags into a campaign.

Public reducers clone before acting and publish a frame only on success.
Malformed inputs/actions, missing context, unsupported monetary/valuation ranges
and redirect cycles fail atomically. Redirect chains are bounded to64 hops.
`dialogueEffects` and `refreshDialoguePrice` are internal mutating helpers for
owned working data; callers must use the reducers to retain atomicity. Frames are
trusted interpreter products, not a new accepted save format.

## Validation and remaining integration

Chrome154.0.8037.57 at `/opt/google/chrome/google-chrome` passes152 rule groups,
including13 new groups. Coverage includes both real counter roots; exact greeting,
quote, acceptance and timeout text/RNG; information bank transitions; all256
control bytes; list/charged-item/offer actions; eager predicate order; decimal
offer limits; continuation and exit flags; caller ownership and atomic failures.
Seventeen exporter tests, all139 generated artifacts and original disk/PDF hashes
pass. No new original-emulator conversation capture is claimed.

Accepting the quote for item10 reaches the source “Here you are” message and item
display while retaining the caller's500Cr and carried items. Selecting that
display is rejected because inventory-transfer procedures5/41 are not ported.
The completed conversation steps must not be advertised as completed purchases.

Next integrate the player counter queue and return state, persist conversation
state, and provide English/Korean presentation. Inventory transfers and campaign
financial operations remain R07. Saves remain version7; the live UI has no new
conversation controls in this checkpoint.
