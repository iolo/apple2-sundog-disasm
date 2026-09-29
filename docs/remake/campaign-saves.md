# Campaign save boundary — R04g / R05f / R06b / R06c / R06d / R06e / R06f

`campaignSaveCodec(content, geometry, cityGeometry)` writes `sundog-campaign`
version7, scope `landed-traffic-1`, and validates/upgrades version1 `landed-ship-1`,
version2 `landed-engineering-1`, version3 `landed-city-1`, version4 `landed-bank-1` and version5 `landed-rooms-1` and version6 `landed-occupants-1`.
`openCampaignStore` gives four indexed slots in the separate
`sundog-campaigns` database. R04h exposes this through title and ship Saved games;
see [character-to-ship flow](campaign-ui.md).
Character drafts and standalone ship checkpoints retain their existing formats.

The state has five explicit parts:

- `start`: the immutable creation record, including recipe/seed, both RNG states,
  character, initial inventory/condition, equipment, resources, generated systems,
  markets/cargo, colony counters and all four starting locations.
- `ship`: active player position, inventory, condition and whole elapsed minutes
  for the currently supported ship walking, inventory and survival rules.
- `equipment`: active installed components, validated performance and special-part
  availability. Group/socket requirements are immutable metadata. The legacy
  field name `spares` means socket requirements, not removable inventory.
- `travel`: active scene (`ship`, `city`, `bank` or `room`) and full-map city player pixels.
  `cityPosition` is null inside; outside it must be reachable from the airlock.
  While outside, `ship.position` is the fixed interior reentry anchor `(54,118)`.
  At a bank the city position must also match a source foot-bank door footprint.
  In a room, the city position retains the entry door; a third field,
  `roomPosition`, must be reachable from the derived layout's interior spawn.
  It is forbidden in other scenes. Only city tile types9/10 are currently enabled.

- `encounters`: unsigned gameplay `randomState`, nullable `roomSeed` and nullable
  `roomState` (actors, active visitor and waiting count). Entry derives occupants;
  traffic advances their state and RNG. Exit clears room seed/state. Outside rooms
  both must be null. Reload validates native actor words, supported actions,
  reachable positions, counter targets, queue references and visible overlap.

The initial inventory/location in `start` records where this campaign began.
Current play uses `ship`, `equipment`, `travel` and `encounters`. It must never read stale initial values as live progress.
Economy, ship resources and navigation are not yet mutable in this scope; allowing
those actions later requires an explicit schema and transition update.

## Validation and transactions

The codec owns a copy of the supplied shipped content. It regenerates the creation
record using recipe2 and the saved character/seed, then compares every field,
independent of JSON object key order. Changed balances, cargo, resource levels,
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
[room occupants](room-occupants.md) for the seed contract and unresolved fallback.
See [component exchange](component-exchange.md) for fit rules and scope limits.

Active ship validation reuses the tested reachable-position, inventory-capacity,
item-byte and condition checks from the checkpoint codec. Only living, awake
snapshots are supported; sleep/input/inspection phases are transient and are not part
of this format. The UI prohibits saving during sleep and restores paused with
held input cleared, as the walkthrough checkpoint UI does.
The bank service is an explicit scene and is preserved by saves.

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
as version7 only on explicit save. The raw original slot remains the comparison
record for stale-write protection. NPC dialogue, bank transactions, other buildings/cities, encoded component repair and
power/charging controls remain outside this version's supported scope.
See [city walking](city-walking.md) for the source trace and active-position rules.
See [city buildings](city-buildings.md) for door dispatch and bank service scope.
See [building interiors](building-interiors.md) for supported room layouts and adaptations.
