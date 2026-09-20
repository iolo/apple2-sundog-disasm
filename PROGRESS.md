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

## 2026-09-20 — Step 07j: packed city-map payloads

- **Work/evidence:** Traced game 21 procedure 26's city-indexed reads to
  disk-2 blocks 64–78: four 128-byte records per block, each skipping eight
  bytes before a 120-byte map. Alternate 7/9's demo path identifies four more
  distinct records at disk-1 block 195. Extracted only the evidenced payloads.
- **Format/artifacts:** Added tools/city_map_asset.py, three tests,
  docs/city-maps.md, and assets/city-maps with packed bytes, reversible tile
  grids, manifest, adoption recipe, and overview. The p-code loops and native
  packed-field handlers establish 20 columns by 12 rows, six bytes per column,
  low nibble first. Runtime random variants and clipping remain separate.
  Visually reviewed all 64 decoded grids. The 512 prefix bytes remain temporary.
- **Validation:** Three tests pass for explicit column/nibble order, bidirectional
  packing, and malformed shape/value rejection. Extraction verifies both rebuilt
  disk hashes, temporary ownership, and every payload round trip; asset verification
  passes for all 7,680 bytes. Adoption, full build, and tools/verify_disks.py pass:
  original inputs unchanged and both rebuilt images exact. No new live emulator
  capture or final behavior-validation completion is claimed.
- **Coverage:** 154,727 source-built disk bytes, 56,262 identified data/asset
  bytes, 75,731 temporary bytes (46,613 disk 1; 29,118 disk 2).
- **Next action:** Trace persistent-state banks and remaining raw code/data;
  keep unknown record prefixes and file tails explicit until evidenced.

## 2026-09-20 — Step 07k: saved-game payloads and slot descriptors

- **Work/evidence:** Traced library 26's save selection and startup 7's inverse
  load/save transfers. Disk-1 banks at blocks 27, 37, 47, and 57 contain a
  512-byte globals snapshot, 3,072 bytes of indexed gameplay records, and
  1,440 bytes of world-table data. Game 20 supplies the 16-/32-byte record
  consumers. Extracted only those 5,024 evidenced bytes per bank, leaving each
  nonzero 96-byte tail unresolved. Utility iteration identifies four 64-byte
  slot descriptors in the first half of block 26; its other half stays temporary.
- **Artifacts:** Added tools/save_state_asset.py, three tests, field/source evidence
  in docs/save-state-banks.md, and packed/structured assets with explicit section
  boundaries. Preserved names, residual name storage, packed words, and all
  descriptor fields without assigning unsupported meanings. Classified 20,352
  disk bytes as data; no executable classification is implied by checksums.
- **Validation:** Native library 26's independent even/odd byte-sum model matches
  every full ten-block bank and descriptor: Hawkmoon $8CAF, Starrion $EE29,
  Brother Wolf $F411, Blackblade $B77A. Tests cover independent-lane overflow,
  checksum mutation, section boundaries/record round trips, malformed dimensions,
  and descriptor residue/checksum preservation. Extraction checks current rebuilt
  disk hash and exclusive temporary ownership; asset verification passes.
  Adopted payloads and descriptors with rebuilds between adoptions. Full build
  and tools/verify_disks.py pass: both images exact and original inputs unchanged.
- **Coverage:** 154,727 source-built disk bytes, 76,614 identified data/asset bytes,
  55,379 temporary bytes (26,261 disk 1; 29,118 disk 2). Existing exact-image
  emulator baselines are reused; no live save/load validation is newly claimed.
- **Next action:** Trace the initial/working-state copies, world-table templates,
  and remaining native fragments. Final both-emulator save/load and gameplay
  checks remain required.

## 2026-09-20 — Step 07l: templates and working gameplay data

- **Work/evidence:** Utility procedure 14 identifies disk-1 block 22 as eighteen
  28-byte record templates plus a selector at byte 504. Game 20 independently
  consumes the identical template at disk-2 block 45; block 2 is another exact
  stored copy. These are templates, not globals snapshots. Classified only 505
  bytes per occurrence and retained the seven-byte tails as temporary.
- **Further data:** Utility initialization copies 1,440 bytes from disk-1 blocks
  23–25 into the three world-table regions; retained its 96-byte allocation tail.
  Startup 7's inverse save/load transfers and game 20's indexed edits identify
  disk-2 blocks 48–53 as working 16-/32-byte gameplay records. Preserved their
  original contents independently of the four saved-game snapshots.
- **Artifacts:** Added tools/working_state_asset.py, three tests,
  docs/working-state.md, and assets/working-state with packed data, reversible
  fields, manifest, and adoption recipe. The 5,017 unique source bytes map to
  6,027 disk bytes. Individual packed-field meanings remain optional analysis;
  data classification rests on the explicit consumers and transfer boundaries.
- **Validation:** Tests pass for template/selector separation, every word layout,
  malformed dimensions/values, and rejection of unreviewed tails. Extraction
  verifies both rebuilt hashes, three template copies, temporary ownership,
  and exact field round trips. Asset verification, adoption, full build, and
  tools/verify_disks.py pass; both disk images are exact and inputs unchanged.
  No new emulator observation or live save/load completion is claimed.
- **Coverage:** 154,727 source-built disk bytes, 82,641 identified data/asset bytes,
  49,352 temporary bytes (24,316 disk 1; 25,036 disk 2).
- **Next action:** Continue remaining graphics/raw-code consumers and record tails;
  final complete code/data audit and both-emulator validation remain required.

## 2026-09-20 — Step 07m: animated SUNDOG letter frames

- **Work/evidence:** Library 26 procedure 14 loads disk-1 blocks 67–78 into
  $4000. Native procedure 11 addresses $4000 + letter*1024 + selector*128 and
  copies four bytes per row for 24 rows, forcing the video phase bit high.
  Extracted six groups of eight stored 28x24 frames; visually confirmed the
  SUNDOG letters in the atlas. Recorded the selector-eight boundary behavior
  without inventing a ninth stored frame or claiming a live trace.
- **Artifacts:** Added tools/logo_frame_asset.py, three tests, docs/logo-frames.md,
  and assets/logo-frames with full records, reversible row bytes, manifest,
  adoption recipe, and atlas. Classified all 6,144 bytes: 4,608 bitmap bytes and
  1,536 zero bytes in the repeated aligned record-padding fields. The extractor
  rejects nonzero padding and preserves every source bitmap bit.
- **Validation:** Tests pass for record/group strides, last-row boundaries,
  full-byte preservation, padding mutation rejection, and invalid extent/shape.
  Extraction checks the rebuilt disk hash, temporary ownership, every padding
  field, and exact record round trips. Asset verification, adoption, full build,
  and tools/verify_disks.py pass; both disks remain exact and originals unchanged.
  Reviewed all 48 frames visually. No new live animation capture is claimed.
- **Coverage:** 154,727 source-built disk bytes, 88,785 identified data/asset bytes,
  43,208 temporary bytes (18,172 disk 1; 25,036 disk 2).
- **Next action:** Continue remaining play-side graphics/data, native fragments,
  and record tails; final both-emulator behavioral validation remains required.

## 2026-09-20 — Step 07n: interaction-window bitmap and position fields

- **Work/evidence:** Game 18 procedure 20 reads disk-2 blocks 37–40 into $1800
  for its type-16 interaction branch. Library 22 procedure 15 swaps/copies exactly
  96 rows of twenty bytes, using the previously runtime-verified linear row tables.
  This identifies a 140x96 bitmap. Game 18 and library 22 also write/read saved
  byte-column and row fields at allocation offsets 2000–2001.
- **Artifacts:** Added tools/window_asset.py, two tests,
  docs/interaction-window.md, and assets/interaction-window with packed bitmap/
  position bytes, reversible fields, manifest, adoption recipe, and monochrome
  preview. Visually reviewed the framed container/panel shape. Preserved all
  source phase bits. Adopted 1,922 bytes; retained the other 126 allocation bytes,
  including nonzero file-record-like residue, as temporary.
- **Validation:** Tests pass for row boundaries, full-byte/phase preservation,
  coordinate separation, and invalid extent/shape/value rejection. Extraction
  verifies the rebuilt disk hash, temporary ownership, and exact field round trip.
  Asset verification, adoption, full build, and tools/verify_disks.py pass: both
  disk images remain exact and originals unchanged. No new live window interaction
  or final emulator-validation completion is claimed.
- **Coverage:** 154,727 source-built disk bytes, 90,707 identified data/asset bytes,
  41,286 temporary bytes (18,172 disk 1; 23,114 disk 2).
- **Next action:** Continue remaining native fragments, dialogue/data banks, and
  record tails; final full classification and both-emulator checks remain required.

## 2026-09-20 — Step 06ad: play-disk boot native code and FLIP DISK notice

- **Work/evidence:** Reconstructed the play disk's first 193 bytes as 93 native
  instructions (192 bytes) and one ROM boot-count field. Traced the four-plane
  RLE decoder at $0812–$0896 and extracted its exact 576-byte input at logical
  offsets 256–831. The decoded HGR page contains a floppy icon and FLIP DISK.
  Boot-sector bytes 193–255 and block-1 bytes 320–511 remain unresolved.
- **Artifacts:** Added ca65 source/config, evidence/adoption recipes, full raw
  instruction audit, tools/play_boot_asset.py, and assets/play-boot with packet
  description, compressed input, decoded page, preview, and manifest. Extended
  the existing RLE codec to evidenced stride four; retained exact packet controls
  and plane-boundary clipping. Added docs/play-disk-boot.md and runtime capture
  metadata/screenshot under docs/reference/play-boot.*.
- **Runtime validation:** Used the a2-mame skill with an owned MAME 0.285 apple2e
  process, verified ROMs, and isolated rebuilt media. Unmodified execution reached
  PC $08AC. Captured $0800–$0DFF matches the first six logical sectors except
  $0800 changes from one to eleven. Decoder input ends at $0B40, stride/plane are
  both four, and all 8,192 live HGR bytes match the static decode. Reviewed the
  screenshot; copied media remained unchanged and the owned process exited cleanly.
  This does not claim acknowledgement, disk-swap, save/load, or final dual-emulator
  completion.
- **Validation:** All four RLE tests pass, including interleaved planes and
  clipped literal/repeat packets at each plane boundary. Existing ship assets
  still decode/repack exactly. Native preparation covers every selected byte and
  assembles exactly; notice verification, adoption, full build, and disk verifier
  pass. Both rebuilt disks remain exact and original inputs are unchanged.
- **Coverage:** 154,920 source-built disk bytes, 91,283 identified data/asset bytes,
  40,517 temporary bytes (18,172 disk 1; 22,345 disk 2).
- **Next action:** Continue remaining record/dialogue banks and native fragments,
  then finish the full classification audit and both-emulator validation.

## 2026-09-20 — Step 07o: interaction bounds/style/parameter records

- **Work/evidence:** Game 18 procedure 16 reads disk-2 block 79 into $4000,
  selects records with a 16-word/32-byte stride, and consumes five packed bounds
  groups, two style nibbles, one drawing value, two biased offsets, and two numeric
  parameters. Procedure 17 unpacks each bounds group and calls library 22's
  bounds/drawing routines. Classified the repeated six-byte zero tails as aligned
  record storage, with nonzero tails rejected. Disk-1 block 196 offsets 128–511
  exactly duplicate records 4–15; its differing first 128 bytes remain unresolved.
- **Artifacts:** Added tools/interaction_record_asset.py, three tests,
  docs/interaction-records.md, and assets/interaction-records with reversible
  fields, 512 source bytes, manifest, and adoption mappings for 896 disk bytes.
  The adjacent glyph-like block 80 remains unresolved pending consumer evidence.
- **Validation:** Tests pass for field and record boundaries, nibble order,
  biased offset extremes, exact round trips, padding mutation, and invalid shapes
  or values. Extraction checks rebuilt hashes, every stored-copy byte, temporary
  ownership, and full field inversion. Verification, adoption, build, and disk
  comparison pass; both images remain exact and original inputs unchanged.
  No fresh live interaction trace or final dual-emulator completion is claimed.
- **Coverage:** 154,920 source-built disk bytes, 92,179 identified data/asset bytes,
  39,621 temporary bytes (17,788 disk 1; 21,833 disk 2).
- **Next action:** Investigate the mixed disk-1 prefix and remaining dialogue,
  graphics, and native fragments; finish full classification and both-emulator
  validation before declaring completion.

## 2026-09-20 — Step 07p: base dialogue dictionary and supplemental text

- **Investigation:** The mixed 128-byte prefix in disk-1 block 196 has no exact
  match among current reconstructed components. Kept it unresolved; appearance
  alone does not establish p-code. Continued with evidenced dialogue consumers.
- **Work/evidence:** Game 16 procedure 37 reads blocks 88–89 to $4A00.
  Procedures 31/12 reconstruct 65 low-byte offsets using page-crossing indices;
  the initial dictionary ends at byte 808. Procedure 13 reads its text with
  alternative markers, high-bit word spacing and character substitutions.
  Procedures 34/32 load twelve supplemental banks and copy 57 counted text
  records, aligning each next record to an even address. Verified the FJP
  bit-zero test in the native interpreter rather than treating it as nonzero.
- **Artifacts:** Added tools/dialogue_dictionary_asset.py, three tests,
  docs/dialogue-dictionary.md, and assets/dialogue-dictionary with readable,
  reversible stored characters/high-bit positions, raw dictionary bytes,
  manifest and sparse adoption mappings. Classified 808 base bytes and 1,122
  supplemental bytes: 1,002 text, 57 lengths, 27 zero alignment, 36 metadata.
  Script regions, block 98, base tail 808–1023 (including final nonzero $A0),
  and other bank tails remain excluded and unresolved.
- **Validation:** Tests pass for wrapped low-byte pointers, empty entries, all
  stored byte values, counted-record boundaries, word alignment, invalid flags,
  malformed lengths and exclusion of extra tails. Extraction verifies rebuilt
  hash, temporary ownership, all pointers/counts and exact inverse encoding.
  Asset verification, adoption, full build and original comparison pass; both
  disks remain exact and original inputs unchanged. No new live dialogue
  observation or final both-emulator completion is claimed.
- **Coverage:** 154,920 source-built disk bytes, 94,109 identified data/asset bytes,
  37,691 temporary bytes (17,788 disk 1; 19,903 disk 2).
- **Next action:** Trace the custom dialogue script decoder and remaining text,
  then continue mixed fragments, full classification and both-emulator checks.

## 2026-09-20 — Step 06ae: custom dialogue scripts and referenced messages

- **Work/evidence:** Traced game 16 procedures 15 and 23–29 to establish the
  packed script header, state/message selectors, conditional transitions,
  reply pairs and variable-length actions. Confirmed the early EXIT(16,23)
  through the native CSP 4 vector/handler, preventing a false fall-through into
  text. Parsed every nonzero entry in the sixteen-byte tables of blocks 90–102:
  96 records, 979 script bytes. All internal record ends agree independently
  with the next stored pointer. Reconstructed 196 remaining entry-table bytes;
  twelve dual-use entry-zero bytes remain owned by the prior dictionary asset.
- **Artifacts:** Added tools/dialogue_script.py and preparation/verification
  tool, four tests, src/dialogue with explicit ca65 script-format macros and
  disassembled records, and docs/reference/dialogue-scripts.json with every
  operation, boundary and reference. Added docs/dialogue-scripts.md and extracted
  assets/dialogue-messages: 160 length-prefixed messages, 3,195 text bytes,
  160 length bytes and 79 checked zero alignment bytes. Source and message
  adoption recipes map the selected ranges; arbitrary gaps/tails remain unresolved.
- **Validation:** Tests pass for early conditional transfer termination, mood
  selectors, predicate-dependent operand lengths, action operands, overlapping
  entry/text rejection, unsupported selectors/actions and alignment mutations.
  Preparation verifies the exact rebuilt image, temporary ownership, all text
  bounds and byte-identical ca65 assembly. Asset verification also reruns the
  complete bank parser against its recorded audit and checks macro definitions.
  Both adoptions, full builds and original comparisons pass; both images remain
  exact and original inputs unchanged. No new live dialogue interaction or final
  both-emulator completion is claimed.
- **Coverage:** 156,095 source-built disk bytes, 97,543 identified data/asset bytes,
  33,082 temporary bytes (17,788 disk 1; 15,294 disk 2).
- **Next action:** Review unreferenced dialogue/text residues and remaining mixed
  fragments, then finish the full code/data audit and both-emulator checks.

## 2026-09-20 — Step 07q: complete dialogue-bank layout classification

- **Work/evidence:** Walked every counted message from the end of each bank's
  supplemental dictionary (or first referenced text in unsupplemented block 98).
  Every known reference is on a sequential record boundary, and all thirteen
  walks end exactly at byte 512. Identified five additional complete messages
  occupying 60 bytes. The 865 bytes between decoded script ends and evidenced
  text starts are zero-filled spare script storage within these structured banks;
  classification uses the complete bank layout, not arbitrary zero runs or lack
  of execution. Nonzero spare bytes are rejected rather than classified.
- **Artifacts:** Added tools/dialogue_bank_remainder.py, two tests,
  docs/dialogue-bank-layout.md, and assets/dialogue-bank-storage with typed fill/
  message fields, data, adoption mappings, and every complete message boundary.
- **Validation:** Tests pass for unused-message discovery and rejection of
  nonzero gaps, truncated/zero-length records, and references into record interiors.
  Extraction verifies rebuilt hash, temporary ownership and exact field inversion;
  asset verification reruns all thirteen layout audits. Adoption, full build and
  original comparison pass; both disks remain exact and original inputs unchanged.
  Independently checked every byte of blocks 90–102: 1,175 source-built bytes,
  5,481 identified-data bytes, and zero temporary bytes. No new live dialogue or
  final emulator-validation completion is claimed.
- **Coverage:** 156,095 source-built disk bytes, 98,468 identified data/asset bytes,
  32,157 temporary bytes (17,788 disk 1; 14,369 disk 2).
- **Next action:** Continue encrypted/packed graphics and mixed residual regions,
  then complete the whole-disk classification audit and both-emulator checks.

## 2026-09-20 — Step 06af: encoded native overlay loader entries

- **Finding:** The play bank at blocks 41–44 decodes to obfuscated native code,
  not graphics. Utility's word-58 parameters provide seed 189/increment 243;
  the game-15 loader/transform call independently establishes that decoding.
  Word-56's seed 251/increment 185 reveals a related native bank at disk-1
  blocks 197–200, with its destination/body call relocated by $0400. A live
  load or invocation of the latter bank is not claimed.
- **Work/evidence:** Disassembled both 63-byte position-independent entry loaders,
  37 instructions each. Each obtains its own address through an RTS written at
  zero page zero, swaps a 1,994-byte region into low memory, calls the body, and
  swaps it back before returning. Recorded the nine-byte overread beyond the
  four-block source buffer without inventing its runtime contents. The following
  NOP and obfuscated bodies remain unresolved; no executable bank is hidden in
  an identified-data asset.
- **Artifacts:** Added tools/storage_encoding.py and four tests; taught raw
  preparation, source adoption and the build to preserve a documented additive
  storage encoding after assembly. Added both source/config/evidence/adoption
  sets, complete raw entry audits, and docs/encoded-native-overlay.md. The normal
  build retains both decoded and disk-encoded component artifacts and reads no
  original images. The existing raw transform's SHIP writes are outside the
  encoded buffers and do not affect reversible disk encoding.
- **Validation:** Thirteen encoding/adoption/raw-decoder tests pass, including
  known byte vectors, full byte-domain round trips, split-stream phase, malformed
  encodings, and rejection of unencoded adoption input. Both native preparations
  cover every selected byte and assemble exactly. Both adoptions, full builds
  and comparisons pass; both disk images remain exact and originals unchanged.
  No live execution of the decoded entries or final emulator completion is claimed.
- **Coverage:** 156,221 source-built disk bytes, 98,468 identified data/asset bytes,
  32,031 temporary bytes (17,725 disk 1; 14,306 disk 2).
- **Next action:** Trace the swapped native bodies and their indirect-jump layout;
  continue the remaining whole-disk classification and both-emulator validation.

## 2026-09-20 — Step 06ag: encoded native body graphs and bounded source slices

- **Work/evidence:** Followed the loader's fixed body entry through 126 reviewed
  indirect vectors per bank. The reachable graph plus one evidenced disconnected
  stub comprises 448 instructions / 1,079 code bytes in each variant, without
  code/data overlap. Identified 418 data bytes per bank: vector words, constants,
  track/symbol tables, mutable read/seek state, wipe-start pointer, and individually
  reviewed repeated obfuscation delimiters. Both variants have matching edges and
  delimiter bytes. Ordinary writes do not modify the reviewed jump vectors; the
  separate nonreturning memory-wipe path is explicitly excluded from that premise.
- **Boundaries:** Two other disconnected jump-shaped stubs lead into ambiguous
  pointer/opcode bytes and remain unresolved with their associated gaps. The
  suffix includes copied native material and is not classified as padding. Eight
  fully classified intervals per bank are emitted as separate components, with
  their actual runtime addresses and encoding phases. No omitted byte is emitted,
  and every assembled byte has a disk mapping. There remain 488 unresolved bytes
  per encoded bank; full reconstruction and live invocation are not claimed.
- **Artifacts:** Added strict reviewed indirect-jump handling and classified-slice
  emission to tools/native_raw_source.py; added tools/prepare_encoded_overlay.py,
  both full-bank evidence/graph reports, sixteen source/config/adoption sets,
  docs/encoded-native-overlay-body.md, and updated the loader document and plan.
- **Validation:** Sixteen raw-decoder/encoding/adoption tests pass, including
  NMOS indirect-vector page wrapping, changed-pointer and missing-data rejection,
  partial-instruction/gap rejection, and assembling a cross-slice relative branch.
  Preparation independently assembles and re-encodes all sixteen slices exactly;
  both --verify runs reproduce every artifact. Each adoption was followed by a
  full exact build. tools/verify_disks.py confirms both originals and rebuilt disk
  hashes, plus unchanged manual input. git diff --check passes. No new live
  emulator or final behavioral-validation completion is claimed.
- **Coverage:** 159,215 source-built disk bytes, 98,468 identified data/asset bytes,
  29,037 temporary bytes (16,228 disk 1; 12,809 disk 2). This checkpoint removes
  2,994 temporary bytes: 2,158 instructions and 836 source-owned data bytes.
- **Next action:** Resolve the encoded-bank disconnected stubs and duplicated
  suffix code/data, then continue remaining disk classification and final checks
  in both emulators. The resumed goal remains active.

## 2026-09-20 — Step 06ah: native footer and copied encoded-bank tails

- **Work/evidence:** Parsed each decoded bank through offset $0638 as a native
  Pascal segment with one procedure: entry zero, native attributes at $0632,
  four zero relocation counts starting at $0628, dictionary pointer at $0634,
  and segment/procedure trailer at $0636. Classified the preceding alignment
  byte and all footer fields (17 bytes per bank).
- **Copied code/data:** Proved that offsets $0638–$07FF copy $0438–$05FF with only
  the independently identified wipe-start pointer changed to a zero initializer.
  Transferred proven instruction/data ownership only: 140 complete instructions,
  two precisely identified clipped instructions, and 120 data bytes per copy.
  Source reconstructs the leading BCC displacement and trailing absolute-LDA
  opcode with their complete original instruction context; no missing operand
  bytes are invented. Nine copied bytes inherit their originals' unresolved
  status. Each bank now has 24 unresolved bytes, including 15 in the earlier body.
- **Artifacts:** Added tools/encoded_overlay_tail.py, three tests, full tail audits,
  fourteen source/config/adoption sets, docs/encoded-native-overlay-tail.md,
  and updated the plan and related overlay documents. The ordinary build retains
  independent source inputs and exact per-slice storage encoding phases.
- **Validation:** Nineteen tail/raw/encoding/adoption tests pass. New tests reject
  malformed metadata, changed copies, unexpected pointer initialization, and
  unsupported partial-instruction context; they verify gap preservation and
  assembly of complete and clipped instruction slices. Both tail --verify runs
  reproduce every artifact. Each adoption was followed by a full exact build;
  tools/verify_disks.py confirms both disk images and originals/manual unchanged.
  git diff --check passes. No live-body or final emulator validation is claimed.
- **Coverage:** 160,143 source-built disk bytes, 98,468 identified data/asset bytes,
  28,109 temporary bytes (15,764 disk 1; 12,345 disk 2). This checkpoint removes
  928 temporary bytes: 654 code bytes and 274 source-owned data bytes.
- **Workspace:** A concurrent PRD.md edit adds two UCSD p-system reference links.
  It is preserved and excluded from this implementation commit.
- **Next action:** Continue the unresolved native stubs/state fields and the
  remaining disk regions, retaining the complete classification requirement;
  complete gameplay/save/load/swap/utility checks in both emulators afterward.

## 2026-09-20 — Step 06ai: preserved copies of disassembled p-code ranges

- **Work/evidence:** Reviewed 26 extended exact copies of 17 fully disassembled
  Pascal source components in previously unresolved disk extents. Each frozen
  extent matches at least 64 consecutive, nontrivial bytes, with its entire copy
  hash and source audit recorded. Freshly assembled every source module, checked
  hashes and interpreter dispatch evidence, and reran complete module analysis.
  Transferred explicit per-item instruction/data ownership, not a generic label
  based only on byte matching. The copies include disk-1 blocks 147–149, repeated
  block 150, numerous partial module tails, and three saved-bank suffixes.
- **Representation:** Added disk mappings to existing assembled components. No
  additional executable binary input, extraction dependency, or opaque source
  fragment is introduced. The audit records each copied item's complete source
  assembly, source boundaries, classification and clipped ends. Twenty-three
  instruction items have clipped boundaries; their full instructions remain in
  the existing source. All 8,030 selected disk bytes have evidenced ownership.
- **Artifacts:** Added src/pcode/evidence/preserved_copies.json,
  docs/reference/preserved-pcode-copies.json, docs/preserved-pcode-copies.md,
  tools/pcode_copies.py and three tests. Factored the existing adoption tool's
  temporary-region replacement so verified source slices can be reused safely;
  updated PLAN.md. The concurrent PRD reference edit remains preserved/uncommitted.
- **Validation:** Eleven copy/adoption/encoding tests pass, including unchanged
  input manifests, exact rebuilt bytes, clipped code/data boundaries, rejection
  of uncovered source bytes, changed sources/disks, stale baselines, overlapping
  outputs, invalid bounds and replacement of already classified bytes. Complete
  source reanalysis agrees with all 17 prior coverage audits. Batch adoption,
  full build, post-adoption ownership/audit verification and original comparison
  pass; original disks/manual remain unchanged. git diff --check passes.
  No runtime use of preserved copies or final emulator completion is claimed.
- **Coverage:** 168,173 source-built disk bytes, 98,468 identified data/asset bytes,
  20,079 temporary bytes (10,744 disk 1; 9,335 disk 2). This checkpoint removes
  8,030 temporary bytes: 6,805 code bytes and 1,225 source-owned data bytes.
- **Next action:** Analyze remaining source variants/orphan fragments, structured
  asset headers and bank padding; continue the complete classification audit and
  final gameplay/save/load/swap/utility checks in both emulators.

## 2026-09-20 — Step 06aj: copies from the early startup/utility audits

- **Work/evidence:** Extended the reviewed source-copy corpus to the complete
  step-06g startup and step-06h utility audits, which predate the later module
  audit directory. Identified fifteen exact ranges totaling 2,538 bytes: two
  448-byte startup copies at block 142 offset 64, and thirteen utility ranges
  in disk-1 blocks 151–155. Surrounding modified utility bytes remain unresolved;
  no complete historical utility module or runtime invocation is inferred.
- **Artifacts:** Added src/pcode/evidence/early_module_copies.json,
  docs/reference/early-module-copies.json and docs/early-module-copies.md;
  updated PLAN.md. tools/pcode_copies.py now accepts explicit repository-local
  recipe/audit paths while preserving the existing default checkpoint.
- **Validation:** Seven copy/adoption tests pass. Both modules freshly assemble
  to their reviewed hashes and their complete reanalysis matches the original
  classification counts. Batch adoption, full exact build, both the old and new
  copy-audit/ownership verifiers, and original disk/manual comparison pass.
  git diff --check passes. No new live emulator validation is claimed.
- **Coverage:** 170,711 source-built disk bytes, 98,468 identified data/asset bytes,
  17,541 temporary bytes (8,654 disk 1; 8,887 disk 2). The new copies contain
  1,759 instruction bytes and 779 source-owned data bytes.
- **Workspace:** The concurrent PRD reference-link edit remains untouched and
  excluded from this implementation commit.
- **Next action:** Continue the remaining variant/orphan code and bounded asset
  headers/storage, followed by the whole-disk audit and both-emulator checks.

## 2026-09-20 — Step 07r: bounded world/city map record prefixes

- **Work/evidence:** Classified the 16-byte prefixes of twenty world-map records
  and eight-byte prefixes of sixty-four city-map records as structured data.
  The consumer code independently establishes each record stride, explicit
  prefix skip and exact payload extent. Repeated prefix patterns, the complete
  fixed-record layout, and exact adjacent payload ownership support classification;
  precise field meanings remain unspecified. Retained the exceptional world
  bit pattern, alternating D5/AA prefixes, city-0 prefix and all-$11 city-59 prefix.
- **Artifacts:** Added assets/map-record-prefixes with all 832 bytes, reversible
  first-word/remaining-byte fields, record-to-payload provenance, and adoption
  mappings. Added tools/map_prefix_asset.py, three tests, docs/map-record-prefixes.md,
  and updated the world/city map documents and PLAN.md. No bytes outside the
  evidenced records or unrelated zero runs are included.
- **Validation:** Three tests pass for all 84 record identities, inverse field
  encoding and rejection of changed patterns, wrong identities, field sizes and
  byte bounds. Extraction checks both disk hashes, both existing payload sources,
  each adjacent payload's exact bytes and actual manifest ownership, and every
  reviewed prefix pattern. Adoption, full exact build, independent asset
  verification and original disk/manual comparison pass. A separate per-byte
  ownership check confirms that all 13,312 bytes of the complete world/city map
  banks are identified data, with no temporary byte remaining in those banks.
  git diff --check passes. No new live-map/emulator completion is claimed.
- **Coverage:** 170,711 source-built disk bytes, 99,300 identified data/asset bytes,
  16,709 temporary bytes (8,590 disk 1; 8,119 disk 2).
- **Workspace:** The concurrent PRD reference-link edit remains untouched and
  excluded from this implementation commit.
- **Next action:** Continue remaining variant/orphan code, bounded file/asset
  storage, and provisional classification audits; complete final emulator checks.

## 2026-09-20 — Step 08c: intrinsic sets and bounded header-extension data

- **New evidence:** Followed the newly added p-system reference links to Apple's
  original Operating System Reference Manual, Appendix C, printed pages 267–269.
  It locates the 32-bit INTRINS_SEGS set immediately after SEGINFO, followed by
  library information and optional compiler comment text. This supplies format
  evidence beyond simple adjacency to the previously classified header tables.
  The online manual is cited in docs/pascal-header-extensions.md; no build or
  verifier downloads it. The second reference site returned HTTP 502; progress
  used the accessible primary Apple manual.
- **Work:** Verified intrinsic segment sets in all eight header occurrences.
  Six tails have zero library storage and bounded empty/copyright strings at
  $01B0, with verified zero remainder. Both block-103 copies have a separate
  counted 67-character command prompt at $01A2 plus bounded zero storage. Their
  surrounding 44+26 word-like bytes remain unresolved; an unspecified private
  format is not used to absorb potentially executable residual bytes.
- **Artifacts:** Added src/data/pascal_header_extensions.s/config/adoption,
  tools/header_extension_source.py, three tests, docs/reference/header-extensions.json,
  and docs/pascal-header-extensions.md. Updated the earlier table document and plan.
  Six unique data slices assemble to 1,050 bytes and map to 1,652 disk bytes.
- **Validation:** Three tests pass for bit numbering, counted comments, malformed
  lengths/text/masks, nonzero library/comment storage rejection, and explicit
  exclusion of unknown words around the prompt. Preparation checks each existing
  288-byte table hash, all new field boundaries, exact assembly and generated
  artifacts. Adoption, full exact disk build, and original disk/manual comparison
  pass. git diff --check passes. No new emulator validation is claimed.
- **Coverage:** 172,363 source-built disk bytes, 99,300 identified data/asset bytes,
  15,057 temporary bytes (7,316 disk 1; 7,741 disk 2). All 1,652 newly source-built
  bytes are classified data, not instructions. Six complete headers are now
  classified; only 140 bytes remain unresolved across the eight header blocks.
- **Workspace:** The concurrent PRD reference-link edit is preserved and excluded
  from this implementation commit.
- **Next action:** Continue remaining bounded asset storage, orphan/variant code
  and provisional runtime classifications, then final checks in both emulators.

## 2026-09-20 — Step 06ak: complete two single-block native overlays

- **Work/evidence:** Identified the retained JMP ($0004) after the transformer's
  RTS as an unused native tail transfer. The existing instructions zero $04,
  save and restore the initial page in $05, and preserve the caller's return
  address; the resulting pointer addresses the transformed $4000/$5800 buffer.
  The known path returns before this instruction, so live body execution is not
  claimed. The three-byte instruction is emitted as JMP rather than data.
- **Metadata/storage:** Independently parsed complete one-procedure native
  containers ending at byte 314 in disk-1 block 2 and byte 112 in block 156.
  Reconstructed alignment, four empty relocation lists, entry displacements,
  attributes, dictionary pointers and trailers. Classified the following 198
  and 400 zero bytes as bounded storage within their evidenced one-block overlay
  reads, after the validated container ends; nonzero tails are rejected. The
  screen block's footer points to offset zero, but its actual raw entry remains
  offset 192; no execution through its HGR address table is inferred.
- **Artifacts:** Added src/native/native_block_tails.s/config/adoption,
  tools/native_block_tail.py, three tests, the complete raw-tail audit and
  docs/native-block-tails.md. Updated the initializer, transformer and encoded
  loader documents plus PLAN.md. The component holds 634 bytes: 3 code and
  631 data. Both full 512-byte blocks now have source/code-data ownership.
- **Validation:** Three tests pass for the metadata boundaries, unused indirect
  transfer, and rejection of changed opcodes/operands, malformed footers,
  nonzero alignment or nonzero block storage. Preparation verifies both exact
  source prefixes, both native dictionaries/relocation structures, complete tail
  coverage and exact assembly. Adoption, full exact build, --verify artifact
  regeneration and original disk/manual comparison pass. A separate per-byte
  check confirms complete source ownership of both blocks. git diff --check
  passes. No new live emulator validation is claimed.
- **Coverage:** 172,997 source-built disk bytes, 99,300 identified data/asset bytes,
  14,423 temporary bytes (6,682 disk 1; 7,741 disk 2).
- **Workspace:** The concurrent PRD reference-link edit remains preserved and
  excluded from this implementation commit.
- **Next action:** Continue the remaining asset tails, orphan/variant code and
  provisional runtime audit, then final gameplay/save/load/swap/utility checks
  in both emulators. The full classification requirement remains in force.

## 2026-09-20 — Step 07s: alternate-program graphics glyph bank

- **Evidence:** Alternate 7 stores relative block 171 in data-segment 29 word
  32, installs the $0800 glyph pointer through library 22 procedure 20, then
  immediately replaces that buffer with a two-block read through procedure 53.
  Its +3 block adjustment selects disk-1 blocks 174–175. The existing native
  glyph renderer's eight-byte stride and reversed row reads establish all
  128 records as graphics data, independently of their visual appearance.
- **Artifacts:** Added tools/alternate_glyph_asset.py, assets/alternate-glyphs/
  (binary, lossless row listing, mask atlas, manifest and adoption recipe), and
  docs/alternate-glyphs.md. Linked the bank from the shared-font document and
  recorded the checkpoint in PLAN.md. Visually reviewed the atlas; individual
  gameplay meanings remain unasserted. All high bits are retained.
- **Validation:** The two existing glyph conversion tests pass. Extraction
  verifies the exact rebuilt disk and reviewed assembled loader/renderer hashes;
  row listing inversion and artifact verification pass. Adoption, full disk
  build, original disk/manual verification and git diff --check pass. Both
  images remain byte-identical to their originals. No new live emulator check
  is claimed.
- **Coverage:** 172,997 source-built disk bytes, 100,324 identified data/asset
  bytes, 13,399 temporary bytes (5,658 disk 1; 7,741 disk 2).
- **Workspace:** The user's PRD reference-link edit remains untouched and is
  excluded from this implementation commit. The goal is active after resume.
- **Next action:** Continue remaining asset storage and orphan/variant code,
  provisional runtime classifications, and final checks in both emulators.

## 2026-09-20 — Step 08d: bounded asset-allocation zero storage

- **Evidence:** The full-ship RLE image ends exactly after a 56-byte repeat
  packet, at consumed byte 1,687 of its evidenced four-block read. Its 361-byte
  zero remainder is unused allocation storage, with a completely identical
  disk-1 allocation. Separately, the one-block save-descriptor read and bounded
  four-slot, 64-byte indexing establish a 256-byte table and 256-byte zero spare
  remainder. Classification uses complete payloads and allocation boundaries;
  arbitrary zero runs and the nonzero section-image tail remain excluded.
- **Artifacts:** Added tools/asset_block_storage.py, two tests, explicit .res
  declarations/config/adoption under src/data, a per-allocation reference audit,
  and docs/asset-block-storage.md. Updated ship/save documentation and PLAN.md.
  The save document now also reflects the previously adopted p-code copies in
  three bank tails; the save verifier's message describes its actual scope.
- **Validation:** Both new tests pass, covering exact extents, changed payloads,
  malformed allocation lengths, nonzero tail rejection and section-image
  exclusion. Preparation verifies existing asset hashes and every payload
  byte's current manifest ownership, format boundaries and all-zero remainders.
  The 617 source bytes assemble exactly and map to 978 disk bytes. Adoption,
  full build, regenerated artifact verification, original disk/manual checks
  and git diff --check pass. Both images remain exact. No new emulator result
  is claimed.
- **Coverage:** 173,975 source-built disk bytes, 100,324 identified data/asset
  bytes, 12,421 temporary bytes (5,041 disk 1; 7,380 disk 2). All 978 bytes in
  this checkpoint are data storage, not newly decoded instructions.
- **Workspace:** The user's PRD reference-link edit is preserved and excluded
  from this commit.
- **Next action:** Continue nonzero residuals, orphan/variant code and provisional
  runtime classification audits, followed by final checks in both emulators.

## 2026-09-20 — Step 06al: retained utility-variant procedures

- **Evidence:** The exact-copy anchors in disk-1 blocks 151–155 surround fifteen
  complete procedures with stored local/parameter sizes, entry/exit pointers,
  attributes and branch tables. Independent decoding of offsets $0042–$089B
  relative to block 151 accounts for all 2,138 bytes: 785 instructions occupying
  1,413 bytes and 725 bytes of explicit data/metadata. No additional code root,
  opaque gap, invented dictionary or trailer is needed. Calls to absent
  fragment procedures 3, 4 and 31 remain explicit; live reachability and the
  variant's date are not asserted.
- **Work:** Added reviewed complete-procedure fragment analysis to the existing
  p-code decoder while retaining all whole-module dictionary and call-count
  checks. Added source-context mappings to adoption: each contextual byte must
  match an existing ordinary source owner and offset; no prior mapping changes,
  and every new assembled byte still requires verified disk provenance.
- **Artifacts:** Added tools/utility_variant_source.py, complete ca65 source,
  config/adoption, full per-item/control-flow audit and
  docs/utility-variant-procedures.md. Updated the earlier copy document and plan.
  The complete source keeps surrounding instructions visible when the new disk
  mapping selects only a changed operand. Its 1,356 contextual bytes independently
  agree with the previous utility-copy code/data classifications.
- **Validation:** Fourteen p-code tests, five adoption tests and three source-copy
  tests pass. New checks cover fragment metadata/absence boundaries, unsupported
  encodings, absent calls, source-context preservation and invalid context.
  All 2,138 source bytes assemble exactly. Adoption maps 782 new disk bytes
  (575 code, 207 data). Regenerated fragment artifacts and every old early-copy
  mapping verify after adoption. Full rebuild, original disk/manual verification
  and git diff --check pass; both disks remain exact. No new emulator execution
  is claimed.
- **Coverage:** 174,757 source-built disk bytes, 100,324 identified data/asset
  bytes, 11,639 temporary bytes (4,259 disk 1; 7,380 disk 2). The retained
  five-block utility area now has 136 unresolved bytes in its clipped edge
  procedures, rather than 918 before this checkpoint.
- **Workspace:** The user's PRD link edit remains untouched and excluded.
- **Next action:** Finish clipped procedure remnants and other orphan code/data,
  audit provisional runtime regions, and complete the final emulator checks.

## 2026-09-20 — Step 06am: high-memory provisional classification audit

- **Evidence:** Reconstructed the contiguous bank-2/common $D000–$F79F view
  from actual assembled components. Its stored footer parses as one native
  procedure with entry $D000, four zero relocation counts and a complete
  dictionary/trailer. The formerly literal byte at $F7A0 is the immediate
  operand of the copied LDY #$03 at original $F59F / copied $6B0F, established
  by the complete 96-byte retained-copy comparison.
- **Format evidence:** Apple's Pascal Technical Note 16 defines the retained
  THISISIT SEPPROC/GLOBDEF records and blank-name EOFMARK at $F800–$F82F.
  Apple's system-location table separately identifies $FFF6 as a stored file
  version word. The local value is 3; no release-name mapping is inferred.
  Primary PDF page links are recorded in docs/native-high-metadata.md. The
  research PDF was downloaded to /tmp only; it is not a build dependency.
- **Work/artifacts:** Replaced preservation literals with explicit metadata
  words, named linker fields and a documented one-byte instruction fragment;
  separated linker-block zero storage from the later fixed-stub gap. Added
  tools/native_high_metadata.py, two mutation tests and the current full audit
  docs/reference/native-high-metadata-audit.json. Extended the existing native
  high-memory checker and updated its da65 information, documentation and plan.
  Historical step-06f evidence remains intact.
- **Validation:** Two tests pass for metadata/record/version mutation, clipped
  instruction provenance and component extents. The extended audit retains 79
  direct/vector checks, bank-specific targets, 22 derived service entries and
  exact copied instructions. Full build, regenerated audit comparison, original
  disk/manual verification and git diff --check pass. No image bytes changed
  and no new emulator execution is claimed.
- **Coverage:** All 59 bytes in this component's three formerly provisional
  ranges are now classified. Native high-memory coverage is 390 complete
  instruction bytes, one operand-fragment byte and 1,769 data bytes. Disk
  ownership totals stay 174,757 source-built, 100,324 identified assets and
  11,639 temporary bytes. The initializer's separate 42-byte payload and other
  remaining work are not silently counted as resolved.
- **Workspace:** The user's PRD link edit remains untouched and excluded.
- **Next action:** Continue the initializer payload, clipped/orphan source,
  remaining disk data classification and final emulator validation.

## 2026-09-20 — Step 06an: native runtime copy after world defaults

- **Evidence/work:** Disk-1 block 25 bytes 416–511 exactly copy native_shared
  offsets $0DBC–$0E1B, originally at $EEA1–$EF00. The first four bytes are two
  input-device vector words, $FF18 and zero; the remaining 92 bytes contain
  fifty complete native instructions. The range starts at a vector boundary
  and ends after LDA #$04. The copy is not classified as world-table padding
  or assigned an unproven execution address.
- **Artifacts:** Added tools/native_shared_copy.py, a complete item/provenance
  audit and docs/preserved-native-shared-copy.md. The manifest maps the 96 bytes
  to the existing assembled source; no additional executable blob or duplicate
  assembly component is introduced. Updated the plan and working-state boundary
  documentation.
- **Validation:** Fresh assembly and the original shared-runtime audit pass,
  including device-vector targets and all code spans. Every copied instruction
  boundary matches the independent native listing. Exact-copy and post-adoption
  ownership verification, the three existing source-reuse tests, full rebuild,
  original disk/manual checks and git diff --check pass. No image byte changes
  or new emulator execution are claimed.
- **Coverage:** 174,853 source-built disk bytes, 100,324 identified data/asset
  bytes, 11,543 temporary bytes (4,163 disk 1; 7,380 disk 2).
- **Workspace:** The user's PRD link edit remains untouched and excluded.
- **Next action:** Continue the initializer payload and other orphan code/data,
  then complete final behavior and reproducibility checks in both emulators.

## 2026-09-20 — Step 06ao: short p-code copies and utility edge changes

- **Evidence/work:** Reviewed eight exact 36–60-byte copies from five fully
  audited p-code components. Five are complete remaining block tails, and
  three lie in the clipped final utility procedure. Their item audits retain
  every instruction/string/metadata boundary and any clipped endpoints.
  They account for 396 bytes: 300 code and 96 data. The frozen recipe explicitly
  uses a 32-byte review minimum; ordinary copy recipes retain 64. Exact hashes,
  nontrivial bytes and complete source classification remain mandatory.
- **Variant edges:** Independently classified the remaining four changed utility
  bytes: a procedure marker 32→31, two LAO address operands 12→11, and a CGP
  operand 44→42. Source emits the complete ten-byte footer and three complete
  instructions, with twelve unchanged context bytes checked against their old
  source ownership. The target procedure 42 is present in the independently
  decoded variant. No missing source body or dictionary is invented.
- **Artifacts:** Added the short-copy evidence recipe/full audit,
  tools/utility_variant_edges.py, sixteen-byte ca65 context source/config/adoption,
  its field audit and docs/short-pcode-copies.md. Updated the earlier variant
  document and PLAN.md. The normal build continues to use assembled source.
- **Validation:** Four source-copy tests and five adoption tests pass, including
  explicit short-match opt-in, minimum rejection, wrong/trivial bytes, source
  context ownership and overlap handling. New copy/edge verification and both
  earlier copy sets pass after adoption. A per-byte check confirms all 2,560
  bytes in disk-1 blocks 151–155 have source ownership: 1,774 primary-copy bytes,
  782 independently decoded variant bytes and four contextual edge bytes.
  Both full disks rebuild exactly, original disk/manual checks pass and
  git diff --check passes. No new live emulator validation is claimed.
- **Coverage:** 175,253 source-built disk bytes, 100,324 identified data/asset
  bytes, 11,143 temporary bytes (3,875 disk 1; 7,268 disk 2). This checkpoint
  removes 400 temporary bytes: 303 code and 97 data.
- **Workspace:** The user's PRD link edit remains untouched and excluded.
- **Next action:** Continue other orphan fragments, remaining data and provisional
  runtime payload classification, followed by final dual-emulator validation.

## 2026-09-20 — Step 06ap: identify the initializer's FORTRAN protection table

- **Evidence/work:** Apple's original ATTACH-BIOS listing reserves $BF56–$BF7F
  for FORTRAN protection. A historical SYSTEM.COMPILER provides the actual
  consumer: segment 9 native procedure 4, established from its dictionary and
  relocation footer. Its copy/patch loops identify four address words, four
  three-byte patches, one helper displacement, and two native helper routines.
  Frozen evidence records source URL, disk/file/segment hashes, native metadata
  and bounded consumer excerpts; the external compiler is not a build input.
- **Classification:** All 42 initializer bytes are now identified: nine data
  bytes, seventeen complete instructions totaling 32 bytes, and one STA opcode
  fragment. That opcode retains operand $CF at bank-2 $D55F. The adjacent $4C
  starts a separate JMP template, rather than supplying the STA operand. The
  compiler's scratch operands are procedure-relative relocations, not literal
  stack-page addresses. The first three patch sites select bank 2; the fourth
  selects bank 1. No SunDog activation of these retained patches is asserted.
- **Artifacts:** Replaced the unresolved payload literals with typed words,
  mnemonic patch templates/helpers and the explicitly identified opcode
  fragment. Updated the independent da65 layout and initializer audit; added
  tools/initializer_protection.py, three tests, the external consumer evidence,
  a current full initializer audit and docs/initializer-fortran-protection.md.
  Updated PLAN.md and both affected native documentation pages.
- **Validation:** Full source build and tools/verify_disks.py preserve both exact
  disk hashes and the manual hash. The initializer audit reports 515 complete
  instructions / 1,064 bytes, one code-fragment byte and 215 data bytes, checks
  94 direct/synthetic-return targets, and matches all 1,280 recorded emulator
  bytes. --fortran-compiler independently verifies the downloaded consumer's
  hash, native procedure/relocations and all frozen excerpts. Three tests pass,
  covering classification, copy/patch mutations, the retained operand and
  rejection of an unrelated external compiler. git diff --check passes.
- **Coverage:** This resolves provisional classification within an already
  source-built component. Disk ownership remains 175,253 source-built bytes,
  100,324 identified data/asset bytes and 11,143 temporary bytes (3,875 disk 1;
  7,268 disk 2). No new live emulator execution is claimed.
- **Workspace:** The user's PRD link edit remains untouched and excluded.
- **Next action:** Continue remaining orphan fragments and disk data, then
  complete final behavior and reproducibility checks in both emulators.

## 2026-09-20 — Step 08e: retained Pascal directory and header metadata

- **Evidence/work:** The identical tails of block 117 on both disks contain
  nine consecutive 26-byte Pascal directory records: four counted development
  filenames and five cleared-name records with retained filename/numeric storage.
  Record structure, sizes, dates and aligned field boundaries establish data
  ownership. The leading two bytes are a clipped preceding date word; 182 zero
  bytes follow the final complete record. These historical records are not
  asserted to be a current allocation map, and overwritten inactive fields
  are preserved without repair or invented file meanings.
- **Header fragment:** Disk-1 block 259 bytes 170–511 retain a segment-header
  suffix with its old origin at byte 12: name storage, sixteen kind words,
  sixteen text-address words, sixteen version/machine/segment words, intrinsic
  set $44, zero library information and an empty clipped comment field. The
  sequence matches the documented header layout. Its missing 158-byte prefix
  and twelve-byte suffix are excluded rather than reconstructed by assumption.
- **Artifacts:** Added tools/retained_pascal_metadata.py, three tests, typed
  source/config/adoption artifacts, a complete field audit and
  docs/retained-pascal-metadata.md. Updated PLAN.md and adopted the 760-byte
  source component for 1,178 disk bytes, sharing the directory fragment between
  disks. No uninterpreted binary component was introduced.
- **Validation:** All three tests pass. An initial test incorrectly expected
  a changed inactive date field to fail despite its intentionally unspecified
  semantics; the corrected rejection case mutates the structurally checked
  final-block byte count. Preparation assembles every field exactly; --verify
  regenerates source/audit/mappings and confirms manifest ownership after
  adoption. An independent per-byte ownership check covers all 418+342 disk-1
  and 418 disk-2 bytes. Full rebuild, original disk/manual checks, exact disk
  comparisons and git diff --check pass. No fresh emulator execution is claimed.
- **Coverage:** 176,431 source-built disk bytes, 100,324 identified data/asset
  bytes and 9,965 temporary bytes (3,115 disk 1; 6,850 disk 2). This checkpoint
  removes 1,178 temporary bytes, all classified as data.
- **Open evidence:** The final play-disk track remains unresolved. Its all-zero
  contents and position beyond the last Pascal module do not supply a complete
  allocation/consumer argument by themselves; this checkpoint does not classify
  it or other unrelated tails by analogy.
- **Workspace:** The user's PRD link edit remains untouched and excluded.
- **Next action:** Continue the remaining retained memory/code fragments and
  data allocations, then final dual-emulator behavior/reproducibility validation.

## 2026-09-20 — Step 08f: retained 128K Pascal stack data

- **Evidence/work:** Disk-1 blocks 260 and 263 retain identical 492-byte tails.
  Two independent linked lists of copied counted strings establish one memory
  origin, $EDE6. Fourteen complete nodes and one clipped node agree with the
  128K conditional string-copy paths in the historical Pascal interpreter
  disassembly. Three call frames share coherent dynamic links, saved stack
  bounds and the extra saved-string-list prefix used by that interpreter.
- **Classification:** Every tail byte is data: copied string records, alignment
  storage, saved call-frame fields, or parameter/local storage bounded by those
  frames. Both child links reach the retained parent; one saved string head and
  stack top point to the same complete empty-string node. Unnamed local fields
  retain their bytes and evidenced activation bounds. These are historical,
  partly reused stack contents; simultaneous live frames or a 128K SunDog
  runtime are not asserted. The different 20-byte code prefixes are excluded.
- **Artifacts:** Added typed source/config/adoption artifacts, a full ownership
  audit, docs/retained-pascal-stack.md, tools/retained_pascal_stack.py and three
  tests. Updated PLAN.md and adopted 492 source bytes for 984 disk bytes.
  Normal builds use committed declarations without downloaded evidence.
- **Validation:** Three tests pass, checking the common address mapping and
  rejecting changed links, lengths, frame bounds, window extents and unreviewed
  local bytes. Preparation assembles the exact tail; --verify regenerates all
  artifacts, checks both copies and confirms manifest ownership. Full rebuild
  and tools/verify_disks.py preserve both original disk hashes and the manual
  hash. git diff --check passes. No fresh emulator execution is claimed.
- **Coverage:** 177,415 source-built disk bytes, 100,324 identified data/asset
  bytes and 8,981 temporary bytes (2,131 disk 1; 6,850 disk 2). This checkpoint
  removes 984 temporary bytes, all classified as data.
- **Workspace:** The user's PRD link edit and untracked ref/ directory remain
  untouched and excluded from this checkpoint.
- **Next action:** Continue remaining retained memory/code fragments and data
  allocations, then final dual-emulator behavior/reproducibility validation.

## 2026-09-20 — Step 08g: retained command-prompt activation stack

- **Evidence/work:** The duplicate block-139 tails contain four complete Pascal
  call frames plus ten bytes of a clipped fifth frame. Four dynamic links resolve
  successively under the common origin $B58C; the saved CPU stack bytes increase
  from $EF to $F7. A frame's saved stack top and string-list head both resolve to
  the complete copied command-prompt node at $B72A. Its 72-byte allocation ends
  exactly at the next frame's prefix. These independent constraints identify
  retained 128K Pascal stack data using the interpreter format established in
  step 08f; no current SunDog activation is asserted.
- **Classification:** All 184 bytes per block-139 tail are saved frame fields,
  copied string data or bounded activation storage. The clipped frame's missing
  saved KP/static link are not invented; its surviving dynamic link bounds the
  interframe data. The final locals are clipped two bytes before their saved
  stack top. Detailed local-field meanings remain optional after classification.
  Block 103 retains the same final 138 bytes on each disk. Its existing 68-byte
  prompt mapping remains intact; the newly classified 44+26 surrounding bytes
  complete the library-header residue and all eight inventoried header blocks.
- **Artifacts:** Added tools/retained_command_stack.py, three mutation/boundary
  tests, typed source/config/adoption artifacts, a complete audit and
  docs/retained-command-stack.md. Updated PLAN.md and the two affected header
  documentation pages. Adopted 184 source bytes for 508 new disk bytes.
- **Validation:** Three tests pass, including altered links, stack bounds,
  saved string heads, prompt fields and unreviewed local storage. Preparation
  assembles the exact window; --verify checks regenerated artifacts, duplicate
  tails and partial copies, plus manifest ownership. Full rebuild and
  tools/verify_disks.py preserve both original disk hashes and the manual hash.
  git diff --check passes. No fresh emulator execution is claimed.
- **Coverage:** 177,923 source-built disk bytes, 100,324 identified data/asset
  bytes and 8,473 temporary bytes (1,877 disk 1; 6,596 disk 2). This checkpoint
  removes 508 temporary bytes, all classified as data.
- **Workspace:** The user's PRD link edit and untracked ref/ directory remain
  untouched and excluded.
- **Next action:** Continue remaining orphan code and data allocations, then
  complete final dual-emulator behavior/reproducibility validation.

## 2026-09-20 — Step 06aq: reconstruct retained Apple Pascal linker code

- **Evidence/work:** Both block-126 tails (offsets 210–511) match the archived
  Apple Pascal 1.2 SYSTEM.LINKER exactly. The original header and complete
  49-procedure dictionary identify adjacent procedures 22 and 26 around the
  copied bytes. Their entry/exit displacements and CFGs independently establish
  all instruction, inline-string, jump-table and footer boundaries. Frozen
  evidence records the archive URL, disk/allocation/segment hashes, header,
  dictionary and bounded complete-procedure context.
- **Classification:** The two 302-byte copies contain 496 disk code bytes and
  108 data bytes. The leading two bytes are the big operand of LDL 295, proven
  from the complete donor instruction; they are emitted with p_big. The last
  instruction is a complete LDCI 20000. Both complete donor procedures decode
  into 443 instructions / 683 code bytes and 127 data/metadata bytes. Calls
  outside the donor context remain explicit absent-procedure references.
- **Decoder:** Added explicit historical INN support and an assembly macro.
  The original full interpreter establishes its one-byte set-membership format.
  SunDog's trimmed dispatch maps $8B to unsupported opcode $D1EF; default decoding
  still rejects it. The opt-in dialect does not claim these retained procedures
  are executable in the live game.
- **Artifacts:** Added tools/retained_linker.py, three tests, disk source and
  complete context source, config/adoption artifacts, provenance and full audit,
  plus docs/retained-linker-code.md. Updated PLAN.md. The disk source emits only
  the reviewed 302-byte slice; normal builds do not read historical evidence.
- **Validation:** Three new tests and fourteen existing p-code decoder tests
  pass. The initial mutation fixture accidentally replaced an already-zero
  byte with zero; XOR now guarantees a changed byte. The adoption guard rejected
  the initial full-context component because not every byte belonged on a disk;
  separating complete context from the 302-byte disk source satisfies that
  invariant without changing the adoption tool. Both source forms assemble
  exactly. --verify --external-linker checks the complete original dictionary,
  frozen excerpts, both copies, regenerated artifacts and manifest ownership.
  Full rebuild, tools/verify_disks.py and git diff --check pass; both disk hashes
  and the manual hash remain exact. No fresh emulator execution is claimed.
- **Coverage:** 178,527 source-built disk bytes, 100,324 identified data/asset
  bytes and 7,869 temporary bytes (1,575 disk 1; 6,294 disk 2). This checkpoint
  removes 604 temporary bytes. All remaining unrelated fragments stay open.
- **Workspace:** The user's PRD link edit and untracked ref/ directory remain
  untouched and excluded.
- **Next action:** Check remaining fragments against the now-available historical
  Pascal files, then continue allocation evidence and final dual-emulator checks.

## 2026-09-20 — Step 08h: retained compiler identifier/parameter heap

- **Evidence/work:** Disk-1 block 258's 460-byte tail contains eleven complete
  named compiler identifiers, nine complete parameter records, a six-byte pointer
  type, and two clipped records. MARK/RELEASE share one parameter whose type
  pointer resolves to the intervening pointer-type record; four unit/real
  intrinsics share another parameter. The STRTONUM pair and a five-parameter
  chain independently establish the same memory origin, $2540 plus block offset.
  ROUND's head locates the clipped preceding record, accounting for its last
  four bytes without reconstructing the overwritten eighteen-byte prefix.
- **Constructor evidence:** Original UCSD compiler definitions name the fields.
  Bounded excerpts from the archived Apple 1.2 SYSTEM.COMPILER independently show
  eleven-word identifier allocations, a three-word pointer type, and writes to
  type/next/class fields at word offsets 6/7/8. The constructor's original
  dictionary/attributes establish segment 7 procedure 8. Frozen evidence records
  source URLs, hashes, metadata and the selected allocation/write instructions;
  it does not claim complete classification of the external compiler.
- **Classification:** Every tail byte is data. Native-looking sequences occupy
  the parameter records' unwritten NAME, tree-link, VLEV and VADDR fields. Their
  classification follows linked allocation boundaries and constructor writes,
  not lack of execution. The source identifies these fields explicitly. Standard
  symbol names/classes/intrinsic numbers and pointer-type values are typed;
  historical ignored values are preserved without repair. Missing NUMTOSTR
  fields beyond the block are excluded, including its unavailable parameter head.
- **Artifacts:** Added tools/retained_compiler_heap.py, three structural/mutation
  tests, typed source/config/adoption files, constructor evidence, field audit
  and docs/retained-compiler-heap.md. Updated PLAN.md and adopted 460 source bytes.
  Normal builds do not read the archived compiler or downloaded source repository.
- **Validation:** All three tests pass, checking pointer relationships, clipped
  fields and rejection of changed names/types/links/classes or unreviewed storage.
  Preparation assembles every byte exactly. --verify --external-compiler checks
  the complete allocation/segment/procedure hashes, metadata, consumer excerpts,
  regenerated artifacts and manifest ownership. Full rebuild, original disk/manual
  verification, exact disk comparisons and git diff --check pass. No new emulator
  execution is claimed.
- **Coverage:** 178,987 source-built disk bytes, 100,324 identified data/asset
  bytes and 7,409 temporary bytes (1,115 disk 1; 6,294 disk 2). This checkpoint
  removes 460 temporary bytes, all classified as data.
- **Next evidence:** Both block-134 tails also exactly match a fourteen-byte
  interval in the already decoded historical linker context (offsets 46–59).
  They begin with two LOD operands, contain the counted Reading string, and end
  at a complete short constant. They remain unadopted for the next checkpoint.
- **Workspace:** The user's PRD link edit and untracked ref/ directory remain
  untouched and excluded.
- **Next action:** Reconstruct that short linker copy, then continue remaining
  allocations/fragments and final dual-emulator behavior/reproducibility checks.

## 2026-09-20 — Step 06ar: reconstruct the short linker reading-prompt copy

- **Evidence/work:** Both block-134 tails match offsets 46–59 in the complete
  historical linker context already validated in step 06aq. Independent decoding
  locates the preceding LOD opcode at offset 45; the copy begins with its two
  operands. NOP, LSA 8, the Reading string and SLDC 0 follow with complete
  boundaries. The missing opcode and neighboring bytes remain excluded.
- **Artifacts:** Added a fourteen-byte source/config/adoption component,
  tools/retained_linker_prompt.py and its classification audit. Updated PLAN.md
  and the existing linker provenance document. The tool reuses complete donor
  validation/decoding rather than inferring a stream from the short string.
- **Validation:** Preparation checks the exact five instruction/data items,
  assembles the source exactly and compares both copies. --verify regenerates
  all artifacts and checks manifest ownership. Full rebuild and
  tools/verify_disks.py preserve both original disk hashes and the manual hash;
  git diff --check passes. No new decoder behavior or emulator run is introduced.
- **Coverage:** 179,015 source-built disk bytes, 100,324 identified data/asset
  bytes and 7,381 temporary bytes (1,101 disk 1; 6,280 disk 2). This checkpoint
  removes 28 bytes: twelve code, including four clipped operand bytes, and
  sixteen string-data bytes.
- **Workspace:** The user's PRD link edit and untracked ref/ directory remain
  untouched and excluded.
- **Next action:** Investigate allocation evidence for the remaining boot-block
  tails, then continue other fragments and final dual-emulator checks.

## 2026-09-20 — Step 08i investigation: boot allocation tails remain open

- **Evidence/work:** Rechecked the exact rebuilt first two blocks against the
  bootstrap load capture, play-boot instruction audit and boot-notice decoder.
  Disk 1 loads only its three reconstructed bootstrap pages. The play notice
  consumes exactly 576 bytes and its last packet is a 27-zero repeat; its
  following nonzero byte is not an unconsumed literal from that packet.
- **Remaining bytes:** Disk-1 block 1 offsets 256–511 contain 255 zeros followed
  by $01. Disk-2 block 0 offsets 193–255 contain 59 zeros, $09 at offset 252,
  then three zeros. Disk-2 block 1 offsets 320–511 contain $78 followed by
  191 zeros. These total 511 bytes, including three isolated nonzero bytes.
- **Allocation check:** Installed a2kit 4.4.2's Pascal formatter reserves and
  initializes boot blocks 0/1; its volume begin-block field also points to zero.
  This supports the outer allocation boundary, but does not identify the three
  retained nonzero values in SunDog's customized boot area. The four downloaded
  Apple Pascal 1.2 disk images have completely zero fourth boot sectors, so none
  supplies an exact provenance match for disk 1's trailing $01.
- **Decision:** Do not classify these tails wholesale as zero padding or infer
  a new code entry from isolated opcode-shaped bytes. No source adoption or
  coverage change follows from this investigation. Existing code and image
  ownership stays intact; no emulator execution was performed.
- **Validation:** Read-only comparisons used the exact rebuilt images checked
  in step 06ar. The boot packet re-decode reproduces the existing packet audit;
  git diff --check passes for this log update.
- **Next action:** Seek direct provenance/consumer evidence for the three boot
  values while advancing other unresolved fragments. In particular, the encoded
  banks retain two disconnected JMP stubs, unconsumed pointer-shaped words and
  bytes adjacent to their table/buffer; their code/data roles still need proof.

## 2026-09-20 — Step 07t: extract the retained 64-glyph font variant

- **Evidence/work:** Every glyph in disk-2 block 80 matches a mask from the
  independently verified shared font. Slots 0–2 and 8–63 keep their indices;
  slots 3–7 match the blank space at shared index 32. Every stored byte has its
  high bit cleared. This complete 64-record relationship accounts for all 512
  bytes using the established eight-row glyph format and renderer's $7F mask.
  It establishes a retained font variant without inventing a direct reader or
  inferring which version was created first.
- **Artifacts:** Extracted assets/retained-font-half with exact glyph bytes,
  a reversible 64-record display-order listing, labeled atlas, provenance/index
  mapping manifest and adoption recipe. Added tools/retained_font_asset.py and
  two relationship/mutation tests. Extended the existing glyph converter and
  preview to accept an explicit 64-glyph count, preserving the 128-glyph default;
  added a half-bank shape/row-order test. Updated PLAN.md, shared-font and
  interaction-record documentation, and added docs/retained-font-half.md.
- **Validation:** Five tests pass: three shared glyph tests and two retained-font
  tests, including pixel/high-bit/blank-slot and donor mutation rejection. The
  atlas was visually reviewed, showing symbols, five blanked slots, punctuation
  and digits. --verify checks all transformed donor bytes, source/renderer hashes,
  reversible rows, regenerated artifacts and manifest ownership. Full rebuild,
  tools/verify_disks.py and git diff --check pass. Both original disk hashes and
  the manual hash remain exact. No new emulator execution or live variant use
  is claimed.
- **Coverage:** 179,015 source-built disk bytes, 100,836 identified data/asset
  bytes and 6,869 temporary bytes (1,101 disk 1; 5,768 disk 2). This checkpoint
  removes 512 temporary bytes, all classified as glyph data. The encoded-bank
  remainder stays separate; its conflicting stub/vector interpretation is not
  forced into a new code or data claim.
- **Workspace:** The user's PRD link edit and untracked ref/ directory remain
  untouched and excluded.
- **Next action:** Continue remaining record/template tails and retained code
  fragments, then finish allocation evidence and final dual-emulator checks.

## 2026-09-20 — Step 08j: reconstruct the disk control record

- **Evidence/work:** Traced all eight leading bytes of disk-1 block 83 to
  direct consumers in library 26 procedure 6 and startup: the mode flag,
  save-slot selector, four bytes copied to/from data-segment 29 words 21–22,
  screen-initializer block selector and directory destination selector.
  The two readers independently select absolute block 83 through library 22's
  three-block bias. The directory write uses byte 7, selecting absolute block
  79; byte 6 independently selects the already reconstructed block-2 initializer.
  Existing utility-entry capture changes at image offsets $A902–$A905 exactly
  match the four-byte persisted-globals field. Its detailed algorithm remains
  unspecified; the direct copy operations establish data classification.
- **Artifacts:** Added eight-byte typed ca65 source, linker configuration and
  adoption recipe under src/data/disk_control, plus docs/disk-control.md with
  every field's instruction offsets. Updated PLAN.md, disk-layout and Pascal
  directory documentation to explain the previously unresolved utility writes.
  No classification claim extends into the remaining 504 bytes of block 83.
- **Validation:** Generic adoption assembled and compared all eight bytes,
  checking exclusive prior temporary ownership. Full rebuild and
  tools/verify_disks.py pass; both disks and the manual retain their reference
  hashes. Independently checked all four captured write offsets and before/after
  values against the documented field. git diff --check passes. No new tool or
  emulator run was needed for this data-declaration checkpoint.
- **Coverage:** 179,023 source-built disk bytes, 100,836 identified data/asset
  bytes and 6,861 temporary bytes (1,093 disk 1; 5,768 disk 2). The eight newly
  source-built bytes are data, not executable instructions.
- **Workspace:** The user's PRD link edit and untracked ref/ directory remain
  untouched and excluded.
- **Next action:** Continue the block-83 remainder and other retained fragments;
  establish evidence for the final-track allocation before classifying it.
  Final clean-build and dual-emulator behavior validation remain pending.
