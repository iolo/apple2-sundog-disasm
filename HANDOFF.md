# Successor handoff — 2026-10-20

## Web remake: limited color palette

- `tools/remake/export_assets.py` restores source parity/phase colors for ship,
  title, tiles, item icons and room artwork. `color_rows()` uses four hues plus
  ivory; it does not simulate NTSC blur or shift artwork coordinates. Moving
  sprites remain ivory. Regenerate SVGs with the exporter, not manual recoloring.
- Room artwork uses a separate composition with full native pattern bytes.
  Gameplay/collision JSON still uses low-seven-bit rows and remains unchanged.
  Keep the ship SVG's explicit dimensions and `preserveAspectRatio="none"`.

## Web remake: overlapping windows

- Walking now draws the 280×192 world at 560×384. Room interiors are 280×192
  windows over the saved city camera, including after loading an interior save.
  `walkingBounds()` in `ship-walk.js` supplies both canvas projection and the
  walking surface's inline bounds. Do not introduce separate CSS/input offsets.
- Inventory is a compact window. Storage replaces the personal-condition view;
  the condition meters and explanatory text remain in the inventory info popover.
  Counter/shop/tavern conversations share the same window header and border,
  with an undimmed backdrop and instructions behind ⓘ. Conversation content
  scrolls separately so the header and actions stay reachable. Sound, language
  and the clock stay outside these windows; do not inject duplicate settings
  into `.pixel-window` dialogs.
  `ui/info.js` owns dismissal/focus handling; opening info pauses the game.
- UI smoke pointer helpers should derive coordinates from `#walk-surface` and
  the scene's native dimensions, rather than hardcoding the old stage offsets.
  `ship_hotspots_smoke.js` also checks retained city pixels behind room windows.

## Web remake: Firefox compatibility and hotspot hints

- The user's `/usr/bin/firefox-devedition` (159.0b3) padded the ship SVG inside
  the canvas destination: source 280×192, destination 640×384. Chrome did not.
  This changed the artwork's X scale relative to collision and hotspot coordinates.
- The same padding affected the Cities/Worlds previews. The exporter now applies
  explicit dimensions and `preserveAspectRatio="none"` to ship and tile SVGs.
  Dimensions alone did not fix Firefox. `render/scene.js` also snaps shared tile
  edges to backing pixels to avoid thin seams at fractional display scales.
  Keep the generator and generated assets/provenance in sync;
  do not compensate by shifting pointer coordinates or changing collision data.
- The approved amber hints use reachable player-centre coordinates (`+3, −3`).
  Preserve the `!campaignMode || campaignStart` guard when drawing them: main-menu
  Saved games renders a ship background before any campaign exists. Reading its
  location caused an exception that blocked Saved games and left Resume broken.
- Serve `remake/` over HTTP and open `/tests/` in **Firefox Dev Edition and Chrome**.
  `remake/tests/ship-stations.js` checks native source coverage and stretched
  artwork; color fills between patterned dots are separate from collision bits.
  `remake/tests/tile-rendering.js` checks all 85 tiles at preview/gameplay sizes
  and verifies continuous opaque terrain at fractional display scales.
  `tools/remake/ship_hotspots_smoke.js` checks cold-start Saves, Resume and overlapping windows.
- Validation: 543 browser checks passed in Chrome and Firefox Dev Edition159.0,
  including all tile banks and fractional-scale seams. 25 exporter tests passed
  and `python3 tools/remake/export_assets.py --check`
  verified 175 artifacts. Use disposable browser profiles; the user's saves are
  browser-local. This was not an exhaustive Firefox campaign playthrough.

## Historical reconstruction handoff — 2026-09-25

The following completed reconstruction scope predates the authorized remake work.

The user has asked to stop work and leave optional follow-ups to a successor.
The required goal is complete under the revised acceptance criteria. Do not
restart investigation or optional implementation without a new user request.

## Current state

- Final delivery checkpoint: `a33a4a1` (step 10b).
- User data exception: `edf3188` (step 08ac).
- Both disks rebuild exactly; no temporary reconstruction inputs remain.
- Coverage: 136,686 code bytes, 149,546 evidenced data bytes, and **488 bytes
  explicitly accepted by the user as unidentified data**. The latter are an
  assumption, not a proved code/data classification. Preserve their exact bytes.
- The goal tracker was marked complete. Steps 01–10 are complete; step 11 is
  optional. Some historical progress entries are out of chronological order
  and contain obsolete next actions. Use the current documents below.

Start with [delivery-checklist.md](docs/delivery-checklist.md),
[classification-ledger.md](docs/classification-ledger.md), and
[user-assumed-data.md](docs/user-assumed-data.md). Source and asset navigation
are in [src/README.md](src/README.md) and [assets/README.md](assets/README.md).

## Validation already completed

- 180 regression tests pass. The complete ledger integrates 166 components and
  checks 404 proof files.
- Two isolated strict builds without original disks, the manual or prior build
  products produce identical images and reports. The complete ledger also
  passes in that isolated tree.
- Final review replayed 15 data audits and 17 asset/script verifiers. Eight
  freshly extracted asset groups reproduce 53 delivered files exactly.
- Step **09a**, `3d5f194`: [MAME save/fresh reload](docs/save-reload-validation.md).
- Step **09b**, `5a40133`: [Apple2TS gameplay, swaps, utilities and save/fresh
  reload](docs/apple2ts-behavior-validation.md).
- Final output bytes equal those exercised by these emulator baselines. No
  fresh final emulator run was claimed. Combat, travel, all utility mutations,
  audio fidelity and synchronized timing were not exhaustively tested.

If verification is needed for new work, the entry points are:

```sh
python3 tools/build_disks.py --no-temporary
python3 tools/verify_disks.py
python3 tools/classification_ledger.py --require-complete
python3 -m unittest discover -s tools
```

Full audits require Python 3.10+ and ca65/ld65 on PATH. Build outputs are under
`build/disks/`. Disk 1 is the title/utility/save side; disk 2 is the play side.
Use disposable media copies for emulator work. Receipts and exact hashes are
linked from the delivery checklist; do not rely on ephemeral `/tmp` files.

## Optional directions discussed, not commissioned

1. Extract and document a reusable Apple Pascal p-code toolkit. The decoder is
   `tools/pcode_source.py`; assembler support is `src/pcode/encoding.inc` using
   ca65 macros. Supported dialects are limited, and repository dependencies
   need separation. No new portable p-code interpreter was implemented: the
   interpreter artifact is reconstructed original 6502 runtime source.
2. Consolidate navigation and distinguish reusable tools from one-off research
   scripts. Keep historical evidence, but make current usage easy to find.
3. Add a concise architecture guide and an understandable end-to-end game
   modification, with meaningful names and relevant validation.
4. Extend behavioral tests where a future change needs them. This is optional
   coverage expansion, not an unfulfilled claim about the completed baseline.

The 488-byte investigation consumed disproportionate time and tokens. Its
history is in [unresolved-tails.md](docs/unresolved-tails.md). The user explicitly
ended that required research. Do not repeat exhausted searches. For any future
uncertain investigation, agree a bounded scope, use a time/attempt limit, and
surface diminishing returns before spending substantially more resources.

## Preserve user work and checkpoint discipline

At handoff, `PRD.md` has two pre-existing unstaged reference links, and `ref/`
is user-owned and untracked. Both were deliberately preserved and excluded
from our commits. Do not clean, overwrite or stage them incidentally.
The original DSKs and `sundog.pdf` are unchanged validation references.

For any newly authorized work: validate the step, update `PROGRESS.md`, and
commit that checkpoint before starting the next step. No new work is running
as part of this handoff.
