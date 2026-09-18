# SunDog Apple II reverse-engineering plan

## Objective

Produce disassembled source, extracted assets, and a reproducible build that
recreates runnable versions of both supplied disk images. Every region must be
classified as code or data with evidence, and all code must be disassembled.
Byte-for-byte identity is preferred, not required; any differences must be mapped,
explained, and behaviorally validated. Detailed code documentation and game
mechanics analysis remain optional follow-up work, as specified in `PRD.md`.

## Base rule: log and commit every step

For **every step below**, including prerequisite fixes and any smaller steps
created during implementation:

1. Perform the work and its validation.
2. Update `PROGRESS.md` with the step identifier, date, work performed, commands
   and results, artifacts, unresolved questions, and next action.
3. Commit the step's changes together with the `PROGRESS.md` update. Use a
   descriptive message such as `step 03: map disk layout and allocation`.
4. Start the next step only after that commit succeeds. If work or validation is
   blocked, record the blocker and commit the partial checkpoint when possible;
   do not mark the step complete. If committing itself is blocked, record that
   fact and resolve Git access before continuing implementation.

Keep original inputs unchanged. Separate observed facts from hypotheses and
attach disk offsets, memory addresses, traces, or other evidence to findings.
Split large steps into independently validated, logged, and committed increments.

## Verified context and current checkpoint

- Available disks: `sundog-disk1-game.dsk` and `sundog-disk2-util.dsk`, each
  143,360 bytes. Filenames are preserved; observed roles are disk 1 for the
  title/utilities and disk 2 for play, as recorded in the current PRD.
- `sundog.pdf` is present; the PRD describes it as a scanned manual.
- Git is operational. The original Git prerequisite in step 01 has been
  resolved; every subsequent checkpoint must follow the base rule above.
- `PROGRESS.md` records completed steps 01–05 and module checkpoints 06a–06j-20.
  Step 06 remains in progress; the remaining steps below retain their original
  order and acceptance criteria.
- The incremental build matches both original disks, but still includes
  temporary binary inputs. Exact output alone does not establish completion
  of executable reconstruction or asset extraction.

## Steps

### 01 — Establish the repository and input baseline

- Restore usable Git metadata and write access through the workspace owner or
  an authorized checkout setup; commit the planning files before implementation.
- Record exact input filenames, sizes, and SHA-256 hashes in an input manifest.
- Establish directories for tools, source, assets, documentation, and generated
  output. Ignore temporary emulator state and reproducible build products.
- Resolve the second-disk naming discrepancy in project documentation while
  preserving the supplied file and recording any remaining uncertainty.

**Done when:** Git commits work, all three inputs have recorded hashes, and the
repository clearly separates original inputs from generated output.

### 02 — Establish tools and a playable reference

- Check and record versions of the cc65 tools, disk inspection tools, apple2ts
  with its server, MAME with Apple II support, and PDF/OCR utilities as needed.
- Boot working copies of the disks. Record machine model, memory, drive setup,
  boot sequence, disk swaps, and the observed purpose of each disk.
- Capture reference screens and a repeatable interaction sequence covering boot,
  entry into play, and available utility functions. Keep saves on disposable
  copies to prevent changes to the original images.
- Read or OCR the manual into working notes; visually verify relevant passages
  and cite page numbers for controls and disk operations.

**Done when:** a documented reference session runs, input hashes remain intact,
and any emulator/tool limitations are explicitly recorded.

### 03 — Map disk layout and account for every byte

- Identify image geometry, sector ordering, filesystem or custom layout, boot
  sectors, directories, allocation structures, and unallocated regions.
- Create a machine-readable map connecting image offsets to tracks/sectors,
  files or extents, and initial content classifications for both disks.
- Extract logical files and raw regions without losing headers, padding,
  unused sectors, or unexplained bytes. Record hashes and source locations.
- Implement a baseline unpack/repack operation that preserves all bytes. This
  verifies the container handling; it is not the final source rebuild.

**Done when:** both images round-trip exactly, and all bytes are represented in
the map even where their meaning remains unknown.

### 04 — Identify the loader, runtime, and memory layout

- Trace the boot path and disk reads to locate entry points, load addresses,
  overlays, relocation behavior, bank use, and resident code.
- Determine whether each executable region contains native 6502 code, bytecode
  such as UCSD p-code, an interpreter, or another representation.
- Document memory maps and module dependencies using static evidence and emulator
  traces. Identify any writes to executable memory or runtime-patched bytes.
- Select the appropriate disassembly and reconstruction tools for each region.
  If bytecode is present, investigate its format and a matching assembler or
  compiler before committing to a native-only toolchain.

**Done when:** the boot-to-game path and executable representations are supported
by evidence, with a viable reconstruction approach for each representation.

### 05 — Prove a minimal source-to-disk build

- Disassemble one small, confirmed executable component, preferably an early
  loader, and reconstruct it from editable source.
- Configure assembly/linking or the required bytecode tooling to preserve exact
  addresses, headers, layout, and bytes.
- Insert the rebuilt component into the disk reconstruction pipeline. Retain
  other regions as explicitly tracked temporary binary inputs.
- Add commands for build and comparison, with failures reporting the first
  differing image offset and its mapped sector/module.

**Done when:** one component rebuilds exactly from source, the resulting full
images match the originals, and the reference boot still works.

### 06 — Reconstruct executable modules incrementally

- Work through the loader, resident runtime, disk I/O, overlays, and remaining
  executable modules in dependency order, using one module per smaller step.
- Separate code from embedded tables and assets; establish labels, entry points,
  cross-references, and comments for verified behavior.
- Preserve instruction choices, branch encodings, relocation data, and layout.
  Model runtime patching without confusing in-memory changes with disk bytes.
- Replace temporary executable blobs with source-built modules. Track unresolved
  areas in a coverage ledger; do not disguise executable blobs as assets.

**Done when:** every identified executable region has a source representation
that assembles, and every executable/data boundary has recorded evidence. No
unclassified code/data chunks remain in the reconstructed modules; detailed
meaning of established data regions may remain unknown.

### 07 — Extract assets and preserve their encodings

- Locate and classify images, sprites, fonts, text, maps, sound routines/data,
  and other game tables as supported by evidence.
- Create repeatable extractors and, where conversion occurs, inverse encoders.
  Preserve packed layouts, palette/display assumptions, compression, and padding.
- Produce useful previews or listings and a manifest linking each asset to its
  original disk location, format, consumer, and build input.
- Rebuild asset regions from extracted representations; retain explicitly
  documented raw data only where that is the appropriate lossless format.

**Done when:** all identified assets are extracted, converted assets have
reproducible encodings (with any changes documented), and representative previews
agree with the running game.

### 08 — Complete the standalone disk build and classification audit

- Replace remaining temporary reconstruction inputs with source-built code,
  extracted assets, or evidence-backed data. Preservation data must be classified
  as data with evidence; it cannot conceal undecoded code or mixed regions.
- Generate both full images, including filesystem metadata, boot structures,
  sector placement, unused contents, and padding.
- Make the build independent of reading or copying the original disk images;
  use originals only as validation references. Audit dependencies to enforce this.
- Provide a single documented build command and a verification command that
  checks image sizes, hashes, and byte equality with nonzero exit on mismatch.

**Done when:** a clean build using only project source, assets, preservation data,
and declared tools produces both runnable images, every byte is classified as
code or data, and no temporary/unidentified chunks remain. Both images either
match the originals exactly or have a complete, explained difference report
supported by behavioral validation.

### 09 — Validate behavior and reproducibility

- Run rebuilt disks through the reference interaction sequence in apple2ts and
  MAME. Include disk swaps, utility behavior, and save/load where available.
- Compare relevant screens and state transitions with the originals. Record
  emulator configuration and any limitations on timing or sound comparisons.
- Repeat a clean build to confirm deterministic output and verify that original
  inputs were never modified. Add lightweight automated regression checks for
  the build and exact-image comparison.

**Done when:** clean builds are deterministic, exact comparisons or explained
difference reports are recorded, the documented emulator checks pass, and any
untested behavior is explicitly listed. Run full emulator checks at integration
milestones and whenever output bytes change; identical-output module checkpoints
can reuse the recorded behavior baseline after byte comparison.

### 10 — Deliver usage documentation and coverage report

- Update `README.md` with prerequisites, build/verification commands, emulator
  setup, output locations, and the role of each supplied disk.
- Document the source and asset organization, tool versions, provenance, and
  treatment of preserved non-code bytes.
- Summarize executable/asset coverage, known limitations, and reproduction steps.
  Keep implementation comments sufficient to navigate and rebuild the project.

**Done when:** a fresh checkout can follow the documentation to reproduce and
verify both images, and every required PRD output is accounted for.

### 11 — Optional: explain architecture and game mechanics

- Expand verified module, runtime, and data-format documentation.
- Analyze mechanics such as navigation, trading, combat, and progression only
  where code or controlled observations support the conclusions.
- Consult the PRD's reference projects for context, citing their sources and
  distinguishing other platforms' behavior from the Apple II implementation.

**Done when:** each published explanation links to code or observations and
clearly labels any remaining hypotheses. This step is not required for the
core deliverables.

## Completion criteria

The required work is complete after steps 01–10 when both runnable disks rebuild
from delivered source and data/assets, every region is classified as code or data
with evidence, all code is disassembled, assets have been extracted, behavioral
checks are documented, and every step has a progress entry and commit. Exact
identity is preferred; differences require location mapping, explanation, and
behavioral validation. A disk copy, executable blob, or unidentified byte chunk
is insufficient. Unknown data semantics are allowed only after data classification
is established. Existing temporary remainders are work in progress, not an
accepted final input category.
