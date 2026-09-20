; Evidence: docs/encoded-native-overlay-tail.md
.setcpu "6502"
.segment "RAW_NATIVE"
.org $1627
component_start:
; Stored bank offset $0627
; native-alignment
    .byte $00
; Stored bank offset $0628
; native-relocation-count-interpreter
    .word $0000
; Stored bank offset $062A
; native-relocation-count-procedure
    .word $0000
; Stored bank offset $062C
; native-relocation-count-segment
    .word $0000
; Stored bank offset $062E
; native-relocation-count-global
    .word $0000
; Stored bank offset $0630
; native-entry-displacement
    .word $0630
; Stored bank offset $0632
; native-attributes
    .byte $00,$00
; Stored bank offset $0634
; procedure-dictionary-pointer
    .word $0002
; Stored bank offset $0636
; segment-trailer
    .byte $01,$01
.assert * - component_start = 17, error, "Tail slice size"
