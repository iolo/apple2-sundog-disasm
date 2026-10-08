# Original fatal second/third startup returns — R10u

These two owned MAME0.285 unenhanced IIe sessions use copied media and the
same declared counter0/source-call re-entry as [R10t](ship-startup-defeat-reference.md).
They stop at the original second `$06C4` or third `$074F` Library24 call,
then apply the existing five-draw fatal fixture at Library24 `$084C`.
Original instructions and Pascal frames remain unmodified. Each session
releases its owned breakpoints and inputs and exits0. The retained inventory
has21 asserted source contexts and48 hashed artifacts, verified by
`tools/remake/verify_later_startup_defeat_reference.py`.

| Actual stop | Second-call hit: phase / gun / cooldown / counter | Third-call hit: phase / gun / cooldown / counter |
| --- | --- | --- |
| Fatal `$096A` / selected call return | 3 / 60 / 40 / 0 | 4 / 60 / 40 / 0 |
| Third-call return `$0752` | 4 / 60 / 36 / 0 | 4 / 60 / 40 / 0 |
| Initial menu poll `$0F19` | 4 / 60 / 36 / 0 | 4 / 60 / 40 / 0 |
| Menu poll returned `$0F2B` | 4 / 60 / 35 / 0 | 4 / 60 / 39 / 0 |
| First main `$1388` | 4 / 60 / 35 / 0 | 4 / 60 / 39 / 0 |
| Exit test `$14CC` | 4 / 60 / 34 / 1 | 4 / 60 / 38 / 1 |
| Startup7 death `$04B2` | 1 / 52 / 30 / 0 | 1 / 52 / 34 / 0 |

The hit changes scene-high to12; remaining startup calls continue. Menu polling
moves the contact without incrementing354; the first main iteration increments
it and moves the contact before testing347. Game13 makes one display-return
call before death dispatch. The clock is18,21,0,0 through the exit test and
19,21,0,0 at death. Post-hit RNG stays `[220,15,135,195]`; range5, condition,
equipment, attributes, carried inventory and location remain unchanged. The
fatal stop precedes the hull store; the selected call return has hull0.

The R10t host correction already handles both suffixes. A new campaign regression
exercises full entry with delayed native-style aim/fire: seed28 fires on call2;
seed3149629074 misses its first aim, then fires on call3. Those host fixtures
retain aggression, unlike the captured suffix fixtures. They consume14 and11
draws respectively, including post-hit aim/fire, and are not claimed to have
identical captured RNG. They verify cooldown30/34, phase1, gun52, clock+1,
immutable input, exact reload and terminal freeze.

Replay each session into a **new** directory:

```sh
python3 tools/remake/capture_startup_defeat_reference.py --fatal-call 2 \
  --output-dir /tmp/sundog-startup-second-new --rompath /absolute/verified/roms
python3 tools/remake/capture_startup_defeat_reference.py --fatal-call 3 \
  --output-dir /tmp/sundog-startup-third-new --rompath /absolute/verified/roms
python3 tools/remake/verify_later_startup_defeat_reference.py
```

These observations close the declared native second/third **normal startup**
context checks. Fatal warp pre-entry and Comm dispatch remain open, as do
ordinary encounter, equipment, shields, negotiation/jettison and recovery
acceptance. The supplied-save contact, source re-entry and fatal fixtures do
not prove natural production or ordinary menu reachability. R10 remains in
progress under its original requirement row and audit.
