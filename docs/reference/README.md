# Reference behavior

## Reproduce

```sh
python3 tools/reference_mame.py docs/reference/game-play.json --rompath /path/to/mame/roms
python3 tools/reference_mame.py docs/reference/game-utilities.json --rompath /path/to/mame/roms
python3 tools/reference_mame.py docs/reference/utility-boot.json --rompath /path/to/mame/roms
```

The harness uses MAME 0.285's `apple2e`, its default slot-6 Disk II controller,
default RAM configuration, and `-gameio joy`. Each invocation creates a new
directory in `build/reference/` with fresh disk copies, its exact command,
sequence, generated Lua, screenshots, log, and final media hashes. Originals are
verified before and after. All media swaps take place in drive 1; drive 2 is
unused. The script reports missing screenshots or process failures but does not
claim that screenshot existence proves the game behaved correctly: images must
be inspected or compared with the checked-in references.

Frame numbers count frame callbacks after the autoboot script is installed.
Execution is unthrottled, but inputs are scheduled by emulated frames. Joystick
button 0 maps to MAME `P1 Button 1`; button 1 maps to `P1 Button 2`. Axis values
are MAME analog input values, not screen coordinates. Sound is disabled for
these reference runs.

## Verified workflow and disk roles

The original filenames are misleading for this pair of images:

| Original input | Observed role |
| --- | --- |
| `sundog-disk1-game.dsk` | Boots the title/menu; contains the utility program and stored game slots |
| `sundog-disk2-util.dsk` | Play side; swap into drive 1 after selecting Play SunDog on disk 1 |

1. Boot disk 1 with centered joystick. In MAME the title proceeds to the menu
   before the first scripted button press; apple2ts instead waits on the title's
   joystick-button prompt. This startup difference has not yet been explained.
2. Select Play SunDog at analog position `(170, 175)` with button 0. The program
   explicitly asks for the PLAY SIDE. See `mame-play-side-prompt.png`.
3. Mount disk 2 in the same drive and press button 0. The program loads the ship
   interior (`mame-ship-interior.png`). Pressing button 1 opens personal status
   (`mame-personal-status.png`), establishing actual interaction after loading.
4. In a separate fresh run, select Use utilities at `(185, 190)`. No swap is
   required: disk 1 loads the utility program (`mame-utility-slots.png`). The
   screen displays four slots numbered 1–4, with slot 2 Being played and the
   other three Suspended. This differs from the manual's eight-slot description.
5. Booting disk 2 directly displays a Flip Disk icon in both emulators. It does
   not directly start the full game or utility interface.

The game-play sequence leaves both working copies byte-identical. Entering
utilities changes the working copy of disk 1 (observed SHA-256
`dcc610d358e22007c787d8390d51aae05c8c286640fd16af8233ee53392791c1`).
The cause and modified regions remain to be analyzed; the original is intact.

## Scope and limitations

The checked-in emulator images were visually inspected. Original Apple2TS
captures established title rendering and disk-2 cold boot. Its private MCP
interface has no joystick axes/buttons, so step 09b uses a separately owned
browser and its normal Gamepad API input path for gameplay.

Step 09a adds a [MAME save and fresh-process reload](../save-reload-validation.md).
The four initial reference screens match exactly and the saved bank checksum
verifies. Step 09b adds [Apple2TS save/reload and utility navigation](../apple2ts-behavior-validation.md)
with a valid exported saved-bank checksum and a separate browser-process reload.
See `game-save.json`, `mame-save-reload.json`, and `apple2ts-save-reload.json`.
Model, timing and rendering differences are recorded; synchronized cross-emulator
pixel equality or complete gameplay coverage is not claimed.

These observations do not identify an unmodified commercial release.
Starting/deleting games, combat, travel, sound, and long-running behavior have
not yet been validated. Original state may contain prior players' saved games.
