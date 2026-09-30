# R06 completion audit

Objective: complete **R06 — City and building exploration** in PLAN-REMAKE.md.
Status: **complete — R06s, 2026-09-30**. Every requirement below has evidence.
The next milestone is R07; the full remake is not complete.

| Requirement | Evidence | Result |
| --- | --- | --- |
| Live city tiles and runtime composition/variants | `city-map.js`;57 ordinary maps plus Banville's ten completed-phase maps. Independent packed-byte/RNG references and120 inspector checks; records58/59 identified as reserved dummies. | Pass. `colony-maps.md`, `colony-map-ui-validation.json`. |
| Ship-to-city transitions | Source glyphs/anchors, collision and boarding proximity;44 city UI checks and the final continuous route. | Pass. `r06-final-city-walk.json`, `r06-journey-validation.json`. |
| Known tile/door behavior | Every classified foot/pod footprint tested. All foot doors enter the ship, a room or the proper service panel; source dispatch reviewed. | Pass. `city-services.md`,77 service and28 bank checks. |
| Building interiors | All thirteen type8/9/10/11 layouts, collision, fixtures, exits and source selection. Core checks cover tavern seats and all four lodging doors;102 room UI checks plus specialized tavern/lodging tests. | Pass. `r06-final-room-walk.json`, `room-fixtures.md`. |
| Basic NPC interaction | Visitors, staff approach, queue/seat scheduling, kinds12/13/14/23 and21/22, social branches and actual-speaker return. Deterministic simulations and live/save checks. | Pass. `room-traffic.md`, `room-counter.md`, `tavern-dialogue.md`. |
| Dialogue interpreter/actions needed here | Source selection, text/setup, predicates, controls/effects, localized presentation, offers and replay saves. Information, rental, joke and tip paths are live. | Pass.200 rule groups,19 dialogue,27 lodging and36 tavern UI checks. |
| Leave/reenter ship/buildings without losing state | Version11 saves validate street anchors, cash/dialogue, queues, traffic, seats, contacts, rental/doors and RNG; versions1–10 validate before migration. Every building class reloads in the continuous route. | Pass.90 journey checks and specialized mid-conversation/closed-bedroom regressions. |
| Recorded branch in both languages | Equipment information,67-credit lodging quote and matched tavern joke retain exact state/RNG through localization and reload. Receipts store the English/Korean branch text. | Pass. `r06-final-dialogue.json`, `r06-final-lodging.json`, `r06-final-tavern.json`. |

## Final validation

Chrome154.0.8037.57 at `/opt/google/chrome/google-chrome` passes all200 browser
rule groups (`service-rules-validation.json`, repeated by final movement suites).
Final UI receipts contain90 journey,77 service,36 tavern,27 lodging,19 dialogue,
102 room,28 bank and44 city checks: **423 checks**, with no reported browser
exceptions. The separate colony inspector checkpoint passed120 checks. These
counts are assertions within overlapping suites, not distinct gameplay features.
All18 exporter tests,159 deterministic artifacts,57 ordinary/11 colony reference
vectors and original disk/manual hashes pass. The final aboard-ship screenshot
was visually reviewed, as were the colony and service checkpoint screenshots.

Reproduce the final route using:

```sh
python3 tools/remake/browser_check.py tools/remake/r06_journey_smoke.js --output docs/remake/r06-journey-validation.json
```

The corresponding `*_smoke.js` scripts under `tools/remake/` reproduce each
`r06-final-*.json` receipt. They use isolated browser contexts and the required
Chrome executable. Run browser helpers sequentially because they share port8000.
No additional R06 implementation or validation work remains from this audit.

## Final route evidence

`tools/remake/r06_journey_smoke.js` starts a fresh seed12345 campaign through
the normal character UI. Its90 checks cover a continuous558-step street route:
ship -> tavern -> bank -> equipment shop -> depot -> item shop -> exchange ->
lodging -> TransStation -> ship. Geometry is read only to find routes; every
live transition uses ordinary pointer/keyboard/click input, with no fixture
imports or direct writes to application state.

Each walking interior is entered, walked, saved, reloaded in a fresh page,
switched to Korean and back, exited and reentered. Each service is likewise
saved/reloaded and revisited. Snapshots compare all state across reload and
locale changes, exact street anchors on return, and inventory/condition/time,
equipment, creation data and RNG across transitions. Room entry consumes RNG;
exit clears visit-only actors without rewinding it. The final ship save resumes
exactly. Receipt: `r06-journey-validation.json`.

## Scope and deliberate adaptations

R06 integrates57 ordinary city backgrounds and the colony's completed-phase
backgrounds. Live walking uses the starting city until R09 adds navigation and
mutable locations. Records58/59 are reserved dummies, not missing destinations.
The thirteen foot layouts comprise four taverns, eight shops and one lodging.
Pod dispatch is classified/tested, with live pod operation belonging to R08.

The source dialogue runner and effects needed for these visits are implemented.
Trade/food/item payment branches are gated before unsupported acceptance;
lodging payments and bartender tips are live because they enable room access
and basic social interaction. Hostile ground/space encounters retain R10 scope.
TransStation, depot, bank and exchange are service panels; their transactional
actions are the explicit R07–R09 work in the original plan. The colony Center
contract branch is R11. These are not hidden walkable interiors.

Browser adaptations remain explicit: localized HTML conversation/service panels,
explicit enter/leave controls, paused inspection, fixed50ms movement/traffic
steps, replay-based dialogue persistence, and repaired empty-population fallback,
queue cancellation and mover/reservation bookkeeping. Source traces and independent
vectors support the rules; this final audit does not claim new native captures
or completion of the full game. Detailed evidence lives in the linked milestone
documents, including `room-fixtures.md`, `room-counter.md`, `tavern-traffic.md`,
`tavern-dialogue.md`, `colony-maps.md` and `city-services.md`.
