# apple2-sundog-disasm

Reverse engineering the supplied Apple II SunDog disks, with the goal of a
byte-identical rebuild from disassembled source and extracted assets.

See [PLAN.md](PLAN.md) for the implementation sequence and
[PROGRESS.md](PROGRESS.md) for evidence and per-step checkpoints.

Original inputs remain at the repository root and are described in
[docs/inputs.md](docs/inputs.md). Verify them with:

```sh
python3 tools/verify_inputs.py
```

`src/` holds reconstructed code, `assets/` holds extracted assets, `tools/` holds
automation, and `docs/` holds investigation notes. Generated files and disposable
emulator media go under ignored `build/`. A source rebuild is not available yet.

Completed investigations include [reference boot and play sequences](docs/reference/README.md)
and a [lossless disk inventory and repacker](docs/disk-layout.md). The supplied
disk filenames are preserved, but disk 1 is the observed title/utility side and
disk 2 is the play side.

Runtime investigation now includes the [bootstrap and initialization trace](docs/bootstrap.md)
and a [Pascal segment/procedure inventory](docs/pascal-segments.md), including
segments on the play disk and native procedures embedded in Pascal libraries.
