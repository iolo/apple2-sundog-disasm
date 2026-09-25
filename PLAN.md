# SunDog Apple II reverse-engineering plan

## Objective

Produce disassembled source, extracted assets, and a reproducible build that
recreates runnable versions of both supplied disk images. Every region must be
classified as code or data with evidence, and all code must be disassembled,
including unused executable routines, subject to the bounded exception below.
Byte-for-byte identity is preferred, not required; any differences must be mapped,
explained, and behaviorally validated. Detailed code documentation and game
mechanics analysis remain optional follow-up work, as specified in `PRD.md`.

### Current acceptance exception — 2026-09-25

The user's latest instruction accepts the remaining **488 bytes as unidentified
data** and ends required classification research on those bytes. Preserve them
unchanged as explicitly user-assumed data; do not claim their role was proven.
[docs/user-assumed-data.md](docs/user-assumed-data.md) and its receipt freeze the
exact scope. This exception applies to every code/data completion criterion
below and supersedes earlier blanket prohibitions only for those 488 bytes.
All other regions retain the evidence and disassembled-source requirements.

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
- `PROGRESS.md` records completed steps 01–05 and module checkpoints 06a–06v.
  All inventoried executable segments are source-built. Step 06 remains open for
  other-region classification and provisional runtime data. Steps 06w–06ad add raw
  screen-initialization, buffer-transformation, certificate-reveal, warp-animation,
  viewscreen-transition, shared drawing/joystick, disk-checksum, and play-disk boot code
  outside the Pascal inventory; step 07a extracts
  the independently confirmed title bitmap, step 07b extracts the shared font,
  step 07c extracts the registration certificate, and step 07d extracts two
  play graphics banks, followed by compressed ship images in step 07e and four
  tile banks in step 07f, world-map tiles in step 07g, and packed maps in
  step 07h, inventory/cargo name-table variants in step 07i, and packed city-map
  payloads in step 07j, four saved-game payloads/descriptors in step 07k,
  working-state data/templates in step 07l, animated logo frames in step 07m,
  the interaction-window bitmap/position fields in step 07n, and interaction
  bounds/style/parameter records and their stored copies in step 07o, and the
  base dialogue dictionary plus twelve supplemental text banks in step 07p.
  Step 06ad also extracts the compressed FLIP DISK boot notice and verifies its
  decoded page against a live MAME capture.
  Step 06ae reconstructs all 96 pointed-to custom dialogue script records in
  blocks 90–102 and extracts their 160 referenced message records separately.
  Step 07q classifies the five remaining messages and bounded spare storage,
  completing code/data ownership for all thirteen dialogue banks.
  Step 06af identifies two encoded native banks and reconstructs their 63-byte
  loader entries with reversible build encoding. Step 06ag reconstructs 1,497
  additional bytes per bank through reviewed indirect flow and embedded-data
  ownership. Step 06ah adds 464 bytes per bank of native Pascal footer data and
  copied instructions/data, including two precisely bounded instruction fragments;
  24 bytes in each bank remain unresolved.
  Step 06ai identifies 26 extended copies of already disassembled p-code ranges
  and maps their 8,030 bytes to existing assembled source, with per-item code/data
  ownership and clipped instruction boundaries recorded.
  Step 06aj adds 15 exact ranges / 2,538 bytes covered by the earlier startup
  and utility module audits, retaining nearby modified utility bytes as unresolved.
  Step 06ak completes the two single-block native overlays with an unused buffer
  transfer, validated native footers and bounded zero block storage.
  Step 06al independently decodes fifteen complete retained utility-variant
  procedures, classifying 782 changed/intervening bytes while preserving prior
  exact-copy mappings and their per-byte code/data classification.
  Step 06am resolves the high-memory runtime's provisional footer, instruction
  operand fragment, linker records and stored file-version word. Other runtime
  provisional ranges remained open at that checkpoint.
  Step 06an identifies the complete 96-byte tail after the world-default table
  as an exact copy of two native-runtime vector words and 92 instruction bytes.
  Step 06ao classifies eight shorter exact p-code copies and four contextual
  utility changes (400 bytes), completing ownership of the retained five-block
  utility area without inventing its missing procedures or dictionary.
  Step 06ap identifies the initializer's retained FORTRAN protection table using
  its original compiler consumer: four address words, four code patches including
  one opcode fragment, a displacement byte and two native helpers. All 42 bytes
  are now classified, without claiming SunDog activates this runtime facility.
  Step 06aq reconstructs 604 retained linker bytes in both block-126 tails.
  Exact historical SYSTEM.LINKER copies provide complete procedure contexts;
  496 disk bytes are code and 108 are embedded data and metadata. Historical
  INN decoding is explicit because SunDog's trimmed interpreter omits it.
  Step 06ar reconstructs 28 more linker-copy bytes in both block-134 tails:
  clipped LOD operands, three complete instructions and their Reading string.
  Step 06as reconstructs 127 encoded native bytes at disk-1 block 196. Constant
  addition reveals a disk reader and its internally called NOP delay subroutine;
  all 66 instructions are reached from one entry. The final byte remains open.
  Step 06at reconstructs three shorter exact p-code tails totaling 70 bytes:
  the alternate segment-10 return/footer and clipped game-13/game-14 instruction
  runs, with complete donor procedure contexts and explicit clipping boundaries.
  Step 07r classifies all 832 bounded world/city map prefix bytes, completing
  code/data ownership of those fixed map-record banks.
  Step 07s extracts the alternate program's 1,024-byte glyph bank, using its
  direct two-block buffer replacement and existing glyph renderer as evidence.
  Step 07t extracts disk-2 block 80 as a 512-byte retained half-font: all 64
  records match shared-font masks, with five blank glyphs and cleared high bits.
  Step 07u identifies both 32-byte world-tile tails as exact copies of bank-3
  tile 15 rows 24–31, classifying another 64 disk bytes as image data.
  This overlap does not waive any
  classification or final validation requirement. Step 08a now reconstructs the
  first 288 bytes of all eight segment headers as metadata. Step 08b reconstructs the four disk-1
  directory blocks, including typed inactive records and directory spare space.
  Step 08c uses the original Apple format documentation plus verified local fields
  to reconstruct 1,652 additional header bytes; 140 library-header bytes remain
  unresolved.
  Step 08d reconstructs 978 bytes of bounded zero storage after the two full-ship
  image copies and the four-record save descriptor table.
  Step 08e reconstructs 1,178 bytes of retained Pascal directory/header fields:
  the identical block-117 directory tails and disk-1 block-259 header suffix,
  preserving cleared-name records and clipped fields without inventing allocations.
  Step 08f reconstructs the identical 492-byte tails of disk-1 blocks 260 and
  263 as retained 128K Pascal stack data, with linked string copies, call frames
  and bounded local storage establishing all 984 disk bytes as data.
  Step 08g reconstructs another 508 bytes of retained command-prompt stack data
  in blocks 103 and 139 on both disks, completing the library-header residue.
  A linked frame chain and its copied-string node bound all intervening storage.
  Step 08h reconstructs the 460-byte disk-1 block-258 compiler heap tail.
  Identifier/parameter links and constructor allocation/write evidence classify
  the native-looking remnants as unused fields inside bounded data records.
  Step 08j reconstructs the eight-byte disk-1 block-83 control record from
  direct consumers: mode, save slot, persisted globals and two block selectors.
  The remaining 504 bytes of that block still require separate classification.
  Step 08k audits 48 already source-built provisional bytes: native Pascal
  footers in the bootstrap/title prefix and bounded bootstrap zero storage.
  The title prefix's final 96 bytes remain explicitly provisional; source
  ownership totals alone are not treated as classification evidence.
  Step 08l verifies the native I/O bank's relocated six-byte state record and
  bounded zero remainder using historical field layout and matching consumers.
  The unused track-field byte and 875 spare-bank bytes now have explicit data
  evidence without changing source ownership totals or disk output.
- Step 08m reconstructs disk 2's final 4,096 zero bytes as sector-image fill.
  Independent nibble evidence has no standard sectors on that track; 532 of
  544 readable sectors, including the complete neighboring segment allocation,
  match exactly. Ownership at that checkpoint is 183,316 source-built bytes, 100,900
  identified data/asset bytes and 2,504 temporary bytes (906 disk 1; 1,598 disk 2).
- Step 08n resolves the primitive-bank descriptor as an interpreter relocation
  base and four address fields, using its direct consumer and historical layout.
  Named declarations and mutation checks preserve the exact component output.
  These ten bytes were already source-built; temporary totals do not change.
- Step 07v extracts 252 retained title-image bytes from disk-1 block 83.
  All pixel bits and eight hole bytes match the classified donor; 61 phase
  differences are preserved separately. The other 252 tail bytes stay unresolved.
  Ownership at that checkpoint is 183,316 source-built bytes, 101,152 identified data/asset
  bytes and 2,252 temporary bytes (654 disk 1; 1,598 disk 2).
- Step 06au reconstructs the disconnected jump stubs, their pointer words and
  retained track-sequence addresses in both encoded banks, including suffix
  copies. Their invalid continuation into known data is recorded without
  altering the strict graph. Six bytes per bank remain unresolved. Checkpoint
  ownership is 183,352 source-built bytes, 101,152 identified data/asset bytes
  and 2,216 temporary bytes (636 disk 1; 1,580 disk 2).
- Step 08o classifies title/viewscreen native output-buffer tails using the
  Apple Pascal assembler's verified 1,024-byte allocation, 1,023-byte clear
  and block-rounded write. This resolves 96 already source-built bytes and
  adopts 80 temporary bytes. Checkpoint ownership is 183,432 source-built bytes,
  101,152 identified data/asset bytes and 2,136 temporary bytes
  (636 disk 1; 1,500 disk 2). Historical producer identity is not asserted.
- Step 06av completes both encoded native banks. Retained disk-format constants
  match surrounding data layout, native immediate comparisons and independent
  raw-track evidence. Each full bank now has 1,475 code bytes and 573 data bytes;
  the combined audit rejects gaps/overlaps and checks every source encoding
  phase. Live body execution remains unproved. Checkpoint ownership is 183,444
  source-built bytes, 101,152 identified data/asset bytes and 2,124 temporary
  bytes (630 disk 1; 1,494 disk 2).
- Step 08p extends the native output-buffer audit to the bootstrap's fourth
  logical disk sector. Its complete footer and zero tail end at the same
  uncleared offset 1,023, with retained value $04. The recorded three-page live
  load is unchanged. Checkpoint ownership is 183,700 source-built bytes, 101,152
  identified data/asset bytes and 1,868 temporary bytes (374 disk 1; 1,494 disk 2).
- Step 08q classifies the byte after the retained encoded reader as native
  word alignment, using its complete odd-length instruction body, the decoded
  zero and independently verified assembler padding behavior. Disk-1 block 196
  is now fully classified. Checkpoint ownership is 183,701 source-built bytes,
  101,152 identified data/asset bytes and 1,867 temporary bytes
  (373 disk 1; 1,494 disk 2).
- Step 08r completes the four-block interaction-window allocation with 110
  bounded zero-storage bytes and a retained 16-byte Pascal identifier prefix.
  Historical compiler layout and native tree-search offsets support the record
  classification; missing variant fields and pointer targets are not invented.
  Checkpoint ownership is 183,827 source-built bytes, 101,152 identified data/asset
  bytes and 1,741 temporary bytes (373 disk 1; 1,368 disk 2).
- Step 08s identifies 189 bytes after the base dialogue dictionary as mutable
  supplement workspace. The shipped copy routine and all twelve supplemental
  banks establish exact writes through offset 996; the final 27 bytes remain
  unresolved. Checkpoint ownership is 184,016 source-built bytes, 101,152 identified
  data/asset bytes and 1,552 temporary bytes (373 disk 1; 1,179 disk 2).
- Step 08t classifies the 680 bytes after the ship-section and FLIP DISK RLE
  images as retained repeat-zero records and bounded zero storage. This is an
  explicit format/allocation inference; neither decoder consumes these records,
  and no historical compressor or terminator convention is asserted. Checkpoint
  ownership is 184,696 source-built bytes, 101,152 identified data/asset bytes
  and 872 temporary bytes (373 disk 1; 499 disk 2).
- Step 07w classifies the remaining 252 title-fragment bytes through a sparse
  differential 6-and-2 comparison: after separating phase and excluding the
  control record, only 16 of 686 symbols differ from the independently classified
  title. All 504 retained image bytes now have data ownership; their historical
  alteration cause remains open. Checkpoint ownership is 184,696 source-built bytes,
  101,404 identified data/asset bytes and 620 temporary bytes
  (121 disk 1; 499 disk 2).
- Step 08u classifies the identical 18-byte tails after both library-22 copies
  as retained CR-terminated text and NUL fill. The complete procedure dictionary,
  text/storage structure and historical text conventions support this inference;
  the missing text prefix and actual producer remain unknown. Current ownership
  is 184,732 source-built bytes, 101,404 identified data/asset bytes and
  584 temporary bytes (103 disk 1; 481 disk 2).
- Step 08v consolidates the five resident native-runtime audits and rechecks
  interpreter linkage. All 16,384 unique component bytes are accounted for:
  12,345 code bytes (including two instruction-fragment bytes) and 4,039 data
  bytes. Earlier provisional runtime checks are resolved. This separate scope
  does not close full-disk classification; disk ownership counts are unchanged.
- Step 08w adds `build_disks.py --no-temporary`, rejecting all temporary component
  declarations before creating outputs, and checks that identified-data evidence
  files exist within the project. Build reports now explicitly enumerate temporary
  inputs. Two fresh isolated incremental builds reproduce identical disks and
  reports without originals or prior build products. The strict check currently
  rejects 584 bytes; it is necessary but insufficient for final completion.
- Step 08x identifies the Blackblade save's 96-byte tail as a retained world-map
  cache. The shipped zero fill, map decoder, city fields, cache-ID write and save
  copy boundary reproduce its 32 tile bytes, one world identifier and 63 cleared
  bytes exactly. Current ownership is 184,828 source-built bytes, 101,404
  identified asset/data bytes and 488 temporary bytes (7 disk 1; 481 disk 2).
- Step 08y records the completed checksum-tail affine-transform search without
  adopting bytes. Step 08z consolidates all current component audit families in
  a disk-wide ledger: 136,686 code bytes, 149,546 data bytes and the same 488
  unresolved bytes. Copied operands, encoded banks and overlapping/fragment
  instructions retain explicit ownership. The strict ledger gate remains red;
  remaining classification and final evidence/delivery review are still open.
- Step 08aa consolidates the remaining tail hypotheses and negative donor
  searches in docs/unresolved-tails.md, with replayable probes and hashed input
  receipts. The template-footer hypothesis still lacks a complete donor or
  pointing dictionary. No remaining bytes are reclassified; completion criteria
  and the strict gates remain unchanged.
- Step 09a validates the rebuilt disks in MAME through play-side swapping,
  personal status, an actual game save, and a fresh-process reload. Four initial
  screens match the reference pixels; the saved bank checksum and final disk
  changes are recorded in docs/save-reload-validation.md. Apple2TS gameplay and
  final integration checks remain open; this does not waive classification.
- Step 09b validates Apple2TS gameplay, both disk swaps, game saving, fresh-browser
  saved-disk reload, and utility slot/menu navigation. The exported saved bank
  checksum passes. Browser Gamepad API input overcomes the MCP joystick gap;
  details and limitations are in docs/apple2ts-behavior-validation.md.
- Step 10a updates source/asset navigation and adds docs/delivery-checklist.md,
  mapping each required deliverable to evidence and remaining work. Two fresh
  isolated incremental builds reproduce the current disks and reports, 178
  regression tests pass, and the ledger verifies. The strict build still rejects
  488 unidentified bytes; final classification/evidence review and strict
  delivery validation remain open.
- Step 08ac applies the user's later acceptance of the exact 488-byte remainder
  as unidentified data. The build/ledger separately record `user-assumed-data`,
  enforce its frozen hashes and mappings, and contain no temporary inputs.
  Strict build and complete-ledger checks pass; both disks remain exact and all
  180 tests pass. Final isolated strict delivery verification follows.
- The incremental build matches both original disks, but still includes
  temporary binary inputs. Exact output alone does not establish completion
  of executable reconstruction or asset extraction. These earlier temporary
  counts are historical; step 08ac applies the user's bounded data exception.

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

The explicit 488-byte exception above is accepted final user-assumed data,
separately recorded from evidence-backed data. It is not an unidentified
temporary remainder and does not expand to other bytes.
