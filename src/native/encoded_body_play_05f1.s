; Evidence: docs/encoded-native-overlay-body.md
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
L_0000:
; disk-read-buffer — STA indexed at $0596 writes read bytes with Y=5 or Y=2; absolute reads consume $05F1..$05F5.
    .byte $00,$00,$00,$00,$00
.assert * - component_start = 5, error, "Raw component size"
