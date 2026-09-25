# Input baseline

`inputs.json` records the original sizes and SHA-256 hashes. Verify them with
`python3 tools/verify_inputs.py`. The build must never modify the originals.
Emulator sessions and exploratory output use disposable copies under `build/`.

The supplied second disk is named `sundog-disk2-util.dsk`. This is the canonical
input filename for this project; `sundog-disk2-game.dsk` in the original PRD was
a filename discrepancy. Step 02 established that disk 1 actually contains the
title/menu and utilities, while disk 2 is the play side. Filenames are preserved
for provenance; see [reference/README.md](reference/README.md) for the tested swap.

The original files were present in the workspace before implementation. Step
08ab confirms exact byte matches with `SUNDOG1.DSK` and `SUNDOG2.DSK` in the
archive's [version-2 disk-1 ZIP](https://mirrors.apple2.org.za/ftp.apple.asimov.net/images/games/rpg/sundog_version_2/sundog_ver2_disk1.zip)
and [disk-2 ZIP](https://mirrors.apple2.org.za/ftp.apple.asimov.net/images/games/rpg/sundog_version_2/sundog_ver2_disk2.zip).
[sundog-version-comparison.json](reference/sundog-version-comparison.json)
records archive/member hashes and byte comparisons. This identifies matching
archived copies, not the user's download route or an untouched commercial master.
Filenames alone do not establish release, filesystem or sector ordering.
