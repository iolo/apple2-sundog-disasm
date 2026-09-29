# Room traffic — R06f

The eight type9/10 interiors now run visitor arrivals/departures, movement,
blocked-route recovery and counter following. Player walking and NPC updates
share a50ms browser step, with player movement first. A delayed frame contributes
at most100ms. This is an explicit browser cadence, not measured Apple II timing.
Pause, help, inventory, saved games, sleep and death stop room traffic. Legacy
empty interiors remain empty until re-entry.

## Source boundary

`src/pcode/game_18.s` provides the rules below. Fresh visits clear global
flags64–71 at `$1016–$102F`, including flag65; types9/10 are not taverns, so
procedure8 seating returns immediately. Dialogue is still unavailable, so the
secondary moving actor in local123 stays zero and is not saved. Player requests
for counter service remain part of the pending dialogue work.

| Source | Implemented behavior |
| --- | --- |
| Procedure1 `$17F6–$17FA` | Player update, counter update, visitor activity, in that order. |
| Procedure28 `$172A–$17E1` | Advance an active visitor; otherwise draw against the record's activity divisor. Compare a further eager draw and current count with `2+maximum div2`; add a visitor or select one to leave. Non-tavern departure still consumes the raw boolean draw. |
| Procedure13 `$0823–$08FA` | New visitors consume trait and seating-preference draws, try counter placement, then check the doorway. Enter at `(doorX,doorY+5)`; use an orientation-dependent intermediate target before reaching the counter. |
| Procedure11 `$041A–$048C` | Set action2, plan departure at `(doorX,doorY-5)`, clear counter-waiting status and begin movement. |
| Procedure12 `$0498–$06E3` | Move up to two pixels per axis using library22's diagonal/X/Y collision order. Arrival first switches to the second target; final arrival removes departing actors or queues counter-bound visitors. |
| Procedure12 `$05B0–$0643` | A blocked action3 actor already in counter bounds settles there. Otherwise the low bit of a raw RNG draw selects small random detours or target reassignment/departure. Equal-coordinate detours consume the additional source draws. |
| Procedure27 `$1616–$1711` | Counter staff select the first waiting visitor after an eager mod8 draw, move to the visitor plus the record offset, set that visitor's served flag and assign `64+random mod192`. |
| Procedures5/6/7 | Update moving/counter flags, remove departing glyphs, compact actor slots and repair active indices. |

Glyph24 is the visitor movement mask; glyph3 is the counter occupant's mask.
Visible glyph23 is removed before a movement probe and redrawn afterward.
The player contributes visible glyph22 to NPC collision. Native code repeats a
failed move after hiding its pointer; the browser pointer never enters the
collision buffer, so that retry has the same result and is omitted.

The actor word9 low byte retains its native assigned values. These procedures
do not decrement it; no invented countdown or service transaction is added.
Actor action/flag/value fields remain numeric until dialogue semantics are traced.

## Explicit browser repairs and limits

Native removal repairs mover indices but does not repair the counter occupant's
followed-slot reference when earlier slots compact. The browser preserves the
followed actor's identity when indices shift, and clears that reference when its
target leaves or cancels waiting. Tests exercise this repair. Waiting count must
match waiting visitors; player counter requests are not enabled yet.

Visitors remain on floor reachable from the doorway; counter staff stay in the
separate counter corridor. Actor sprites cannot overlap visibly. Moving masks
can overlap empty sprite margins: the source probes other actors' visible
pixels, not their whole bounding rectangles. Save validation therefore checks
visible overlap in addition to static movement-mask clearance, rather than
rejecting legitimate intermediate states.

Tavern seating, dialogue-triggered pursuit/secondary movement, player service,
transactions and fixture-dependent types8/11 remain gated. The R06e no-visitor
entry fallback remains unresolved and still fails atomically at the street.

## Version7 state

Scope `landed-traffic-1` extends `encounters` with nullable `roomState`:

```json
{
  "randomState": 123,
  "roomSeed": 456,
  "roomState": {"actors": [], "active": 0, "waiting": 0}
}
```

The empty actor array above illustrates the shape only; populated states require
the counter occupant and up to four visitors. Actors retain slot IDs and ten
native words. Visitor slots are contiguous from2, followed by actor0 in the
array. The seed identifies initial population; the active RNG now advances
during traffic and is no longer required to equal the initial-generation tail.
There is no full input-history replay or anti-cheat guarantee.

Validation requires exact fields, integer bounds, supported glyphs/actions/flags,
matching moving/queue/follow references, reachable visitor positions, valid
counter positions/targets and no visible actor/player overlap. Derived collision
rows and partial-frame timing are not saved. Reload preserves actor targets,
movement, waiting and RNG, pauses play and drops partial ticks.

Version6 first passes its original seed/RNG-tail and occupied-position checks,
then receives the exact initial actors with no active mover or waiting visitors.
Versions1–5 keep the existing migration to empty interiors. Null room seeds and
states must agree; both must be null outside rooms. Loading does not rewrite
slots. See [validation](room-traffic-validation.md).

Next: player counter interaction and dialogue dispatch, then tavern/other
fixtures and remaining city behavior. R06 remains partial.
