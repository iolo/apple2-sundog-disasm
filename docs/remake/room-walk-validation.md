# Interior validation — R06d

2026-09-29; required executable `/opt/google/chrome/google-chrome`,
Chrome154.0.8037.57, fresh isolated contexts through Playwright CLI.
All live changes use normal UI; read-only geometry imports only plan routes.
No original-emulator observation is claimed.

`tools/remake/room_walk_smoke.js` creates seed12345 and walks26 city steps to
type10, then36 steps to type9. Its56 checks verify both room types:

- Source-door entry by touch/keyboard at interior `(12,56)`, paused.
- Keyboard and pointer movement at the interior scale, time advancement,
  full-mask counter collision and doorway-only exit availability.
- Carried-only inventory, immutable creation/RNG and preserved equipment.
- Version5 export, explicit save, fresh-page reload and complete state roundtrip.
- Rejected wall-position imports preserving live state, preview isolation,
  exact street return by keyboard/touch and clearing interior-only save fields.
- English/Korean fit at640×480,1280×720,390×844 and844×390.

Four screenshots cover both layouts and languages; type9 English and type10
Korean were visually inspected. Paths/hashes are retained in
`room-walk-validation.json`; screenshots
remain ignored local artifacts. The90 browser rule groups cover all eight room
layouts, entry/exit and counter collision, reachable-position validation, owned
geometry, source record selection and version4 ship/city/bank migration.

Regressions cover28 bank,44 city-walking,45 campaign,37 equipment-exchange and14
recovery checks. Thirteen Python exporter tests include raw record bounds,
visible/collision glyphs, corridor clearing order, occupied counters and SVG/row
agreement. All135 generated artifacts,57 city references,584 source strings
and original input hashes verify. `git diff --check` passes.

These checks validate the scoped browser implementation. Fixed window placement,
local stripe phase, explicit door activation, absent NPCs and excluded building
types are detailed in [building interiors](building-interiors.md).
