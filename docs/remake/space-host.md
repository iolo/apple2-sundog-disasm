# Campaign ship encounter host — R10i–R10o

`campaign-space.js` connects the source ship-combat primitives to actual
regional flight, machinery, resources, equipment, pod cargo and campaign RNG.
R10i introduced opt-in25 `ship-encounters-1`; R10j extends the opt-in core/save
to26 `ship-communication-1` (`content.space:true`). R10m adds opt-in27
`ship-tactical-1` with `content.tactical:true`, actual entry/frame/clock calls
and saved reticle/input/menu state. R10n extends it to28 `ship-input-1`, saving
button edges and correcting cached-contact firing and the one Comm-return
dispatcher call; see [tactical host](ship-tactical.md).
R10o extends tactical saves to29 `ship-salvage-1`, connecting source bounty,
wreck drift/inhibition and blocking tractor collection into actual bank/cargo
owners; see [ship salvage](ship-salvage.md). Space-only saves remain26.
The live asset loader/UI
remains version24 pending sensors, reticle/input, bolt arming and recovery
integration, including exposing the verified Comm reducer. This document
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

The `space` block owns only contact flags29/35/36/40–47, words205–209/214–217/347/354,
range-memory byte193,12 cooldown nibbles, an integer normal-clock remainder,
ship/tactical context, six combat-cache markers, loss receipts and destruction.
Other flag slots must be false in this block. The adapter derives power,
attachment, cloaking and working-special flags from their existing owners.
Resources own hull/fuel/charges; equipment and engineering own component bytes
and pending offsets; pod owns the two actual lots; encounters owns RNG.
Game16 return flags48–51 remain in the shared campaign dialogue owner so a
ground return cannot be shadowed by a second space flag array. Preparing Comm
clears48–50 but retains51; the verified Game12 return consumes49 or51 according
to its source priority. Other campaign dialogue flags supply source context.

Contact state is bounded canonical progress, like regional flight progress.
It is not an anti-cheat replay of the entire campaign history. Exact-field,
dense-array, byte/range, location, machinery, component-cache and cargo/wealth
checks reject malformed imports atomically. Version26 validates versions1–25
under their historical rules before adding idle communication/activity records.
Version25 still requires its exact nine-field space record and original flag
set before migration; it cannot import26 conversations, sleep or flag35. Old scopes
cannot import hull loss, multiple raw failed components or missing cryogens.

Normal ship-view due ticks remain250ms and minute advancement remains phase1. Version25
owns the0–249ms remainder rather than reconstructing it from an ephemeral
survival object; pause preserves it and a JSON reload can finish the next tick
exactly. Calls accept integer0–60000ms and process all due ticks. Historical
hosts retain their existing capped/transient presentation clock. R10j adds
saved sleep-mode restoration in the core; exposing it in the live space UI and
display-refresh acceptance remain integration work.

## R10j communication and sleep ownership

`reduceCampaignShipCommunication` prepares actual kind19/scene-middle1 Comm
from Game12 proc22 `$1272–$1356`. Frozen inputs include the actual visited
system/account, personal cash/attributes/carried items, source flags, workspace,
city, hour and surface position. It uses `currentShipLocation`, not the parked
ground world's campaign location. A nullable world between planets is valid;
the tested foreign-system opening and Agree path do not request a random place.
The quantity is actual enemy type+1; mood/item are0. Game16 proc30
`$0E4E–$0E62` resets word354 for scene-middle<3. This does not advance ship
machinery or the clock: Game16 has no Library24 proc9 scheduler call.

Only `{context,record:{seed,inputs}}` is saved, with exact fields and bounded
validated inputs. The frozen tree must equal setup reconstructed from canonical
owners; replay must reach the exact continuing campaign RNG and remain open.
Imported frames, locals, messages, completed records, extra fields and owner
mismatches fail atomically. This proves the dialogue transition, not the entire
campaign history: canonical contact/progress is still not a full anti-cheat log.
Clock, production/combat and flight/power/engineering/space controls freeze while
Comm is open. Personal/workspace/account changes publish only on verified return;
the source preparation's control flags publish at opening.

Game12 proc9 `$0754–$07BE` consumes49 first, setting cooldown215=128 and speed207=2
for retreat. Otherwise51 starts `{pending:true,ticks:6}` without payment or
automatic cargo loss; other returns restore hostility. All clear35/41 and set47
to prevent a second Comm with that contact. Source initial Dismiss It enters
the hostile message first; its following dismiss returns, rather than skipping
the source intermediate view.

R10n's opt-in28 `ship-input-1` corrects the surrounding return dispatch. Native
phase3→4 and unchanged clock, together with Game13 `$2588`, establish one actual
machinery call before Game12 consumes the return bits. Verified dialogue outputs
commit before this call; the new deadline starts at6 afterward. Contact may
disappear or sleep/defeat may interrupt restoration. The three tactical startup
calls remain skipped. Historical space-only26 retains its earlier host schedule;
active27 saves migrate to28 without replaying any call at load time. See
[native input/Comm reference](ship-tactical-input-reference.md).

The saved counter runs after movement→production→power→combat, matching Game12
`$0B87–$0BAC`. Six due calls decrement to0; the seventh sets aggression44, so that
call cannot retroactively schedule an enemy shot. Pause and fractional due ticks
preserve the counter and remainder. Game12 exit `$14D4–$14E0` restores44 if a
demand is pending; changing to ship view, sleeping, exhaustion, destruction or
a successful warp ends the local deadline. Source jettison proc21 does not
clear it: cargo-induced retreat can still regain aggression when it expires.
R10m joins the deadline to actual tactical-frame due calls in opt-in27;
the earlier26 deadline fixtures alone do not claim native frame-by-frame timing.

`activity:{sleeping,forced,sleepPhase}` owns the persisted aboard sleep state.
Sleep switches to ship view and clears the presentation remainder, then uses
50ms due calls, the existing machinery phase/minute owner and one rest point
every second sleep iteration. A reload ignores an ephemeral survival object's
default awake state. Sleeping remainders must be0–49ms. Exhaustion retains forced
sleep until rest>128; wake cannot bypass it. Death clears sleep/forced/remainder
and freezes subsequent calls. Historical25 adds default awake activity because
its format did not own sleep state. These are serialized browser-cadence rules,
not Apple II CPU-cycle equivalence or full native recovery dispatch.

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
enemy fire still run. Live sensor/aim/input integration remains pending.

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

R10j adds eleven campaign groups (25 total ship-host groups), including strict25
migration, frozen Comm/replay and unavailable controls, actual foreign account
with a nullable world, Agree/Refuse/Bluff/Dismiss returns, shared return flags,
deadline ordering/exit/jettison, pause/cadence/reload, voluntary/forced sleep and
sleep death, and malformed frozen/counter/activity imports. Contexts remain
declared fixtures, not ordinary-play encounter acceptance. No additional native
capture or UI activation is claimed. [The R10j rule receipt](r10j-rules-validation.json)
reports457 passing groups in Chrome155.0.8059.39 with no errors.22 exporter tests,
171 artifacts,584 source strings and three original input hashes verify.

The full original R10 scope remains in [the requirement audit](r10-completion.md):
live Comm/deadline controls; sensors/aim/input
and localized help; source jettison confirmation; full native recovery and rare
kind18 target224; live frame-rate/resume proof; and fresh-character ordinary
ground/space avoid/fight/lose acceptance. Colony progression remains R11.

R10i's earlier [rule receipt](r10i-rules-validation.json) reports446 passing groups
in Chrome155.0.8059.39 without failures/page errors. [The regional journey](r10i-journey-validation.json)
passes64 ordinary-control checks and [navigation](r10i-navigation-validation.json)
passes44 across both locales/four viewports, with charging reload/cancellation.
The [validation inventory](r10i-validation-summary.json) also records22 exporter
tests,171 artifacts,584 source strings and three original input hashes.
