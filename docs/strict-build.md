# Strict build inputs and reproducibility

**Current scope (step 08ac):** no temporary inputs remain. The strict command
accepts the user's [488-byte data exception](user-assumed-data.md), separately
reported as `user-assumed-data`. Hashes and every mapped occurrence must match
the acceptance receipt. This is not an evidence-backed classification. The
older refusal results below are historical checkpoints.

The incremental build deliberately accepts `temporary-unresolved` inputs while
reconstruction is underway. Exact output does not classify those bytes. A strict
build now makes that distinction enforceable:

```sh
python3 tools/build_disks.py --no-temporary
```

At step 08w this command **exits 1 before creating or changing build outputs**.
It reports two temporary components containing 584 mapped disk bytes: 103 on
disk 1 and 481 on disk 2. The manifest's descriptive status cannot override the
check. Unused or zero-length temporary declarations are also rejected and must
be removed when their reconstruction is complete.

The ordinary command remains available for incremental work:

```sh
python3 tools/build_disks.py
python3 tools/verify_disks.py
```

Each build report now includes `temporary_inputs`, `has_temporary_inputs` and
`no_temporary_required`. For every temporary component, the report distinguishes
input size from mapped disk size, so duplicated copies cannot understate disk
coverage. Identified-data components must reference an existing classification
document within the project, in addition to their existing format and byte-hash
requirements. Include `docs/` when preparing a standalone build tree.

**Scope:** absence of temporary inputs is a necessary final-build requirement,
not a complete code/data proof. Renaming a blob to an asset or source component
does not satisfy the PRD. Classification evidence, disassembled instructions,
asset extraction, behavior, clean reproduction and delivery documentation still
require their own review. The strict check does not produce a "goal complete"
status or infer that all source-built bytes are instructions.

## Isolated rebuild, 2026-09-25

At step 08w, an empty temporary directory received only `tools/`, `src/`, `assets/`,
`reconstruction/` and `docs/`. The two original disk files, manual and previous
`build/` directory were absent. The strict command failed before creating its
requested output directory. Two ordinary builds into distinct empty output
directories then produced byte-identical disks and identical build reports.
Those disks also match the current workspace outputs, which passed the normal
comparison against the original images. Temporary source inputs were included
explicitly; this was an incremental reproducibility check.

| Output | Size | SHA-256 |
| --- | ---: | --- |
| `sundog-disk1-game.dsk` | 143360 | `79226c9a2d8df006097c9c69a7de46019a610c5486dc52e07616d39381eba082` |
| `sundog-disk2-util.dsk` | 143360 | `52676db37d9eb93aed9a16b44b705f630522db6e160ad51d5d2c2fd9ac691e7d` |

`docs/reference/step08w-build-validation.json` records the build report, strict
check result, copied directories and tool versions. The temporary tree was
removed after comparison. No original input, user reference file, or emulator
state was changed. A final isolated strict build remains required after the
unclassified remainders are resolved.

Step 10a repeats that experiment at the current **488-byte** checkpoint. Two
new builds without original images, the manual or prior build products again
match each other and both originals exactly; their build reports also match.
The strict command exits 1 before creating its requested output directory.
[step10a-build-validation.json](reference/step10a-build-validation.json) records
the current manifest hash, versions, build report and strict refusal. This
supersedes the older receipt for current ownership counts, while retaining its
historical result. It is still an incremental check, not the final strict build.

## Regression checks

```sh
python3 tools/test_reconstruction.py
python3 tools/test_adopt_component.py
```

The reconstruction tests cover duplicated temporary mappings, rejection despite
a misleading complete status, an unmapped zero-length temporary component,
preservation of existing outputs on refusal, missing classification evidence,
successful strict building of classified fixture data and continued incremental
building of explicit temporary fixture data. Existing coverage, path-boundary
and image-difference checks remain in place.
