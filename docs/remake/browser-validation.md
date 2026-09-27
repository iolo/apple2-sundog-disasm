# Browser foundation validation — R03a

The [receipt](browser-validation.json) records 61 passing smoke checks in
Chrome 154.0.8037.57 using `/opt/google/chrome/google-chrome` and the committed
`tools/remake/chrome.config.json`. Six dependency-free browser tests also passed.
This validates the preview, not gameplay, campaign state, audio or saves.

The smoke run covers English/Korean across ship/city/world views at 640×480,
1280×720, 1920×1080 and 390×844. It checks 4:3 containment, absence of page
scrollbars, header separation, pointer selection, wraparound navigation,
keyboard selection, dialog focus/return, locale persistence, all maps after
network disconnection, and a standalone folder copied under a nested base.
No external runtime request, uncaught exception or failed resource response
occurred in the final run. Device pixel ratio in this run was the default;
high-DPI coverage remains for a later presentation checkpoint.

Visually reviewed title, ship, city and world views, including Korean and the
portrait title/ship. The monochrome world overview deliberately displays raw
tile 13 before the original runtime's terrain-variant/city substitutions.
The art preserves original silhouettes; it is a first vector pass.

Checks caught compact text sizing and prompted larger portrait labels/controls.
The header gives descriptions a constrained width and keeps the pager intact.
The smoke helper also needed to wait for the page's resize handler before
measuring and to avoid a URL global absent from the CLI execution environment.
A missing test-page favicon was fixed. These issues are resolved in the final
receipt; no clean run is claimed for earlier attempts.

## Reproduce

Serve `remake/` on port 8000. Copy that folder to
`/tmp/sundog-remake-check-20260927/archive/` and serve
`/tmp/sundog-remake-check-20260927/` on port 8001. That second server has no
access to the original repository's asset/source folders.

With the Playwright CLI available:

```sh
playwright-cli -s=remake open http://127.0.0.1:8000/ --config=tools/remake/chrome.config.json
playwright-cli -s=remake run-code "$(cat tools/remake/browser_smoke.js)"
```

The local skill wrapper can substitute for `playwright-cli`. Automation is
development tooling; it adds no app dependency. Screenshots go to the ignored,
regenerable `output/playwright/remake/` directory. The committed JSON receipt
retains the final check list independently of temporary logs.

For manual checks, `/tests/` under the app's static root runs the six tests.
Source/content checks remain `source_index.py --check`, `test_exports.py`, and
`export_assets.py --check` under `tools/remake/`.
