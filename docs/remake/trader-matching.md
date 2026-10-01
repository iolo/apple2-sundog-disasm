# Bartender trader matching — R07h

The bartender's Buy/Sell branches now create a pending request. Select an item,
read the instruction to sit, and take a free table. Visitors continue using the
room's movement, collisions and seat reservations. A visitor assigned opposite
the seated player carries the requested item and opens the source kind17 trade.
No trader is teleported or spawned by the request itself.

Accepting a quote exposes the existing explicit slot handover. Purchases require
an empty carried slot and sufficient cash; sales remove the chosen complete item
byte of the quoted type. Cash, inventory and gross sale income commit together
on dialogue return. Refusing the referred trader clears the request without a
transfer. Completed handovers survive leaving the conversation and reloads.

## Source correspondence

| Source | Implemented behavior |
| --- | --- |
| Game16 records26–30; builtin3 | Buy lists available requested items; Sell lists carried items. Return records flag65, selling flag66 and the workspace item byte. |
| Game18 proc8 `$01AE–$0316` | When flag65 and the player's seated state are both set, start the search at the player's table without the two random group/side draws. Reserve a free seat and respect sprite collisions. An opposite visitor receives bits0/1, mood4 and the requested high item byte. |
| Game18 proc28 `$17A0–$17E1` | A pending request skips the leave-coin draw and retargets the selected visitor. Existing movement and arrival rules remain active. |
| Game18 proc12 `$072A–$074A` | Arrival opposite the player selects kind17 when visitor bits0/1 are set, kind22 for bit0 alone, otherwise kind21. |
| Game18 proc24 `$13FE–$1427` | Sitting opposite an existing visitor selects kind17 only when both visitor bits and flag65 are set; otherwise it selects kind21. |
| Game16 proc39 `$12AA–$12E7` | Kinds17/22 consume flag66 as the trading direction, use mood4 and the speaker's item/gate. Kind17 starts at record32; kind22 starts at33. |
| Game16 proc11 `$0525–$0542` | Appraisal may add128 to an already charged item byte. Local41 remains an integer through predicates and quotes; sale matching uses its item type and handover removes the actual selected inventory byte. |
| Game16 builtin4; Game18 proc21 | Clear request/mode/item on the trade exit, resume the actual speaker through the existing return mover, and write back that speaker's mood/gate. |

The request is represented by existing source flags/workspace, not a duplicate
campaign queue. A transient room frame derives its solicitation from them.
Consequently the source's workspace and flag changes in intervening conversations
remain effective. Leaving a room discards its actors; source flags may survive
outside, but fresh room entry clears flags64–71 and begins a new visit.

## Save boundary

Version17 uses scope `landed-trader-matching-1`; the eight top-level state parts
are unchanged. It permits pending requests, kind17 contacts and the visitor's
high item byte. Contacts still require a real seated opposite actor and an active
replay record. Staff item bytes, malformed mood bytes, missing actor flags and
orphan contacts are rejected.

Versions1–16 pass their original field and dialogue-input checks before migration.
Version16 retains its pod, cargo, market and account state exactly; it cannot
claim pending matching, kind17 contacts, encoded trader items or new bartender
Buy/Sell inputs. Open dialogue restores from its original RNG and input history,
including consumed selling mode and pending transfer receipts. Completed income
commits once. Save validation checks consistent progress, not authenticated
transaction history.

## Verification

Rule tests cover both request directions, real visitor movement and arrival,
deterministic resume, before/after-handover saves, refusal, invalid slots,
accounts/cargo preservation, historical replay gates and loaded version16
migration. All four taverns and six seats are checked against the source's six
arrival draws instead of eight. Sixty-four appraisal seeds exercise charged-item
sales, including internal values above255.

`tools/remake/trader_matching_smoke.js` imports a documented pre-request tavern
fixture, then uses UI controls for the referral, tip, walk to a free table,
visitor arrival, purchase/sale/refusal, departure and fresh entry. It reloads
pending requests, contacts, handovers and completed trades. This is a controlled
fixture journey, not a fresh-character journey or a native emulator capture.
Fresh-character bank, foot exchange and pod cargo journeys are separate R07
regressions. English/Korean controls fit four viewports; the Korean landscape
screenshot was visually inspected, including all slot and footer buttons.

See `trader-matching-validation.json` and `r07-final-rules-validation.json` for
the current receipts, and [R07 completion audit](r07-completion.md) for closure.
