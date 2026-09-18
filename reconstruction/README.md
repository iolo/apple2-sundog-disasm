# Incremental reconstruction inputs

`manifest.json` accounts for every output byte of both disk images. It combines
assembled source components with the explicitly **temporary, unresolved** bytes
in `temporary/`. These binary files include executable code awaiting disassembly;
they are not extracted assets or accepted final preservation data.

Build with `python3 tools/build_disks.py`. The normal build reads this directory
and `src/`; it never invokes extraction or reads the original `.dsk` files.

The initial remainder files were generated once with:

```sh
python3 tools/seed_reconstruction.py reconstruction
```

That command refuses an existing destination. It is an archival extraction tool,
not a build prerequisite. Do not rerun it over an evolving reconstruction.

For disk 1, the remainder concatenates the gaps between the source-built ranges
in image order. Disk 2 is entirely temporary at this checkpoint. Each manifest
region names its output offset, size, input component, and offset within that
component. Component hashes catch changed or damaged inputs; complete-coverage
checks reject gaps, overlaps, and out-of-bounds slices.

Replace these temporary ranges incrementally during steps 06 and 07. The final
step-08 build cannot be declared complete while either temporary component
remains. See `docs/reconstruction.md` for the current coverage and verification.
