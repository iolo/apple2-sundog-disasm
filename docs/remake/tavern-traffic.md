# Tavern seating and visitor traffic

R06o implements the traffic/controller foundation for foot-interior records4–7.
It does **not** enable type8 city entry yet. Tavern dialogue setup, localized
presentation, campaign replay saves and live input still need integration.
Version9 campaign saves continue to accept only the existing room classes.

## Source mapping

All offsets below are segment-relative in `src/pcode/game_18.s`.

| Procedure | Evidence | Browser behavior |
| --- | --- | --- |
| 8, `$01AE–$0316` | Random table/side, six-seat search, glyph24 probe, actions4–9; an opposite player sets trait0 and mood4 | Reserves an available seat with the same two random draws; a failed physical probe tries the other side of that table. Fresh visits have no flag65 item solicitation. |
| 10, `$03B8–$040D` | At-counter visitors seek a seat; others seek the counter; a seated visitor's intermediate Y is target+10 | Retargets between the two areas and releases the previous seat. |
| 11/12, `$041A–$075D` | Departure releases seats; arrival sets seated bit2 and clears the action; opposite-player contacts select21/22 | Retains seat ownership by the stationary actor's coordinates after its action clears, and records the speaker/kind before yielding. |
| 13 | Initial population goes directly to the counter; later arrivals draw a seat preference before counter/seat fallbacks | Existing initial population stays unchanged; subsequent arrivals can reserve seats. |
| 21, `$0F37–$0F70` | NPC kind>15 plus flag49 sets secondary mover123, tries counter retarget on an odd random result, otherwise leaves | `finishTavernContact(...,{dismiss:true})` consumes this draw and resumes the actual speaker independently of mover124. The future dialogue host must supply the interpreted flag49. |
| 24, `$1372–$142C` | Player group/side derives from floor bounds; a stationary opposite actor triggers21 without flag65 | Explicit sit claims the source seat number and yields a kind21 contact. Walking releases it. |
| 28, `$1720–$17E1` | Move124 then123; when neither moves, activity scheduling chooses arrival, departure or retarget | Both movers step and keep their identities through actor-array compaction. The non-tavern eager draw sequence is preserved. |

## Owned state and validation

`initialRoomTraffic(population, room)` adds this object only for records4–7:

```js
tavern: { playerSeat: null, secondary: 0, contact: null }
// playerSeat: null or source action4..9
// contact: null or { actor: 2..count, kind: 21 | 22 }
```

The actors retain their original ten-word representation. Moving seat actions
reserve their final target; stationary seated actors reserve their exact fixture
position. There is no second serialized occupancy table. Validation checks seat
ownership, matching target coordinates, the two distinct mover references,
contact speaker/opposite seat, waiting count, physical reachability and visible
overlap. Shop/lodging state rejects the tavern extension.

Traffic freezes, including RNG, while a contact awaits its host. Sit, stand and
return operations own their output and leave previous state/static geometry
unchanged. JSON round trips preserve future traffic; this is a core-state check,
not a claim that the campaign codec accepts tavern saves yet. NPC mood/greeting
writeback belongs to the pending dialogue controller integration.

## Explicit browser repairs

- Derive reservations from committed actors. Native procedure8 writes the packed
  seat table before procedure13 probes the entry; rejected arrivals must not
  leave phantom reservations. A blocked probe may not flip onto a seat already
  reserved by another moving actor.
- Retargeting an unserved counter visitor decrements the waiting count and
  cancels staff following that visitor, just as departure does. Native procedure5
  clears the at-counter bit without repairing these references.
- A failed retarget clears the selected primary mover immediately, so a saved
  mover always corresponds to an actor with the moving bit set.
- Compaction repairs both mover indices and the counter's followed actor.
- If a primary visitor arrives opposite the player while a prior conversation's
  visitor still moves, returning the new speaker promotes the old secondary to
  the now-free primary slot. Native procedure21 overwrites the secondary index.
  A new player-initiated contact is deferred with `roomTrafficBusy` if both slots
  are already occupied; no actor or random draw is lost. Live controls still need
  to present this short wait during integration.

## Verification

`python3 tools/remake/browser_check.py` passes189 rule groups in required
Chrome154.0.8037.57. Ten seating groups cover exact seed1 arrival draws/targets,
blocked entry, physical side fallback, reservation rejection, queue cancellation,
both contact kinds, frozen RNG, both return paths, simultaneous movement,
compaction, overlapping conversation returns and strict malformed-state checks.
The four layouts each run6,000 unseated-player ticks and6,000 seated-player ticks,
with repeated validation and deterministic JSON replay.

Receipts: `tavern-traffic-rules-validation.json` and
`tavern-traffic-room-regression.json`. No new native emulator capture is claimed.
