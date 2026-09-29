# SunDog web remake progress

## R06d — First walking building interiors — 2026-09-29

City types9/10 now admit foot entry into eight source-derived room layouts.
Walk with pointer/touch/keyboard, collide with walls/counters, access carried
inventory and return through the left doorway to the exact street position.
Entry, return and loading pause play. Indoor exploration uses the shared survival
clock. The browser displays generic building names while service/dialogue semantics
remain incomplete; no NPCs, purchases or conversations are invented.

The deterministic exporter reads original interaction records8–15 and native
fill-pattern tables to produce eight external room SVGs, player glyph22 and
separate collision rows. Glyph24 occupies the full7×8 cell, unlike the city mask.
Spawn is `(12,56)` and the native exit threshold normalizes to `x<=12`.
Fixed window placement, local stripe phase, boundary framing and explicit Enter
exit activation are documented browser adaptations. Types8/11 need additional
fixtures and remain gated. See `docs/remake/building-interiors.md`.

Version5 (`landed-rooms-1`) adds a room scene with a retained city door and a
reachable interior position. Extra layout IDs, non-door street anchors, walls,
disconnected counter areas and cross-scene fields fail validation. Versions1–4
retain their old scene rules before migration. No automatic slot rewrite or
gameplay RNG draw is introduced.

Chrome154.0.8037.57 passes56 new UI checks and90 browser rule groups. Both room
types are reached through ordinary city walking; English/Korean fit four
viewports. Regressions pass28 bank,44 city,45 campaign,37 equipment and14 recovery
checks. Thirteen exporter tests,135 artifacts,57 city references,584 source
strings and original input hashes pass. Receipts are in
`docs/remake/room-walk-validation.md` and its JSON companion.

Next: source NPC creation/state and dialogue actions, followed by special
fixtures/interactions for the remaining room types. R06 is still partial.

## R06c — Source city doors and bank visits — 2026-09-29

Walk to a Drahew bank door and use Enter or the contextual button to visit the
Uniteller. It shows generated cash and the current system's bank balance, under
the source-derived Jondd Bank name. Escape or Leave bank returns to the exact
street anchor, paused. The service screen supports English/Korean, keyboard,
pointer and touch; inquiry pauses movement and survival. Deposits, withdrawals,
transfers and other building interiors remain pending.

The pure door resolver ports all eleven foot/pod branches from game21
procedures19/20, including inclusive proximity boundaries and separate tile vs
door coordinate anchors. Only the foot-bank destination is enabled. Source
research identifies scene5's walking interiors, scene6's service dispatch, and
the already-extracted sixteen layout records for the next implementation.
See `docs/remake/city-buildings.md`.

Campaign version4 (`landed-bank-1`) preserves bank visits, requires an airlock-
reachable bank-door position and retains all existing state. Versions1/2/3
validate under their former scene rules before migration. Loading does not write
slots automatically. Invalid bank positions and balance edits are rejected.

Chrome154.0.8037.57 passes28 new UI checks,86 browser rule groups,44 city walking,
45 campaign,37 component exchange and14 recovery checks. The new smoke reaches
the bank through51 normal movement steps, tests save/reload and invalid import,
and checks both locales in four viewports. Twelve exporter tests,125 deterministic
artifacts,57 city references,584 source strings and original input hashes pass.
Receipts: `docs/remake/bank-visit-validation.md` and its JSON companion.

Next: port scene5 layout/fixture drawing, player collision and exit gates, then
NPC/dialogue state. R06 remains partial; bank transactions belong to R07 and need
mutable financial state rather than changes to the immutable creation record.

## R06b — Foot airlock, Drahew walking and exterior saves — 2026-09-29

Campaigns can leave through the landed foot airlock, walk through connected
Drahew streets and board again. The source-derived exit is full-map pixel
`(287,217)`; reentry returns to interior `(54,118)`. Enter and contextual buttons
require the correct proximity. Each transition pauses and clears held input.
Active equipment, carried items, condition and time persist across the round trip.

Added city glyph10/11, the ship36/37 plus attached-pod16 silhouette and pattern9
pixel collision. Collision ignores the background's alternating pixel columns;
the ship's replaced background is included. The camera follows city tiles.
Walking stays within the stored city rectangle until surface travel is implemented.
Exterior inventory exposes carried items; locker/stores and engineering remain
available only inside. City encounters and building entry are not yet implemented.

Campaign version3 (`landed-city-1`) adds active scene and full-map exterior player
position. Imports require a position reachable from the airlock and a consistent
interior reentry anchor. Version1/2 validate before migration; version2 equipment
is preserved. Raw-slot comparison and explicit saving remain unchanged. Corrected
the location documentation: legacy `surfacePosition` is the active map tile in
both city and world scenes; recipe2 names and values are retained for compatibility.

Chrome154.0.8037.57 passes44 new UI checks,83 rule groups,45 campaign checks,
37 equipment checks,97 city-preview checks and14 recovery checks. Both languages
fit four exterior viewport sizes and the expanded ship footer. Twelve exporter
tests,125 artifacts,57 city references,584 strings and original input hashes verify.
See `docs/remake/city-walking.md` and `city-walk-validation.md` with its JSON receipt.
No new original-emulator observation is claimed.

Next: source-backed building entrances/interiors, then the NPC/dialogue rules
needed for R06. Pod driving, encounters and city-to-surface travel remain bounded
out; trading and banking remain R07 work.

## R06a — Ordinary city composition and inspection — 2026-09-29

Added the source-derived background layer for all57 named ordinary cities:
40×24 buffers, x-major private RNG draws for240 stored cells, and separate
system/world-selected tile banks. Composition never consumes campaign randomness.
Independent packed-byte references verify every map cell and both bank selectors.

The preview now offers City view with a10×6 camera, horizontal wrapping, bounded
vertical panning and full-map tile inspection. English/Korean UI supports keyboard,
pointer and touch; locale/viewport changes preserve selection and camera. Stored
layouts retain manual bank selection. Records58–60 remain available as stored-only
layouts, since their runtime context is outside this ordinary-city path.

Required Chrome154.0.8037.57 passes97 city UI checks,78 browser rule/localization/
storage groups,45 campaign checks and37 component-exchange regressions. Both view
modes fit four viewport sizes in both languages; all city records browse offline.
Testing caught and fixed city-heading and mobile-footer fit issues. Eleven exporter
tests,122 artifacts,584 strings,6 captured equipment records and original input
hashes also verify. See `docs/remake/city-map-validation.md` and its JSON receipt.

This is a background/inspection checkpoint on the path to ship exits, not live
city walking. Campaign version2 and its reachable-interior position contract remain
unchanged. No new original-game emulator observation is claimed. Next: trace
collision against composed tiles and ship/pod overlays, establish exterior airlock
placement/reentry, then add active scene/location state and save migration.
Doors, NPCs and dialogue remain subsequent R06 work. See `docs/remake/city-maps.md`.

## R05f — Component exchanges and active equipment saves — 2026-09-29

Added atomic exchanges between carried items and compatible installed components,
including removal, replacement, occupied-slot exchange and cancellation. Both
destinations validate before writes; source-derived recalculation updates unit/total
performance and special-component availability. Selection never removes an item.
English/Korean panels preserve pending moves across locale/viewport changes.

Corrected a prior semantic error: record bytes20–23 are fixed socket requirements,
not spare inventory. Game14's fit/draw consumers establish this. The panel now
shows real carried items and names the selected socket's standard requirement.
The legacy `spares` field remains immutable for recipe2/save compatibility; it
cannot be used as an inventory source. Prior receipts retain their historical scope.

Campaign version2, scope `landed-engineering-1`, adds active equipment independently
of creation state. Validation rejects false ratings, incompatible sockets and
changed requirements. Valid version1 saves upgrade in memory after full validation;
slot writes remain explicit and retain raw-record conflict protection. Exchanges
persist through save/export, reload and import without altering creation data.

Required Chrome 154.0.8037.57 passes 72 browser groups, 37 exchange checks,
89 engineering, 45 campaign and 14 recovery/storage regressions. Both locales fit
640×480, 1280×720, 1920×1080 and390×844. Eleven exporter tests, 122 artifacts,
584 classified strings, six captured equipment records and original input hashes
verify. See `docs/remake/component-exchange.md` and its validation receipt.

Exchanges follow the paused browser inventory convention. Encoded damage repair,
power/charging, services and fuel remain pending; no original-emulator observation
or exact live repair timing is claimed. Next: ship exits/city transitions on R06,
then the planned economy and remaining R08/R09 machinery work. The user PRD remains
unchanged and untracked.

## R05e — Engineering bay inspection — 2026-09-29

Added campaign equipment inspection at all six source-mapped engineering bays.
Walk to a bay and use Engineering or Enter to identify installed components,
missing/destroyed parts, shunts and spares, with individual and total performance.
Previous/next stays within the source's three-system bay bank. The existing
component SVGs and localized item names supply the display.

Inspection owns a copy of validated creation equipment. It pauses movement/time,
clears held input, traps focus and returns paused; locale/resize preserves selection.
Preview walking remains independent. No component/resource mutation or save-scope
change is introduced. Source tracing and manual PDF pages11–12 establish the bay
mapping/window behavior; no new original-emulator observation is claimed.

Required Chrome 154.0.8037.57 passes 65 browser groups, 89 engineering checks,
45 campaign-flow and 14 recovery/storage regressions. Tests walk to every bay
through ordinary pointer input, verify all installed/spare labels and performance,
preserve the complete creation record and reopen engineering after fresh-page load.
English/Korean panels fit 640×480, 1280×720, 1920×1080 and 390×844. Eleven exporter
tests, 122 generated artifacts, 584 classified strings and original input hashes
verify. See `docs/remake/engineering.md` and `engineering-validation.md`.

Next: complete component transfer, recalculation and timing rules, then add active
equipment plus save validation before enabling replacement. Repairs, services,
power controls and ship exits remain pending; R04/R05/R08 are still partial.
The user PRD remains unchanged and untracked.

## R04h — Character-to-ship and campaign saves UI — 2026-09-28

Connected character allocation to a boarding form with optional explicit seed,
bounded browser entropy, unspent-points confirmation and atomic campaign creation.
The title now leads with character creation, resume and saved games. The ship
retains the full recipe2 creation record alongside active walking, inventory,
condition and elapsed time. New/loaded games enter paused with held input cleared.

Exposed four campaign slots and JSON import/export, including loading directly
from a fresh title screen. Preview walking and its checkpoint database stay
independent. Imports validate before replacement; storage failures retain JSON
recovery. Sleep blocks saves; death offers load/back without reset or save. There
is no autosave. Both locales cover scope, seed errors and recovery messages.

Required Chrome 154.0.8037.57 passes 63 browser groups, 45 campaign-flow checks,
14 recovery/storage checks, 25 character and 27 checkpoint regressions, four title
layout checks plus About focus, and six normal-time boarding visual checks. Fixed
a title text/action overlap. Boarding/save controls fit both locales at 640×480,
1280×720 and 390×844. Eleven exporter tests, 122 generated artifacts, 584 classified
strings and original input hashes verify. See `docs/remake/campaign-ui.md` and
`campaign-ui-validation.md`. No new emulator observation is claimed.

This completes the first character → ship → save → fresh-page load loop within
`landed-ship-1`. Machinery, exits, travel, trade and colony progression remain
pending. Next: source-backed equipment inspection and engineering rules, with
active-state/save extensions before resource mutation, then ship exits. R04/R05
remain partial. The user PRD remains unchanged and untracked.

## R04g — Ship resources and campaign save boundary — 2026-09-28

Completed and verified the pending ship-resource changes: initial hull, fuel,
warp/shield/gun charges and controls, destination/pod locations and pod attachment.
Updated the independent capture decoder so all reference fields regenerate from
original bytes. Nonzero synthetic values verify resource-word offsets and separate
the actual attachment flag from an unrelated scene bit that also starts true.

Corrected R04f's missing utility20 hull draw. Hull 13–16 is generated after the six
equipment groups and before systems. This changes later generation results, so
the recipe is now `shipped-defaults-2`; recipe1 is explicitly rejected by saves.
The original four gameplay RNG bytes and cash generation remain unchanged.

Added a versioned campaign codec and four independent transactional slots for
scope `landed-ship-1`. Immutable creation state stays separate from active ship
position, inventory, condition and time. Imports validate the entire creation
record against the recipe, preserve object independence, and reject unsupported
progress/fields. Stale-tab writes/deletes and invalid writes leave stored data
intact. The new database is separate from character drafts and ship checkpoints.

Required Chrome 154.0.8037.57 passes 61 browser groups. Eleven exporter tests,
122 artifacts, 584 classified strings and original input hashes verify. See
`docs/remake/ship-resources.md`, `campaign-saves.md` and `campaign-save-validation.md`.
No new emulator observation, machinery behavior or original-seed replay is claimed.

The new save modules are not yet exposed in the UI. Next: connect character
creation, explicit seed selection, campaign save controls and the landed ship
runtime, preserving the supported scope. Travel/machinery/colony transitions need
further state rules and save-version changes. The PRD remains untracked.

## R04f — Deterministic starting-state assembly — 2026-09-28

Added `createCampaignStart`, combining validated character attributes with cash,
inventory/condition, equipment, systems, orbits, markets/warehouses and independently
owned player/ship locations. The creation recipe takes an explicit seed, follows
utility21 →17 generation order, fixes the first orbital comparison to 0 and uses
immutable shipped defaults. Failures return no partial state or replacement seed.

Traced the first four utility draws to saved RNG bytes at word 64. Startup7 restores
these to the live RNG at word 21; they are not the utility's final generation state.
Both states are preserved separately. The fifth draw supplies 0–899 credits on hand.
Exported static starting-location fields and independently decoded the clean
capture: Jondd/Drahew, surface (10,6), city (12,7), player (54,110), ship (147,115).
Generated orbital angles remain dynamic and are shared by value, not object alias.

Required Chrome 154.0.8037.57 passes 56 browser groups, including four new assembly
groups and 100 deterministic campaign seed replays. Ten exporter tests, 122 artifacts,
584 source strings and original disk/manual hashes verify. Evidence and remaining
boundaries are in `docs/remake/campaign-start.md` and its validation receipt.

This is a starting-state assembly checkpoint, not a complete playable campaign.
It remains separate from character drafts, ship checkpoints and the live UI.
No new emulator observation or original-seed replay is claimed. Next: remaining
ship resources/modes and location-copy semantics, campaign save validation, then
character-to-ship integration. The user PRD remains unchanged and untracked.

## R04e — City economy initialization and refresh — 2026-09-28

Added named templates and city memberships, nine colony demand recipes, pure
initialization for 57 ordinary markets plus the colony, and four-slot warehouses
with 17 distinct cryogen placements. Exported data comes from utility defaults
and source literals; captured working records remain test evidence only. Correctly
excluded the overloaded phase-recipe and scratch-copy records from logical cities.

Implemented ordinary first-visit randomization and weekly replenishment. Preserved
supply-before-demand draws, strict negative-day initialization, day-zero revisits,
whole-week caps and partial-week loss. Commodity 31 stays outside these ordinary
loops. Placement preserves the source's exact 1-based cursor arithmetic and
occupied retries; bounded nonconvergence fails explicitly. State remains isolated.

Required Chrome 154.0.8037.57 passes 52 browser groups, including six new groups and
1000 economy seed replays. Nine exporter tests, 121 artifacts, 584 source strings
and original input hashes verify. An independent capture decoder confirms initial
market quantities, selector, city names, cargo layout and all nine recipes. The
recipes require 17 cryogen units in total. The original placement seed/order is
unknown; no complete original RNG replay is claimed. See
`docs/remake/economy-initialization.md` and `economy-validation.md`.

The restart required reopening Chrome and restarting the static development server.
No new emulator observation or unrelated interactive smoke run was performed.
The walkthrough, character drafts and checkpoint schema remain independent of
these foundations. R04/R05 are partial. Next: remaining global/location fields,
seed lifecycle and campaign assembly, then engineering and ship exits. Colony
delivery/rewards and phase advancement still need their complete transaction.
The user PRD remains unchanged and untracked.

## R04d — Source-derived initialization primitives — 2026-09-28

Implemented a serializable native RNG port and pure generators for six equipment
groups, 12 system coordinate triples/balances and 18 planetary orbital angles.
Equipment preserves original damage branches, missing/broken parts, shunts,
spares and performance totals. System generation preserves fixed Woremed,
clamped coordinate jitter, rejection spacing and starting balances. Independent
objects and explicit random streams prevent accidental reuse of prior state.

Exported only named navigation defaults: system/planet names, membership,
baseline coordinates and orbital radii. Saved balances, prior orbital angles,
flags and working gameplay records are excluded. The original modifies disk
world defaults between creations; the browser baseline/seed lifecycle remains an
explicit campaign integration decision. The first orbital comparison reads an
uninitialized outer local on the traced path, so the helper requires that boundary
as an input. Rejection loops fail explicitly instead of silently changing rules.

Used a2-cc65 guidance to extract the native library22 RNG loop and execute it with
cc65/sim65. All 112 transitions match JavaScript, including the unusual return-byte
order. Traced Pascal low-bit branches and eager random draw consumption. A
constructed compatible tape reproduces all six equipment records in the existing
clean-character capture; it is not an observed random stream or recovered seed.

Required Chrome 154.0.8037.57 passes 46 browser tests, including six new groups and
1,000 deterministic seed replays. Seven exporter tests, 120 artifacts, 584 source
strings and original disk/manual hashes verify. See `docs/remake/initialization.md`
and `initialization-validation.md` for offsets, checks and evidence limits.
No new Apple II play session or unrelated interactive smoke run is claimed.

This step adds tested initialization code, without changing the live walkthrough,
drafts or checkpoint schema. R04/R05 remain partial. Next: trace commodity/city
records (utility14/16) and remaining global/location fields, assemble campaign
state and connect character creation. Engineering/exit interactions follow that
state boundary. The user PRD remains unchanged and untracked.

## R04c — Explicit ship walkthrough checkpoints — 2026-09-28

Added four independent ship checkpoint slots with save/load/delete and JSON
import/export. They preserve position, all inventory bytes including charges,
condition and whole elapsed game minutes. Opening Saves pauses play; loading
resumes paused with held input cleared. Ended walkthroughs can load living
checkpoints, while sleep/death cannot be saved. Import changes only live state;
slot writes remain explicit. Drafts and future campaign saves stay separate.

Validation rejects incompatible versions/content, malformed inventories,
terminal conditions and coordinates outside the connected ship interior before
changing live state. Transactional comparisons prevent stale tabs from replacing
or deleting newer records. Unreadable records require explicit replacement or
deletion. Storage failure keeps JSON import/export usable and offers retry.
The format and safe-boundary timing adaptation are in `docs/remake/checkpoints.md`.

Required Chrome 154.0.8037.57 passes 40 browser tests and 64 smoke checks: 27 checkpoint,
14 survival edge and 23 movement. Coverage includes fresh-page restoration,
charged items, depleted condition, all four slots, JSON round-trip, invalid import,
cancellation, stale-tab conflict, offline use, storage failure, terminal recovery,
touch, focus and both locales at desktop/portrait sizes. Reviewed screenshots.
Six exporter tests, 119 artifacts, 584 source strings and original input hashes
verify. See `docs/remake/checkpoint-validation.md` and its JSON receipt.

R04/R05 remain partial: these are walkthrough checkpoints, not a complete campaign.
Next: name and implement the remaining clean world/equipment initialization,
connect character creation to campaign state, then consequential engineering/exit
interactions. Original sleep-loop and consumable-use observations remain pending.
No new emulator observation or original disk-save compatibility is claimed.
The user's PRD remains unchanged and untracked.

## R05d — Hourly survival and landed-ship sleep — 2026-09-28

Added an elapsed game clock and hourly rest/nourishment drain, health recovery
and vigor changes. Sleep restores rest while advancing time; exhaustion forces
sleep until rest exceeds 128. Zero vigor freezes the walkthrough and offers an
explicit fixture restart. Food now restores naturally depleted nourishment.
Normal play advances one game minute per real second; sleep uses 50 ms iterations.
These rates and menu pauses are browser adaptations, not original wall-clock
calibration. Hidden/unfocused pages pause with no catch-up. State still resets
on reload and stays separate from character drafts.

Traced library22 procedures26/29/60, library24 procedure9 and game8 procedures3/17.
Three controlled original-game hour transitions match the JavaScript results,
including sleep suppression of rest drain and a health-recovery threshold.
The RAM setup and helper are checked in as `docs/reference/remake-survival.json`
and `tools/remake/survival_reference.lua`. These are explicit fixtures; original
sleep UI, forced sleep/death and item use are not claimed as observed. Both owned
MAME launches were stopped, and original disk/manual hashes remain unchanged.

Required Chrome 154.0.8037.57 passes 35 browser tests and 104 smoke checks: 23 ordinary
survival, 11 depleted-condition edge fixtures, 25 inventory, 22 consumable and 23
movement checks. Coverage includes natural depletion, food restoration, sleep,
forced waking guard, terminal restart, touch wake, keyboard focus, both locales,
portrait layouts, pause/blur, offline use and reload. No production test hooks.
Six exporter tests, 119 artifacts and 584 classified source strings verify. Reviewed
sleep screenshots; fixed automatic-dialog focus to stay inside the active panel.
See `docs/remake/survival.md` and `survival-validation.md` for evidence and limits.

R04/R05 remain partial. Next: complete named world/equipment initialization and
campaign persistence, then consequential engineering/exit interactions. Original
sleep-loop and consumable-use observations remain follow-ups. Temporary attribute
recovery, ship machinery, outdoor sleep hazards and campaign events are not part
of this isolated landed-ship simulation. The user PRD remains untracked.

## R05c — Personal condition and food/rapidheal use — 2026-09-28

Added four condition meters and atomic food/rapidheal use from carried slots.
Food restores 80 nourishment and rapidheal 80 health, capped at 255. Both consume
one item even when full; English/Korean warnings make that explicit. Keyboard
focus returns to the empty slot, selection clears, and other supplies remain
unchanged. Condition uses source-verified full defaults and persists with the
walkthrough until reload. Hunger/fatigue do not yet accumulate.

Traced field order, 32-unit meter rounding, use targets, +80 effects, clamp and
consumption through game8, library27 and library22. Initial bytes independently
match the clean-character capture. A controlled MAME RAM fixture showed the
condition display, but attempted joystick item clicks did not establish successful
consumption. Item effects remain source-derived, not independently observed.
This limitation and the fixture are recorded in `docs/remake/condition.md` and
`docs/reference/remake-condition-fixture.json`. The owned emulator was stopped;
original disk/manual hashes remain unchanged.

Required Chrome 154.0.8037.57 passes 30 browser rule/storage tests and 156 smoke
checks: 22 condition, 25 inventory, 23 movement, 25 character and 61 preview.
New rule checks cover every starting byte for both consumables, including caps
and single consumption. Ordinary UI flows cover keyboard, touch, cancellation,
locales, offline use and reload. Reviewed English/Korean desktop/portrait layouts
and corrected grid/footer spacing. Six Python exporter tests, 119 artifacts and
584 classified strings verify. See `docs/remake/condition-validation.md` and
its JSON receipt for exact coverage and evidence limits.

R04/R05 remain partial. Next: trace and implement the survival clock and sleep,
confirm original consumable-use interactions, then finish named world/equipment
initialization and campaign persistence. The untracked user PRD and original
reconstruction deliverables remain outside this implementation commit.

## R05b — Carried items, locker and stores — 2026-09-28

Implemented four carried slots and twenty slots each in the ship's locker and
stores, gated by the recovered interaction regions. Select an item and destination
to transfer; occupied slots swap atomically while preserving the whole byte,
including shield charge. Cancel, Escape and closing cannot strand an item.
English/Korean labels, original composed item SVGs, keyboard focus handling,
touch taps and offline operation are included. Inventory pauses walking and
lasts within the page; reload resets the walkthrough fixture.

Traced slot layout, initialization, item encoding, writes and icon composition
through utility20/21, game14 and library27. All 44 initial inventory bytes match
the independent clean-character capture. A separate owned MAME session reached
Ship's Stores at (54,86) and moved food byte 8 from store slot 5 into carried slot 0,
without changing other captured slots. Checked in memory and screenshot evidence;
stopped the emulator and verified original disk/manual hashes. See
`docs/remake/inventory.md` and `docs/reference/remake-inventory-transfer.json`.

Required Chrome 154.0.8037.57 passes 25 inventory smoke checks, 25 browser tests,
23 movement checks, 61 preview checks and 25 character checks. Six exporter tests,
119 artifacts and 584 classified strings verify. Reviewed desktop/portrait
screens and removed an overlay flash. Source-pixel targeting in the smoke and
the locker reachability target were corrected. Full details are in
`docs/remake/inventory-validation.md` and its JSON receipt.

R04/R05 remain partial. Next: personal condition and item-use effects, engineering
equipment semantics, then complete world initialization and campaign persistence.
Character drafts and original reconstruction deliverables remain separate;
the user-supplied untracked PRD stays outside implementation commits.

## R05a — Source-backed ship walkthrough — 2026-09-28

Implemented full-ship walking with the recovered collision glyph, native
diagonal/X/Y attempt order and one-pixel fallback. Added separate collision data
and player SVG exports, pointer/touch hold-and-release, focused arrow keys,
pause/reset/help, lost-focus pause and bounded frame catch-up. English/Korean
controls fit the viewport. Stations report arrival; their systems remain pending.
Walk position lasts within the page and is separate from saved character drafts.

Required Chrome 154.0.8037.57 passes 23 walkthrough checks, 19 browser tests,
61 preview regression checks and 25 character regression checks. Four Python
export tests and all 94 artifacts verify. Coverage includes the native endpoint,
all 1784 connected ship positions, touch cancellation, DPR2 rendering, keyboard,
focus, locales, offline movement and copied-folder delivery. Visually reviewed
desktop/portrait walkthrough and preview screens. See `docs/remake/walk-validation.md`
and its JSON receipt. Original source assets and disk images are unchanged.

R04/R05 remain partial: next map named equipment/inventory and world initialization,
then add consequential ship interactions, status and campaign save/resume.
The user-supplied untracked PRD is excluded from implementation commits.

## R04b — Observed clean character and ship movement — 2026-09-28

Added a repeatable MAME new-character input sequence and captured the resulting
classified save state. Fresh name A, base attributes, 440 unspent points and
(54,110) coordinates are observed/source-cross-checked; descriptor and bank
checksum agree. The sequence completed on disposable media and the original
disks/manual still match their baseline hashes.

Traced native collision to shared glyph13 against low HGR bits, including the
first-success diagonal/X/Y attempts and one-pixel retry. A separate resumed-game
movement capture reaches (47,93) from (50,99) toward (3,81), matching the browser
rule. Its HGR differs from the source background only at player/pointer pixels.
Recorded the distinction between fresh creation and the existing play session.
See `docs/remake/ship-movement.md` and the two reference receipts.

This closes the missing clean-character observation and collision-rule trace;
full equipment/world initialization semantics remain open. Next: expose and
validate the bounded ship walkthrough, then implement the remaining systems.

## R04a — Character allocation and persistent drafts — 2026-09-28

Implemented the five source-derived attributes, 440-point allocation budget,
escalating costs and exact refunds. Added English/Korean character editing,
normalized Unicode names, four separate IndexedDB draft slots, explicit save/load,
JSON import/export, overwrite/reset confirmations and validation before mutation.
Campaign saves use a different future contract; the interface clearly labels
these as character drafts. No world defaults or collision rules were invented.

Validation in the required Chrome 154.0.8037.57: 13 browser unit/rule/storage
tests, 25 character smoke checks, and all 61 existing preview smoke checks pass.
Checks include cost-tier boundaries and full-budget exhaustion, Unicode names,
duplicate-name transaction rollback, reload persistence, JSON roundtrip,
invalid/future imports, cancelled overwrites, escaped display text, storage
failure/export fallback, locale preservation, and three character viewport sizes.
Visually reviewed English/Korean desktop/portrait character and draft layouts.
Fixed points/footer and title introduction/action overlaps; four final title-layout
checks and About focus restoration also pass. Corrected asynchronous waits and an accidentally
duplicated block in smoke automation. Source-string verification and diff checks
pass. See `docs/remake/character-validation.md` and the JSON receipt.

R04 is partial: fresh campaign initialization, campaign save/resume, and the
playable ship are still pending. Next is named initialization/equipment state and
a successful clean new-game reference capture, followed by collision/interaction
geometry for R05. Original assets and the accepted reconstruction exception stay
unchanged; the supplied untracked PRD remains outside these commits.

## R01b — Character allocation and movement source trace — 2026-09-27

Traced the five initial attributes, 440-point budget, escalating per-point costs,
minimum values, refunds, and unspent-point warning. Recorded source offsets and
independent cost checkpoints in `docs/remake/character-creation.md`. Traced ship
motion into the native collision consumer; collision semantics remain pending.

Booted a disposable disk1 copy in MAME 0.285, reached the four-slot utility
screen and the first slot menu, then stopped the owned session. Follow-up input
did not reach character allocation. No clean-state emulator fixture is claimed.
World generation/equipment semantics and observed initialization still gate
campaign creation. R04a will expose the verified allocation rules as explicitly
labelled character drafts, stored separately from campaign saves.

## R03a — Runnable bilingual browser preview — 2026-09-27

Implemented the first static ESM app in `remake/`: title, ship/city/world
inspection views, external SVG loader and Canvas renderer, 4:3 viewport,
English/Korean catalogs, local Mulmaru, pointer/keyboard selection, tile-bank
selection, help dialog and persistent language preference. No runtime libraries
or build step. Original assets are accessed only through the copied browser
exports. The app explicitly identifies itself as a preview.

Added six browser tests and repeatable Chrome smoke automation/configuration.
Final validation: all six browser tests and 61 smoke checks pass in the required
Chrome 154.0.8037.57; all 92 generated artifacts still verify and the three
exporter tests pass. Visually reviewed the generated SVG scenes in Chrome.
English/Korean layouts and pointer transforms were checked at four viewport
sizes. All 78 maps browse after network disconnection. A copied `remake/`
folder loads at a nested static URL with no repository dependency or external
runtime requests. See `docs/remake/browser-validation.md` and its JSON receipt.

Fixed small-viewport text/control sizing, constrained header layout and a test
favicon. Corrected smoke-helper resize timing and an unsupported CLI global.
No strict cross-browser, high-DPI or gameplay-fidelity test is claimed.

Checkpoint scope: R01/R02/R03 have their first substeps implemented. New game,
ship movement, campaign saves and the remaining systems are still pending.
Next implementation work is R01b: decode and observe clean new-game state and
movement, then R04/R05: persistent playable ship. Do not replace these evidence
gates with the preview's UI state or the prior players' saved-game payloads.

## R02a — Deterministic vector/content export — 2026-09-27

Added the standalone asset exporter, three focused tests, 92 generated browser
artifacts, and local Mulmaru v1.0 WOFF2/license/provenance. Exports include 88
SVGs, 60 live cities, 18 worlds, 64 item/cargo names and source/output hashes.
All artwork is external vector path data; original source assets are unchanged.

Validation: `python3 tools/remake/test_exports.py` (3 tests pass), exporter
`--check` passes for all 92 artifacts. Checks cover HGR holes/phase bits, vector
run boundaries, live-map filtering, and ignoring residual item-name storage.
Visual inspection of these exports follows in R03's browser preview.

R02 is partial: semantic interaction geometry and remaining gameplay assets/text
will accompany their features. See `docs/remake/assets.md` for representation
limits. Next: R03a, runnable localized browser preview and viewport/input checks.

## R01a — Behavior evidence and state boundaries — 2026-09-27

Implementation authorized. Added `docs/remake/behavior-matrix.md` and
`state-contract.md`, plus a repeatable index of 584 explicitly classified
p-code string records (`python3 tools/remake/source_index.py --check`).

Traced utility new-game entry 48 → name 31 → initialization 9 → attributes 22;
initialization 21 clears the globals area while preserving the name. Located
five attribute fields and the game-20 phase-nine completion branch. Recorded
source offsets, evidence levels, intended browser checks and version discrepancies.

R01 is partial: clean-state field semantics, an observed new-game fixture and
ship movement/collision still need work. These prevent claiming a playable
new game, but do not block R02/R03's independent asset and browser foundation.
No original-game behavior was invented to fill those gaps. Defined separate
preview UI state so a content inspection scene cannot be mistaken for a save.

Validation: source index regeneration/check passed; source passages reviewed
against the recorded offsets. No emulator run or old reconstruction test rerun.
Next: R02a, deterministic SVG/content export and local Mulmaru font.

## R00 — Resource review and implementation plan — 2026-09-27

Status: planning complete; application implementation has not started.

Read [PRD-REMAKE.md](PRD-REMAKE.md), the current reconstruction handoff and
delivery checklist, source/asset indexes, reference-session reports, and the
map, save-state, dialogue and utility documentation. Inspected representative
p-code and the existing ship screenshot. Confirmed `remake/` is empty.

The supplied manual is a 22-page scan with no extractable text. Visually
reviewed PDF page 7 and pages 11–22; used existing manual notes for pages 8–10.
Identified the campaign objective and the ship, navigation, city, encounter,
banking and trade flows that must be included in a full remake.

Checked the Mulmaru repository/release and the previously linked Atari ST port
and Resurrection Project. Verified the Mulmaru v1.0 release exposes proportional
and Mono archives; downloading/vendor installation remains an implementation
task. Checked browser documentation for ESM and optional service-worker delivery.

Created [PLAN-REMAKE.md](PLAN-REMAKE.md) with:

- A resource inventory distinguishing exact reconstruction from still-unknown
  gameplay semantics, including incomplete behavior/audio coverage.
- A native JavaScript architecture using Canvas, separate SVGs, local Mulmaru,
  English/Korean catalogs and versioned browser saves.
- A stated static-hosting interpretation of “no server”; literal `file://`
  launch requires a delivery decision before browser implementation.
- Steps R01–R13 with dependencies, concrete outputs, verification gates, a first
  playable ship milestone and a full campaign completion criterion.
- Bounded reference research and preservation of the accepted 488-byte exception.

Validation: checked referenced local paths and documentation formatting before
commit. The earlier 180-test reconstruction result is historical evidence, not
a new test run. No browser gameplay, live emulator run, exporter, font download,
or application implementation is claimed for this planning checkpoint.

Next planned step: R01, establish the behavior/source matrix, clean new-game
specification, early campaign requirements and the first ship interaction fixture.
The user's supplied `PRD-REMAKE.md` remains unchanged and outside this commit.
