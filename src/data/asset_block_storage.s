; Classified data storage: docs/asset-block-storage.md
.segment "ASSET_STORAGE"
full_ship_zero_storage:
    .res 361, 0
.assert * - full_ship_zero_storage = 361, error, "Storage extent"
save_descriptors_zero_storage:
    .res 256, 0
.assert * - save_descriptors_zero_storage = 256, error, "Storage extent"
