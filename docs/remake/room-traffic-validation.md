# Room traffic validation — R06f

2026-09-29; required executable `/opt/google/chrome/google-chrome`,
Chrome154.0.8037.57, fresh isolated contexts through Playwright CLI. Source rules
are transcribed from Game18/library22; no original-emulator traffic capture is
claimed.

`tools/remake/room_walk_smoke.js` passes102 checks. All live mutations use normal
UI, including supported legacy and invalid JSON imports. Both building types
are reached through ordinary city walking. The test freezes its virtual clock
between explicit time steps.

Beyond entry/walking/inventory/exit checks, it verifies:

- Version6 migration reconstructs exact initial actors without advancing RNG.
- Four seconds of idle player time matches79–80 core traffic ticks, accounting
  for the browser animation-frame boundary, with changed actor state and RNG.
- Help and inventory freeze actor state, survival and RNG.
- Fresh-page save/load restores moving actor positions, targets, waiting and RNG.
- Invalid waiting counts and visible overlaps fail without replacing progress.
- Preview sessions, version5 empty-room migration and failed-entry recovery
  retain their existing isolation and behavior.
- English/Korean controls fit640×480,1280×720,390×844 and844×390.

The103 browser rule groups include controlled eager-RNG/departure transitions,
two-stage target arrival, counter service, blocked-counter settling and followed
actor identity across slot compaction.1200 steps in each of the eight rooms
exercise arrivals, removals, counter motion and service, checking valid saved
states throughout and deterministic continuation from copied state. Malformed
actors, unsupported flags/actions, invalid targets, inaccessible positions,
queue drift and visible overlaps are rejected. A regression permits legitimate
overlap of empty movement-mask margins.

Regressions pass28 bank,44 city,45 campaign,37 equipment and14 sleep/death/storage
recovery checks:270 UI checks total. Thirteen exporter tests check native glyph3
and doorway parameters alongside existing art. All136 deterministic artifacts,
64 initial population reference vectors,57 city references,584 source strings
and original disk/PDF hashes verify. `git diff --check` passes.

Type9 English and type10 Korean screenshots were visually inspected. Four
screenshot paths/hashes and detailed check names are in
`room-traffic-validation.json`; images remain ignored local artifacts.

The50ms cadence, counter-reference repair, pending player service/dialogue,
secondary movement, remaining building types and unresolved entry fallback
are described in [room traffic](room-traffic.md).
