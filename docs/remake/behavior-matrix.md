# Remake behavior evidence — R01a

This is a working specification, not a claim of complete semantic recovery.
Offsets are segment-relative hexadecimal; procedure numbers need their source
filename. `source-strings.json` indexes explicitly classified inline strings
with source lines, procedure, offset and exact bytes. It retains display-control
characters and includes historical variants; it is not a localization catalog.

| Flow / rule | Evidence | Status | Fixture / browser acceptance |
| --- | --- | --- | --- |
| Four save slots | `utility_disk1.s` procedure 8, `$00D0–$00E0`, loop 0–3 with 32-word descriptor stride; reference utility screenshot | Source-derived and previously observed | Four independent slots; no fifth slot. R04 pending. |
| New-game entry | Utility procedure 48, `$1FE4–$2020`: deletion/replacement check, name flow (31), initialization (9), attributes (22) | Source-derived | New state must not clone one of the supplied saves. R04 pending. |
| Name validation | Utility procedure 37, `$1442–$1580`: trim surrounding spaces, reject empty/duplicate name, confirm | Source-derived | Empty/duplicate names rejected. Unicode/IME entry replaces joystick alphabet as a deliberate browser adaptation. |
| Initialization | Utility procedure 9 `$0A86–$0A93` selects bank `word31 + 10*slot`, then calls 21, 17, 18. Procedure 21 `$08EA–$0902` preserves name around clearing 512 bytes starting at segment-29 word 36 | Source-derived, incomplete field semantics | Fresh-game defaults blocked until generator fields and mutation order are mapped; browser preview has no fake New Game action. |
| Attributes | Utility procedure 30 `$1036–$10B9` reads five bytes beginning at segment-29 word 48 as strength, intelligence, dexterity, charisma, luck | Source-derived | Schema records those five IDs; defaults, costs and refund rules are traced in `character-creation.md`; R04a implements editable drafts. |
| Initial coordinates | Utility procedure 21 `$09C7–$09D1` writes word40=54 and low byte word41=110; procedure 18 temporarily changes coordinates while copying six-word location blocks | Source-derived values; meaning partly unresolved | Preserve evidence without asserting a spawn location until the ship consumer is traced. |
| Generated world records | `docs/working-state.md`; utility 14 rotates 18 record templates using selector `(old+5)%18`; 17 persists world tables | Source-derived | Fresh worlds are generated. Extracted working-state records are not clean defaults. |
| Primary movement / secondary status | Manual PDF 10–12; `docs/reference/game-play.json` frames 18100–18600 and status capture | Manual-only movement; status previously observed | First gameplay fixture will hold/release primary input and open/close status. Movement/collision source trace still pending. |
| Ship artwork | `game_15.s` `$0315–$033C`, library 24 procedure 5; `docs/packed-ship-images.md` | Source-derived | External SVG derives from decoded HGR pixels; section/full variants remain separate. Artwork is not collision data. |
| World/city payloads | `docs/world-maps.md`, `docs/city-maps.md`, `game_21.s` procedures 26/28 | Source-derived | Preview all 18 stored worlds and 60 play cities. Raw indices are not claims of terrain meaning or live composition. |
| Colony requirement check | `game_20.s` procedure 4 `$00A0–$00B2` scans a 14-byte area using CSP 11 before proceeding; exact CSP predicate still to trace | Source-derived entry; predicate unresolved | Do not treat displaying a completion string as proof of delivery semantics. |
| Colony phase | Same procedure `$00B4–$00FE`: reads byte 2 at segment-29 word271, reports completed phase, tests equality with 9 | Source-derived | Store explicit phase and outstanding requirements; final phase must not be assumed to be a single delivery. |
| Campaign ending | Same procedure `$0101–$013B`: fulfilled-contract text, two packed fields of word45 set to 13; `startup_7.s` procedure 8 `$0647/$0665` congratulates player | Source-derived final branch | Later fixture must reach this through deliveries, not direct flag editing. |
| Next phase | `game_20.s` procedure 4 `$019D–$01AC` writes previous phase to byte1 and phase+1 to byte2 at word271 | Source-derived | Prevent repeated delivery effects. Quantities, cargo IDs and initial phase generation still pending. |
| Trading/banking | Manual PDF 19–20; `game_20.s` candidate consumer module, item table at `$0296–$02B5` | Manual-only financial rules | Bank-first purchase, sales to local bank, balances per system. Price formulas not yet ported. |
| Browser presentation | PLAN-REMAKE.md | Proposed adaptation | 4:3, separate SVGs, local font, English/Korean, pointer/keyboard/touch. No game-rule claim. |

## New-game and campaign blockers

Before R04, trace utility procedures 10–21 and 25–30 into named state fields,
including starting money, inventory/equipment, attribute budget, time, location
and generator randomness. Then observe a clean new game on disposable disks.
Use the existing utility sequence as the scenario starting point; no live
emulator session was run in R01a. Before R05, trace movement/hit/collision rules.
Before R11, decode phase requirement generation, delivery accounting and the
remaining-goods predicate. These block gameplay fidelity, not the independent
graphics loader, content viewer, localization or viewport work.

The first ship fixture is specified as: a verified new state near the airlock,
primary press/hold/release movement, secondary status open/close, one supported
inventory transfer, save, fresh-session reload, continuation. It remains pending
until initialization and movement gates pass. Development previews have their
own UI state and must never be serialized as campaign saves.

## Discrepancies and decisions

- Manual PDF 9 describes eight games and different disk roles. Use four slots
  and the observed supplied-image roles (disk1 title/utilities, disk2 play).
- Source string lengths/ASCII are original constraints. Browser names and text
  accept Korean; retain stable IDs and define a Unicode length limit in R04.
- Original display-control symbols (`|`, backslash, etc.) are preserved in the
  source index. Translate their meaning when building UI; never show them raw.
- A bank-selected, overlaid city screen is not the bare 20×12 payload. The
  preview calls it a stored layout; palette and variant choices are preview
  presentation, not evidence of original composition.
- The accepted 488 bytes remain out of scope. No new dependencies on them.

Manual page index and available resource inventory remain in PLAN-REMAKE.md.
