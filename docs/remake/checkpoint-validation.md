# Ship checkpoint validation — R04c

Run date: 2026-09-28 (Asia/Seoul). Required Chrome:
`/opt/google/chrome/google-chrome`, version 154.0.8037.57.
All 40 browser tests and 64 smoke checks pass: 27 checkpoint, 14 survival edge and
23 movement checks. See [machine-readable results](checkpoint-validation.json).

Five new browser test groups cover copied snapshot round-trips, charged item
bytes, the next hourly boundary after load, malformed/future/foreign envelopes,
invalid positions/conditions/inventories, four independent persistent slots,
connection reopening, rejected writes and transactional stale-tab save/delete.
The existing 35 groups also pass, including independent character-draft storage.
A local exhaustive comparison found no legal movement endpoint rejected by the
checkpoint codec across the 1784 connected ship positions and input directions.

The checkpoint smoke reaches stores through ordinary pointer input, advances
browser time across an hour, transfers a charged shield, saves four slots and
exports JSON. A fresh page in the same browser context loads the saved position,
condition, inventory and time while remaining paused. Import restores live state
without writing a slot; foreign imports preserve it. Cancellation, slot deletion,
keyboard focus, stale-tab conflicts, offline saving, storage failure/retry and
import without IndexedDB also pass. No game-state injection is used in this flow.

English/Korean checkpoint and movement controls fit 640×480, 1280×720 and 390×844.
Reviewed English desktop and Korean portrait screenshots. The survival edge
smoke uses isolated HTTP initial-condition replacements to reach death/exhaustion.
It verifies terminal Save/Export are disabled, closing restores dialog focus,
touch loading restores a living paused state, and explicit restart still works.
Those fixtures are not production defaults or new original-game observations.

Six Python exporter tests pass; 119 deterministic artifacts and 584 source strings
verify. Original disk/manual hashes remain unchanged. No original emulator run,
campaign save compatibility or strict cross-browser guarantee is claimed.
Fresh-page and reopened database persistence are tested; a full OS/browser restart
is not part of this receipt. Screenshots/downloads remain under ignored
`output/playwright/remake/`.

Reproduce with the static app served on port 8000 and the configured Chrome:

```sh
playwright-cli -s=remake open http://127.0.0.1:8000/ --config=tools/remake/chrome.config.json
playwright-cli -s=remake run-code "$(cat tools/remake/checkpoint_smoke.js)"
playwright-cli -s=remake run-code "$(cat tools/remake/survival_edge_smoke.js)"
playwright-cli -s=remake run-code "$(cat tools/remake/walk_smoke.js)"
python3 tools/remake/test_exports.py
python3 tools/remake/export_assets.py --check
python3 tools/remake/source_index.py --check
python3 tools/verify_inputs.py
```
