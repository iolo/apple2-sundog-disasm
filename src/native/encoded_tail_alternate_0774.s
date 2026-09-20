; Evidence: docs/encoded-native-overlay-tail.md
.setcpu "6502"
.segment "RAW_NATIVE"
.org $1574
component_start:
; Stored bank offset $0774; original +$0574
; obfuscation-delimiter
    .byte $AD
; Stored bank offset $0775; original +$0575
    cmp a:$15E8,y
; Stored bank offset $0778; original +$0578
    beq $1580
; Stored bank offset $077A; original +$057A
    dey
; Stored bank offset $077B; original +$057B
    bpl $1575
; Stored bank offset $077D; original +$057D
    lda #$04
; Stored bank offset $077F; original +$057F
    rts
; Stored bank offset $0780; original +$0580
    jmp ($12AC)
; Stored bank offset $0783; original +$0583
; jump-vector
    .byte $DC,$10
; Stored bank offset $0785; original +$0585
; obfuscation-delimiter
    .byte $E6
; Stored bank offset $0786; original +$0586
    lda a:$C08C,x
; Stored bank offset $0789; original +$0589
    bpl $1586
; Stored bank offset $078B; original +$058B
    jmp ($1203)
; Stored bank offset $078E; original +$058E
; jump-vector
    .byte $9B,$13
; Stored bank offset $0790; original +$0590
; obfuscation-delimiter
    .byte $D0
; Stored bank offset $0791; original +$0591
    lda a:$C08C,x
; Stored bank offset $0794; original +$0594
    bpl $1591
; Stored bank offset $0796; original +$0596
    sta a:$15F0,y
; Stored bank offset $0799; original +$0599
    dey
; Stored bank offset $079A; original +$059A
    bne $1591
; Stored bank offset $079C; original +$059C
    jmp ($14FB)
; Stored bank offset $079F; original +$059F
; jump-vector
    .byte $FE,$14
; Stored bank offset $07A1; original +$05A1
; obfuscation-delimiter
    .byte $CD
; Stored bank offset $07A2; original +$05A2
    beq $15A5
; Stored bank offset $07A4; original +$05A4
    rts
; Stored bank offset $07A5; original +$05A5
    jmp ($1079)
; Stored bank offset $07A8; original +$05A8
; jump-vector
    .byte $A3,$12
; Stored bank offset $07AA; original +$05AA
; obfuscation-delimiter
    .byte $4C
; Stored bank offset $07AB; original +$05AB
    pla
; Stored bank offset $07AC; original +$05AC
    jmp ($14A2)
; Stored bank offset $07AF; original +$05AF
; jump-vector
    .byte $FC,$12
; Stored bank offset $07B1; original +$05B1
; obfuscation-delimiter
    .byte $6C
; Stored bank offset $07B2; original +$05B2
    lda a:$C08E,x
; Stored bank offset $07B5; original +$05B5
    lda a:$C08C,x
; Stored bank offset $07B8; original +$05B8
    bmi $15B5
; Stored bank offset $07BA; original +$05BA
    lda a:$C08C,x
; Stored bank offset $07BD; original +$05BD
    bpl $15BA
; Stored bank offset $07BF; original +$05BF
    jmp ($14AE)
; Stored bank offset $07C2; original +$05C2
; jump-vector
    .byte $06,$12
; Stored bank offset $07C4; original +$05C4
; obfuscation-delimiter
    .byte $20
; Stored bank offset $07C5; original +$05C5
    rol $02
; Stored bank offset $07C7; original +$05C7
    jmp ($12B4)
; Stored bank offset $07CA; original +$05CA
; jump-vector
    .byte $2E,$12
; Stored bank offset $07CC; original +$05CC
; obfuscation-delimiter
    .byte $6D
; Stored bank offset $07CD; original +$05CD
    rol $02
; Stored bank offset $07CF; original +$05CF
    jmp ($12A6)
; Stored bank offset $07D2; original +$05D2
; jump-vector
    .byte $16,$13
; Stored bank offset $07D4; original +$05D4
; obfuscation-delimiter
    .byte $8D
; Stored bank offset $07D5; original +$05D5
    jsr $120F
; Stored bank offset $07D8; original +$05D8
    jmp ($1243)
.assert * - component_start = 103, error, "Tail slice size"
