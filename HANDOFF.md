# Successor handoff — 2026-09-25

The user has asked to stop work and leave optional follow-ups to a successor.
The required goal is complete under the revised acceptance criteria. Do not
restart investigation or optional implementation without a new user request.

## Current state

- Final delivery checkpoint: `a33a4a1` (step 10b).
- User data exception: `edf3188` (step 08ac).
- Both disks rebuild exactly; no temporary reconstruction inputs remain.
- Coverage: 136,686 code bytes, 149,546 evidenced data bytes, and **488 bytes
  explicitly accepted by the user as unidentified data**. The latter are an
  assumption, not a proved code/data classification. Preserve their exact bytes.
- The goal tracker was marked complete. Steps 01–10 are complete; step 11 is
  optional. Some historical progress entries are out of chronological order
  and contain obsolete next actions. Use the current documents below.

Start with [delivery-checklist.md](docs/delivery-checklist.md),
[classification-ledger.md](docs/classification-ledger.md), and
[user-assumed-data.md](docs/user-assumed-data.md). Source and asset navigation
are in [src/README.md](src/README.md) and [assets/README.md](assets/README.md).

## Validation already completed

- 180 regression tests pass. The complete ledger integrates 166 components and
  checks 404 proof files.
- Two isolated strict builds without original disks, the manual or prior build
  products produce identical images and reports. The complete ledger also
  passes in that isolated tree.
- Final review replayed 15 data audits and 17 asset/script verifiers. Eight
  freshly extracted asset groups reproduce 53 delivered files exactly.
- Step **09a**, `3d5f194`: [MAME save/fresh reload](docs/save-reload-validation.md).
- Step **09b**, `5a40133`: [Apple2TS gameplay, swaps, utilities and save/fresh
  reload](docs/apple2ts-behavior-validation.md).
- Final output bytes equal those exercised by these emulator baselines. No
  fresh final emulator run was claimed. Combat, travel, all utility mutations,
  audio fidelity and synchronized timing were not exhaustively tested.

If verification is needed for new work, the entry points are:

```sh
python3 tools/build_disks.py --no-temporary
python3 tools/verify_disks.py
python3 tools/classification_ledger.py --require-complete
python3 -m unittest discover -s tools
```

Full audits require Python 3.10+ and ca65/ld65 on PATH. Build outputs are under
`build/disks/`. Disk 1 is the title/utility/save side; disk 2 is the play side.
Use disposable media copies for emulator work. Receipts and exact hashes are
linked from the delivery checklist; do not rely on ephemeral `/tmp` files.

## Optional directions discussed, not commissioned

1. Extract and document a reusable Apple Pascal p-code toolkit. The decoder is
   `tools/pcode_source.py`; assembler support is `src/pcode/encoding.inc` using
   ca65 macros. Supported dialects are limited, and repository dependencies
   need separation. No new portable p-code interpreter was implemented: the
   interpreter artifact is reconstructed original 6502 runtime source.
2. Consolidate navigation and distinguish reusable tools from one-off research
   scripts. Keep historical evidence, but make current usage easy to find.
3. Add a concise architecture guide and an understandable end-to-end game
   modification, with meaningful names and relevant validation.
4. Extend behavioral tests where a future change needs them. This is optional
   coverage expansion, not an unfulfilled claim about the completed baseline.

The 488-byte investigation consumed disproportionate time and tokens. Its
history is in [unresolved-tails.md](docs/unresolved-tails.md). The user explicitly
ended that required research. Do not repeat exhausted searches. For any future
uncertain investigation, agree a bounded scope, use a time/attempt limit, and
surface diminishing returns before spending substantially more resources.

## Preserve user work and checkpoint discipline

At handoff, `PRD.md` has two pre-existing unstaged reference links, and `ref/`
is user-owned and untracked. Both were deliberately preserved and excluded
from our commits. Do not clean, overwrite or stage them incidentally.
The original DSKs and `sundog.pdf` are unchanged validation references.

For any newly authorized work: validate the step, update `PROGRESS.md`, and
commit that checkpoint before starting the next step. No new work is running
as part of this handoff.
