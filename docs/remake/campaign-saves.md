# Campaign save boundary — through R09f

R09 activates version23, scope`regional-flight-1`, in the live UI. The asset
loader supplies `regional:true`, flight defaults and
`ground:{maps,cityWalk,surfaceWalk}`. Ground-only and city-only consumers retain
versions22 and21 respectively and reject newer scopes they cannot render.
The [R09 completion audit](r09-completion.md) records345 rule groups and667 UI
checks, including a two-system trade/return/reload journey.

Version23 adds `regional:{shipLocation,podWorldId,colonyPosition,cities,
cargoProceeds,legacyDialogueSurface}` and
`flight:{motion,refuelAt,lastEvent}`. The archive owns56 dormant ordinary city
economies; the active exchange owns the remaining city. Cargo and all17 cryogens
have one owner across warehouses and pod. Money plus stored purchase costs is
bounded by creation wealth and validated personal/cargo gross proceeds.
Ship and pod worlds remain independent when a pod is left behind.

Regional validation checks membership, destination geometry, generated colony
terrain, motion kind/target/duration/interpolation, charge requirements, engine
flags and a single distress deadline. All18 capitals and57 ordinary cities plus
Banville have landing/access/save coverage. Mid-launch, sublight, charging,
landing and distress reloads continue with identical clock, RNG and resources.
All historical versions1–22 validate before regional metadata is added; they
cannot inject flight or archive fields. An open historical conversation retains
its creation surface coordinates in a strictly bounded `legacyDialogueSurface`
hint until verified return, preserving old quotes. New counters use actual city
tiles. See [regional ownership](regional-world.md) and [flight rules](flight.md).

The following version22 description records the earlier ground-only boundary.

Version22 adds`ground:{worldId,cityId,podCityId,colonyPosition,camera}` and the
`surface` travel scene. It retains the existing travel position, pod cargo and
resources without duplicating their ownership. The validator uses the actual
city/surface geometry, connected surface component from source departure
anchors, city entry borders and ship/parked-pod geometry. It validates independent
pod domains, surface heading26 vs city headings14/16/18/20, occupied position
agreement, exact fields and visible camera bounds. Only source city side/corner
arrival anchors may overlap surface terrain; arbitrary blocked imports fail.
Colony coordinates must be on eligible composed terrain and cannot overlap an
ordinary city. Its prior RNG draw history is not replayed; this is validated
progress rather than an anti-cheat log.

Ground imports retain local financial/cargo conservation, source ship resources,
equipment/machinery, room replay and detached interior validation. Unsupported
remote room/service visits are rejected, so another city's coordinates cannot
access the starting market or account through this checkpoint. Surface/city
transition reducers do not advance money or consume cargo. Boarding checks
same-domain proximity, including recovery at the original overlapping arrival
anchors after parking there.

Versions1–21 are validated against their historical schemas and geometry before
ground metadata is added. Migration starts in the original city with no colony
placement or invented surface progress; detached/occupied cargo is preserved.
Old saves cannot inject the new ground record or expanded city coordinates.
Current-city pixel checks keep their original field scope when surface content
is absent. Ground-aware validators own their content and cap per-city/per-colony
reachability caches. See `ground-save-rules-validation.json`:317 passing groups,
including all21 legacy schemas, ground travel round trips, key-order independent
imports, source-arrival recovery, remote-service rejection and malformed saves.

`campaignSaveCodec(content, geometry, cityGeometry)` writes `sundog-campaign`
version23 with regional content, version22 with ground content (version21 for
city-only content), and validates/upgrades version1 `landed-ship-1`,
version2 `landed-engineering-1`, version3 `landed-city-1`, version4 `landed-bank-1`,
version5 `landed-rooms-1`, version6 `landed-occupants-1`, version7 `landed-traffic-1`
version8 `landed-dialogue-1`, version9 `landed-lodging-1`, version10 `landed-taverns-1`
version11 `landed-services-1`, version12 `landed-banking-1`, version13 `landed-exchange-1`, version14 `landed-purchases-1`, version15 `landed-personal-trade-1`, version16 `landed-local-cargo-1`, version17 `landed-trader-matching-1`, version18 `landed-depot-1`, version19 `landed-failures-1`, version20 `landed-power-1`, and version21 `landed-parking-1`.
`openCampaignStore` gives four indexed slots in the separate
`sundog-campaigns` database. R04h exposes this through title and ship Saved games;
see [character-to-ship flow](campaign-ui.md).
Character drafts and standalone ship checkpoints retain their existing formats.

Version15 adds visitor purchases/sales and `economy.personalTrade:{sold,proceeds}`,
with32-entry gross sale counts/income indexed by low-five-bit item type. Source
price bounds validate the ledger; the wealth ceiling adds its total proceeds.
Open conversations derive receipts from replay and commit them with cash/items
once on return. Versions1–14 receive zero totals after their original field/input
checks; older saves cannot introduce visitor trade acceptance or handover.
See [personal trading](personal-trading.md) for bounds and validation limitations.

Version14 adds explicit `purchase` replay inputs for cash-paid shop and bartender
items. Accepted quotes do not pay until an empty carried destination is chosen.
Working cash/items reconstruct from the input log and commit together on return;
versions1–13 cannot inject these inputs or bartender food selection. No new
economy fields are needed because purchases only reduce cash. See
[shop purchases](shop-purchases.md).

Version16 connects the [cargo core](cargo-loading.md) to local pod transport and
loading. The active `pod` block owns attachment, city position, heading and two
cargo slots. Both containers contribute paid costs to the wealth ceiling and
conserve the initial local cryogens. Detached travel requires reachable pod
geometry and pod exchange entry. Versions1–15 migrate with an attached empty pod
after historical validation. See [pod cargo](pod-cargo.md).

Version17 adds [bartender matching](trader-matching.md) using existing dialogue
flags/workspace and visitor words. Pending flag65, kind17 contacts and visitor
high item bytes are accepted only in this scope. Historical bartender Buy/Sell
replay inputs stay blocked for versions1–16. Version16 pod/cargo progress is
preserved exactly. Fresh room entry clears the request; leaving discards actors.

Version18 adds active `resources` and depot purchases. Legacy saves receive an
owned copy of initial hull/fuel and inactive machinery after historical validation.
Versions18 onward accept world-origin auxiliary fuel cargo and detached pod depot
visits. See [depot services](depot-services.md) for source rules and constraints.
R08e's automatic docking refill uses the existing255 fuel/null cargo values and
therefore retains version19. Only an actual dock consumes a load; importing or
loading an already-docked save does not repeat it.

Version19 adds pending faulty installations and their temporary performance cache.
Versions1–18 validate their original plain installed-part rules before receiving
an empty engineering state. Version18 resources and depot cargo carry forward.
See [component failures](equipment-failures.md) for update ordering and browser
timing adaptations.

Version20 adds live landed machinery. Versions1–19 retain their original resource
validation before receiving phase0 and cloaker-off. Version19 pending failures
are preserved. See [ship power](ship-power.md) for clock ownership and adaptations.

The state has eleven explicit parts:

- `machinery`: `phase`0–3 tracks completed phases modulo4; `cloaked` requires a
  working special component in the shield group. The next phase1 advances time.
  Inoperative guns cannot retain power/charge; inoperative shields cannot retain
  a positive target. Browser fractional elapsed time is not saved.

- `engineering`: six `pendingFailures` source offsets (`unit*5+socket`), with31
  meaning none. Only each marked socket may contain a compatible encoded faulty
  component. Its temporary output uses the masked type; all other output remains
  canonical. Multiple combat faults are outside this installation-only scope.

- `resources`: current hull/fuel, gun charge/power and shield charge/target.
  Depot purchases change hull/fuel without rewriting the immutable `start` record.
  Hull remains from its initial value through16; fuel/charges permit0–255.
  Shield targets follow source button steps (0,63,64,127,128,191,192,255).
  Version23 activates warp charge/target/destination and engine motion; older
  schemas require those fields to remain inactive. Historical18/19 require
  fuel multiples of16 or255 and zero/off machinery before migration.

- `start`: the immutable creation record, including recipe/seed, both RNG states,
  character, initial inventory/condition, equipment, resources, generated systems,
  markets/cargo, colony counters and all four starting locations.
- `dialogue`: active cash, attributes,128 boolean flags and counter workspace. Open
  conversations are saved in `encounters.counter` as a service phase plus an
  initial RNG/input record, replayed on import. See [live dialogue](dialogue-ui.md)
  for replay validation and [lodging](lodging.md) for version9 cash/access rules.
- `ship`: active player position, inventory, condition and whole elapsed minutes
  for the currently supported ship walking, inventory and survival rules.
- `equipment`: active installed components, validated performance and special-part
  availability. Group/socket requirements are immutable metadata. The legacy
  field name `spares` means socket requirements, not removable inventory.
- `economy`: twelve ordered `accounts`, each with `systemId` and nonnegative
  integer `balance`. Banking changes these accounts and `dialogue.cash` atomically.
  `exchange` owns the local market, four warehouse slots and nullable offer board.
  `personalTrade` owns completed personal-sale counts and gross proceeds.
  Other cities remain immutable creation data. See [exchange trading](exchange-trading.md).
- `pod`: active attachment, nullable exterior position, directional glyph heading,
  two cargo slots and boolean `occupied`. Attached pods are unoccupied with null
  position/heading16. Occupied pods share the active city position and require
  city/exchange/depot scenes. Unoccupied detached pods keep their own reachable
  position during foot city/room/service/ship visits. See [parking](parked-pod.md).
- `travel`: active scene (`ship`, `city`, `bank`, `room`, `transstation`, `depot`
  or `exchange`) and full-map city player pixels.
  `cityPosition` is null inside the ship; outside it must be reachable with the
  current foot/pod geometry. Parked foot geometry includes the pod obstacle and
  source-clear disembark/airlock origins.
  While outside, `ship.position` is the fixed interior reentry anchor `(54,118)`.
  At a bank the city position must also match a source foot-bank door footprint.
  Other service scenes require their matching reachable foot door; occupied
  pods instead require the matching exchange/depot entrance and pod reachability;
  no redundant service identity is stored. Exchange progress lives in `economy.exchange`.
  In a room, the city position retains the entry door; a third field,
  `roomPosition`, must be reachable from the derived layout's interior spawn.
  It is forbidden in other scenes. City tile types8/9/10/11 are currently enabled.
  Type11 additionally requires `lodging: {rented, openMask}`; a saved bedroom can
  reach the doorway through its rented door even while that door is closed.

- `encounters`: unsigned gameplay `randomState`, nullable `roomSeed` and nullable
  `roomState` (actors, active visitor and waiting count). Entry derives occupants;
  traffic advances their state and RNG. Exit clears room seed/state. Outside rooms
  both must be null. Reload validates native actor words, supported actions,
  reachable positions, counter targets, queue references and visible overlap.
  Type8 requires a population and adds `tavern: {playerSeat, secondary, contact}`
  inside `roomState`. An active contact must have a matching talking/replay record;
  its speaker is derived from that contact when replay begins. See
  [tavern dialogue](tavern-dialogue.md).

The initial inventory/location in `start` records where this campaign began.
Current play uses the active state blocks, including `economy.accounts` and
`dialogue.cash`. It must never read stale initial values as live progress.
Carried cash can increase through withdrawals or personal-item sales and decrease
through purchases, deposits, lodging and bartender tips; system transfers conserve account totals.
Local warehouse trades update cash/accounts, stock and stored cargo together.
Other cities and navigation are not yet mutable; allowing
those actions later requires an explicit schema and transition update.

## Validation and transactions

The codec owns a copy of the supplied shipped content. It regenerates the creation
record using recipe2 and the saved character/seed, then compares every field,
independent of JSON object key order. Changed creation balances, cargo, resource levels,
creation RNG states, locations, old recipes and extra fields fail validation. Validation
returns newly owned objects; it never silently repairs unsupported progress.

Active equipment accepts empty/destroyed sockets, compatible plain components,
and version19's matching pending encoded installation. Validation recomputes unit
output, total output and special availability, rejecting
false cached values or changed requirements. Version1 first passes its original
two-part state checks; only then is active equipment derived from creation data.
Version2 preserves its validated active equipment. Both acquire an interior
`travel` state. Version3 validates scene/position consistency and rejects positions
inside walls, disconnected from the airlock or beyond the supported city area.
Version3 migration preserves ship/city state and rejects bank scenes. Version4
additionally permits validated bank visits, restoring the service screen.
Version5 additionally validates room door/layout/reachability; version4 migration
cannot introduce room fields. Room saves preserve a visit at its interior anchor.
Version6 adds initial occupants and active RNG. Version7 saves live traffic state
and no longer compares the active RNG with the initial population tail. Version6
migration performs that comparison before reconstructing initial actors. See
[room traffic](room-traffic.md) for actor validation, cadence and repairs. Versions1–5 receive the creation
gameplay RNG and a null seed after validation. Legacy interiors remain empty until
re-entry; null room seeds are retained for that migration. See
[room occupants](room-occupants.md) for the seed contract and
[room fixtures](room-fixtures.md) for the R06m fallback repair.
See [component exchange](component-exchange.md) for fit rules and scope limits.

Version10 accepts all thirteen foot layouts. Versions1–9 reject tavern visits
before migration; version9 still requires workspace actor0. Version10 permits
actor0 or visitor2–8 as the last dialogue speaker, including after departure.
Tavern traffic independently validates its live actor references and reservations.
Open conversations replay from the untouched campaign attributes/cash and input
history; tips, speaker mood/gate and return movement commit together at completion.

Version11 adds read-only TransStation, depot and exchange visits. Versions1–10
reject these scenes before migration; existing version10 state carries forward
unchanged. Their inspection pauses survival/movement and returns to the exact
street anchor. Transactions and navigation were unavailable in that version. R07 adds bank and
exchange transactions; version18 activates depot services; TransStation actions remain future work. See `city-services.md`.

Version12 adds active system accounts and deposit/withdraw/transfer operations.
Versions1–11 reject the new block and retain their original carried-cash limits
before migration; derived accounts then come from the validated creation record.
Version12 requires cash and every account to be in0..32,767,999, with their combined
total no greater than original total money. Thus withdrawals may raise cash above
its creation value while unsupported new wealth is rejected. Lodging/tips may
reduce total money. Version13 expands this bound to include stored purchase costs.
Pending bank amounts/destinations are UI drafts, not committed or serialized state.
See `banking.md` for source arithmetic, deliberate adaptations and tests.

Version13 adds `economy.exchange` with active local market/warehouse state and
nullable offers. Saved offers retain their quote quantities so stale asking prices
can be recomputed exactly. Initial cryogens cannot disappear; local purchased lots
have the current city as origin. Cash plus all accounts plus stored purchase costs
cannot exceed creation wealth in version13/14; version15 additionally allows
validated gross personal-sale proceeds. Historical versions reject exchange fields before
migration. A legacy preview prepares its first board on UI resume; an existing
version13 board reloads without draws. See [exchange trading](exchange-trading.md)
for the schema, validation limits, settlement adaptation and tests.

Active ship validation reuses the tested reachable-position, inventory-capacity,
item-byte and condition checks from the checkpoint codec. Only living, awake
snapshots are supported; sleep/input/inspection phases are transient and are not part
of this format. The UI prohibits saving during sleep and restores paused with
held input cleared, as the walkthrough checkpoint UI does.
All four service visits are explicit scenes and are preserved by saves.

Import is bounded to 131072 text characters, rejects malformed JSON, future
versions, unsupported scopes, invalid slots/timestamps, and foreign draft or
checkpoint envelopes. Extra state is rejected instead of discarded. Invalid
imports return no replacement state. This is consistency validation, not a
cryptographic anti-cheat system: anyone can create a different valid campaign.

Storage reuses the checkpoint store's transactional comparison against the record
the caller last displayed. An outdated save/delete aborts with `campaignChanged`.
Failed validation writes nothing. The database is separate; its internal object
store name remains `checkpoints` because it reuses the tested storage mechanism.
Stored/imported JSON has no dependency on that internal name.

R04h uses `codec.create`, `make`, `parse` and the four-slot store for the campaign
menu and character-to-ship handoff, retaining the complete creation record.
There is no automatic save. A legacy slot is upgraded in memory on load and written
as version23 in the live app only on explicit save. The raw original slot remains the comparison
record for stale-write protection. Version21 derives old occupancy after historical
checks; old formats cannot inject parked positions or the new field. Detached
interior saves use the connected original ship-section collision region.
Version22 additionally supports other-city outdoor travel and the surface.
Version23 extends that boundary to other-city transactions and flight/warp
controls, retaining historical validation for version22.
See [city walking](city-walking.md) for the source trace and active-position rules.
See [city buildings](city-buildings.md) for door dispatch and bank service scope.
See [building interiors](building-interiors.md) for supported room layouts and adaptations.
