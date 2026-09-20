; Retained stack data: docs/retained-command-stack.md
.segment "COMMAND_STACK"
snapshot:
stack_0148:
; Memory $B6D4: clipped-call-frame
    .word $B6EE,$FD26,$FDFA,$FD1C
    .byte $EF,$FC
stack_0152:
; Memory $B6DE: interframe-activation-storage
; Activation storage; bounds and owner recorded in the audit.
    .byte $00,$00,$00,$00,$BD,$B8,$7E,$08,$7E,$08,$7E,$08
stack_015e:
; Memory $B6EA: call-frame-with-128k-prefix
    .word $0000,$B700,$B7CA,$B704,$BD1A,$FDFA,$BD10
    .byte $F1,$00
stack_016e:
; Memory $B6FA: activation-local-storage
; Activation storage; bounds and owner recorded in the audit.
    .byte $00,$00,$BC,$B8,$7E,$08
stack_0174:
; Memory $B700: call-frame-with-128k-prefix
    .word $0000,$B716,$B7CA,$B71A,$B6AE,$FDFA,$B698
    .byte $F3,$B6
stack_0184:
; Memory $B710: activation-local-storage
; Activation storage; bounds and owner recorded in the audit.
    .byte $0B,$00,$02,$42,$3A,$BD
stack_018a:
; Memory $B716: call-frame-with-128k-prefix
    .word $B72A,$B72A,$B7CA,$B776,$A1CA,$A202,$A004
    .byte $F5,$00
stack_019a:
; Memory $B726: activation-local-storage
; Activation storage; bounds and owner recorded in the audit.
    .byte $1E,$BD,$5C,$BD
stack_019e:
; Memory $B72A: copied-string-node
    .word $9FAF,$0000
    .byte 67 ; 'Command: E(dit, R(un, F(ile, C(omp, L(ink, X(ecute, A(ssem, ? [1.2]'
    .byte $43,$6F,$6D,$6D,$61,$6E,$64,$3A,$20,$45,$28,$64,$69,$74,$2C,$20
    .byte $52,$28,$75,$6E,$2C,$20,$46,$28,$69,$6C,$65,$2C,$20,$43,$28,$6F
    .byte $6D,$70,$2C,$20,$4C,$28,$69,$6E,$6B,$2C,$20,$58,$28,$65,$63,$75
    .byte $74,$65,$2C,$20,$41,$28,$73,$73,$65,$6D,$2C,$20,$3F,$20,$5B,$31
    .byte $2E,$32,$5D
stack_01e6:
; Memory $B772: call-frame-with-128k-prefix
    .word $B78E,$B78E,$B7CA,$B798,$BFC0,$FDFA,$BEDF
    .byte $F7,$B7
stack_01f6:
; Memory $B782: activation-local-storage
; Activation storage; bounds and owner recorded in the audit.
    .byte $05,$00,$00,$00,$04,$00,$43,$00,$FE,$FF
.assert * - snapshot = 184, error, "Command stack extent"
