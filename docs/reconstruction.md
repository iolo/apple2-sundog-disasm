# Incremental exact-disk build

The incremental build reconstructs both disk images using assembled source components and
explicitly temporary binary inputs for the remaining bytes. It is a working
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
manifest and its component files. It checks component sizes/hashes, complete
image coverage, and final image hashes. The comparison command separately
checks the originals, then exact byte equality; any mismatch exits nonzero and
reports the first image offset, expected/actual byte, track, image/physical
sector, logical block/half, and mapped reconstruction component.

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
| Unresolved disk-1 remainder | `reconstruction/temporary/disk1-unresolved.bin` | All other disk-1 bytes, mapped explicitly | 125,148 |
| Unresolved disk-2 remainder | `reconstruction/temporary/disk2-unresolved.bin` | All disk-2 bytes | 143,360 |

The 18,212 source-built bytes include instructions and their owned tables,
attributes, text, padding, and bootstrap tail bytes. This is **not** a count of
18,212 instruction bytes. Most identified executable regions are still in the
temporary inputs. The [Pascal inventory](pascal-segments.md) and
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
