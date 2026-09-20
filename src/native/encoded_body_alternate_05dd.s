; Evidence: docs/encoded-native-overlay-body.md
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
L_0000:
; jump-vector — Read by reviewed JMP indirect; stored target $122E. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $2E,$12
L_0002:
; jump-vector — Read by reviewed JMP indirect; stored target $12CA. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $CA,$12
L_0004:
; jump-vector — Read by reviewed JMP indirect; stored target $12CE. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $CE,$12
.assert * - component_start = 6, error, "Raw component size"
