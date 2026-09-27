# SunDog web remake progress

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
