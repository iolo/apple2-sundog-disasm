# Ordinary city composition (R06a)

The preview now offers **City view** for the 57 named ordinary cities. This is
the source-derived background layer needed for later ship exits and city walking.
It is an inspector: moving its camera does not move the player or alter a campaign.
Stored layouts and manual bank selection remain available for all 60 records.

## Source rules

Game21 procedure26, `src/pcode/game_21.s`:

| Offsets | Rule implemented |
| --- | --- |
| `$0EB8–$0ED2`, `$0F3C–$0F41` | One-based city identity selects the stored record; the existing exporter has already decoded its packed payload. |
| `$0F0B–$0F3A`, `$0FCA–$0FCF` | Save the two-word gameplay RNG, install words `3*city+39` and `11*city+51`, then restore it after composition. The browser uses a private RNG instead. |
| `$0F43–$0F4B` | Clear the full 960-byte / 40×24 map to tile0. |
| `$0F4D–$0FC8` | Iterate x=10..29 outside y=6..17; each stored nibble becomes `nibble + 16*(random mod 2)`. Every one of the 240 cells consumes a draw, including empty nibbles. |
| `$0FD1–$0FEC` | First bank is `(systemId-1) mod 4`; second is `(worldId-1) mod 4`. |

Procedure3 `$0056–$006C` loads those banks into `$4000` and `$4800`; procedure4
reads four blocks for each. Each bank has sixteen 128-byte tiles, so runtime
indices0..15 select the first bank and16..31 the second. A variant can select the
same artwork where the two bank numbers coincide; do not synthesize different art.
The ordinary-city membership comes from the existing utility-derived system/world
and city/world tables, rather than inferring it from record order.

Game21 procedure9 `$02B7–$02C4` requests six rows of 32-pixel tiles.
Library23 native procedure3 `$00E8–$0137` fetches ten columns, wraps x at40,
and uses `tile*128 + $4000` as the artwork address. `$0182–$0194` advances
the map by40 bytes between rows, without a vertical wrap. The inspector therefore
uses a 10×6 window with horizontal wrapping and clamps its top row to0..18.
Its initial center (20,12) and four camera buttons are browser presentation choices,
not source-derived spawn points. Tile inspection reports full-map coordinates
one-based, while core coordinates and bank numbers are zero-based.

## Ownership and scope

`core/city-map.js` returns fresh map rows and bank arrays. It takes no gameplay RNG
or campaign object. Loading assets prepares the57 ordinary backgrounds once.
Camera, selected tile, raw bank and view mode belong only to the existing preview
state. City changes recenter and clear selection; language/viewport changes retain
the camera and selection. Unsupported records58–60 show their stored layouts and
a disabled city-view button, without discarding the preferred view mode.

This implements the ordinary, unclipped background path only. Colony60 uses
procedure17's progress-dependent clipping, and flags can change cache/entry
behavior. Ship/pod overlays are drawn later by procedures7/8/9. Neither those
overlays nor collision, NPCs, doors, city travel, airlock transitions, world-map
variants or colony growth are implemented here. Campaign saves remain version2,
`landed-engineering-1`, with only reachable ship-interior player positions.

## Validation

`tools/remake/city_map_reference.py` independently reads the packed payload bytes
and utility membership words, emulates the RNG with bytewise carry, and hashes all
960 cells for each of57 maps. This is a source translation, **not a live emulator
capture**. Browser tests compare those hashes and banks, verify all original
nibbles and zero margins, reject unsupported records, check ownership and camera
boundaries, and run existing rule/localization/storage tests.

`tools/remake/city_map_smoke.js` exercises normal UI actions across all57 city views,
the three stored-only records, camera/selection behavior, keyboard, touch and both
languages at four viewport sizes. See `city-map-validation.md` for the receipt.

The next R06 step is to trace city collision against the composed pixels and
ship/pod overlays, establish the airlock's exterior placement and reentry path,
then introduce active scene/location state with a validated save migration.
