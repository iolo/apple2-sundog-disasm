# Initial room occupants — R06e

R06f extends this checkpoint with [live room traffic](room-traffic.md) and
version7 saves. The sections below preserve the original R06e boundary.

Types9/10 now display the initial visitors and the person behind the counter.
They use exported glyph23; the player retains glyph22 and collision glyph24.
Occupants remain stationary in this checkpoint. Wandering, arrivals/departures,
counter tracking, dialogue and transactions are not yet implemented.

## Source trace

`src/pcode/game_18.s` supplies the following behavior:

| Procedure / address | Implemented rule |
| --- | --- |
| 16, layout initialization | Record bytes4–7 supply population bounds in bottom/top/right/left order. Bytes22/23 minus128 give the counter occupant's offset. Byte24, clamped to at least3, is maximum population. Byte25 (zero means128) is retained for later activity. |
| 14 `$0908–$0AB3` | Clear nine ten-word actor slots; draw player1; populate slots2 through the selected count, shrinking count on failed placement and retrying the same slot; position actor0 relative to actor2. |
| 13 `$077A–$0821`, `$08E8–$08FA` | Each attempt consumes flag0 (`random mod8=0`), word8 low byte (`random mod5`), placement draws, then a timer (`2+random mod250`) only on success. Successful initial visitors have bits3/4 and action3 set. |
| 9 `$032A–$03A9` | At most ten candidates; each consumes X then Y. Probe glyph24 at both offsets: X `5*sign((right-left) div4)`, Y `3*sign((bottom-top) div4)`. A clear tenth candidate still fails because the caller tests the exhausted counter. |
| 4 `$0040` / library22 draw mode1 | Draw the visible glyph into the same collision buffer using XOR. Other actors block through glyph23's visible pixels, not a full seven-by-eight rectangle. |
| library22 procedure40 `$06C0–$06CC` | Inclusive range `low+random mod(high-low+1)` consumes a draw even for equal endpoints. |

All supported records have maximum5 and activity divisor32. Types9 use an
offset of `(16,0)`; types10 use `(0,13)`. Visitor slot numbers and the ten native
words are retained in the derived actor records. Unresolved flag/value meanings
are deliberately not assigned dialogue or personality labels. Actor0 uses
visible glyph23, collision glyph3 and word8 value3; visitors use collision24.

The browser builds an owned collision buffer, draws the initial player for
placement tests, draws visitors and actor0, then removes the player glyph for
ordinary player walking. Static room geometry is unchanged. Rendering uses a
separate external SVG and the existing room coordinate scale. The room's fixed
window/local pattern phase remains the R06d adaptation.

## Saved state and entry

Version6, scope `landed-occupants-1`, adds:

```json
{"encounters":{"randomState":123,"roomSeed":null}}
```

`randomState` begins at `start.gameplayRandomState`, not the world-generation
tail. Successful entry stores the pre-entry state in `roomSeed` and advances
`randomState` through all population draws. The layout is derived from the street
door. Exit clears `roomSeed` and keeps the advanced stream; re-entry generates
another population. Ordinary walking, pausing, locale changes and saving do not
consume it in this checkpoint.

Because actors are stationary, a seed regenerates their complete state without
serializing redundant actor arrays. Loading checks the regenerated RNG tail and
player reachability against the occupied collision buffer. Validation caches
only the last population/reachability result. Loading restores paused and draws
the same occupants; it does not advance the saved stream again.

Versions1–5 validate under their old field/scene rules before adding the creation
gameplay RNG and a null room seed. An existing version5 room stays empty until
exit/re-entry, preserving its position even if a new population could overlap it.
Null seeds therefore remain permitted in version6 rooms. Seeds outside rooms
must be null; active RNG states must be unsigned32 integers. No full action-history
replay or anti-cheat guarantee is claimed. Loading never rewrites a slot.

## Empty-population fallback (resolved in R06m)

If all visitors fail placement, procedure14 `$0A43–$0A68` reverses the X range
arguments. For records8–11 this gives a zero modulo divisor; for records12–15
it gives a negative divisor. R06e initially rejected this entry. R06m traced the
native modulo implementation and confirmed the zero-divisor trap and absolute
negative divisor. The browser now normalizes the X endpoints, retains two draws
and creates a staff-only room. See [fixture and fallback evidence](room-fixtures.md)
for this explicit repair and the live save/service/reentry checks.

`tools/remake/room_population_reference.py` independently transcribes source
placement into a Python pixel grid. Its64 vectors cover all eight layouts,
unsigned and degenerate states, placement retries, count reduction and clear
tenth-candidate rejection. These are source-derived reference vectors, **not**
original-emulator captures. See [validation](room-occupants-validation.md).

Next: port procedure12 movement, procedures10/11 target selection, procedure27
counter following and procedure28 activity; then trace interaction/dialogue
dispatch and remaining fixture-dependent building types. R06 remains partial.
