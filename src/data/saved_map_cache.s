; Retained map-cache data in the Blackblade save; docs/saved-map-cache.md.
.segment "SAVED_MAP_CACHE"
retained_world_map_last_row_columns_8_to_39:
    .res 32, $0C
retained_cleared_map_cache_gap:
    .res 40, 0
retained_cached_world_identifier:
    .byte 1
retained_cleared_map_cache_suffix:
    .res 23, 0
.assert * - retained_world_map_last_row_columns_8_to_39 = 96, error, "Saved map cache extent"
