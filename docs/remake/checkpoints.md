# Ship walkthrough checkpoints — R04c

Four explicit browser-local slots preserve the implemented landed-ship session.
They use an independent `sundog-ship-checkpoints` IndexedDB database and the
`sundog-ship-checkpoint` JSON envelope. Character drafts and the planned
`sundog-remake` campaign format remain separate. Four slots follow utility
procedure8's slot count; browser storage, file format and safe saving boundaries
are deliberate adaptations, not an original disk-save implementation.

Choose **Saves** while awake. Opening the panel pauses time and movement. Save,
load and delete target one slot; replacement and deletion require confirmation.
Loading/importing asks before replacing live progress and resumes paused. Close
the panel and choose Resume. Nothing loads automatically on opening the app.
After death, Saves allows loading/importing but disables saving/exporting the
terminal state. Sleep must finish or be interrupted before saving.

JSON export downloads the current live snapshot, not the selected stored slot.
Import replaces only live state; save explicitly to retain it in a browser slot.
Import/export remain available when IndexedDB is unavailable. Local slots belong
to the browser profile and origin; export a copy before clearing site data or
moving to another host. There is no original disk-save compatibility.

## Version 1 boundary

Envelope fields: `format`, `version:1`, `content:landed-ship-1`, slot0–3,
ISO `savedAt`, and `state`. The state contains:

- Integer player coordinates inside the spawn-connected ship collision region.
- Four carried, twenty locker and twenty stores bytes. Preserve all charge bits;
  reject nonempty bytes whose low-five-bit type is below7.
- Vigor, rest, health and nourishment bytes, each0–255; vigor/rest must be nonzero.
- Whole elapsed game minutes, a nonnegative safe integer with1440 headroom.

The codec validates the complete snapshot before any live-state mutation. Future
versions, other formats/content, oversized files (16KiB), malformed inventories,
invalid conditions and unreachable positions are rejected. Unknown extra fields
are discarded; no imported DOM or display labels are retained. Position validity
uses the shipped collision mask, not just the rectangular screen bounds.

Saving is restricted to an awake, living, paused boundary. Held keys, pointer
capture, selection, menu state, animation handles, fractional elapsed time and
sleep phases are transient. Load clears them and creates a paused awake survival
state with the saved whole minutes. This can discard less than one real second
of progress; it cannot skip the next hourly transition. Sleep always initializes
its own phases when entered. No hidden-page catch-up is introduced.

Each save/delete compares the displayed raw record with the current record inside
one IndexedDB write transaction. A stale tab aborts the change, refreshes its list
and reports the conflict. Loading also checks for a changed displayed record.
Unreadable records disable Load and remain stored until explicit replace/delete.
Storage failures keep the live walkthrough usable and offer a retry. The previous
valid slot survives invalid input, cancelled confirmation and aborted transactions.

This step does not initialize worlds/equipment, link character drafts into a
campaign, or save unimplemented ship systems. Those evidence and implementation
gates remain in R04/R05. No new original-game emulator observation is claimed.
