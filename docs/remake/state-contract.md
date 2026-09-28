# State boundaries — R01a / R04a / R05a / R05b / R05c / R05d

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

Visual thesis: a dark shipboard display, ivory vector silhouettes and one amber
selection accent, preserving SunDog's spare Apple II composition.

Content plan: a SunDog title with a single preview entry; the ship as the main
workspace; compact view navigation; contextual selection details and help.
Later gameplay replaces the preview workspace as the primary entry.

Interaction thesis: a short display entrance, a restrained scene transition,
and a clear selection reticle. Respect reduced motion; no scroll effects in a
viewport-fitted game. Use native CSS/Canvas, not animation dependencies.
