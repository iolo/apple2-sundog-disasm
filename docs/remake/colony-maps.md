# Colony composition — R06q

City60 is Banville on world1. Its composed map is now available in the inspector,
with a completed-phase selector from0 through9. This control changes presentation
only; campaign travel and contract progression retain R09/R11 ownership.
Records58/59 are the source's `dummy1`/`dummy2`, not active cities, and retain raw
layout inspection. All57 ordinary city maps remain unchanged.

## Source evidence

Game21 procedure17 (`src/pcode/game_21.s`, `$07E4–$0841`) recognizes city60
and reads workspace word271 byte1: **completed phase**, not active phase byte2.
Library22 procedure37 clamps the unsigned byte to0..9. It forms strict bounds
`18-p < x < 21+p` and `10-trunc((p+1)/2) < y < 13+trunc((p+1)/2)`.
The equivalent inclusive rectangle starts at x19..20,y11..12 for phase0 and
expands to x10..29,y6..17 for phase9. Source values10..255 use phase9 bounds.

Procedure26 `$0EAE–$106E` clears all960 cells, installs the city-specific private
RNG, and visits all240 packed cells in x-major order. Every cell consumes its
variant draw even when outside the colony rectangle; growth therefore reveals
stable variants. It restores gameplay RNG after composition. Procedure27
`$10C1–$10C9` limits clipping to city60. Cache flags do not change the resulting
background; the browser derives it directly.

Procedure28 `$1201–$1213` appends city60 only on world1. The initial name comes
from default city record60 at offset528+59*12 of the1440-byte world table.
World1's existing system membership selects system1; both tile banks are0.
Surface relocation under flag112 belongs to world travel, not background
composition. The dummy records also hold recipe storage in other contexts;
they must not be added as ordinary markets or destinations.

## State and validation

`composeCityMap` requires an explicit completed phase for city60 and rejects
the dummy IDs. `createCityMaps` includes the colony at phase0 by default.
The inspector precomputes all ten maps and owns `colonyPhase`, independently
of its manual raw bank, camera, language and campaign state. Exported membership
metadata adds no active economy field and does not change save version10.

`city_map_reference.py` independently reads packed source bytes, emulates
bytewise RNG carry and applies strict source bounds. Its57 ordinary and11 colony
vectors (0..9 and255) match browser hashes. This is a source translation, not a
new native emulator capture. Tests also verify retained variants, zero outside
the bounds, malformed phases, ordinary-map stability and preview ownership.

Chrome154.0.8037.57 passes198 rule groups and the expanded city inspector suite
in `colony-map-ui-validation.json`. Every phase renders offline; raw/composed
switching, language changes and four viewport sizes preserve phase and keep
controls beside the map. Korean phase0/9 screenshots were visually reviewed.
All18 exporter tests,159 deterministic artifacts and original input hashes pass.
