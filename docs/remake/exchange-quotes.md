# Ordinary exchange quotes and offer generation — R07b

`remake/js/core/exchange.js` implements the source price calculation, eight-row
ordinary offer board and a staged market visit. These are rule foundations, not
live campaign transactions. The exchange panel remains a service preview and
campaign saves remain version12. Active markets, persisted offers, warehouse
ownership and payment commits are the next checkpoint.

## Static inputs

`data/exchange-defaults.json` exports only static fields from the shipped world
defaults, alongside existing commodity names/value bytes in `items.json`.
Game20 procedure5 `$03FD–$0410` reads system packed nibbles4 and5, relative to
word8, into locals10 and9. These are byte18's low/high halves. `priceLevel` is
the first price factor; `technologyLevel` names the factor applied specifically
to commodities16–24. The names describe pricing roles, not additional simulation
behavior. System nibble3 is also loaded but is not used by proc16.

World word7 bits3–8 identify the capital city. Bits9–14 and bits0–2 give the
first city and city count. System word5 bits2–6 and bits0–1 identify its first
world and world count. Game20 proc16 `$0BF5–$0C0D` and proc19 `$0ACA–$0B5A`
use these relationships for capital and cargo-origin comparisons. The exporter
test independently compares all 12 system price fields and all 18 world capital/
membership records with the existing clean-character capture. No new native
execution or price capture is claimed.

## Prices

Game20 proc16 `$0B6A–$0C70` begins with the commodity record's byte15, which is
the exported `valueByte`. **For commodities**, this is a base price in hundreds
of credits. This finding does not assign the same interpretation to every
personal-item byte or enable shop purchases.

Proc17 `$0A96–$0ABD` adjusts a price for a pair `(a,b)`:

- If `a >= b`, multiply by `(8 + a - b) / 8`.
- Otherwise, multiply by `8 / (8 + b - a)`.

Integer truncation happens after each factor, in this order:

| Factor | a | b | Source |
| --- | --- | --- | --- |
| Market | demand | supply | `$0BC4–$0BC8` |
| System price level | nibble4 | 8 | `$0BCA–$0BD0` |
| Lot quality | quality0–7 | 6 | `$0BD2–$0BDA` |
| Manufactured goods16–24 only | 8 | nibble5 | `$0BDC–$0BF3` |
| Non-capital purchase | 6 | 8 | `$0C1B–$0C1F` |
| Non-capital sale | 8 | 6 | `$0C10–$0C17` |

Proc18 `$0A70–$0A89` avoids intermediate signed-word overflow: if
`floor(32767 / multiplier) <= price`, divide the price before multiplying.
The equality case matters: `3276 * 10 / 8` becomes4090, not4095. The browser
retains this order. A final result above32767 is rejected instead of wrapping;
ordinary generated asking prices never reach that final overflow limit.

Sales also establish a ceiling (proc16 `$0C24–$0C64`): same-city cargo uses its
price paid; another city on the same world allows a factor10/8; another world
in the same system allows12/8; a different system uses the calculated market
price. Price paid is stored in hundreds, with the public helper accepting exact
credit multiples of100. The final Library22 proc37 clamp first raises a price
below1 to1, otherwise lowers it to the ceiling. Its branch order is preserved,
including a zero-price-paid edge case. Proc23 `$1015–$1027` makes ordinary
fuel/cryogen sales non-negotiable; the helper returns `null` for those sales.

Example: radioactives base193, demand6/supply2, system level10 and quality7
produce193 →289 →361 →406 units, or40,600 credits in a capital. Combining
the fractions and rounding only once would give a different answer.

## Eight offers and RNG order

Proc28 `$192D–$1940` fills eight rows using proc21. For each ordinary row:

1. Draw quality as `draw%4 + draw%4 + 1` (quality1–7, displayed G through A).
2. Draw the initial commodity as `1 + draw%31` using Library22 proc40.
3. Increment before probing, wrap modulo31 and replace0/1 with2. Only
   commodities2–30 can appear; fuel and cryogens are excluded.
4. Skip zero supply with a budget of32 empty probes. Skip a commodity/quality
   pair already elsewhere in the board without decrementing that budget.
5. Accept if `supply > draw%7`, otherwise continue probing with the same
   quality. The probability draw still occurs when the empty budget is exhausted.
6. An exhausted row is empty; otherwise calculate its asking price with proc16.

References: proc21 `$0DA0–$0E38`, `$0E54–$0E6A`, `$0EAE–$0EB9`; duplicate
comparison proc22 `$0CE0–$0D27`. Supply is an availability weight, not the number
of displayed units. Several qualities of one commodity may coexist; creating
the board does not consume supply. The helper bounds each row at4096 probes
and rejects a nonconverging input instead of hanging the browser.

`prepareExchangeVisit` owns a fresh `sourceRandom` stream from the supplied
continuing gameplay state. It refreshes the ordinary market using the existing
proc5/6 helper, then generates offers, and returns `{market,offers,randomState}`.
Failure exposes no partially updated market or RNG. Successful same-day visits
retain quantities but generate a new board and advance RNG. This staged result
is deliberately not yet accepted as campaign state: door validation, current-day
projection, saved board validation and account/warehouse reducers must join it.

## Next transaction boundary

Source tracing identifies the remaining coupled steps:

- Proc11 `$0676–$06CD` searches four warehouse slots or two pod slots. Proc26
  `$1522–$153B` checks space before entering the purchase loop; foot visits use
  the warehouse. Proc24 selects/stores cargo, with its purchase price and origin
  supplied by proc23 `$0FD9–$100C`.
- Proc5 `$03DA–$0432` prepares cash/account spending funds. Proc27
  `$1643–$165B` subtracts the price, stores cargo and updates supply. Proc7
  `$04A0–$0505` reconciles funds on exchange exit. These paths still need a
  tested per-transaction browser reducer and explicit save wealth rules.
- Proc20 `$0C7C–$0CD3` reduces the relevant ordinary demand/supply by `draw%3`,
  clamped to0. It does **not** always subtract one. Proc25 `$14A7–$1511`
  changes demand, adds sale proceeds and clears the sold slot.
- Proc27 can replace a random offer while shopping; the entry-board helper does
  not yet implement the Buy/Pass loop or replacement of a purchased row.

## Validation

Chrome154.0.8037.57 passes 215 rule groups, including eight new exchange groups:
source arithmetic and overflow threshold, origin ceilings, non-negotiable goods,
explicit draw tapes, empty/sparse markets, uniqueness, invalid inputs, bounded
failure and 1000 deterministic staged visits/revisits with state ownership checks.
Receipt: [exchange-rules-validation.json](exchange-rules-validation.json).
All 19 exporter tests pass; all 160 generated artifacts match the exporter.
