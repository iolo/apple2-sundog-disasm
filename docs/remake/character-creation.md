# Character creation — R01b / R04a

The first implemented new-game rule is character allocation. It is independent
of world initialization. Editable drafts are explicitly not resumable campaigns.

## Source evidence

All offsets below belong to `src/pcode/utility_disk1.s`.

| Rule | Procedure / offsets | Interpretation |
| --- | --- | --- |
| Initial attributes | 25, `$0C98–$0CD5` | Five bytes at segment-29 word48: 30, 30, 30, 30, 0 |
| Attribute names/order | 30, `$1036–$10B9` | Strength, intelligence, dexterity, charisma, luck |
| Allocation budget | 25, `$0CD7–$0CDA` | 440 points |
| Cost | 27, `$0D8E–$0DB6` | Start cost=1 and remainder=target value−30. While remainder>0, double cost, then subtract 10 if remainder>60, otherwise 20. |
| Minimum | 29, `$0E04` onward | First four attributes cannot fall below 30; luck cannot fall below 0. |
| Increment/refund | 29, `$0E98–$0FC4` | Raise by one for cost(new value). Lower by one for refund cost(old value). Reject negative remaining budget; zero is allowed. |
| Unspent points | 30, `$10E1–$10FE` | Warn when at least eight points remain; this is not a hard requirement to spend everything. |
| Name | 37, `$1442–$1580`; subsequent `p_sas 15` storage | Trim surrounding spaces, reject empty/duplicate names; original name storage allows 15 characters. |

Independent cost checkpoints: target values 1–30 cost 1, 31–50 cost 2,
51–70 cost 4, 71–90 cost 8, 91–100 cost 16, 101–110 cost 32.
Raising strength from 30 to 100 uses exactly 440 points. Raising luck from
0 to 98 uses 438. No valid allocation can exceed 100; the import validator
uses this derived bound before performing any loops. It is not an invented
stat cap for future gameplay.

Browser adaptations: direct Unicode name entry, NFC normalization, trimming
Unicode surrounding whitespace, a maximum of 15 grapheme clusters, and rejection
of control/format characters. Draft names must be unique across four slots
(exact case-sensitive comparison after normalization). Adjusting a value exposes
the next point's price; lowering it refunds the same price paid to acquire it.
Reset and replacing an edited character require a local confirmation.

## Persistence boundary

`format: sundog-character-draft`, `version: 1`, slot 0–3, ISO timestamp and
`character: { name, attributes }`. Remaining points are derived, never trusted
from JSON. The database `sundog-character-drafts` is separate from future campaign
storage. Locale, preview selection, world records and campaign progress do not
belong in a draft. Loading/importing only changes the editor; saving is explicit.
Import is bounded to 8 KiB, rejects future versions and invalid allocations, and
projects accepted fields into a fresh object. File content is never HTML.

IndexedDB writes check duplicate names and replace the selected record in the
same transaction. Failed validation and aborted writes preserve existing slots.
Occupied slots require an explicit replacement confirmation. Export remains
available if browser storage is unavailable. Import does not overwrite a slot.
The file's slot is metadata; the user chooses where to save an imported character.

## Reference observation and remaining work

A disposable copy of disk1 was booted in MAME 0.285 (`apple2e`, joystick,
headless). The existing `docs/reference/game-utilities.json` sequence reached
the four occupied slots and opened the first slot's delete/play menu. Screenshots
are local in `build/remake-reference-r01b/`; the session has been stopped. The
interactive follow-up did not reach character creation, so no observed clean
new-game fixture or emulator-confirmed allocation result is claimed. An initial
pause call used an obsolete method and was corrected to the skill helper.

Movement source tracing identified `game_15.s` procedure 13 (`$070C` onward):
cursor offset (−3,+3), signed two-pixel steps limited by remaining distance, then
one-pixel retry if neither coordinate changed. Library22 procedure22 (`$14FE`)
tries diagonal and axis movement through native sprite/collision code. Collision
masks and interaction regions still require tracing; decorative SVG pixels do
not substitute for collision evidence.

Utility procedures 10–21 also contain generated bank/world/equipment records.
Their complete named semantics, a verified fresh-world fixture, and collision
remain the R04/R05 campaign gates. This checkpoint makes character preparation
usable while leaving those uncertainties explicit.
