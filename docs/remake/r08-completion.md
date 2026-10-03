# R08 completion audit

Status: **complete, R08m**, 2026-10-03. This audit retains the original
R08 row in `PLAN-REMAKE.md`: equipment failures/replacement, repair/fuel services,
ship readiness, pod boarding/departure, surface traversal/return, terrain and
ship/pod/cargo ownership. The acceptance gate requires a damaged ship serviced
at proper costs, a pod reaching a supported destination and returning with
inventory intact, and rejection of invalid terrain/transitions.

## Requirement evidence

| Requirement | Implementation and authoritative evidence | Result |
| --- | --- | --- |
| Equipment failures and replacement | `equipment-failures.js` and `campaign-engineering.js` implement encoded installation, pending offsets, source burnout ordering, socket fit and atomic replacement. `r08-final-failures-validation.json` proves 28 UI checks through faulty installation, burnout, working replacement, pending/repaired reloads and invalid imports. Its carried faulty-part fixture is explicit. `r08-final-equipment-validation.json` proves 37 fresh-character exchange/shunt/cannibalization checks, item conservation and old-save imports. | Proven. |
| Hull repair and fuel services | `depot.js`/`campaign-depot.js` implement source pricing, bank-first payment, cash spill, exact funds and atomic cancellation/capacity failure. `ground-depot-regression-validation.json` proves 61 checks through repair, refuel, auxiliary purchase, warehouse transport, loaded docking and power use. `ground-services-validation.json` proves 8 outer-street parked-pod/foot-service checks. The combined journey repairs initial hull 15 to 16 and buys 16 fuel units for 145 +16×157 credits. | Proven. |
| Ship readiness and dependencies | Installed components determine output and special availability. Removing the last working unit shuts down the source-dependent controls; repaired systems must be enabled again. `r08-final-machinery-validation.json` proves 31 UI checks for guns, shields, cloaker, charges/phases, fuel depletion, attached auxiliary consumption, forced sleep, death/recovery and reload. The combined journey runs repaired equipment after servicing, with the expected 12 fuel cost. | Proven for landed machinery. Launch/orbit/warp are R09. |
| Boarding, departure, parking and return | `city-pod.js`, `parked-pod.js` and ground reducers enforce actual access, directional collision, clear foot exits, same-domain proximity and docking. The 42-check parking regression covers foot exchange/ship visits and loaded return. The 60-check final surface run extends parking/retrieval across city/surface boundaries and another city. | Proven. |
| Surface traversal and terrain | The live renderer/input uses composed source maps, saved camera hysteresis, pixel masks, one-pixel foot movement and repeated pod two-pixel requests with fallback.319 rule groups include every tile/sub-tile collision against an independent stencil, wrapped seams, strict border/contact vectors, invalid requests and source arrival recovery. A routed entry/park/board/return/save test covers all five ordinary cities and initial colony on Jondd. The live journey reaches Obburg and returns. | Proven. |
| Independent ship, player, pod and cargo ownership | `ground` records active world, player/pod domains, colony position and camera; cargo has one owner. Geometry draws the ship only in its city and a parked pod only in its own city domain. Remote boarding/loading/services are rejected. The combined 74-check journey buys two real lots, parks on the surface, visits the ship on foot, retrieves the pod, visits Obburg and docks with both lots and repaired equipment intact. Accounts and colony placement are conserved across travel. | Proven. |
| Persistence and rejected transitions | Live version 22 saves retain ground domains, camera, occupancy, resources, equipment and cargo without duplicating them. All 21 earlier schemas validate historically before migration.319 rule groups reject malformed domains, blocked imports, extra fields, duplicate cryogens, wrong camera/heading and remote service scenes. Repeated full-state exports/reloads occur in every live journey. Legacy saves initialize a camera because they did not store one. | Proven. |
| English/Korean controls, artifacts and regressions | Final surface controls/help fit 1280×720,640×480,390×844 and 844×390. Other engineering/service checks include 1920×1080.20 exporter tests and 168 deterministic artifacts pass;584 classified source-string records verify. Current failure, power, banking, trading, cargo, service, room and dialogue receipts are listed below. | Proven;319 rule groups and 1,070 UI checks pass. |

## Combined acceptance

`tools/remake/r08_journey_smoke.js` starts a fresh seed 12345 character. It reads
geometry only to plan routes; all campaign changes use ordinary controls. The
74-check `r08-journey-validation.json` records:

1. Reach engineering, remove a working part, replace a shunt and reuse the displaced
   shunt, conserving every installed/carried item; reload the changed equipment.
2. Drive to the depot, repair hull and fill fuel with exact source charges; reload.
3. Dock, walk to engineering, run guns/shields using actual installed performance
   and fuel, then turn them off and reload.
4. Buy/load two commodity lots, cross the city boundary, save/reload the surface,
   park, walk into Drahew and visit the ship without exposing remote cargo.
5. Return to the surface pod, retrieve it, drive to Obburg, park/board and reload,
   return to Drahew and dock loaded. Preserve repaired hull, changed components,
   immutable creation, both lots, accounts and original colony placement.

The separate final 60-check surface run additionally checks the updated localized
help in all four viewports. Screenshots of the Korean surface and English Obburg
arrival were inspected. No uncaught page errors were reported by passing runs.

## Evidence boundaries

Faulty carried-part and controlled power/condition fixtures deliberately exercise
failure and depletion cases. The source trader producer is independently tested;
these fixtures do not prove ordinary acquisition of a faulty engineering part in
Drahew. Regional market producers belong to R09 and combat damage to R10. The
fresh-character combined journey does not grant items, money, repaired hull or
fuel through fixtures. No random landed damage or invented timed-repair action
was added: Game 14's delayed operation is failure, and component repair replaces
parts. Hull repair is a separate depot service.

Browser movement/time cadence, explicit city-entry/parking controls, stable
surface pod pose 26 and wrapped map-row rendering are documented adaptations in
`surface-travel.md`, `parked-pod.md` and `ship-power.md`. No new native-emulator
capture or cycle-equivalent timing claim is made. Surface composition exports
all 18 worlds; live ground travel operates on the starting world until R09.
Other-city interiors/markets, launch/orbit/warp/landing and regional economics
remain R09; combat remains R10; colony deliveries/growth/ending remain R11.
These later requirements do not replace any unimplemented R08 gate.

The requirement-by-requirement audit finds no remaining R08 gate. R09 is next:
regional navigation/flight, landing and other-city economic state. The complete
game and release acceptance remain later milestones.

## Closing receipts

`r08-validation-summary.json` inventories 24 passing receipts: one 319-group rule
run and 23 UI runs totalling 1,070 checks. Embedded copies of rule results are not
added to the UI total. All runs use Chrome 154.0.8037.92 selected through
`tools/remake/chrome.config.json` and `/opt/google/chrome/google-chrome`.

| Receipt | Passing checks |
| --- | ---: |
| `ground-parking-regression-validation.json` | 42 |
| `ground-depot-regression-validation.json` | 61 |
| `ground-room-regression-validation.json` | 102 |
| `ground-services-validation.json` | 8 |
| `r08-journey-validation.json` | 74 |
| `r08-final-bank-visit-validation.json` | 28 |
| `r08-final-banking-validation.json` | 44 |
| `r08-final-cargo-validation.json` | 33 |
| `r08-final-city-validation.json` | 44 |
| `r08-final-dialogue-validation.json` | 19 |
| `r08-final-equipment-validation.json` | 37 |
| `r08-final-exchange-validation.json` | 64 |
| `r08-final-failures-validation.json` | 28 |
| `r08-final-fallback-validation.json` | 19 |
| `r08-final-lodging-validation.json` | 27 |
| `r08-final-machinery-validation.json` | 31 |
| `r08-final-matching-validation.json` | 75 |
| `r08-final-room-journey-validation.json` | 90 |
| `r08-final-rules-validation.json` | 319 rule groups |
| `r08-final-services-validation.json` | 78 |
| `r08-final-shops-validation.json` | 29 |
| `r08-final-surface-validation.json` | 60 |
| `r08-final-taverns-validation.json` | 43 |
| `r08-final-visitors-validation.json` | 34 |

Reproduction: run browser jobs sequentially with
`python3 tools/remake/browser_check.py tools/remake/<name>_smoke.js --output <receipt>`;
omit the script argument for the rule suite. The combined script is
`r08_journey_smoke.js`, the final surface script is`surface_smoke.js`, and source
mapping for each other receipt is recorded in the progress log or its feature
page. Static checks are`python3 tools/remake/source_index.py --check`,
`python3 tools/remake/test_exports.py` and
`python3 tools/remake/export_assets.py --check`.
