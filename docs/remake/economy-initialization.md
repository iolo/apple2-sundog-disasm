# City economy foundations — R04e

`remake/js/core/economy.js` implements utility14/16 initialization and ordinary
market refresh from game20 procedures5/6. It takes explicit content and randomness,
returns independent named state, and never reads a saved campaign. The live
walkthrough and checkpoint format do not yet use this module.

## Content and storage boundaries

`initial-economy.json` exports 18 templates from bytes 0–503 of
`assets/working-state/data.bin`, the selector byte 504, and 57 city names/world
memberships from the next 1440 default bytes. It excludes the saved working-record
tail. Nine colony recipes come directly from utility14's eight-character literals
at `$04D1–$0539`; their ASCII values minus64 identify commodities, with 0 ignored.

Each 28-byte template has 14 bytes of demand followed by 14 bytes of supply.
Pascal `IXP 5,3` packs five 3-bit quantities per 16-bit word, leaving bit 15 unused.
The exported arrays contain 31 quantities: index 0 is cargo-01 and index 30 is
cryogens/cargo-31. Other packed fields and padding are excluded. Game20 procedure23
`$109B–$10B7` labels the first half Demand; procedure21 `$0D99–$0D9E` uses the
second half for ordinary offers.

World record word 7 bits 0–2 give city count; bits 9–14 give its city base, used by
game20 procedure19 `$0AE7–$0AFC`. The shipped memberships enumerate cities 1–57.
City 60 is the colony. Physical map IDs 58/59 remain in the asset viewer, but their
32-byte storage records hold the 54-byte colony recipe bank, not ordinary markets.
Warehouse-bank records 60/61 (zero-based) hold a copied colony market, not cargo.
These overloaded records never become additional logical cities or warehouses.

## Initialization

Utility14 `$040A–$0421` advances the selector by 5 modulo 18. The supplied baseline
byte is 23, so the resulting selector is 10. Each world's cities copy the template
at `(selector + zeroBasedWorldIndex) % 18`; their signed last-update day is −16.
City 60 starts with zero quantities and the same day sentinel. The ordinary source
records' final two bytes are 0/0 and the colony's are 1/1; their consumer semantics
are unresolved, so this module does not invent named gameplay flags for them.

Utility16 `$05B9–$061B` clears warehouses and places 17 cryogen units. Every city
has four cargo slots. It starts a cursor at `1 + random % 57`, then computes
`(cursor + random % 4 + 1) % 57 + 1` for each candidate. This exact expression
moves 2–5 cities in a 1-based representation. An occupied first slot causes a retry
from the updated cursor. Every successful placement is cargo-31, quality 7,
originating in its own city, with price paid 0. The colony warehouse stays empty.
The implementation fails explicitly after 10000 attempts rather than hanging.

Game20 procedures11–13 use four 4-byte warehouse units. In the first word, bits 0–4
are commodity type, bits 5–7 quality, and the high byte origin city. The second word
is price paid in 100-credit units (`$115A–$117A`); browser money uses integer credits.
Empty slots are `null`. Procedure15 maps quality 7 to the displayed grade A.

The nine recipes require cryogen counts `[0,2,4,1,2,3,2,2,1]`, totaling 17. Initial
active/completed phase counters are both 0 (utility16 `$059B–$05A8`). Recipe data
is exported, but delivery, rewards, phase advancement and completion are pending.

## Ordinary market refresh

`refreshCityMarket` implements these rules without mutating either input:

- Game20 `$030C–$0311` uses `LESI`: first visit requires a **negative** stored day.
  For commodities 1–30 it draws supply, then demand, modulo the current quantity + 1.
  Zero quantities still consume draws. It records the current 14-bit day.
  Revisiting on day 0 does not randomize again.
- Otherwise, every whole elapsed week adds one to both tables, capped at their
  template quantities (procedure6 `$0204`, procedure5 `$037F–$03BE`). Quantities
  above their caps are lowered to the cap. A refresh records the current day,
  discarding partial weeks. Day subtraction follows the source without wraparound.
- Commodity 31 is untouched by these ordinary loops. No refill draws randomness.

The helper rejects city 60. Its visit path copies supply, clears demand and calls
the colony phase/reward logic. That coupled transaction needs further tracing;
treating it as an ordinary weekly market would lose colony progress.

## Evidence and next work

`tools/remake/economy_reference.py` independently decodes the existing clean
character capture's 58 market/warehouse records and nine packed recipes. All 57
ordinary initial markets, the empty colony market, selector and recipes match the
export/generator. Captured cargo confirms 17 distinct origins, type, quality, price
and slot layout; the captured random placement order and seed are unknown. No
exact seeded replay of that capture is claimed.

Chrome tests exercise constructed placement sequences, wrapping, occupied retries,
bounded failure, draw order, refresh boundaries, copy isolation and 1000 seed
replays. See [validation](economy-validation.md). There is no new emulator play
observation or trade UI in this checkpoint. Next: remaining global/location fields,
seed lifecycle and campaign assembly, followed by engineering and ship exits.
