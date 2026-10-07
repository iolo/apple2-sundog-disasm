# Ground encounter host and save boundary — R10g

R10h subsequently activates this boundary in the [live ground UI](ground-encounter-ui.md).
The following scope statement records the original core checkpoint.

This checkpoint joins normal ground movement, the due threat gate, chase,
mandatory Game16 dialogue, Game17 combat and verified return in one core host.
Version24 `ground-encounters-1` is opt-in through `content.combat:{chase,ground}`.
The live asset loader and UI still use version23; ordinary-control campaign
acceptance, tactical presentation and recovery dispatch remain R10 work.

## Due clock and ownership

Game21 procedure1 `$1E48–$1F6E` moves the player before its clock check. Button
edges at `$1E92–$1EC2` switch global words353/351 between the cached active
limit/minute increment and idle15/1. Procedure27 `$10CC–$10E5` supplies city
10/10 on foot or10/1 in a pod; procedure29 `$1317–$1330` supplies surface2/120
on foot or2/20 in a pod. Procedure30 `$151D–$1531` caches the active values and
resets the current rate to idle. A scene refresh while movement stays held
therefore retains idle timing until another button edge.

`ground-host.js` stores that clock, iteration count, sub-tick remainder and pod
direction. Each browser logical iteration is50ms, an explicit adaptation of the
native loop. Movement uses actual campaign geometry, then time advances, then
the eager threat gate consumes its RNG. One viewport pointer space is shared
by normal movement, chase and combat; normal travel alone projects it onto the
full map. A scene transition stops the current browser update for UI handoff.

Library22 procedure29 resets word354, adds the whole word351 minute increment
and checks whether the displayed hour changed. A120-minute surface update
executes the shared condition-hour reducer once, including midnight. This
checkpoint retains the browser's existing condition model; it does not claim
the complete native attribute-erosion cycle or cycle-equivalent timing.
Condition death suppresses production after consuming the eager gate draw,
matching the source scene-middle12 ordering. Exhaustion stops the host pending
the future live recovery/condition flow.

Chase and combat freeze ground time and the campaign return pose. Their arena,
actors, working personal state, RNG and dialogue are owned by the active
encounter. Catch opens mandatory dialogue before the first active combat tick.
Dialogue returns to the same combat activation, preserving actors and history.
A last-enemy kill opens kind15 post-fight dialogue before committing its reward.

## Replay and persistence

Version24 adds exactly:

```
combat:{clock,ground,rewards,defeat}
ground:null | {seed,inputs}
```

Inputs are exact held-control tick batches or shared validated dialogue inputs.
The log is dense and bounded to1024 events and12000 logical ticks; a tick batch
cannot cross a dialogue or terminal boundary. Saves contain no imported actors,
interpreter locals, working balances, outcomes or arbitrary activation objects.
Load reproduces the actual campaign-context gate, chase, combat and conversations
from the frozen personal/map baseline and verifies the final shared RNG.

`snapshotCampaignGroundHost` publishes terminal results through replay again.
Escape clears the session without changing personal inventory/cash. Surrender
and knockout commit source robbery, lost carried bytes and damaged condition.
A combat death retains source health/vigor zero and a `groundDeath` marker;
clock death records `conditionDeath`. These durable records do not implement
the live death/wreck/recovery dispatch or invent restoration.

Post-fight income receipts record system, source quantity, quote seed and amount.
Validation recomputes the source quote before adding income to the campaign
wealth ceiling. Source personal-sale receipts keep their existing ledger owner.
The replay return can commit only once because the completed session is cleared.
The bounded reward ledger validates source prices rather than proving the entire
campaign history, consistent with existing personal/cargo progress validation.

Historical versions1–23 validate using their original exact fields, quantity1
and living-condition rules before receiving default combat state. Only24 allows
source encounter quantity1–5 and inactive conditions with the required death
marker. Standalone checkpoint formats keep their historical validation.

## Validation and limits

Nineteen host test groups exercise clock rates and edges, source hour updates,
actual due production, city/surface eligibility, mandatory conversation,
partial-clock/chase/dialogue/combat JSON resume, surrender, escape, owned item
losses, source shots and post-fight cash, fatal damage, historical validation,
atomic malformed-input rejection and equal30/60/144Hz continuation with pause.

Controlled fixtures use real map context and declared seeds10804/10753. The
fight moves the actual starting laser from stores to carried inventory, wins
against a source-initialized actor and earns360 credits. The loss fixture moves
the actual medicine and laser, then loses both without restoring their stores.
The fatal fixture first receives health51 from source knockout, then declares
a second gate seed and reaches source health/vigor zero without injecting
damage or actor records. These are core integration fixtures, not ordinary-play
UI acceptance or new native combat-outcome observations.

See [R10 requirement audit](r10-completion.md) for all remaining milestone gates
and `r10g-rules-validation.json` for the complete browser regression receipt.
