# R10 requirement audit

Status: **in progress**, 2026-10-07. This audit preserves the R10 row in
[PLAN-REMAKE.md](../../PLAN-REMAKE.md). Isolated cores and controlled references
do not establish completion of the live campaign milestone.

| Original requirement | Current evidence | Remaining work |
| --- | --- | --- |
| Complete dialogue predicates/actions | Existing Game16 interpreter has source predicate/action/builtin handlers. Predicate12–14 case pointers at `$047C/$047E/$0480` target the default false branch; builtin dispatch `$10E8` covers0–11, with later codes taking its default. [R10f encounter dialogue](encounter-dialogue.md) adds actual kind15/16/18/19/22 setup, bank/personal money outcomes, charged free-gift transfer, replay and enemy localization. R10h owns ground context/outcomes in live24. R10j connects frozen actual space context/verified returns in opt-in26. | Expose space Comm in live controls. Observe and resolve the unsupported rare reward target224. Complete negotiation acceptance in ordinary campaign play. |
| Ground threats | [Ground chase core](ground-chase.md) ports Game21's eager gate, actual map/system context, window, player/chaser ticks, blocked-step catch and escape. The controlled R10d path matches records/RNG. [Ground combat core](ground-combat.md) implements source actors, collision, weapons, shields, surrender and robbery. [R10h live host](ground-encounter-ui.md) connects movement/due clocks, chase, mandatory dialogue, combat, version24 saves and verified personal returns. | Prove fresh-character campaign acceptance through ordinary controls; retain native background/timing adaptation boundaries. |
| Pirate encounters | [Ship combat core](ship-combat.md) implements source production, movement, firing, damage and jettison. [R10i ship host](space-host.md) runs production during actual powered flight before power/combat, owns contact flags and system cooldown, and commits failures/hull/defeat/RNG in opt-in25. | Activate the host with live space controls and source frame/inhibit context; complete ordinary campaign acceptance. |
| Negotiation/evasion | Source cores include retreat/surrender flags, ground boundary escape and cargo-induced retreat. [Native space dialogue](encounter-reference.md) shows Comm and Agree/Refuse/Dismiss It. R10j connects actual frozen context/verified returns and the six-decrement/seventh-call cargo deadline to ticks/saves, including source exit aggression and jettison retaining the deadline. R10h live fixtures exercise ground escape, surrender/cancellation and refusal/fight on the same activation. | Expose space negotiation/deadline in live controls. Complete peaceful and fresh-character ordinary-play negotiation acceptance; Agree is not a permanent truce. |
| Tactical controls | Ship shot primitive accepts focused/spray selection. R10h live ground controls cover arrows/held pointer, Space/right-click/primary-pointer fire, surrender cancellation, pause and English/Korean help. | Implement actual ship sensors/contact/aim/fire interactions and source gating. Prove remaining controls through ordinary campaign acceptance. |
| Weapons/shields/damage | Ship and ground vectors cover charge, damage, equipment failure, health, hull and source quirks. R10h live laser shots and defeat commit personal inventory/condition with verified returns. | Activate R10i ship mutations in the live UI; complete equipment/shield and recovery acceptance through ordinary campaign play. |
| Cargo jettison | Ship primitive preserves reverse slot order and RNG draws. R10i applies removals to actual attached cargo, owns aggregated losses and packed cooldown changes, conserves stored+lost cryogens, and retains destroyed purchase costs in the wealth bound. | Add live controls and source bolt-arming confirmation; prove UI loss/conservation and negotiation acceptance. |
| Defeat/recovery | Ship core sets defeat word347/scene12; ground core preserves scene-middle12 and source knock-out/robbery. R10h commits personal losses/condition, opens the ended-campaign scene and saves/reloads durable death markers without restarting time. R10i saves actual ship destruction independently of personal condition. | Trace and integrate full native death/wreck/recovery dispatch and legitimate continuation. Do not invent automatic restoration. |
| Deterministic avoid/fight/lose fixtures | Ground core exercises all three outcomes; ship vectors exercise shots, retreat, jettison and destruction. | Complete campaign/UI acceptance with legitimate action/state transitions, persistence and atomic rejection. Isolated injected fixtures do not replace ordinary-control acceptance. |
| At least one ground and one space encounter has original-game evidence | R10b records a valid controlled space contact and enemy dialogue. [R10d](ground-encounter-reference.md) records the Game21 gate/chase/catch and six-actor Game17 initialization. | This observation gate is met with declared controlled contexts; the earlier invalid scene5 probe remains excluded. The captures do not establish native damage/negotiation outcomes or live campaign acceptance. |
| Timing independent of display refresh | Ground cores and live R10h UI use serialized50ms remainders;30/60/144Hz browser display-timer shims yield identical campaign/replay/RNG with JSON resume and pause. R10j ship sessions persist awake/sleep remainders, forced/rest phases and actual deadlines, with cadence/pause/reload rule proof. | Activate/verify live space display refresh, sleep restoration and campaign-save continuation. |

R10g opt-in version24 preserves version1–23 validation before migration and
adds ground session/reward/defeat fields. Space loss ownership was pending at
that checkpoint; R10i now validates it in the opt-in ship host.
R10h live version24 is now `ground-encounters-1`. R10i adds opt-in25
`ship-encounters-1`; R10j extends it to opt-in26 `ship-communication-1` with frozen
Comm/returns/deadlines and saved sleep activity, without activating unfinished
space controls. Its source
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
