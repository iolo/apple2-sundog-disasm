; Evidence: docs/encoded-native-overlay-body.md
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
L_0000:
; jump-vector — Read by reviewed JMP indirect; stored target $11D5. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $D5,$11
L_0002:
; retry-counter — STA at $02EB initializes this counter; DEC at $04CE consumes it.
    .byte $00
L_0003:
; disk-symbol-table — CMP indexed at $0575 searches this table with Y initialized to seven at $0410 and decremented through zero.
    .byte $AF,$AB,$D5,$EA,$F5,$FA,$FD,$FE
.assert * - component_start = 11, error, "Raw component size"
