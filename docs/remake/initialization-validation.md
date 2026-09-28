# Initialization validation — R04d

Run date: 2026-09-28 (Asia/Seoul). Required Chrome:
`/opt/google/chrome/google-chrome`, version 154.0.8037.57.
All 46 browser tests pass, including six new initialization groups. See
[machine-readable receipt](initialization-validation.json).

- The source-extracted native RNG loop runs through cc65/sim65. Seven explicit
  seeds and 16 draws each give 112 matching values and resulting states.
- A constructed compatible draw tape reproduces the six equipment records in
  the independent clean-character capture. Tests compare all unit components,
  spares, performances and special requirements. This is not a recovered seed.
- Exhaustive socket/parity cases verify missing/broken/shunt outcomes, eager
  Pascal draw consumption, protected spares and totals. Copies stay independent.
- System tests cover starting/other bank ranges, fixed Woremed coordinates,
  rejected candidates becoming the next baseline, input isolation and alternate
  starting-system selection. Orbit tests cover the exact 15/16 boundary, linear
  distance, explicit first comparison and bounded nonconvergence.
- For 1,000 seeds, duplicate runs produce identical equipment, coordinates,
  balances, angles and final RNG states. Each satisfies source bounds and spacing.
  Invalid seeds, random results and initialization boundaries are rejected.

Seven Python exporter tests pass. Static system/planet names, membership and
orbital radii match the clean-character capture; saved balances and orbital angles
are absent from the exported baseline. All 120 deterministic browser artifacts,
584 classified strings and original disk/manual hashes verify.

These primitives are not yet used by the live walkthrough or character editor.
Existing browser tests also pass; unrelated interactive smoke suites were not
rerun. No UI change, complete campaign initialization, full Apple II replay,
original startup seed recovery or new emulator play observation is claimed.

Reproduce:

```sh
python3 tools/remake/random_reference.py
python3 tools/remake/initialization_reference.py
python3 tools/remake/test_exports.py
python3 tools/remake/export_assets.py --check
python3 tools/remake/source_index.py --check
python3 tools/verify_inputs.py
```

Serve `remake/` and open `/tests/` with the configured Chrome to run all 46 browser
tests. The native helper requires `cl65` and `sim65`; its temporary compiled files
are removed automatically. No original disk writes are performed.
