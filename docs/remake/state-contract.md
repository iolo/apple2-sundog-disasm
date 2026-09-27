# State boundaries — R01a

The campaign schema below is a design contract. Defaults are intentionally not
instantiated until the new-game evidence gate passes. A content viewer is not a
new game and uses separate ephemeral state.

| Group | Fields / rules |
| --- | --- |
| Save envelope | `format: sundog-remake`, integer `version`, timestamp, slot 0–3, content revision, complete game state |
| Player | Unicode name; strength/intelligence/dexterity/charisma/luck; health, vigor, rest, nourishment; carried item IDs and quantities |
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

Visual thesis: a dark shipboard display, ivory vector silhouettes and one amber
selection accent, preserving SunDog's spare Apple II composition.

Content plan: a SunDog title with a single preview entry; the ship as the main
workspace; compact view navigation; contextual selection details and help.
Later gameplay replaces the preview workspace as the primary entry.

Interaction thesis: a short display entrance, a restrained scene transition,
and a clear selection reticle. Respect reduced motion; no scroll effects in a
viewport-fitted game. Use native CSS/Canvas, not animation dependencies.
