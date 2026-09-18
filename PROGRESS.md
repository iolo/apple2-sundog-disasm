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

## 2026-09-18 — Step 04d: prove exact p-code assembly and trace an external call

- **Status:** Toolchain proof complete; step 04 remains open for coarse overlay
  tracing through SYSTEM.STARTUP and the remaining native load conventions.
- **Work:** Added source for the first SYSTEM.PASCAL procedure, a checked ca65
  encoding subset, linker configuration, and `tools/build_pcode_probe.py`.
  Added `docs/pcode-toolchain.md` and a 16-stop p-code dispatch trace. Extended
  the evidence verifier to compare those snapshots with original disk bytes.
- **Evidence:** The native dispatch table and operand reader confirm the used
  opcode subset and one-/two-byte variable operands. Captured CXP 4,1 entering
  segment 4 procedure 1 at `$B674`, with segment load base `$B06A`. Its attribute
  pointer and all eleven sampled instruction windows agree with disk block 264.
- **Validation:** `python3 tools/build_pcode_probe.py` assembles 36 bytes exactly
  from editable source, including label-based branches, jump-table pointer, and
  attributes. SHA-256 is
  `ef70020a699c0a1201d839a50e0cf38a7c8fe4c69971c0a68b621ce38c3cdfc3`.
  `python3 tools/verify_runtime_evidence.py` verifies the five earlier capture
  ranges and all 16 dispatch snapshots. Original hashes and whitespace checks
  pass. Assembly reads no original image; the separate comparison does.
- **Decision:** Use ca65 macros for explicit p-code instructions and metadata,
  plus native ca65 assembly, preserving operand widths and relocation records.
  The include is deliberately a tested subset, not a complete UCSD assembler.
- **Remaining:** Full p-code decoding, native relocation records, startup/overlay
  load trace, source-to-disk integration, and the rest of PLAN.md. This small
  procedure proof does not satisfy the step-05 full-image build requirement.
- **Next action:** Trace the coarser segment-load path into SYSTEM.STARTUP,
  close the step-04 architecture gate, and reconstruct the bootstrap for step 05.

## 2026-09-18 — Step 04e: confirm startup and library loading; close architecture gate

- **Status:** Step 04 complete at the architecture/tool-selection level. Detailed
  module reconstruction, relocation decoding, and later gameplay overlays remain
  explicit work for steps 06–09, not completed source coverage.
- **Work:** Recorded 12 whole segment loads and the first SYSTEM.STARTUP p-code
  entry in `docs/reference/overlay-loads.json`. Added
  `docs/runtime-architecture.md` and extended the evidence verifier.
- **Evidence:** SYSTEM.STARTUP loads 576 bytes from block 141 at `$B2B4` and
  enters procedure 1 at `$B49C`, with attribute pointer `$B4E4`. Subsequent
  loads cover library segments 22–28. Segment 22 reloads at a different address,
  confirming that fixed-address-only disassembly cannot describe its runtime use.
- **Validation:** `python3 tools/verify_runtime_evidence.py` compares all 29,830
  new captured load bytes with the disk sources, verifies table-derived block,
  length, destination, successful read status, and startup pointer relationships.
  All previous evidence checks and original hashes remain valid.
- **Decision:** Proceed with ca65 native source and verified p-code encoding
  macros, keeping relocation structures, embedded data, and unexplained regions
  distinct. The full module and asset coverage gate remains step 06/07 work.
- **Next action:** Step 05: reconstruct the three-page bootstrap, integrate the
  source-built components with explicitly temporary remaining bytes, verify both
  full disk hashes, and run the reconstructed images through the play reference.

## 2026-09-18 — Step 05: exact source-component-to-disk build

- **Status:** Complete. This is the planned minimal integration proof, not the
  completed PRD reconstruction; temporary executable and asset bytes remain.
- **Work:** Reconstructed the 768-byte native bootstrap with ca65, separating
  instructions, text, tables, padding, and unreferenced tail bytes. Integrated it
  and the 36-byte p-code entry into `reconstruction/manifest.json`. Added build,
  comparison, initial extraction, and boundary-test tools, plus usage/coverage
  documentation. Every remaining byte is explicitly `temporary-unresolved`.
- **Build validation:** `python3 tools/build_disks.py` followed by
  `python3 tools/verify_disks.py` produces and compares both complete 143,360-byte
  images exactly. Source-built component coverage is 804 bytes; the remaining
  285,916 bytes are temporary. An isolated tree without the original disks builds
  identical outputs from the committed source and temporary components.
- **Failure checks:** Three reconstruction tests pass. A deliberately flipped
  byte at `$00E07` is rejected with exit code 1 and the correct sector/block and
  bootstrap component diagnostic. Gaps, overlaps, truncations, invalid slices,
  missing inputs, and escaping input paths are covered by the tests.
- **Behavior:** Rebuilt media pass the MAME `game-play.json` sequence. All six
  screenshots match the original reference byte for byte, including play-side
  swap, ship interior, and personal status. Disposable media hashes remain
  unchanged. Evidence is in `docs/reference/step05-build-validation.json`.
- **Integrity:** Original input hashes and `git diff --check` pass. The normal
  build does not read originals or rerun extraction. Binary inputs are explicitly
  temporary and include unreconstructed code; they are not presented as assets.
- **Next action:** Step 06: replace temporary executable regions module by module,
  starting with the remaining early native component and interpreter, then
  expanding p-code/source coverage and preserving native relocation records.

## 2026-09-18 — Step 06a: reconstruct the early title routine and scanline tables

- **Status:** First step-06 module checkpoint complete; overall executable
  reconstruction remains in progress.
- **Work:** Added `src/native/title_draw.s` and its linker configuration for
  `$4000`–`$43FF`: 528 instruction bytes, two 192-byte scanline tables, and
  112 explicitly unreferenced tail bytes. Integrated the assembled prefix into
  the manifest and removed its 1,024 bytes from the temporary disk-1 component.
  Documented the routine and its limits in `docs/title-draw.md`.
- **Evidence:** Its full containing load was already captured at `$4000` in
  step 04a. Both scanline tables exactly match the HGR addressing formula and
  are generated from that formula in source. Native code copies bitmap strips
  from `$4400` to page 1, expanding to the full 40-byte by 192-line display.
- **Validation:** The entire 1,024-byte prefix assembles exactly. The full build
  and comparison commands reproduce both baseline hashes and byte equality.
  A new MAME play run matches all six reference screenshots byte for byte and
  leaves disposable media unchanged. Evidence is in
  `docs/reference/step06a-build-validation.json`. Whitespace checks pass.
- **Coverage:** 1,828 output bytes now come from assembled source; 284,892 remain
  temporary. Source totals include owned data, not just instruction bytes.
  The 8 KB bitmap region and its HGR holes remain temporary pending step 07.
- **Next action:** Continue step 06 with the banked native interpreter/I/O
  modules, expanding source and relocation coverage without treating tables or
  preserved unknown bytes as decoded instructions.

## 2026-09-18 — Step 06b: reconstruct the native p-code primitive bank

- **Status:** Module checkpoint complete; step 06 remains in progress.
- **Work:** Added `pcode_primitives.s`, its linker configuration and typed da65
  recipe. Reconstructed the complete alternate bank plus shared `$E000`–`$E0E4`
  continuation: 2,146 instructions (3,899 bytes) and 426 table/data bytes.
  Preserved the self-modifying dispatch operand and the instruction crossing
  `$DFFF`/`$E000`. Added the module to the disk build and removed 4,325 temporary
  bytes. Detailed boundaries are in `docs/pcode-native.md`.
- **Automation:** Added `tools/adopt_component.py` to assemble and validate new
  source replacements before updating the manifest/remainder. Three tests cover
  scattered bank mappings, wrong/stale bytes, omissions, overlaps, out-of-bounds
  slices, and refusal to replace already reconstructed ranges.
- **Structural validation:** `python3 tools/check_pcode_native.py` verifies all
  code spans and 555 direct/vector targets. A deliberately corrupted vector into
  an operand byte is rejected. Masks match formula-generated tables exactly.
- **Build/behavior:** Both complete disk images remain byte-identical. New MAME
  play and utility runs match all ten reference PNGs; final media hashes match
  the original runs, including expected utility-side writes. Reports are in
  `docs/reference/step06b-native-audit.json` and `step06b-build-validation.json`.
  Original hashes and whitespace checks pass.
- **Coverage:** 6,153 source-built output bytes; 280,567 still temporary. The
  ten-byte descriptor at `$D1AD` is explicitly preserved with unresolved field
  meanings, not presented as executable instructions or fully explained data.
- **Next action:** Reconstruct bank-2 disk I/O and the remaining shared native
  runtime, retaining self-modifying operands and separating lookup tables.

## 2026-09-18 — Planning checkpoint: review the step-by-step plan

- **Status:** Planning review complete; implementation status is unchanged.
- **Work:** Reviewed `PRD.md` and `PLAN.md`. Retained the eleven ordered steps,
  acceptance criteria, and mandatory progress-log-and-commit rule for every
  step and substep. Updated stale repository assumptions to reflect working
  Git, the corrected disk roles, and the recorded step-06 checkpoint.
- **Validation:** Compared the plan with the PRD's required source, asset, and
  byte-identical build outputs and optional documentation/mechanics scope.
  Checked Git history and existing progress entries; `git diff --check` passes.
- **Next action:** Follow the remaining implementation steps in `PLAN.md`,
  beginning with the next step-06 module checkpoint.
