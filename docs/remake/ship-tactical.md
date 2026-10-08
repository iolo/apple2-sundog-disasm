# Ship tactical controls and campaign host — R10k–R10o

R10o adds [source bounty/wreck/tractor salvage](ship-salvage.md) and its actual
campaign bank/cargo ownership in opt-in29 `ship-salvage-1`. The earlier R10k–R10n
boundary below is retained as history; the live space UI remains pending.

`ship-tactical.js` adds source-facing Game12 controls alongside the existing
ship-combat and campaign-space owners. R10m connects the record to actual
campaign calls; R10n corrects native button/cache and Comm dispatch in opt-in28
`ship-input-1` saves (`content.space:true,tactical:true`). The live UI
remains24. This does not activate space
encounters or claim complete R10 tactical, timing or ordinary-play acceptance.

## Source procedures and state

The core accepts the validated ship-combat source state and a separate bounded
tactical record: reticle angle/radius, captured contact presence, visibility,
signed grace counter, focused/firing mode, cached sensor output, source frame
limit, menu0–3 and armed jettison choices. All operations clone their inputs.
Version28 owns it in `space.tactical:{record,control,carry,trigger}`. Campaign persistence
is tested; live UI input and resume remain integration requirements.

| Source | Implemented behavior |
| --- | --- |
| Native viewscreen `$0A73–$0AFE` | Paddle counters saturate at127, divide by4 and select the32 signed motion values from+8 to−8. Word order is y then x. Positive motion corresponds to low paddle counts. |
| Game12 proc9 `$052C–$0655` | Capture flag40, clear producer inhibition36, clear41–47 only when no contact, initialize reticle from actual world angle/128. Working targeting flag19 draws x then y as448+(RNG&127), deriving both reticle values by right shift2. |
| Game12 proc15 `$0D01–$0ED8` | Cached sensors>0 plus attachment allow Jettison;>1 allow Guns;>2 allow Shields and a working cloaker20;>4 allow range plots. Comm uses actual contact/repeat flags. |
| Game12 proc12 `$09F4–$0A78` | Firing uses paddle deflection. Otherwise working targeting19 reacquires toward512/512 at signed8 per axis; visible tracking uses the negative arithmetic half of velocity times max(0,3−(range>>5)). |
| Game12 proc10 `$088F–$0996` | Reticle radius subtracts x deflection; angle subtracts y. Active contact range adds speed and clamps at5 while positive cooldown decrements by1. Coordinates add twice the corresponding deflection plus `(3−(updatedRange>>5))*velocity`, wrapping at1024. The far-range factor may be negative. |
| `$0942–$0996` | With cached sensors>1, visibility uses inclusive absolute half-coordinate offsets65/45 and range108. Offscreen movement sets grace2. With lower cached sensor output, the source visibility local is retained, while rendering capability remains unavailable. |
| Main loop `$1388–$139C`; firing `$0F7A–$0F84`; menu `$0F17–$0F3B` | Main and firing loops increment counter354. Main dispatch tests bit0 before proc12; firing calls it every iteration. Proc15 polls proc12 without the increment while waiting for button release, then returns. A selected submenu does not keep subsequent main frames in that polling loop. The core caller supplies an explicit polling context. |
| Proc12 `$0AC5–$0BF4` | Redraw/decrement grace only when invisible, at the half-limit counter, or while grace>0. The false branch through table `$0BF8` jumps to `$0B5D`: movement and the due machinery check still run. Move before a due call, then refresh sensors and move again using the old captured contact before replacing it with flag40. |
| Proc17/proc7; Library22 native proc2 | Selecting laser/cannon starts the powered firing loop; leaving it turns gun power off. A fresh primary edge spends actual charge before movement and uses actual dexterity. Held primary does not refire after recharge. A kill clears captured contact before global40 and resets the reticle to angle128/current world angle. |

`prepareShipTactical` reports **three startup machinery calls**, corresponding
to proc9 `$0655/$06C4/$074F`; it does not silently run them. R10m's campaign
adapter commits those calls in order through the actual flight, production,
power, combat and clock owners. The Comm-return branch skips those three calls,
restoring the byte-sized reticle from workspace16/17 instead. R10n also commits
Game13's one dispatcher call at `$2588` before that restoration. The source frame
limit353 and existing grace local3 are explicit preparation inputs. Game13
startup sets353=5, while other overlays change/restore it. This core does not
guess a CPU-cycle duration, a native initial grace value, or a universal limit.
Native `false_jump` at `$D2A0–$D2A6` explicitly masks bit0; treating a nonzero
even counter as true would implement a different main-loop schedule.

Counter354 is shared frame/time state, not a dedicated hit total. Library22
proc29 `$0450–$0451` resets it at the phase1 clock call; Game16's space overlay
also resets it. R10m owns these resets in the version27 context; historical26
continuation retains its earlier host schedule. The half-counter/visibility/grace
gate affects drawing, not the machinery check. R10l's prepared native captures
correct the R10k interpretation that skipped movement/due calls when that gate
was false. The core now reports `redraw` separately from `updated`/`due`.
R10n's [native input reference](ship-tactical-input-reference.md) separately
observes aim, fresh/held fire, empty-space expenditure, loop exit and Comm byte
storage/restoration, and exposes the omitted Game13 return call.

Game13's successful warp writes354=353+1 at `$18AC–$18B2`, clears the
engine/contact/Comm flags and calls actual Library24 proc9 at `$18DA` before
tactical entry. R10m initially committed that call and three startup calls.
R10aa/R10ac additionally observe/implement the accepted Nav pre-action and
Nav display-return calls: six calls on healthy success, two on gravity failure.
Fatal success performs pre-action/post-jump/Nav return only, then freezes
without Game12 startup. See [Warp reference](ship-warp-defeat-reference.md).
Nav calls outside Game12 preserve its pending cargo deadline on failure.

## Source bolt arming and selection

Game12 proc21 selection0 `$11C9–$1260` opens the Jettison menu and announces
`BOLTS ARMED` with both pod contents before accepting a selection. The core
requires menu2/armed choices before calling the actual cargo-loss primitive;
backing out removes those choices without spending RNG or cargo.

Proc15 `$0E21–$0E5E` offers a slot only for types>0 and<31. This permits
auxiliary fuel1 and ordinary cargo2–30, excludes empty slots and **cryogens31**,
and offers Both only when both slots qualify. The lower-level proc21 primitive
can process31 when called with a forced selector; R10i's cryogen-loss fixtures
prove accounting, not native menu reachability. A live UI must preserve this
distinction instead of exposing a new cryogen-discard option.

Armed choices are source menu state. If a due power tick consumes auxiliary
fuel after the menu was built, the old selection still draws once even though
the actual slot is now empty. Confirmation processes actual current cargo,
Both in slot2→slot1 order, and returns losses/cooldown signals for their campaign
owners. R10m's campaign adapter retains R10j's pending cargo deadline after
discarding cargo; the menu primitive does not cancel it. Live bolt controls
remain required.

## Campaign frame and save owner — R10m

`enterCampaignShipTactical` performs normal entry once, retaining the cached
contact/sensor context captured before the three startup calls. Targeting uses
the actual campaign RNG before those calls. The normal Game13 context has
frameLimit5. Initial grace0 is a declared browser adaptation because R10l's
native stack local has no universal initial value.

The browser assigns50ms to a logical tactical frame. Main bit0/firing dispatch
controls whether proc12 runs, and counter354/frameLimit controls actual due
machinery calls. Movement occurs before a due call and again afterward using
the old captured contact, then refreshes contact and sensors. A phase1 call
resets354; its minute, resources, combat damage and RNG use existing campaign
owners. A fresh shot spends charge first and commits the actual packed system
cooldown on a kill. No second combat RNG or resource simulation is introduced.
The50ms cadence is a presentation adaptation, not native CPU-cycle equivalence.

Discrete submenu actions represent completed button-release input. They do not
hold the host in proc15's release-poll loop. Saved controls are signed x/y−8..8
plus held fire. Version28 saves `trigger:{latched,previous}`: Library22's
dispatch hook buffers a press between polls, while proc2 returns only a rising
edge. Both native firing polls consume that state; the logical frame samples
one fixed input, so its second poll can clear a short released pulse without
inventing another press. Holding/reloading cannot manufacture a repeat shot.
Comm truncates both reticle values to bytes before freezing the conversation.
Verified Game16 outputs commit first, then one actual Game13 machinery call
runs before Game12 consumes retreat/deadline flags and restores its reticle.
The new deadline starts at6 afterward. Fractional frame/carry remains saved;
dispatch may remove contact or enter sleep/defeat. There are no three startup
calls on this branch. Frozen/returned Comm resets the held control and latch.
Sleep/terminal transitions release firing power and remove the controller.

Version28 validates versions1–27 under their exact historical contracts first.
Historical27's exact three-field controller receives a cleared latch and
`previous=control.fire`, preserving an already held input without creating a
press or spending RNG/time/resources. Version27 introduced the following
historical26 migration:
An active historical26 view receives the missing controller without consuming
RNG, resources or time. Its0–249ms remainder becomes `carry`, preserving the full
budget for the first unpaused advance; current tactical remainders are0–49ms.
Exiting before consumption returns that carry to the ordinary ship clock.
Initial ship views use a null controller. Exact fields, ranges, frozen Comm,
frame-limit context and terminal/view relationships reject malformed imports.
Source zero-output gun loops may retain power only in validated firing records;
historical26 retains its strict zero-output machinery rule.

## Verification and next integration

Fifteen groups cover all paddle counter values, source entry/target RNG,
cached sensor capability thresholds, reacquisition/manual/tracking modes,
signed movement and wrap, visibility boundaries and stale cache, main/menu/
firing counter gates, pre/post-combat movement, charge/kill/loop exit, bolt
arming/selection/cancellation/stale auxiliary choice and atomic malformed-input
rejection. The prepared working-equipment/contact fixtures are declared source
contexts, not naturally generated campaign encounters. R10l adds a prepared
native movement/clock reference and a regression for its visible/grace-zero
sequence; see [tactical reference](ship-tactical-reference.md).

Sixteen campaign groups add exact entry/RNG/resource vectors, native frame
ordering,30/60/144Hz rules-state equivalence, pause/reload, historical migration,
gun loops, cached control gates, actual cargo costs/losses, byte-sized Comm
return, due deadlines, successful/failed warp and sleep/destruction/import guards.
These use declared working equipment/fuel/contact/cargo setups. They do not
establish ordinary-play or live display-refresh acceptance.

R10n adds saved held/short-pulse edges across recharge/pause/reload and all three
caller cadences, strict28/27 migration, native cache/aim vectors and the actual
Comm dispatcher phase/power/clock/deadline/sleep/contact-loss return. These are
rule-state checks, not live space input/display acceptance.

Next: implement source bounty/wreck/inhibition/tractor/salvage context;
expose sensors/aim/fire/Comm/bolt controls with English/Korean help;
activate the live ship host and prove30/60/144Hz, pause/sleep/reload and legitimate
ordinary-play avoid/fight/lose outcomes. Full death/wreck/recovery and rare
reward224 remain in the [R10 completion audit](r10-completion.md).
