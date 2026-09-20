; Evidence: docs/encoded-native-overlay-body.md
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
L_0000:
; jump-vector — Read by reviewed JMP indirect; stored target $15AB. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $AB,$15
L_0002:
; obfuscation-delimiter — $AD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $AD
.assert * - component_start = 3, error, "Raw component size"
