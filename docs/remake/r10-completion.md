# R10 requirement audit

Status: **in progress**, 2026-10-08. This audit preserves the R10 row in
[PLAN-REMAKE.md](../../PLAN-REMAKE.md). Isolated cores and controlled references
do not establish completion of the live campaign milestone.

| Original requirement | Current evidence | Remaining work |
| --- | --- | --- |
| Complete dialogue predicates/actions | Existing Game16 interpreter has source predicate/action/builtin handlers. Predicate12–14 case pointers at `$047C/$047E/$0480` target the default false branch; builtin dispatch `$10E8` covers0–11, with later codes taking its default. [R10f encounter dialogue](encounter-dialogue.md) adds actual kind15/16/18/19/22 setup, bank/personal money outcomes, charged free-gift transfer, replay and enemy localization. R10h owns ground context/outcomes in live24. R10j connects frozen actual space context/verified returns in opt-in26. | Expose space Comm in live controls. Observe and resolve the unsupported rare reward target224. Complete negotiation acceptance in ordinary campaign play. |
| Ground threats | [Ground chase core](ground-chase.md) ports Game21's eager gate, actual map/system context, window, player/chaser ticks, blocked-step catch and escape. The controlled R10d path matches records/RNG. [Ground combat core](ground-combat.md) implements source actors, collision, weapons, shields, surrender and robbery. [R10h live host](ground-encounter-ui.md) connects movement/due clocks, chase, mandatory dialogue, combat, version24 saves and verified personal returns. | Prove fresh-character campaign acceptance through ordinary controls; retain native background/timing adaptation boundaries. |
| Pirate encounters | [Ship combat core](ship-combat.md) implements source production, movement, firing, damage and jettison. [R10i ship host](space-host.md) runs production during actual powered flight before power/combat, owns contact flags and system cooldown, and commits failures/hull/defeat/RNG in opt-in25. | Activate the host with live space controls and source frame/inhibit context; complete ordinary campaign acceptance. |
| Negotiation/evasion | Source cores include retreat/surrender flags, ground boundary escape and cargo-induced retreat. [Native space dialogue](encounter-reference.md) shows Comm and Agree/Refuse/Dismiss It. R10j connects actual frozen context/verified returns and the six-decrement/seventh-call cargo deadline to ticks/saves, including source exit aggression and jettison retaining the deadline. R10h live fixtures exercise ground escape, surrender/cancellation and refusal/fight on the same activation. | Expose space negotiation/deadline in live controls. Complete peaceful and fresh-character ordinary-play negotiation acceptance; Agree is not a permanent truce. |
| Tactical controls | [R10k–R10o tactical host](ship-tactical.md) adds native paddle mapping, sensor/menu gates, automatic/manual aim, source own movement, visibility and pre/post-due frame ordering. R10m connects startup/due calls and phase1 counter reset. [R10n native input](ship-tactical-input-reference.md) observes manual aim, fresh/held/empty-space fire, loop exit and Comm byte storage/return; opt-in28 saves the button latch and corrects cached-contact firing plus Game13's one return call. R10h live ground controls cover arrows/held pointer, Space/right-click/primary-pointer fire, surrender cancellation, pause and English/Korean help. | R10o implements source bounty/wreck/inhibition/tractor/salvage and saved bank/cargo ownership; expose live sensors/contact/aim/fire/tractor interactions and observe full native collection. Prove remaining controls through ordinary campaign acceptance. |
| Weapons/shields/damage | Ship and ground vectors cover charge, damage, equipment failure, health, hull and source quirks. R10h live laser shots and defeat commit personal inventory/condition with verified returns. | Activate R10i ship mutations in the live UI; complete equipment/shield and recovery acceptance through ordinary campaign play. |
| Cargo jettison | R10k core requires source bolt arming and preserves menu choices/stale auxiliary selection. Source selectable slots are types1–30, excluding cryogens31. Ship primitive preserves reverse slot order and RNG draws. R10i applies actual removals/loss ownership and cooldowns, conserving stored+lost cryogens and destroyed purchase costs. R10m joins armed choices and actual losses/costs to saved campaign state while retaining the due Comm deadline. | Connect live bolt-arming controls to actual cargo loss/deadline owners; prove UI loss/conservation and negotiation acceptance. Forced-selector cryogen-loss fixtures do not establish native menu reachability. |
| Defeat/recovery | Ship core sets defeat word347/scene12; ground core preserves scene-middle12 and source knock-out/robbery. R10h commits personal losses/condition, opens the ended-campaign scene and saves/reloads durable death markers without restarting time. R10i saves actual ship destruction independently of personal condition. [R10p native recovery and R10q due-frame exit](ship-recovery-reference.md) observe a fatal hull hit, original death dispatch, saved-point restart and playable ship continuation; the opt-in29 host now matches the observed post-move and extra display-return phase. | Audit fatal entry/startup and Comm-dispatch contexts; connect live saved-campaign recovery. Complete native tractor/wreck and ordinary defeat/recovery acceptance. Do not invent automatic restoration. |
| Deterministic avoid/fight/lose fixtures | Ground core exercises all three outcomes; ship vectors exercise shots, retreat, jettison and destruction. | Complete campaign/UI acceptance with legitimate action/state transitions, persistence and atomic rejection. Isolated injected fixtures do not replace ordinary-control acceptance. |
| At least one ground and one space encounter has original-game evidence | R10b records a valid controlled space contact and enemy dialogue. [R10d](ground-encounter-reference.md) records the Game21 gate/chase/catch and six-actor Game17 initialization. | This observation gate is met with declared controlled contexts; the earlier invalid scene5 probe remains excluded. The captures do not establish native damage/negotiation outcomes or live campaign acceptance. |
| Timing independent of display refresh | Ground cores and live R10h UI use serialized50ms remainders;30/60/144Hz browser display-timer shims yield identical campaign/replay/RNG with JSON resume and pause. R10j ship sessions persist awake/sleep remainders, forced/rest phases and actual deadlines. R10m adds saved50ms tactical-frame dispatch, actual startup/due clock calls and30/60/144Hz rules-state equivalence with reload/pause. | Activate/verify live space display refresh, sleep restoration and campaign-save continuation. Rule cadence proof does not substitute for live UI acceptance. |

R10q matches R10p's due-frame fatal continuation: post-hit movement followed by
one Game13 display-return machinery call, giving phase3, gun charge60,
cooldown35 and unchanged RNG/condition.503 Chrome rules and45 focused groups
pass, including terminal reload/freeze and phase1 hour-boundary chronology.
Fatal entry/startup and Comm-dispatch context, browser live recovery and
ordinary acceptance remain open.

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
remains24 until space controls are connected and verified. R10o extends the
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
