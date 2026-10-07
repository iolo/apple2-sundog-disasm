# R10 requirement audit

Status: **in progress**, 2026-10-07. This audit preserves the R10 row in
[PLAN-REMAKE.md](../../PLAN-REMAKE.md). Isolated cores and controlled references
do not establish completion of the live campaign milestone.

| Original requirement | Current evidence | Remaining work |
| --- | --- | --- |
| Complete dialogue predicates/actions | Existing Game16 interpreter has source predicate/action/builtin handlers. Predicate12–14 case pointers at `$047C/$047E/$0480` target the default false branch; builtin dispatch `$10E8` covers0–11, with later codes taking its default. Those defaults are source behavior. | Add actual encounter-kind setup, space/ground context, money/inventory/outcome ownership, replay validation and localized presentation. Exercise negotiation outcomes in live play. |
| Ground threats | [Ground combat core](ground-combat.md) implements Game17 records, player/NPC ticks, collision, weapons, shields, surrender, robbery and suspension. [R10d](ground-encounter-reference.md) records the valid prepared native path and initialization comparison. | Port Game21's gated chase/window preparation and actual system threshold; integrate its catch/escape result, ground return location and encounter dialogue. |
| Pirate encounters | [Ship combat core](ship-combat.md) implements source arrival production, movement, firing, damage and jettison. | Invoke production from actual arrival and combat after actual movement/power. Own system cooldown, equipment failures, hull, contact flags, defeat and RNG in campaign state. |
| Negotiation/evasion | Source cores include retreat, truce/surrender flags, ground boundary escape and cargo-induced retreat. [Native space dialogue](encounter-reference.md) shows Comm and Agree/Refuse/Dismiss It. | Add enemy conversation setup/dispatch and ordinary controls; apply accepted/refused/truce/surrender results atomically. Prove escape and peaceful outcomes through the live host. |
| Tactical controls | Ship shot primitive accepts focused/spray selection; ground ticks accept pointer movement/fire. | Implement actual sensors/contact/aim/fire interactions, source gating, keyboard/pointer mapping, pause and English/Korean help. |
| Weapons/shields/damage | Ship and ground vectors cover charge, damage, equipment failure, health, hull and source quirks. | Apply these mutations to live resources, engineering, inventory and condition; represent damaged/dead encounters and recovery scenes. |
| Cargo jettison | Ship primitive preserves reverse slot order and RNG draws, returning lost lots/cooldown signal. | Add controls, confirmation where source requires it, persistent cargo/cryogen loss ownership and conservation checks. |
| Defeat/recovery | Ship core sets defeat word347/scene12; ground core preserves scene-middle12 and source knock-out/robbery. | Trace and integrate host death/wreck/recovery dispatch, durable outcomes and legitimate continuation. Do not invent automatic restoration. |
| Deterministic avoid/fight/lose fixtures | Ground core exercises all three outcomes; ship vectors exercise shots, retreat, jettison and destruction. | Complete campaign/UI acceptance with legitimate action/state transitions, persistence and atomic rejection. Isolated injected fixtures do not replace ordinary-control acceptance. |
| At least one ground and one space encounter has original-game evidence | R10b records a valid controlled space contact and enemy dialogue. [R10d](ground-encounter-reference.md) records the Game21 gate/chase/catch and six-actor Game17 initialization. | This observation gate is met with declared controlled contexts; the earlier invalid scene5 probe remains excluded. The captures do not establish native damage/negotiation outcomes or live campaign acceptance. |
| Timing independent of display refresh | Ground core has serialized50 ms remainder and equal30/60/144 Hz results, including JSON resume/pause. Ship primitive performs one logical tick independent of rendering. | Connect both to the actual host clocks and verify display-refresh/save continuation for live encounters. |

The next integration schema must preserve version1–23 validation before
migration and introduce explicit encounter/session, loss and defeat fields.
Live version23 remains `regional-flight-1` until that checkpoint. Colony
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
