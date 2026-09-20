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

## 2026-09-18 — Step 06c: reconstruct the native disk/device/console bank

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Work:** Added `src/native/native_io.s`, its linker configuration, typed
  disassembly recipe, and adoption mapping for disk-1 blocks 219–226. The
  complete 4 KB language-card bank contains 1,393 instructions (including three
  intentional BIT overlaps), occupying 2,778 distinct bytes, plus 1,318 bytes
  of tables, initial state, and preserved zero fill. Documented boundaries and
  evidence in `docs/native-io.md`.
- **Reconstruction:** Preserved ten self-modifying instructions and all timed
  disk loops. Derived 192 conversion-table entries from reversed bit pairs;
  retained explicit disk symbols, inverse table, control vectors, and delays.
  Classified `$D680` as slot-table data and the 875-byte tail as zero fill.
- **Validation:** `tools/check_native_io.py` checks every declared code span,
  372 direct/vector targets, overlap encodings, patch operands, and conversion
  tables. Deliberately corrupted vectors, overlaps, operands, and table entries
  are rejected. Six reconstruction/adoption tests and `git diff --check` pass.
- **Build/behavior:** `tools/build_disks.py` and `tools/verify_disks.py` reproduce
  both original images exactly and verify unchanged input hashes. New MAME
  play/utility runs match all ten reference screenshots and final media hashes,
  including the utility-side writes. Results are recorded in
  `docs/reference/step06c-native-audit.json` and
  `docs/reference/step06c-build-validation.json`.
- **Coverage:** 10,249 source-built output bytes; 276,471 still temporary.
  Counts include owned data and fill, not only instructions. Peripheral paths
  beyond the reference sessions are not claimed as behaviorally tested.
- **Next action:** Reconstruct the remaining shared native runtime and copied
  initialization code, then expand Pascal module reconstruction and assets.

## 2026-09-18 — Step 06d: reconstruct the shared native runtime

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Work:** Added `native_shared.s`, its typed recipe, linker configuration,
  and adoption mapping for `$E0E5`–`$F28F`. This adds 4,523 source-built bytes:
  2,192 instructions occupying 4,212 bytes, plus 311 data bytes. Documented
  procedure/segment handling, device wrappers, synthetic returns, messages,
  constants, and the initializer-copy stub in `docs/native-shared.md`.
- **Evidence:** Preserved the patched standard-procedure jump and expressed
  two synthetic RTS addresses as return-label-minus-one. Classified 39
  power-of-ten constants by their word order and finite binary32 encodings.
  The original last entry is three units in the last place above correctly
  rounded `10^38`; retained it exactly and recorded the anomaly.
- **Validation:** `tools/check_native_shared.py` verifies all code spans,
  464 outgoing/vector/return targets, 27 incoming primitive vectors, messages,
  dispatch encoding, initializer endpoints, and all numeric constants. Bad
  return targets, a changed dispatch operand, and a normalized last constant
  are rejected. Integer rounding was checked in both nearest-even tie
  directions. Existing captured initialization and overlay evidence still
  matches its disk sources; `git diff --check` passes.
- **Build/behavior:** Both rebuilt disk images match the originals byte for
  byte. New MAME play/utility runs match all ten reference screenshots and
  expected final media hashes. Results are in
  `docs/reference/step06d-native-audit.json` and
  `docs/reference/step06d-build-validation.json`.
- **Coverage:** 14,772 source-built output bytes; 271,948 remain temporary.
  Numeric/peripheral paths beyond the recorded runs are not claimed as tested.
- **Next action:** Reconstruct the copied initializer and high-memory native
  entry stubs, then continue with Pascal executable modules and assets.

## 2026-09-18 — Step 06e: reconstruct the copied runtime initializer

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Work:** Added `native_init.s`, its typed recipe, linker configuration, and
  adoption mapping. Assemble the five-page image at `$6800`, placing its bytes
  back at original `$F290`–`$F78F`. The source contains 498 instructions (1,032
  bytes) and 248 data bytes. Documented the dual-address behavior and data
  boundaries in `docs/native-init.md`.
- **Evidence:** All 1,280 assembled bytes equal the complete recorded emulator
  capture. Preserved two calls to the checksum helper at original `$F69A`,
  original-address data aliases, synthetic device-init returns, version-mask
  check, and final erase/dispatch loop. A 42-byte payload copied to `$BF56`
  remains explicitly unclassified; its format/consumer is a coverage question
  for later work, not a claimed decoded routine or identified asset.
- **Validation:** `tools/check_native_init.py` checks every code span and 90
  direct/synthetic-return targets, including the original/copy address mapping.
  It rejects a redirected checksum call, a return into an operand, and a
  changed version check. An initial source-expression syntax issue was fixed
  using explicit absolute addressing; the resulting component matches exactly.
  Whitespace checks pass.
- **Build/behavior:** Both disk images match the originals byte for byte.
  New MAME play and utility runs match all ten reference screenshots and
  expected final media hashes. Evidence is recorded in
  `docs/reference/step06e-native-audit.json` and
  `docs/reference/step06e-build-validation.json`.
- **Coverage:** 16,052 source-built output bytes; 270,668 remain temporary.
  Source totals include owned data and preserved fill, not just instructions.
- **Next action:** Reconstruct the remaining `$F790`–`$FFFF` native/data region,
  resolve its preserved fragments and the initialization payload, then continue
  with Pascal executable modules and assets.

## 2026-09-18 — Step 06f: reconstruct high-memory services and preserved tail

- **Status:** Module checkpoint complete. All SYSTEM.APPLE bytes are now
  source-built; overall step 06 and unresolved data analysis remain active.
- **Work:** Added `native_high.s`, typed recipe, linker configuration, and
  adoption mapping for `$F790`–`$FFFF`: 2,160 bytes containing 168 instructions
  (390 bytes) and 1,770 table/preservation bytes. Documented bank switching,
  service dispatch, keyboard translation, and open questions in
  `docs/native-high.md`.
- **Evidence:** The 95-byte fragment at `$F7A1` exactly duplicates initializer
  bytes `$F5A1`–`$F5FF`. It is represented as a truncated instruction fragment,
  without claiming it executes. Preserved the unknown `THISISIT` records,
  metadata, and zero fill. The 42-byte initialization payload remains open
  until its later consumer can be established during Pascal reconstruction.
- **Validation:** `tools/check_native_high.py` checks all code spans, 79
  direct/vector targets against the correct banks, 22 computed service
  targets, switch operands, keyboard tables, and the duplicate fragment.
  Corrupt bank-2 destinations, bank switches, and fragment bytes are rejected.
  Whitespace checks pass.
- **Build/behavior:** Both disks compare byte for byte. A new isolated tree
  containing only `tools/`, `src/`, and `reconstruction/` builds identical
  reports and images without originals. New MAME play/utility runs match all
  ten screenshots and expected final media hashes. Reports are in
  `docs/reference/step06f-native-audit.json` and
  `docs/reference/step06f-build-validation.json`.
- **Coverage:** Audited every byte of logical blocks 219–250: all 16,384
  SYSTEM.APPLE bytes belong to the five assembled runtime components, with no
  temporary owner. Overall source-built output is 18,212 bytes; 268,508 remain
  temporary. Counts include owned data/fill and do not imply complete semantic
  understanding or completion of the other executable regions.
- **Next action:** Expand the p-code decoder/assembler from the entry proof to
  complete Pascal procedures and modules, using native handler behavior to
  resolve instruction encodings and later revisit unknown runtime payloads.

## 2026-09-18 — Step 06g: reconstruct the complete disk-1 startup p-code segment

- **Status:** First full p-code segment checkpoint complete; overall step 06
  remains in progress.
- **Work:** Added `tools/pcode_source.py` and expanded `encoding.inc` with
  verified startup instruction formats. Added `startup_disk1.s`, configuration,
  and adoption mapping for the 576-byte segment at disk-1 block 141. Its six
  procedures contain 243 instructions, 447 instruction-encoding bytes, eight
  branch words, eighteen case words, three alignment bytes, and explicit
  procedure attributes/dictionary. Every segment byte is accounted for.
- **Evidence:** Decoder control flow follows entry/exit roots and branches,
  preserving big-operand widths, signed word constants, both case alignments,
  and 16-bit pointer subtraction. It checks supported opcode dispatch targets
  against the assembled interpreter and rejects unknown encodings/gaps rather
  than outputting executable blobs. Documentation is in `docs/startup-pcode.md`.
- **Validation:** Seven decoder tests pass, including malformed targets,
  selectors, truncated/unsupported instructions, wrapped case pointers, and
  nonzero padding. All 263 control-flow edges resolve to instruction boundaries.
  A newly generated listing assembles identically. All 576 bytes also match the
  recorded loader capture at `$B2B4`. Whitespace checks pass.
- **Build/behavior:** Both full disk images remain byte-identical. New MAME
  play/utility runs match all ten reference screenshots and expected final
  media hashes. Reports are in `docs/reference/step06g-pcode-audit.json` and
  `docs/reference/step06g-build-validation.json`.
- **Coverage:** 18,788 source-built output bytes; 267,932 remain temporary.
  The decoder is intentionally incomplete outside its verified subset; other
  p-code formats, inline data, and native-procedure relocations remain work.
- **Next action:** Apply the decoder to the remaining segment inventory,
  extend it for newly encountered formats using the shipped handlers, and
  reconstruct further system/library/game modules in validated checkpoints.

## 2026-09-18 — Goal revision: classification required, byte identity preferred

- **Authorization:** User requested adjustment of the goal and related documents,
  then continuation. Unidentified chunks are unacceptable; every region must be
  distinguished as code or data at minimum.
- **Changes:** Updated PRD, PLAN, README, and reconstruction guidance. Require
  evidence-backed classification and disassembly of all executable content.
  Established data may retain unknown semantics. Byte identity is preferred,
  with mapped/explained and behaviorally validated differences permitted.
  Source/data-only builds, asset extraction, final emulator checks, and logging
  and committing every checkpoint remain required.
- **Validation:** Reviewed acceptance language for consistency; no code or output
  changed. Existing exact build comparisons remain useful and strict. Full
  emulator reruns are now reserved for integration milestones or changed outputs.
- **Goal tracking:** The session goal refers to implementing PLAN.md; the revised
  PLAN is its current acceptance specification. The goal tool cannot edit the
  objective text or resume its paused scheduling state. No completion claimed.
- **Next action:** Continue p-code format coverage and reconstruct additional
  complete modules, retaining explicit failures for unclassified bytes.

## 2026-09-18 — Step 06h: extend p-code formats and reconstruct utility segment

- **Status:** Checkpoint complete; overall step 06 remains in progress.
- **Work:** Extended the decoder and ca65 macros using the shipped native handlers
  for integer/addressing operations, compact loads, typed comparisons, inline
  strings/arrays/words, CIP and BPT. Data payloads have separate owners and
  consumer offsets; undecodable or unexplained chunks still fail.
- **Reconstruction:** Complete disk-1 UTILITY segment: 8,644 bytes, 50 procedures,
  4,073 instructions. Separated 1,239 inline string bytes, 150 pointer-table
  bytes, 25 alignment bytes, and 602 metadata/dictionary bytes from instructions.
  Added source, configuration, adoption mapping, audit, and utility documentation.
- **Validation:** Eleven decoder tests pass, including ca65/ld65 round trips for
  new inline formats; three adoption and three reconstruction tests pass.
  Utility assembly and both complete images match exactly. `git diff --check`
  passes. Reused unchanged-output MAME evidence; no redundant emulator run.
- **Coverage:** 27,432 source-built output bytes; 259,288 remain temporary.
  A dry run now decodes most remaining pure p-code segments; mixed native
  procedures, split-system metadata, and two unexplained gaps remain rejected.
- **Next action:** Adopt the successfully classified p-code modules, then resolve
  the mixed native procedures and unexplained gaps without hiding them as data.

## 2026-09-18 — Step 06i: reconstruct library_25

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk1 header 103, segment 25, block 127; disk2 header 103, segment 25, block 127.
- **Work:** Reconstructed 958 bytes, 9 procedures,
  573 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/library_25.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 29,348 output bytes, with 257,372 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.
- **Tooling:** Added `prepare_pcode_component.py` to reproduce source preparation,
  per-byte classification, assembly verification, and mapping of identical copies
  without reading originals. It refuses already reconstructed regions or outputs.

## 2026-09-18 — Step 06j-01: reconstruct library_27

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk1 header 103, segment 27, block 135; disk2 header 103, segment 27, block 135.
- **Work:** Reconstructed 1,616 bytes, 15 procedures,
  913 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/library_27.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 32,580 output bytes, with 254,140 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.

## 2026-09-18 — Step 06j-02: reconstruct library_28

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk1 header 103, segment 28, block 139; disk2 header 103, segment 28, block 139.
- **Work:** Reconstructed 328 bytes, 6 procedures,
  181 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/library_28.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 33,236 output bytes, with 253,484 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.

## 2026-09-18 — Step 06j-03: reconstruct startup_7

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk1 header 140, segment 7, block 143; disk2 header 140, segment 7, block 143.
- **Work:** Reconstructed 1,868 bytes, 8 procedures,
  778 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/startup_7.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 36,972 output bytes, with 249,748 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.

## 2026-09-18 — Step 06j-04: reconstruct alternate_7

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk1 header 157, segment 7, block 158.
- **Work:** Reconstructed 764 bytes, 3 procedures,
  353 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/alternate_7.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 37,736 output bytes, with 248,984 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.

## 2026-09-18 — Step 06j-05: reconstruct alternate_8

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk1 header 157, segment 8, block 160.
- **Work:** Reconstructed 3,348 bytes, 13 procedures,
  1,317 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/alternate_8.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 41,084 output bytes, with 245,636 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.

## 2026-09-18 — Step 06j-06: reconstruct alternate_9

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk1 header 157, segment 9, block 167.
- **Work:** Reconstructed 1,212 bytes, 5 procedures,
  464 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/alternate_9.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 42,296 output bytes, with 244,424 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.

## 2026-09-18 — Step 06j-07: reconstruct alternate_10

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk1 header 157, segment 10, block 170.
- **Work:** Reconstructed 950 bytes, 1 procedures,
  95 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/alternate_10.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 43,246 output bytes, with 243,474 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.

## 2026-09-18 — Step 06j-08: reconstruct system_1

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk1 header 251, segment 1, block 260.
- **Work:** Reconstructed 20 bytes, 1 procedures,
  3 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/system_1.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 43,266 output bytes, with 243,454 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.

## 2026-09-18 — Step 06j-09: reconstruct system_3

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk1 header 251, segment 3, block 263.
- **Work:** Reconstructed 20 bytes, 1 procedures,
  3 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/system_3.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 43,286 output bytes, with 243,434 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.

## 2026-09-18 — Step 06j-10: reconstruct system_4

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk1 header 251, segment 4, block 264.
- **Work:** Reconstructed 1,998 bytes, 10 procedures,
  855 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/system_4.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 45,284 output bytes, with 241,436 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.

## 2026-09-18 — Step 06j-11: reconstruct system_5

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk1 header 251, segment 5, block 268.
- **Work:** Reconstructed 1,670 bytes, 10 procedures,
  894 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/system_5.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 46,954 output bytes, with 239,766 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.

## 2026-09-18 — Step 06j-12: reconstruct game_8

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk2 header 140, segment 8, block 147.
- **Work:** Reconstructed 3,130 bytes, 18 procedures,
  1,503 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/game_8.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 50,084 output bytes, with 236,636 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.

## 2026-09-18 — Step 06j-13: reconstruct game_12

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk2 header 140, segment 12, block 174.
- **Work:** Reconstructed 5,546 bytes, 23 procedures,
  2,590 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/game_12.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 55,630 output bytes, with 231,090 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.

## 2026-09-18 — Step 06j-14: reconstruct game_13

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk2 header 140, segment 13, block 154.
- **Work:** Reconstructed 10,214 bytes, 52 procedures,
  4,854 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/game_13.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 65,844 output bytes, with 220,876 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.

## 2026-09-18 — Step 06j-15: reconstruct game_14

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk2 header 140, segment 14, block 185.
- **Work:** Reconstructed 2,544 bytes, 12 procedures,
  1,300 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/game_14.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 68,388 output bytes, with 218,332 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.

## 2026-09-18 — Step 06j-16: reconstruct game_15

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk2 header 140, segment 15, block 190.
- **Work:** Reconstructed 2,654 bytes, 16 procedures,
  1,310 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/game_15.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 71,042 output bytes, with 215,678 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.

## 2026-09-18 — Step 06j-17: reconstruct game_16

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk2 header 140, segment 16, block 196.
- **Work:** Reconstructed 7,446 bytes, 48 procedures,
  3,856 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/game_16.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 78,488 output bytes, with 208,232 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.

## 2026-09-18 — Step 06j-18: reconstruct game_17

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk2 header 140, segment 17, block 211.
- **Work:** Reconstructed 3,532 bytes, 17 procedures,
  2,071 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/game_17.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 82,020 output bytes, with 204,700 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.

## 2026-09-18 — Step 06j-19: reconstruct game_18

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk2 header 140, segment 18, block 218.
- **Work:** Reconstructed 6,280 bytes, 28 procedures,
  3,669 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/game_18.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 88,300 output bytes, with 198,420 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.

## 2026-09-18 — Step 06j-20: reconstruct game_19

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk2 header 140, segment 19, block 231.
- **Work:** Reconstructed 5,200 bytes, 26 procedures,
  2,483 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/game_19.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 93,500 output bytes, with 193,220 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.

## 2026-09-18 — Step 06j-21: reconstruct game_20

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk2 header 140, segment 20, block 242.
- **Work:** Reconstructed 6,836 bytes, 32 procedures,
  3,385 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/game_20.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 100,336 output bytes, with 186,384 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.

## 2026-09-18 — Step 06j-22: reconstruct game_21

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk2 header 140, segment 21, block 256.
- **Work:** Reconstructed 8,132 bytes, 41 procedures,
  4,567 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/game_21.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 108,468 output bytes, with 178,252 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.

## 2026-09-18 — Step 06k: reconstruct system_2

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk1 header 251, segment 2, block 261.
- **Work:** Reconstructed 808 bytes, 5 procedures,
  510 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/system_2.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 109,276 output bytes, with 177,444 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.
- **Boundary resolution:** Classified two unreachable UJP instructions from their
  encoding and repeated conditional-join context. Their targets are independently
  reachable from existing procedure roots; the extra roots themselves are not.
  Added explicit reviewed-code-root support, without any automatic gap decoding.
  Twelve decoder tests pass. Evidence also identifies the two analogous segment-6
  gaps for the following module checkpoint.

## 2026-09-18 — Step 06l: reconstruct system_6

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk1 header 251, segment 6, block 272.
- **Work:** Reconstructed 3,652 bytes, 15 procedures,
  2,332 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/system_6.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 112,928 output bytes, with 173,792 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.
- **Boundary resolution:** The two statically reviewed UJP roots are explicitly
  recorded in the audit and source. All their targets were confirmed reachable
  independently; no arbitrary gap was classified as code or data.

## 2026-09-18 — Step 06m: reconstruct library_23

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk1 header 103, segment 23, block 116; disk2 header 103, segment 23, block 116.
- **Work:** Reconstructed 606 bytes, 4 procedures,
  268 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/library_23.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 114,140 output bytes, with 172,580 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.
- **Native evidence:** This mixed module contains 267 native instructions plus
  one p-code instruction. Added a parser for four loader-defined relocation lists
  and a module audit separating native code, lookup/mask tables, padding, and
  attributes. The two relocated words are a table address and an internal JMP;
  both are source label differences. Three parser tests pass; corrupted relocation
  operands, branch boundaries, and list counts are rejected. One mask table's
  consumer remains unknown, with its data-classification evidence documented.

## 2026-09-18 — Step 06n: replace the duplicate disk-2 startup payload

- **Work:** Mapped the disk-2 copy of the 576-byte startup segment to the existing
  startup source/configuration. No duplicate instruction listing was introduced.
- **Evidence/validation:** Inventory hash and adoption byte comparison establish
  identity with the reconstructed disk-1 segment. All replacement ranges were
  temporary. The full build and exact comparisons pass for both disks.
- **Coverage:** 114,716 source-built output bytes; 172,004 remain temporary.
- **Next action:** Audit current executable coverage and build independence, then
  continue the remaining mixed native modules, split system core, and assets.

## 2026-09-18 — Step 06o: audit executable coverage and independent build

- **Status:** Integration checkpoint complete; project completion is not claimed.
- **Coverage:** Added a reproducible executable ownership report. All disk copies
  of 28 of 34 distinct valid inventoried Pascal segments are source-built. Six
  remain: libraries 22/24, both distinct library-26 variants, alternate startup 1,
  and system core 0. The split fragment and non-segment regions remain separate
  open work. Overall totals: 114,716 source-built bytes; 172,004 temporary bytes.
- **Validation:** A new isolated tree containing only tools, source, and
  reconstruction inputs builds both identical disks without originals or docs.
  Rechecked 5,598 initialization capture bytes, 16 dispatch snapshots, and 12
  full overlay loads. Twelve decoder and three relocation-parser tests passed in
  their implementation checkpoints; module checks reject malformed boundaries.
  Exact output supports reuse of existing emulator evidence; final both-emulator
  behavior/save-load validation remains outstanding.
- **Documentation:** Refreshed root/source/reconstruction READMEs and current
  coverage guidance. Historical progress and original evidence are preserved.
- **Next action:** Apply the native relocation layout to libraries 22, 24, and 26
  and alternate startup, then reconstruct the split core, classify remaining
  regions and extract assets. Unidentified chunks remain unacceptable at finish.

## 2026-09-18 — Step 06p: reconstruct alternate_1

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk1 header 157, segment 1, block 172.
- **Work:** Reconstructed 880 bytes, 8 procedures,
  413 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/alternate_1.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 115,596 output bytes, with 171,124 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.
- **Mixed-module tooling:** Added a native control-flow decoder and integration
  with p-code byte ownership. Its 151 standard opcode encodings round-trip through
  ca65; six native boundary tests and twelve p-code tests pass. Native code/data
  recipes record bounded table consumers and relocation constraints. A reviewed
  library-24 recipe is prepared for the next module checkpoint.

## 2026-09-18 — Step 06q: reconstruct library_24

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk1 header 103, segment 24, block 118; disk2 header 103, segment 24, block 118.
- **Work:** Reconstructed 4,306 bytes, 17 procedures,
  2,298 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/library_24.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 124,208 output bytes, with 162,512 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.
- **Native classification:** Three native procedures contain 457 instruction
  bytes, three 12-byte lookup tables and one 33-byte lookup table. Bounded indexed
  loads establish every table extent; two native alignment bytes are separate.
  All native relocation and control-flow targets are validated by the mixed decoder.

## 2026-09-18 — Step 06r: reconstruct library_26_disk1

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk1 header 103, segment 26, block 129.
- **Work:** Reconstructed 3,058 bytes, 18 procedures,
  1,266 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/library_26_disk1.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 127,266 output bytes, with 159,454 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.
- **Native/data evidence:** Seven native procedures contain 647 instruction bytes;
  a 280-byte indexed division table is expressed as floor(pixel_x/7). Cross-call
  relocation targets establish the helper following the table as code. Factored
  the variant source into a shared include, preserving the 13 differing bytes of
  the inline identification string. Rebuilt after formula refactoring; both
  image comparisons pass. The disk-2 variant is the next checkpoint.

## 2026-09-18 — Step 06s: reconstruct library_26_disk2

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk2 header 103, segment 26, block 129.
- **Work:** Reconstructed 3,058 bytes, 18 procedures,
  1,266 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/library_26_disk2.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 130,324 output bytes, with 156,396 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.
- **Variant handling:** Disk 2 uses the shared library-26 instruction/table source
  with its own original inline string. Both variants were independently decoded,
  assembled, and compared; their native code and data classifications are equal.

## 2026-09-18 — Step 06t: reconstruct library_22

- **Status:** Module checkpoint complete; overall step 06 remains in progress.
- **Origin:** disk1 header 103, segment 22, block 104; disk2 header 103, segment 22, block 104.
- **Work:** Reconstructed 6,126 bytes, 63 procedures,
  2,710 instructions; all bytes classified by control flow,
  inline-data consumers, pointer tables, or procedure metadata. Equivalent disk
  copies share one source component. No unidentified fallback data is accepted.
- **Evidence:** `docs/reference/pcode-modules/library_22.json` records origins,
  classification totals, and every data range. The source retains numeric call
  names where semantics are not established.
- **Validation:** Generated listing assembles byte for byte; adoption checks each
  disk mapping. Full build and comparison pass for both disks. Source coverage
  is 142,576 output bytes, with 144,144 remaining temporary.
  The unchanged-output emulator baseline is reused; no new run was required.
- **Next action:** Continue remaining p-code modules and resolve mixed native
  procedures and unclassified gaps. Final asset and emulator checks remain open.
- **Runtime patch evidence:** Verified the dispatch-hook pointer, helper root,
  unconditional BEQ outcome, and four stores into two JMP operands. Table formulas
  reproduce all 266 pixel-index bytes; the final ten are documented data
  continuation with unknown original intended use. No executable gap remains in
  this module. It contains 45 p-code and 18 native procedures.

## 2026-09-18 — Step 06u: reconstruct the split system core

- **Work:** Reconstructed all 39 SYSTEM.PASCAL core procedures, including procedure
  38 in its separately loaded 170-byte fragment. Retained the existing 36-byte
  entry component and adopted the remaining 3,258 bytes. The concatenated source
  uses the captured $F248/$BC72 address relationship for its one cross-region
  dictionary pointer; no original bytes are hidden in data directives.
- **Classification:** Complete core/fragment analysis covers 3,294 bytes: 1,891
  instructions (2,667 bytes), 76 string bytes, 62 branch-pointer bytes, 19 alignment
  bytes, and explicit procedure metadata/dictionary. One reviewed unreachable UJP
  at $03BD is code, with independently reachable target $03CB.
- **Validation:** Thirteen p-code tests pass, including a synthetic split-memory
  layout and rejection of a wrong dictionary delta. A regenerated listing matches
  the accepted source. Full component assembly, adoption, and both disk comparisons
  pass exactly. The existing first-procedure component matches the core prefix.
- **Coverage:** 145,834 source-built output bytes; 140,886 remain temporary.
  All distinct valid inventoried Pascal segments are now source-built. This does
  not classify remaining disk regions, orphan candidates, or provisional native
  runtime data; it is not full project completion.
- **Next action:** Refresh the executable audit, investigate remaining regions and
  the unresolved initialization payload, then continue asset/data reconstruction.

## 2026-09-18 — Step 06v: audit complete inventoried executable ownership

- **Work/evidence:** Refreshed the executable coverage tool and report, including
  the separately inventoried 170-byte procedure-38 fragment. Every disk copy of
  all 34 distinct valid segments and that fragment is owned by source components.
  Updated current documentation without changing historical checkpoint records.
- **Scope limit:** This proves ownership of inventoried executables, not complete
  disk classification. Orphan/header candidates, asset buffers, unallocated bytes,
  and provisional native-runtime ranges remain open. In particular, the 42-byte
  BF56 initialization payload still needs code/data boundaries established.
- **Next action:** Classify and extract the confirmed title bitmap as an asset;
  continue investigation of other regions and provisional runtime classifications.

## 2026-09-18 — Step 07a: classify and extract the title bitmap

- **Work:** Extracted the complete 8,192-byte title HGR buffer with a manifest,
  adoption recipe, and monochrome PNG preview. Its native consumer addresses
  7,680 displayed bytes; 512 non-display bytes remain losslessly preserved as
  image-buffer padding. Recorded the eight non-$FF padding bytes individually.
  The preview's ship/planet artwork was visually compared with the MAME reference;
  later text/menu overlays and artifact colors are explicitly outside this preview.
- **Build integration:** Added `identified-data` components with required format
  and classification evidence, separate from source and temporary remainders.
  The normal build reads the committed asset; no extraction or original images
  are required. Kept the remaining classification work in step 06 explicitly open.
- **Validation:** Three HGR tests verify known row addresses, complete/disjoint
  byte coverage, preservation of high bits/holes, and bad-size rejection. Four
  adoption tests and three reconstruction tests pass. Both disks compare exactly.
  A fresh build with only tools/source/reconstruction/assets produces identical
  disks. New MAME play and utility runs match all ten reference screenshots and
  expected final media hashes; report: step07a-build-validation.json.
- **Coverage:** 145,834 source-built bytes; 8,192 identified asset bytes; 132,694
  bytes remain temporary. Complete disk classification, remaining asset extraction,
  and final both-emulator/save-load checks are not yet done.
- **Next action:** Investigate provisional runtime bytes and orphan/header regions,
  map the remaining data consumers, and extract further images/fonts/game data.

## 2026-09-18 — Step 08a: reconstruct classified segment-header tables

- **Work/evidence:** Reconstructed the first 288 bytes of all eight inventoried
  headers as explicit extent/name/kind/text/info tables. Six unique tables serve
  eight locations. The initializer's sixteen-record walk at $6B34–$6B7A and its
  version check supply consumer evidence, alongside the validated segment extents.
  Added source, linker configuration, adoption recipe, repeatable preparation
  tool, and docs/reference/header-tables.json with locations and classifications.
- **Scope:** The 224-byte tail of each header remains outside this classification.
  Block 103 has a command prompt and surrounding unexplained words there; it is
  not blanket-classified as padding. Block 84's tables are established metadata,
  but its mismatched segment reference remains unresolved. The 42-byte runtime
  initialization payload also remains open after reviewing its copy and pointer
  setup; no unsupported data classification was substituted for that question.
- **Validation:** `python3 tools/prepare_header_tables.py` assembled all six tables
  and compared their bytes before producing source. Adoption checked all 2,304
  mapped output bytes. `python3 tools/build_disks.py` and
  `python3 tools/verify_disks.py` pass, including original input hashes and exact
  comparisons of both complete disks. Unchanged outputs reuse step 07a's MAME
  references; final both-emulator/save-load validation remains required.
- **Coverage:** 148,138 source-built bytes, including typed metadata; 8,192
  identified asset bytes; 130,390 temporary bytes (68,562 disk 1; 61,828 disk 2).
  These are ownership totals, not instruction counts or completion percentages.
- **Next action:** Continue classifying header tails, runtime payloads, and other
  disk regions through their consumers, and extract further supported assets.

## 2026-09-18 — Step 06w: reconstruct a raw screen-table initializer

- **Discovery:** Traced library 22 procedure 53's block-I/O wrapper and procedure
  54's load/call sequence. Startup reads disk-1 block 83 byte 6 (value 2), loads
  block 2 at $0E80, and calls $0F40 through procedure 25's patched JMP. This is
  executable content outside the completed Pascal segment inventory.
- **Classification:** The first 192 bytes are HGR row-address high bytes; every
  byte matches the row formula, and native drawing consumers index the table.
  The following 105 bytes decode to 58 native instructions that generate the
  complementary low-byte and linear-row tables and return at $0FA8. The block's
  remaining 215 bytes stay unresolved. Added source, recipe, audit, and evidence.
- **Tooling:** Added strict fixed-address raw decoding and preparation tools.
  Four tests cover internal calls/branches, unreachable-byte rejection, targets
  inside operands/data, and evidence requirements for roots/external transfers.
  Indirect jumps remain rejected until an appropriate target model is supplied.
- **Validation:** `python3 tools/test_native_raw_source.py` passes all four tests.
  Preparation assembled and compared all 297 bytes. Adoption, full build, and
  `python3 tools/verify_disks.py` pass; both disks and original input hashes are
  unchanged. Existing MAME reference behavior remains applicable.
- **Coverage:** 148,435 source-built bytes, 8,192 asset bytes, 130,093 temporary
  bytes (68,265 disk 1; 61,828 disk 2). This does not resolve provisional runtime
  regions or establish complete executable discovery.
- **Next action:** Reconstruct the raw routine loaded from disk-1 block 156 into
  $0F40; follow other raw loads, including native code visible in disk-2 block 83.

## 2026-09-18 — Step 06x: raw buffer transform and live screen-table validation

- **Work:** Reconstructed the 93-byte/53-instruction entry path loaded from disk-1
  block 156 at $0F40. The p-code caller and block bias establish its origin. It
  adds an incrementing byte value across a page-counted buffer, writes SHIP at
  $1801–$1804, and returns. Recorded the four-byte parameter source in utility
  code. Kept the trailing indirect-jump candidate and metadata outside adoption;
  no unsupported classification was introduced to fill the rest of the block.
- **Runtime evidence:** Revalidated the existing private apple2ts session paused
  at $E4DE. Without changing CPU/memory/media, continued to the screen initializer
  at $0F40, captured its whole 512-byte load, then stopped before RTS at $0FA8.
  Its 384 generated table bytes exactly match the HGR/linear row formulas.
  Continued to the title prompt and paused. The second raw routine has static
  call evidence but was not reached in this runtime trace.
- **Validation:** Preparation/adoption checked all 93 new bytes; full build and
  exact-disk verification pass. Extended `tools/verify_runtime_evidence.py` to
  verify the new 512-byte load, 384-byte output, entry/exit PCs, and stack change.
  All earlier initialization, p-code, and overlay capture checks still pass.
- **Coverage:** 148,528 source-built bytes, 8,192 asset bytes, 130,000 temporary
  bytes (68,172 disk 1; 61,828 disk 2). Original images remain unchanged.
- **Next action:** Extract the font/tile data loaded by library 22 procedure 20,
  then reconstruct further raw overlays and remaining native metadata/tails.

## 2026-09-18 — Step 07b: extract the shared font and symbol bank

- **Work/evidence:** Traced library 22 procedure 20's two-block bank loader and
  native procedure 9's eight-byte glyph addressing and reverse-row rendering.
  Extracted the identical 1,024-byte bank from blocks 3–4 of both disks. Added
  raw data, a manifest, display-order JSON rows, a 128-glyph atlas, extraction/
  preview tooling, and the shared adoption recipe. Visually reviewed the atlas's
  symbols, punctuation, digits, and upper/lowercase letters.
- **Runtime:** Captured the complete font bank at $1000 in the unpatched apple2ts
  reference session paused at the title prompt. Every byte equals the extracted
  asset. Recorded docs/reference/shared-font-runtime.json and extended the runtime
  evidence verifier to compare the capture, both disks, and packed JSON rows.
- **Validation:** Two glyph tests verify row order, record boundaries, high-bit
  preservation, exact round trip, and malformed input rejection. All runtime
  evidence checks pass. Adoption and the complete build preserve both full-disk
  hashes and exact bytes; original inputs are unchanged. The build reads only the
  shared raw font, with no original images or Pillow dependency.
- **Coverage:** 148,528 source-built bytes, 10,240 identified asset bytes, 127,952
  temporary bytes (67,148 disk 1; 60,804 disk 2). Other glyph banks, raw overlays,
  native provisional regions, and remaining disk data are still open.
- **Next action:** Follow additional raw block-load/call pairs, then extract other
  tile banks with confirmed renderer consumers and resolve preserved native tails.

## 2026-09-18 — Step 06y: reconstruct the certificate reveal routine

- **Work/evidence:** Traced library 26 procedure 7's 18-block read from disk-1
  blocks 5–22 into $4000, followed by its native call to $6000. Reconstructed
  block 21 as 176 instructions/307 code bytes, native metadata, and zero block
  padding. Its 40-byte row copy and two bounded row counters establish the HGR
  certificate consumer. The extra fetched block 22 remains unresolved.
- **Classification:** The native body ends at RTS $6132. Independently validated
  its 324-byte one-procedure Pascal container and four empty relocation lists;
  expressed entry/dictionary pointers symbolically. The remaining 188 block bytes
  are uniformly zero after the explicit segment trailer. Source and audit retain
  these data boundaries; no guessed data fills an undecoded executable body.
- **Validation:** Raw preparation and adoption each compare every byte. The full
  build and exact comparison pass for both disks and original input hashes.
  The image preview identifies a starship registration certificate; extraction
  is the next separately committed checkpoint. No fresh emulator execution of
  this reveal routine is claimed.
- **Coverage:** 149,040 source-built bytes, 10,240 identified asset bytes, 127,440
  temporary bytes (66,636 disk 1; 60,804 disk 2).
- **Next action:** Extract the confirmed certificate HGR page, then continue raw
  overlay reconstruction and classify the remaining native metadata/tails.

## 2026-09-18 — Step 07c: extract the registration certificate image

- **Work/evidence:** Extracted disk-1 blocks 5–20 as the starship registration
  certificate HGR page, separated from its now-reconstructed reveal code. The
  library's alternate load path displays the same image directly at $2000.
  Added raw image, monochrome preview, manifest, repeatable extractor, and adoption
  recipe. Visually reviewed the artwork and documented the blank recipient line
  and later overlays separately from the stored image.
- **Classification:** The row consumer accounts for 7,680 display bytes. All 512
  memory-hole bytes are $80, preserved as image-buffer padding. Extraction checks
  this pattern and proves the existing split/pack round trip for the whole page.
- **Validation:** All three HGR tests pass; preparation, adoption, full build,
  original-input checks, and both exact disk comparisons pass. No new image bytes
  or game behavior were introduced. Fresh emulator validation of the animated
  certificate path remains part of the outstanding final behavior work.
- **Coverage:** 149,040 source-built bytes, 18,432 asset bytes, 119,248 temporary
  bytes (58,444 disk 1; 60,804 disk 2).
- **Next action:** Reconstruct additional raw overlays, including game-side native
  code around block 83, and resolve the remaining native tails and data banks.

## 2026-09-18 — Step 06z: reconstruct warp animation and clarify completion scope

- **Goal/criteria:** Confirmed the revised PRD and PLAN allow explained,
  behaviorally validated byte differences but require evidence-backed code/data
  classification everywhere. Explicitly included unused executable routines.
  The active goal references PLAN.md; its tool supports status changes only,
  so its existing title was retained with the revised plan as acceptance criteria.
- **Work/evidence:** Reconstructed all 1,536 bytes of disk-2 blocks 83–85 loaded
  at $1800 by game segment 13. The caller and library block bias establish the
  extent and entry. The source contains 586 instructions (1,216 distinct code
  bytes) and 320 classified bytes of masks, arithmetic state, bitmap, and workspace.
- **Decoder:** Added explicitly evidenced BIT-prefix overlaps for independently
  reachable embedded instructions. Both BIT/SBC paths are retained. Other overlaps
  remain errors; diagnostic gap inspection cannot emit adoptable source. Documented
  two runtime opcode patches without changing the original stored instructions.
- **Validation:** Five raw-decoder tests pass, including a real ca65/ld65 overlap
  round trip and rejection cases. Preparation/adoption compare all 1,536 bytes.
  Full build and verify_disks.py pass: both complete disk images remain exact,
  and all original input hashes are unchanged. No fresh warp runtime trace is claimed.
- **Coverage:** 150,576 source-built bytes, 18,432 asset bytes, 117,712 temporary
  bytes (58,444 disk 1; 59,268 disk 2). This does not claim complete classification
  of provisional regions in older source modules or completion of the overall goal.
- **Next action:** Follow the adjacent two-block raw overlay loaded from disk-2
  block 86, then continue remaining raw code, assets, and native tails.

## 2026-09-18 — Step 06aa: reconstruct the viewscreen transition

- **Work/evidence:** Followed game 13's two-block load from disk-2 block 86 and
  native call at $1F60. Reconstructed the 944-byte native container at $1800:
  410 instructions/843 code bytes and 101 bytes of drawing tables, row-copy
  buffer, alignment, and metadata. Recorded the $09F5 external drawing dependency
  in the separately loaded blocks 81–82 overlay.
- **Classification:** The existing Pascal dictionary/relocation parsers confirm
  entry zero, four empty relocation lists beginning at offset 928, and the
  trailer ending at offset 944. The final 80 fetched bytes remain explicitly
  unresolved. Corrected the warp document: $1F60 calls this replacement overlay,
  not the earlier warp animation sharing its load address.
- **Validation:** Preparation and adoption each verify all 944 bytes; typed
  metadata and symbolic pointers assemble exactly. Full build and disk comparison
  pass, with original inputs unchanged. No new runtime trace is claimed; final
  behavior checks remain outstanding.
- **Coverage:** 151,520 source-built bytes, 18,432 asset bytes, 116,768 temporary
  bytes (58,444 disk 1; 58,324 disk 2). Older provisional source regions still
  require the final code/data audit.
- **Next action:** Reconstruct the shared drawing overlay at disk-2 blocks 81–82,
  then continue asset classification and unresolved native/container tails.

## 2026-09-18 — Step 06ab: shared viewscreen drawing and joystick overlay

- **Work/evidence:** Reconstructed all 1,024 bytes of disk-2 blocks 81–82 at
  $0800. P-code callers establish three argument-consuming entries and the
  viewscreen transition establishes the direct $09F5 helper. Classified 290
  instructions/545 code bytes and 479 data bytes: drawing masks/columns, mark
  addresses, signed paddle mapping, native metadata, and initial table workspace.
- **Workspace evidence:** Game 13 calls procedure 2 immediately after the block
  read. Its bounded loop writes all 256 bytes of $0B00–$0BFF, which native $0A06
  indexes. This accounts for the metadata-overwritten page and its nonzero final
  stored byte without guessing padding or changing the on-disk representation.
- **Validation:** The existing dictionary/relocation parsers confirm the 784-byte
  native container. Preparation and adoption verify all 1,024 bytes, including
  typed metadata. Full build, original-input hashes, and both complete disk
  comparisons pass. No new emulator trace is claimed for these routines.
- **Coverage:** 152,544 source-built bytes, 18,432 asset bytes, 115,744 temporary
  bytes (58,444 disk 1; 57,300 disk 2). Final classification and behavior gates
  remain open, including provisional regions in older native source.
- **Next action:** Trace the scene-display raw loader in game 21 and its image
  consumers, then continue remaining native tails and data banks.

## 2026-09-18 — Step 06ac: raw disk-integrity checker and checksum table

- **Work/evidence:** Traced the game-21 raw load to disk-2 block 54 and entry
  $1840. The routine is an integrity checker, not a scene renderer: 41
  instructions/71 bytes sum alternating bytes of a 4,096-byte buffer into two
  independent modulo-256 accumulators. Reconstructed the preceding 64-byte
  table; its caller indexes by block >> 2 and explicitly skips group 48.
- **Validation:** Added verify_block_checksums.py and its 32-group report. All
  31 checked groups match the native algorithm; the skipped self-containing
  group mismatch is recorded, not altered. A one-byte mutation is detected in
  the correct group. Preparation/adoption verify all 135 reconstructed bytes;
  full build, original hashes, and both exact disk comparisons pass.
- **Limits:** The other 377 bytes of block 54 remain unresolved. Checksums prove
  content integrity, not code/data classification of their input. No fresh
  runtime trace of the checker is claimed.
- **Coverage:** 152,679 source-built bytes, 18,432 asset bytes, 115,609 temporary
  bytes (58,444 disk 1; 57,165 disk 2).
- **Next action:** Extract additional glyph/tile banks through the confirmed
  library-22 bank loader and renderer; continue classifying remaining raw tails.

## 2026-09-18 — Step 07d: extract both play-side graphics banks

- **Work/evidence:** Extracted bank 1 from disk-2 blocks 5–6 and bank 2 from
  blocks 7–8. Traced the startup/game-13 bank loads, library-22 glyph renderer,
  and bank-2 copy to $0400 followed by game-12's explicit pointer selection.
  Added all 256 records as raw bytes, display-order row listings, atlases,
  manifests, adoption recipes, repeatable extraction tool, and consumer notes.
- **Visual/boundary review:** Both atlases show graphics masks, symbols, and
  digits. Bank 2's eight omitted runtime-copy records alternate all $00/all $80;
  all are blank under the renderer mask. The extractor checks their exact stored
  values and preserves them. Runtime destination gaps are not falsely equated
  with source records; the previews represent stored masks only.
- **Validation:** Both complete row listings pack exactly to their raw banks.
  Existing glyph tests pass. Both adoptions and full builds preserve every byte;
  original-input checks and complete disk comparisons pass. No live capture of
  these two banks is claimed; the previous font capture covers bank zero.
- **Coverage:** 152,679 source-built bytes, 20,480 asset bytes, 113,561 temporary
  bytes (58,444 disk 1; 55,117 disk 2). Code/data audit and final behavior checks
  remain required, including older provisional native regions.
- **Next action:** Trace the remaining raw block loaders and classify the
  persistent game-state/map buffers and native/container tails with their consumers.

## 2026-09-18 — Step 07e: extract the compressed ship-outline images

- **Work/evidence:** Traced game 15's flag-selected four-block reads from disk-2
  blocks 29 and 33 to library 24's native HGR decompressor. Extracted the complete
  1,687-byte and 1,560-byte consumed streams, plus the identical 1,687-byte copy
  at disk-1 block 188. Added raw streams, reversible packet listings, decoded
  8 KB HGR pages, previews, manifests, and adoption recipes.
- **Visual/boundary review:** Decoded previews show a full ship outline and a
  shorter ship section. Every adopted byte is a header/control/payload byte
  consumed by the renderer. Fetched tails remain unresolved, including the $01
  just beyond the second stream; no invented terminator or padding rule is used.
- **Validation:** Three new codec tests cover literal/repeated runs, high bits,
  clipping at the native page boundary, malformed input, and trailing packet
  rejection. All pass. Packet encodings round-trip exactly and the shared copy
  matches. Adoption, full builds, original hashes, and exact disk checks pass.
  No fresh emulator rendering of these images is claimed.
- **Coverage:** 152,679 source-built bytes, 25,414 asset bytes, 108,627 temporary
  bytes (56,757 disk 1; 51,870 disk 2).
- **Next action:** Follow the tile-image bank consumer for disk-2 blocks 9–28
  and its disk-1 copies, then return to remaining raw code and persistent data.

## 2026-09-18 — Step 07f: extract four complete 32-row tile banks

- **Work/evidence:** Traced game 21's four-block indexed loader and modulo-four
  bank selection to disk-2 blocks 9–24. Library 23 procedure 3's 32-row path
  multiplies map indices by 128 and copies four bytes per row from the two
  adjacent buffers. Extracted all 64 tiles and the exact disk-1 copies of banks
  0/1 at blocks 176–183, replacing 12,288 temporary disk bytes.
- **Artifacts/review:** Added per-bank raw data, reversible row listings, atlases,
  manifests, adoption recipes, extractor, and consumer documentation. Visually
  reviewed the dotted terrain and building-like frames/shapes. Preserved all HGR
  phase bits; previews are monochrome masks with numeric tile labels.
- **Validation:** Two tile tests verify row/record boundaries, full-byte round
  trips, and malformed inputs. Extraction independently checks baseline hashes,
  shared-copy equality, and every row-list inverse. All four adoptions, builds,
  original-input checks, and complete disk comparisons pass.
- **Limits:** The fifth, 24-row bank is excluded pending its separate format/tail
  analysis. No fresh emulator trace or rendered-map comparison is claimed.
- **Coverage:** 152,679 source-built bytes, 37,702 asset bytes, 96,339 temporary
  bytes (52,661 disk 1; 43,678 disk 2). Overall completion still requires full
  classification, older provisional native-region review, and final behavior checks.
- **Next action:** Resolve the 24-row tile bank and packed world-map consumer,
  then continue the remaining native fragments and persistent data buffers.

## 2026-09-18 — Step 07g: world-map tiles and terrain variants

- **Work/evidence:** Resolved the fifth image bank's 24-row layout. Library 23
  draws 96-byte records; its map decoder emits indices 0–13, and game 21's
  postprocessing explicitly replaces index 13 with variants 14–20. Extracted
  all 21 records and the exact disk-1 copy, replacing 4,032 disk bytes.
- **Artifacts/limits:** Added raw tile data, reversible row listing, atlas,
  manifest, adoption recipe, and consumer notes. Extended the tile tool with
  explicit height/count layouts. The 32 fetched bytes after each confirmed
  bank remain excluded. The atlas shows stored masks, not runtime variant choices.
- **Validation:** All three tile tests pass, including 96-byte boundary checks
  and rejection of the extra tail. Shared copies and inverse packing match.
  Adoption, build, original hashes, and both exact full-disk comparisons pass.
- **Coverage:** 152,679 source-built bytes, 41,734 asset bytes, 92,307 temporary
  bytes (50,645 disk 1; 41,662 disk 2).
- **Next action:** Decode and extract the packed world-map records through
  library 23's confirmed two-bit state machine, retaining unclassified prefixes.

## 2026-09-18 — Step 07h: packed world-map payloads; pause checkpoint

- **Work/evidence:** Traced game 21's world-indexed loads to disk-2 blocks 55–63,
  with 256-byte records and a 16-byte prefix skipped before native decoding.
  Extracted all 18 240-byte payloads and two exact disk-1 copies at block 194,
  replacing 4,800 disk bytes. Kept every prefix explicitly unresolved.
- **Format/artifacts:** Modeled library 23's low-pair-first two-bit reader and
  14-state table, resetting state 12 per row. Added original payloads, reversible
  40×24 symbol grids, decoded tile grids, manifest, adoption recipe, and overview.
  Visually reviewed all maps. Symbols remain the lossless representation because
  distinct state transitions can produce the same tile. Random variants and city
  overlays are separate runtime changes.
- **Validation:** Three map tests pass: bit-pair order/inverse, known state
  sequences and row resets, and malformed input rejection. Extraction checks
  the transition table against the source-built native library, both disk hashes,
  all symbol round trips, and duplicate payloads. Adoption, full build, original
  input verification, and both exact full-disk comparisons pass.
- **Coverage:** 152,679 source-built bytes, 46,534 asset bytes, 87,507 temporary
  bytes (50,165 disk 1; 37,342 disk 2). Final classification and both-emulator
  behavior checks remain incomplete; no new live map capture is claimed.
- **Pause:** User requested a pause after the current task. This extraction is
  complete and committed; no next task is started. On explicit resumption,
  continue remaining native fragments, persistent data, and record/container tails.

## 2026-09-20 — Step 08b: resume and reconstruct Pascal directory data

- **Resume:** User explicitly resumed the project after step 07h's requested
  pause. The same PRD classification, independent-build, logging, and per-step
  commit requirements continue to apply.
- **Work/evidence:** Reconstructed disk-1 blocks 79–82 as typed Pascal directory
  records. The existing full-buffer boot capture, native 26-byte record scanner,
  library 26's alternate-directory reads, and utility-entry write receipt support
  the classification. Replaying the recorded writes makes directory 79 exactly
  match directory 80. Block 82's three inactive records retain SYSTEM.PASCAL's
  fields with cleared name lengths; its demo selection is not newly live-traced.
- **Artifacts:** Added tools/prepare_directory_tables.py, explicit ca65 data
  source/config/adoption recipe, docs/pascal-directories.md, and a structured
  field report. Three unique 512-byte tables supply four directory blocks.
  Fixed-width name residue, raw dates, reserved bytes, inactive records, and
  zero-filled unused directory capacity are preserved. No code is inferred
  from filesystem file-type values.
- **Validation:** Generator assembles exactly before writing artifacts. Three
  deliberate mutations to spare storage/inactive records were rejected. All
  three disk-layout tests and four adoption tests pass. Ran adoption, full
  build, and tools/verify_disks.py: both images remain byte-identical to their
  originals. Existing behavior baselines are reused under PLAN.md; no new
  emulator capture or final behavior-validation completion is claimed.
- **Coverage:** 154,727 source-built disk bytes, 46,534 classified asset bytes,
  85,459 temporary bytes (48,117 disk 1; 37,342 disk 2).
- **Next action:** Continue tracing persistent game-data records and remaining
  native fragments; retain evidence requirements for every unresolved tail.

## 2026-09-20 — Step 07i: inventory and cargo name-table variants

- **Work/evidence:** Traced play and demo startup loads to disk-2 blocks 46–47
  and disk-1 blocks 192–193. Library 27 indexes inventory names at $1600 with
  a 16-byte stride and passes counted strings to the renderer. Game 20 loads
  cargo names at $5800, checks record 31 against `cryogens`, and independently
  reads record byte 15 using a five-bit cargo ID. Demo loading and matching
  record structure identify the corresponding variant.
- **Artifacts:** Added tools/item_name_asset.py, three codec tests,
  docs/item-names.md, and demo/play assets with original record bytes,
  reversible JSON, manifests, and adoption recipes. All 128 records retain the
  counted name, residual fixed-width storage, and numeric byte. Zero-length
  names are not inferred from stale text; original variant differences remain.
  Exact meanings of all numeric values are optional further analysis.
- **Validation:** Three tests pass for nontext residue/value preservation,
  zero-length names, and rejection of malformed records or field-width edits.
  Extraction checks both rebuilt disk hashes, temporary ownership, and exact
  record round trips. `--verify assets/item-names` passes. Adopted each variant
  with a rebuild between adoptions, then ran tools/verify_disks.py: both images
  are exact and original inputs unchanged. No new live emulator run is claimed.
- **Coverage:** 154,727 source-built bytes, 48,582 identified data/asset bytes,
  83,411 temporary bytes (47,093 disk 1; 36,318 disk 2).
- **Next action:** Continue persistent-state/map-record classification and raw
  executable fragments. Final both-emulator behavioral validation remains open.
