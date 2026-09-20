; Evidence: docs/encoded-native-overlay-tail.md
.setcpu "6502"
.segment "RAW_NATIVE"
.org $1038
component_start:
; Stored bank offset $0638; original +$0437
; bcc $103C: only the displacement survives; missing opcode $90.
    .byte ($103C - $1039)
; Stored bank offset $0639; original +$0439
    jmp ($11E1)
; Stored bank offset $063C; original +$043C
    lda $00
; Stored bank offset $063E; original +$043E
    pha
; Stored bank offset $063F; original +$043F
    lda $04
; Stored bank offset $0641; original +$0441
    sta $00
; Stored bank offset $0643; original +$0443
    pla
; Stored bank offset $0644; original +$0444
    sta $04
; Stored bank offset $0646; original +$0446
    lda $06
; Stored bank offset $0648; original +$0448
    pha
; Stored bank offset $0649; original +$0449
    lda $02
; Stored bank offset $064B; original +$044B
    sta $06
; Stored bank offset $064D; original +$044D
    pla
; Stored bank offset $064E; original +$044E
    sta $02
; Stored bank offset $0650; original +$0450
    jmp $0FC6
; Stored bank offset $0653; original +$0453
    jmp ($119F)
; Stored bank offset $0656; original +$0456
; jump-vector
    .byte $C0,$10
; Stored bank offset $0658; original +$0458
; obfuscation-delimiter
    .byte $AD
; Stored bank offset $0659; original +$0459
    cmp #$0B
; Stored bank offset $065B; original +$045B
    jmp ($0D08)
; Stored bank offset $065E; original +$045E
; jump-vector
    .byte $37,$0F
; Stored bank offset $0660; original +$0460
; obfuscation-delimiter
    .byte $E6
; Stored bank offset $0661; original +$0461
    ldy #$02
; Stored bank offset $0663; original +$0463
    lda a:$C08C,x
; Stored bank offset $0666; original +$0466
    bpl $1063
; Stored bank offset $0668; original +$0468
    dey
; Stored bank offset $0669; original +$0469
    bne $1063
; Stored bank offset $066B; original +$046B
    jmp ($0F1B)
; Stored bank offset $066E; original +$046E
; jump-vector
    .byte $3F,$0F
; Stored bank offset $0670; original +$0470
; obfuscation-delimiter
    .byte $D0
; Stored bank offset $0671; original +$0471
    dey
; Stored bank offset $0672; original +$0472
    bne $107B
; Stored bank offset $0674; original +$0474
    dec $05
; Stored bank offset $0676; original +$0476
    bne $107B
; Stored bank offset $0678; original +$0478
    lda #$01
; Stored bank offset $067A; original +$047A
    rts
; Stored bank offset $067B; original +$047B
    lda a:$C08C,x
; Stored bank offset $067E; original +$047E
    bpl $107B
; Stored bank offset $0680; original +$0480
    cmp #$D5
; Stored bank offset $0682; original +$0482
    bne $1071
; Stored bank offset $0684; original +$0484
    lda a:$C08C,x
; Stored bank offset $0687; original +$0487
    bpl $1084
; Stored bank offset $0689; original +$0489
    cmp #$D7
; Stored bank offset $068B; original +$048B
    bne $1071
; Stored bank offset $068D; original +$048D
    ldy #$04
; Stored bank offset $068F; original +$048F
    lda a:$11F9
; Stored bank offset $0692; original +$0492
    bmi $1097
; Stored bank offset $0694; original +$0494
    jmp $1063
; Stored bank offset $0697; original +$0497
    jmp ($0E09)
; Stored bank offset $069A; original +$049A
; jump-vector
    .byte $B4,$0C
; Stored bank offset $069C; original +$049C
; obfuscation-delimiter
    .byte $CD
; Stored bank offset $069D; original +$049D
    lda $03
; Stored bank offset $069F; original +$049F
    jmp ($0E2B)
; Stored bank offset $06A2; original +$04A2
; jump-vector
    .byte $BE,$0F
; Stored bank offset $06A4; original +$04A4
; obfuscation-delimiter
    .byte $4C
; Stored bank offset $06A5; original +$04A5
    jmp ($0E3C)
; Stored bank offset $06A8; original +$04A8
; jump-vector
    .byte $91,$11
; Stored bank offset $06AA; original +$04AA
; obfuscation-delimiter
    .byte $6C
; Stored bank offset $06AB; original +$04AB
    jmp ($11C2)
; Stored bank offset $06AE; original +$04AE
; jump-vector
    .byte $61,$10
; Stored bank offset $06B0; original +$04B0
; obfuscation-delimiter
    .byte $20
; Stored bank offset $06B1; original +$04B1
    lda a:$C08D,x
; Stored bank offset $06B4; original +$04B4
    jmp ($100D)
; Stored bank offset $06B7; original +$04B7
; jump-vector
    .byte $0B,$11
; Stored bank offset $06B9; original +$04B9
; obfuscation-delimiter
    .byte $6D
; Stored bank offset $06BA; original +$04BA
    jmp ($0F3C)
; Stored bank offset $06BD; original +$04BD
; jump-vector
    .byte $9A,$0C
; Stored bank offset $06BF; original +$04BF
; obfuscation-delimiter
    .byte $8D
; Stored bank offset $06C0; original +$04C0
    inc a:$11F8
; Stored bank offset $06C3; original +$04C3
    jmp ($0D4F)
; Stored bank offset $06C6; original +$04C6
; jump-vector
    .byte $48,$11
; Stored bank offset $06C8; original +$04C8
; obfuscation-delimiter
    .byte $84
; Stored bank offset $06C9; original +$04C9
    bne $10CE
; Stored bank offset $06CB; original +$04CB
    jmp $1154
; Stored bank offset $06CE; original +$04CE
    dec a:$11E7
; Stored bank offset $06D1; original +$04D1
    jmp ($0D8F)
; Stored bank offset $06D4; original +$04D4
; jump-vector
    .byte $F5,$10
; Stored bank offset $06D6; original +$04D6
; obfuscation-delimiter
    .byte $A9
; Stored bank offset $06D7; original +$04D7
    lda a:$C08C,x
; Stored bank offset $06DA; original +$04DA
    bpl $10D7
; Stored bank offset $06DC; original +$04DC
    cmp #$D5
; Stored bank offset $06DE; original +$04DE
    beq $10E6
; Stored bank offset $06E0; original +$04E0
    dey
; Stored bank offset $06E1; original +$04E1
    bne $10D7
; Stored bank offset $06E3; original +$04E3
    lda #$06
; Stored bank offset $06E5; original +$04E5
    rts
; Stored bank offset $06E6; original +$04E6
    lda a:$C08C,x
; Stored bank offset $06E9; original +$04E9
    bpl $10E6
; Stored bank offset $06EB; original +$04EB
    cmp #$D7
; Stored bank offset $06ED; original +$04ED
    bne $10D7
; Stored bank offset $06EF; original +$04EF
    jmp ($0F2B)
; Stored bank offset $06F2; original +$04F2
; jump-vector
    .byte $59,$10
; Stored bank offset $06F4; original +$04F4
; obfuscation-delimiter
    .byte $AD
; Stored bank offset $06F5; original +$04F5
    jsr $0FC6
; Stored bank offset $06F8; original +$04F8
    jmp ($0D39)
; Stored bank offset $06FB; original +$04FB
; jump-vector
    .byte $82,$0C
; Stored bank offset $06FD; original +$04FD
; obfuscation-delimiter
    .byte $E6
; Stored bank offset $06FE; original +$04FE
    pla
; Stored bank offset $06FF; original +$04FF
    jmp ($1183)
; Stored bank offset $0702; original +$0502
; jump-vector
    .byte $23,$10
; Stored bank offset $0704; original +$0504
; obfuscation-delimiter
    .byte $D0
; Stored bank offset $0705; original +$0505
    jmp ($1028)
; Stored bank offset $0708; original +$0508
; jump-vector
    .byte $5C,$0D
; Stored bank offset $070A; original +$050A
; obfuscation-delimiter
    .byte $CD
; Stored bank offset $070B; original +$050B
    jsr $0C49
; Stored bank offset $070E; original +$050E
    jmp ($109A)
; Stored bank offset $0711; original +$0511
; jump-vector
    .byte $B3,$0F
; Stored bank offset $0713; original +$0513
; obfuscation-delimiter
    .byte $4C
; Stored bank offset $0714; original +$0514
    sty $04
; Stored bank offset $0716; original +$0516
    lda a:$11F9
; Stored bank offset $0719; original +$0519
    bpl $1120
; Stored bank offset $071B; original +$051B
    jmp ($11DD)
; Stored bank offset $071E; original +$051E
; obfuscation-delimiter
    .byte $6C
; Stored bank offset $071F; original +$051F
; xor-constant
    .byte $DA
; Stored bank offset $0720; original +$0520
    ldy #$22
; Stored bank offset $0722; original +$0522
    lda a:$C08C,x
; Stored bank offset $0725; original +$0525
    bpl $1122
; Stored bank offset $0727; original +$0527
    cmp #$D7
; Stored bank offset $0729; original +$0529
    beq $1131
; Stored bank offset $072B; original +$052B
    dey
; Stored bank offset $072C; original +$052C
    bne $1122
; Stored bank offset $072E; original +$052E
    lda #$05
; Stored bank offset $0730; original +$0530
    rts
; Stored bank offset $0731; original +$0531
    lda a:$C08C,x
; Stored bank offset $0734; original +$0534
    bpl $1131
; Stored bank offset $0736; original +$0536
    cmp #$D5
; Stored bank offset $0738; original +$0538
    bne $1122
; Stored bank offset $073A; original +$053A
    jmp ($0E7A)
; Stored bank offset $073D; original +$053D
; jump-vector
    .byte $99,$0D
; Stored bank offset $073F; original +$053F
; obfuscation-delimiter
    .byte $6C
; Stored bank offset $0740; original +$0540
    sty $02
; Stored bank offset $0742; original +$0542
    jmp ($0C7F)
; Stored bank offset $0745; original +$0545
; jump-vector
    .byte $ED,$0C
; Stored bank offset $0747; original +$0547
; obfuscation-delimiter
    .byte $20
; Stored bank offset $0748; original +$0548
    lda $03
; Stored bank offset $074A; original +$054A
    jmp ($0FB0)
; Stored bank offset $074D; original +$054D
; jump-vector
    .byte $48,$0F
; Stored bank offset $074F; original +$054F
; obfuscation-delimiter
    .byte $6D
; Stored bank offset $0750; original +$0550
    jmp $0E36
; Stored bank offset $0753; original +$0553
; obfuscation-delimiter
    .byte $6C
; Stored bank offset $0754; original +$0554
    ldx $01
; Stored bank offset $0756; original +$0556
    jmp ($0FFE)
; Stored bank offset $0759; original +$0559
; jump-vector
    .byte $51,$0F
; Stored bank offset $075B; original +$055B
; obfuscation-delimiter
    .byte $8D
; Stored bank offset $075C; original +$055C
    lda a:$C083
; Stored bank offset $075F; original +$055F
    jmp ($1145)
; Stored bank offset $0762; original +$0562
; jump-vector
    .byte $CF,$0F
; Stored bank offset $0764; original +$0564
; obfuscation-delimiter
    .byte $84
; Stored bank offset $0765; original +$0565
    lda #$53
; Stored bank offset $0767; original +$0567
    jmp ($0EE8)
; Stored bank offset $076A; original +$056A
; jump-vector
    .byte $EB,$0E
; Stored bank offset $076C; original +$056C
; obfuscation-delimiter
    .byte $A9
; Stored bank offset $076D; original +$056D
    lda #$00
; Stored bank offset $076F; original +$056F
    jmp ($0F90)
.assert * - component_start = 314, error, "Tail slice size"
