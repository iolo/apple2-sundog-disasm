# Progress log

Every implementation step must update this file and commit its changes together
with the log update before the next step begins. See `PLAN.md` for the full rule
and acceptance criteria.

## 2026-09-18 — Planning checkpoint

- **Status:** Plan prepared; implementation has not started; commit blocked.
- **Work:** Read `PRD.md`, checked the available inputs and repository state, and
  created `PLAN.md` with ten required steps and one optional documentation step.
- **Validation:** File listing confirms both disk images and `sundog.pdf` exist.
  Both disks are 143,360 bytes. No repository `AGENTS.md` was found in the checked
  locations. `git status --short` fails with `not a git repository`; `.git` is
  empty and read-only in this workspace.
- **Discrepancy:** The actual second input is `sundog-disk2-util.dsk`; the PRD
  lists `sundog-disk2-game.dsk`. Its role is not yet verified.
- **Artifacts:** `PLAN.md`, `PROGRESS.md`.
- **Blocker:** A usable, writable Git checkout is required before this planning
  checkpoint can be committed or the per-step commit workflow can begin.
- **Next action:** When implementation is requested, resolve step 01's Git
  prerequisite, commit this checkpoint, and establish input hashes and structure.

## 2026-09-18 — Planning checkpoint committed

- **Status:** Git prerequisite resolved; implementation authorized by the user.
- **Evidence:** `.git` is now writable and `git status --short` succeeds. The
  inspected `main` branch has no commits yet, so this checkpoint establishes the
  initial commit, including the original inputs and planning documents.
- **Next action:** Step 01: create and verify the input manifest and project layout.

## 2026-09-18 — Step 01: input baseline and layout

- **Status:** Complete.
- **Work:** Recorded all three original inputs in `inputs.json`, added
  `tools/verify_inputs.py`, established `src/`, `assets/`, `docs/`, and ignored
  generated `build/` output. Corrected the second filename in `PRD.md` and
  documented that its actual behavior remains unverified.
- **Validation:** `python3 tools/verify_inputs.py` passes for both 143,360-byte
  disks and the 1,302,733-byte PDF. `git diff --check` passes. Git prerequisite
  proved by the successful planning commit `f116cc9`.
- **Next action:** Step 02: inventory tools, boot disposable disk copies, and
  establish manual-backed reference interactions.

## 2026-09-18 — Step 02a: tools, manual, and initial boots

- **Status:** Partial step 02 checkpoint; playable reference still in progress.
- **Work:** Inventoried tools in `docs/toolchain.md`, visually read manual pages
  7–10 into `docs/manual-notes.md`, and captured initial apple2ts screens under
  `docs/reference/` using disposable media copies.
- **Evidence:** Private apple2ts boots the game disk to a Version 2.0 title with
  a NUTCRACKER credit. A separate fresh utility-disk session reaches Flip Disk.
  MAME 0.285 runs with local verified Apple IIe ROMs and scripted joystick input.
  Neither disk catalogs with a2kit 4.4.2 (`FileSystemMismatch`).
- **Validation:** MAME's `-verifyroms apple2e` succeeds with the documented local
  ROM path. `python3 tools/verify_inputs.py` verifies originals. Exploratory
  MAME sessions changed their disposable game copy, showing that every reference
  run must begin with fresh copies rather than reuse a prior session's media.
- **Remaining:** Establish repeatable play and utility sequences, isolate each
  run's media/configuration, and verify observed disk swaps before completing 02.
- **Next action:** Implement and run the isolated MAME reference harness.
