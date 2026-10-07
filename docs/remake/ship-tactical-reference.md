# Original-game tactical entry and frame evidence — R10l

Two owned MAME0.285 unenhanced Apple IIe/joystick sessions resumed the supplied
being-played slot on disposable media. The original sizes/hashes verify before
and after the sessions. This is a prepared native reference, not naturally
generated piracy or fresh-character campaign acceptance.

[Metadata](../reference/remake-ship-tactical-reference.json) inventories25 source
contexts and29 hashed raw artifacts, including three visually inspected PNGs.
The source contexts retain CPU/VM registers, activation-record locals, source
globals, equipment and their exact stop status.24 contexts are owned debugger
stops; the final bolt-menu context is an ordinary paused snapshot. Early
unsuccessful breakpoint probes and the mistaken startup-return probe are excluded.

## Native redraw branch correction

Game12 proc12 at `$0AC5–$0AD8` tests invisible/half-counter/grace. Its false
table branch is **not a return**: `$0BF8` stores a backwards pointer to `$0B5D`.
It skips drawing and grace decrement, then still moves and tests the machinery
threshold. R10k incorrectly gated all movement/due calls with that redraw test;
R10l corrects the core and reports `redraw` independently.

The visible/grace-zero captures independently prove that correction:

| Capture | Virtual offset | Counter354 | Phase352 | x/y | Grace | Visible |
| --- | --- | ---: | ---: | --- | ---: | ---: |
| `redraw-false-due-gate` | `$0AC5` | 5 | 1 | 538/512 | 0 | 1 |
| `redraw-false-pre-due` | `$0B70` | 5 | 1 | 544/512 | 0 | 1 |
| `redraw-false-post-due` | `$0BB9` | 5 | 2 | 550/516 | 0 | 1 |

Frame limit353=5 and its cached half=2. At counter5, visible1/grace0 makes the
redraw condition false. The native velocity begins x3/y0; range39 gives factor2,
so pre-due movement adds6/0. Actual machinery changes velocity to x3/y2; post-due
movement adds6/4. The [screenshot](../reference/remake-tactical-redraw-false-due-gate.png)
shows the sensor target. A separate false-branch capture at counter3 reaches
the proc12 return with movement executed and no due call.

The regression also retains the observed visible/grace-zero sequence at
counter11: x516/y510, velocity2/1, pre-move520/512; actual phase1 clock resets
354 and combat changes velocity3/0; post-move526/512. The next captured main
frame has counter1. No substitute unconditional display-frame tick is inferred.

## Pre/post movement and phase clock

The offscreen gate/pre-due/post-due/post-move contexts show x/y899/730→905/736,
unchanged by the machinery call, then911/742. Range39 and velocity3/3 explain
each6/6 movement. These observations match the [control core](ship-tactical.md).

Due calls retain counter354 across intervening phases. The `clock-reset`
capture shows phase352=1, counter354=0 and a new game minute after the actual
phase1 clock call. Counter354 is shared frame/time state, not a hit total or a
counter that resets on every machinery call.

## Entry and main dispatch

The second session stops at proc9 entry `$04DA`, then each startup call site
`$0655/$06C4/$074F` in order. Actual Game13 dispatch restores353=5 before entry,
superseding the contact fixture's provisional16. The first two observed startup
calls advance phase3→4→1; the second resets354 from2 to0 and adds one minute.
The source's third call is reached and execution continues into the main loop.
The later ready captures do not isolate its immediate return from subsequent
main-loop updates.

Parent grace local3 retains raw34012, signed−31524, through startup preparation.
It is leftover activation-record data, not evidence for a universal initial0.
The browser host must declare its initialization adaptation and save its own
subsequent grace; copying arbitrary native stack contents is not a campaign rule.
Reticle initialization does match actual world angle16/radius128 and sensor16.

Consecutive main-loop stops at `$1388` show counters1→2→3. At even2 the cooldown
and range remain30/117; at odd3 they become29/116. This verifies the native
`false_jump` bit0 dispatch independently of JavaScript truthiness.

## Ordinary joystick bolt arming

Joystick inputs move from the retained cursor to Jettison and open the
[BOLTS ARMED screen](../reference/remake-tactical-bolts.png). The retained input
receipt is `remake-tactical-bolts-input.json`. The later paused source context
records menu2 and the unchanged actual two-slot manifest: packed records
`$01E1/$018D`, whose low5 type bits are1/13. Their source labels are Ship's fuel
and stock embryos. Both qualify for the source menu's1–30 gate.

No discard was confirmed. This supports source arming/menu entry, not native
loss accounting, cryogen menu reachability, RNG outcome or negotiated escape.
Cryogen31 exclusion remains source-derived from proc15's strict `<31` test.

## Reproduction

Use the [a2-mame skill](/home/iolo/.codex/skills/a2skills/a2-mame/SKILL.md) and
`tools/remake/encounter_bootstrap.py --output-dir <new directory> --rompath
<local ROM directory> --debug`. Load the installed control helper, verify the
boot debugger stop, call `go`, and wait for `R10_BOOT_PAUSED`. Inspect status and
devices before loading the three project Lua helpers listed in metadata.

`tacticalOpcodeBreakpoint(offset)` resolves the Game12 trailer at `$BDB6` on
dispatch and returns an owned breakpoint ID. Send each operation separately
through `a2.call`, verify its matching receipt, and retain the returned ID.
At each debugger stop, pause and use `tacticalSourceSave(path)`; that helper
validates the Game12 trailer and actual machinery-call bytes before capture.
Do not treat a scheduled go/probe or ordinary snapshot as a breakpoint hit.

For entry, set offset `$04DA` before `spaceContact(path)`. Replace each owned
breakpoint sequentially with `$0655`, `$06C4` and `$074F`, capturing before
advancing. `$0754` is the Comm-return branch, not the normal startup return.
For frames, use `$0AC5/$0B70/$0B8A/$0BB9` to separate the gate, pre-move,
post-machinery and post-move states. `$1388` observes the main increment boundary.
The first session's centered fixture additionally writes205/206=512 and
208/209=0 after a due call; all other owners are retained.

Remove each owned breakpoint, release touched joystick inputs and exit only the
owned process. Scheduled exit must be observed as terminal. Both sessions were
closed; all three original input sizes/hashes verify afterward.

Native aim/fire input, Comm reticle restoration, salvage, damage/death/recovery
and rare reward224 remain open. Campaign frame/save integration, live localized
space controls, display-refresh/sleep/reload and legitimate ordinary-play
avoid/fight/lose acceptance remain required by the [R10 audit](r10-completion.md).
