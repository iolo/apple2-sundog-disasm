# Campaign save boundary — R04g

`campaignSaveCodec(content, geometry)` implements `sundog-campaign` version1,
scope `landed-ship-1`. `openCampaignStore` gives four indexed slots in the separate
`sundog-campaigns` database. This module is tested but not yet exposed in the UI.
Character drafts and standalone ship checkpoints retain their existing formats.

The state has two explicit parts:

- `start`: the immutable creation record, including recipe/seed, both RNG states,
  character, initial inventory/condition, equipment, resources, generated systems,
  markets/cargo, colony counters and all four starting locations.
- `ship`: active player position, inventory, condition and whole elapsed minutes
  for the currently supported ship walking, inventory and survival rules.

The initial inventory/location in `start` records where this campaign began.
Current play uses `ship`. It must never read stale initial values as live progress.
Economy, ship resources and navigation are not yet mutable in this scope; allowing
those actions later requires an explicit schema and transition update.

## Validation and transactions

The codec owns a copy of the supplied shipped content. It regenerates the creation
record using recipe2 and the saved character/seed, then compares every field,
independent of JSON object key order. Changed balances, cargo, resource levels,
RNG states, locations, old recipes and extra fields fail validation. Validation
returns newly owned objects; it never silently repairs unsupported progress.

Active ship validation reuses the tested reachable-position, inventory-capacity,
item-byte and condition checks from the checkpoint codec. Only living, awake
snapshots are supported; sleep/input/modal phases are transient and are not part
of this format. The later UI integration must prohibit saving during sleep and
restore paused with held input cleared, as the walkthrough checkpoint UI does.

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

No automatic save, migration, campaign menu, entropy selection or character-to-ship
handoff is added here. Next integration work can use `codec.create`, `make`, `parse`
and the four-slot store without dropping the generated campaign's identity/state.
Other scenes and machinery remain outside this version's supported scope.
