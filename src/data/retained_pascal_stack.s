; Retained stack data: docs/retained-pascal-stack.md
.segment "RETAINED_STACK"
snapshot:
stack_0014:
; Original memory $EDFA: clipped-string-node
    .word $EDFE
    .byte 1 ; '/'
    .byte $2F
stack_0018:
; Original memory $EDFE: copied-string-node
    .word $4649
    .word $EE04
    .byte 1 ; '/'
    .byte $2F
stack_001e:
; Original memory $EE04: copied-string-node
    .word $45E9
    .word $EE0A
    .byte 1 ; '.'
    .byte $2E
stack_0024:
; Original memory $EE0A: copied-string-node
    .word $4567
    .word $EE48
    .byte 56 ; '7CONSOLE1:7SYSTERM2:7GRAPHIC3:7PRINTER6:5REMIN7:6REMOUT8'
    .byte $37,$43,$4F,$4E,$53,$4F,$4C,$45,$31,$3A,$37,$53,$59,$53,$54,$45
    .byte $52,$4D,$32,$3A,$37,$47,$52,$41,$50,$48,$49,$43,$33,$3A,$37,$50
    .byte $52,$49,$4E,$54,$45,$52,$36,$3A,$35,$52,$45,$4D,$49,$4E,$37,$3A
    .byte $36,$52,$45,$4D,$4F,$55,$54,$38,$EF
stack_0062:
; Original memory $EE48: copied-string-node
    .word $450F
    .word $0000
    .byte 1 ; '/'
    .byte $2F
stack_0068:
; Original memory $EE4E: call-frame-with-128k-prefix
    .word $0000,$EFB2,$F5EE,$EFB6,$4BE6,$59E8,$4B0B
    .byte $F9,$83
stack_0078:
; Original memory $EE5E: activation-local-storage
; Parameter/local storage within frame $EE52.
    .byte $C6,$EF,$10,$00,$00,$00,$68,$EE,$19,$00,$02,$00,$01,$00,$0D,$00
    .byte $50,$00,$74,$EE,$02,$2E,$50,$45,$B2,$EE,$38,$37,$43,$4F,$4E,$53
    .byte $4F,$4C,$45,$31,$38,$37,$43,$4F,$4E,$53,$4F,$4C,$45,$31,$3A,$37
    .byte $53,$59,$53,$54,$45,$52,$4D,$32,$3A,$37,$47,$52,$41,$50,$48,$49
    .byte $43,$33,$3A,$37,$50,$52,$49,$4E,$54,$45,$52,$36,$3A,$35,$52,$45
    .byte $4D,$49,$4E,$37,$3A,$36,$52,$45,$4D,$4F,$55,$54,$38,$F0,$01,$50
    .byte $20,$F0,$9A,$49,$E8,$59,$90,$49,$F9,$83,$4C,$F0,$10,$00,$00,$00
    .byte $01,$3A,$19,$00,$02,$00,$01,$00,$0D,$00,$50,$00,$2F,$00,$02,$2E
    .byte $50,$EF,$3E,$EF,$0D,$00,$02,$00,$3A,$00,$01,$3A,$02,$00,$38,$37
    .byte $43,$4F,$4E,$53,$4F,$4C,$45,$31,$3A,$37,$53,$59,$53,$54,$45,$52
    .byte $4D,$32,$3A,$37,$47,$52,$41,$50,$48,$49,$43,$33,$3A,$37,$50,$52
    .byte $0D,$50,$3A,$4E,$45,$57,$43,$2F,$43,$2E,$43,$4F,$44,$45,$3A,$36
    .byte $52,$45,$4D,$4F,$55,$54,$38,$EF,$01,$50
stack_0142:
; Original memory $EF28: copied-string-node
    .word $6253
    .word $EF2E
    .byte 1 ; ':'
    .byte $3A
stack_0148:
; Original memory $EF2E: copied-string-node
    .word $623D
    .word $EF34
    .byte 1 ; '/'
    .byte $2F
stack_014e:
; Original memory $EF34: copied-string-node
    .word $6223
    .word $EF3A
    .byte 0 ; ''
    .byte $00
stack_0154:
; Original memory $EF3A: copied-string-node
    .word $61C7
    .word $EF40
    .byte 1 ; ':'
    .byte $3A
stack_015a:
; Original memory $EF40: copied-string-node
    .word $6125
    .word $EF46
    .byte 1 ; ':'
    .byte $3A
stack_0160:
; Original memory $EF46: copied-string-node
    .word $60FB
    .word $EF4C
    .byte 1 ; '!'
    .byte $21
stack_0166:
; Original memory $EF4C: copied-string-node
    .word $6049
    .word $EF52
    .byte 1 ; '['
    .byte $5B
stack_016c:
; Original memory $EF52: copied-string-node
    .word $602F
    .word $EF58
    .byte 0 ; ''
    .byte $00
stack_0172:
; Original memory $EF58: copied-string-node
    .word $6029
    .word $0000
    .byte 0 ; ''
    .byte $00
stack_0178:
; Original memory $EF5E: activation-local-storage
; Parameter/local storage within frame $EE52.
    .byte $00,$00,$01,$00,$10,$F8,$32,$F0,$E2,$20,$AC,$34,$90,$1E,$F7,$83
    .byte $01,$00,$00,$00,$B4,$F4,$B6,$F4,$6A,$F3,$0D,$50,$3A,$4E,$45,$57
    .byte $43,$2F,$43,$2E,$43,$4F,$44,$45,$44,$45,$44,$45,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
stack_01b4:
; Original memory $EF9A: call-frame-with-128k-prefix
    .word $EFAC,$EFAC,$F5EE,$EFB6,$4BE6,$59E8,$4BD9
    .byte $F9,$83
stack_01c4:
; Original memory $EFAA: activation-local-storage
; Parameter/local storage within frame $EF9E.
    .byte $00,$00
stack_01c6:
; Original memory $EFAC: copied-string-node
    .word $4B1F
    .word $0000
    .byte 0 ; ''
    .byte $00
stack_01cc:
; Original memory $EFB2: call-frame-with-128k-prefix
    .word $0000,$F02E,$F5EE,$F032,$20E2,$34AC,$1F6B
    .byte $F9,$83
stack_01dc:
; Original memory $EFC2: activation-local-storage
; Parameter/local storage within frame $EFB6.
    .byte $A6,$F2,$C6,$F2,$0E,$2F,$50,$2F,$4E,$45,$57,$43,$2F,$43,$2E,$43
    .byte $4F,$44,$45,$00,$00,$00,$00,$00,$00,$00,$05,$2E,$43,$4F,$44,$45
    .byte $00,$00,$00,$00
.assert * - snapshot = 492, error, "Retained stack extent"
