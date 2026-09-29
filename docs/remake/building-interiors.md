# Walking interiors — R06d

R06e extends this checkpoint with [initial room occupants](room-occupants.md)
and version6 saves. The sections below record the original R06d boundary.

Campaigns can enter the ordinary scene5 buildings represented by city base
tiles9/10. Their eight layouts come from interaction records8–15. Walk to the
source door, then press Enter or Enter building. Explore using the existing
pointer, touch and keyboard controls; return to the left doorway to leave.
Saves preserve both the interior position and the street return position.

These rooms currently have no occupants or conversations. Their building names
remain generic until the dialogue/service semantics are ported. Type8's extra
fixtures and type11's room/door interactions are excluded. No purchases, NPC
random draws, combat or other service actions are simulated.

## Layout and drawing evidence

`game_18.s` procedure16 loads the sixteen32-byte interaction records already
extracted in `assets/interaction-records/records.bin`. `$0BA8–$0BC5` selects
`4*(type-7)+((activeTileX+activeTileY)%4)`. City variant bit16 does not affect
the type. Record1 is reserved by this consumer for type11 and is not enabled.

Each four-byte bounds group is stored **bottom, top, right, left**. Nested
procedure17 `$0B2C–$0B68` expands them relative to the current window's left/top
minus2. Library22 procedure18 `$01EA–$01FE` writes four-word rectangles in the
same order; procedure19 `$020C–$021D` forwards them to native fill procedure7.
The renderer ports the source draw order:

1. Fill the window content with record byte21's pattern.
2. Fill group4 with byte20's high nibble: floor bounds.
3. Fill group3 with the same pattern: clear the left doorway through the wall.
4. Fill group2 with byte20's low nibble: counter/partition.
5. Groups1/0 are logical bounds and receive no fill.

Native library22 procedure7 `$1251–$1297` selects the alternating byte patterns
from `$164A` for even bytes and `$163E` for odd bytes, preserving inclusive
rectangle edges. The exporter reads these tables from reconstructed source.
Like the other remake SVGs, it retains the seven monochrome pixel bits and
omits the high color-phase bit. Generated art and collision rows share the same
source drawing operations, and the player remains a separate external SVG.

The browser normalizes the movable native window to140×96 pixels. Library22
procedure51 `$0B07–$0B19` supplies content bounds `(2,2)` through `(137,93)`;
record bounds are therefore used directly at origin `(0,0)`. The surrounding
two-pixel region is a solid browser frame/containment guard. Pattern phase is
anchored to this fixed local window instead of the native window's screen-byte
offset. These are explicit presentation adaptations, not an original screen
capture. The eight external files are `room-08.svg` through `room-15.svg`.

## Spawn, collision and exit

Game18 `$0C35–$0C48` assigns spawn x from group0's **right** and y from its
**bottom**, giving `(12,56)` in each enabled room. The other two bounds from
that group are distinct values, not alternative spawn coordinates.
Procedure14 `$0975–$0990` installs visible glyph22 and collision glyph24 for
ordinary rooms; type16 uses the ship glyphs instead. With storage rows reversed:

- Visible22: `[0,0,12,30,30,12,0,0]`.
- Collision24: eight rows of127, the entire7×8 sprite rectangle.

Game18 `$0F16–$0F17` sets background pattern2. Library22 native procedure9
complements its zero bytes, so all seven occupied background bits obstruct this
mask; the city pattern9 filter must not be reused indoors. Sprite high bits are
masked at `$1478–$147C`. Game18 procedure12 `$04BD–$055D` uses two-pixel
movement and a one-pixel retry through the existing native diagonal/X/Y sequence.

Procedure26 `$15E9–$15F6` exits after movement when player x is no greater than
window-left+10. Normalized window-left2 gives `x<=12`. The browser additionally
requires a clear full collision footprint, and uses an explicit Enter/button
activation rather than automatically exiting during movement. This matches its
other contextual doors and allows immediate reversal at the entry point.
Leaving restores the exact street anchor and pauses. Escape retains the existing
campaign Back behavior, allowing a room session to resume from the title.

## Saves and current limits

Campaign version5 scope `landed-rooms-1` adds this travel shape:

```json
{"scene":"room","cityPosition":{"x":311,"y":267},"roomPosition":{"x":40,"y":50}}
```

The street position must be reachable from the ship and match an enabled door.
It derives the layout; no caller-supplied type or layout index is accepted. The
room position must be reachable from that layout's spawn with supported one/two-
pixel movement. Extra keys, walls, disconnected counter areas, fractional points
and foreign scenes fail. `ship.position` remains canonical reentry `(54,118)`;
the other active ship fields and equipment retain their existing validation.
Leaving removes `roomPosition`. Versions1–4 validate under their old scene rules
and upgrade without rewriting slots automatically.

Interior walking advances the shared browser survival clock; inventories expose
carried items only. Bank inquiry still pauses, and preview sessions remain
isolated. Room visits do not consume gameplay RNG while NPC generation is absent.
This is an incremental exploration implementation, not full original room behavior.
NPC creation, persistent NPC state, dynamic collision, dialogue and the two
excluded building types remain the next source work.

See [validation](room-walk-validation.md) for browser and exporter checks.
