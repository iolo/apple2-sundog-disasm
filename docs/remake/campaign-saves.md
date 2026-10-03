# Campaign save boundary — through R08b

`campaignSaveCodec(content, geometry, cityGeometry)` writes `sundog-campaign`
version18, scope `landed-depot-1`, and validates/upgrades version1 `landed-ship-1`,
version2 `landed-engineering-1`, version3 `landed-city-1`, version4 `landed-bank-1`,
version5 `landed-rooms-1`, version6 `landed-occupants-1`, version7 `landed-traffic-1`
version8 `landed-dialogue-1`, version9 `landed-lodging-1`, version10 `landed-taverns-1`
version11 `landed-services-1`, version12 `landed-banking-1`, version13 `landed-exchange-1`, version14 `landed-purchases-1`, version15 `landed-personal-trade-1`, version16 `landed-local-cargo-1`, and version17 `landed-trader-matching-1`.
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
Only version18 accepts world-origin auxiliary fuel cargo and detached pod depot
visits. See [depot services](depot-services.md) for source rules and constraints.

The state has nine explicit parts:

- `resources`: current hull/fuel and inactive warp/shield/gun/engine fields.
  Depot purchases change hull/fuel without rewriting the immutable `start` record.
  This scope permits hull from its initial value through16, and fuel multiples
  of16 or255; power/charge remain off/zero until later machinery integration.

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
- `pod`: active attachment, nullable exterior position, directional glyph heading
  and two cargo slots. Detached position equals the active city position and is
  allowed only in city/exchange/depot scenes. Attached pods use null position/heading16.
- `travel`: active scene (`ship`, `city`, `bank`, `room`, `transstation`, `depot`
  or `exchange`) and full-map city player pixels.
  `cityPosition` is null inside; outside it must be reachable from the airlock.
  While outside, `ship.position` is the fixed interior reentry anchor `(54,118)`.
  At a bank the city position must also match a source foot-bank door footprint.
  Other service scenes require their matching reachable foot door; detached
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
Other cities, ship resources and navigation are not yet mutable; allowing
those actions later requires an explicit schema and transition update.

## Validation and transactions

The codec owns a copy of the supplied shipped content. It regenerates the creation
record using recipe2 and the saved character/seed, then compares every field,
independent of JSON object key order. Changed creation balances, cargo, resource levels,
creation RNG states, locations, old recipes and extra fields fail validation. Validation
returns newly owned objects; it never silently repairs unsupported progress.

Active equipment accepts empty/destroyed sockets or compatible plain components.
Validation recomputes unit output, total output and special availability, rejecting
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
as version18 only on explicit save. The raw original slot remains the comparison
record for stale-write protection. Other cities, unattended pod parking, encoded component repair and
power/charging controls remain outside this version's supported scope.
See [city walking](city-walking.md) for the source trace and active-position rules.
See [city buildings](city-buildings.md) for door dispatch and bank service scope.
See [building interiors](building-interiors.md) for supported room layouts and adaptations.
