# MAME save and fresh-process reload

Step 09a exercises the exact rebuilt images from commit `ede8465` in MAME
0.285, `apple2e`, default slot-six Disk II, and `-gameio joy`. ROM verification
passed. The enhanced `apple2ee` ROM set is unavailable locally, so this is not
a matched-model comparison with Apple2TS. Sound was disabled.

The run used the a2-mame skill launcher and an owned persistent Lua console,
isolated configuration directories, and disposable copies of both rebuilt
images. Inputs were bounded by emulated frame counts, with pauses between
inspection batches. Only joystick inputs and disk mounting changed the game;
there were no CPU/memory patches or emulator save states.

## Observed sequence

1. Boot disk 1, choose Play SunDog, mount disk 2 at the play-side prompt,
   and enter the ship. Button 1 opens personal status. The menu, swap prompt,
   ship interior, and personal-status captures have exactly the same RGB pixels
   as the four existing MAME reference images.
2. In personal status, select the disk icon at analog `(88, 65)`. The Save Game
   command is at `(140, 180)`. Select it with button 0. The game requests the
   UTILITY SIDE, which is disk 1 despite its supplied filename.
3. Mount the working disk-1 copy and acknowledge with button 0. Allow disk
   activity and title rendering to finish, then exit the owned emulator to
   flush the image. The game returns to its title animation.
4. Launch a fresh MAME process with a copy of that saved disk. Repeat the
   original play sequence and swap to a fresh copy of the unchanged play side.
   The ship loads and button 1 again opens personal status. Shut down this
   process; both of its disk copies remain unchanged.

The scanned manual's PDF page 8 describes personal status → disk icon → Save
Game. The actual disk-side prompt is recorded in
[the save prompt capture](reference/mame-save-side-prompt.png); the menu is
[also captured](reference/mame-save-menu.png). The fresh reload's
[personal status](reference/mame-saved-personal-status.png) shows the resulting
condition bars. This is a save/reload smoke test, not a claim that every saved
field, travel, combat, or every utility action has been validated.

## Disk evidence

The final disk-1 SHA-256 is
`feab3f940cd18cdea8a306cb8dd6f432e3c14ebc9ce58a3a942256f2c2e23af3`.
Its 98 changed bytes are confined to:

| Logical block | Changes | Existing interpretation |
| --- | ---: | --- |
| 26 | 2 | Slot 1 checksum, descriptor offsets 94–95 |
| 37 | 7 | Slot 1 serialized globals |
| 46 | 89 | Final 96-byte bank tail, replaced with zeros |

The slot's ten-block checksum changes from `$EE29` to `$5851`, matching its
updated descriptor. Slot 1 is the existing Starrion game. The tail write
corroborates the known full-bank save, but does not reclassify original retained
code or unresolved bytes as data. An intermediate on-disk snapshot had 265
changed bytes; it was taken before shutdown flushing and is not the final save.
Disk 2 retains its original hash throughout. The exact per-byte changes,
configuration, comparisons, and reload hashes are in
[mame-save-reload.json](reference/mame-save-reload.json).

## Reproduction

[game-save.json](reference/game-save.json) records all input frames, including
exploratory cursor positions that missed the Save Game button. It extends
`game-play.json`. Frame counts exclude inspection pauses. Use these events in
an owned persistent MAME console with fresh writable media copies and the
configuration above. After shutdown, use the resulting disk 1 as the boot
medium of a second fresh process and replay `game-play.json`, with disk 2
available for the swap. Compare final hashes only after flushing media.

The repository's `tools/reference_mame.py` accepts both sequence formats and
`--image-dir` for rebuilt or saved media. The checked-in sequence was recorded
from the console run; a separate unattended replay is not claimed here.

Apple2TS gameplay/save-load, the remaining classification work, and final
integration checks remain outstanding. The original disks and manual were
verified unchanged after both processes exited.
