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
