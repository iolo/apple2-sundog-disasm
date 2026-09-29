# State boundaries — R01a / R04a / R05a / R05b / R05c / R05d / R04c / R04d

The campaign schema below is a design contract. Defaults are intentionally not
instantiated until the new-game evidence gate passes. A content viewer is not a
new game and uses separate ephemeral state.

| Group | Fields / rules |
| --- | --- |
| Save envelope | `format: sundog-remake`, integer `version`, timestamp, slot 0–3, content revision, complete game state |
| Player | Unicode name; strength/intelligence/dexterity/charisma/luck; health, vigor, rest, nourishment; four encoded carried item bytes |
| Location | Stable system/planet/city IDs, scene, local coordinates, active transport; original record mappings in content manifest |
| Ship and pod | Independent position, equipment slots/condition, hull, shields, fuel, charge, cargo and lockers |
| Economy | Cash, per-system bank balances, per-city stock/prices/warehouses; integer quantities and money; atomic transactions |
| Campaign | Discovered colony, current/completed phases, outstanding goods/cryogens, delivery ledger, encounter flags |
| Simulation | Tick/time, serializable RNG state, resumable events; no wall-clock catch-up when hidden |

Only IDs and state values belong in saves. Exclude translated labels, DOM,
Canvas, Image, AudioContext, input capture and loaded assets. A schema migration
validates its output before replacing a saved slot. Unknown future versions are
rejected without destroying the last valid save.

Preview state consists solely of selected view (`ship`, `cities`, `worlds`),
record index, palette/bank and optional selected point. Locale is a preference.
This deliberately has no money, player statistics, fabricated quest progress,
or gameplay persistence.

R04a adds an independent character editor. Its four IndexedDB slots use the
`sundog-character-draft` format, never the campaign envelope above. Drafts hold
only a validated Unicode name and five attributes; remaining points are derived.
See `character-creation.md`. They are editable preparation, not game sessions.

R05a adds separate ephemeral walkthrough state: player position, held input,
pointer target, pause flag and a bounded movement accumulator. Its source-backed
spawn is (54,110). It retains position while reopening the screen but resets on
reload and advances no campaign clock or survival state.
Input capture and animation handles remain in the UI, outside persisted data.

R05b adds four carried bytes and twenty bytes each for locker and stores. Low
five bits identify an item; upper bits are preserved across every transfer.
Initialization uses only named deterministic fields verified against the clean
capture. Container access is derived from the player's interaction region.
Selection is transient UI state; selecting/cancelling does not remove an item.
Transfers commit both slots atomically. This inventory remains local to the
walkthrough and resets on reload, independently of character drafts.

R05c adds four condition bytes: vigor, rest, health and nourishment, each 0–255.
The clean fixture initializes all four to 255. Food and rapidheal atomically
consume one carried slot and add 80 to nourishment or health, capped at 255.
Use at full condition still consumes the item. Selection and render state cannot
repeat consumption after the slot becomes empty. Condition remains local to the
walkthrough alongside inventory; neither is serialized into character drafts.
No hunger, fatigue, sleep, elapsed-time effects or campaign persistence are added.
See `condition.md` for source boundaries and the limited emulator observation.

R05d adds a separate survival clock and sleep state: elapsed game minutes,
bounded fractional time, sleep/forced/dead flags and sleep/ship iteration phases.
Normal visible play advances time even while idle. Inventory/help/explicit pause
and lost visibility/focus stop time; sleep explicitly advances its own cadence.
Hourly changes use the source drain/recovery/vigor rules. Exhaustion forces sleep;
zero vigor freezes the walkthrough. Explicit restart restores its fixture.
The clock begins at day0 00:00, matching the independent clean capture. All of
this state remains ephemeral; character draft schemas are unchanged. Temporary
attribute recovery, ship machinery and outdoor events are not yet instantiated.
See `survival.md` for rates, source offsets and remaining campaign boundaries.

R04c supersedes the earlier reload-only lifetime with explicit ship checkpoints.
The independent `sundog-ship-checkpoint` version1 format persists position, all
44 inventory bytes, four condition bytes and whole elapsed minutes. Only awake,
living snapshots are accepted. Load is atomic, clears transient input/time phases,
and resumes paused. No automatic restore occurs on reload. The four indexed slots
use transactional stale-record checks before replacement/deletion. Invalid imports
leave live and stored states unchanged. See `checkpoints.md` for validation and
scope; this does not instantiate the campaign schema above.

R04d adds pure initialization primitives outside all current saved schemas.
Equipment has six named groups, four component rows per group, requirements, unit/total
performance and special requirements. Navigation initialization produces 12
system coordinate triples and integer bank balances plus 18 orbital angles.
Static names, system membership and orbital radii are separate content. A private
source-derived RNG exposes its unsigned 32-bit state for exact continuation.
No function constructs a complete campaign yet; caller-supplied seed/baseline
lifecycle and first orbital comparison boundary remain explicit. See
`initialization.md`. Existing drafts/checkpoints receive no new fields.

R04f now combines the R04d/e primitives in a `sundog-campaign-start` creation
object, with an explicit seed/recipe, saved gameplay RNG, generation tail, cash,
character, inventory/condition and named player/ship locations. It is not a save
codec and remains separate from all live UI and stored schemas. Remaining ship
resources, modes and other location-copy semantics still gate campaign persistence.
See `campaign-start.md` for generation order and browser adaptation choices.

R04g adds resources and separate destination/pod locations, and corrects the
creation order with the utility20 hull draw (recipe2). The new campaign save
format uses scope `landed-ship-1`: immutable `start` creation data plus active `ship`
walking/inventory/condition/time state. Four slots are transactional and isolated
from other formats. Unsupported world/resource progress is rejected, not dropped.
See `campaign-saves.md`.

R04h connects creation and campaign slots to the live ship. The runtime owns the
creation record separately from active position/inventory/condition/time. Campaign
and preview sessions remain independent; switching/closing pauses and clears held
input. Saves validate before replacement and restore paused. Seed selection is
explicit or drawn from browser entropy once per creation attempt. There is no
autosave; sleep/death cannot be persisted. See `campaign-ui.md`.

Visual thesis: a dark shipboard display, ivory vector silhouettes and one amber
selection accent, preserving SunDog's spare Apple II composition.

R05e exposes owned inspection copies of the immutable campaign equipment at
source-mapped bays. Component selection and frame cycling are transient UI state;
no equipment/resource mutation or new save field is introduced. Inspection pauses
and clears movement; closing restores focus and stays paused. Future repairs must
introduce active equipment and validate it independently of the creation record.

R05f adds active equipment to campaign version2 (`landed-engineering-1`). Atomic
exchanges conserve carried/installed bytes and recompute performance/availability.
The legacy field `spares` is corrected to mean immutable socket requirements.
Version1 validates before migration; its raw slot remains the transaction's
comparison record. Selection/move mode stays transient. Power, charges and other
resources remain at creation defaults; encoded damage repair is not supported.

R06a adds owned, derived ordinary-city backgrounds outside campaign state. The
preview alone owns its stored/composed mode, camera and selected tile. Composition
uses a private source-derived seed and leaves campaign RNG untouched. The map
cache contains57 named ordinary cities; records58–60 retain stored-only inspection.
No city player location, airlock transition or new save field is introduced.
See `city-maps.md`.

R06b introduces active `travel:{scene,cityPosition}` in campaign version3,
`landed-city-1`. City positions use full-map pixels and must be reachable from the
initial foot exit. The legacy `ship` block retains active inventory/condition/time;
its interior position is the fixed reentry anchor while outside. Version1/2 gain
an interior travel state after validation. Geometry and camera are derived, not
serialized. Preview/campaign sessions stay separate. Source-derived city collision
uses glyph11 and pattern9, with the landed attached-pod ship overlay. See
`city-walking.md` for boundaries and legacy location-field naming.

R06c extends `travel.scene` with `bank` in version4 (`landed-bank-1`). Its city
position is the retained street anchor and must match a reachable foot-bank door.
The bank dialog is derived from that explicit scene, so save/reload preserves a
visit. Version3 validates only ship/city before migration; older versions retain
their existing upgrades. Inquiry has no financial or RNG mutation, and pauses
time. All balances remain immutable creation data until R07 adds active accounts.
See `city-buildings.md`.

Content plan: a SunDog title led by character creation, then resume/saved games
and a secondary preview entry; the ship as the main workspace; compact view
navigation; contextual selection details and help.

Interaction thesis: a short display entrance, a restrained scene transition,
and a clear selection reticle. Respect reduced motion; no scroll effects in a
viewport-fitted game. Use native CSS/Canvas, not animation dependencies.
