# Campaign save/resource validation — R04g

2026-09-28: required `/opt/google/chrome/google-chrome` 154.0.8037.57 passes all
61 browser test groups. Eleven Python exporter tests pass; 122 generated artifacts,
584 classified source strings and original disk/manual hashes verify.
See the [machine-readable receipt](campaign-save-validation.json).

New checks cover all four hull outcomes, exact one-draw consumption and corrected
generation order, independent resource/location state, and the captured resource
defaults. The independent reference decoder now projects four location records,
resource words and power/attachment flags. A synthetic nonzero record distinguishes
word offsets and flags that otherwise all start at zero in the clean capture.

Save tests cover complete creation-record plus active-ship round trips, arbitrary
JSON object key order, charged item preservation, day-crossing elapsed time,
independent objects and owned content baselines. Twenty-two invalid envelope/state
mutations, stale recipes, malformed/oversized text and foreign formats are rejected.
Four separate campaign slots survive a database reopen. Stale-tab writes/deletes
abort, invalid writes preserve existing records, and explicit deletion leaves
other slots intact. Test databases are isolated and deleted after use.

Existing browser tests still pass, including 100 corrected campaign seed replays.
No UI change or new original-emulator observation was performed. The save scope is
limited to existing ship walking/inventory/survival behavior; it cannot silently
accept later navigation, market, machinery or colony changes.

```sh
python3 tools/remake/campaign_reference.py
python3 tools/remake/test_exports.py
python3 tools/remake/export_assets.py --check
python3 tools/remake/source_index.py --check
python3 tools/verify_inputs.py
```

Serve `remake/` and open `/tests/` with the configured Chrome for the full suite.
