# Character draft validation — R04a

Required Chrome executable: `/opt/google/chrome/google-chrome`, version
154.0.8037.57, configured through `tools/remake/chrome.config.json`.
The [receipt](character-validation.json) contains 25 passing character smoke
checks, 13 passing browser rule/localization/storage tests, and 61 passing
preview regression checks. Four final title-layout checks and About focus restoration
also pass after the title layout adjustment. Run date: 2026-09-28 (Asia/Seoul).

Coverage includes original cost tiers and independent budget checkpoints,
refunds/minima, invalid and overspent allocations, normalized Korean names,
four isolated slots, IndexedDB reopen, duplicate-name transaction rollback,
reload/load, JSON download/import, future-version rejection without mutation,
cancelled overwrites, HTML-safe name display, language changes, storage failure,
and export availability without IndexedDB. Character layouts were measured at
640×480, 1280×720 and 390×844 in both locales. The preview regression also covers
1920×1080, offline map browsing and a copied folder under a nested static base.

Screenshots in ignored `output/playwright/remake/` were visually reviewed.
This caught and fixed a points/footer overlap and title introduction/button overlap.
The title now puts About in the footer; a wider portrait introduction clears the
two title actions. `tools/remake/title_smoke.js` reproduces the final title checks. Smoke automation needed a
null-safe wait for asynchronously rendered slot controls and removal of an
accidentally duplicated cancellation test block. Final receipts reflect clean
runs after these fixes.

Korean text entry and normalization are tested, plus a synthetic composition
Escape event; a real OS input-method session is not claimed. Persistence checks
reopen the database and reload the page, not restart an entire browser process.
No high-DPI, cross-browser, campaign-playthrough or emulator allocation parity
claim is made. The original-game reference limits are in `character-creation.md`.

Reproduce with the app served on port 8000:

```sh
playwright-cli -s=remake open http://127.0.0.1:8000/ --config=tools/remake/chrome.config.json
playwright-cli -s=remake run-code "$(cat tools/remake/character_smoke.js)"
```

The character smoke creates an isolated browser context and closes it afterward.
It writes JSON exports and screenshots only under the ignored output directory.
`/tests/` uses a temporary, uniquely named IndexedDB database and removes it.
For preview regression, additionally serve a copied `remake/` as `/archive/`
on port 8001, then run `tools/remake/browser_smoke.js` the same way.
