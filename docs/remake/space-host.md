# Campaign ship encounter host — R10i

`campaign-space.js` connects the source ship-combat primitives to actual
regional flight, machinery, resources, equipment, pod cargo and campaign RNG.
This is an opt-in core/save checkpoint (`content.space:true`, version25
`ship-encounters-1`). The live asset loader/UI remains version24 pending space
Comm, sensors, reticle/input, bolt arming and recovery integration. This document
does not claim live space encounter acceptance or full R10 completion.

## Source scheduler and corrected gates

Library24 proc9 `$0E2D–$0E3D` calls proc12 movement, proc15 power, then proc13
combat when flag40 is set. The campaign machinery adapter now preserves
contact-owned flags through power and equipment-dependency updates.

| Source instruction/pointer | Host behavior |
| --- | --- |
| Library24 `$02BC`, pointer `$0678→$0676` | Flag1 off returns before motion RNG or the producer. |
| `$02D3` LAND | Powered ticks draw RNG on every phase, but successful movement requires odd phase bit0 and roll strictly below engine performance. |
| `$0416–$0423` | Phase3 spends one working fuel with engines on, including failed motion rolls. |
| `$042D`, pointer `$067E→$04BA` | Non-arrival ticks also reach encounter production. The earlier arrival-only interpretation is corrected. |
| `$049B–$04A6` | Actual arrival resets an existing contact's cooldown215 to0 before combat. |
| `$051F` LESI, `$0553` LEQI | Ordinary cargo types2–30 qualify; cryogens31 do not. System word8/nibble3 must be <= the drawn low nibble. The API retains its original name `piracy`. |
| Utility12 `$0289–$0291` | Initialize all12 system word8/nibble7 cooldowns to0 rather than importing saved working bytes. |
| Game13 `$18B6–$18D8` | Successful warp clears contact40/47 and switches to the tactical context. Warp is not an arrival producer. |

The existing explicit browser five/twenty-minute planetary overlays remain
separate resumable transitions. They do not acquire an invented fuel fee or
engine-powered encounter draw. Source procedure bodies and jump pointers, not
an animation's frame rate, determine the ship host's update order.

The flight corrections apply to the current live version24 runtime too.
Historical save *validation* stays unchanged; historical continuation uses the
corrected current reducers. R09f and R10h receipts precede this audit. R10i
records fresh navigation and regional trade/return regressions.

## State owners and persistence

The `space` block owns only contact flags29/36/40–47, words205–209/214–217/347/354,
range-memory byte193,12 cooldown nibbles, an integer normal-clock remainder,
ship/tactical context, six combat-cache markers, loss receipts and destruction.
Other flag slots must be false in this block. The adapter derives power,
attachment, cloaking and working-special flags from their existing owners.
Resources own hull/fuel/charges; equipment and engineering own component bytes
and pending offsets; pod owns the two actual lots; encounters owns RNG.

Contact state is bounded canonical progress, like regional flight progress.
It is not an anti-cheat replay of the entire campaign history. Exact-field,
dense-array, byte/range, location, machinery, component-cache and cargo/wealth
checks reject malformed imports atomically. Version25 validates versions1–24
under their historical rules before adding an idle space record. Old scopes
cannot import hull loss, multiple raw failed components or missing cryogens.

Normal due ticks remain250ms and minute advancement remains phase1. Version25
owns the0–249ms remainder rather than reconstructing it from an ephemeral
survival object; pause preserves it and a JSON reload can finish the next tick
exactly. Calls accept integer0–60000ms and process all due ticks. Historical
hosts retain their existing capped/transient presentation clock. Sleep-mode
UI restoration and live display-refresh acceptance remain integration work.

Installation failures retain their historical masked output cache. Combat
failures recalculate from raw high bytes and may contain multiple damaged
shunts. The marker selects the corresponding canonical validation rule; it
does not let an imported cache override recalculation. Engineering entry/tick
resolves the source failure session and clears that marker. Reconciliation
preserves contact flags and does not turn a repaired system on automatically.

Ship destruction commits source word347 and a durable reason/time. The native
retained-pointer zero-output case can leave the actual hull nonzero. Personal
condition is not fabricated to represent ship death. If the condition clock
and hull both become terminal on one scheduler call, both owner records persist.
Subsequent clocks/actions freeze. Native death/wreck/recovery dispatch remains
pending; the marker does not invent recovery or fulfill that R10 gate.

## Shots and cargo loss

The tactical reducers spend actual gun charge, use actual dialogue dexterity,
commit health/hit counters and wrap the visited system's kill cooldown to4 bits.
Source contact40 persists after a lethal shot until the next combat tick.
Tactical context stops cooldown-driven contact drift, while power and pending
enemy fire still run. Sensor/aim/input mapping remains pending.

Jettison processes Both as slot2 then slot1, retains the source eager RNG draws,
and clears the visited cooldown when the source requests it. Its campaign
guard prevents remotely discarding cargo in a detached pod. The primitive
still has no UI bolt-arming confirmation; that source flow must be connected
before live activation.

Loss entries aggregate identical canonical lots as `{lot,count}`, retaining
ordinary, auxiliary and cryogen identities. Counts are1–65535, at most512
distinct entries, and cryogens additionally obey their global17-lot multiset.
Stored plus lost cryogens must equal creation placements exactly. Destroyed
paid cargo retains its cost in the wealth bound; a loss is not an income grant.
Lost cryogens cannot be restored to another owner without rejecting the save.

## Validation and remaining scope

Fourteen new campaign groups cover version25/legacy validation, actual
non-arrival production, movement→producer→power→combat RNG order, shields before
damage, arrival retreat, partial-tick cadence/pause/reload, hull/component/shunt
failure, engineering burnout, retained-pointer destruction, real gun charge,
packed kill cooldown, ordinary/cryogen jettison conservation, tactical drift,
successful/failed warp and malformed-import atomic rejection. Test contexts
explicitly set working equipment/contact seeds to isolate the rules; they are
not fresh-character ordinary-play encounter acceptance.

The full original R10 scope remains in [the requirement audit](r10-completion.md):
space frozen Comm context/returns and actual cargo deadline; sensors/aim/input
and localized help; source jettison confirmation; full native recovery and rare
kind18 target224; live frame-rate/resume proof; and fresh-character ordinary
ground/space avoid/fight/lose acceptance. Colony progression remains R11.

The final [rule receipt](r10i-rules-validation.json) reports446 passing groups
in Chrome155.0.8059.39 without failures/page errors. [The regional journey](r10i-journey-validation.json)
passes64 ordinary-control checks and [navigation](r10i-navigation-validation.json)
passes44 across both locales/four viewports, with charging reload/cancellation.
The [validation inventory](r10i-validation-summary.json) also records22 exporter
tests,171 artifacts,584 source strings and three original input hashes.
