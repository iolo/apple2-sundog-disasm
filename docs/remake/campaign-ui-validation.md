# Campaign UI validation — R04h

2026-09-28: required `/opt/google/chrome/google-chrome` 154.0.8037.57 passes
63 browser rule/localization/storage groups, 45 campaign-flow checks and
14 campaign recovery/storage checks. Existing character (25), checkpoint (27)
and title (four layout checks plus About focus) regressions pass. Six additional
boarding checks confirm the entrance reaches full opacity with normal browser
time. See the [machine-readable receipt](campaign-ui-validation.json).

The campaign flow uses ordinary UI actions in isolated browser storage: validates
the character/seed, boards seed12345, walks to stores, transfers a charged item,
saves all four slots, exports, closes the page and reloads explicitly from the
title. Identity, position, time, item byte and condition survive. Invalid imports,
cancelled replacement, deletion, offline saves and preview/campaign separation
are checked. Both locales fit boarding and save screens at 640×480, 1280×720
and 390×844. Existing title checks caught and verified a corrected text/action
overlap. Screenshots are under ignored `output/playwright/remake/`.

Recovery fixtures modify only active condition/time in a valid exported game,
then enter through the normal import UI. Forced sleep blocks saves and Escape;
waking pauses; death offers load/back without reset or save; a living save clears
death. Blocking IndexedDB in a fresh document still permits import/export and
preserves the campaign after failed storage retry. Random seed generation and
return focus on reopening boarding are also checked. No uncaught page errors.

Browser-clock screenshots initially caught a partially completed CSS entrance.
The normal-time visual check confirms completion; campaign screenshot capture now
finishes animations explicitly. This was a capture issue, not a gameplay change.

Eleven Python exporter tests pass. All 122 generated artifacts, 584 classified
source strings and original disk/manual hashes verify. No original disk content,
save schema or creation recipe changed in this checkpoint.

## Reproduction

Serve `remake/` on localhost:8000 and open the configured Chrome session using
`tools/remake/chrome.config.json`. Open `/tests/` for the 63 test groups. Run the
following CLI `run-code` scripts in order:

1. `tools/remake/campaign_smoke.js` (writes the base JSON export).
2. `python3 tools/remake/campaign_edge_fixtures.py` (prepares recovery imports).
3. `tools/remake/campaign_edge_smoke.js`.
4. `tools/remake/boarding_visual_smoke.js` (normal-time screenshots).

Regression scripts: `title_smoke.js`, `character_smoke.js`, `checkpoint_smoke.js`
under `tools/remake/`. Integrity commands:

```sh
python3 tools/remake/test_exports.py
python3 tools/remake/export_assets.py --check
python3 tools/remake/source_index.py --check
python3 tools/verify_inputs.py
```
