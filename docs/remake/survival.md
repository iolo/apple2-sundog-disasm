# Landed ship survival and sleep — R05d

The walkthrough now advances a game clock, updates personal condition hourly,
and offers Sleep from inventory. Food restores naturally depleted nourishment.
This remains an isolated landed ship scene: no machinery, campaign events,
temporary attribute boosts or outdoor sleep hazards are simulated.

## Recovered rules

These are p-code routines in `src/pcode/library_22.s`, not native CPU timing.
Offsets are segment-relative. Condition retains the field order and byte layout
described in [condition.md](condition.md).

| Rule | Source | Interpretation |
| --- | --- | --- |
| Clock | Library22 procedure26 `$028E–$02C1` | Add minutes, carry at60 to hours and at24 to days. Original packed clock occupies word42/43; the clean capture has four zero bytes. |
| Hour gate | Library22 procedure29 `$0455–$048E`, `$0560–$0570` | Compare the hour before/after adding time; process each crossed hour. |
| Rest drain | Procedure29 `$04B1–$04B9`, procedure60 `$03A0–$03C5` | Subtract `[4,2,3,4]`, indexed by the old rest byte divided by64. Suppressed by sleep flag59 at word82. |
| Health drain | Procedure29 `$04BB–$04C3` | Subtract `[1,0,0,0]` by the old health band. |
| Nourishment drain | Procedure29 `$04C5–$04CD` | Subtract `[1,1,2,3]` by the old nourishment band. |
| Health recovery | Procedure29 `$04A0–$04AF`; procedure60 `$03C7–$03D9` | If health after drain is above128, add `4 * max(0, trunc((oldVigor-128)/32))`. Clamp each byte to0–255. |
| Low-condition penalty | Procedure60 `$042A–$0440` | For each updated rest/health/nourishment below64, add `floor(value/16)-4` to the vigor penalty. Also sum the three updated values. |
| Vigor | Procedure29 `$04CF–$0514` | If the penalty is negative, add it. Otherwise move vigor by2 toward the integer average of the updated trio. Clamp0–255. |
| Exhaustion | Procedure60 `$03DB–$0412` | Zero rest requests mode10, forced sleep. The browser opens its sleep dialog and blocks waking. |
| Death | Procedure29 `$04EA–$0501` | Zero vigor requests mode12. The browser freezes this walkthrough and offers an explicit restart. |
| Sleep loop | Game8 procedure17 `$0962–$09B4` | Set sleep flag59; restore one rest point every two iterations, capped at255. |
| Clock during ship sleep | Game8 procedure3 `$00A4–$00B6`; library24 procedure9 `$0E0C–$0E27` | Landed-ship calls reach the condition clock once per four iterations. |
| Forced waking guard | Game8 procedure17 `$09B6–$09DC` | At rest above128, clear forced mode10 so waking becomes possible. Rest reaching255 does not automatically end voluntary sleep. |

Procedure29 also moves temporary attributes toward their base values. The
walkthrough has no mutable/boosted attributes, so this checkpoint implements only
its condition and time effects. Library24's ship equipment updates and game8's
location-sensitive theft/encounter branches remain outside this scene's scope.

## Original-game comparison

[Three controlled MAME fixtures](../reference/remake-survival.json) match the
browser hourly function exactly:

| Initial vigor/rest/health/nourishment | Sleep flag | After one hour |
| --- | --- | --- |
| 128 / 90 / 120 / 100 | Off | 126 / 88 / 120 / 99 |
| 128 / 90 / 120 / 100 | On | 126 / 90 / 120 / 99 |
| 192 / 64 / 129 / 192 | Off | 191 / 62 / 137 / 189 |

These are explicit RAM fixtures in an existing play session on disposable disks.
They do not claim natural depletion, original item consumption, or execution of
the original sleep UI. The sleep-flag fixture specifically verifies suppression
of hourly rest drain; the two-iteration rest increment is source-derived.

To reproduce, launch an owned MAME 0.285 Apple IIe joystick session using the
existing `docs/reference/game-play.json` sequence through ship entry at frame 18000,
before opening status. Pause, load the a2-mame `control.lua` helper as `a2`, then
load `tools/remake/survival_reference.lua`. Use `a2.call` sequentially:

```lua
a2.call('awake', 'hourProbe', 'awake', {128,90,120,100}, false)
-- Wait for PROBE and /tmp/r05d-awake.json before the next operation.
a2.call('sleep', 'hourProbe', 'sleep', {128,90,120,100}, true)
a2.call('threshold', 'hourProbe', 'threshold', {192,64,129,192}, false)
```

The helper verifies writes to the four condition bytes and clock `00:59`, sets
the sleep flag, then runs until hour01 and pauses fifteen frames later. A 2000-frame
deadline prevents an unbounded probe. All three finished without timeout. The
interactive emulator exited normally. An initial launch without writable stdin
was stopped using its exact owned-session path. Original disk/manual hashes match.

## Browser timing and controls

Normal visible play advances **one game minute per real second**, including idle
time. Sleep runs one source sleep iteration per 50 ms: five game minutes and ten
rest points per second. These are explicit browser presentation rates, not
calibrated Apple II wall-clock timing. Sleep starts with clock phase0 and rest
phase0; ship machinery timing is not shared with this isolated clock. Elapsed
days are shown from day0 rather than as a campaign date.

Inventory, help, Pause, lost focus and hidden tabs suspend the clock. Sleep is
the explicit exception to inventory pause. Its own Pause/Resume controls stop
both time and recovery. A frame contributes at most 250 ms; paused fractions are
discarded, and there is no background-tab catch-up. Movement retains its separate
50ms cadence. Wake or Escape returns to paused inventory with focus restored;
exhaustion prevents waking until rest exceeds128. The terminal screen freezes
time and requires an explicit restart, which restores the walkthrough fixture.

No independent inventory, position or clock reset occurs when changing locale,
reopening the scene or choosing Return to start. Reload resets this isolated
state. Campaign saves remain separate from the four existing character drafts.

Visual approach: reuse the dark ship display, ivory text and amber action accent.
Place a small clock in the existing scene/inventory margins; use the established
bounded dialog for sleep. The clock/rest text updates without replacing controls
or moving focus. Existing scene transitions and selection feedback remain;
sleep adds no decorative animation.
