# Component exchange validation — R05f

2026-09-29: required `/opt/google/chrome/google-chrome` 154.0.8037.57 passes
72 browser rule/localization/storage groups, 37 exchange UI checks, 89 engineering
regressions, 45 campaign-flow checks and 14 recovery/storage checks. See the
[machine-readable receipt](component-exchange-validation.json).

New rule checks cover multi-shunt penalties, the control-node restriction,
inoperative units, special-component availability, source-captured ratings,
owned recalculation, component conservation and two-way fit rejection. All249
candidate bytes from7–255 are exercised against each of24 group/socket combinations.
Encoded carried items remain unchanged on invalid installation; pocket-to-pocket
exchange preserves a charged shield byte. Remote access, the former "spares" pseudo
container and invalid slot references are rejected.

Save checks roundtrip changed equipment independently of creation data, reject
false performance/availability and changed metadata, and upgrade validated legacy
records. An actual version1 record is placed in an isolated IndexedDB slot; its
upgrade succeeds with the original raw comparison value, while a stale writer
fails afterward. Invalid legacy data cannot bypass validation by requesting
migration. Existing creation, storage and seed tests remain green.

The browser exchange flow creates seed12345 and walks to warp engineering using
normal pointer input. It removes a working flux modulator (output14→10), rejects
installation in the control socket, exchanges it with a shunt (10→11), then installs
the recovered shunt into the donor unit (11→14). The exported component multiset is
conserved and the immutable creation record is identical. Changed unit contents
survive an explicit save, page reload and load.

Move hands keyboard focus to Cancel; Escape restores focus to Move and cancels
without removing an item. Frame changes also cancel pending moves. Locale/resize
preserves a pending move. English and Korean fit without footer overlap at 640×480,
1280×720, 1920×1080 and 390×844. Invalid performance imports preserve live equipment;
legacy and current JSON imports both work. No uncaught browser errors were observed.
Screenshots are in ignored `output/playwright/remake/`, with hashes in the receipt.

The CLI sandbox lacks Node Buffer and structuredClone; the harness uses JSON copies
and downloads fixture Blobs before ordinary file-input imports. These fixtures do
not write application state directly. Two initial harness failures were corrected
before the successful run. This does not constitute original-emulator evidence.

Eleven exporter tests, 122 generated artifacts, 584 classified strings, six captured
equipment records and original disk/manual hashes verify. Power/charging, encoded
damage repair and live original timing are outside the supported scope.

## Reproduce

Serve `remake/` at localhost:8000 using the configured Chrome executable from
`tools/remake/chrome.config.json`. Open `/tests/`, then use Playwright CLI `run-code`
with `tools/remake/equipment_exchange_smoke.js` and `equipment_smoke.js`.
Run campaign regressions in this order:

1. `tools/remake/campaign_smoke.js`.
2. `python3 tools/remake/campaign_edge_fixtures.py`.
3. `tools/remake/campaign_edge_smoke.js`.

Integrity commands:

```sh
python3 tools/remake/test_exports.py
python3 tools/remake/export_assets.py --check
python3 tools/remake/source_index.py --check
python3 tools/remake/initialization_reference.py
python3 tools/verify_inputs.py
```
