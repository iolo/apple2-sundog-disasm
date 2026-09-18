; Evidence: docs/raw-screen-init.md
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
L_0000:
; hgr-row-address-high — Formula matches every high byte; library 22 native procedure 15 reads $0E80,Y for Y < 192
    .byte $20,$24,$28,$2C,$30,$34,$38,$3C,$20,$24,$28,$2C,$30,$34,$38,$3C
    .byte $21,$25,$29,$2D,$31,$35,$39,$3D,$21,$25,$29,$2D,$31,$35,$39,$3D
    .byte $22,$26,$2A,$2E,$32,$36,$3A,$3E,$22,$26,$2A,$2E,$32,$36,$3A,$3E
    .byte $23,$27,$2B,$2F,$33,$37,$3B,$3F,$23,$27,$2B,$2F,$33,$37,$3B,$3F
    .byte $20,$24,$28,$2C,$30,$34,$38,$3C,$20,$24,$28,$2C,$30,$34,$38,$3C
    .byte $21,$25,$29,$2D,$31,$35,$39,$3D,$21,$25,$29,$2D,$31,$35,$39,$3D
    .byte $22,$26,$2A,$2E,$32,$36,$3A,$3E,$22,$26,$2A,$2E,$32,$36,$3A,$3E
    .byte $23,$27,$2B,$2F,$33,$37,$3B,$3F,$23,$27,$2B,$2F,$33,$37,$3B,$3F
    .byte $20,$24,$28,$2C,$30,$34,$38,$3C,$20,$24,$28,$2C,$30,$34,$38,$3C
    .byte $21,$25,$29,$2D,$31,$35,$39,$3D,$21,$25,$29,$2D,$31,$35,$39,$3D
    .byte $22,$26,$2A,$2E,$32,$36,$3A,$3E,$22,$26,$2A,$2E,$32,$36,$3A,$3E
    .byte $23,$27,$2B,$2F,$33,$37,$3B,$3F,$23,$27,$2B,$2F,$33,$37,$3B,$3F
L_00C0:
    pla ; $0F40
L_00C1:
    sta $00 ; $0F41
L_00C3:
    pla ; $0F43
L_00C4:
    sta $01 ; $0F44
L_00C6:
    pla ; $0F46
L_00C7:
    sta $02 ; $0F47
L_00C9:
    pla ; $0F49
L_00CA:
    sta $03 ; $0F4A
L_00CC:
    ldx #$00 ; $0F4C
L_00CE:
    stx $04 ; $0F4E
L_00D0:
    lda #$03 ; $0F50
L_00D2:
    sta $06 ; $0F52
L_00D4:
    lda #$04 ; $0F54
L_00D6:
    sta $08 ; $0F56
L_00D8:
    lda $04 ; $0F58
L_00DA:
    ldy #$08 ; $0F5A
L_00DC:
    sta a:$0DC0,x ; $0F5C
L_00DF:
    inx ; $0F5F
L_00E0:
    dey ; $0F60
L_00E1:
    bne L_00DC ; $0F61
L_00E3:
    ora #$80 ; $0F63
L_00E5:
    ldy #$08 ; $0F65
L_00E7:
    sta a:$0DC0,x ; $0F67
L_00EA:
    inx ; $0F6A
L_00EB:
    dey ; $0F6B
L_00EC:
    bne L_00E7 ; $0F6C
L_00EE:
    dec $08 ; $0F6E
L_00F0:
    bne L_00D8 ; $0F70
L_00F2:
    lda $04 ; $0F72
L_00F4:
    clc ; $0F74
L_00F5:
    adc #$28 ; $0F75
L_00F7:
    sta $04 ; $0F77
L_00F9:
    dec $06 ; $0F79
L_00FB:
    bne L_00D4 ; $0F7B
L_00FD:
    ldx #$00 ; $0F7D
L_00FF:
    ldy #$60 ; $0F7F
L_0101:
    stx $04 ; $0F81
L_0103:
    lda #$18 ; $0F83
L_0105:
    sta $05 ; $0F85
L_0107:
    lda $04 ; $0F87
L_0109:
    sta a:$0D00,x ; $0F89
L_010C:
    lda $05 ; $0F8C
L_010E:
    sta a:$0D60,x ; $0F8E
L_0111:
    clc ; $0F91
L_0112:
    lda $04 ; $0F92
L_0114:
    adc #$14 ; $0F94
L_0116:
    sta $04 ; $0F96
L_0118:
    lda $05 ; $0F98
L_011A:
    adc #$00 ; $0F9A
L_011C:
    sta $05 ; $0F9C
L_011E:
    inx ; $0F9E
L_011F:
    dey ; $0F9F
L_0120:
    bne L_0107 ; $0FA0
L_0122:
    lda $01 ; $0FA2
L_0124:
    pha ; $0FA4
L_0125:
    lda $00 ; $0FA5
L_0127:
    pha ; $0FA7
L_0128:
    rts ; $0FA8
.assert * - component_start = 297, error, "Raw component size"
