# R06 completion audit

Objective: complete **R06 — City and building exploration** in PLAN-REMAKE.md.
Status: **in progress**. The full objective remains active.

| Requirement | Current evidence | Remaining work |
| --- | --- | --- |
| Live city tiles and runtime composition/variants | `city-map.js`,57 ordinary city maps, private seeded variant stream; city-map rule tests | Review special city/colony clipping and live variants against Game21; do not infer coverage from the ordinary-city tests. Navigation between worlds remains R09. |
| Ship-to-city transitions | `city-walk.js`, live airlock entry/exit, city walking and save tests/smoke | Recheck this flow with final R06 state once all building changes land. |
| Known tile/door behavior | `city-doors.js` ports every classified foot/pod footprint; bank and types9/10/11 are live | Complete tavern dispatch; distinguish other service panels from walkable rooms using source evidence. |
| Building interiors | Nine type9/10/11 layouts have collision, entry/exit, visitors and traffic; empty-population entry is repaired. Lodging rental opens bedrooms and saves behind closed doors. All thirteen foot layouts export source fixtures. Type8 core seating/traffic/contact return now passes four-layout simulations. | Connect type8 traffic to live entry, player input, dialogue and campaign saves. |
| Basic NPC interaction | Counter request/approach, dialogue kinds13/14/23, information/quotes, paid lodging and return are live | Extend interaction/setup and return to taverns; later hostile encounter/combat branches remain R10. |
| Dialogue interpreter/actions needed here | Catalogue, text, predicates, controls/actions, runner, localized counter/lodging presentation and replay saves | Cover tavern dialogue and required actions. Other purchases and trade transfers remain R07. |
| Leave/reenter ship/buildings without losing state | Version9 stores active cash/dialogue, queues, room traffic, rental/doors, return anchor and RNG; mid-payment and closed-bedroom reload tested | Final cross-scene/fresh-session run including every R06 building class. |
| Recorded branch in both languages | `dialogue-ui-validation.json`: equipment information; `lodging-ui-validation.json`: rental quote/payment, English/Korean, save/reload and room return | Add tavern language coverage. |

Next work: integrate the type8 traffic controller with NPC/player dialogue and saves; special city composition review;
finally an end-to-end R06 audit against this table and the plan. Transactional
trade/banking, ground transport, travel, combat and colony-contract progression
retain their original R07–R11 ownership. This table does not move incomplete R06
exploration work into those later milestones.
