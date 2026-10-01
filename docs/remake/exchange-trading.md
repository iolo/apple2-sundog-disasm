# Local warehouse trading — R07c

The Drahew exchange now supports foot purchases into its four-slot warehouse and
sales from that warehouse. Bank-first payment, cargo ownership, offer replacement,
stock changes and continuing RNG commit together. Version13 saves preserve the
market, cargo and current eight-row offer board. Shops, pod loading/unloading,
intercity trading and colony deliveries remain outside this checkpoint.

## Controls and transactions

Walk to the exchange door and enter. **Offers** shows commodities, grades and
asking prices in credits. **Warehouse** shows owned cargo and current sale quotes.
Selecting a row opens a review; Confirm commits the trade. Cancel or Escape
discards the review. A second Escape leaves the service. Saving retains committed
state only; loading clears a pending review. Services pause movement/survival.
English and Korean use the same state and controls. The list scrolls independently
so balances, feedback and action buttons stay visible.

`reduceCampaignExchange` requires the real exchange door and supported scene.
Entry refreshes the local market for `floor(ship.minutes/1440) % 16384`, then
creates offers from the continuing gameplay RNG. Same-day reentry preserves stock
and warehouse contents while generating a new board. Reloading an existing board
does not generate offers or draw RNG. Leaving clears only the visit board.

Source evidence builds on [R07b prices and offers](exchange-quotes.md):

| Rule | Source | Browser implementation |
| --- | --- | --- |
| Four warehouse slots; two pod slots | Game20 proc11 `$0676–$06CD`; proc26 `$1522–$153B` | First empty warehouse slot; reject a full warehouse before any mutation. Pod remains unavailable. |
| Funds must exceed asking price | Proc23 `$0F52–$0F74`; Library28 proc6 `$00FE–$0121` | The comparison is strictly greater. Exact funds are rejected, with an explanation in the review. |
| Bank-first spending | Proc5 `$03DA–$0432`, proc7 `$04A0–$0505` | Debit the local account up to the price, then use cash for the remainder. |
| Cargo type, quality, origin and paid price | Proc23 `$0FD9–$100C`; proc24 `$1436–$1467` | Own a fresh lot record in the first empty slot, with the current city as origin. |
| Replace purchased offer before reducing supply | Proc27 `$162F–$165B` | Replace that row using proc21/22 rules against the other seven rows, then reduce supply. Other asking prices stay fixed. |
| Ordinary stock reduction | Proc20 `$0C7C–$0CD3` | Subtract `draw%3` from supply on buying or demand on selling, clamped to zero. Every completed trade consumes this draw even when the reduction is zero. |
| Sale proceeds and clearing cargo | Proc25 `$14A7–$1511`, proc7 settlement | Deposit the accepted sale quote in the local account and clear exactly one slot. Reject account overflow. |

Money is integer credits. A local resale never exceeds the lot's paid price.
Initial cryogens occupy their original warehouse slot and cannot be sold or moved
in this scope. Invalid selections, insufficient funds, full capacity, overflow
and failed offer generation return no replacement state. The reducer owns its
cloned state and RNG until the entire operation succeeds.

## Explicit browser adaptations

- Each confirmation settles money immediately. Native Game20 keeps a combined
  spending pool during the visit and reconciles cash/accounts on exit. A native
  purchase followed by a sale during the same visit can refill its original
  cash reserve before depositing the rest. The browser treats each confirmation
  as a completed settlement, and every sale credits the local account.
- Offers stay fixed during review, language changes, saves and idle time. The
  native Buy/Pass loop can randomly replace an offer before presenting the next
  choice (proc27 `$15D0–$15E2`). The browser omits that idle/Pass replacement;
  confirmed purchases replace their row and reentry generates a fresh board.
- The browser permits selecting any visible offer to inspect it, including an
  unaffordable one. Native proc23 searches for a nonempty affordable offer. The
  browser disables confirmation and explains insufficient funds or capacity.
- Time remains paused in the service. Work limits and monetary overflow checks
  reject unsafe inputs rather than hanging or wrapping native signed words.

These adaptations are deliberate. No cycle-equivalent UI loop or new native
transaction capture is claimed.

## Version13 state and migration

Scope is `landed-exchange-1`. Active economy is:

```text
economy.accounts[12] = {systemId, balance}
economy.exchange = {
  market: {cityId, templateIndex, demand[31], supply[31], lastUpdateDay},
  warehouse: {cityId, slots[4]},
  visit: null | {offers[8]}
}
lot = null | {commodityId, quality, originCity, pricePaid}
offer = null | {commodityId, quality, price, demand, supply}
```

Only the starting city's market and warehouse are mutable. Other cities and pod
cargo remain creation data; travel will need to expand this boundary explicitly.
An offer's saved demand/supply are the quantities used when it was quoted. They
let validation recompute its exact asking price even after subsequent trades
change the current market. Visible pairs must be unique. These are consistency
checks, not a replay of all historical gameplay or cryptographic anti-cheat.

Validation checks exact keys, dense arrays, template quantity caps, fixed city/
template IDs, dates, initial cryogen identity, lot quality/origin and exact paid
credit multiples. Cash plus all account balances plus stored purchase costs may
not exceed creation wealth. Buying conserves that sum; local sales, lodging and
tips can only lower it. Intercity profits will require a future rule expansion.
Bank operations preserve the exchange block. Creation data is never modified.

Versions1–12 first pass their historical shape and money rules. The local exchange
state is then derived from validated creation data. A legacy exchange preview
has no board; UI resume prepares its first visit before replacing live state.
This advances RNG once. A normal version13 visit reloads its saved board exactly.
Pending confirmations and the selected tab remain transient. Reordered JSON keys
are accepted and city/room coordinates are returned in canonical order.

## Validation

Chrome154.0.8037.57 passes 222 rule groups. Seven new campaign-exchange groups
cover entry/reentry, bank-first and cash-spill purchases, exact-funds rejection,
capacity, sales, overflow, offer replacement, deterministic save/replay, invalid
imports, version12 migration, weekly refill, cryogen preservation and rollback
after offer generation fails. The earlier eight quote groups remain passing.

The 62-check exchange UI walkthrough uses normal controls from character creation through
street entry, purchases, cancellation, warehouse capacity, sales, fresh-page
IndexedDB reload and reentry. It checks both languages in five viewports, quote
tampering and legacy preview imports. Offer and review screenshots were inspected.
Existing banking44, service78 and full exploration90 checks pass. See:

- [Rule receipt](exchange-trading-rules-validation.json)
- [Exchange UI receipt](exchange-trading-ui-validation.json)
- [Bank regression](exchange-banking-regression.json)
- [Service regression](exchange-services-regression.json)
- [Exploration regression](exchange-journey-regression.json)

All 160 generated artifacts still match their exporter. The existing source and
capture evidence supports these rules; no new emulator observation was added.
