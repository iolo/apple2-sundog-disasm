# Original fatal Comm-dispatch return — R10v

An owned MAME0.285 unenhanced IIe session on copied media retains8 asserted
source contexts and19 hashed artifacts. The runner declares an original Comm
case call at Game12 `$1458` in its existing main activation. It observes the
workspace stores at `$1320`, then lets the original Game16 timed return run
without injected dialogue buttons. The actual Game13 `$2588` dispatcher has
returned flag51=true and counter354=0. A declared fatal fixture is applied at
Library24 `$084C`, as in [the recovery reference](ship-recovery-reference.md).
Original instructions and Pascal frames remain unmodified. The session
releases owned breakpoints and inputs and exits0.

| Original stop | Phase | Gun | Cooldown | Counter354 | Flags35 / 51 |
| --- | --- | --- | --- | --- | --- |
| Game13 dispatcher `$2588` | 1 | 68 | 29 | 0 | true / true |
| Library24 fatal `$096A` | 2 | 68 | 40 | 0 | true / true |
| Game13 returned `$258B` | 2 | 68 | 40 | 0 | true / true |
| Game13 first UI poll `$20E8` | 2 | 68 | 40 | 1 | false / false |
| Startup7 death `$04B2` | 2 | 68 | 40 | 1 | false / false |

The original Game13 continuation clears the return flag at `$25E9`. Its
proc45 first poll increments354 at `$20DE–$20E4`; the counter is below the
new limit5, so no due machinery call runs. The exit test at `$215F` observes347.
There is no Game12 restoration, startup, post-hit movement or extra display
machinery call on this captured fatal path. This differs from the captured
[tactical-loop fatal return](ship-recovery-reference.md) and
[normal-startup returns](ship-later-startup-defeat-reference.md).

At death, hull0, phase2, gun68, cooldown40 and range5 retain the one dispatcher
call. Clock18,21,0,0, condition237/235/255/228, RNG `[220,15,135,195]`, equipment,
attributes, carried items and location are unchanged after the hit. Flags41/44
remain true. The fatal `$096A` stop precedes the final hull store.

The host already ran one Comm machinery call. It now also clears the returned
flag51 through its campaign dialogue owner, commits counter1 and removes the
conversation/deadline on ship destruction. The native-vector regression checks
source state, owner preservation, immutable input, exact reload and terminal
freeze. Its fixture represents already committed Game16 output at the dispatch
boundary; it does not bypass dialogue replay in playable campaign code.

Replay into a **new** directory and verify retained evidence:

```sh
python3 tools/remake/capture_comm_defeat_reference.py \
  --output-dir /tmp/sundog-comm-defeat-new --rompath /absolute/verified/roms
python3 tools/remake/verify_comm_defeat_reference.py
```

The original command-entry, supplied-save contact and prepared fatal hit do not
prove natural production, ordinary menu selection, a manually selected Agree
reply or fresh-character acceptance. Failed transport/input probes01/02 and
preliminary successful diagnostic probes03/04 are excluded from this retained
inventory; all their owned sessions also exited0. Only the repository runner's
successful probe05 is retained. Fatal warp pre-entry, reward224 and ordinary
encounter/equipment/shields/negotiation/jettison/recovery acceptance remain open.
R10 remains in progress under its original requirement row and full audit.
