# Original-game ground encounter — R10d

A fresh owned MAME0.285 Apple IIe/joystick session resumed the supplied
being-played slot on copied disks, prepared a declared city-foot context, and
ran the original Game21 encounter gate, chase and catch. Game17 then initialized
six combat actors. [Metadata and hashes](../reference/remake-ground-encounter.json)
cover ten raw JSON/PNG artifacts. This is controlled reference evidence, not a
fresh-game journey or natural unseeded production.

## Observations and browser comparison

The [city context](../reference/remake-ground-city.png) has scene3, a valid
city tile8 under the actor, and source system threshold12. Clearing source
flags28/114 prevents retained exit/map state from replacing the declared
position. The earlier probes placed the actor outside the populated city map;
their tile0 and direct-scene5 results are excluded.

At the actual Library22 procedure3 entry for Game21's `$1F11` gate, the fixture
writes the live RNG bytes `[52,42,0,0]` (seed10804). These are declared data
edits. No instructions, virtual IP, CPU registers, chase records, kind16 or
combat scene5 are written. The source draws6677 (`MOD64=21`),6797,8077 and15501.
The gate enters procedure40; its subsequent draws select the upper entry side,
the slow chaser and finally a mugger (`15501 MOD16=13 > threshold12`, tile8<12).

The [prepared chase](../reference/remake-ground-chase.png) has window
`(100,66)–(180,126)`, player `(137,99)`, chaser `(137,76)`, and native workspace
mode8. Primary movement is not held. The source chaser reaches `(137,93)` and
its attempted step is blocked by the player's collision glyph. The
[catch receipt](../reference/remake-ground-caught.json) has counter32731,
direction3, kind16, and current/middle scene5/3. Catching is the source's
blocked-step rule, not an invented distance test.

The [initialized combat window](../reference/remake-ground-combat-initial.png)
and [activation receipt](../reference/remake-ground-combat-initial.json) were
captured immediately after Game17 procedure11 returns, before the initial
conversation and combat iterations. Its saved bounds are left70/top40/right209/
bottom135; local94 is actor count6. Locals9–38 contain:

```text
[91,137,5656,47878,256]
[83,137,5912,22018,265]
[109,183,5912,39683,264]
[65,124,5912,33543,264]
[72,135,5912,30210,265]
[83,161,5912,26626,269]
```

The browser initialization matches every word of these six records, the
carried laser swap, and the native final RNG state1537047451 from input
1183653752. It uses29 draws; an independent byte/carry RNG oracle also reaches
that final state. The regression fixture in
`remake/tests/fixtures/ground-native-init.json` is derived from the retained
receipts. Cash and other flags are outside this comparison. Later native
equipment/session locals must not be treated as initialized at this capture
point. The blank browser background represents the cleared combat interior;
the comparison does not claim pixel equivalence outside it.

This establishes R10's required original-game ground observation and a native
initialization comparison. No native shot/damage, negotiation, robbery,
defeat/recovery, ordinary browser campaign journey or cycle-equivalent timing
is proven. Timed dialogue-settling experiments are excluded from this receipt.

## Reproduction

Start a new owned console using verified local ROMs:

```sh
python3 tools/remake/encounter_bootstrap.py --output-dir <new directory> --rompath <local ROM directory> --debug
```

The Qt debugger initially stops at boot. Load the installed a2-mame helper,
inspect status, and call `go`. Wait for `R10_BOOT_PAUSED` at frame18000, then inspect
status and devices to verify paused Apple IIe and copied disk2. Load
`tools/remake/encounter_reference.lua` and `tools/remake/ground_reference.lua`.
Use absolute paths for the checkout, helpers and output.

Send these calls individually, reading every matching `A2` receipt:

```lua
a2.call('city','encounterRun','ground-city-context','/absolute/output/city',
  {[36]=0x1449,[37]=0x0211,[38]=0x0c0e,[39]=0x0709,[40]=147,[41]=115,
   [73]=0x0211,[45]=0x332b,[292]=5,[347]=0},
  {[7]=true,[28]=false,[40]=false,[48]=false,[49]=false,[114]=false},1200)
```

Wait for the completed `R10_PROBE` and city JSON/PNG, then verify scene3 and
the intended map context. Callback counts bound the run; they do not count
source machinery iterations. If an unseeded encounter has already happened,
the Game21 guard refuses the next step; do not treat that state as this fixture.

```lua
a2.call('ready-bp','groundOpcodeBreakpoint',0x1cce)
a2.call('gate-bp','groundGateBreakpoint')
a2.call('run-gate','resume')
```

Retain the returned breakpoint IDs and RNG address, rather than assuming the
IDs or load addresses in the receipt apply to a new session. The helper checks
Game21's trailer/call bytes and locates the unique relocated native RNG entry.
Wait with a host deadline for status `debugger:stop`, then pause. Inspect native
PC and source virtual IP: the retained run stopped at41406/IP38123. Only then:

```lua
a2.call('seed','write',<returned RNG address>,{52,42,0,0})
a2.call('gate-save','groundSourceSave','/absolute/output/gate')
a2.call('gate-clear','clear_breakpoint',<gate breakpoint ID>)
a2.call('chase-go','go')
```

Wait for the owned ready breakpoint, pause, and capture `chase` with
`groundSourceSave`. Its Game21 IP must be segment-base+$1CCE and workspace
mode8. Set `groundOpcodeBreakpoint(0x1df0)`, clear the ready breakpoint, and
`go`. At that stop, pause and capture `caught`; verify kind16/direction3/scene5.
Clear the catch breakpoint and set `groundCombatBreakpoint(0xd66)`. This
resolves the subsequently loaded Game17 trailer on each interpreter dispatch.
Run to the stop, pause and capture `combat-initial`. Verify segment17,
procedure1, actor count6, the actor records and RNG above.

Pause/read receipts between each dependent operation. A scheduled `go` is not
a completed capture; stop on a failed guard or mismatched state. Clear each
owned breakpoint, call `encounterRelease`, exit only the owned process, and
verify `tools/verify_inputs.py` again. The helper reads CPU-visible RAM and
bounded activation records; it does not read I/O or mutate gameplay state.

## Integration consequence

Game21's eligible current scene3 is the **city** map with32-pixel tile height;
scene4 is the world surface. The native gate draws RNG eagerly on each due
ground tick, but combines that result with scene3, foot-mode and local35.
Source procedure26 populates the city region of the40×24 runtime map; assigning
coordinates outside that region is not a valid encounter fixture. Browser
integration must retain these scene/map predicates and the actual system nibble,
rather than attach a substitute probability to every surface movement.
