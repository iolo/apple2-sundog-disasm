# R06 completion audit

Objective: complete **R06 — City and building exploration** in PLAN-REMAKE.md.
Status: **in progress**. The full objective remains active.

| Requirement | Current evidence | Remaining work |
| --- | --- | --- |
| Live city tiles and runtime composition/variants | `city-map.js`,57 ordinary city maps, private seeded variant stream; city-map rule tests | Review special city/colony clipping and live variants against Game21; do not infer coverage from the ordinary-city tests. Navigation between worlds remains R09. |
| Ship-to-city transitions | `city-walk.js`, live airlock entry/exit, city walking and save tests/smoke | Recheck this flow with final R06 state once all building changes land. |
| Known tile/door behavior | `city-doors.js` ports every classified foot/pod footprint; bank and types8/9/10/11 are live | Distinguish remaining service panels from walkable rooms using source evidence. |
| Building interiors | All thirteen type8/9/10/11 layouts have collision, entry/exit, visitors and traffic. Lodging doors and tavern seats/contacts are live; staff-only entry is repaired. | Recheck in final cross-scene audit. |
| Basic NPC interaction | Counter kinds12/13/14/23 and seated kinds21/22 are live, with staff approach, small talk/jokes, quotes, tips, rental and return. | Recheck final cross-scene flow; hostile encounter/combat branches remain R10. |
| Dialogue interpreter/actions needed here | Source runner, localized counter/lodging/tavern presentation, offer controls, actual-speaker return and replay saves | Recheck final audit. Food/item purchases and trade transfers remain R07, gated before acceptance. |
| Leave/reenter ship/buildings without losing state | Version10 stores cash/dialogue, queues, room traffic, tavern seats/contacts, rental/doors, return anchor and RNG. Moving-visitor, mid-joke, mid-offer, mid-payment and closed-bedroom reload tested. | Final cross-scene/fresh-session run including every R06 building class. |
| Recorded branch in both languages | Equipment information, lodging rental and tavern joke branches have English/Korean UI receipts with save/reload and room return. | Proven for these recorded branches; preserve during final regression. |

Next work: special city composition and remaining service-dispatch review;
finally an end-to-end R06 audit against this table and the plan. Transactional
trade/banking, ground transport, travel, combat and colony-contract progression
retain their original R07–R11 ownership. This table does not move incomplete R06
exploration work into those later milestones.
