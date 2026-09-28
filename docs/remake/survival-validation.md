# Survival validation — R05d

Run date: 2026-09-28 (Asia/Seoul). Required Chrome:
`/opt/google/chrome/google-chrome`, version 154.0.8037.57.
All 104 smoke checks pass: 23 ordinary survival, 11 edge fixtures, 25 inventory,
22 consumable and 23 movement checks. See [machine-readable results](survival-validation.json).

The 35 browser tests pass, including five new survival groups. They verify the
hour boundary, all drain-band edges, health-recovery thresholds, low-condition
penalties, the three recorded MAME outcomes, sleep iteration ordering, recovery
cap, exhaustion/waking threshold, terminal state, midnight carry, independent
copies, frame partitioning and bounded catch-up. Six Python exporter tests also
verify the original zero clock and condition bytes against the independent clean
capture. All 119 artifacts and 584 classified strings verify; original input hashes
remain unchanged.

The ordinary survival smoke walks to stores using normal input, advances the
browser clock across an hour, checks natural depletion, eats carried food and
restores rest through sleep. It covers inventory pause, sleep pause, lost-focus
pause, focus trapping/restoration, Escape, offline sleep, reopening, Return to
start and reload. English/Korean sleep layouts fit 640×480, 1280×720 and 390×844;
desktop and portrait screenshots were visually reviewed. It changes browser
time with Playwright's clock API, not game state.

A separate edge smoke replaces the initial inventory HTTP response only inside
isolated test contexts. Depleted-condition fixtures reach forced sleep and death
after one hour. Checks cover automatic focus, blocked early waking/Escape,
recovery unlocking wake, touch waking, frozen terminal time and explicit restart.
These are test fixtures, not alternate shipped defaults or production test hooks.
Existing inventory, consumable and movement smoke suites also pass.

Original-game observation is limited to three controlled hourly transitions.
Original sleep-loop recovery, forced sleep and death are source-derived and tested
in the browser; they were not independently observed in MAME. Original consumable
use is still unverified. Wall-clock calibration, equipment simulation, outdoor
sleep events, temporary attributes and campaign persistence remain pending.

Reproduce with the static app served on port 8000 and the configured Chrome:

```sh
playwright-cli -s=remake open http://127.0.0.1:8000/ --config=tools/remake/chrome.config.json
playwright-cli -s=remake run-code "$(cat tools/remake/survival_smoke.js)"
playwright-cli -s=remake run-code "$(cat tools/remake/survival_edge_smoke.js)"
playwright-cli -s=remake run-code "$(cat tools/remake/inventory_smoke.js)"
playwright-cli -s=remake run-code "$(cat tools/remake/condition_smoke.js)"
playwright-cli -s=remake run-code "$(cat tools/remake/walk_smoke.js)"
python3 tools/remake/test_exports.py
python3 tools/remake/export_assets.py --check
python3 tools/remake/source_index.py --check
python3 tools/verify_inputs.py
```
