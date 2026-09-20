; Disk-1 block 83, offsets 0..7: directly consumed control data.
; Field evidence: docs/disk-control.md. The remaining 504 bytes are separate.
.segment "DISK_CONTROL"
disk_control:
mode_flag:
    .byte $00
save_slot:
    .byte $01
persisted_globals_21_22:
    .word $9C1B, $A614
screen_initializer_block:
    .byte 2
directory_destination_block:
    .byte 79
.assert * - disk_control = 8, error, "Control record size changed"
