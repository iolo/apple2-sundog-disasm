# R10 requirement audit

Status: **in progress**, 2026-10-08. This audit preserves the R10 row in
[PLAN-REMAKE.md](../../PLAN-REMAKE.md). Isolated cores and controlled references
do not establish completion of the live campaign milestone.

| Original requirement | Current evidence | Remaining work |
| --- | --- | --- |
| Complete dialogue predicates/actions | Existing Game16 interpreter has source predicate/action/builtin handlers. Predicate12–14 case pointers at `$047C/$047E/$0480` target the default false branch; builtin dispatch `$10E8` covers0–11, with later codes taking its default. [R10f encounter dialogue](encounter-dialogue.md) adds actual kind15/16/18/19/22 setup, bank/personal money outcomes, charged free-gift transfer, replay and enemy localization. R10h owns ground context/outcomes in live24. R10j connects frozen actual space context/verified returns in opt-in26. R10r connects live Comm and frozen actual conversation/save owners. | Observe and resolve the unsupported rare reward target224. Complete negotiation acceptance in ordinary campaign play. |
| Ground threats | [Ground chase core](ground-chase.md) ports Game21's eager gate, actual map/system context, window, player/chaser ticks, blocked-step catch and escape. The controlled R10d path matches records/RNG. [Ground combat core](ground-combat.md) implements source actors, collision, weapons, shields, surrender and robbery. [R10h live host](ground-encounter-ui.md) connects movement/due clocks, chase, mandatory dialogue, combat, version24 saves and verified personal returns. R10r retains these owners in live29; its [68-check exchange journey](r10r-exchange-trading-validation.json) starts a fresh seed12345 character and escapes two naturally produced city chases using ordinary held-arrow controls without personal/economic losses. | R10w proves ordinary fresh-character victory/knockout, legitimate laser/shield use and explicit earlier-slot recovery. Complete peaceful ground negotiation and ordinary terminal defeat acceptance; retain native background/timing adaptation boundaries. |
| Pirate encounters | [Ship combat core](ship-combat.md) implements source production, movement, firing, damage and jettison. [R10i ship host](space-host.md) runs production during actual powered flight before power/combat, owns contact flags and system cooldown, and commits failures/hull/defeat/RNG in opt-in25. R10r activates version29 with live contact/sensors, tactical controls and source frame/inhibit context;110 controlled browser checks pass. | Complete ordinary fresh-character space encounter acceptance. |
| Negotiation/evasion | Source cores include retreat/surrender flags, ground boundary escape and cargo-induced retreat. [Native space dialogue](encounter-reference.md) shows Comm and Agree/Refuse/Dismiss It. R10j connects actual frozen context/verified returns and the six-decrement/seventh-call cargo deadline to ticks/saves, including source exit aggression and jettison retaining the deadline. R10h live fixtures exercise ground escape, surrender/cancellation and refusal/fight on the same activation. R10r exposes actual Comm, verified Agree deadline and source exit aggression in live controls, with exact fresh-page restores. | Complete peaceful and fresh-character ordinary-play negotiation acceptance; Agree is not a permanent truce. |
| Tactical controls | [R10k–R10o tactical host](ship-tactical.md) adds native paddle mapping, sensor/menu gates, automatic/manual aim, source own movement, visibility and pre/post-due frame ordering. R10m connects startup/due calls and phase1 counter reset. [R10n native input](ship-tactical-input-reference.md) observes manual aim, fresh/held/empty-space fire, loop exit and Comm byte storage/return; opt-in28 saves the button latch and corrects cached-contact firing plus Game13's one return call. R10h live ground controls cover arrows/held pointer, Space/right-click/primary-pointer fire, surrender cancellation, pause and English/Korean help. R10r connects live sensors/contact/aim/fire, captured pointers, held-fire history, tractor collection and complete saved owners;110 browser checks cover both locales and all menus. | Prepared native collection is proven by [R10s](ship-salvage-reference.md), including all five pulls, the copy and return-menu call. Prove remaining controls through ordinary campaign acceptance; the declared command-entry fixture does not prove native menu reachability. |
| Weapons/shields/damage | Ship and ground vectors cover charge, damage, equipment failure, health, hull and source quirks. R10h live laser shots and defeat commit personal inventory/condition with verified returns. R10r commits live ship shield targets, shot charge, source component bytes/performance/pending failures and native due-frame destruction. | R10w proves ordinary personal laser/shield use and earlier-slot recovery after knockout. Complete ordinary ship equipment/shield use and terminal defeat/recovery acceptance. |
| Cargo jettison | R10k core requires source bolt arming and preserves menu choices/stale auxiliary selection. Source selectable slots are types1–30, excluding cryogens31. Ship primitive preserves reverse slot order and RNG draws. R10i applies actual removals/loss ownership and cooldowns, conserving stored+lost cryogens and destroyed purchase costs. R10m joins armed choices and actual losses/costs to saved campaign state while retaining the due Comm deadline. R10r exposes bolt arming, actual pod contents and source selectable loss ownership; live collection/jettison/reload passes. | Complete ordinary cargo-demand/jettison negotiation acceptance. Forced-selector cryogen-loss fixtures do not establish native menu reachability. |
| Defeat/recovery | Ship core sets defeat word347/scene12; ground core preserves scene-middle12 and source knock-out/robbery. R10h commits personal losses/condition, opens the ended-campaign scene and saves/reloads durable death markers without restarting time. R10i saves actual ship destruction independently of personal condition. [R10p native recovery and R10q due-frame exit](ship-recovery-reference.md) observe a fatal hull hit, original death dispatch, saved-point restart and playable ship continuation; the opt-in29 host now matches the observed post-move and extra display-return phase. R10r connects the native due-frame vector to the Ship destroyed scene, terminal freeze/reload and explicit earlier-slot restoration/resumed play. | R10t matches the captured fatal first-startup continuation. R10u captures second/third normal startup returns. R10v captures fatal Comm dispatch and its one UI poll. Observe fatal warp pre-entry. R10w proves ordinary living knockout/robbery and explicit earlier-slot recovery; ordinary terminal defeat/recovery remains required. R10s supplies prepared native Tractor continuation under its declared scope. Do not invent automatic restoration. |
| Deterministic avoid/fight/lose fixtures | Ground core exercises all three outcomes; ship vectors exercise shots, retreat, jettison and destruction. | R10r/R10w prove ordinary ground avoid/fight/knockout-loss with legitimate controls and exact persistence. Complete ordinary space avoid/fight/lose, remaining negotiation/equipment/terminal recovery and atomic rejection acceptance. Isolated injected fixtures do not replace ordinary-control acceptance. |
| At least one ground and one space encounter has original-game evidence | R10b records a valid controlled space contact and enemy dialogue. [R10d](ground-encounter-reference.md) records the Game21 gate/chase/catch and six-actor Game17 initialization. | This observation gate is met with declared controlled contexts; the earlier invalid scene5 probe remains excluded. The captures do not establish native damage/negotiation outcomes or live campaign acceptance. |
| Timing independent of display refresh | Ground cores and live R10h UI use serialized50ms remainders;30/60/144Hz browser display-timer shims yield identical campaign/replay/RNG with JSON resume and pause. R10j ship sessions persist awake/sleep remainders, forced/rest phases and actual deadlines. R10m adds saved50ms tactical-frame dispatch, actual startup/due clock calls and30/60/144Hz rules-state equivalence with reload/pause. R10r verifies complete live campaign equivalence at30/60/144Hz through held input/save, short fire, partial137ms budgets, pause, fresh reload and sleep/rest. Its current100 ground checks also verify held arrows/captured pointers, exact137+137+726ms budgets, pause and two fresh reloads at all three rates. | This display-refresh gate is met for the exercised live paths. Ordinary encounter/equipment/recovery acceptance remains separately required. |

[R10r live space controls](space-encounter-ui.md) activates version29
`ship-salvage-1`: actual tactical/menu/input, Comm, shields, cargo and salvage
owners, saved sleep, ship destruction and explicit earlier-slot recovery.
[110 live browser checks](r10r-space-ui-validation.json) and
[503 rule groups](r10r-rules-validation.json) pass. The browser display-callback
shims yield identical complete campaign states at30/60/144Hz through held
input/save, pause, short fire, fresh reload and sleep. These are declared
controlled contexts, not ordinary fresh-character encounter acceptance.

R10q matches R10p's due-frame fatal continuation: post-hit movement followed by
one Game13 display-return machinery call, giving phase3, gun charge60,
cooldown35 and unchanged RNG/condition.503 Chrome rules and45 focused groups
pass, including terminal reload/freeze and phase1 hour-boundary chronology.
At R10q, fatal entry/startup and Comm-dispatch context, browser live recovery
and ordinary acceptance remained open. R10r now proves controlled live recovery;
fatal entry/Comm context and ordinary acceptance remain required.

R10p's [native recovery reference](ship-recovery-reference.md) retains26 hashed artifacts and exit0 from an owned IIe session. A declared fatal hit reaches scene12 without personal injury; native Yes restores earlier campaign data and Play SunDog resumes the ship interior. The exact five-draw fatal vector is rule-tested.

R10o's [ship salvage](ship-salvage.md) connects full kill continuation into
opt-in29 `ship-salvage-1`: current-system bounty, eager wreck RNG, source drift,
inhibition and blocking tractor collection into the actual pod manifest. The
prepared R10n capture independently matches cargo25/quality6, packed record217
and its exact RNG bytes. Its earlier1000Cr prose is corrected to3000Cr by the
screenshot and proc6 locals. Ownership/wealth, unknown-origin sale/fuel, due
machinery ordering and strict historical28 migration are rule-tested. This does
not prove native tractor collection, live controls or ordinary space acceptance.

R10l's [native tactical reference](ship-tactical-reference.md) observes prepared
entry, frame dispatch, pre/post-due movement, phase-clock reset and joystick
bolt arming. It corrects the R10k redraw gate: a false condition still reaches
movement/due checks. Native initial grace is retained stack data, requiring a
declared browser initialization adaptation. R10m completes opt-in campaign
frame/save integration: normal entry commits three actual calls, successful warp
commits its prior call plus those three, and verified Comm return skips startup.
Proc15's polling applies only while waiting for button release; a selected
submenu does not stop future main-frame counter increments. R10n observes
native aim/fire/Comm reticle input and corrects two consequential host assumptions:
primary is a fresh edge, and Game13 performs one actual return dispatcher call
before Game12's restoration (which still skips its three startup calls). Native
kill continuation also shows bounty, wreck/inhibition and RNG draws beyond gun
arithmetic. At R10n those campaign owners remained unimplemented; the capture
does not itself prove browser salvage or full death/recovery acceptance. R10o now
supplies those bounty/wreck campaign owners and rule-tested collection above;
native full collection and death/recovery remain required.

R10g opt-in version24 preserves version1–23 validation before migration and
adds ground session/reward/defeat fields. Space loss ownership was pending at
that checkpoint; R10i now validates it in the opt-in ship host.
R10h live version24 is now `ground-encounters-1`. R10i adds opt-in25
`ship-encounters-1`; R10j extends it to opt-in26 `ship-communication-1` with frozen
Comm/returns/deadlines and saved sleep activity. R10m adds opt-in27
`ship-tactical-1` with `content.tactical:true`, exact controller/input/menu state,
historical carry migration and source startup/frame/clock integration. R10n
extends the opt-in to28 `ship-input-1`, exact saved button-latch/history, strict
historical27 migration and the corrected native Comm dispatch ordering. Live
remained24 through R10q; R10r activates29 after connecting and verifying space
controls and the saved host. R10o extends the
opt-in to29 `ship-salvage-1`, adding strict historical28 migration and actual
bounty/wreck/tractor ownership. The source
audit corrects prior arrival-only production, reversed system comparison,
cryogen producer eligibility, engines-off RNG, even-phase movement and failed
phase3 fuel deductions; see [space host](space-host.md). Colony
contracts/deliveries/growth/ending remain R11; this audit does not defer any R10
requirement to R11.

## Source dispatch notes for the next integration

Game16 procedure39's actual case-pointer table `$13BC–$13D2` maps kinds12–23,
in order: `16,80,81,51,65,32,reward,police,default,48,33,96`. In particular,
kind16 starts threat entry65, kind18 is the reward/small-payment branch, kind19
is ground police entry50 or space entry64, and kind21 is social entry48. Kind15
is the post-fight/source money-quote entry51. Do not infer these mappings from
the physical order of code blocks.

Game21 procedure30 `$14E4–$14EC` supplies local61 from system record
word8/nibble3, matching the same source system nibble used for dialogue local32
and space piracy. Procedure1 `$1EFA–$1F1A` draws its `RNG MOD64` gate eagerly
on each due ground machinery tick, then combines scene3, foot-mode and local35.
Procedure27 sets local35 for Banville (city60); procedure17 also sets it for
its special context. Procedure40 `$1DB8–$1DE5` chooses caught kind16 only when
`RNG MOD16 > local61` and tile<12; otherwise another draw chooses kind22/18.
These source branches need their real map/timing context, not a substitute
random encounter probability attached to pointer movement.

R10d confirms scene3 is the eligible **city** map; scene4 is the world surface.
The original city payload fills a central region of the40×24 runtime map.
Retained exit flags28/114 can replace a forced fixture's coordinates; those
flags must be accounted for before interpreting an off-map tile0 probe. The
passing reference clears them, uses actual tile8, and follows source preparation
instead of injecting combat records or scene5.

## R10r current validation inventory

[r10r-validation-summary.json](r10r-validation-summary.json) records23 passing
receipts:503 rule groups and1183 UI checks across22 runs, including17 earlier
machinery/engineering/service/interior regressions. Ordinary source ground
avoidance is now proven by two naturally produced fresh-character chases in the
exchange journey. The original milestone remains **in progress** for native
collection, exceptional defeat returns, rare reward224 and the remaining
ordinary encounter/equipment/negotiation/recovery acceptance above.

## R10s native collection and return-menu correction

[Native Tractor continuation](ship-salvage-reference.md) retains12 asserted
source contexts and26 hashed artifacts from an owned IIe session with exit0.
The declared wreck/empty-slot/source-command-entry fixture proves the full
original proc18 loop, slot2 copy, inhibition clearing and return to the main
loop. It does not prove ordinary menu selection, a new kill or fresh-character
acceptance. Native phase2→3/charge68→60 occurs in proc15's release poll after
collection; the host now commits that call before returning control.

[504 browser rule groups](r10s-rules-validation.json) pass, including the native
vector, exact partial/completed reloads and auxiliary-fuel ordering. The full
R10 objective remains open for fatal entry/startup and Comm-dispatch contexts,
rare reward224 and ordinary encounter/equipment/negotiation/recovery acceptance.

[110 live space UI checks](r10s-space-ui-validation.json) also pass with no page
errors, retaining both locales, four viewports, cadence/reload/pause, Comm,
cargo loss and terminal recovery regressions. The [R10s inventory](r10s-validation-summary.json)
records these results separately from the historical R10r inventory above.

## R10t fatal first-startup continuation

[The native first-startup reference](ship-startup-defeat-reference.md) retains12
asserted source contexts and27 hashed artifacts with an owned terminal exit0.
The declared counter0/source-call/fatal fixture observes the remaining two
startup calls, initial release poll, first main iteration and Game13 death
return. The corrected host matches phase1, gun52, cooldown26, clock+1 and the
unchanged post-hit RNG/condition, then freezes across reload. All505 browser
rule groups pass. Fatal second/third startup, warp pre-entry and Comm dispatch
remain separately unproven native contexts; no ordinary-play gate is closed by
this fixture.

[110 live space UI checks](r10t-space-ui-validation.json) pass with no page
errors. [The R10t inventory](r10t-validation-summary.json) separates this
checkpoint from earlier receipts;47 focused tactical groups and the static
content/input checks also pass. Browser and native sessions are closed.

## R10u later normal-startup fatal returns

[Second/third startup references](ship-later-startup-defeat-reference.md) retain21
asserted contexts and48 hashed artifacts across two owned terminal exits0.
Native cooldown30/34, phase1, gun52 and clock+1 corroborate the R10t generic
continuation. A delayed-shot host regression covers both entry paths and exact
terminal reload/freeze. These close the declared normal-startup return contexts;
fatal warp pre-entry and Comm dispatch remain open. The original R10 milestone
and all ordinary-play gates remain in progress.

[506 browser rule groups](r10u-rules-validation.json) and48 focused tactical
groups pass; [the R10u inventory](r10u-validation-summary.json) records the
native contexts separately from earlier checkpoints. No core behavior change
was required after the R10t correction.

## R10v fatal Comm dispatcher

[The fatal Comm reference](ship-comm-defeat-reference.md) retains8 asserted
source contexts and19 hashed artifacts from the repository runner's owned
IIe session with exit0. The native return has one machinery call, then clears
35/51 and polls354 to1 before death; phase2/gun68/cooldown40/time/RNG do not
advance again. The host now commits the omitted return flag and counter through
their campaign owners, with exact terminal reload/freeze coverage. Fatal warp
pre-entry remains required, along with reward224 and every remaining ordinary
encounter/equipment/negotiation/recovery gate.

[507 Chrome rule groups](r10v-rules-validation.json),
[110 live space UI checks](r10v-space-ui-validation.json) and49 focused tactical
groups pass. [The R10v inventory](r10v-validation-summary.json) records the
bounded native scope and every remaining gate. Owned sessions are closed.

## R10w ordinary ground fight and knockout-loss

[Ordinary ground acceptance](ordinary-ground-acceptance.md) uses two new
seed12345 characters with no campaign imports or state writes. The armed
journey defeats three naturally produced enemies, commits one2016Cr reward and
uses five actual shield charges while preserving health255. The unarmed
journey reaches source knockout/robbery, health87/vigor174/cash0, then reproduces
the saved result on a fresh page and explicitly restores an earlier fresh slot.
Storage/bank owners and immutable creation data remain intact. These are
ordinary victory, living loss and recovery contexts; terminal death and
peaceful negotiation are separately required.

The [R10w inventory](r10w-validation-summary.json) retains both UI receipts and
a repeated8-context native Comm check for the guarded source-breakpoint helper.
The native check adds no new gameplay acceptance gate. Prepared Warp probes
remain excluded from death-return evidence because their healthy control also
fails in the post-jump renderer. Fatal Warp, reward224 and the remaining
ordinary ground/space negotiation, space avoid/fight/lose, ship equipment and
terminal recovery gates remain open under the original milestone scope.
