# Component failure lifecycle — through R08m

The Game14 operation previously described as delayed repair is **delayed
failure**. It writes destroyed-item7, not a repaired component. Repairs replace
the destroyed part with a working standard part, compatible special part or
shunt. R08c implements the source failure operations and dependency updates in
`remake/js/core/equipment-failures.js`. R08d connects faulty installation, failure
updates and replacement to live engineering through `campaign-engineering.js`.
Version19 introduced pending failures. R08f connects dependency updates to live
gun/shield/cloaker controls, fuel consumption and version20 saves.

## Source trace

| Evidence | Behavior |
| --- | --- |
| Game16 proc11 `$0525–$0542`; existing `dialogue-effects.js` | Trader appraisal can add128 to a part when the attribute/chance checks both fail. Purchase transfers the complete byte. The interpreter producer is tested; an ordinary current-city acquisition journey for a faulty engineering component is not yet proven. |
| Game14 proc11 `$0742–$0784` | Installation fit uses the low-five-bit type, standard socket requirement, shunt23 outside socket0, or designated special part/socket. |
| Game14 proc8 `$05AE–$05F2` | Convert the display index to a five-byte-row offset. Write `byte % 32`, recalculate through Library24 proc8, then, if the supplied byte exceeds127, set record byte25 to that offset and restore the complete byte. The resulting performance cache temporarily describes the plain part. |
| Game14 proc7 `$0513–$0544` | Frame entry/cycling writes31 to record byte25, then replaces bytes strictly greater than144 with7. It does not recalculate performance here. |
| Game14 proc9 `$0691–$06A3` | An engineering update first runs Library24 proc9 in ship contexts or Library22 proc29 in other contexts. |
| Game14 proc9/10 `$06AE–$070F`, `$0673–$067E` | If byte25 is below20, clear it to31 and destroy that offset. Then scan offsets19 down to0 and destroy every remaining byte above127. Recalculate the group after the entire sweep. This is not a per-part repair duration. |
| Library24 proc13 `$09B1–$0A07` | After combat selects a component, a shunt hit makes20 eager random draws across the entire four-row record, including performance-byte positions. Each shunt with an odd draw receives128. The selected byte, if between8 and127, is then marked with128, byte25 is set, and output is immediately recalculated. |
| Library24 proc8 `$0177–$0181`, `$01F8–$0260` | Recompute special availability in flags16–21. At zero group performance, clear the corresponding power flag0–5. Groups0/2/4 also clear words222/226/224 respectively. If no working special component remains, clear the corresponding special control flag8–13. |

Offsets are segment-relative in `src/pcode/game_14.s`, `game_16.s` and
`library_24.s`. Word222 is the warp target charge,224 the shield target,226 the
gun charge. This cleanup does **not** directly zero current warp charge223,
current shield charge225 or fuel227. Do not clear these extra resources merely
because a component was removed.

The supplied manual's PDF pages11–14 were rendered and visually reviewed. Page11
locates the six engineering bays, page12 describes repairs through their object
windows, and page13 distinguishes status, hull, fuel, shield and weapon meters.
The detailed bit/tick behavior above comes from the recovered source, not the
manual illustrations. No original-emulator observation was made.

## Core boundary

The isolated state is `{group, pendingFailure}`. `group` uses the established
four-unit component/performance model; `pendingFailure` uses original offsets
`unit*5+socket`, with31 meaning none. Installation, frame entry, failure resolution
and selected-component damage each return owned data. They do not grant access
to a bay, transfer pocket contents, change a campaign clock or validate a save.
The R08d campaign controller owns access, pocket transfers and pending state
atomically, without changing cash, RNG or game time. R08f also reconciles the
source resource/control dependencies after equipment recalculation.

The source has observable ordering details that cannot be represented by simply
masking all encoded bytes during every performance calculation:

- A newly installed faulty part initially contributes output. Older encoded
  parts in the same group still make their units inoperative on that calculation.
- A combat-marked part immediately loses output.
- Entering another engineering frame can leave a stale native output cache after
  changing its displayed components. The source core preserves that ordering;
  the live save validator must either represent it explicitly or document a
  deliberate canonical-cache adaptation.
- Overwriting the marked socket does not itself clear the source's byte25. The
  subsequent update targets that offset even if a replacement was just placed
  there. A live atomic exchange implementation must resolve its update ordering
  explicitly, rather than silently inventing a repair timer.

`equipmentDependencyResult` uses a separate source flag/word session. R08f maps
it to named live resources and machinery controls without borrowing dialogue
flags. It preserves unrelated flags/words and never enables a control
automatically when a repair restores output. Zero gun output clears gun charge
and power; zero shield output clears its target; loss of a working cloaker
clears its control. Current shield charge is retained until its power update.

`hitEquipmentComponent` implements only a **selected** component hit. Encounter
generation, target selection, shield absorption, hull damage and ship destruction
remain part of the R10 combat work. They are not random landed failure events.

## Live engineering and deliberate adaptations

Installation validates both destinations before exchanging items. A carried
encoded component is checked by its low-five-bit type; its full faulty byte is
then retained with the source pending offset. The displaced part goes back into
the same pocket. A failed fit or remote/wrong-bank action cannot partially commit.

The visible engineering frame resolves pending failure after250ms. This is a
browser presentation cadence, not a repair duration, game-minute charge or native
CPU timing claim. Saves and a hidden document suspend the update and discard
partial elapsed time. Closing a panel retains pending state until that group is
opened again. Frame entry destroys the faulty part and recalculates output;
this deliberately canonicalizes the native stale frame-entry cache. Moves in a
pending group are disabled until resolution so a replacement cannot accidentally
inherit the source's old pending target. Cycling frames cancels selected moves.

The panel reports hull, fuel and offline units, plus failure/replacement feedback.
These are status values, not launch permission. Working parts or compatible
shunts restore output through ordinary exchanges; no component service fee or
invented healing action is added. The Power panel now runs the controls and fuel
rules described in [ship power](ship-power.md).

Version19 `landed-failures-1` adds `engineering.pendingFailures`, one source
offset or sentinel31 per group. Only the marked socket may hold an encoded faulty
byte; its temporary output is derived from the masked type. Other sockets and
metadata retain canonical validation. Versions1–18 pass their original checks
before receiving six sentinel values; older formats cannot inject failures.
Combat's multiple faults and immediate-output semantics need a later boundary.

## Verification and next integration

Seven rule groups cover all96 standard sockets, masked installation, special
parts, shunt restrictions, transient and final output, ordered multi-part burn
out, the strict144 frame boundary, selected hits, eager RNG, dependency cleanup,
caller ownership and the existing trader appraisal-to-fault path. The fixed
shunt vector starts at12345 and ends at2553372812 after20 draws. Its component
matrix was computed independently using four little-endian bytes, seven carry
shifts per draw, feedback from bit6 XOR bit30, and the documented result bytes.

The R08c Chrome receipt is `equipment-failure-core-validation.json`. R08d adds
six campaign rule groups for atomic exchanges, transient/final saves, legacy
migration and rejected malformed pending state. The historical278-group receipt is
`engineering-live-rules-validation.json`.

`engineering-failures-validation.json` covers28 live UI checks, including pending
save/reload, suspended updates, burnout, working replacement and both locales at
four viewport sizes. It explicitly seeds a carried faulty component156.
`engineering-exchange-regression-validation.json` separately covers37 checks of
the fresh-character replacement/shunt/cannibalization journey and legacy imports.
Neither receipt proves ordinary acquisition of a faulty component in Drahew:
the current system's availability rules limit visitor/referral offers. Further
regional markets belong to R09 and combat damage to R10; landed random damage
must not be invented to fill this coverage gap.

R08f's `machinery-rules-validation.json` covers293 rule groups, including live
dependency consequences and phase/resource saves. Its failure regression repeats
the28 UI checks against version20. `machinery-ui-validation.json` also verifies
last-working-gun removal and cloaker operation. R08m repeats28 failure,37
equipment and31 machinery UI checks against version22. Its74-check combined
fresh-character journey joins component replacement, paid services, power use
and loaded surface return; see the [R08 audit](r08-completion.md).
