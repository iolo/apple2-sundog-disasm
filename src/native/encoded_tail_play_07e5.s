; Evidence: docs/encoded-native-overlay-tail.md
.setcpu "6502"
.segment "RAW_NATIVE"
.org $11E5
component_start:
; Stored bank offset $07E5; original +$05E5
; jump-vector
    .byte $D5,$11
; Stored bank offset $07E7; original +$05E7
; retry-counter
    .byte $00
; Stored bank offset $07E8; original +$05E8
; disk-symbol-table
    .byte $AF,$AB,$D5,$EA,$F5,$FA,$FD,$FE
.assert * - component_start = 11, error, "Tail slice size"
