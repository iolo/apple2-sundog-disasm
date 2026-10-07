# Original-game encounter evidence — R10b

MAME0.285, unenhanced Apple IIe and the project joystick profile were used in
an owned headless console. Both supplied disks were verified before and after
the session; only copies were mounted. The existing being-played slot was
resumed using `docs/reference/game-play.json` through frame18000. This is a
controlled original-game reference, not a naturally generated encounter or a
fresh-game acceptance journey.

## Observed space encounter

[Metadata and capture hashes](../reference/remake-space-encounter.json) describe
the scope and all six raw artifacts. The [contact screenshot](../reference/remake-space-contact.png)
shows the cockpit with an identified target and its hull meter; its
[RAM receipt](../reference/remake-space-contact.json) records the declared setup
and resulting native state. The fixture explicitly writes enemy type1,
health200, coordinates512/512, range127 and source encounter flags40/41, then
requests the cockpit through scene1. Equipment, inventory and the existing
campaign are retained from the supplied save.

A joystick probe at x25/y15 with primary held30 frame callbacks opens the
enemy Comm window. The raw [input receipt](../reference/remake-space-input.json)
retains its original experimental name `tactical-select`: the observed result
was Comm, so it is not evidence of tactical aiming. After600 further callbacks,
the [conversation screenshot](../reference/remake-space-dialogue.png) shows the
enemy's demand and Agree/Refuse/Dismiss It choices. Its
[RAM receipt](../reference/remake-space-dialogue.json) verifies dialogue scene9,
workspace kind9, enemy level2 and active encounter flag40. The screenshot was
visually inspected. No dialogue choice or shot was executed in this reference.

These observations satisfy the space-observation portion of R10's evidence
gate. They do not verify natural production, exact native RNG continuation,
damage formulas, the zero-output pointer defeat, any negotiation outcome or
browser timing. The R10a arithmetic vectors remain source-derived. Frame
callback durations bound the probes; they do not establish cycle-equivalent
simulation timing or an exact count of source machinery ticks.

## Ground observation — R10d

An earlier controlled scene3 setup drew the city map with an off-map actor
position; it was initially described as surface terrain.
Changing directly to scene5/kind16 without Game21 proc40's chase/window
preparation produced an invalid striped encounter window. That probe is
excluded from passing evidence and its helper was removed. R10d now follows
the actual Game21 gate/chase/catch in a corrected city-foot
fixture and captures six Game17 actors. All packed actor records and final
native RNG match browser initialization. See the
[ground reference](ground-encounter-reference.md) for ten hashed captures,
reproduction and scope. The controlled ground observation gate is met; live
avoid/fight/lose and native damage/outcome evidence remain open.

## Reproduction

Run `python3 tools/remake/encounter_bootstrap.py --output-dir <new directory>
--rompath <local ROM directory>` in a persistent terminal. The tool verifies
original media, copies disk2, generates the existing frame-indexed boot inputs
and calls the installed a2-mame skill launcher. That launcher copies disk1 and
isolates machine output. The bootstrap uses an explicit Apple IIe/joystick
profile; its generated wrapper excludes dynamic joystick options from
`-verifyroms`. `--prepare-only` writes the launch inputs without starting MAME.
The bootstrap and wrapper/ROM verification were checked in this checkpoint.

After `R10_BOOT_PAUSED`, load the skill helper into the console, inspect status
and devices, and load the project probe file. Use absolute paths from the
actual checkout and installed skill:

```lua
a2=dofile('/absolute/a2-mame/scripts/control.lua')
a2.call('status-1','status')
a2.call('devices-1','devices')
dofile('/absolute/project/tools/remake/encounter_reference.lua')
a2.call('contact-1','spaceContact','/absolute/output/space-contact')
```

Send one command at a time and wait for its matching `A2` receipt. A scheduled
probe is not finished until its JSON/PNG files exist and the session is paused.
The callback captures before/setup/after state, declared writes and the final
screen. From that paused contact state, run the recorded joystick probe and
settle the dialogue:

```lua
a2.call('input-1','encounterInput','tactical-select','/absolute/output/space-input',25,15,0,30)
a2.call('settle-1','encounterRun','space-dialogue','/absolute/output/space-dialogue',{},{},600)
a2.call('inspect-1','encounterCapture')
a2.call('release-1','encounterRelease')
a2.call('exit-1','exit')
```

Wait for each probe to finish before the next. The input probe releases both
buttons at its end; `encounterRelease` also clears every touched joystick axis
and button override. Exit only the owned process and rerun
`python3 tools/verify_inputs.py`. Existing save-state helpers may unpause MAME;
re-pause and verify restored memory before any further controlled setup. The
published receipts retain actual native state rather than asserting an exact
replay of RNG or game time across asynchronous host operations.
