# Engineering inspection validation — R05e

2026-09-29: required `/opt/google/chrome/google-chrome` 154.0.8037.57 passes
65 browser groups and 89 engineering UI checks. The existing 45 campaign-flow
and 14 recovery/storage checks also pass. See the
[machine-readable receipt](engineering-validation.json).

The two new rule groups verify collision-connected access to all six interaction
regions, correct bank-limited forward/backward cycling and owned inspection copies.
The UI smoke test creates seed12345 through the normal character form and derives
collision-safe routes from the exported geometry. It walks those routes with
pointer input; it does not inject player position or game state. All six entry
systems, all 120 installed/spare component labels, unit output and aggregate
performance match the exported campaign record.

Checks cover unavailable remote access, Enter activation, component selection,
Tab/Shift-Tab trapping, Escape focus return, paused movement/time and unchanged
creation/inventory data. English and Korean fit at 640×480, 1280×720, 1920×1080
and 390×844; locale/resize preserves selection. A fresh-page saved-game load
reopens the expected engineering bay. Preview walking has no campaign equipment.
No uncaught page errors were observed. Screenshots of every bay and both locales
are under ignored `output/playwright/remake/`; their hashes are in the receipt.

The first rule-test coordinates lay inside some interaction cells but failed the
collision-reachability check. They were replaced with clear anchors found by the
connected-position traversal. This changed test destinations, not source collision
or interaction rules. A second UI pass verifies improved portrait text sizing.

Eleven exporter tests pass, all 122 generated artifacts and 584 classified strings
verify, and original disk/manual hashes match. No new emulator observation,
equipment mutation, repair behavior or save-version change is claimed.

## Reproduce

Serve `remake/` on localhost:8000 and use `tools/remake/chrome.config.json` for
the required Chrome executable. Open `/tests/` for rule/storage/localization groups.
Use the Playwright CLI's `run-code` with `tools/remake/equipment_smoke.js` for
engineering checks and screenshots. Existing regressions run in this order:

1. `tools/remake/campaign_smoke.js`.
2. `python3 tools/remake/campaign_edge_fixtures.py`.
3. `tools/remake/campaign_edge_smoke.js`.

Integrity commands:

```sh
python3 tools/remake/test_exports.py
python3 tools/remake/export_assets.py --check
python3 tools/remake/source_index.py --check
python3 tools/verify_inputs.py
```
