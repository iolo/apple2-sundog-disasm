# Ship movement and clean-character evidence — R04b / R05a

## Clean character

`docs/reference/remake-new-character.json` replays a complete new-character
creation on a disposable disk copy in MAME 0.285, Apple IIe, joystick. It empties
slot 0, starts a new character, enters `A`, confirms default attributes without
spending points, then leaves utilities so the descriptor is written. The runner
checks both original disk hashes and the manual before and after execution.

The successful run's screenshots show 30/30/30/30/0, 440 points, and a new game
named A at Jondd. `docs/reference/remake-clean-character.json` preserves the
5024 classified state bytes, descriptor, checksum and screenshot hashes. Both
stored and computed ten-block checksum are `$FD5A`. The 96-byte tail is excluded
from the state fixture. The save records x=54, y=110. The remaining budget is not
part of the saved character: accepting the warning permits unspent points.

This is a reference fixture, not a browser world template. Generated equipment,
world tables and random values still require named semantics before campaign
initialization can be considered implemented. Reproduce with:

```sh
python3 tools/reference_mame.py docs/reference/remake-new-character.json \
  --rompath /path/to/roms --mame /usr/games/mame
```

The interactive research run also returned to play. That path resumed the
already-being-played slot, rather than the newly created slot: its runtime
attributes and coordinates differed from A. The movement observations below
therefore apply to the existing ship session, separately from clean creation.
Neither observation is misrepresented as a clean-character ship playthrough.

## Movement and collision source

- `game_15.s` procedure 11, `$05C7–$05DD`, case 11 in `$062A–$0648`, preserves
  the initial coordinates from globals. `$069E–$06A3` selects visible glyph12
  and collision glyph13. `$06AF–$06B0` selects background color/pattern 8.
- Procedure13, `$070C–$0720`: target anchor is cursor `(x−3,y+3)`.
  `$072B–$0767` limits signed displacement to two pixels per axis, or less
  when close to the target. `$077C–$078A` attempts movement; `$078D–$07B2`
  retries with signed one-pixel steps only if neither coordinate changed.
- `library_22.s` native procedure22, `$14FE–$15C2`, XOR-erases the current
  visible glyph, tries diagonal, horizontal, then vertical motion, and redraws.
  A successful trial discards its return address at `$1581–$1582`, updates the
  coordinates, and jumps to redraw at `$159F`; it does not apply all three steps.
- Native procedure9, `$1376–$14C5`, chooses collision mode 2 and reads the
  glyph at the active text-bank pointer. Native global `$02C6` corresponds to
  p-code word356: the native relocation base is the data segment base plus 2.
  Startup7 procedure7 reloads shared font bank0 at `$03AE–$03B3`.
- Glyph rows are read in reverse storage order, seven low bits per row, with
  anchor `(x,y−7)`. Glyph12 is `[0,0,8,28,28,8,0,0]`; glyph13 is
  `[0,0,62,62,62,62,0,0]`. Thus the collision footprint is x+1 through x+5,
  y−5 through y−2, not the visible diamond or the full seven-by-eight cell.
- At `$13AA–$13CF`, background pattern8 reads `$80` from both phase tables
  (`$163E/$164A`) and complements it to `$7F`. `$1470–$14BC` tests occupied
  screen bits under the shifted mask. High phase bits and HGR memory holes do
  not obstruct walking. The source page's low bits are therefore legitimate
  collision data in this scene, exported separately from its decorative SVG.

## Runtime comparison

`docs/reference/remake-ship-movement.json` records mapped HGR captures from the
owned interactive MAME session. The active font pointer was `$1000`. The initial
page differed from the stored full-ship page in exactly 16 low-bit pixels:
eight player pixels at anchor `(50,99)` and eight pointer pixels. No additional
station overlay changed collision in that captured scene.

After aiming joystick `(0,128)`, the pointer was `(3,81)`. A 30-frame primary
hold stopped the player at `(47,93)`. The browser rule converges to that same
endpoint through `(48,97)`, `(48,95)`, `(48,93)`, `(47,93)`. Only the endpoint,
initial state and pointer were observed; intermediate positions are derived.
The final one-pixel retry is required to reach x=47. Both post-aim and post-move
HGR differences consist solely of the expected player and pointer masks.
The original disks were never mounted writable; only disposable copies changed.

## Browser walkthrough boundary

R05a exposes movement on the complete ship outline. Pointer/touch hold moves,
release stops, and arrow keys use the same collision rule. The gold ring makes
the small original sprite visible; it has no collision effect. A 50 ms fixed
movement cadence is a presentation choice, not a claim about original timing.
Hidden/unfocused windows pause; resume is explicit; delayed frames have bounded
catch-up. Walking advances no campaign clock or character condition.

Procedure14 (`$07CC–$08A1`) maps anchor cells to interaction IDs. The browser
recognizes these regions and reports reaching a station. R05b adds locker/store
transfers at IDs5/6; see `inventory.md`. IDs3/4 have the original landed-location guard. Walking uses the
landed full-ship case; partial-ship movement is not exposed. On the full ship,
1784 one-pixel-connected clear anchor positions are reachable from `(54,110)`.

R05c adds personal condition and food/rapidheal use; see `condition.md`.
Other ship systems, exits, other consumables, sleep, combat, and campaign saves are
still pending. Walkthrough position, inventory and condition are ephemeral and survive opening/closing
the screen within the page, but not reload. Character drafts remain separate.
