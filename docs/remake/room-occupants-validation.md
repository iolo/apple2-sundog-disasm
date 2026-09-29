# Room occupants validation — R06e

2026-09-29; Chrome154.0.8037.57 at the required
`/opt/google/chrome/google-chrome`, fresh isolated contexts through Playwright CLI.
All live campaign changes use normal UI, including JSON imports for invalid,
legacy and degenerate-state fixtures. Read-only core imports derive routes and
expected occupant positions. No original-emulator observation is claimed.

The extended `tools/remake/room_walk_smoke.js` passes84 checks. Both types are
reached through ordinary city walking (26 steps to type10,36 to type9). Checks
cover occupant rendering/count, pixel collision, entry RNG advancement, preserved
ship progress, survival time, carried-only inventory, version6 export, explicit
save and fresh-page reload, unchanged populations after reload, and new RNG draws
on re-entry. Occupied-position imports fail without replacing live state.

Version5 interiors import empty and retain their saved positions; subsequent
entry creates occupants. Preview visits preserve the campaign population. A
zero gameplay RNG fixture exercises the unresolved no-visitor fallback: the
player stays outside, paused, with no live state/RNG mutation and a localized
message. Both English/Korean interiors fit640×480,1280×720,390×844 and844×390.
Type9 English and type10 Korean screenshots were visually inspected. All four
screenshot paths/hashes are recorded in the JSON receipt; images remain ignored
local artifacts.

The94 browser rule groups include64 independent Python reference vectors covering
every layout, unsigned/degenerate states, placement retries, shrinking population
and clear tenth-candidate rejection. Tests check RNG draw counts, actor words,
owned collision rows, reachable exits, blocked occupant positions, exact saved
RNG tails, strict fields and version5 migration. The reference generator reads
original records and native patterns and uses a separate pixel-grid algorithm.

Regressions pass28 bank,44 city,45 campaign,37 equipment and14 recovery checks,
for252 UI checks in total. One city smoke initially failed at the ship airlock;
its virtual clock was still advancing between input steps. Pausing it between
explicit `runFor` calls made that regression deterministic. The complete rerun
passed without application movement changes.

Thirteen exporter tests,136 deterministic artifacts,64 population vectors,
57 city references,584 source string records and original disk/PDF hashes pass.
`git diff --check` passes. Detailed results are in
`room-occupants-validation.json`.

The scope remains initial stationary population. Native NPC movement, counter
following, dialogue, unresolved fallback behavior and other building types are
tracked in [room occupants](room-occupants.md).
