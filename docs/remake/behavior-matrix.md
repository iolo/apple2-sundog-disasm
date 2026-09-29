# Remake behavior evidence — R01a

This is a working specification, not a claim of complete semantic recovery.
Offsets are segment-relative hexadecimal; procedure numbers need their source
filename. `source-strings.json` indexes explicitly classified inline strings
with source lines, procedure, offset and exact bytes. It retains display-control
characters and includes historical variants; it is not a localization catalog.

| Flow / rule | Evidence | Status | Fixture / browser acceptance |
| --- | --- | --- | --- |
| Four save slots | `utility_disk1.s` procedure 8, `$00D0–$00E0`, loop 0–3 with 32-word descriptor stride; reference utility screenshot | Source-derived and previously observed | Four independent slots; no fifth slot. R04a drafts and R04c ship checkpoints implement separate browser stores; campaign saves pending. |
| New-game entry | Utility procedure 48, `$1FE4–$2020`: deletion/replacement check, name flow (31), initialization (9), attributes (22) | Source-derived | New state must not clone one of the supplied saves. R04 pending. |
| Name validation | Utility procedure 37, `$1442–$1580`: trim surrounding spaces, reject empty/duplicate name, confirm | Source-derived | Empty/duplicate names rejected. Unicode/IME entry replaces joystick alphabet as a deliberate browser adaptation. |
| Initialization | Utility procedure 9 `$0A86–$0A93` selects bank `word31 + 10*slot`, then calls 21, 17, 18. Procedure 21 `$08EA–$0902` preserves name around clearing 512 bytes starting at segment-29 word 36 | Source-derived, incomplete field semantics | Clean allocation/save observed in R04b; generated field meanings and mutation order still need mapping; browser preview has no fake New Game action. |
| Attributes | Utility procedure 30 `$1036–$10B9` reads five bytes beginning at segment-29 word 48 as strength, intelligence, dexterity, charisma, luck | Source-derived | Schema records those five IDs; defaults, costs and refund rules are traced in `character-creation.md`; R04a implements editable drafts. |
| Initial coordinates | Utility procedure 21 `$09C7–$09D1` writes word40=54 and low byte word41=110; procedure 18 temporarily changes coordinates while copying six-word location blocks | Source-derived values; meaning partly unresolved | New-character save and ship entry case 11 verify (54,110); see `ship-movement.md`. |
| Generated world records | `docs/working-state.md`; utility 14 rotates 18 record templates using selector `(old+5)%18`; 17 persists world tables | Source-derived | R04d implements system position/balance and orbital-angle generators; utility14/16 commodity/city records still need semantic mapping. Extracted working records are not clean defaults. |
| Primary movement / secondary status | Manual PDF 10–12; game15 procedure13; library22 procedures9/22; `docs/reference/remake-ship-movement.json` | Movement source-derived with observed endpoint; status previously observed | R05a implements hold/release walking with the recovered glyph mask and fallback order. See `ship-movement.md` and `walk-validation.md`. R05c adds condition meters; complete status actions remain pending. |
| Ship artwork | `game_15.s` `$0315–$033C`, library 24 procedure 5; `docs/packed-ship-images.md` | Source-derived | External SVG derives from decoded HGR pixels; section/full variants remain separate. Native collision consumes low HGR bits with glyph13; explicit collision data is exported separately. |
| Carried items / ship storage | Utility20/21; game14 procedures3/4/8/12; library27 procedures7/13/15 | Source-derived; initial bytes match clean capture | R05b implements four carried slots and twenty each in locker/stores, reached through ship movement. Atomic two-click transfers preserve complete bytes. See `inventory.md`. |
| Item names / charge / icons | Library27 procedures3/4/10; play-side item-name table | Source-derived | External composed SVGs, English/Korean names, low-five-bit type and upper-three-bit shield/scattergun value. R05c supports food/rapidheal use; other item effects and engineering fit remain pending. |
| Personal condition | Game8 procedures2/7; utility21 `$0922–$092B`; manual PDF12; `remake-condition-fixture.json` | Source-derived, fresh values independently observed; controlled display observation | R05c shows vigor/rest/health/nourishment with `(value+7) div8` meter extent; initial bytes are 255. R05d adds hourly changes; see `condition.md` and `survival.md`. |
| Food / rapidheal | Library27 procedures11/14; library22 procedures34/35/37 | Source-derived; successful original use not observed | R05c adds 80 to nourishment/health, clamps to 255 and consumes one carried item even at full. Browser pure tests cover all 256 starting values for both effects. |
| Hourly survival / landed sleep | Library22 procedures26/29/60; library24 procedure9; game8 procedures3/17; `remake-survival.json` | Three hourly transitions observed with explicit RAM fixtures; sleep-loop effects source-derived | R05d adds clock, depletion/recovery, sleep, exhaustion and terminal restart. Browser cadence and menu pauses are explicit adaptations. See `survival.md` and `survival-validation.md`. |
| Ship checkpoint persistence | Browser adaptation over the verified R05a–d state; utility8 supplies only the four-slot convention | R04c implemented; no original save-format compatibility | Atomic validated restore, paused load, JSON round-trip, fresh-page persistence, independent slots and stale-tab protection. See `checkpoints.md` and `checkpoint-validation.md`. |
| Equipment initialization | Utility19/21; game14 procedure3; library24 procedure8; clean-character globals offset108 | Source-derived; all six captured initial records reproduced with constructed compatible draws | R04d pure generator for components, damage, spares and performance. Repair/ship consequences remain pending. See `initialization.md`. |
| Initialization randomness | Library22 native procedure3; Pascal FJP native handler | 112 source-loop transitions checked with sim65; startup seed not observed | R04d serializable RNG preserves byte order, seven shifts, eager draws and low-bit boolean behavior. |
| World/city payloads | `docs/world-maps.md`, `docs/city-maps.md`, `game_21.s` procedures 26/28 | Source-derived | Preview all 18 stored worlds and 60 play cities. Raw indices are not claims of terrain meaning or live composition. |
| Colony requirement check | `game_20.s` procedure 4 `$00A0–$00B2` scans a 14-byte area using CSP 11 before proceeding; exact CSP predicate still to trace | Source-derived entry; predicate unresolved | Do not treat displaying a completion string as proof of delivery semantics. |
| Colony phase | Same procedure `$00B4–$00FE`: reads byte 2 at segment-29 word271, reports completed phase, tests equality with 9 | Source-derived | Store explicit phase and outstanding requirements; final phase must not be assumed to be a single delivery. |
| Campaign ending | Same procedure `$0101–$013B`: fulfilled-contract text, two packed fields of word45 set to 13; `startup_7.s` procedure 8 `$0647/$0665` congratulates player | Source-derived final branch | Later fixture must reach this through deliveries, not direct flag editing. |
| Next phase | `game_20.s` procedure 4 `$019D–$01AC` writes previous phase to byte1 and phase+1 to byte2 at word271 | Source-derived | Prevent repeated delivery effects. Quantities, cargo IDs and initial phase generation still pending. |
| Trading/banking | Manual PDF 19–20; `game_20.s` candidate consumer module, item table at `$0296–$02B5` | Manual-only financial rules | Bank-first purchase, sales to local bank, balances per system. Price formulas not yet ported. |
| Browser presentation | PLAN-REMAKE.md | Proposed adaptation | 4:3, separate SVGs, local font, English/Korean, pointer/keyboard/touch. No game-rule claim. |
| City doors / bank inquiry | Game21 procedures19/20/21; startup_disk1 scene dispatch; game19 procedures1/17 | Source-derived, browser validated | R06c ports door footprints and foot-bank visits; current-system account/cash inquiry, exact street return and version4 saves. No transactions or other building entry yet. See `city-buildings.md`. |
| Walking building interiors | Game18 procedures14/16/17/26; library22 fill/collision; interaction records8–15 | Source-derived, browser validated; no emulator capture | R06d enables types9/10, eight static layouts, glyph24 collision, doorway exit and version5 saves. Fixed window/explicit exits are adaptations; NPCs and other types pending. See `building-interiors.md`. |

| Initial room occupants | Game18 procedures9/13/14/16; library22 procedures3/40; interaction bytes4–7/22–25, glyph23 | Source-derived, 64 independent Python vectors and browser validated; no emulator capture | R06e adds stationary visitors/counter occupant, pixel collision and version6 seed/RNG saves. The no-visitor reversed-range fallback fails atomically; movement/dialogue pending. See `room-occupants.md`. |

## New-game and campaign blockers

R04b observes clean character creation on disposable disks; R05a implements the
traced movement/collision rules. Attribute allocation is implemented in R04a.
To finish R04, map the remaining utility procedures 10–21 and 25–30 into named
state fields, including money, inventory/equipment, time, world generation and
randomness. R05b implements storage transfers; R05c adds personal condition and
food/rapidheal use; R05d adds a clock and landed-ship survival/sleep. R05 still
needs engineering, exits and other consequential interactions. Original sleep
UI and item-use observations remain incomplete.
Before R11, decode phase requirement generation, delivery accounting and the
remaining-goods predicate. These block gameplay fidelity, not the independent
graphics loader, content viewer, localization or viewport work.

The first ship fixture is specified as: a verified new state near the airlock,
primary press/hold/release movement, secondary status open/close, one supported
inventory transfer, save, fresh-session reload, continuation. It remains pending
until initialization, status, inventory and campaign persistence pass. Development previews have their
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
