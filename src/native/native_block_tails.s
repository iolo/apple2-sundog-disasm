; Evidence: docs/native-block-tails.md
.setcpu "6502"
.segment "NATIVE_TAILS"

raw_screen_init_tail:
; Bank +$0129: native-alignment
    .byte $00
; Bank +$012A: native-relocation-count-interpreter
    .word $0000
; Bank +$012C: native-relocation-count-procedure
    .word $0000
; Bank +$012E: native-relocation-count-segment
    .word $0000
; Bank +$0130: native-relocation-count-global
    .word $0000
; Bank +$0132: native-entry-displacement
    .word $0132
; Bank +$0134: native-attributes
    .byte $00,$00
; Bank +$0136: procedure-dictionary-pointer
    .word $0002
; Bank +$0138: segment-trailer
    .byte $01,$01
; Bank +$013A: zero-block-storage
    .res 198, 0
.assert * - raw_screen_init_tail = 215, error, "Native tail size"

raw_buffer_transform_tail:
; Bank +$005D: unused-indirect-transfer
; Pointer $04/$05 is the restored transformed-buffer start; preceding RTS bypasses this retained instruction.
    jmp ($0004)
; Bank +$0060: native-relocation-count-interpreter
    .word $0000
; Bank +$0062: native-relocation-count-procedure
    .word $0000
; Bank +$0064: native-relocation-count-segment
    .word $0000
; Bank +$0066: native-relocation-count-global
    .word $0000
; Bank +$0068: native-entry-displacement
    .word $0068
; Bank +$006A: native-attributes
    .byte $00,$00
; Bank +$006C: procedure-dictionary-pointer
    .word $0002
; Bank +$006E: segment-trailer
    .byte $01,$01
; Bank +$0070: zero-block-storage
    .res 400, 0
.assert * - raw_buffer_transform_tail = 419, error, "Native tail size"
