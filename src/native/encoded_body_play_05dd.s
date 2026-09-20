; Evidence: docs/encoded-native-overlay-body.md
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
L_0000:
; jump-vector — Read by reviewed JMP indirect; stored target $0E2E. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $2E,$0E
L_0002:
; jump-vector — Read by reviewed JMP indirect; stored target $0ECA. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $CA,$0E
L_0004:
; jump-vector — Read by reviewed JMP indirect; stored target $0ECE. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $CE,$0E
.assert * - component_start = 6, error, "Raw component size"
