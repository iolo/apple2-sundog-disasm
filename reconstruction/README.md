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

For each disk, the remainder concatenates the gaps between source-built ranges
in image order. Both disks now contain reconstructed Pascal modules. Each manifest
region names its output offset, size, input component, and offset within that
component. Component hashes catch changed or damaged inputs; complete-coverage
checks reject gaps, overlaps, and out-of-bounds slices.

Replace these temporary ranges incrementally during steps 06 and 07. The final
step-08 build cannot be declared complete while either temporary component
remains. Every final region must have an evidence-backed code/data classification;
unknown data semantics are acceptable, unidentified or mixed chunks are not.
Exact output is preferred; any differences require explanation and validation. See `docs/reconstruction.md` for the current coverage and verification.

To adopt a newly reconstructed component, first build the current baseline, then
run `python3 tools/adopt_component.py path/to/recipe.json`. A recipe identifies
the ca65 source/config and byte mappings; `src/native/pcode_primitives.adopt.json`
is an example spanning two bank regions. The tool assembles the source, checks
the baseline images and every replacement byte, rejects overlapping or already
reconstructed ranges, and repacks the affected temporary remainder before
updating the manifest. It does not read the originals. Adoption is a one-time
maintenance operation; do not rerun an already adopted recipe as a build step.
