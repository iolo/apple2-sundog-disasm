# Fatal first tactical-startup call — R10t

An owned MAME0.285 unenhanced IIe session on copied media observes a fatal hit
during the first Game12 proc9 startup call and continues through original death
dispatch. [Metadata](../reference/remake-startup-defeat-reference.json) retains12
asserted source contexts and27 hashed artifacts, matching receipts, breakpoint
cleanup, joystick release and terminal exit0.

The context is declared: the existing Game12 main activation is redirected to
its original proc9 call at `$1381`, Comm return/deadline fields are cleared and
counter354 is set to0. At the first actual startup call `$0655`, the probe enters
Library24 proc13 and stops at `$084C`. The existing fatal fixture then sets
hull1, pending fire45, range5, speed0, shield charge0 and RNG28. Original code
executes the hit and all subsequent calls. No Pascal frame or instruction is
fabricated. The retained setup records every edit. This does not establish an
ordinary menu transition or fresh-character combat acceptance.

| Native stop | Phase | Gun charge | Cooldown | Counter354 |
| --- | ---: | ---: | ---: | ---: |
| First startup call, before damage | 1 | 68 | 29 | 0 |
| Fatal `$096A` / first call return `$0658` | 2 | 68 | 40 | 0 |
| Second call return `$06C7` | 3 | 60 | 36 | 0 |
| Third call return `$0752` | 4 | 60 | 32 | 0 |
| Initial menu poll return `$0F2B` | 4 | 60 | 31 | 0 |
| First main exit check `$14CC` | 4 | 60 | 30 | 1 |
| Startup7 death dispatch `$04B2` | 1 | 52 | 26 | 0 |

The fatal stop precedes the final hull store; the first startup return has
hull0. RNG finishes at bytes `[220,15,135,195]` and remains unchanged. Personal
condition `[237,235,255,228]`, equipment, attributes and carried inventory are
preserved. The final Game13 display-return call advances clock21:18→21:19 and
resets354 at phase1. The earlier counter-retaining exploratory probe is excluded
from this canonical counter0 inventory, as is the failed helper-loading run.

The host previously stopped its startup loop at the fatal first call. It now
allows the remaining actual startup calls, the initial menu poll and one main
iteration before releasing the controller/deadline and committing Game13's
display-return call. The literal campaign regression matches phase1/gun52/
cooldown26, RNG, fatal timestamp and final clock. Complete save/reload freezes
that result without rerunning any return calls; the input campaign stays intact.

Reproduce with an owned new output directory and verified IIe ROMs:

```sh
python3 tools/remake/capture_startup_defeat_reference.py --output-dir /tmp/new-startup-defeat --rompath /absolute/roms
python3 tools/remake/verify_startup_defeat_reference.py --retain /tmp/new-startup-defeat
python3 tools/remake/verify_startup_defeat_reference.py
```

This evidence covers a fatal **first normal startup call**. Native captures for
fatal second/third startup calls, the warp pre-entry call and Comm dispatch
remain separate audit work. Reward224 and ordinary encounter, equipment,
negotiation/jettison and recovery acceptance remain in the unchanged full R10
scope. R10 is in progress.

R10u subsequently retains [the second/third normal-startup returns](ship-later-startup-defeat-reference.md).
The metadata above preserves R10t's historical scope; the later evidence closes
those two declared context checks. Warp pre-entry and Comm remain open.
