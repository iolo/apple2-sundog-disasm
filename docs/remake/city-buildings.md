# City doors and bank visits — R06c

The first supported building visit is the bank. Walk to a bank door in Drahew,
then press Enter or use Enter bank. The Uniteller displays carried cash and the
current system account. Leave bank or Escape returns to the exact street anchor,
paused. Saves made at the bank reload into its service screen. Transactions,
other services and walking interiors remain pending.

## Source door dispatch

`game_21.s` procedure21 selects the city tile using `(x+3) div28` and
`(y-3) div32`, adjusted by the viewport's tile origin. Procedure19 at
`$09EA–$0AD9` uses `(x-3) mod28`, `(y+3) mod32` for proximity and the tile's
low nibble for dispatch. Procedure20 `$09BA–$09DD` requires its vehicle
condition and inclusive absolute differences no greater than four on both axes;
then it writes current scene and the dispatch type. These are different coordinate
anchors: using the proximity anchor to select the tile changes boundary behavior.

| Base tile | Vehicle | Proximity x,y | Scene | Type |
| --- | --- | --- | --- | --- |
| 7 | Foot | 14,30 | 3 | 1 |
| 8 | Foot | 1,15 | 5 | 8 |
| 9 | Foot | 2,16 | 5 | 9 |
| 10 | Foot | 1,15 | 5 | 10 |
| 11 | Foot | 1,21 | 5 | 11 |
| 12 | Foot | 6,28 | 6 | 1 |
| 13 | Foot | 1,18 | 6 | 2 |
| 14 | Foot | 1,15 | 6 | 3 |
| 14 | Pod | 2,22 | 6 | 3 |
| 15 | Foot | 2,15 | 6 | 5 |
| 15 | Pod | 14,21 | 6 | 4 |

Tiles8–11 derive their targets from Pascal strings `ABAA` and `OPOU`,
one-based index `tile-7`, minus64. `cityDoorAt` ports all these footprints
without adding actions for unfinished destinations. It returns tile coordinates,
base tile, scene and type; collision/reachability is a caller responsibility.
Variant bit16 changes artwork, not door dispatch. The browser remains foot-only.

The top-level dispatcher is **`startup_disk1.s`**, not `startup_7.s`:
`$0148–$015E` sends scene5 to game18 (or game17 for type255) and scene6 to
game19 for types1–3, game20 otherwise. Game19 procedure1 `$13B0–$13CA`
selects procedure17 for type2. Procedure17 `$0C10–$0C41` uses the current
system record and appends ` Bank` to its name; `$0C49` names the Uniteller.
`$0C6D–$0CB9` displays carried cash from word46 and the system balance copied
from record words6–7. Thus the title is **Jondd Bank**, even though its door is
in Drahew. The browser reads these still-immutable balances from campaign creation.

Game19 `$13D3–$13EC` restores the previous scene after service completion.
The browser preserves the exact street anchor, clears input and returns paused.
Its service screen is a localized HTML dialog over the existing SVG city view;
there is no invented walkable bank artwork. Unlike the native timed service loop,
the browser's read-only inquiry freezes time, consistent with other inspection
panels. Financial actions will need active economy state and source timing rules.

## Persistence

Version4 scope `landed-bank-1` keeps the existing four state parts and adds
`bank` to `travel.scene`. A bank visit holds its street anchor in
`travel.cityPosition`; `ship.position` remains `(54,118)`. The codec requires
both airlock reachability and an actual foot-bank footprint. A reachable street
point alone is insufficient. Extra balance/type/location fields fail validation.
The scene determines the service; no redundant bank identifier is stored.

Versions1/2 retain their validated migration to the ship. Version3 accepts only
its former ship/city scenes and preserves them; it cannot introduce a bank visit
by relabeling an old envelope. Older slots upgrade only on explicit write. See
[campaign saves](campaign-saves.md) for conflict protection and complete limits.

## Walking interiors: next source work

The necessary layout records already exist in `assets/interaction-records/`;
see [interaction bounds](../interaction-records.md). They are **sixteen32-byte
records**, loaded from disk2 block79. Game18 procedure16 `$0B9C–$0BBF` selects
record1 for type11, otherwise `4*(type-7)+((activeTileX+activeTileY)%4)`.
Its five packed bounds groups are consumed in reverse group order by nested
procedure17 `$0B2C–$0B68`, relative to current clip origin minus2.
Styles come from byte20's nibbles and byte21. Procedure16 assigns spawn and
exit-related coordinates at `$0C35–$0C48`; their roles still need tracing through
movement/exit consumers before enabling room walking or saving room positions.

Game18 procedure20 `$0E91–$0EA3` calls the layout builder, then procedure18
for type8 or procedure19 for type11. These add fixtures drawn with native fill
patterns. Procedure14 initializes the player with visible glyph22/collision24
for ordinary interiors; type16 uses ship glyph12/13 instead. NPC creation and
conversation follow in the same module. Porting only the rectangular backdrop
would omit fixture collision, exit gates, NPC state and RNG draws. No completeness
claim for those interiors or original-emulator observation is made here.

Browser results are recorded in [bank visit validation](bank-visit-validation.md).
