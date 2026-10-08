# Native Warp pre-entry defeat — R10aa

The [capture runner](../../tools/remake/capture_warp_defeat_reference.py) uses
MAME0.285, the unenhanced `apple2e` driver, copied media, the recorded boot
sequence and an owned Qt debugger. Both a healthy control and a fatal run execute
original code through Nav/Warp and return. The
[verifier](../../tools/remake/verify_warp_defeat_reference.py) checks33 stopped
source contexts,77 hashed artifacts, original VM offsets, actual current/selected
location, opcode vectors, resources, RNG, clock and independent personal owners.
Both owned emulator processes exit0 and release their inputs/breakpoints.

## Declared entry and display context

This is a prepared source context, not ordinary campaign reachability. At the
existing Game12 main activation `$1388`, local12 is set and execution re-enters
its original exit test `$14CC`. Game13 main `$269D`, before operand pushes,
re-enters the original Nav case call `$2683`. At Nav `$2368`, before its UI-poll
operands, locals6/7/8 become1/0/7, local9 receives the existing12-byte current
location with system11, and the target/charge words221/222/223 become11/10/10.
Execution re-enters original action operands `$2415`, not an invented frame.

The earlier prepared Warp probes failed in the renderer even with a healthy
hull. A bounded diagnostic found status-window307 zeroed while the graphics
row tables remained intact. The canonical context explicitly supplies the
original Game15 `$009D–$00A9` rectangle245,265,4,13. Library22 proc18
`$01EA–$01FF` stores its reversed parameter order as words13,4,265,245.
The retained byte record is13,0,4,0,9,1,245,0. The healthy control now returns
through Nav with unchanged interpreter opcode vectors, establishing that the
prepared display context no longer corrupts the interpreter. No code is patched.
The old renderer-failing probes remain excluded.

At the actual first pre-action Library24 firing point `$084C`, the existing
fatal fixture supplies hull1, RNG28, type1, range5, cooldown40, radial motion0,
shield0 and pending fire45. The healthy control changes only that hull to100.
Both runs preserve actual equipment, inventory and personal condition.

## Observed fatal continuation

| Stop | Phase | Gun | Cooldown | Counter354 | Hull | Contact40 |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Game13 pre-action call `$1F94` | 1 | 68 | 29 | 3 | 16 | true |
| First call return `$1F97` / Warp entry `$1760` | 2 | 68 | 40 | 3 | 0 | true |
| Warp post-jump call `$18DA` | 2 | 68 | 40 | 6 | 0 | false |
| Post-jump return `$18DD` / Nav return `$1FD4` | 3 | 60 | 40 | 6 | 0 | false |
| Nav exit `$2442` / Game13 return `$2685` | 4 | 60 | 40 | 6 | 0 | false |
| Original Game7 death entry `$04B2` | 4 | 60 | 40 | 6 | 0 | false |

Fatal347 is set inside the pre-action call. It does not abort Warp proc35.
Its five-draw hit ends at RNGbytes220,15,135,195. The original gravity draw
continues to31,238,135,195; the two star-map passes preserve that RNG. The jump
changes actual location144 from system12 to11 and resets contact40/repeat47.
Nav copies the resulting current location into selected location72 before
return. The final clock stays18,21,0,0, and condition237,235,255,228, carried
items, attributes and all equipment bytes remain unchanged through the suffix.
The final native return has no Game12 three-call tactical startup and no extra
clock advance after Nav's phase4 display call.

The healthy control follows the same original return offsets without fatal347.
Its actual hull100→91 hit has a different RNG suffix, retained literally in its
own reference. It reaches Nav return at phase4/gun60/counter6 with no interpreter
vector corruption. This is a control for context validity, not terminal evidence.

## Reproduction and limits

```sh
python3 tools/remake/capture_warp_defeat_reference.py --healthy-control \
  --output-dir /tmp/new-warp-healthy --rompath /absolute/roms
python3 tools/remake/capture_warp_defeat_reference.py \
  --output-dir /tmp/new-warp-fatal --rompath /absolute/roms
python3 tools/remake/verify_warp_defeat_reference.py
```

The [healthy manifest](../reference/remake-warp-defeat-healthy-reference.json)
and [fatal manifest](../reference/remake-warp-defeat-fatal-reference.json) retain
scope, stopped offsets and hashes. Bounded diagnostics and a Lua argument-format
failure are excluded; their owned sessions were closed. The canonical captures
use the checked-in runner and helper.

This proves the declared native fatal Warp pre-entry/successful-jump return.
It does not prove a fatal gravity-failure return or ordinary Warp defeat
reachability. At R10aa, browser host matching was still required: that adapter lacked the
pre-action call and used normal tactical startup on fatal return. R10ac below
implements and verifies the captured Nav/death suffix. The
[full R10 audit](r10-completion.md) remains open.

## R10ac browser host integration

The live Warp adapter now commits the accepted Game13 pre-action machinery
call before gravity RNG, the successful post-jump call and the Nav display
return. A fatal pre-action hit still completes the accepted jump; its final
phase remainder0/gun60/cooldown40/counter6/RNG0xc387ee1f matches R10aa.
Terminal return clears the controller and freezes every owner without normal
Game12 startup. Healthy successful returns then perform the normal three-call
startup, for six calls in total. Failed gravity commits only pre-action and
Nav display calls, preserving location. Calls outside Game12 do not poll its
cargo deadline.

Rule coverage includes exact terminal save/reload, every starting phase and
atomic rejection of forged earlier fatal timestamps. When the post-jump call
crosses phase1, the second suffix call ends at phase2 with counter0. The live29
validator accepts that one-minute fatal timestamp difference only for completed
Warp, cleared contact/deadline flags, tactical terminal context and radius43.
Historical versions keep their existing contract. No save fields or version
change.

The original native capture remains the phase1 pre-action/successful-jump
fixture; other phase and gravity-failure checks are source-derived host tests,
not additional native observations. Personal forced sleep/death retains the
existing browser survival boundary before jump selection.

[54 focused Chrome UI checks](r10ac-warp-defeat-ui-validation.json) cover the
native phase1 vector in English desktop and Korean portrait, plus the
source-derived phase3 clock-crossing return. Actual Warp review/confirmation
produces the terminal panel; complete-state fresh reload, paused terminal
time, explicit earlier-slot restoration and a new navigation action all pass.
All three terminal screenshots were inspected. The [515-rule receipt](r10ac-rules-validation.json)
also passes, including all phases and forged timestamp rejection.
