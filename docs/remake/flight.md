# Flight rules — R09b

The pure campaign flight reducer implements launch, orbital and in-system
travel, warp destination charging/cancellation, jumps, landing, city flights,
halt and distress refuelling. Creation remains immutable. The moving ship,
attached pod, flight progress and gameplay RNG belong to campaign state.

| Rule | Apple II evidence |
| --- | --- |
| Charge `3*distance²+10`, maximum255; fuel/engine gates | Game13 proc32 `$1695–$16B5` |
| Cancellation retains current charge | Game13 proc34 `$1716` |
| Gravity failure and radius43/16-angle arrival | Game13 proc35 `$1760–$19F5` |
| Shortest-angle ETA, halt | Game13 proc36 `$1A4A–$1C31`, proc38 `$1C3E` |
| Probabilistic engine motion, interpolation, phase3 fuel | Library24 proc12 `$02B4–$04B8` |
| Launch clearance, shields/cloak reset, displayed5/20 ETA | Game13 proc39 `$1D5C` onward |
| Capital landing tile, other-city pilotage and side selection | Game13 proc26 `$10C4–$123B`, proc12 `$12E9–$12F1` |
| Distress delay and one-time fuel255 | Game13 proc52 `$2512–$257A`, Library24 proc15 `$0DAE–$0DF4` |

The source eagerly draws the motion RNG even when engines are off. Motion runs
before existing machinery power and uses its four-phase clock. No second clock
or fuel ledger is introduced. A detached pod stays on its original world.

Explicit browser adaptation: the native planetary animation becomes a resumable
five/twenty game-minute transition using its displayed ETA. This is not a claim
that the original overlay consumed that exact native clock duration. Planetary
travel adds no invented fuel fee. Encounter production remains R10 work.

`flight-defaults.json` exports all18 capital landing tiles and the source
ship anchor150/115; exporter tests compare these with clean-character raw data.
Ten new declared rule groups cover guards, all18 capital geometry/spawns,
interpolation, halt, charge/cancel, safe/gravity jumps, rescue and detached pods.
All335 groups pass in Chrome154.0.8037.97 with no page errors;21 exporter tests
and169 deterministic artifacts pass. See `r09-flight-core-validation.json`.
The live application/save codec still awaits regional integration; this
checkpoint does not claim the two-system UI acceptance journey.

## R09 integration and final source audit

Live Navigation uses the existing Canvas/SVG/ESM presentation and four save
slots. Its star chart uses generated3D positions for jump costs (the drawing
projects X/Y); system charts use generated orbital angles, source radii and16
radius43 points. Planet charts use all city surface markers. Destination drafts
are transient and confirmation alone changes the campaign. Ordinary destination
services use their actual world/system/city and retain separate economic owners.

The closing source audit corrected an intermediate shift transcription:
Game13 proc36 `$1BD9–$1BE2` calls Library22 proc30 (`ASL/ROL`, left shift),
not proc31 (`ROR`, arithmetic right shift). Successful motion steps are
`(abs(radiusDelta)/3 + ((abs(angleDelta)*(r0+r1)) >> 8)) << 2`, then add1;
integer division truncates. Displayed ETA at `$1C09–$1C15` is
`1 + (steps >> 1)`. Independent numeric vectors produce37 and153 steps,
with displayed19 and77 minutes. Earlier intermediate receipts precede this
correction; final rule/journey receipts establish the accepted implementation.

Colony positions likewise validate against generated source terrain, where disk
13 tiles become14–20 before city markers are overlaid. Raw disk tiles alone
cannot validate a legitimate colony location. Regional saves preserve this one
position globally while ground domains change. Banville's construction/delivery
logic remains R11. Encounter scheduling and combat remain R10.

The motion gate at Library24 `$02CD–$02D3` is `LESI` (strict less-than),
so roll1 fails at performance1 and succeeds at performance2. The final boundary
vector verifies both outcomes and phase3 fuel. Earlier intermediate motion used
an inclusive comparison; the source audit corrected it before R09 completion.

Regional counters read their actual outer city tile (Game16 proc39
`$1256–$1267`, globals38/39), rather than the world's city marker. Save23's
`legacyDialogueSurface` exists only for an open migrated historical conversation,
must equal immutable creation coordinates, and clears on its verified return.
This preserves old quoted prices while new regional conversations use the actual
entry tile. Tests cover source valuation27 at tile11/8, historical valuation33,
exact replay, invalid hints and atomic hint removal.

R09 is complete at R09f. The [completion audit](r09-completion.md) and
[validation inventory](r09-validation-summary.json) supersede intermediate
checkpoint totals:345 rule groups,667 UI checks and the audited ordinary-play
two-system trade/refuel/return/reload journey pass.
