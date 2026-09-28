# Character-to-ship flow — R04h

The title now offers Create a character and Saved games. After allocating
attributes, Board ship opens a short boarding form. Unspent points require
confirmation. Character drafts remain available independently of games.

An optional decimal world seed replays the `shipped-defaults-2` creation recipe.
Accepted values are 1–4294967295 excluding 2147483648; the excluded value and zero
are degenerate native RNG states. Blank input uses browser crypto entropy,
rejecting those states with a bounded retry. Invalid input or failed generation
leaves the current session intact. Replacing a live campaign requires confirmation.
The resulting seed appears aboard the ship and in exported creation data.

Boarding creates the complete validated R04g creation record and enters the
landed ship paused at its initial position. Resume enables the existing walking,
inventory, condition and survival rules. The title's Resume preserves the live
session while moving between screens; reloading the page requires an explicit
load. The preview walkthrough retains its own session and checkpoint database.

## Saves and recovery

Saves aboard the ship provides four campaign slots and JSON import/export.
Title Saved games also permits loading/importing without first creating a
character. Closing that panel without a campaign returns to the title.
Slot summaries show the character and elapsed day. User names are escaped.

Opening saves pauses play. Loading/importing validates the entire campaign before
replacement, clears held input and resumes paused. Import replaces live state;
writing a slot remains explicit. There is no autosave. Storage failure disables
slot writes but retains import/export and retry. Existing transactional conflict
protection prevents stale tabs from overwriting newer records.

Sleeping sessions cannot open saves. Death offers Back and Saves; it cannot be
saved/exported or reset through the preview's restart control. Loading a living
save restores the paused session. The preview reset is absent throughout campaign
play. English and Korean cover the new flow and its validation messages.

## Supported scope

The save is now `sundog-campaign` version2, scope `landed-engineering-1`:
immutable creation record plus active ship position, inventory, condition,
whole elapsed minutes and equipment. R05f adds [component exchange](component-exchange.md)
at the six engineering bays and upgrades valid version1 saves on load. Generated
resources, markets and navigation remain retained. Power controls, exits, travel,
trade, encounters and colony progression require further rules and an explicit
state/schema extension. No new original-emulator behavior observation is claimed.

See [save validation](campaign-saves.md), [creation recipe](campaign-start.md)
and [browser evidence](campaign-ui-validation.md).
