# Parked pod ownership and boarding — through R08m

`remake/js/core/parked-pod.js` implements the source city geometry for an
unattended pod, foot exit placement and boarding proximity. R08h connects those
rules to actual parking/boarding, independent player and pod positions, foot
visits with unattended cargo and version21 saves. R08l extends these rules to
independent city/surface domains and live version22 saves; see `surface-travel.md`.

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
| Game15 proc8 `$0315–$0333` | Attachment flag7 selects the full ship image or the detached section four disk blocks later. The browser already exports both image/collision resources. |
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

## Live ownership and deliberate UI adaptation

In a city, **Park / exit** leaves the pod at its current position and chooses
the source-clear foot exit. **Board pod** enables only within the source bounds
at a clear foot position. These buttons directly represent the native pod-room
exit/drive choices; the browser does not add a separate type16 cabin scene here.
Both transitions arrive paused and clear held input. A blocked exit or remote
boarding attempt changes no position, cargo, money, resources, clock or RNG.

`pod.occupied` distinguishes driving from an unattended pod. Attachment still
controls ship artwork, cargo availability aboard and automatic auxiliary fuel.
Walking, rooms, banking and foot depot/exchange visits leave the pod unchanged.
Only an occupied pod at the matching entrance can load warehouse cargo or buy
auxiliary fuel. Returning to the ship on foot does not dock or refuel the ship,
and its inventory no longer presents the remote pod manifest as aboard.

The ship uses the original detached-section artwork and its connected collision
region while the pod is absent. Clear pixels where the pod used to be are outside
that region and cannot become saved interior positions. The exterior uses the
detached ship plus the saved parked glyph. Foot collision uses the same parked
geometry when walking or returning from a room. Boarding the ship on foot still
requires its own source proximity; it cannot summon the parked pod.

Version21 `landed-parking-1` requires an exact boolean `pod.occupied`. Attached
pods must be unoccupied, position-null and heading16. Occupied pods must share
the player's city position in city/exchange/depot scenes. Unoccupied detached
pods retain a reachable city position while the player visits supported foot
scenes, including the ship. Saved exterior foot positions must be clear/reachable
with the parked body present. Reachability includes the source-clear pod exit
and the ship airlock, since boarding/exiting the ship can connect those origins.

Versions1–20 retain their original restrictions before deriving occupancy from
attachment. In particular, a version20 envelope cannot contain occupancy or
independent player/pod positions. Migration preserves active power, pending
equipment failures, all cargo and account state. Listing/loading does not rewrite
old slots; the R08h writer used version21, now upgraded to version22 by R08l.

## Verification and remaining integration

Four rule groups verify independent visible-glyph vectors, XOR/pattern9 pixels,
all orientations, detached ship drawing, input ownership, invalid parking points,
search order/scale, blocked exits, four-pixel boarding boundaries and collision.
A real city geometry journey walks away from street parking and returns through
actual movement, while separately checking immediate boarding recovery at the
initial departure point. `parked-pod-core-validation.json` records the full297
rule groups. That R08g receipt is browser execution of the rule suite, not a live
parking UI journey.

R08h adds five campaign groups for atomic ownership, foot visits, remote cargo
rejection, detached-interior saves, unattended auxiliary fuel, migration and
malformed imports. `parking-live-rules-validation.json` covers302 rule groups.
The live fresh-character journey is in `parking_smoke.js`: ordinary purchases,
loaded parking, reload, foot exchange/ship visits, return boarding and loaded
docking. Its42 UI checks pass, plus61 depot and102 room regressions, in the
`parking-*-validation.json` receipts. The Korean city and English detached-ship
screenshots were visually inspected. R08m adds the60-check final surface run
and74-check combined engineering/service/loaded return journey, with independent
parking and version22 reloads. See the [R08 audit](r08-completion.md).
