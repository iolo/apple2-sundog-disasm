# Delivery review

Step 10a reviews the current deliverables against PRD.md. **The project is not
complete:** 488 bytes remain unidentified, the final evidence review remains
open, and a standalone strict build cannot yet pass. Documentation and exact
output do not override those requirements.

| Required output or criterion | Current evidence | Remaining work |
| --- | --- | --- |
| Disassembled source | [Source index](../src/README.md), Pascal/native/script decoders, source-built components | Resolve any executable content among the remaining tails; finish the evidence/source review |
| Code/data classification of every byte | [Disk-wide ledger](classification-ledger.md): 136,686 code, 149,546 data, 488 unidentified | Classify all [remaining tails](unresolved-tails.md) with positive evidence; rerun the strict ledger |
| Extracted assets | [Asset index](../assets/README.md), 32 identified-data components with format/consumer evidence and lossless representations | Include any assets established by the remaining investigation; finish evidence review |
| Independent disk generation | [Build pipeline](reconstruction.md), [isolated incremental builds](strict-build.md) | Remove all temporary inputs only after classification; repeat isolated builds with the strict option |
| Exact or explained output | Both current 143,360-byte images match the originals; `verify_disks.py` maps any mismatch | Preserve exactness, or review and behaviorally validate each intentional difference |
| Boot, gameplay, swaps, utilities, save/reload | [Reference sequences](reference/README.md), [MAME](save-reload-validation.md), [Apple2TS](apple2ts-behavior-validation.md) | Reuse these baselines while bytes remain identical; rerun integration checks if output changes |
| Reproduction and usage | Commands below, source/asset indexes, emulator configuration and reports | Repeat final fresh-checkout instructions after strict completion |
| Per-step logs and commits | [PROGRESS.md](../PROGRESS.md), Git checkpoints | Continue for every remaining step |

The evidence ledger replays code decoders and selected audits, but inherits
some data classifications from their reports. Its coverage totals alone do not
close review of those reports' reasoning. Detailed code explanations and game
mechanics analysis are optional; evidence supporting code/data distinctions is
required. Clipped instruction fragments retain their documented donor context.

## Reproduce the current checkpoint

Use Python 3.10 or newer for the full audit commands and put `ca65` and `ld65`
on PATH. Python 3.14.4 and ca65/ld65 V2.19 Git `a028ac414` were used for the
current validation. The ordinary builder uses only Python's standard library
and the assembler/linker. Python 3.9 is sufficient for the builder itself;
the retained-linker audit uses `zip(..., strict=True)`, requiring Python 3.10.
Pillow is optional for regenerating graphical previews. Historical donor disks,
a2kit, emulator ROMs and browsers are research/behavior dependencies, not disk
build inputs. See [toolchain.md](toolchain.md) for the observed environment.

From the repository root:

```sh
python3 tools/verify_inputs.py
python3 tools/build_disks.py
python3 tools/verify_disks.py
python3 tools/classification_ledger.py
python3 -m unittest discover -s tools
```

The two outputs are `build/disks/sundog-disk1-game.dsk` and
`build/disks/sundog-disk2-util.dsk`. The same directory contains the build report
and component binaries, assembler listings and linker maps. A new output
location can be supplied with `--output` and passed to `verify_disks.py`.
The current expected hashes are:

| Image | SHA-256 |
| --- | --- |
| Disk 1 | `79226c9a2d8df006097c9c69a7de46019a610c5486dc52e07616d39381eba082` |
| Disk 2 | `52676db37d9eb93aed9a16b44b705f630522db6e160ad51d5d2c2fd9ac691e7d` |

These two checks intentionally fail until the unidentified inputs are resolved:

```sh
python3 tools/build_disks.py --no-temporary
python3 tools/classification_ledger.py --require-complete
```

The final build tree needs `tools/`, `src/`, `assets/`, `reconstruction/` and
`docs/`; evidence paths are checked during building. Original disks and the
manual are validation references. Copy those five directories into an empty
directory without originals or previous build products, run the strict build
there twice into separate output directories, and compare disks and reports.
At this checkpoint only the incremental form succeeds because it explicitly
includes temporary inputs. Remove neither their declarations nor bytes to make
a gate pass without first completing classification and source reconstruction.

The [step 10a receipt](reference/step10a-build-validation.json) records two
isolated incremental builds with identical disks/reports and the expected
488-byte strict refusal before output creation. All 178 regression tests pass;
the current ledger verifies with no missing audit adapters. These results leave
the classification and final-review requirements in the table open.

## Run the rebuilt game

Use writable working copies of the outputs. Disk 1 is the title/utility/save
side; boot it, select Play SunDog, and insert disk 2 in the same drive when the
game requests the PLAY SIDE. Saving requests disk 1 again. Booting disk 2 by
itself shows the FLIP DISK notice. The filenames are preserved for provenance.

For MAME, provide the Apple IIe ROM set and joystick support. The reproducible
reference harness creates disposable media and records its configuration:

```sh
python3 tools/reference_mame.py docs/reference/game-play.json \
  --rompath /path/to/mame/roms --image-dir build/disks
```

Inspect the resulting screens; harness completion alone does not prove correct
behavior. Follow the [save/reload report](save-reload-validation.md) to exercise
saving and a fresh process. For Apple2TS, mount working copies in its frontend
and follow the recorded [gamepad, disk-swap and fresh-browser sequence](apple2ts-behavior-validation.md).
Its MCP interface alone did not supply joystick input in the tested setup.

The baselines cover initial gameplay, utility navigation and save/reload, not
all travel, combat or utility mutations. MAME sound was disabled; no audio or
cycle-timing equivalence is claimed. MAME used `apple2e`, while Apple2TS used
`APPLE2EE`; the reports retain that model difference. Unknown meanings of
already classified data are allowed, but unidentified code/data chunks are not.
