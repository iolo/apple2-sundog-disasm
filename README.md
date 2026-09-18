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
available, with most bytes still explicitly marked as temporary and unresolved:

```sh
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

See [build instructions and coverage](docs/reconstruction.md). The bootstrap,
early title routine, complete SYSTEM.APPLE runtime, and 28 of the 34 distinct
inventoried Pascal segments are source-built. Six segments, the split system
fragment, assets, and other disk regions still require work. The
[executable coverage report](docs/executable-coverage.json) lists remaining modules.
Current source-built output is 114,716 bytes; 172,004 bytes remain temporary.
These are disk-byte ownership totals, not instruction counts or completion percentages.

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
