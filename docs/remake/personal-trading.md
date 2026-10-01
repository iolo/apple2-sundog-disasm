# Visitor personal-item trading — R07f

Tavern visitors now buy and sell through the source conversation branches.
Ordinary shops retain their existing purchase routes. Bartender trader matching
is still gated pending its actor lifecycle. See the [source audit](personal-item-resale.md)
for Game16 procedures37/39/41–43 and the distinction between these routes.

The direct seated route reaches social state130, Sell selects a carried item in
131, state35 quotes it, and Accept reaches37/action1. Acceptance alone moves no
money or item. The player then chooses a matching carried slot to hand over;
the complete selected byte leaves that slot, price106 enters cash104, and the
source continuation38 determines the visitor's response/departure. Matching uses
the low five bits, so two shields with different charges remain distinct choices.
Supported sale types are10–31 except14; food/ale8/9 are not resale goods.
Visitor kinds21/22 also use the existing purchase confirmation into an empty slot.

The browser substitutes explicit slot buttons for the original cross-boundary
drag. Source bargaining, refusal, prices, continuation and RNG remain in the
dialogue runner. Conversations pause movement and advance delays with Continue.
Cancellation before transfer costs nothing; leaving after transfer retains it.
Cash cannot exceed32,767,999. Invalid slots, mismatched types and overflow fail
atomically. English/Korean labels include the chosen item's charge value.

## Save ownership and migration

Version15, `landed-personal-trade-1`, adds `economy.personalTrade` with exactly
two dense32-entry integer arrays: `sold` and `proceeds`. Their indexes are item
types, not encoded charge bytes. They record completed gross sale counts and
income, independently of current cash, bank balances and immutable creation data.
Depositing or spending proceeds does not reduce this ledger.

Counts are bounded to0..1,000,000,000 per type. Unsupported types require zeros.
Using the exported item's base value, each ordinary sale lies between1 and128
times that value; types15–22 lie between3 and126 times it. Aggregate proceeds
must fit those count bounds and be divisible by the corresponding minimum unit.
Every amount and the aggregate total must be safe integers. The count cap is a
practical save bound, not an original gameplay limit.

The wealth check is:

```text
cash + all bank balances + warehouse purchase costs
  <= initial cash + initial bank balances + gross personal-sale proceeds
```

Pending conversations retain baseline campaign cash, carried items and ledger.
Only the seed and validated inputs are saved; replay derives working transfers
and sale receipts. A sale input stores exactly `type: sale` and `slot: 0..3`,
never an asserted price or receipt. Pending receipt totals are validated before
acceptance/import so an eventual ledger overflow cannot strand a paid trade.
Cash, carried items, ledger and speaker return commit together when dialogue ends;
the input log then clears. Reopening or replaying a save does not pay twice.

Versions1–14 pass their historical field/input checks before receiving an empty
ledger. Version14 cannot inject visitor acceptance, purchases, sales or ledger
fields. Version13 and earlier keep their existing shop/food restrictions too.
Other cities and active pod cargo remain outside this save boundary.

This is consistency validation, not authenticated trade history. A coordinated
edit to otherwise valid completed counts, proceeds and money can pass validation;
the ledger is not an anti-cheat mechanism. Open transfers are checked by replay.

## Evidence and remaining work

Chrome154 passes242 rule groups and34 new UI checks. These cover charged-slot
selection, cancellation, full cash, rejected/malformed inputs, historical gates,
replay before/after handover, one-time return, ledger bounds, sale-proceeds bank
deposit, visitor purchases and eight English/Korean viewport combinations.
The UI uses a controlled seated-visitor campaign fixture, then normal controls;
it is not a fresh-game-to-trader journey or a native emulator capture.

Receipts are `personal-trade-rules-validation.json` and
`personal-trade-ui-validation.json`. Existing tavern, shop, banking, exchange,
lodging and dialogue regressions pass226 additional checks and are recorded as
`personal-trade-*-regression.json`.

R07 remains incomplete. Next connect the [cargo core](cargo-loading.md) to
minimal pod departure/arrival, exchange entry, active cargo saves and loading
controls. Broader ground transport/services remain R08.
