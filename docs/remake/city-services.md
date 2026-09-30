# Remaining city services — R06r

All classified foot doors now respond: ship boarding, the thirteen walkable
layouts for types8/9/10/11, bank inquiry, TransStation, depot and exchange.
The last three open localized read-only service visits with return and save
controls. They pause time and movement, trap keyboard focus, and preserve the
exact street anchor. This follows the existing bank inspection adaptation.
It does not enable transport, market purchases, fuel or repair transactions.

## Source dispatch and milestone ownership

Game21 procedures19/20 supply footprints; `startup_disk1.s` `$0148–$015E`
routes scene6 to Game19 for types1–3 and Game20 for types4/5. These routines
draw service interfaces, not Game18 walking interiors.

| Tile / foot type | Source behavior | Implemented here / remaining actions |
| --- | --- | --- |
| 12 / 1 | Game19 proc1 `$13B0–$13CA` -> proc15 `$09BC`; title `TransStation` at `$09CF`, destination selection | Visit/return/save; transport belongs to R09 navigation. |
| 13 / 2 | Game19 proc17 `$0C10–$0CB9`; current system Bank, Uniteller, cash/account | Existing inquiry preserved; account transactions belong to R07. |
| 14 / 3 | Game19 proc25 `$121C–$130D`; city name + ` Depot`, controls `REFUEL SHIP` `$1275`, `REPAIR SHIP` `$1297`, `BUY AUX FUEL` `$12B7` | Visit/return/save; fuel and repair services belong to R08. This is not the warehouse. |
| 15 / 5 | Game20 proc1 `$1A16–$1A19` calls proc28 with type==4; foot type5 takes false. Proc31 `$180A–$18F2` names the city Exchange and displays lots | Visit/return/save; stock initialization, quotes, purchases, warehouse/cargo transfers belong to R07. |

The pod uses the same depot type3 and exchange type4 at separate door anchors.
Those footprints remain covered by the door rule tests; driving/entry in pod mode
belongs to R08. Game20 `$026A–$0274` sets the colony flag from city==60; proc31
uses ` Center` and outstanding phase requirements there instead of ` Exch.` and
lots. This is a colony-contract service (R11), not another walking-room layout.
Current live travel remains in Drahew; other destinations require R09.

Game19 `$13D3–$13EC` restores the previous scene after service completion.
The browser clears held input and returns paused. Game20's transaction loops,
market visit refresh, resource changes and time costs are intentionally deferred
together, so a read-only exchange visit cannot silently alter stock or RNG.
The UI explicitly says these actions are not yet available, and shows no invented
prices, quantities, destinations or successful transaction messages.

## Persistence and validation

Campaign version11 (`landed-services-1`) adds `transstation`, `depot`, `exchange`
to `travel.scene`, with the existing `cityPosition` only. The codec requires
airlock reachability, fixed ship reentry position and a matching source door.
Room-only state is forbidden there. Version10 retains its historical scene
restrictions before migration, including full tavern support.

Chrome154.0.8037.57 passes200 rule groups and77 service UI checks in
`service-rules-validation.json` and `service-ui-validation.json`. Normal pointer
walking reaches all three doors; keyboard/touch enter and leave. Fresh-page
IndexedDB reload preserves every state field; mismatched-door and forged legacy
imports fail without replacing the visit. Both languages fit five viewport sizes,
including1920×1080, portrait and short landscape. Focus cycling and paused time
are checked. The Korean depot screenshot was visually reviewed.

This review closes the service classification question in R06. Final cross-scene
regression still determines milestone completion; transaction milestones remain
as originally planned. No new original-emulator capture is claimed.
