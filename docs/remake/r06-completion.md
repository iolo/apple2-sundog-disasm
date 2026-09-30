# R06 completion audit

Objective: complete **R06 — City and building exploration** in PLAN-REMAKE.md.
Status: **in progress**. The full objective remains active.

| Requirement | Current evidence | Remaining work |
| --- | --- | --- |
| Live city tiles and runtime composition/variants | `city-map.js`,57 ordinary city maps, private seeded variant stream; city-map rule tests | Review special city/colony clipping and live variants against Game21; do not infer coverage from the ordinary-city tests. Navigation between worlds remains R09. |
| Ship-to-city transitions | `city-walk.js`, live airlock entry/exit, city walking and save tests/smoke | Recheck this flow with final R06 state once all building changes land. |
| Known tile/door behavior | `city-doors.js` ports every classified foot/pod footprint; bank and types9/10 are live | Complete exploration dispatch for remaining building types. Distinguish walkable rooms from later transactional service panels using source evidence. |
| Building interiors | Eight type9/10 layouts have collision, entry/exit, visitors and traffic | Type8 fixture/seating rooms and type11 lodging fixtures/doors remain excluded. Resolve the no-visitor initial-placement fallback; a known entry rejection is not complete room support. |
| Basic NPC interaction | Counter request/approach, dialogue kinds13/14, information/quotes and return are live | Extend required interaction/setup and return behavior to remaining R06 interiors; later hostile encounter/combat branches remain R10. |
| Dialogue interpreter/actions needed here | Catalogue, text, predicates, controls/actions, runner, localized counter presentation and replay saves | Cover the additional dialogue banks and actions reached by the remaining interiors. R07 purchase/cash/inventory operations stay separate. |
| Leave/reenter ship/buildings without losing state | Version8 stores active dialogue flags/attributes/workspace, queues, room traffic, return anchor and RNG; mid-dialogue replay tested | Final cross-scene/fresh-session run including every R06 building class. |
| Recorded branch in both languages | `dialogue-ui-validation.json`: equipment information branch, English/Korean, save/reload, room return | Broaden language coverage to all newly reachable R06 content as interiors are enabled. |

Next work: source-backed type8/type11 fixture composition and entry/return rules,
then their NPC/dialogue presentation and saves; special city composition review;
finally an end-to-end R06 audit against this table and the plan. Transactional
trade/banking, ground transport, travel, combat and colony-contract progression
retain their original R07–R11 ownership. This table does not move incomplete R06
exploration work into those later milestones.
