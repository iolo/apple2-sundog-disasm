# Surface map and movement source audit

R08i implements the surface core; R08j adds camera, location and independent
transport ownership reducers. Live controls, persistence and the combined R08
acceptance journey remain pending. The playable city still has its
historical stored-rectangle guard; version21 saves do not yet contain a surface
scene. No new original-game emulator capture is claimed.

## Source rules

| Source | Implemented rule |
| --- | --- |
| Game21 proc28 `$1136–$11AD` | Compose a40×24 map. Save gameplay RNG, seed the private generator with low word`3*world+39` / high word`11*world+51`, scan X outer/Y inner, replace each stored tile13 with`14+random mod7`, then restore gameplay RNG. |
| Game21 `$11AF–$1201` | Overlay ordinary cities as tile13 using each world's first/count membership and city record word5's low6 X / next5 Y bits. Stored tile13 is not a city marker until composition. |
| Game21 `$1215–$126D` | On world1, initial colony placement draws gameplay RNG modulo960 until the composed tile is at least14; then overlays city60. Subsequent visits use its persisted coordinate without further draws. The helper takes placement state explicitly; live ownership of the source pending-placement flag is not connected yet. |
| Game21 proc29 `$12D8–$12F2` | Surface tiles are28×24, with an eight-row viewport, unlike the six-row28×32 city viewport. |
| Game21 proc23 `$0C80–$0C94` | Foot visible glyph10; pod visible/alternate glyphs26/29. Both use collision glyph15. Terrain is pixel collision, not a tile-name whitelist. |
| Game21 proc10 `$02EC–$02FE`, proc25 `$0E90`, Library22 proc9 `$13AA–$13CF`, `$1470–$14BC` | Collision uses mode2 and pattern9, ignoring alternating background columns via masks`0x55/0x2a`. |
| Game21 proc12 `$0486–$050F`, `$05FA` onward | Try diagonal, X, then Y; retry a failed two-pixel request at one pixel. Scroll coordinates wrap modulo40/24. Whole-world collision wraps the sprite footprint at the seams. |
| Game21 proc12 `$05AE–$05F8`, proc11 `$030A–$03B8` | Exit when attempted camera X is strictly below`12-size` or above`17+size`, or Y below`7-half` or above`11+half`. Place the player on the city's world tile at side offsets`(0,16)`, `(21,16)`, `(11,7)` or`(11,23)`; corner crossings combine offsets. |
| Game21 proc17 `$07E4–$0841` | Entry border is X`18-size..21+size`, Y`10-half..13+half`, half=`(size+1) div2`. Ordinary size9 gives9..30 /5..18. Colony size is clamped completed phase0..9. |
| Game21 proc21 `$0AEA–$0BB9`, proc18 `$08FA–$0999` | Detect tile13 at the sprite center; resolve its city record. Entry fractions are`(x+3) mod28`, `(y-3) mod24`. Side priority: X<7, Y<12, X>20, otherwise bottom. Proportional entry tile plus saved anchor160/108 gives city pixel offsets20/12. |

The `lesi` instructions are strict less-than comparisons, distinct from `leqi`.
Tests include exact camera boundaries, X6/7 and Y11/12 entry fractions, and the
top-before-right corner priority.

## Arrival overlap and integration requirements

The original north/south surface arrival anchors overlap the city glyph under
the surface collision mask. Proc25 installs them directly; proc12 tests only
the attempted destination. The core therefore allows movement out of a blocked
starting anchor, while still rejecting every blocked destination. For city01,
north can step from347/175 to347/174; south can take a two-pixel step from347/191
to347/193. The south point still resolves to the city's contact tile. This is
not permission to accept arbitrary blocked imported positions. Live validation
must distinguish source transition anchors, and verify foot/pod cadence and
reentry behavior before claiming usable travel in both modes.

Next connect source scrolling thresholds to the live camera, expand city
geometry to the source border, introduce active city/world ground locations,
and preserve independent ship/pod/cargo domains across transitions and saves.
Keep parked vehicles out of collision/rendering when in a different domain.
Connect colony placement once to the campaign RNG and persist its coordinate.
Regional flight/markets remain R09; colony progression remains R11.

## Verification

`surface-walk.json` exports all21 original tile pixel arrays, four source glyphs,
and57 ordinary city coordinates. Python checks compare coordinates with the
independent clean-character world-table capture and glyphs with original font
bytes. The existing source hash/export manifest includes the new artifact.

Six browser rule groups cover all18 composed maps against independent bit-array
LFSR reference SHA-256 digests,57 overlays, initial/revisited colony RNG ownership,
every21×28×24 tile/sub-tile collision position against a separate pixel stencil,
seam wrapping, fallback movement, blocked/invalid requests, strict city boundary
and entry vectors, and original arrival overlap. These tests establish core
rules, not a live surface journey.

## R08j camera and location ownership

`ground-camera.js` follows Game21 proc12 `$0571–$05A5`: compute character
column`(x+3) div7` and row`(y-3) div8` relative to the saved camera. Scroll left
below column7, right above32, up below row7, down above16, with horizontal
priority. This is hysteresis, not a centered camera. The attempted origin is
tested against city exit limits before modulo wrapping. Even failed movement
requests run the camera check, as in the source.

Initial cameras follow proc26 `$102C–$104D` and proc28 `$1291–$12BF`: subtract
five tile columns and three city/four surface tile rows; wrap coordinates, then
reset a surface Y origin above20 to0. `groundWindow` wraps row fetches at24 as
an explicit browser adaptation. Native Library23 proc3 `$0182–$0194` advances
rows without wrapping, potentially reading beyond the960-byte map near a
surface seam. The browser keeps both terrain and rendering within the world
instead of reproducing out-of-map memory reads. City windows never need that
adaptation along ordinary legal camera paths.

`campaign-ground.js` adds a companion record without duplicating cargo or pixel
positions already owned by `travel` and `pod`:

| Field | Meaning |
| --- | --- |
| `worldId` | Active landed world; fixed to creation's world until regional travel. |
| `cityId` | Player's city; null means the world surface. |
| `podCityId` | Independent pod domain. Foot transitions preserve it; driving transitions update it together with pod position. |
| `colonyPosition` | Null until initial surface composition, then a persisted world coordinate. |
| `camera` | Active ground viewport's tile origin. |

Utility16 `$0592–$059A` sets source flag112 for initial colony placement.
The named `colonyPosition===null` state represents that pending flag separately
from the browser's dialogue-only flag array. First city exit places the colony
and commits the resulting encounter RNG once. Later exits reuse the coordinate.

The geometry factory expands the city to its complete composed40×24 map and
keeps legacy geometry's original guard by default. Only the ship's own city
gets its exterior, airlock spawn or docking gate. A city pod is included in foot
collision only when its domain matches the player's. Game21 proc8 `$0268–$0292`
draws an unattended pod only in scene3. Its surface foot exit (proc25 `$0E3A–$0E5D`)
retains the pod coordinate without the city expanding exit search. The reducer
therefore parks on the surface in place and checks same-domain proximity on
boarding; a foot city visit cannot summon the pod from the surface.

`ground-domain-rules-validation.json` records313 passing groups. Five new groups
cover strict camera thresholds/initialization, legacy vs expanded city bounds,
absent remote ship docking, loaded departure through a collision-routed city
boundary, parked surface pod/foot city return/retrieval, and a pod journey from
city01 to city02 and back. Cargo is a declared loaded fixture; all subsequent
movement uses actual collision steps and reducers. Ship/resources/accounts remain
unchanged, original inputs remain unchanged, and colony RNG is not consumed
again on return. These are core journeys, not normal-control browser UI journeys.

Next: add this record to the active save contract with historical validation
before migration, validate source arrival exceptions and reachable domains,
connect dynamic geometry/camera/rendering/input and surface boarding, then prove
reload and ownership in the live journey. Other-city transaction producers and
regional flight retain R09 scope; no initial-city services may be applied to a
remote city by accidentally retaining the starting map or location.
