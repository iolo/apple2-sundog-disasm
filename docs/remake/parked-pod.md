# Parked pod geometry — R08g

`remake/js/core/parked-pod.js` implements the source city geometry for an
unattended pod, foot exit placement and boarding proximity. This is a rule-core
checkpoint. Live campaigns still couple the detached pod and player positions;
parking controls, independent ownership and save migration remain required.

## Source trace

| Source | Rule |
| --- | --- |
| Game21 proc6 `$0141–$0177` | Copy player location into the pod's six-word location only when word45 bit13 is false (driving). Preserve visible/collision headings separately. Walking does not move the pod. |
| Game21 proc8 `$0268–$0290` | In city scene3, on foot, with attachment flag7 false, draw the saved pod location using its saved visible heading. |
| Game21 proc7 `$0218–$022B` | Its false third argument selects XOR drawing. The pod uses one visible glyph; the ship path separately replaces two glyphs and optionally XORs the attached pod. |
| Game21 proc23 `$0C2C–$0C39` | Foot mode uses visible glyph10 and collision glyph11; driving selects direction-dependent pod glyphs. |
| Game21 proc21 `$0B1B–$0B5A` | Boarding requires matching city IDs, foot mode, detached pod and player tile within1 of the saved pod tile in each axis. Player tile uses `(x+3) div28`, `(y−3) div32`. |
| Game21 proc16 `$0783–$07A1` | Convert the saved pod location to viewport coordinates; require absolute X and Y differences at most4. The remainder sets pod mode and copies the pod location back to the player. |
| Game18 proc21 `$0FE0–$0FE5`, proc26 `$150D–$1568` | Room type16 is the pod. Its exit/drive areas select foot/driving through word45 bit13. Scene5 is dispatched through Game18 by Startup proc4 `$011E–$0137`. |
| Game21 proc25 `$0D85–$0E36` | On driving-to-foot return in a city, start scale1/index0. Test X offset `(index div7−3)*scale` and Y offset `(index mod7−3)*scale`. Increment index; at49 reset it and increment scale. Repeat until the foot collision check succeeds. |

Locations refer to segment29: player word36, pod word228, ship word72. Bit13
is transport mode, not pod attachment; attachment remains flag7 at word82.
Offsets above are segment-relative in `src/pcode/game_21.s`, `game_18.s` and
`startup_disk1.s`. No native-emulator observation is claimed.

## Geometry contract

`parkedPodGeometry` takes the existing foot and detached-pod city geometries,
a legal pod position and visible heading14/16/18/20. It copies the background's
outer row list and the eight affected rows, XORs the visible pod pixels and
applies the existing pattern9 masks. It keeps the foot collision glyph. The
ship is drawn without its attached pod. Neither input geometry is mutated.

The proximity predicate checks clear foot placement, tile proximity and both
four-pixel bounds. Scene, transport mode and city identity remain the caller's
responsibility; geometry alone never authorizes boarding a remote pod.

The exit search preserves source order, including its repeated center tests and
expanding scales. It does not select a nearest point or silently teleport to
the road. The native loop is unbounded. In the browser's finite supported city
rectangle, the search returns null once every nonzero candidate must be outside
the map. The eventual campaign transition must reject this case atomically.

At the initial detached position `(296,211)`, the first clear exit is `(293,210)`.
With the ship and parked pod both present, this is a small isolated pocket. It
still meets the boarding bounds, so the player can board again and move the pod.
At street position `(360,215)`, the first exit `(357,212)` permits walking away
and returning. No global-connectivity preference is added to the native search.

## Verification and remaining integration

Four rule groups verify independent visible-glyph vectors, XOR/pattern9 pixels,
all orientations, detached ship drawing, input ownership, invalid parking points,
search order/scale, blocked exits, four-pixel boarding boundaries and collision.
A real city geometry journey walks away from street parking and returns through
actual movement, while separately checking immediate boarding recovery at the
initial departure point. `parked-pod-core-validation.json` records the full297
rule groups. This is browser execution of the rule suite, not a live parking UI
journey.

Next integrate independent pod/player transport state, parked foot collision and
drawing, boarding/disembark controls, foot room/ship visits with an unattended
pod, cargo access checks and versioned saves. Native pod-room exit/drive choices
must be represented or their UI adaptation explicitly documented. Then implement
surface traversal/return and the full [R08 acceptance audit](r08-completion.md).
