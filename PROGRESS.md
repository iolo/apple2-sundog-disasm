# Progress log

Every implementation step must update this file and commit its changes together
with the log update before the next step begins. See `PLAN.md` for the full rule
and acceptance criteria.

## 2026-09-18 — Planning checkpoint

- **Status:** Plan prepared; implementation has not started; commit blocked.
- **Work:** Read `PRD.md`, checked the available inputs and repository state, and
  created `PLAN.md` with ten required steps and one optional documentation step.
- **Validation:** File listing confirms both disk images and `sundog.pdf` exist.
  Both disks are 143,360 bytes. No repository `AGENTS.md` was found in the checked
  locations. `git status --short` fails with `not a git repository`; `.git` is
  empty and read-only in this workspace.
- **Discrepancy:** The actual second input is `sundog-disk2-util.dsk`; the PRD
  lists `sundog-disk2-game.dsk`. Its role is not yet verified.
- **Artifacts:** `PLAN.md`, `PROGRESS.md`.
- **Blocker:** A usable, writable Git checkout is required before this planning
  checkpoint can be committed or the per-step commit workflow can begin.
- **Next action:** When implementation is requested, resolve step 01's Git
  prerequisite, commit this checkpoint, and establish input hashes and structure.

## 2026-09-18 — Planning checkpoint committed

- **Status:** Git prerequisite resolved; implementation authorized by the user.
- **Evidence:** `.git` is now writable and `git status --short` succeeds. The
  inspected `main` branch has no commits yet, so this checkpoint establishes the
  initial commit, including the original inputs and planning documents.
- **Next action:** Step 01: create and verify the input manifest and project layout.

## 2026-09-18 — Step 01: input baseline and layout

- **Status:** Complete.
- **Work:** Recorded all three original inputs in `inputs.json`, added
  `tools/verify_inputs.py`, established `src/`, `assets/`, `docs/`, and ignored
  generated `build/` output. Corrected the second filename in `PRD.md` and
  documented that its actual behavior remains unverified.
- **Validation:** `python3 tools/verify_inputs.py` passes for both 143,360-byte
  disks and the 1,302,733-byte PDF. `git diff --check` passes. Git prerequisite
  proved by the successful planning commit `f116cc9`.
- **Next action:** Step 02: inventory tools, boot disposable disk copies, and
  establish manual-backed reference interactions.

## 2026-09-18 — Step 02a: tools, manual, and initial boots

- **Status:** Partial step 02 checkpoint; playable reference still in progress.
- **Work:** Inventoried tools in `docs/toolchain.md`, visually read manual pages
  7–10 into `docs/manual-notes.md`, and captured initial apple2ts screens under
  `docs/reference/` using disposable media copies.
- **Evidence:** Private apple2ts boots the game disk to a Version 2.0 title with
  a NUTCRACKER credit. A separate fresh utility-disk session reaches Flip Disk.
  MAME 0.285 runs with local verified Apple IIe ROMs and scripted joystick input.
  Neither disk catalogs with a2kit 4.4.2 (`FileSystemMismatch`).
- **Validation:** MAME's `-verifyroms apple2e` succeeds with the documented local
  ROM path. `python3 tools/verify_inputs.py` verifies originals. Exploratory
  MAME sessions changed their disposable game copy, showing that every reference
  run must begin with fresh copies rather than reuse a prior session's media.
- **Remaining:** Establish repeatable play and utility sequences, isolate each
  run's media/configuration, and verify observed disk swaps before completing 02.
- **Next action:** Implement and run the isolated MAME reference harness.

## 2026-09-18 — Step 02b: reproducible playable reference

- **Status:** Step 02 complete, with emulator differences documented.
- **Work:** Added `tools/reference_mame.py` and three frame-indexed input
  sequences. Captured and visually inspected title/menu, play-side swap prompt,
  ship interior, personal status, utility slots, and disk-2 cold boot screens.
- **Finding:** Disk 1 contains title/menu and utilities; disk 2 is the play side.
  Preserved filenames and corrected observed roles in the manifest and docs.
  Utilities display four slots, unlike the manual's eight-slot description.
- **Validation:** All three reference scenarios run in MAME 0.285, produce the
  requested screenshots, and verify the originals before and after. Gameplay
  responds to button 1 by opening personal status. Utility entry changes only
  its disposable disk-1 copy. `git diff --check` passes.
- **Limitations:** apple2ts title and disk-2 cold boot verified, but its private
  MCP controls lack joystick input. Full gameplay there and save/load validation
  remain for step 09. MAME's automatic title advance remains unexplained.
- **Next action:** Step 03: map sectors and custom disk structures, preserve all
  bytes in a reversible extraction, and investigate the utility-side write.

## 2026-09-18 — Step 03: sector map and exact container reconstruction

- **Status:** Complete at the initial classification level required by this step;
  unresolved content remains explicitly labeled for steps 04–07.
- **Work:** Added `tools/disk_layout.py`, generated a full sector/track inventory,
  extracted four Pascal directory views and their file extents, and documented
  the mapping and findings in `docs/disk-layout.md` and its JSON summary.
  Added `--image-dir` to the MAME harness to test reconstructed images.
- **Evidence:** Disk 1 directory views are at logical blocks 79–82, not block 2.
  a2kit independently extracts the same 40,448-byte SYSTEM.STARTUP when a
  directory is placed at block 2 in a disposable image. All six entries in the
  primary directory are retained by our parser, including SYSTEM.PASCAL.
- **Validation:** `python3 tools/test_disk_layout.py` passes three tests covering
  mapping completeness, known directory/loader anchors, and rejection of corrupt,
  overlapping, or escaping track records. Unpack/pack reconstructs both original
  hashes; both `cmp` checks pass. Repacked disks run the full game-play reference
  sequence; all six PNGs match the original run byte for byte. `git diff --check`
  passes, and originals retain their baseline hashes.
- **Utility writes:** Recorded the 30 changed bytes in
  `docs/reference/utility-entry-writes.json`: 26 in directory block 79 and four in
  block 83. The four-byte field's meaning is unresolved.
- **Limitations:** This repacker uses extracted raw tracks, so it is not a source
  build. Disk-2 file boundaries, runtime directory selection, executable coverage,
  p-code dialect, and asset formats still need investigation.
- **Next action:** Step 04: trace boot and runtime disk reads; identify the native
  interpreter, p-code files/segments, memory layout, and directory remapping.

## 2026-09-18 — Step 04a: confirm bootstrap and native runtime loads

- **Status:** Partial step 04 checkpoint; architecture investigation continues.
- **Work:** Followed apple2ts breakpoints at `$08FF`, `$4000`, `$FEF2`, and bank-1
  `$D152`. Recorded captures and load parameters in
  `docs/reference/boot1-at-reader.json`, and documented reproduction and memory
  mapping in `docs/bootstrap.md`.
- **Validation:** The three-page bootstrap matches original disk sectors except
  its runtime count byte (1 → 5). The entire 9,216-byte `$4000` component matches
  blocks 201–218. The primary 12 KB and alternate 4 KB language-card banks match
  SYSTEM.APPLE exactly before interpreter initialization. All expected breakpoint
  stops were confirmed by the emulator. No CPU/memory patches were used.
- **Investigation note:** Exploratory MAME memory taps returned empty logs and
  were removed; they provide no trace evidence. Read the UCSD cross-tool source
  for code-file metadata, but have not yet established a compatible p-code
  dialect or build tool.
- **Remaining:** Runtime disk-service tracing, directory remapping, complete
  native/bytecode module inventory, runtime patches, and p-code reconstruction
  strategy. Step 05's minimal source build has not started.
- **Next action:** Continue from bank-1 `$D152`, identify its disk-read path and
  parse the segment dictionaries of the extracted files.

## 2026-09-18 — Step 04b: trace initialization through the first p-code entry

- **Status:** Partial step 04 checkpoint; module inventory and bytecode tooling
  remain unfinished.
- **Work:** Continued the live apple2ts session through five initialization
  breakpoints. Added `docs/reference/runtime-init.json`, expanded
  `docs/bootstrap.md`, and added `tools/verify_runtime_evidence.py`.
- **Evidence:** Initialization relocates to `$6800`, explicitly reads directory
  block 79, then loads the SYSTEM.PASCAL header from block 251. Its two initial
  code parts load at `$BC72` and `$F248`; the first p-code pointer is `$F248`.
  Recorded initialization erasure and the dispatcher's self-modifying operand.
  Segment version 5 is required by an explicit native comparison.
- **Validation:** `python3 tools/verify_runtime_evidence.py` verifies all 5,598
  captured source bytes against the disk images. Original input hashes and
  `git diff --check` pass. No CPU/register/memory edits were used in the emulator.
- **New lead:** The startup header's later segments have valid procedure tails
  on disk 2 at the same absolute block addresses, including entries beyond the
  disk-1 directory extent. A file-boundary-only extractor would miss them.
- **Next action:** Step 04c: implement a bounded segment/procedure inventory
  across both disks, preserving unresolved entries and split-system references.

## 2026-09-18 — Step 04c: inventory Pascal segments and procedure boundaries

- **Status:** Partial step 04 checkpoint. Structural boundaries established;
  instruction dialect/reconstruction and runtime overlay tracing remain.
- **Work:** Added `tools/pascal_inventory.py`, four boundary/corruption tests,
  `docs/pascal-inventory.json`, and `docs/pascal-segments.md`. Scanned all 560
  logical blocks across the two disks and retained eight header candidates.
- **Results:** Found 42 valid segment occurrences (34 distinct payloads), with
  597 p-code and 41 native procedure entries in the distinct segments. Eleven
  startup entries point to valid segments on disk 2 despite failing locally on
  disk 1. Block 84's candidate remains unresolved. DATASEG allocations and unused
  slots with metadata are explicitly separated from stored executable payloads.
- **Split system:** Resolved SYSTEM.PASCAL procedure 38 through the captured
  `$F248`/`$BC72` memory mapping. Header slot 15 holds this procedure fragment,
  not an independent segment. Without the mapping the parser flags the pointer.
- **Validation:** `python3 tools/test_pascal_inventory.py` passes four tests
  covering scanned anchors, wrong-side extents, native procedures, split pointers,
  and rejection of corrupt counts/offsets/metadata. Regenerating the inventory
  produces identical JSON. Original hashes and `git diff --check` pass.
- **Limitations:** These are procedure boundaries, not decoded instructions;
  standalone native loaders and runtime are outside the procedure totals.
- **Next action:** Step 04d: validate the bytecode instruction format against
  the native dispatch table and prove an exact reassembly approach; then finish
  the architecture gate before step 05's minimal source-to-disk build.
