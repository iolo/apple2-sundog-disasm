; Evidence: docs/encoded-native-overlay-tail.md
.setcpu "6502"
.segment "RAW_NATIVE"
.org $11DD
component_start:
; Stored bank offset $07DD; original +$05DD
; jump-vector
    .byte $2E,$0E
; Stored bank offset $07DF; original +$05DF
; jump-vector
    .byte $CA,$0E
; Stored bank offset $07E1; original +$05E1
; jump-vector
    .byte $CE,$0E
.assert * - component_start = 6, error, "Tail slice size"
