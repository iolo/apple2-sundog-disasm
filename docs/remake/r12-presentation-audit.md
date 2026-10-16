# R12 presentation and audio audit

R12 completes the playable campaign's presentation pass. The map inspector
remains a separate, read-only preview. Hosted offline caching was deliberately
left out: the static folder runs without internet when served locally, while a
hosted copy requires a connection on a fresh visit. This is the optional R12
choice, not a missing gameplay resource.

| R12 requirement | Implementation and evidence |
| --- | --- |
| Reachable artwork | The exporter now includes ground encounter glyphs 22–25 as source-derived SVGs. All 156 catalog SVG paths exist and contain no raster embeds. Room/door, pod-heading, city and world tile references are audited against every generated map. Dynamic encounter masks remain source-bit Canvas composition; their actor glyphs use SVG. `r12_static_audit.py` and `export_assets.py --check` pass. |
| Sound | Short square-wave cues are inspired by the source's one-bit `$C030` speaker, with browser-specific pitches and timing. A single sound preference applies to title, inspector, character editor, ship, dialogs and saves; Web Audio starts from an action and mute zeros output immediately. Unsupported audio disables the control. See [audio.md](audio.md), the browser audio/layout receipt and the browser audio test. |
| Transitions and controls | A brief reduced-motion-aware reveal marks scene changes; help covers navigation, encounters and Banville's contract. The completed Center shows the fulfilled ledger and a save reminder. Tactical right-click now actually fires after being accepted by the surface. |
| English/Korean and font | Both locale catalogs have the same 739 keys and matching interpolation. The audit covers 187 static UI keys, all 165 dialogue messages and the runtime cargo/item label families. Every locale character and non-ASCII UI literal is in the vendored Mulmaru font; unsupported minus/chevron symbols were replaced. |
| Small screens and network | Required Chrome checks enabled controls at 1280×720 and 390×844 across title, setup, help, ship, saves, ending, exchange, bank, depot, room, surface, tactical and ground combat, including scroll access to the last offer. Separate tactical checks cover 640×480, 390×844, 844×390 and 1920×1080 in both languages. Browser receipts report no uncaught errors or external requests. |

Receipts: `r12a-audio-layout-validation.json`,
`r12a-saved-layout-validation.json`, `r12a-ground-validation.json`,
`r12a-space-validation.json`, `r12a-ending-regression-validation.json` and
`r12a-rules-validation.json`. The final browser environment is Chrome
155.0.8059.84 at `/opt/google/chrome/google-chrome`. The `output/playwright/remake/`
screenshots are local visual-QA artifacts, not runtime dependencies.

The pitch pattern, accent colors and transition duration are adaptations, not
claims of exact Apple II timing. The R13 release gate will repeat the core
journeys and document final run instructions and remaining intentional
differences.
