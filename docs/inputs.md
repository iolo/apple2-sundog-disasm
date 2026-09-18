# Input baseline

`inputs.json` records the original sizes and SHA-256 hashes. Verify them with
`python3 tools/verify_inputs.py`. The build must never modify the originals.
Emulator sessions and exploratory output use disposable copies under `build/`.

The supplied second disk is named `sundog-disk2-util.dsk`. This is the canonical
input filename for this project; `sundog-disk2-game.dsk` in the original PRD was
a filename discrepancy. Step 02 established that disk 1 actually contains the
title/menu and utilities, while disk 2 is the play side. Filenames are preserved
for provenance; see [reference/README.md](reference/README.md) for the tested swap.

The original files were present in the workspace before implementation. No
download source or revision provenance has been established beyond these exact
file hashes. Filenames alone do not establish the release, filesystem, or sector
ordering. The PDF's scan quality and pagination will be checked in step 02.
