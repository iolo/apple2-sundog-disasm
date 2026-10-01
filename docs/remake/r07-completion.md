# R07 completion audit

Status: **complete**, verified 2026-10-01. This audit covers the original R07
row in `PLAN-REMAKE.md`: shops, cash/system accounts, transfers, exchange quotes,
buy/sell, warehouse ownership, cargo loading/capacity, price/stock rules and
relevant dialogue conditions. R07's acceptance gate is the complete local trade
loop, atomic insufficient-funds/capacity failures, bank-first commodity purchases
and local sale deposits. It does not require the later intercity travel milestone.

## Requirement evidence

| Requirement | Current implementation and authoritative verification |
| --- | --- |
| Shops and carried cash | `dialogue-runner.js` implements food, personal-item and equipment purchases, with explicit empty-slot payment. `campaign-dialogue.js` commits replayed cash/items once. `dialogue-runner.js` tests and `r07-final-shops-validation.json` cover actual purchases, poor/full inventories, cancellation and before/after-payment reloads. Ordinary shops have no native Sell branch; personal resale is implemented through visitors. |
| System accounts, deposits, withdrawals and transfers | `banking.js` and its rule tests cover exact integer credits, all132 directed account pairs, source amount controls, conservation, overdraft and overflow. `r07-final-banking-validation.json` starts a fresh campaign and uses normal controls through bank entry, transfers, deposits, withdrawals, reloads and old-save migration. |
| Exchange quotes, prices and stock updates | `exchange.js`, `economy.js` and their rule tests cover source integer truncation, geography, quality, local/world/system resale ceilings, first-visit/weekly stock updates, unique eight-row offers and1000 deterministic staged visits. `campaign-exchange.js` validates saved quotes against their original quantity inputs and preserves current market/RNG. Source offsets and adaptations are recorded in `exchange-quotes.md` and `exchange-trading.md`. |
| Commodity buying/selling and bank-first settlement | Campaign exchange tests prove local-bank-first spending, cash spill, strictly-greater-than-price funds, offer replacement before stock reduction, local account sale deposits and rollback on generation failure. `r07-final-exchange-validation.json` verifies a fresh-character UI journey through purchases, full capacity, sales, reentry, language changes, malformed imports and reloads. |
| Warehouse and shared pod/ship cargo ownership | `cargo.js` implements four warehouse/two pod slots, first-empty Store/Fetch and occupied-slot Swap. Rule tests exhaust all64 occupancy patterns, preserve quality/origin/paid price and reject remote/foot loading. `campaign-pod.js` and the save codec conserve initial cryogens and include paid cargo in both containers in the wealth bound. |
| Live loading, transport and capacity | `city-pod.js`, campaign reducers and exchange controls require actual pod departure, reachable driving and the cargo entrance. `r07-final-cargo-validation.json` starts a fresh character, drives to the exchange, buys/fills/swaps/reloads, docks loaded, checks the shared ship manifest, departs again, unloads and sells. Full capacity and cancelled transfers cannot partially commit. |
| Personal resale and bartender matching | `personal-trade.js` validates gross sale income; dialogue handover removes the exact selected charged byte. `room-traffic.js` now targets a seat opposite the player for bartender requests, and kinds17/21/22 use actual visitor actors. Rule tests cover four taverns/six seats, both referral directions, source RNG, charged appraisal, refusal and deterministic saves. `r07-final-visitors-validation.json` and `trader-matching-validation.json` exercise visible transfer controls and lifecycle. |
| Persistence, atomicity and local trade reconciliation | Version17 preserves cash, twelve accounts, local market/warehouse, pod cargo and pending room/dialogue progress. Versions1–16 retain historical validation before migration; loaded version16 pod state is preserved. Rule tests reject malformed saves and failed operations without changing inputs. Browser receipts include reloads before and after transfers, and reconciliation after bank, personal and commodity trading. |
| English/Korean presentation and existing interactions | Both locales retain source item/text data and offline assets. Bank, exchange, cargo and referral trade controls pass viewport checks. The referral screenshot was inspected. `r07-final-taverns-validation.json`, `r07-final-lodging-validation.json` and `r07-final-dialogue-validation.json` verify existing room service and replay after the new save scope. |

The mapping above is supported by current rule and browser runs, not just the
presence of test files. Browser UI trading uses both fresh-character journeys
(bank, foot exchange, pod cargo) and explicitly seeded room fixtures (personal
trading and referrals). The latter still use normal controls for requests,
movement, NPC arrival, handover, refusal and save/reload; they do not establish a
fresh-character-to-ending campaign, which remains R11/R13.

## Current receipts and checks

- `r07-final-rules-validation.json`:252 rule groups, no failures or page errors.
- `r07-final-banking-validation.json`:44 checks.
- `r07-final-shops-validation.json`:29 checks.
- `r07-final-visitors-validation.json`:34 checks.
- `r07-final-exchange-validation.json`:64 checks.
- `r07-final-cargo-validation.json`:33 checks.
- `r07-final-taverns-validation.json`:43 checks.
- `r07-final-lodging-validation.json`:27 checks.
- `r07-final-dialogue-validation.json`:19 checks.
- `trader-matching-validation.json`:75 referral and lifecycle browser checks.
- `python3 tools/remake/test_exports.py`:19 tests passed.
- `python3 tools/remake/export_assets.py --check`:165 deterministic artifacts verified.

All252 rule groups and368 browser UI checks pass in Chrome154.0.8037.57,
with no reported page errors. The audit found no remaining R07 requirement.

## Explicit boundaries

The documented exchange adaptations remain: confirmations settle individually,
sales credit the local account, and offers remain stable during review instead
of changing in the native idle/Pass loop. Browser cadence is50ms; pod docking
uses the documented one-pixel clear interior adjustment. These are declared
adaptations, not claims of cycle-equivalent emulation. No new native emulator
capture was taken for R07h.

Broader ground traversal, unattended pod parking and depot repair/fueling remain
R08. Activating other cities' markets/warehouses and intercity profit/save rules
belongs with R09 travel. Colony delivery and ending progression remain R11.
The local warehouse/pod loop required by R07 is implemented and verified; those
later milestones are not substitutes for missing local cargo access.
