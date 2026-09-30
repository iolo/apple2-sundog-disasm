# Player counter queue and dialogue return — R06k

`remake/js/core/room-counter.js` connects room traffic to the dialogue runner in
an owned core session. It supports requesting service, cancelling on movement,
staff approach, dialogue dispatch and returning to the same populated room.
This checkpoint exercises the complete core round trip for all eight type9/10
layouts. Live controls, conversation saves and localized presentation are next.

## Source trace

`src/pcode/game_18.s` supplies the room side of the transition:

| Procedure / address | Behavior |
| --- | --- |
| 2 `$0000–$0014` | Inclusive rectangular bounds test. Static collision still restricts where the player can stand. |
| 26 `$14D2–$1509`, 5 `$00D1–$00E1` | Starting movement clears player counter status and stops staff following actor1. |
| 26 `$156E–$157E`, `$15AD–$15CB` | Releasing movement inside the counter rectangle sets the player's waiting flag and increments the queue count. |
| 27 `$1694–$170F` | Eager mod8 draw, then scan waiting actors in slot order, starting with player1. Staff target is actor position plus the layout offset. |
| 27 `$163C–$1690` | Staff arrival at waiting player1 dispatches dialogue. Visitor service instead marks served and draws `64+random mod192`. |
| 23 `$1277–$1307` | Types9/10 select dialogue kinds13/14 and actor0. Workspace receives actor mood, greeting gate, item byte, actor index0 and quantity1. |
| 1 `$17F6–$181D` | Finish the current visitor update after counter dispatch, then leave the room loop. |
| 21 `$0F70–$0F91`, `$0FBA–$0FDC` | Restore the speaker's mood/greeting flag and clear dialogue return flags48–51. |

The counter actor's word8 low byte is mood; bit1 of word7 is the persistent
greeting gate. These fields were fixed at3/false in the visitor-only path. The
new controller retains changes from dialogue and supplies them to subsequent
conversations in that room visit.

## Session and ownership

A controller session contains `room`, `traffic`, `position`, `randomState`,
`service` and nullable `conversation`. Service progresses through `idle`,
`waiting`, `talking` and `served`. Actor1 stays represented by the existing
player position instead of duplicating its sprite in the visitor actor array.

- `createRoomCounter` owns a validated populated room and current player position.
- `requestRoomCounter` queues the player at the counter. Repeated requests are
  idempotent, matching the native button-edge restriction.
- `cancelRoomCounter` cancels waiting and stops staff following the player.
  It preserves staff motion toward an unrelated visitor.
- `moveRoomCounter` cancels service and validates the caller's completed walk
  position before publishing either change. The existing walker still owns
  collision stepping; this operation does not implement a path or teleport UI.
- `tickRoomCounter` uses existing room traffic and RNG, with player priority.
  Staff arrival changes service to `talking`. The current visitor update still
  runs; later ticks freeze while the room has yielded to dialogue.
- `openRoomCounter` combines the actor-derived workspace with explicit current
  campaign context, then starts the actual counter script. A failed setup leaves
  the ready room untouched so the host can retry with valid context.
- `advanceRoomCounter` advances the dialogue. On exit it returns a new served
  room and an owned `outcome`, updates actor0 mood/gate, and clears flags48–51
  in that outcome. The host must commit campaign fields and the room together.

All public transitions preserve caller objects and publish changes only on
success. Positions, queues, actor follow references and RNG are validated at the
controller boundary. These sessions are trusted runtime products, **not** an
accepted external save format; conversation import validation is still pending.

## Queue repair and current limits

The source increments local125 for a player request, but its movement cancellation
and player-dialogue dispatch paths do not subtract that request. The browser
consumes it once on cancellation or dispatch, keeping the count equal to actual
waiting visitors plus a waiting player. This extends the existing queue invariant
and avoids stale counts across repeated requests. Staff target1 is cleared when
the player cancels; unrelated visitor follow references retain their identities.

`validateRoomTraffic` and `tickRoomTraffic` accept an explicit service option for
this controller. Validation then permits counter target1 only for a waiting
player, requires its targets to match player position plus the record offset,
and permits the speaker's mood/gate changes. The existing default path retains
version7's strict visitor-only rules. No campaign codec or live UI call opts into
the new state yet, so existing saved games retain their established contract.

Flag65 enables unported transaction/pursuit behavior in Game18 procedure28. A
return with that flag fails atomically rather than admitting an unsupported room
simulation. Counter transactions, inventory transfers, tavern seating and other
encounter setup remain pending. The no-visitor initial-placement limitation from
R06e also remains; the controller starts from a valid populated room.

## Validation

The required Chrome154.0.8037.57 passes163 rule groups, including11 new counter
groups. The new tests cover all eight layouts across three seeds, checking
geometry and queue invariants after every tick and comparing a serialized clone's
next transition. They cover player priority, inclusive reachable boundary points,
wall rejection, cancellation during staff movement, preservation of visitor
service, dispatch RNG, traffic freezing, both dialogue kinds, information/cancel
round trips, repeated greetings, and atomic setup/return failures.

Seventeen exporter tests, all139 deterministic artifacts and original disk/PDF
hashes pass. Tests are source-derived; no new original-emulator capture or live
conversation UI validation is claimed. Campaign saves remain version7.

Next add durable campaign dialogue fields and versioned session validation, then
English/Korean controls and presentation for these core transitions.
