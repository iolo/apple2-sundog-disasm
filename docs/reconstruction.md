# Incremental exact-disk build

Current checkpoint: step 06au has 183,352 source-built disk bytes (including
explicit data declarations), 101,152 identified asset/data bytes, and 2,216
temporary bytes: 636 on disk 1 and 1,580 on disk 2. The latest reconstruction adds
[retained encoded-bank stubs and pointers](encoded-retained-stubs.md). Historical counts
below describe their individual checkpoints; the manifest is authoritative.

The incremental build reconstructs both disk images using assembled source components and
classified asset data and explicitly temporary binary inputs for remaining bytes. It is a working
source-to-disk pipeline, not the completed source-and-assets reconstruction.

## Build and verify

Prerequisites are Python 3.9 or newer and `ca65`/`ld65` on PATH. Tested versions
are recorded in [toolchain.md](toolchain.md). From the repository root:

```sh
python3 tools/build_disks.py
python3 tools/verify_disks.py
python3 tools/test_reconstruction.py
```

Output goes to `build/disks/`, including the two original filenames,
`build-report.json`, and assembled component binaries/listings/maps under
`components/`. Use `--output /path/to/new-output` for a different build location
and pass that directory to `verify_disks.py`.

The build reads only source, linker configurations, and the reconstruction
manifest and its component files, plus identified data under `assets/`. It checks component sizes/hashes, complete
image coverage, and final image hashes. The comparison command separately
checks the originals, then exact byte equality; any mismatch exits nonzero and
reports the first image offset, expected/actual byte, track, image/physical
sector, logical block/half, and mapped reconstruction component.

## Acceptance criteria

Every region must be classified as code or data with evidence. All executable
content must be represented as instructions; identified data may retain unknown
semantics. Temporary unresolved inputs are never accepted as final data simply
because the build succeeds. Byte identity is preferred rather than mandatory;
any deviations need a mapped, explained difference report and behavioral checks.
The current pipeline remains strict because its outputs still match exactly.
Full emulator runs are reserved for integration milestones or changed output;
byte-identical module replacements reuse the established reference behavior.

## Source coverage at this checkpoint

| Component | Source | Output locations | Bytes |
| --- | --- | --- | ---: |
| Three-page native bootstrap | `src/native/bootstrap.s` | Disk 1 image offsets `$0000`, `$0E00`, `$0D00`, 256 bytes each | 768 |
| Early title routine and tables | `src/native/title_draw.s` | Disk 1 logical blocks 201–202 | 1,024 |
| Native p-code primitives | `src/native/pcode_primitives.s` | Disk 1 blocks 243–250 and first 229 bytes of block 227 | 4,325 |
| Native disk/device/console bank | `src/native/native_io.s` | Disk 1 blocks 219–226 | 4,096 |
| Shared native interpreter/device runtime | `src/native/native_shared.s` | Disk 1 block 227 byte 229 through block 236 byte 143 | 4,523 |
| Copied runtime initializer | `src/native/native_init.s` | Disk 1 block 236 byte 144 through block 238 byte 399 | 1,280 |
| High-memory native services and preserved tail | `src/native/native_high.s` | Disk 1 block 238 byte 400 through block 242 byte 511 | 2,160 |
| SYSTEM.PASCAL first procedure | `src/pcode/system_entry.s` | Disk 1 image offset `$1F700` | 36 |
| Disk-1 SYSTEM.STARTUP segment 1 | `src/pcode/startup_disk1.s` | Disk 1 block 141 through first 64 bytes of block 142 | 576 |
| Disk-1 UTILITY segment 1 | `src/pcode/utility_disk1.s` | Disk 1 block 86 onward | 8,644 |
| P-code library_25 | `src/pcode/library_25.s` | disk1 block 127 onward; disk2 block 127 onward | 1,916 |
| P-code library_27 | `src/pcode/library_27.s` | disk1 block 135 onward; disk2 block 135 onward | 3,232 |
| P-code library_28 | `src/pcode/library_28.s` | disk1 block 139 onward; disk2 block 139 onward | 656 |
| P-code startup_7 | `src/pcode/startup_7.s` | disk1 block 143 onward; disk2 block 143 onward | 3,736 |
| P-code alternate_7 | `src/pcode/alternate_7.s` | disk1 block 158 onward | 764 |
| P-code alternate_8 | `src/pcode/alternate_8.s` | disk1 block 160 onward | 3,348 |
| P-code alternate_9 | `src/pcode/alternate_9.s` | disk1 block 167 onward | 1,212 |
| P-code alternate_10 | `src/pcode/alternate_10.s` | disk1 block 170 onward | 950 |
| P-code system_1 | `src/pcode/system_1.s` | disk1 block 260 onward | 20 |
| P-code system_3 | `src/pcode/system_3.s` | disk1 block 263 onward | 20 |
| P-code system_4 | `src/pcode/system_4.s` | disk1 block 264 onward | 1,998 |
| P-code system_5 | `src/pcode/system_5.s` | disk1 block 268 onward | 1,670 |
| P-code game_8 | `src/pcode/game_8.s` | disk2 block 147 onward | 3,130 |
| P-code game_12 | `src/pcode/game_12.s` | disk2 block 174 onward | 5,546 |
| P-code game_13 | `src/pcode/game_13.s` | disk2 block 154 onward | 10,214 |
| P-code game_14 | `src/pcode/game_14.s` | disk2 block 185 onward | 2,544 |
| P-code game_15 | `src/pcode/game_15.s` | disk2 block 190 onward | 2,654 |
| P-code game_16 | `src/pcode/game_16.s` | disk2 block 196 onward | 7,446 |
| P-code game_17 | `src/pcode/game_17.s` | disk2 block 211 onward | 3,532 |
| P-code game_18 | `src/pcode/game_18.s` | disk2 block 218 onward | 6,280 |
| P-code game_19 | `src/pcode/game_19.s` | disk2 block 231 onward | 5,200 |
| P-code game_20 | `src/pcode/game_20.s` | disk2 block 242 onward | 6,836 |
| P-code game_21 | `src/pcode/game_21.s` | disk2 block 256 onward | 8,132 |
| P-code system_2 | `src/pcode/system_2.s` | disk1 block 261 onward | 808 |
| P-code system_6 | `src/pcode/system_6.s` | disk1 block 272 onward | 3,652 |
| Mixed p-code/native library_23 | `src/pcode/library_23.s` | disk1 block 116 onward; disk2 block 116 onward | 1,212 |
| Disk-2 startup segment 1 | `src/pcode/startup_disk1.s` (shared source) | Disk 2 block 141 onward | 576 |
| P-code alternate_1 | `src/pcode/alternate_1.s` | disk1 block 172 onward | 880 |
| P-code library_24 | `src/pcode/library_24.s` | disk1 block 118 onward; disk2 block 118 onward | 8,612 |
| P-code library_26_disk1 | `src/pcode/library_26_disk1.s` | disk1 block 129 onward | 3,058 |
| P-code library_26_disk2 | `src/pcode/library_26_disk2.s` | disk2 block 129 onward | 3,058 |
| P-code library_22 | `src/pcode/library_22.s` | disk1 block 104 onward; disk2 block 104 onward | 12,252 |
| Split SYSTEM.PASCAL remainder | `src/pcode/system_core.s` | Disk 1 core block 252 after byte 35; fragment at block 259 | 3,258 |
| Title HGR image data | `assets/title/title.hgr` | Disk 1 blocks 203–218 | 8,192 |
| Pascal segment-header tables | `src/data/pascal_header_tables.s` | First 288 bytes of eight headers on both disks | 2,304 |
| Raw screen-address initializer and table | `src/native/raw_screen_init.s` | Disk 1 block 2, first 297 bytes | 297 |
| Raw buffer transformation entry | `src/native/raw_buffer_transform.s` | Disk 1 block 156, first 93 bytes | 93 |
| Shared font and symbol bank | `assets/font/font.bin` | Both disks, blocks 3–4 | 2,048 |
| Certificate reveal code and native metadata | `src/native/certificate_reveal.s` | Disk 1 block 21 | 512 |
| Registration certificate HGR page | `assets/certificate/certificate.hgr` | Disk 1 blocks 5–20 | 8,192 |
| Warp animation code and embedded data | `src/native/warp_animation.s` | Disk 2 blocks 83–85 | 1,536 |
| Viewscreen transition and native metadata | `src/native/viewscreen_transition.s` | First 944 bytes of disk 2 blocks 86–87 | 944 |
| Shared viewscreen drawing/joystick overlay | `src/native/viewscreen_io.s` | Disk 2 blocks 81–82 | 1,024 |
| Raw disk-integrity checker and table | `src/native/disk_checksum.s` | First 135 bytes of disk 2 block 54 | 135 |
| Play graphics banks 1 and 2 | `assets/play-glyphs/bank{1,2}/glyphs.bin` | Disk 2 blocks 5–8 | 2,048 |
| Compressed ship outlines | `assets/ship-images/{full_ship,ship_section}/image.rle` | Disk 2 blocks 29 and 33; shared stream at disk 1 block 188 | 4,934 |
| Four 32-row tile banks | `assets/tiles/bank{0,1,2,3}/tiles.bin` | Disk 2 blocks 9–24; copies at disk 1 blocks 176–183 | 12,288 |
| World-map tiles and variants | `assets/world-tiles/tiles.bin` | First 2,016 bytes at disk 2 block 25 and disk 1 block 184 | 4,032 |
| Packed world-map payloads | `assets/world-maps/maps.bin` | 240-byte payloads in disk 2 blocks 55–63; copies in disk 1 block 194 | 4,800 |
| Pascal directory views | `src/data/pascal_directories.s` | Disk 1 blocks 79–82 | 2,048 |
| Inventory/cargo name-table variants | `assets/item-names/{demo,play}/records.bin` | Disk 1 blocks 192–193; disk 2 blocks 46–47 | 2,048 |
| Packed city-map payloads | `assets/city-maps/maps.bin` | 120-byte payloads in disk 2 blocks 64–78 and disk 1 block 195 | 7,680 |
| Saved-game payloads and descriptors | `assets/save-states/{payloads,slots}.bin` | Disk 1 first 5,024 bytes of banks at 27, 37, 47, 57; first 256 bytes of block 26 | 20,352 |
| Record templates, world defaults, working state | `assets/working-state/data.bin` | Reviewed regions at disk 1 blocks 22–25; disk 2 blocks 2, 45, 48–53 | 6,027 |
| Animated logo letter frames | `assets/logo-frames/frames.bin` | Disk 1 blocks 67–78 | 6,144 |
| Unresolved disk-1 remainder | `reconstruction/temporary/disk1-unresolved.bin` | All other disk-1 bytes, mapped explicitly | 17,725 |
| Interaction-window bitmap and position fields | `assets/interaction-window/window.bin` | Disk 2 blocks 37–40: first 1,920 bytes and offsets 2000–2001 | 1,922 |
| Play-disk boot native code and count | `src/native/play_boot.s` | Disk 2 block 0 bytes 0–192 | 193 |
| Compressed FLIP DISK boot notice | `assets/play-boot/image.rle` | Disk 2 logical bytes 256–831 | 576 |
| Interaction bounds/style/parameter records | `assets/interaction-records/records.bin` | Disk 2 block 79 and disk 1 block 196 offsets 128–511 | 896 |
| Base and supplemental dialogue dictionary | `assets/dialogue-dictionary/dictionary.bin` | Disk 2 blocks 88–89 first 808 bytes; reviewed metadata/text in twelve blocks 90–102 | 1,930 |
| Custom dialogue scripts and entry tables | `src/dialogue/scripts.s` | Reviewed records/table bytes in disk 2 blocks 90–102 | 1,175 |
| Counted dialogue messages | `assets/dialogue-messages/messages.bin` | 160 referenced word-aligned records in disk 2 blocks 90–102 | 3,434 |
| Dialogue bank spare storage and unused messages | `assets/dialogue-bank-storage/data.bin` | Final reviewed ranges in disk 2 blocks 90–102 | 925 |
| Encoded native loader entries | `src/native/encoded_loader_{play,alternate}.s` | First 63 bytes at disk 2 block 41 and disk 1 block 197 | 126 |
| Unresolved disk-2 remainder | `reconstruction/temporary/disk2-unresolved.bin` | Other disk-2 bytes | 14,306 |

The 156,221 source-built bytes include instructions, custom script records and their owned tables,
attributes, text, padding, header metadata, and bootstrap tail bytes. This is **not** a count of
156,221 native instruction bytes. All inventoried Pascal segments and the split core fragment are now source-built;
other unclassified disk regions remain in the temporary inputs. The [Pascal inventory](pascal-segments.md) and
[runtime architecture](runtime-architecture.md) identify the next modules.

All 16,384 bytes of SYSTEM.APPLE now come from the five native runtime
components. Their documentation explicitly retains open data/provenance
questions; this does not mark the remaining Pascal code or overall step 06 done.

The native source preserves the bootstrap page-count byte as 1, not its runtime
value 5. It separates the slot-error message, physical-sector order, seek-delay
tables, padding, and unreferenced tail from instructions. Branches use labels,
and explicit link addresses reproduce the observed `$0800`–`$0AFF` image.
No executable bytes are imported with `.incbin` in the source components.

Both remaining blobs are categorized `temporary-unresolved`, not assets or
finished source. `reconstruction/manifest.json` is the byte-level coverage
ledger: replace those ranges as executable modules and assets are reconstructed.
The normal build does not run `seed_reconstruction.py`; original disks are
needed only to repeat the initial archival extraction or perform comparison.

## Validation evidence

`reference/step05-build-validation.json` records the initial build report, emulator
command, six screenshot hashes, media hashes, and independent-build/tamper checks.
`reference/step06a-build-validation.json` records the subsequent title-routine
integration and its matching screenshot comparison.
`reference/step06b-build-validation.json` adds the native primitive bank and
matching play/utility reference runs.
`reference/step06c-build-validation.json` adds the native disk/device/console
bank with matching play/utility reference runs.
`reference/step06d-build-validation.json` adds the shared native runtime and
its matching reference comparisons.
`reference/step06e-build-validation.json` adds the copied initializer, matching
the complete captured memory image and the play/utility reference sessions.
`reference/step06f-build-validation.json` completes SYSTEM.APPLE byte coverage
and repeats the isolated build without original inputs and reference sessions.
`reference/step06g-build-validation.json` adds the complete disk-1 startup p-code
segment and matching loader capture and play/utility reference sessions.
`reference/step06h-build-validation.json` adds the full utility segment and
expanded decoder; exact comparisons reuse the unchanged behavior baseline.

- Both full images are 143,360 bytes and match their original SHA-256 hashes
  and every byte. The baseline hashes are in `inputs.json`.
- A fresh isolated tree containing only the needed tools, `src/`, and
  `reconstruction/` builds the same disks with no original images present.
  This proves the build dependency boundary, not completeness of the temporary
  inputs' reconstruction.
- A modified byte at image offset `$00E07` is rejected with exit status 1 and
  correctly reported as track 0, physical sector 2, block 0 half 1, bootstrap.
  Unit tests also reject coverage gaps/overlaps, bad slices, missing inputs,
  and path escapes, and check truncated/extended-image differences.
- MAME runs the rebuilt pair through `game-play.json`: title/menu, selection,
  play-side prompt, disk swap, ship interior, and personal-status screen.
  All six PNG files are byte-identical to the original reference run, and both
  disposable media copies retain their initial hashes.

Repeat the behavior check using the ROM path on your machine:

```sh
python3 tools/reference_mame.py docs/reference/game-play.json \
  --rompath /path/to/mame/roms --image-dir build/disks
```

This checkpoint does not validate every game interaction, save/load, sound, or
the final required gameplay checks in both emulators. Those remain step 09.

## Current executable inventory audit

Run `python3 tools/executable_coverage.py --output docs/executable-coverage.json`
to reproduce source ownership for inventoried segments and the split-system
fragment. Every copy of all 34 distinct inventoried segments and the 170-byte
fragment is source-built. This is an inventory-scoped result. Orphan/header
candidates, assets, unallocated regions, and provisional native-runtime data
classifications still need investigation; none is silently included in the
completed count.

`reference/step06o-build-validation.json` records a fresh build using only copied
`tools/`, `src/`, and `reconstruction/` directories, with no original images or
docs available. Both outputs equal the current exact baseline. Recorded runtime
captures were rechecked: 5,598 initialization bytes, 16 p-code dispatch snapshots,
and 12 whole overlay loads. No new emulator session was run for this checkpoint;
final behavior checks in both emulators, including save/load, remain outstanding.

## First classified asset

The title HGR page contributes 8,192 `identified-data` bytes. At step 07a it
accompanied 145,834 `ca65-source` bytes and 132,694 temporary bytes. Step 08a
raises source ownership to 148,138 bytes and reduces temporary inputs to 130,390 bytes. The build
requires asset format and evidence metadata, checks its size/hash, and reads its
repository-relative asset path. It does not extract data during a normal build.

`reference/step07a-build-validation.json` records a new clean build with only
`tools/`, `src/`, `reconstruction/`, and `assets/`, plus fresh MAME play and utility
runs. All ten screenshots and normalized final media hashes match the original
references. The title PNG is a monochrome layout preview; its limitations and
lossless row/hole round trip are documented in [title-bitmap.md](title-bitmap.md).

## Classified segment-header tables

Step 08a adds 2,304 data bytes as typed ca65 declarations: the first 288 bytes
of each inventoried header. Six unique tables serve eight disk locations. The
[header evidence](pascal-header-tables.md) distinguishes the table layout from
the unreviewed tails and block 84's invalid segment reference. Generation and
adoption each checked exact bytes; the complete build still matches both disks.
No new emulator run is needed for these unchanged outputs; step 07a's fresh
reference runs remain applicable.

Step 06w adds the [raw screen initializer](raw-screen-init.md): 105 code bytes
and 192 table bytes outside the Pascal inventory. At that checkpoint ownership was 148,435
source-built bytes, 8,192 asset bytes, and 130,093 temporary bytes. Discovery of
raw overlays reinforces that inventoried-segment coverage is not full code coverage.

Step 06x adds 93 raw buffer-transformation instruction bytes and confirms the
earlier screen initializer in apple2ts. At that checkpoint ownership was 148,528 source bytes,
8,192 asset bytes, and 130,000 temporary bytes. See [raw-buffer-transform.md](raw-buffer-transform.md)
and `reference/raw-screen-runtime.json` for the distinct static and runtime evidence.

Step 07b extracts the [shared font](shared-font.md), with all 128 glyphs previewed
and a lossless display-order row listing. Its 1,024 bytes match live apple2ts
memory and replace 2,048 disk bytes across both copies. At that checkpoint ownership was
148,528 source-built bytes, 10,240 classified asset bytes, and 127,952 temporary
bytes. The source/data-only completion gate and final gameplay checks remain open.

Step 06y reconstructs the [certificate reveal routine](certificate-reveal.md)
and its complete first-block metadata/padding. At that checkpoint source ownership was 149,040 bytes,
classified assets occupy 10,240 bytes, and 127,440 bytes remain temporary. The
extra block fetched by its caller is explicitly excluded from classification.

Step 07c extracts the [registration certificate](certificate-bitmap.md), whose
row consumer is now disassembled. At that checkpoint ownership was 149,040 source-built bytes,
18,432 classified asset bytes, and 119,248 temporary bytes. Its image holes are
uniform $80 padding, preserved along with every pixel/phase byte.

Step 06z reconstructs the [warp animation](warp-animation.md), with 586 native
instructions and fully classified embedded masks, bitmap, and workspace bytes.
At that checkpoint ownership was 150,576 source-built bytes, 18,432 classified asset bytes,
and 117,712 temporary bytes. Both complete images still match the originals.

Step 06aa reconstructs the [viewscreen transition](viewscreen-transition.md),
including its 410 instructions, drawing tables, row-copy buffer, and native
metadata. At that checkpoint ownership was 151,520 source-built bytes, 18,432 classified
asset bytes, and 116,768 temporary bytes. The extra 80 bytes read after the
944-byte native container remain unresolved. Both full images still match exactly.

Step 06ab reconstructs the [shared viewscreen drawing/joystick overlay](viewscreen-io.md),
including its 290 instructions and all lookup tables/workspace. At that checkpoint ownership
was 152,544 source-built bytes, 18,432 classified asset bytes, and 115,744 temporary
bytes. Both complete disk images still match exactly.

Step 06ac reconstructs the [raw disk-integrity checker](disk-checksum.md) and
validates its table against all 31 checked eight-block groups. At that checkpoint ownership
was 152,679 source-built bytes, 18,432 asset bytes, and 115,609 temporary bytes.
The checker does not establish code/data classification of the bytes it checks.

Step 07d extracts the [two play graphics banks](play-glyphs.md), including
all 256 glyph records, raw masks, display-order rows, and atlas previews. At that checkpoint
ownership was 152,679 source-built bytes, 20,480 asset bytes, and 113,561 temporary
bytes. The bank-2 copy gaps retain their original high bits.

Step 07e extracts the [compressed ship outlines](packed-ship-images.md), with
lossless packet listings and complete decoded HGR pages. At that checkpoint ownership was
152,679 source-built bytes, 25,414 asset bytes, and 108,627 temporary bytes.
Bytes fetched beyond the consumed RLE streams remain separately unresolved.

Step 07f extracts the [four 32-row tile banks](tile-banks.md), including all
64 tiles and the two identical disk-1 copies. At that checkpoint ownership was 152,679
source-built bytes, 37,702 asset bytes, and 96,339 temporary bytes. The separate
24-row bank and its boundaries remain unresolved.

Step 07g extracts the [world-map tiles](world-tiles.md), including seven
terrain variants selected after map decoding. At that checkpoint ownership was 152,679
source-built bytes, 41,734 asset bytes, and 92,307 temporary bytes. The 32-byte
tail of each four-block read remains unresolved.

Step 07h extracts the [packed world maps](world-maps.md), preserving the exact
two-bit symbols as well as their state-decoded tile grids. Current ownership is
152,679 source-built bytes, 46,534 asset bytes, and 87,507 temporary bytes. All
16-byte record prefixes remain separately unresolved.

Step 08b reconstructs all four disk-1 directory blocks from typed declarations,
including inactive records and unused directory capacity; see
[Pascal directories](pascal-directories.md). At that checkpoint ownership was 154,727
source-built bytes, 46,534 asset bytes, and 85,459 temporary bytes. Both rebuilt
images remained exact; the final code/data audit and emulator checks remained open.

Step 07i extracts the two [inventory/cargo name tables](item-names.md) as counted
strings, residual fixed-width string storage, and numeric bytes. Ownership then
was 154,727 source-built bytes, 48,582 classified data/asset bytes, and 83,411
temporary bytes. Both full disks remain exact; final classification and behavior
validation are still incomplete.

Step 07j extracts 60 play and four demo [city maps](city-maps.md), preserving
each 20×12 grid as reversible four-bit values. Their eight-byte record prefixes
remain unresolved. Ownership then was 154,727 source-built bytes, 56,262
identified data/asset bytes, and 75,731 temporary bytes. Both disks remain exact;
full classification and final behavioral validation are still incomplete.

Step 07k extracts the evidenced portions of four [saved-game banks](save-state-banks.md)
and their slot descriptors, with exact structured-record round trips and matching
full-bank checksums. Their 96-byte bank tails remain unresolved. Ownership then
was 154,727 source-built bytes, 76,614 classified data/asset bytes, and 55,379
temporary bytes. Both disks remain exact; final classification and live save/load
validation in both emulators remain open.

Step 07l extracts [working-state records and templates](working-state.md),
including three copies of a 505-byte template table, 1,440 bytes of default
world tables, and six blocks of working records. Ownership then was 154,727
source-built bytes, 82,641 classified data/asset bytes, and 49,352 temporary
bytes. Both rebuilt images remain exact; the remaining template/allocation tails
and final emulator validation are still open.

Step 07m extracts the 48 [animated logo frames](logo-frames.md), including their
explicit zero record padding. Ownership then was 154,727 source-built bytes,
88,785 classified data/asset bytes, and 43,208 temporary bytes. Both images
remain exact; the final complete classification and emulator checks remain open.

Step 07n extracts the [interaction-window bitmap and position fields](interaction-window.md),
leaving 126 unrelated allocation bytes unresolved. Ownership then was 154,727
source-built bytes, 90,707 classified data/asset bytes, and 41,286 temporary bytes.

Step 06ad reconstructs the [play-disk boot program and FLIP DISK notice](play-disk-boot.md):
192 native instruction bytes, one boot-count byte, and 576 compressed data bytes.
The static HGR decode matches the live MAME page exactly. Ownership then was
154,920 source-built bytes, 91,283 classified data/asset bytes, and 40,517 temporary
bytes (18,172 disk 1; 22,345 disk 2). Final classification and both-emulator
validation remain open.

Step 07o extracts sixteen [interaction records](interaction-records.md) and twelve
exact stored copies, classifying 896 disk bytes. The differing 128-byte disk-1
prefix and adjacent disk-2 glyph-like block remain unresolved. Ownership then
was 154,920 source-built bytes, 92,179 classified data/asset bytes, and 39,621
temporary bytes (17,788 disk 1; 21,833 disk 2).

Step 07p extracts the [base dialogue dictionary and supplemental text](dialogue-dictionary.md):
808 base bytes plus 1,122 bytes from twelve banks. Script regions and unrelated
tails remain unresolved. Ownership then was 154,920 source-built bytes,
94,109 classified data/asset bytes, and 37,691 temporary bytes (17,788 disk 1;
19,903 disk 2).

Step 06ae reconstructs the [custom dialogue scripts](dialogue-scripts.md) and
extracts their counted messages: 979 script bytes, 196 additional table bytes,
and 3,434 message bytes. Ownership then was 156,095 source-built bytes,
97,543 classified data/asset bytes, and 33,082 temporary bytes (17,788 disk 1;
15,294 disk 2).

Step 07q finishes [dialogue-bank classification](dialogue-bank-layout.md) with
five additional counted messages and bounded zero-filled spare script storage.
All 6,656 bytes in blocks 90–102 are now classified. Ownership then was
156,095 source-built bytes, 98,468 classified data/asset bytes, and 32,157
temporary bytes (17,788 disk 1; 14,369 disk 2).

Step 06af reconstructs two [encoded native loader entries](encoded-native-overlay.md).
The builder assembles plain instructions and applies their reversible storage
encoding before placement; `.decoded.bin` component artifacts retain the plain
assembly output for review. The encoded bodies remain unresolved. Current
ownership is 156,221 source-built bytes, 98,468 classified data/asset bytes,
and 32,031 temporary bytes (17,725 disk 1; 14,306 disk 2).
Both rebuilt images remain exact; final classification and behavioral validation
remain incomplete.
