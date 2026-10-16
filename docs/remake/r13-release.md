# R13 release validation

The standalone `remake/` folder is the deliverable. From the repository root,
serve it with:

```sh
python3 -m http.server 8000 --bind 127.0.0.1 --directory remake
```

Open `http://127.0.0.1:8000/` in Chrome. A copied `remake/` folder can be
served the same way from any local path or static host; there is no build,
backend, package install or external runtime service. ESM requires HTTP rather
than `file://`. Create a character to start the campaign. **Saves** holds four
browser-local campaign slots; saving is explicit. JSON export/import transfers
a version30 campaign to another browser or origin. The map inspector and ship
walkthrough have separate state and saves. The interface supports English and
Korean; the Sound button persists its mute choice separately from game saves.

## Acceptance evidence

| Plan gate | Release evidence |
| --- | --- |
| Fresh campaign and core journeys | The [R11 completed run](r11aq-r11-completion-validation.json) began from a new character, used ordinary controls and transactions, and finished all nine demand recipes: 61 deliveries, 17 distinct cryogens and the visible ending. No `remake/js/core/` file changed between R11 commit `23c17d0` and this release. On the current build, the [fresh two-system trade/refuel/return loop](r13a-journey-validation.json) passed 64 checks, [ordinary ground victory and peaceful negotiation](r13a-ground-negotiation-validation.json) passed 32, [ground knockout/robbery/recovery](r13a-ground-loss-validation.json) passed 14, [space victory/shield overflow/Tractor](r13a-space-fight-validation.json) passed 36, and [space loss/Comm/jettison/recovery](r13a-space-loss-validation.json) passed 44. [Final cryogen delivery](r13a-ending-action-validation.json) passed 14 current-build checks. Full diagnostic states for the large encounter runs remain under ignored `output/playwright/remake/`; the committed receipts retain checks, stage hashes and final owners. |
| Content and resource references | [R13 static audit](../../tools/remake/r13_static_audit.py) resolves 285 imports in 86 runtime modules, four HTML references, one CSS font URL, 176 named runtime resources, all 18 world/57 ordinary-city memberships, 174 dialogue message references and 29 conditional redirect targets. The [R12 audit](r12-presentation-audit.md) covers all 156 SVGs, 60 stored city maps, 18 world maps, 739 bilingual keys, dynamic item/cargo labels and vendored Mulmaru glyph coverage. Source-string verification finds 584 classified records; 175 deterministic exports and 23 exporter tests pass. City58/59 are retained inspector-only records; Banville is the playable colony city. |
| Saves and locale | [Direct migration](r13a-migration-validation.json) takes every historical campaign schema, versions1–29, to version30 exactly from a fresh state and rejects a wrong scope without changing input. The [four-slot UI journey](r13a-saves-validation.json) passes 45 checks for independent slots, fresh-page resume, export/import, invalid-import preservation, deletion isolation, offline writes and locale/resize continuity. [Five R11 milestones](r13a-campaign-stages-validation.json), from phase one to the 61-delivery ending, reopen in the current English/Korean UI and save/reload with identical complete state. Six compressed, hashed campaign fixtures and their [verifier/restorer](../../tools/remake/r13_fixture_bundle.py) make those stage checks reproducible from a clean checkout. |
| Standalone display and controls | [Isolated-copy Chrome run](r13a-clean-copy-validation.json) passes 46 checks with 534 local-only requests, no missing resources or page errors, and matching pointer coordinates and physical-pixel canvas backing at device scale1/2. At 640×480, 1280×720, 1920×1080 and 390×844, the stage remains4:3 without page scrolling. [Current Center-stage checks](r13a-campaign-stages-validation.json) prove active requirements/cargo remain scroll-reachable without overlapping the footer in English desktop and Korean portrait. R12's saved-scene audit covers ending, exchange, bank, depot, room, surface, tactical and ground combat controls. |
| Rendering and rules | Chrome155.0.8059.84 on Linux/x86_64 (Intel Core Ultra 9 275HX) sampled 120 frames each in title/inspector/ship and [180 frames](r13a-performance-validation.json) each in landed ship, active Center and composed city. Median and 95th-percentile intervals were 16.7 ms in each measured scene. This records this machine's headless Chrome cadence, not a universal device guarantee. The isolated-copy [rule suite](r13a-rules-validation.json) passes all 525 groups; R12's 110-check tactical run establishes identical complete campaign state at simulated 30/60/144 Hz. |

The visually reviewed screenshots show the [high-DPI Korean ship](release-screenshots/r13-ship-ko-dpr2.png),
[portrait inspector](release-screenshots/r13-ship-390-dpr2.png),
[active Center](release-screenshots/r13-phase-five-ko.png),
[completed ending](release-screenshots/r13-ending-ko.png),
[exchange](release-screenshots/r12a-exchange-ko-portrait.png),
[tactical view](release-screenshots/r12a-tactical-en-portrait.png) and
[ground combat](release-screenshots/r12a-ground-combat-ko-portrait.png).

To repeat the release checks from a clean checkout, restore the six ordinary
campaign checkpoints, then run the static audits and isolated-copy Chrome
checks from the repository root:

```sh
python3 tools/remake/r13_fixture_bundle.py --restore
python3 tools/remake/r12_static_audit.py
python3 tools/remake/r13_static_audit.py
python3 tools/remake/source_index.py --check
python3 tools/remake/export_assets.py --check
python3 tools/remake/test_exports.py
python3 tools/remake/browser_check.py --clean-copy
python3 tools/remake/browser_check.py --clean-copy tools/remake/r13_release_smoke.js
python3 tools/remake/browser_check.py --clean-copy tools/remake/r13_campaign_stages_smoke.js
python3 tools/remake/browser_check.py --clean-copy tools/remake/r13_migration_smoke.js
```

Use the same harness with `tools/remake/campaign_smoke.js`,
`r09_journey_smoke.js`, the `ordinary_*_smoke.js` encounter journeys,
`r11_phase_nine_cryo57_deliver_smoke.js` and `r13_performance_smoke.js` for the
other receipts. Pass `--output path.json` to retain a result. The harness uses
`/opt/google/chrome/google-chrome` through `tools/remake/chrome.config.json`.

## Intentional differences and boundaries

| Area | Release behavior |
| --- | --- |
| Presentation and controls | Separate SVGs, 4:3 scaling, English/Korean text, pointer/keyboard/touch and short transitions replace Apple II pixels, disk swapping, joystick calibration and display-control glyphs. Very small windows scroll bounded dialogs. |
| Timing and sound | The browser's movement/clock cadence and resumable planetary transitions are documented adaptations, not cycle matching. Web Audio square waves reflect the source's one-bit speaker character, not measured original pitches. |
| Saves | Four slots match the supplied disk image; the manual's eight-slot description differs. Browser JSON saves and versioned migration replace original disk-save files. No autosave or original disk-save import is claimed. |
| Exceptional source branch | The rare reward224 dialogue reaches an observed original zero-divisor fault. The browser preserves it as a stopped, recoverable conversation; it does not invent the unproven award. See [R10 audit](r10-completion.md). |
| Nonessential service and hosting | TransStation routes remain read-only; ship Navigation and pod travel carry the complete colony route. A locally served copy runs without internet, while a hosted copy has no offline restart cache. Gamepad support and a hosted PWA remain optional follow-ups. |

The R06–R12 completion audits hold the detailed source comparisons and
adaptation bounds. The R13 checks found no unresolved campaign-rule blocker.
