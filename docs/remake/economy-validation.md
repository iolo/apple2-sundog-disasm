# Economy validation — R04e

2026-09-28: `/opt/google/chrome/google-chrome` 154.0.8037.57 passes all 52 browser
test groups, including six new economy groups and 1000 deterministic economy seed
replays. [Machine-readable receipt](economy-validation.json).

Nine Python exporter tests pass. All 121 exported artifacts, 584 classified source
strings and original disk/manual hashes verify. The fixture decoder verifies 58
markets/warehouses and nine colony recipes from the prior clean-character capture.

The comparison covers exact initial market quantities, selector, city names and
recipes. Cargo comparisons cover count, type, quality, origin and slot layout;
the original placement sequence is unknown. Constructed sequences separately test
the source cursor arithmetic, wraparound, retries and nonconvergence. Browser
tests also cover supply-before-demand draws, zero-capacity draws, day 0 revisits,
weekly boundaries, caps, partial-week loss and cryogen exclusion from refill.

This is pure-rule and content validation. Campaign wiring, colony transactions,
trading UI and original-seed replay are not claimed. No new Apple II play session
or unrelated UI smoke suite was run. Existing browser tests all still pass.

```sh
python3 tools/remake/economy_reference.py
python3 tools/remake/test_exports.py
python3 tools/remake/export_assets.py --check
python3 tools/remake/source_index.py --check
python3 tools/verify_inputs.py
```

Serve `remake/` and open `/tests/` in the configured Chrome. Use `--write` on the
reference helper only to intentionally regenerate its checked-in test fixture.
