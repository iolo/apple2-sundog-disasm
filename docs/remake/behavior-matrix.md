# Remake behavior evidence — through R10b

For city/building milestone evidence, see [R06 completion audit](r06-completion.md).
Active deposits, withdrawals and inter-system transfers are traced and implemented
in [R07a banking](banking.md). [R07c exchange trading](exchange-trading.md) adds
local purchases, sales, warehouse ownership and version13 saves.
[R07d shop purchases](shop-purchases.md) adds cash-paid personal items/food and
version14 replay saves. [R07e cargo rules](cargo-loading.md) implement isolated
Store/Fetch/Swap and audit the [personal resale route](personal-item-resale.md).
[R07f personal trading](personal-trading.md) enables visitor purchases/sales and
version15 sale-income saves, with242 rule groups and34 new UI checks.
[R07g pod cargo](pod-cargo.md) adds local driving, loading, docking and version16
cargo saves. The [R07 audit](r07-completion.md) records its completed scope.
R08 adds source engineering failures, services, landed machinery, independent
parking, surface travel and version22 saves. Its [audit](r08-completion.md) maps
requirements to current rule and live journey evidence.
R09 activates regional flight, destination services and version23 saves across
12 systems,18 worlds and57 ordinary cities plus Banville. Its
[audit](r09-completion.md) maps all requirements to345 rule groups and667 UI
checks, including the ordinary-play two-system trade/return/reload journey.
R10a adds isolated source ship-combat rules and15 deterministic rule groups;
R10b observes a controlled original-game space contact and enemy Comm dialogue.
Live integration, native damage checks and ground observations remain pending.
The entries below retain their checkpoint-specific evidence; current save behavior
is in [campaign saves](campaign-saves.md).

This is a working specification, not a claim of complete semantic recovery.
Offsets are segment-relative hexadecimal; procedure numbers need their source
filename. `source-strings.json` indexes explicitly classified inline strings
with source lines, procedure, offset and exact bytes. It retains display-control
characters and includes historical variants; it is not a localization catalog.

| Flow / rule | Evidence | Status | Fixture / browser acceptance |
| --- | --- | --- | --- |
| Ship encounter, weapon, damage and jettison core | Library24 proc11/12/13; Game12 proc7/9/21; Library22 proc3/30/31/40; `remake-space-encounter.json` | Source-derived isolated rules; native contact/dialogue observed with declared fixture; live integration and native damage observation pending | Fifteen groups cover arrival cargo/RNG gates, motion/aim jump paths, shield and signed16 penetration, component/shunt failure, retained-pointer defeat, laser/cannon charge/accuracy, jettison and atomic guards. See `ship-combat.md` and `encounter-reference.md`. |
| Regional membership, reachability and economic ownership | Utility generated navigation/economy records; Library24 proc6 `$00A8–$00E9`; Game13 proc32; Game20 proc16 `$06B8–$07BC` | Source-derived, rule and ordinary-play UI validated; no new emulator capture | All12 systems,18 worlds,57 ordinary cities and Banville agree; all systems connect in the tested seeded graph. Independent stock/warehouses, origin-sensitive settlement, visited accounts and17 conserved cryogens. See `regional-world.md` and `r09-completion.md`. |
| Navigation, flight and landing | Game13 proc12/26/32/34/35/36/38/39/52; Library24 proc9/12/15; Library22 proc30/31 | Source-derived rules; explicit planetary timing adaptation; browser validated | Three localized map scales, review/confirm/cancel, launch/orbit/sublight/halt/warp/landing/city flight/distress. Source strict motion rolls, left-shift duration, shared fuel/clock/RNG and gravity failures. All58 city landings have declared-fixture access/save coverage;64 UI checks complete a fresh-character two-system trade/refuel/return. See `flight.md`. |
| Regional saves and counter context | Historical schemas1–22; Game16 proc39 `$1256–$1267`; source flight/ground state | Browser persistence adaptation, source state rules and migration validated | Version23 retains actual ship/pod worlds, all city economies, colony coordinates, motion interpolation, charge and distress deadline. Old conversations preserve original quotes until return; new counters use actual city tiles. Rejected imports are atomic; mid-flight continuation reproduces clock/RNG/resources. See `campaign-saves.md` and `r09-final-rules-validation.json`. |
| Parked pod ownership and boarding | Game21 proc6/7/8/16/21/25; Game18 proc21/26; Game15 proc8 | Source-derived, campaign rules and fresh-character browser journey validated | R08h separates pod occupancy/location from player foot visits, uses parked and detached-ship collision, blocks remote loading and preserves version21 saves.42 UI checks cover loaded parking, walking, reload and return. See `parked-pod.md`. |
| Depot services and auxiliary cargo | Game19 procedures18–26; Library28 payment; Library24 proc16; Game15 proc10 | Source-derived, campaign rules and fresh-character browser journey validated; no emulator capture | R08b activates services and auxiliary transport; R08e connects docking refill; R08f connects machinery consumption and verifies ordinary purchase/return/running systems/reload. See `depot-services.md`. |
| Landed machinery and readiness | Library24 proc8/9/14–17; Game12 proc1/17/19/23 | Source-derived, live rule/UI verification; explicit control/cadence adaptations | R08f runs guns/shields/cloaker with one aboard clock, dependency shutdown and version20 phase/resource saves.293 rule groups and31 machinery UI checks pass. Flight remains R09. See `ship-power.md`. |
| Four save slots | `utility_disk1.s` procedure 8, `$00D0–$00E0`, loop 0–3 with 32-word descriptor stride; reference utility screenshot | Source-derived and previously observed | Four independent slots; no fifth slot. R04a drafts and R04c ship checkpoints implement separate browser stores; campaign saves pending. |
| New-game entry | Utility procedure 48, `$1FE4–$2020`: deletion/replacement check, name flow (31), initialization (9), attributes (22) | Source-derived | New state must not clone one of the supplied saves. R04 pending. |
| Name validation | Utility procedure 37, `$1442–$1580`: trim surrounding spaces, reject empty/duplicate name, confirm | Source-derived | Empty/duplicate names rejected. Unicode/IME entry replaces joystick alphabet as a deliberate browser adaptation. |
| Initialization | Utility procedure 9 `$0A86–$0A93` selects bank `word31 + 10*slot`, then calls 21, 17, 18. Procedure 21 `$08EA–$0902` preserves name around clearing 512 bytes starting at segment-29 word 36 | Source-derived, incomplete field semantics | Clean allocation/save observed in R04b; generated field meanings and mutation order still need mapping; browser preview has no fake New Game action. |
| Attributes | Utility procedure 30 `$1036–$10B9` reads five bytes beginning at segment-29 word 48 as strength, intelligence, dexterity, charisma, luck | Source-derived | Schema records those five IDs; defaults, costs and refund rules are traced in `character-creation.md`; R04a implements editable drafts. |
| Initial coordinates | Utility procedure 21 `$09C7–$09D1` writes word40=54 and low byte word41=110; procedure 18 temporarily changes coordinates while copying six-word location blocks | Source-derived values; meaning partly unresolved | New-character save and ship entry case 11 verify (54,110); see `ship-movement.md`. |
| Generated world records | `docs/working-state.md`; utility 14 rotates 18 record templates using selector `(old+5)%18`; 17 persists world tables | Source-derived | R04d implements system position/balance and orbital-angle generators; utility14/16 commodity/city records still need semantic mapping. Extracted working records are not clean defaults. |
| Primary movement / secondary status | Manual PDF 10–12; game15 procedure13; library22 procedures9/22; `docs/reference/remake-ship-movement.json` | Movement source-derived with observed endpoint; status previously observed | R05a implements hold/release walking with the recovered glyph mask and fallback order. See `ship-movement.md` and `walk-validation.md`. R05c adds condition meters; complete status actions remain pending. |
| Ship artwork | `game_15.s` `$0315–$033C`, library 24 procedure 5; `docs/packed-ship-images.md` | Source-derived | External SVG derives from decoded HGR pixels; section/full variants remain separate. Native collision consumes low HGR bits with glyph13; explicit collision data is exported separately. |
| Carried items / ship storage | Utility20/21; game14 procedures3/4/8/12; library27 procedures7/13/15 | Source-derived; initial bytes match clean capture | R05b implements four carried slots and twenty each in locker/stores, reached through ship movement. Atomic two-click transfers preserve complete bytes. See `inventory.md`. |
| Item names / charge / icons | Library27 procedures3/4/10; play-side item-name table | Source-derived | External composed SVGs, English/Korean names, low-five-bit type and upper-three-bit shield/scattergun value. R05c supports food/rapidheal use; other item effects and engineering fit remain pending. |
| Personal condition | Game8 procedures2/7; utility21 `$0922–$092B`; manual PDF12; `remake-condition-fixture.json` | Source-derived, fresh values independently observed; controlled display observation | R05c shows vigor/rest/health/nourishment with `(value+7) div8` meter extent; initial bytes are 255. R05d adds hourly changes; see `condition.md` and `survival.md`. |
| Food / rapidheal | Library27 procedures11/14; library22 procedures34/35/37 | Source-derived; successful original use not observed | R05c adds 80 to nourishment/health, clamps to 255 and consumes one carried item even at full. Browser pure tests cover all 256 starting values for both effects. |
| Hourly survival / landed sleep | Library22 procedures26/29/60; library24 procedure9; game8 procedures3/17; `remake-survival.json` | Three hourly transitions observed with explicit RAM fixtures; sleep-loop effects source-derived | R05d adds clock, depletion/recovery, sleep, exhaustion and terminal restart. Browser cadence and menu pauses are explicit adaptations. See `survival.md` and `survival-validation.md`. |
| Ship checkpoint persistence | Browser adaptation over the verified R05a–d state; utility8 supplies only the four-slot convention | R04c implemented; no original save-format compatibility | Atomic validated restore, paused load, JSON round-trip, fresh-page persistence, independent slots and stale-tab protection. See `checkpoints.md` and `checkpoint-validation.md`. |
| Equipment initialization | Utility19/21; game14 procedure3; library24 procedure8; clean-character globals offset108 | Source-derived; all six captured initial records reproduced with constructed compatible draws | R04d pure generator for components, damage, spares and performance. Repair/ship consequences remain pending. See `initialization.md`. |
| Initialization randomness | Library22 native procedure3; Pascal FJP native handler | 112 source-loop transitions checked with sim65; startup seed not observed | R04d serializable RNG preserves byte order, seven shifts, eager draws and low-bit boolean behavior. |
| World/city payloads | `docs/world-maps.md`, `docs/city-maps.md`, `game_21.s` procedures 26/28 | Source-derived | Preview all 18 stored worlds and 60 play cities. R08i additionally composes18 surface maps with private terrain RNG and57 source city overlays; explicit colony placement owns gameplay RNG separately. |
| Surface terrain and city transitions | Game21 proc11/12/17/18/23/28/29; Library22 proc9 | Source-derived rules and normal-control browser journey verified | R08l activates source camera/terrain, independent domains and version22 saves.R08m passes60 UI surface/help checks and74 combined engineering/service/loaded-travel checks;319 rule groups cover terrain, all six starting-world destinations, ownership and historical migration. See `surface-travel.md`. |
| Colony requirement check | `game_20.s` procedure 4 `$00A0–$00B2` scans a 14-byte area using CSP 11 before proceeding; exact CSP predicate still to trace | Source-derived entry; predicate unresolved | Do not treat displaying a completion string as proof of delivery semantics. |
| Colony phase | Same procedure `$00B4–$00FE`: reads byte 2 at segment-29 word271, reports completed phase, tests equality with 9 | Source-derived | Store explicit phase and outstanding requirements; final phase must not be assumed to be a single delivery. |
| Campaign ending | Same procedure `$0101–$013B`: fulfilled-contract text, two packed fields of word45 set to 13; `startup_7.s` procedure 8 `$0647/$0665` congratulates player | Source-derived final branch | Later fixture must reach this through deliveries, not direct flag editing. |
| Next phase | `game_20.s` procedure 4 `$019D–$01AC` writes previous phase to byte1 and phase+1 to byte2 at word271 | Source-derived | Prevent repeated delivery effects. Quantities, cargo IDs and initial phase generation still pending. |
| Trading/banking | Manual PDF 19–20; `game_20.s` candidate consumer module, item table at `$0296–$02B5` | Manual-only financial rules | Bank-first purchase, sales to local bank, balances per system. Price formulas not yet ported. |
| Browser presentation | PLAN-REMAKE.md | Proposed adaptation | 4:3, separate SVGs, local font, English/Korean, pointer/keyboard/touch. No game-rule claim. |
| City doors / bank inquiry | Game21 procedures19/20/21; startup_disk1 scene dispatch; game19 procedures1/17 | Source-derived, browser validated | R06c ports door footprints and foot-bank visits; current-system account/cash inquiry and exact street return. Bank transactions remain pending; later rows cover live interiors. See `city-buildings.md`. |
| Walking building interiors | Game18 procedures14/16/17/26; library22 fill/collision; interaction records8–15 | Source-derived, browser validated; no emulator capture | R06d enables types9/10, eight static layouts, glyph24 collision, doorway exit and version5 saves. Fixed window/explicit exits are adaptations; R06e–n expand population and lodging below. See `building-interiors.md`. |

| Initial room occupants | Game18 procedures9/13/14/16; library22 procedures3/40; interaction bytes4–7/22–25, glyph23 | Source-derived, 64 independent Python vectors and browser validated; no emulator capture | R06e adds visitors/counter occupant and pixel collision; R06f–l add traffic/dialogue. R06m repairs the reversed-range fallback, with live staff-only entry/service/save/reentry checks. See `room-occupants.md` and `room-fixtures.md`. |

| Room visitor traffic / counter following | Game18 procedures5–13/27/28; fresh-visit flag reset in procedure21; library22 movement | Source-derived, browser rules and UI validated; no emulator capture | R06f adds arrivals, departures, blocked-route recovery, counter motion and live actor saves.50ms cadence and followed-slot compaction repair are adaptations. R06l/n add dialogue; R06o/p add live tavern seats and secondary movement. See `room-traffic.md` and `tavern-traffic.md`. |
| Lodging rental and bedrooms | Game16 procedures3/39, bank95 states96–101; Game18 procedures15/19/21/25 | Source-derived,179 browser rule groups and27 lodging UI checks; no emulator capture | R06n adds type11 clerk dialogue, fee/debit, random room assignment, dynamic doors and version9 cash/access saves. Mid-payment and closed-bedroom reloads pass. See `lodging.md`. |
| Tavern seating and conversation | Game18 procedures8/21/23/24/28; Game16 procedure39 and banks90/91/92/97/100/101/102 | Source-derived,196 browser rule groups and36 tavern UI checks; no emulator capture | R06p enables type8 entry, bartender12, visitor21/22, small talk/jokes, tips, localized presentation and version10 replay saves. Actual-speaker return and moving-visitor reload are checked. Food/item trading remains R07. See `tavern-dialogue.md`. |

## New-game and campaign blockers

R04b observes clean character creation on disposable disks; R05a implements the
traced movement/collision rules. Attribute allocation is implemented in R04a.
To finish R04, map the remaining utility procedures 10–21 and 25–30 into named
state fields, including money, inventory/equipment, time, world generation and
randomness. R05b implements storage transfers; R05c adds personal condition and
food/rapidheal use; R05d adds a clock and landed-ship survival/sleep. R05 still
needs engineering, exits and other consequential interactions. Original sleep
UI and item-use observations remain incomplete.
Before R11, decode phase requirement generation, delivery accounting and the
remaining-goods predicate. These block gameplay fidelity, not the independent
graphics loader, content viewer, localization or viewport work.

The first ship fixture is specified as: a verified new state near the airlock,
primary press/hold/release movement, secondary status open/close, one supported
inventory transfer, save, fresh-session reload, continuation. It remains pending
until initialization, status, inventory and campaign persistence pass. Development previews have their
own UI state and must never be serialized as campaign saves.

## Discrepancies and decisions

- Manual PDF 9 describes eight games and different disk roles. Use four slots
  and the observed supplied-image roles (disk1 title/utilities, disk2 play).
- Source string lengths/ASCII are original constraints. Browser names and text
  accept Korean; retain stable IDs and define a Unicode length limit in R04.
- Original display-control symbols (`|`, backslash, etc.) are preserved in the
  source index. Translate their meaning when building UI; never show them raw.
- A bank-selected, overlaid city screen is not the bare 20×12 payload. The
  preview calls it a stored layout; palette and variant choices are preview
  presentation, not evidence of original composition.
- The accepted 488 bytes remain out of scope. No new dependencies on them.

Manual page index and available resource inventory remain in PLAN-REMAKE.md.
