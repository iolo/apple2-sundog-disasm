# SunDog web remake progress

## R04a — Character allocation and persistent drafts — 2026-09-28

Implemented the five source-derived attributes, 440-point allocation budget,
escalating costs and exact refunds. Added English/Korean character editing,
normalized Unicode names, four separate IndexedDB draft slots, explicit save/load,
JSON import/export, overwrite/reset confirmations and validation before mutation.
Campaign saves use a different future contract; the interface clearly labels
these as character drafts. No world defaults or collision rules were invented.

Validation in the required Chrome 154.0.8037.57: 13 browser unit/rule/storage
tests, 25 character smoke checks, and all 61 existing preview smoke checks pass.
Checks include cost-tier boundaries and full-budget exhaustion, Unicode names,
duplicate-name transaction rollback, reload persistence, JSON roundtrip,
invalid/future imports, cancelled overwrites, escaped display text, storage
failure/export fallback, locale preservation, and three character viewport sizes.
Visually reviewed English/Korean desktop/portrait character and draft layouts.
Fixed points/footer and title introduction/action overlaps; four final title-layout
checks and About focus restoration also pass. Corrected asynchronous waits and an accidentally
duplicated block in smoke automation. Source-string verification and diff checks
pass. See `docs/remake/character-validation.md` and the JSON receipt.

R04 is partial: fresh campaign initialization, campaign save/resume, and the
playable ship are still pending. Next is named initialization/equipment state and
a successful clean new-game reference capture, followed by collision/interaction
geometry for R05. Original assets and the accepted reconstruction exception stay
unchanged; the supplied untracked PRD remains outside these commits.

## R01b — Character allocation and movement source trace — 2026-09-27

Traced the five initial attributes, 440-point budget, escalating per-point costs,
minimum values, refunds, and unspent-point warning. Recorded source offsets and
independent cost checkpoints in `docs/remake/character-creation.md`. Traced ship
motion into the native collision consumer; collision semantics remain pending.

Booted a disposable disk1 copy in MAME 0.285, reached the four-slot utility
screen and the first slot menu, then stopped the owned session. Follow-up input
did not reach character allocation. No clean-state emulator fixture is claimed.
World generation/equipment semantics and observed initialization still gate
campaign creation. R04a will expose the verified allocation rules as explicitly
labelled character drafts, stored separately from campaign saves.

## R03a — Runnable bilingual browser preview — 2026-09-27

Implemented the first static ESM app in `remake/`: title, ship/city/world
inspection views, external SVG loader and Canvas renderer, 4:3 viewport,
English/Korean catalogs, local Mulmaru, pointer/keyboard selection, tile-bank
selection, help dialog and persistent language preference. No runtime libraries
or build step. Original assets are accessed only through the copied browser
exports. The app explicitly identifies itself as a preview.

Added six browser tests and repeatable Chrome smoke automation/configuration.
Final validation: all six browser tests and 61 smoke checks pass in the required
Chrome 154.0.8037.57; all 92 generated artifacts still verify and the three
exporter tests pass. Visually reviewed the generated SVG scenes in Chrome.
English/Korean layouts and pointer transforms were checked at four viewport
sizes. All 78 maps browse after network disconnection. A copied `remake/`
folder loads at a nested static URL with no repository dependency or external
runtime requests. See `docs/remake/browser-validation.md` and its JSON receipt.

Fixed small-viewport text/control sizing, constrained header layout and a test
favicon. Corrected smoke-helper resize timing and an unsupported CLI global.
No strict cross-browser, high-DPI or gameplay-fidelity test is claimed.

Checkpoint scope: R01/R02/R03 have their first substeps implemented. New game,
ship movement, campaign saves and the remaining systems are still pending.
Next implementation work is R01b: decode and observe clean new-game state and
movement, then R04/R05: persistent playable ship. Do not replace these evidence
gates with the preview's UI state or the prior players' saved-game payloads.

## R02a — Deterministic vector/content export — 2026-09-27

Added the standalone asset exporter, three focused tests, 92 generated browser
artifacts, and local Mulmaru v1.0 WOFF2/license/provenance. Exports include 88
SVGs, 60 live cities, 18 worlds, 64 item/cargo names and source/output hashes.
All artwork is external vector path data; original source assets are unchanged.

Validation: `python3 tools/remake/test_exports.py` (3 tests pass), exporter
`--check` passes for all 92 artifacts. Checks cover HGR holes/phase bits, vector
run boundaries, live-map filtering, and ignoring residual item-name storage.
Visual inspection of these exports follows in R03's browser preview.

R02 is partial: semantic interaction geometry and remaining gameplay assets/text
will accompany their features. See `docs/remake/assets.md` for representation
limits. Next: R03a, runnable localized browser preview and viewport/input checks.

## R01a — Behavior evidence and state boundaries — 2026-09-27

Implementation authorized. Added `docs/remake/behavior-matrix.md` and
`state-contract.md`, plus a repeatable index of 584 explicitly classified
p-code string records (`python3 tools/remake/source_index.py --check`).

Traced utility new-game entry 48 → name 31 → initialization 9 → attributes 22;
initialization 21 clears the globals area while preserving the name. Located
five attribute fields and the game-20 phase-nine completion branch. Recorded
source offsets, evidence levels, intended browser checks and version discrepancies.

R01 is partial: clean-state field semantics, an observed new-game fixture and
ship movement/collision still need work. These prevent claiming a playable
new game, but do not block R02/R03's independent asset and browser foundation.
No original-game behavior was invented to fill those gaps. Defined separate
preview UI state so a content inspection scene cannot be mistaken for a save.

Validation: source index regeneration/check passed; source passages reviewed
against the recorded offsets. No emulator run or old reconstruction test rerun.
Next: R02a, deterministic SVG/content export and local Mulmaru font.

## R00 — Resource review and implementation plan — 2026-09-27

Status: planning complete; application implementation has not started.

Read [PRD-REMAKE.md](PRD-REMAKE.md), the current reconstruction handoff and
delivery checklist, source/asset indexes, reference-session reports, and the
map, save-state, dialogue and utility documentation. Inspected representative
p-code and the existing ship screenshot. Confirmed `remake/` is empty.

The supplied manual is a 22-page scan with no extractable text. Visually
reviewed PDF page 7 and pages 11–22; used existing manual notes for pages 8–10.
Identified the campaign objective and the ship, navigation, city, encounter,
banking and trade flows that must be included in a full remake.

Checked the Mulmaru repository/release and the previously linked Atari ST port
and Resurrection Project. Verified the Mulmaru v1.0 release exposes proportional
and Mono archives; downloading/vendor installation remains an implementation
task. Checked browser documentation for ESM and optional service-worker delivery.

Created [PLAN-REMAKE.md](PLAN-REMAKE.md) with:

- A resource inventory distinguishing exact reconstruction from still-unknown
  gameplay semantics, including incomplete behavior/audio coverage.
- A native JavaScript architecture using Canvas, separate SVGs, local Mulmaru,
  English/Korean catalogs and versioned browser saves.
- A stated static-hosting interpretation of “no server”; literal `file://`
  launch requires a delivery decision before browser implementation.
- Steps R01–R13 with dependencies, concrete outputs, verification gates, a first
  playable ship milestone and a full campaign completion criterion.
- Bounded reference research and preservation of the accepted 488-byte exception.

Validation: checked referenced local paths and documentation formatting before
commit. The earlier 180-test reconstruction result is historical evidence, not
a new test run. No browser gameplay, live emulator run, exporter, font download,
or application implementation is claimed for this planning checkpoint.

Next planned step: R01, establish the behavior/source matrix, clean new-game
specification, early campaign requirements and the first ship interaction fixture.
The user's supplied `PRD-REMAKE.md` remains unchanged and outside this commit.
