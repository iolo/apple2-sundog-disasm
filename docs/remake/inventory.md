# Carried items and ship storage — R05b

This checkpoint implements inventory transfers inside the ship walkthrough.
It does not initialize a campaign or advance survival/time. Only the named,
deterministic inventory fields below are initialized; generated world and
engineering records are not copied from an existing save.

## Source mapping

Offsets are relative to their p-code segment. Global word numbers refer to
data segment29; save offsets are relative to the 512-byte globals snapshot,
which starts at word36.

| Field or rule | Source | Interpretation |
| --- | --- | --- |
| Carried items | Library27 procedure13 `$05D5–$05EF`, procedure15 `$0428–$0436`; procedure7 `$0193–$01AA` | Four bytes at word62, save offsets52–55. No stacking or weight-derived extra slots. |
| Locker | Game14 procedure3 `$0238–$0278`; procedure4 `$02B0–$0330` | Interaction5 selects record6. Twenty item slots, bytes0–19 of a 28-byte record at word90. Save offsets276–295. |
| Stores | Same source, interaction6 selects record7 | Twenty item slots at save offsets304–323. Cargo interaction7 and engineering interactions8–13 have other layouts and remain separate. |
| Empty initialization | Utility21 `$08F2–$08FA` | Clear the globals snapshot before populating named fields. Four carried bytes start empty. |
| Locker contents | Utility20 `$085C–$0879` | Slots15–19 contain shunt23; all earlier slots remain empty. Record byte24 is randomized separately and is not an item slot. |
| Store contents | Utility20 `$088B–$08D6` | Slots0–4 rapidheal10; slots5–9 food byte 8; slot10 shield byte 235; slot11 stinger byte 12; slots12–19 empty. |
| Encoded item | Library27 procedure10 `$0276–$02BA` | Low five bits select the item name. Types11/13 display the upper three bits as a number when nonzero. Shield235 is type11 with value7. |
| Storage write | Game14 procedure8 `$0598–$060A` | Locker/stores retain the complete item byte; engineering sockets use a separate type-masking/fit path. |
| Pick/place | Game14 procedure12 `$0796–$08C8`; library27 procedure7 `$0156–$01D6` | Replace the destination with the held byte, return its previous byte, update carried bytes when applicable; retain a return path for the held item. |
| Storage access | Game15 procedure14, Game14 procedure3 | Interaction5 is locker, interaction6 is stores. Both regions are reachable from the source spawn using the existing collision rule. Browser tests use (83,110) and (54,86). |
| Icons | Library27 procedures3/4 `$0044–$00B5` | Four bank1 glyphs: base=`2*type + (type>=16 ? 32 : 0)`; top pair base/base+1, bottom pair base+32/base+33. Each glyph is 7×8 with reversed stored rows and low seven bits visible. |

`tools/remake/export_assets.py` exports 24 composed item SVGs and the small
`ship-inventory.json` fixture. The exporter tests independently compare carried,
locker and store defaults with `docs/reference/remake-clean-character.json`.
All three ranges match the observed fresh-character bytes exactly. English names
come from the play-side item table; Korean labels are remake translations.
The item table's unrelated value byte is not interpreted as a price or charge.

## Original-game observation

`docs/reference/remake-inventory-transfer.json` records an owned MAME 0.285
Apple IIe session on disposable copies. Walking to (54,86) and releasing opened
Ship's Stores. Picking store slot 5 changed its byte 8 to 0; placing into carried
slot 0 changed that byte 0 to 8. Other captured slots remained unchanged, including
the existing stinger byte 12 and shield byte 235. Before/after screenshots are checked in.
This is an existing play session, separate from the clean initialization capture.
The browser smoke also reaches both storage locations through ordinary controls.

The first mount script referenced an incorrect device tag; device enumeration
identified `:sl6:diskiing:0:525`, and play continued after mounting the copy there.
The interactive capture is not presented as a frame-replayable boot sequence.
Original disk/manual hashes still match their baseline, and the owned emulator
was stopped. The observed food transfer validates the captured byte transition;
other transfer cases use source-derived tests and browser checks.

## Browser interaction and limits

The inventory button opens four carried slots anywhere. At the locker or stores,
it also exposes that container's twenty slots. The rules reject remote container
access. Walk above the starting position to reach stores; walk right to reach
the locker. Enter or I opens inventory while the ship has keyboard focus.

Select an item, then a destination. An occupied destination swaps both complete
bytes atomically. This is a deliberate browser adaptation of the original held
item cursor: there is no removed-but-unplaced item. Cancel, Escape, closing the
panel and switching language cannot strand or duplicate an item. Escape cancels
a selection before closing the panel. Inventory pauses walking; Resume continues.

The twenty visible storage slots are kept distinct from the remaining eight
bytes in each source record. R05c adds food/rapidheal use from carried slots;
see `condition.md`. Engineering sockets, other consumables and discard remain
unimplemented.
Inventory persists while leaving/reopening the walkthrough and changing locale,
but reload restores the initial fixture. Return to start moves the player only.
Character drafts and future campaign saves remain separate.

Visual composition: the existing dark shipboard surface and ivory original
item silhouettes, with amber selection. Four carried slots sit beside the
reachable container; selected-item guidance occupies a single footer. Selection
changes immediately and keyboard focus remains inside the open inventory.
