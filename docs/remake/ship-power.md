# Ship power and automatic auxiliary fuel — R08e

`ship-power.js` implements the recovered power-phase arithmetic and both automatic
auxiliary-fuel helpers. **Only the pod-docking helper is connected to live play in
this checkpoint.** Power controls, phase/clock ownership and general machinery
fuel depletion still require campaign integration. R08 remains incomplete.

## Power phase source trace

The source core accepts six equipment performance values, a phase1–4 and an owned
session of source flags, words, two cargo lots and RNG. Words222/223 are warp
target/current charge,224/225 shield target/current charge,226 guns and227 fuel.
It composes with R08c's `equipmentDependencyResult`; it does not silently apply
that routine on every tick, because dependency cleanup belongs to recalculation.
Unrelated flags/words and caller-owned state remain unchanged.

| Source in `library_24.s` | Implemented rule |
| --- | --- |
| Proc14 `$0AAC–$0AC1` | Return the signed proposed step unless it passes the target in the requested direction; otherwise return target minus current. |
| Proc15 `$0BE2–$0C4B` | Guns update on phases1/3. The raw phase branch uses Pascal FJP's low-bit test, not JavaScript nonzero truth. With positive working fuel, nonzero gun performance and flag2, add `(performance+1)*16`, bounded at255; charge4 fuel only for positive gain. Otherwise positive gun charge decays by8, bounded at0. |
| Proc15 `$0C4D–$0CA5` | Phase2 approaches shield target using `performance*8` with direction+1. Lowering the target immediately returns its negative difference, rather than a gradual decrement. Maintenance is `(target+1) div64`, including when charge is already at target. |
| Proc15 `$0CA6–$0CBC` | Phase3 spends12 more fuel when cloaker flag12 is set, after that phase's gun update. |
| Proc15 `$0CBD–$0D30` | Phase4 warp growth draws RNG and compares its low nibble with performance. A successful draw adds up to8 toward target. Both success and failure spend2 fuel. Discharge uses a bounded−4 and costs nothing; equal charge/target draws nothing. |
| Proc15 `$0D32–$0D56` | Set word350 when armed word349, flag0 and an upward step reaching target all hold. This reports the source request; it does not execute travel. |
| Proc17 `$0B5A–$0B94` | Deduct cost, attempt auxiliary refueling, then apply/clamp the charge change. The helper clamps negative fuel to0, so its subsequent `fuel>=0` guard permits the final charge step even when no auxiliary load was found. |
| Proc15 `$0D57–$0DAA` | Attempt auxiliary refueling after the phase. If working fuel is now0 and committed word227 was positive, clear power flags0/1/3/4 and special flags8/9/11/12, plus warp/shield targets. Preserve gun flag2, special flag10, group5 flags and current charges. |

The FJP instruction implementation in `ref/apple-pascal-interpreter.txt` tests
`AND #$01`. Shield maintenance and cloaker cost can make working fuel negative;
that deficit is retained until the next helper invocation. The core accepts a
separate working-fuel argument for movement's earlier cost, while word227 remains
the committed value used by the exhaustion transition.

Library24 proc9 `$0E06–$0E50` owns the larger tick: reduce old phase modulo4,
advance the clock when that result is0, increment to1–4, run movement, power,
optional combat, and finally commit fuel. This checkpoint does not replace it
with independently advancing browser clocks. Movement, warp execution and the
location/refuel-beacon branch `$0DAE–$0DF4` remain R09; combat remains R10.
Display drawing and sound side effects are outside the pure rule core.

## Two distinct auxiliary consumers

Library24 proc16 `$0ACE–$0B4C` acts when working fuel is at most0 **and flag7 says
the pod is attached**. It scans slots0 then1, adds255 for the first auxiliary lot,
clears that lot and stops after one load, even if the resulting fuel is still
nonpositive. Finally it clamps remaining negative fuel to0. Thus fuel−3 plus a
load yields252. It cannot draw fuel from a detached pod or warehouse.

Game15 proc10 `$049A–$04EF` is different: fuel below5 consumes the first auxiliary
lot and **sets fuel to255**. Its caller, proc11 `$05EE–$060A`, selects the return
from pod branch when the previous scene is3/4 and word45 bit13 is false. Pod
departure clears that bit (`$0288–$028E`); foot departure does not. Do not invoke
this refill on every foot airlock entry or merely when importing a save.

`reduceCampaignPod` now invokes this helper after validating an actual dock, in
the same owned transition as attachment and return position. A failed or remote
dock changes nothing. Full tanks retain both loads; one empty-tank return consumes
only the first. Ordinary goods and cryogens remain untouched. No extra money,
inventory item, time or RNG change is introduced. Normal city driving does not
consume ship fuel.

Version19 already represents255 fuel and nullable auxiliary cargo, so docking
requires no new field or migration. Loading preserves exactly what was saved;
it does not repeat docking or consume another load. Active charging and phase
state will require a separate versioned extension before being exposed.

## Verification

Eight power-rule groups cover phases1–4, performance bounds, charge saturation,
shield target bands, downward steps, charge/cost/refuel ordering, depletion flags,
RNG draw counts, attachment and first-slot semantics, distinct docking thresholds,
dependency composition, ownership and malformed input. The fixed RNG vector was
computed independently by seven bytewise carry shifts:12345 becomes bytes
`[185,28,24,0]`, state1580217 and Pascal result23576 (low nibble8).

A campaign rule group covers actual docking, saved refills, repeat entry, remote
rejection and conservation. The depot cargo regression now expects consumption
when that existing empty-tank journey returns. The extended depot browser test
adds a second fresh-character journey: buy two loads without buying ship fuel,
drive back, dock, save/reload, then depart/dock again. No campaign fixture grants
the fuel or auxiliary cargo. Current receipts are `ship-power-rules-validation.json`
and `auxiliary-docking-validation.json`. No native-emulator capture is claimed.

Next: live machinery controls and dependencies, deterministic phase/clock and
save ownership, then parked-pod boarding and surface traversal/return. The full
[R08 audit](r08-completion.md) retains those requirements.
