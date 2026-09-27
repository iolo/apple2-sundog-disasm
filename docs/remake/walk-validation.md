# Ship walkthrough validation — R05a

Run date: 2026-09-28 (Asia/Seoul). Required executable:
`/opt/google/chrome/google-chrome`, version 154.0.8037.57. The
[receipt](walk-validation.json) records 23 passing walkthrough checks, 19 browser
rule/localization/storage tests, 61 preview regression checks and 25 character
regression checks. Four Python export tests and all 94 generated artifacts verify.

Movement tests cover the observed MAME endpoint and required one-pixel fallback,
pointer centering, collision mask extents, interaction boundaries/landed guards,
fixed cadence, pause/release and bounded catch-up. All 1784 connected clear ship
positions are checked against nine input directions. The native endpoint belongs
to an existing play session; clean creation is a separate reference capture.
See [ship movement evidence](ship-movement.md) for sources and limitations.

Browser checks exercise pointer press/release, focused arrow keys, pause and
window blur, focus-trapped help, locale/state preservation, Escape/back focus,
reopening the walkthrough, and movement after network disconnection. CDP touch
start/cancel verifies release handling in a touch-enabled context. A DPR2 context
verifies canvas backing dimensions without changing simulation coordinates.
English/Korean layouts pass at 640×480, 1280×720 and 390×844; preview regression
also covers 1920×1080 and a copied folder served under a nested base URL.

Screenshots under ignored `output/playwright/remake/` were visually reviewed,
including English desktop, Korean portrait and the updated preview entry.
The complete campaign, ship controls, inventory and campaign save/resume are
outside this checkpoint. The 50 ms movement cadence is a browser presentation
choice; original real-time speed parity and physical touch hardware are not claimed.

Reproduce with the app served on port 8000:

```sh
playwright-cli -s=remake open http://127.0.0.1:8000/ --config=tools/remake/chrome.config.json
playwright-cli -s=remake run-code "$(cat tools/remake/walk_smoke.js)"
playwright-cli -s=remake run-code "$(cat tools/remake/character_smoke.js)"
python3 tools/remake/test_exports.py
python3 tools/remake/export_assets.py --check
```

For `tools/remake/browser_smoke.js`, also serve a copied `remake/` folder as
`/archive/` on port 8001. Walk and character smoke scripts use isolated contexts;
unit tests use a temporary database and remove it afterward.
