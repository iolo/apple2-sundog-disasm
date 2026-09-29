# Drahew walking and the foot airlock — R06b

A campaign can now leave the landed ship through the foot airlock, walk through
Drahew's connected streets, save/reload outside, and board again. The player must
reach the interior airlock or the exterior boarding area before the action enables.
Enter or the contextual button performs the transition; arrival is paused, with
held input cleared. Inventory, equipment, condition and elapsed time survive it.

## Source trace

| Source | Implemented rule |
| --- | --- |
| Game15 procedure14 | Interior interaction4 is the landed foot airlock. Pod interaction3 remains separate and unavailable. |
| Game15 procedure6 `$0253–$0268` | Select city scene3 and exit direction6. The temporary interior y+20 drawing is not the exterior position. |
| Game21 procedure30 `$143A–$145C` | Exterior ship tile comes from words74/75 low fields, with sub-tile offsets `word76 mod28` and `word77 mod32`. |
| Game21 procedure25 `$0D06–$0D40` | With previous scene2, foot mode and direction6, exterior placement is ship anchor plus `(0,6)`. |
| Game21 procedures7/9 | Draw ship glyph36 and37 in replace mode, then attached-pod glyph16 XORed over the right half. |
| Game21 procedures23/24 | Foot movement in city scene3 uses visible glyph10 and collision glyph11. Both are two pixels square, unlike the interior glyph12/13. |
| Game21 procedure21 `$0B74–$0B9E`, procedure15 `$070F–$0732` | Boarding first requires the same city, nearby tile column and matching tile row, then an inclusive ±4-pixel box around the ship anchor. |
| Game15 procedure11 `$060E–$061B` | Returning on foot places the player at `(54,118)` inside the ship. |

The initial ship is in city map tile `(10,6)` with saved anchor `(147,115)`.
Its full-map pixel anchor is `(10*28+147%28,6*32+115%32)=(287,211)`;
the exit is `(287,217)`. The first source view has top-left tile `(5,3)`, so
the corresponding screen anchor is `(147,121)`. Boarding is initially out of
reach: the six-pixel departure offset exceeds the four-pixel boarding box.
Moving southwest to `(285,215)` gives a clear, reachable boarding position.

The creation schema's legacy `surfacePosition` means the **active map tile**,
including when the active scene is a city. `cityPosition` retains the city's
planet-map coordinates. These names and their recipe2 values remain stable for
save compatibility. Game21 procedure11 `$032C–$0343` restores planet coordinates
when leaving a city; the earlier campaign-start note called it a city-entry path.

## Pixel collision and rendering

The exporter adds all64 city tiles' low-seven-bit rows, the city glyph masks and
the attached exterior ship silhouette in `data/city-walk.json`, plus separate
SVGs for the exterior ship and player. Ship glyph zero bits replace the underlying
terrain as well as its set bits. The collision buffer applies that replacement
before masking; the canvas clears the same rectangle before drawing its SVG.

Game21 `$1537` selects background pattern9. Library22 procedure9 `$13AA–$13CF`
complements pattern-table bytes `$AA` for even HGR byte columns and `$D5` for odd
ones. After discarding phase bits the collision masks are `$55,$2A`. The native
routine ANDs those masks with the screen and shifted glyph11; consequently the
background's odd pixel columns do not obstruct the player. Treating every visible
terrain pixel as a wall would be wrong here. Interior pattern8 remains unchanged.

`city-walk.js` builds a background with ship overlay once from the static landed
start. Walking reuses the diagonal/X/Y attempts and one-pixel retry already traced
in library22. Camera coordinates are separate from full-map player pixels. The
10×6 view follows the current tile; controls use the existing bounded50ms browser
cadence. The larger amber ring and monochrome SVG palette are presentation choices.

## Scope and persistence

This checkpoint supports the initial landed, attached-pod configuration in Drahew.
It bounds player anchors to x280..833 and y199..575, keeping the whole seven-by-eight
sprite within the stored20×12 city rectangle. This is an explicit browser limit
until city-to-surface travel exists, not an original invisible wall claim. Building
entry, NPCs, encounters, shops, pod driving and travel to other cities remain pending.
Personal item use, survival and sleep reuse the existing rules; city encounters
while sleeping have not been implemented.

Campaign version3, scope `landed-city-1`, adds `travel:{scene,cityPosition}`. Inside,
scene is `ship` and cityPosition is null; outside, scene is `city` and the point
contains full-map pixels. The legacy `ship` block still owns active inventory,
condition and time; its position is fixed to `(54,118)` while outside. The initial
creation locations never change. Version1/2 saves validate before acquiring an
interior travel state, and version2 active equipment is preserved.

Imported city positions must belong to the component reachable from the exit.
A compact flood fill includes all one/two-pixel destination requests supported
by movement, including diagonal steps, so validation also admits positions reached
by native-style two-pixel steps. Wall, disconnected, fractional, extra-field and
out-of-scope positions fail before live state replacement. The raw slot remains
the transaction comparison value across migrations; writes remain explicit.

See `city-walk-validation.md` for browser and source-data verification. This
checkpoint adds no original-emulator observation; its rules are source-derived.
