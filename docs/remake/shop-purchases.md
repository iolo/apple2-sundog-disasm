# Shop and bartender purchases — R07d

Item/equipment counters and bartenders now sell into the four carried slots.
Choose an item, accept the shop quote with **Buy**, then choose an empty slot to
pay and receive it. Bartender food/ale selection opens the payable offer directly.
Only cash pays for personal items; banking and warehouse state remain unchanged.
Exact-price cash is sufficient. Selecting or accepting a quote spends nothing.

## Source evidence

- `src/pcode/game_16.s`, procedure23/34 and exported script states82–85:
  shop roots list goods, state84 quotes, state85 uses action1 to display the
  transferable item. Action1 continuation9 returns through local53[0] to the
  appropriate shop root. Information records are not purchase offers.
- Bartender states16/18 list food8/ale9 and display a selected item with action1;
  continuation16 returns to the menu after a transfer.
- Procedure40, `$172C–$173B`, writes the encoded item into carried storage.
  Action1 supplies charge bits for shield11/scattergun13, yielding235/237.
- Procedure41, `$18E1–$192B`, compares asking price106 against cash104 with
  library28 procedure6. Only price greater than cash fails. This differs from
  the exchange's strict available-funds comparison.
- Procedure42, `$1748–$178B`, debits price106 when local18 is false, adds two
  delay units, stores the transferred byte in local41 and executes local95[0].
  Procedure43 supplies the transferred item and destination from drag state.
- Procedure47 writes the conversation's final cash/workspace on return.

The implementation reuses existing source price calculations, script predicates,
text and RNG continuations. No alternate price table or invented stock quantity
is introduced. This is source-derived work; no native emulator transaction
capture or pixel/cycle equivalence is claimed.

## Browser and save boundary

An explicit `purchase` input with slot0–3 replaces pointer dragging. The reducer
requires a current action1 purchase offer from kind12/13/14, an empty destination
and sufficient cash. Quotes, information, stale panels, invalid slots, occupied
slots and insufficient cash reject atomically, including RNG and replay history.
Each transfer returns through the source continuation, allowing multiple buys.
Whole bytes preserve item charge. English/Korean controls show item, price,
working cash, all four destinations and reasons a purchase cannot proceed.

During an open conversation, carried items and cash live in its derived frame.
Version14 `landed-purchases-1` saves the existing campaign baseline plus the
conversation seed and validated inputs. Replay reconstructs every paid transfer;
it never treats a completed purchase as a new confirmation. On conversation
return, cash and carried inventory commit together and replay history clears.
Cancelling an untransferred offer costs nothing; leaving after a transfer keeps
its payment and item. Account balances, warehouse lots, creation data, condition,
stores and locker are preserved. Food is carried first and consumed later through
the existing inventory controls.

Versions1–13 retain their historical acceptance rules before migration. In
particular, older saves cannot inject the new purchase input or bartender item
selection. Version13 accounts, exchange state and existing quote conversations
upgrade without resetting their RNG. Purchases reduce cash, so the existing
money-plus-warehouse-cost wealth bound remains valid without a new income ledger.

Deliberate limitations: purchases require an empty carried slot; native drag
swapping and direct consumption at a counter are not implemented. Transfer
controls appear only on the actual offer record, not a later impatience message;
its ordinary reply can return to the offer. Dialogues remain paused with explicit
Continue timing. Personal-item resale and visitor/street-trader matching remain
pending, as do warehouse/pod/ship cargo loading. R07 is not complete.

## Validation

`shop-purchases-rules-validation.json` records227 passing browser rule groups.
Six UI receipts record226 passing checks (shop29, tavern43, exchange64, bank44,
information dialogue19, lodging27). The asset check verifies160 deterministic
exports. No browser exceptions were recorded.
`shop-purchases-ui-validation.json` covers controlled equipment-shop imports,
ordinary counter interaction, keyboard confirmation, English/Korean viewports,
capacity/funds rejection and fresh-page saves before/after transfers.
`shop-tavern-ui-validation.json` covers a real tavern door from a controlled street
fixture, food/ale purchases, replay and existing tips/seating/visitor flows.
These fixtures do not claim a new-game-to-shop journey.
