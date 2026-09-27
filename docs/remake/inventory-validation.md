# Inventory validation — R05b

Run date: 2026-09-28 (Asia/Seoul). Required Chrome executable:
`/opt/google/chrome/google-chrome`, version 154.0.8037.57.
The [receipt](inventory-validation.json) records 25 inventory smoke checks,
25 browser rule/storage tests, 23 movement regression checks, 61 preview checks
and 25 character checks. All pass. Six Python exporter tests verify the fresh
inventory bytes, composed glyph quadrants and existing artwork/data contracts;
all 119 artifacts and 584 classified source strings verify.

The inventory tests exercise remote-container rejection, invalid slots, empty
sources, immutable transitions, full pockets, occupied-slot swaps, item
conservation and complete-byte preservation. Both storage locations are reached
through the collision rule. Browser input tests use ordinary walking, selection
and controls; they do not inject inventory or player positions into the UI.

Chrome checks cover opening/closing, focus trapping/restoration, cancel/Escape,
closing while selected, locale changes preserving selection and charge, offline
transfer, reopening, and reload reset. English/Korean layouts fit 640×480,
1280×720 and 390×844. A touch-enabled context performs CDP touch movement followed
by actual slot taps to carry the charged shield. The movement regression also
checks touch cancellation and DPR2 rendering. Physical touch hardware was not used.

Screenshots under `output/playwright/remake/inventory-*` were visually reviewed.
Review removed a repeated opacity animation that briefly showed the ship beneath
the inventory on each selection. Pointer automation was corrected to aim inside
a source pixel rather than on its floating-point boundary; gameplay code did not
change for that correction. The reachable locker anchor is (83,110), before the
wall at the initially tested (84,110).

An original-game food pickup/place was observed in MAME on disposable media;
see [inventory evidence](inventory.md) and its linked memory/screenshot receipt.
It uses an existing play session. Initial inventory bytes are independently
checked against the earlier clean-character capture. No campaign initialization,
item consumption, engineering, survival clock or campaign save/reload is claimed.

Reproduce with the app on port 8000 and a copied `remake/` served as `/archive/`
on port 8001 for the preview regression:

```sh
playwright-cli -s=remake open http://127.0.0.1:8000/ --config=tools/remake/chrome.config.json
playwright-cli -s=remake run-code "$(cat tools/remake/inventory_smoke.js)"
playwright-cli -s=remake run-code "$(cat tools/remake/walk_smoke.js)"
playwright-cli -s=remake run-code "$(cat tools/remake/character_smoke.js)"
playwright-cli -s=remake run-code "$(cat tools/remake/browser_smoke.js)"
python3 tools/remake/test_exports.py
python3 tools/remake/export_assets.py --check
python3 tools/remake/source_index.py --check
python3 tools/verify_inputs.py
```
