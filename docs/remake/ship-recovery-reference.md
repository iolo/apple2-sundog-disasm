# Native ship defeat and saved-point restart — R10p

An owned MAME0.285 unenhanced IIe session boots the supplied play slot on
disposable media. [Metadata](../reference/remake-recovery-reference.json)
retains26 hashed artifacts, operation receipts and the observed terminal exit0.
The encounter and fatal hit are declared RAM fixtures. The damage, dispatcher,
death dialog, disk requests and restart controls execute original routines.
This establishes a native recovery path, not fresh-character combat acceptance.

## Fatal damage and dispatch

`recovery_reference.lua` asserts an actual Library24 proc13 `$084C` debugger
stop before changing range to5, pending fire45 totrue, shield charge to0, hull
to1 and RNG to28. It retains enemy health, equipment and personal condition.
The five native draws3584/3591/3719/3975/28295 choose a penetrating shot and
the hull record. Their final bytes are220/15/135/195 (`$C3870FDC`).

[Library24 `$096A`](../reference/remake-recovery-fatal.json) has already set
word347=1 and scene-high12. The hull byte is still1 because that stop precedes
its final store. [Startup7 `$04B2`](../reference/remake-recovery-death-dispatch.json)
independently observes hull0 after Game12/Game13 return. Personal condition
remains237/235/255/228; ship death must not fabricate personal injury.

The capture exposed an integration gap: phase2 at the fatal hit becomes
phase3 before the dialog, gun charge68 becomes60 and contact cooldown40 becomes35.
Clock21:18 and RNG bytes remain unchanged. R10p's campaign host froze at the
fatal call. R10q now reproduces this due-frame exit in the opt-in29 host, as
described below; the live UI and ordinary recovery acceptance remain pending.

## Legitimate continuation

Startup7 proc8 `$04A8–$056B` checks scene-high12 and opens the death dialog.
The visually inspected [screen](../reference/remake-recovery-death-screen.png)
offers restart at the last saved point. Physical axes95/240 position the pointer
over Yes; a released/new primary press produces the native utility-side request.

The repository filenames describe physical input disks, not the game's side
labels: the utility request accepts disposable disk1, whose block0 byte252 is0;
the play request accepts disposable disk2 with marker9. An initially rejected
disk2 swap and off-target pointer attempts contribute no acceptance proof.

After the native utility transition, the [restored title/menu state](../reference/remake-recovery-restored.json)
has hull16, word347=0, clock16:48, condition227/255/255/243 and charisma10.
Those differ from the fatal state and belong to the saved campaign. Restoration
rolls back the campaign rather than resurrecting the destroyed ship in place.
The attempted Startup7 `$063E` breakpoint was never reached across this
transition; no exact reload-opcode stop is claimed.

Selecting Play SunDog through the native menu, swapping to the requested play
side and acknowledging with a fresh primary press resumes the ship interior.
The [continued capture](../reference/remake-recovery-continued.json) retains
hull16/word347=0 and advances the clock to17:45. The [interior screenshot](../reference/remake-recovery-play-side-run.png)
verifies the playable scene. All held inputs and owned breakpoints are released;
the worker observes exit0.

## Browser scope and reproduction

The new ship-combat rule group reproduces the native five-draw fatal vector,
defeat word, hull store and scene12. It leaves equipment/cargo owners unchanged
and checks input immutability against an independent byte/carry RNG oracle.

Browser recovery must load a validated saved campaign with all owners restored.
The existing save screen already supports explicit saved-slot loading; live
space defeat detection and ordinary UI acceptance
remain R10 work. Native tractor collection, rare reward224 and the other full
[R10 acceptance gates](r10-completion.md) also remain open.

## Due-frame defeat exit — R10q

Game12 proc12 does not return at the fatal hit: `$0B8A` polls its demand
deadline, `$0BAD` refreshes sensors, and `$0BB5` moves again using the captured
contact. Thus cooldown40 becomes39 before the tactical loop exits. Game12
`$14D4` releases a pending demand; proc17's gun-loop exit clears power2.

Game13 main `$26B2` calls proc12 with both boolean parameters true. Its
initial proc13 call at `$1300` runs Library24 proc9 at `$0C2A`. Because the
ship is now in scene12, combat uses the non-tactical movement branch, subtracting
another4 from cooldown. The native power phase3 subtracts8 from the unpowered
gun charge. CSP4 `EXIT(13,12)` at `$1314` returns before proc18 at `$131B` can
run its own Library24 call. This accounts for exactly one additional phase,
not a fresh tactical frame or a blanket extra tick on every terminal update.

`advanceCampaignMachinery` completes the due frame's post-move, releases the
controller/deadline, and performs that one actual flight/production/power/combat
call. Subsequent terminal updates remain frozen. Two new campaign rule groups
compare the R10p literal phase/charge/cooldown/RNG vector, owner preservation,
input immutability, and saved terminal continuation. A separate phase4→1
case verifies the real hour update and gun/deadline release. Current29 accepts
the fatal-hit timestamp one minute before dispatch only at phase1; earlier
historical formats retain equal timestamps, and imports never replay the exit.

[R10q rules](r10q-rules-validation.json) pass503 Chrome155.0.8059.39 groups;
45 focused tactical/salvage/campaign groups also pass. This proof covers fatal
damage during a due Game12 frame. Fatal entry/startup and Comm-dispatch contexts
still need auditing, as do live recovery controls and ordinary campaign play.

Reproduce using the [a2-mame skill](/home/iolo/.codex/skills/a2skills/a2-mame/SKILL.md),
`encounter_bootstrap.py --debug` and the helpers in metadata. Verify model,
media, actual debugger stops and matching operation receipts. Use new output
directories and disposable media. Scheduled go/mount/input/exit receipts
require subsequent observed states; retain the final worker termination result.

`python3 tools/remake/verify_recovery_reference.py` checks all26 retained hashes,
actual fatal/death source offsets, personal-condition preservation, restored
owners/clock and terminal receipts. The [validation summary](r10p-validation-summary.json)
records501 passing Chrome rule groups,19 focused ship-combat groups,22 exporter
tests,171 deterministic artifacts,584 source-string records and three original
input hashes. It retains R10's in-progress status.

## R10t first-startup follow-up

[The declared first-startup capture](ship-startup-defeat-reference.md) now
observes the complete fatal first-call continuation and death dispatch. It
corrects the earlier host's immediate startup freeze. Other startup/warp/Comm
contexts and ordinary recovery acceptance remain under the full R10 audit.
