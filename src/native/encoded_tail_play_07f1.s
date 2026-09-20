; Evidence: docs/encoded-native-overlay-tail.md
.setcpu "6502"
.segment "RAW_NATIVE"
.org $11F1
component_start:
; Stored bank offset $07F1; original +$05F1
; disk-read-buffer
    .byte $00,$00,$00,$00,$00
.assert * - component_start = 5, error, "Tail slice size"
