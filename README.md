# apple2-sundog-disasm

Reverse engineering the supplied Apple II SunDog disks, with the goal of a
runnable rebuild from disassembled source and extracted data/assets. Every region
must be classified as code or data with evidence. Byte identity is preferred;
any differences must be explained and validated. Unidentified chunks are not
acceptable in the final deliverable (see [PRD.md](PRD.md)).

See [PLAN.md](PLAN.md) for the implementation sequence and
[PROGRESS.md](PROGRESS.md) for evidence and per-step checkpoints.

Original inputs remain at the repository root and are described in
[docs/inputs.md](docs/inputs.md). Verify them with:

```sh
python3 tools/verify_inputs.py
```

`src/` holds reconstructed code, `assets/` holds extracted assets, `tools/` holds
automation, and `docs/` holds investigation notes. Generated files and disposable
emulator media go under ignored `build/`. An incremental exact-disk build is now
available, with unresolved bytes explicitly tracked as temporary inputs:

```sh
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

The build also supports `python3 tools/build_disks.py --no-temporary`. It
currently exits with an error because 488 bytes remain unclassified. This
[strict input check](docs/strict-build.md) prevents temporary inputs from entering
a final build; passing it alone would not prove the required classification audit.

See [build instructions and coverage](docs/reconstruction.md). The bootstrap,
early title routine, complete SYSTEM.APPLE runtime, all 34 distinct inventoried
Pascal segments, the split-system fragment, raw overlays and encoded native
banks are source-built. The [resident runtime audit](docs/runtime-classification.md)
resolves its earlier provisional fields; the [Pascal inventory report](docs/executable-coverage.json)
has a separate, narrower scope.

Current disk ownership is **184,828 source-built bytes**, **101,404 identified
asset/data bytes**, and **488 temporary unclassified bytes** (7 on disk 1;
481 on disk 2). Source-built totals include explicit data declarations and are
not instruction counts. The [disk-wide classification ledger](docs/classification-ledger.md)
separately records 136,686 code bytes and 149,546 data bytes, with every current
component audit connected and the 488 unresolved bytes still explicit. The
remaining tails, final evidence review, clean reproducibility checks and
delivery documentation are still open.
Exact output alone does not establish completion.
The [remaining-tail evidence notes](docs/unresolved-tails.md) distinguish current
hypotheses from classification evidence and record bounded donor searches.

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
