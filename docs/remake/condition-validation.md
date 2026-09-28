# Condition and item-use validation — R05c

Run date: 2026-09-28 (Asia/Seoul), using the required
`/opt/google/chrome/google-chrome`, version 154.0.8037.57.
The [receipt](condition-validation.json) contains 22 new condition smoke checks,
25 inventory checks, 23 movement checks, 25 character checks and 61 preview
checks: 156 total, all passing. The 30 dependency-free browser tests also pass.
Six Python exporter tests, 119 generated artifacts and 584 classified source
strings verify. Original disk/manual hashes match their baseline.

Five added browser rule tests cover field order, independent defaults, meter
rounding, food/rapidheal isolation, immutable transitions, single consumption,
invalid input and the complete 0–255 starting range for both effects. The cap
tests assert all 512 resulting values and item removal, including use at full.
Exporter tests independently compare all four initial bytes with the previously
captured clean-character state.

UI checks use ordinary walking and slot controls, without inserting inventory
or depleted condition into the app. They verify a full-meter warning, no direct
storage use, cancellation, locale/resize preservation, keyboard activation,
post-use focus, repeat prevention, remaining supplies, shield exclusion,
offline rapidheal use, reopen persistence and reload reset. A touch-enabled
Chrome context walks using CDP touch input, picks up food with slot taps and
consumes it using the visible action. Physical touch hardware was not tested.

English and Korean layouts fit 640×480, 1280×720 and 390×844, with the condition
meters, full warning and action visible. Reviewed desktop and portrait captures
under `output/playwright/remake/condition-*`. The first layout check found the
storage grid touching the footer; adjusted column spacing and footer padding,
then passed both the new checks and inventory regression. The preview regression
also loads a copied app at `http://127.0.0.1:8001/archive/`, browses all 78 maps
offline and confirms no external runtime requests.

Original-game evidence covers the clean starting values and a controlled
condition display. Attempted original item clicks did not establish consumption.
Successful positive restoration is covered by source-derived rule tests; browser
input tests exercise the reachable full-condition state. These evidence levels
are distinct. See [condition rules](condition.md) for source offsets and the
emulator receipt. Hunger, fatigue, sleep and campaign persistence remain pending.

Reproduce with the app on port8000 and a copied `remake/` served as `/archive/`
on port8001:

```sh
playwright-cli -s=remake open http://127.0.0.1:8000/ --config=tools/remake/chrome.config.json
playwright-cli -s=remake run-code "$(cat tools/remake/condition_smoke.js)"
playwright-cli -s=remake run-code "$(cat tools/remake/inventory_smoke.js)"
playwright-cli -s=remake run-code "$(cat tools/remake/walk_smoke.js)"
playwright-cli -s=remake run-code "$(cat tools/remake/character_smoke.js)"
playwright-cli -s=remake run-code "$(cat tools/remake/browser_smoke.js)"
python3 tools/remake/test_exports.py
python3 tools/remake/export_assets.py --check
python3 tools/remake/source_index.py --check
python3 tools/verify_inputs.py
```
