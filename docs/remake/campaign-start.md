# Starting-state assembly — R04f

`createCampaignStart(character, content, seed)` in `remake/js/core/campaign.js`
combines the verified creation primitives into one independent, JSON-serializable
starting object. It includes character attributes, cash, time, inventory,
condition, equipment, systems, orbital angles, city markets/warehouses, colony
counters, and player/ship locations. It does not mutate its inputs or read saves.

This is a creation boundary, not a complete campaign save format or a New Game
UI. It explicitly identifies itself as `sundog-campaign-start`, version1. Character
drafts and ship checkpoint codecs reject it. Remaining ship resource fields,
mode/encounter flags, other location copies and complete campaign validation still
need work before the character editor can safely hand off to persistent play.

## Generation order and two random states

Utility9 calls21,17,18. Procedure21 preserves the name while clearing 512 bytes,
then performs the following random operations:

1. `$0912–$0921`: take four successive random results modulo 256, storing four
   bytes at segment29 word 64. These are a **saved gameplay RNG state**.
2. `$09D2–$09DE`: take the next result modulo 900 as cash on hand. Word 46 is zero
   thousands and word 47 is the remainder. Game8 procedure13 `$0561–$05A6`
   displays these words as credits on hand.
3. `$0A03–$0A31`: initialize the six equipment groups in their traced order.
4. Procedure17 `$0650–$0656` calls12,13,14,16: system balances/positions, orbital
   angles, market templates/recipes, then cryogen placements. Procedure18 derives
   starting locations without further random draws.

Startup7 `$03E9–$03EF` copies saved word 64 into live word 21. The native RNG uses
four bytes beginning at data offset `$28`, corresponding to word 21. Startup7
`$0492–$0498` later copies the evolved live RNG back. Therefore the utility's
final generation state is **not** the starting saved gameplay state.

The constructor preserves this distinction as `gameplayRandomState` and
`creation.finalRandomState`. The former is the little-endian combination of the
four initial low bytes; the latter is the generation tail for reproducibility.
The boundary is before game startup: no claim is made that the first interactive
screen has consumed no additional random draws.

The browser recipe `shipped-defaults-1` accepts an explicit unsigned 32-bit seed,
uses the exported shipped baselines without modifying them, and fixes the first
orbital comparison to 0. That comparison originally reads an uninitialized outer
local. Original creations also rewrite world defaults on disk; browser creations
remain independent. These are explicit adaptation choices, not recovered original
seed/default history. Seeds 0 and `$80000000` are rejected because they collapse
to the degenerate zero stream. Other generation failures propagate without a
hidden replacement seed or partial result. No ambient `Math.random`, clock or
browser storage is used; entropy selection belongs to later UI integration.

## Starting locations

Utility21 `$09B9–$09D1` selects system 1/world 1 and player position (54,110).
Utility18 derives the location block from the newly generated first world and
its first city. The exported `initial-location.json` contains static fields only:

| Named field | Source | Starting value |
| --- | --- | --- |
| System/world | Global word 37 bits 0–3 /4–8 | Jondd, system-01/world-01 |
| City | World word 7 bits 3–8 → global word 37 bits 9–14 | Drahew, city-01 |
| Orbit | World word 6 → global word 36 | Generated angle; radius 20 |
| Surface tile | World byte 10, `%20+10` and `/20+6` → words 38/39 low fields | (10,6) |
| City tile | City word 5 bits 0–5 and 6–10 → words 38/39 high bytes | (12,7) |
| Player anchor | Global words 40/41 | (54,110) |
| Ship anchor | Utility18 `$073D–$0754`, copied to word 72 | (147,115) |

Game21 procedure6 `$00DC–$0101` updates the surface fields modulo 40/24, and its
city-entry path `$032C–$0342` loads the city's coordinates. Utility18 temporarily
changes the anchor to (147,115), copies six words to 72,66,228 and the descriptor,
then restores the player's anchor. Only the player and confirmed ship location
are named in this assembly. The semantics of the other copies are still being
traced; they are not guessed to be independent pod/navigation state.

The generated first orbital angle is linked into both locations. All nested
points are copied independently, so later player movement cannot move the ship.
The reference decoder reads player globals offset 0 and ship offset 72 separately.
Their static fields match the export; the captured angle 73 is evidence, not a
runtime default. The same capture contains 720 credits and saved RNG `$3EF2D937`.
Neither is hard-coded into the constructor or claimed as a recovered seed replay.

## Validation

Required Chrome 154.0.8037.57 passes 56 browser test groups, including four new
groups. Native sim65 vectors check the first five generated values; composition
checks then verify equipment → systems → orbits → economy and the final RNG.
One hundred campaign seeds replay identically despite intervening creations.
Tests cover named-location comparison, acceptance of unspent character points,
serialization, copy isolation, rejected inputs and separation from saved formats.

Ten exporter tests pass; 122 artifacts, 584 source strings and original input hashes
verify. See the [machine-readable receipt](campaign-start-validation.json).
No UI change, new Apple II play observation or complete campaign replay is claimed.

```sh
python3 tools/remake/campaign_reference.py
python3 tools/remake/test_exports.py
python3 tools/remake/export_assets.py --check
python3 tools/remake/source_index.py --check
python3 tools/verify_inputs.py
```

Serve `remake/` and open `/tests/` in the configured Chrome. Next: trace remaining
ship resources/modes and location copies, then define the campaign save boundary
and connect character creation and the ship runtime.
