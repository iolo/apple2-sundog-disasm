; Evidence: docs/encoded-native-overlay-tail.md
.setcpu "6502"
.segment "RAW_NATIVE"
.org $11F8
component_start:
; Stored bank offset $07F8; original +$05F8
; track-sequence-index
    .byte $00
; Stored bank offset $07F9; original +$05F9
; read-mode
    .byte $00
; Stored bank offset $07FA; original +$05FA
; wipe-start-address
    .byte $00,$00
; Stored bank offset $07FC; original +$05FC
    lda a:$C083
; Stored bank offset $07FF; original +$05FF
; lda a:$C083: only opcode survives; operands $83,$C0 lie beyond the copied extent.
    .byte $AD ; LDA absolute opcode fragment
.assert * - component_start = 8, error, "Tail slice size"
