# Delivery review

The required deliverables are complete under the user's explicit acceptance of
**488 unidentified bytes as data**. Those bytes remain unchanged and separately
counted; their code/data role is not claimed to be proved. The exact exception
is documented in [user-assumed-data.md](user-assumed-data.md).

| Required output or criterion | Final evidence / status |
| --- | --- |
| Disassembled source | [Source index](../src/README.md), procedure-aware native/Pascal/script audits, exact assembly and documented clipped instruction contexts; the bounded user exception is preserved separately |
| Every disk byte accounted for | [Ledger](classification-ledger.md): 136,686 code, 149,546 evidenced data, 488 user-assumed data; all 166 components integrated, zero temporary bytes or missing adapters |
| Extracted assets | [Asset index](../assets/README.md): 32 identified-data components, 31 manifests, format/consumer evidence and lossless representations |
| Independent disk generation | [Final build receipt](reference/final-build-validation.json): two isolated strict builds without originals, manual or earlier build products; disks and reports identical |
| Exact or explained output | Both 143,360-byte images exactly match the originals; no output deviation requires explanation |
| Boot, gameplay, swaps, utilities, save/reload | [Reference sequences](reference/README.md), [MAME](save-reload-validation.md), [Apple2TS](apple2ts-behavior-validation.md); final identical bytes reuse these exercised baselines |
| Evidence and representation review | [Final review receipt](reference/final-evidence-review.json): integrated ledger with 404 proof files, 15 data audits, 17 asset/script verifiers and eight re-extracted asset groups |
| Reproduction and usage | Commands below, source/asset indexes, emulator configuration and reports |
| Per-step logs and commits | [PROGRESS.md](../PROGRESS.md), including final step 10b and earlier checkpoints |

All 180 regression tests pass. Fifty-three regenerated asset files, including
previews and reversible representations, match the delivered files exactly.
The complete-ledger check also passes inside the isolated tree without original
inputs. Source inspection found no `.incbin` directives; documented clipped
instruction bytes retain their complete donor contexts. Data classifications
based on bounded inference retain the limitations stated in their reports.

No required work remains under the revised scope. Further interpretation of the
488 bytes, extended gameplay/audio testing, detailed code explanations and game
mechanics analysis are optional. Earlier documents and progress entries retain
historical incomplete counts; this review and the current manifest/ledger state
the final acceptance status.

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
python3 tools/build_disks.py --no-temporary
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

Both strict gates now pass with the user exception recorded separately:

```sh
python3 tools/build_disks.py --no-temporary
python3 tools/classification_ledger.py --require-complete
```

The final build tree needs `tools/`, `src/`, `assets/`, `reconstruction/` and
`docs/`; evidence paths are checked during building. Original disks and the
manual are validation references. Copy those five directories into an empty
directory without originals or previous build products, run the strict build
there twice into separate output directories, and compare disks and reports.
The final receipt records two such strict builds and a complete-ledger check.
The accepted data files are required inputs; do not omit them or expand their
scope. Their exact sizes, hashes and disk mappings are enforced independently
of the normal image comparison.

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
already classified data are allowed. The only accepted unidentified bytes are
the explicitly recorded 488-byte user exception.
