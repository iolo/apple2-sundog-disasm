# Surface map and movement source audit

R08i implements the surface core. Live travel, ownership, persistence and the
combined R08 acceptance journey remain pending. The playable city still has its
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
