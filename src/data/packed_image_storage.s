; Retained compression data and bounded storage; inferred from image format
; and independently established allocations. See docs/packed-image-storage.md.
; Neither native decoder consumes these records. They are not terminators.
.segment "PACKED_IMAGE_STORAGE"
ship_section_retained_zero_run:
    .byte $01, $00       ; Repeat-zero record: format count 2, unused by decoder.
ship_section_zero_storage:
    .res 486, 0
.assert * - ship_section_retained_zero_run = 488, error, "Ship storage extent"
flip_disk_retained_zero_run:
    .byte $78, $00       ; Repeat-zero record: format count 121, unused by decoder.
flip_disk_zero_storage:
    .res 190, 0
.assert * - flip_disk_retained_zero_run = 192, error, "Boot image storage extent"
