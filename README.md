# apple2-sundog-disasm

Reverse engineering the supplied Apple II SunDog disks, with the goal of a
runnable rebuild from disassembled source and extracted data/assets. Every region
must be classified as code or data with evidence, except for the explicitly
accepted [488-byte user data assumption](docs/user-assumed-data.md). Byte identity
is preferred; any differences must be explained and validated (see [PRD.md](PRD.md)).

Required work is complete under that bounded exception. Two isolated strict
builds reproduce both original disks exactly; all 180 tests pass.

See [PLAN.md](PLAN.md) for the implementation sequence and
[PROGRESS.md](PROGRESS.md) for evidence and per-step checkpoints.
The [delivery checklist](docs/delivery-checklist.md) maps each required output
to its evidence, reproduction commands and remaining work. The
[source index](src/README.md) and [asset index](assets/README.md) describe the
current delivered representations.

Original inputs remain at the repository root and are described in
[docs/inputs.md](docs/inputs.md). Verify them with:

```sh
python3 tools/verify_inputs.py
```

`src/` holds reconstructed code, `assets/` holds extracted assets, `tools/` holds
automation, and `docs/` holds investigation notes. Generated files and disposable
emulator media go under ignored `build/`. The exact-disk build preserves the accepted data assumption separately:

```sh
python3 tools/build_disks.py --no-temporary
python3 tools/verify_disks.py
```

The [strict input check](docs/strict-build.md) rejects temporary inputs. It accepts
the exact 488-byte user exception with its recorded scope and hashes; this does
not turn that assumption into code/data evidence.

See [build instructions and coverage](docs/reconstruction.md). The bootstrap,
early title routine, complete SYSTEM.APPLE runtime, all 34 distinct inventoried
Pascal segments, the split-system fragment, raw overlays and encoded native
banks are source-built. The [resident runtime audit](docs/runtime-classification.md)
resolves its earlier provisional fields; the [Pascal inventory report](docs/executable-coverage.json)
has a separate, narrower scope.

Current disk ownership is **184,828 source-built bytes**, **101,404 identified
asset/data bytes**, and **488 user-assumed data bytes** (7 on disk 1; 481 on disk
2). There are no temporary inputs. Source-built totals include data declarations.
The [disk-wide ledger](docs/classification-ledger.md) separately records 136,686
code bytes, 149,546 evidenced data bytes and the 488-byte assumption, with every
component audit connected. [Historical tail research](docs/unresolved-tails.md)
retains the evidence limits; the user has ended required identification of those
bytes. See the [delivery checklist](docs/delivery-checklist.md) for validation.

Extracted assets include [title artwork](docs/title-bitmap.md),
[fonts](docs/shared-font.md), [compressed images](docs/packed-ship-images.md),
[tiles](docs/tile-banks.md), [world maps](docs/world-maps.md),
[city maps](docs/city-maps.md), [saved-game data](docs/save-state-banks.md),
[dialogue text](docs/dialogue-dictionary.md), and their documented retained
variants. [Custom dialogue scripts](docs/dialogue-scripts.md) are reconstructed
as instructions separately from their text.

Behavior checks cover gameplay, disk swaps, utilities, saving and fresh-session
reloads in [MAME](docs/save-reload-validation.md) and
[Apple2TS](docs/apple2ts-behavior-validation.md). Those reports state their
limits; the identical-output reconstruction checkpoints reuse those baselines.

Completed investigations include [reference boot and play sequences](docs/reference/README.md)
and a [lossless disk inventory and repacker](docs/disk-layout.md). The supplied
disk filenames are preserved, but disk 1 is the observed title/utility side and
disk 2 is the play side.

Runtime investigation now includes the [bootstrap and initialization trace](docs/bootstrap.md)
and a [Pascal segment/procedure inventory](docs/pascal-segments.md), including
segments on the play disk and native procedures embedded in Pascal libraries.
The [p-code toolchain proof](docs/pcode-toolchain.md) documents the first
system procedure reconstructed from source with ca65.
The [runtime architecture](docs/runtime-architecture.md) documents the confirmed
startup/library load path and the selected reconstruction tools.
