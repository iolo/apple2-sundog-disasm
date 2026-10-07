# R09 completion audit

Status: **complete, R09f**, 2026-10-07. This audit retains the original R09 row
in [PLAN-REMAKE.md](../../PLAN-REMAKE.md): verified regional associations and
full live maps; navigation scales and destination confirmation/cancellation;
launch, orbit, in-system travel, warp, landing; fuel, charge, time and failure
paths. Its acceptance gate is travel between two systems, land, trade, return
and reload with consistent location/resources, plus content and destination
reachability validation.

## Requirement evidence

| Requirement | Implementation and authoritative evidence | Result |
| --- | --- | --- |
| Complete regional membership and live map content | `regional-world.js` cross-checks generated navigation, economy, exchange, maps and surface records:12 systems,18 worlds,57 ordinary cities and Banville. Every destination has one world/system owner, a surface marker and composed geometry. The tested seed12345 graph connects all12 systems using source jump limits. Reserved city58/59 remain inspector records. See [regional world](regional-world.md). | Proven. |
| Star/system/planet navigation and explicit destinations | `ui/navigation.js` draws all three scales from generated positions, orbital angles/radii and city markers. A transient selection is reviewed before confirmation; cancellation leaves state, fuel and RNG unchanged.44 UI checks cover English/Korean, all three scales and640×480,390×844,844×390,1920×1080. Final English desktop and Korean portrait screenshots were visually inspected. | Proven. |
| Launch, orbit, sublight, halt, warp and landing | `campaign-flight.js` implements source clearance and equipment gates, launch/city flights, orbital targets, shortest-angle motion, HALT, charge/cancel/jump, safe radius43 points, gravity failures and source arrival sides. Game13 procedures12/26/32/34/35/36/38/39 and Library24 procedure12 supply the rules. All18 capitals and57 ordinary city landings plus Banville have geometry/access/canonical-save checks. See [flight](flight.md). | Proven; noncapital pilotage coverage uses a declared working-equipment fixture. |
| Shared fuel, charge, time, RNG and failure paths | Flight uses the existing machinery phases and clock. Source motion eagerly draws RNG, requires roll strictly below performance, interpolates signed offsets and charges phase3 fuel. Game13's successful-step arithmetic uses a left shift2; independent vectors37/153 steps give displayed ETA19/77. Charge is `3*floor(distance3D)²+10`, capped at255. Failed gravity jumps consume charge; cancellation retains stored charge. Distress sets one source delay and refills once. Guards and atomic rejection are checked. | Proven by source-derived rule vectors and live charge/failure journeys. |
| Regional markets, warehouses, accounts and cargo | One active exchange and56 dormant economies retain separate stock/warehouse state. Source origin-sensitive sale quotes credit the visited system. Global17 cryogens and all transported lots have one owner. Bank/depot/dialogue/cargo handlers use actual destination context and reject mismatched maps. The ordinary-play journey sells real home purchases abroad, refuels from the visited account and restores home stock without duplicate refresh or cargo. | Proven. |
| Ground destinations, unattended pods and colony location | Regional ground geometry uses actual ship/world/city; detached pods remain on their own world. All58 landings have valid access/spawns; an unattended Jondd pod survives foreign-world flight and return. Generated terrain validates the global colony position. Current74-check engineering/ground and60-check surface/help regressions preserve loaded parking, foot visits, retrieval, cross-city travel and return. R08's routed six starting-world destinations remain in the full rule suite. | Proven for R09 location/transport scope; colony delivery and growth remain R11. |
| Persistence and historical compatibility | Live version23 `regional-flight-1` saves actual ship/pod worlds, independent economies, motion progress, warp requirements, colony position and distress deadline. Versions1–22 validate historically before migration. Exact continuation checks cover launch, sublight, charging, landing and rescue. New counters use actual city tiles; open historical conversations retain original quote context until verified return. Forged location/interpolation/charge/stock/extra fields are rejected atomically. See [campaign saves](campaign-saves.md). | Proven. |
| Affected services, interiors and localized help | Current receipts cover banking44, exchanges64, city services78, rooms102, dialogue19, trader referrals75 and taverns43. Surface controls/help and navigation fit both locales at four viewports; economic services also test1920×1080.21 exporter tests,169 deterministic artifacts and584 classified source-string records verify. | Proven;345 rule groups and667 UI checks pass. |

## Ordinary-play acceptance

[r09-journey-validation.json](r09-journey-validation.json) records64 checks from
`tools/remake/r09_journey_smoke.js`, starting a fresh seed12345 character.
Read-only geometry/price planning selects routes and actual available board
offers. Every campaign change uses ordinary controls; no fixture grants cargo,
money, fuel, repaired equipment or destination state.

1. Walk/drive to the depot and exchange, pay for fuel, buy two offered lots for
   **22,700**, load them into the pod, dock and reach pilotage.
2. Launch, charge and attempt a real gravity-field warp. Confirm failure consumes
   accumulated charge; reload, move to a safe source warp point and save/reload
   during sublight travel.
3. Charge/jump from system01 to system02, travel to world03 and land in city09.
   Reload the foreign ground domain and verify its market owns its actual stock
   while the home market remains archived.
4. Unload and sell the two purchased lots for **35,700**, crediting only the
   visited account. Reload, pay for foreign refueling and depart.
5. Return to system01/world01/city01, reload, revisit the home exchange and verify
   preserved stock, empty sold-cargo slots, unchanged creation and retained sale
   proceeds. The audited run takes **292 game minutes** and returns with
   **fuel172**.

These final figures supersede intermediate R09d results before the flight
arithmetic and strict engine-roll audit. The navigation run independently proves
normal home launch/landing, airborne airlock guards and saved warp charging.

## Evidence and adaptation boundaries

Flight rules are source-derived from the supplied Apple II procedures/native
helpers, with independent arithmetic/boundary vectors and browser checks. No
new native-emulator flight capture or cycle-equivalent timing is claimed. The
native planetary animation becomes an explicitly documented resumable5/20
game-minute transition using its displayed ETA; it adds no invented fuel fee.
Existing browser movement/time cadence and pause behavior remain adaptations.

Full city-landing coverage uses declared working-pilotage/colony fixtures and
direct regional placement to isolate geometry, access and persistence. It does
not claim58 ordinary-play routes. The fresh-character acceptance journey proves
two-system capital travel, profitable trading and return without injected
campaign state. Connectivity is checked for the acceptance seed, not asserted
as exhaustive enumeration of every possible generated seed.

Encounters, combat damage, negotiation/evasion and tactical controls remain R10.
Banville deliveries, cryogen use, growth and the contract ending remain R11.
Their later gates do not replace any unimplemented R09 gate. TransStation
transactions remain read-only. Complete-game and release acceptance are later
milestones.

## Closing receipts

[r09-validation-summary.json](r09-validation-summary.json) inventories12 passing
receipts: one345-group rule run and11 UI runs totalling667 checks. Embedded rule
lists are counted once. All runs use Chrome154.0.8037.97 through
`tools/remake/chrome.config.json` and report no page errors.

| Receipt | Script | Passing checks |
| --- | --- | ---: |
| `r09-final-rules-validation.json` | Browser rules, no script argument | 345 rule groups |
| `r09-r08-journey-validation.json` | `r08_journey_smoke.js` | 74 |
| `r09-surface-validation.json` | `surface_smoke.js` | 60 |
| `r09-rooms-validation.json` | `room_walk_smoke.js` | 102 |
| `r09-banking-validation.json` | `banking_smoke.js` | 44 |
| `r09-exchange-validation.json` | `exchange_trading_smoke.js` | 64 |
| `r09-services-validation.json` | `city_service_smoke.js` | 78 |
| `r09-dialogue-validation.json` | `dialogue_smoke.js` | 19 |
| `r09-traders-validation.json` | `trader_matching_smoke.js` | 75 |
| `r09-taverns-validation.json` | `tavern_smoke.js` | 43 |
| `r09-navigation-validation.json` | `navigation_smoke.js` | 44 |
| `r09-journey-validation.json` | `r09_journey_smoke.js` | 64 |

Reproduce sequentially with
`python3 tools/remake/browser_check.py tools/remake/<script> --output <receipt>`;
omit the script for rules. Preserve the harness-written JSON rather than copying
possibly truncated console output. Embedded rule waits are120 seconds; UI jobs
open a blank tab to avoid starting a second rule suite unnecessarily. An initial
room timeout and a truncated intermediate report are excluded from this passing
inventory. Static checks are `python3 tools/remake/test_exports.py`,
`python3 tools/remake/export_assets.py --check` and
`python3 tools/remake/source_index.py --check`.

The requirement audit finds no remaining R09 gate. Next: R10 encounters/combat.
