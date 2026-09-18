; Evidence: docs/viewscreen-io.md
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
L_0000:
    pla ; $0800
L_0001:
    sta $20 ; $0801
L_0003:
    pla ; $0803
L_0004:
    sta $21 ; $0804
L_0006:
    pla ; $0806
L_0007:
    sta $22 ; $0807
L_0009:
    pla ; $0809
L_000A:
    sta $23 ; $080A
L_000C:
    lda $21 ; $080C
L_000E:
    pha ; $080E
L_000F:
    lda $20 ; $080F
L_0011:
    pha ; $0811
L_0012:
    ldy #$01 ; $0812
L_0014:
    lda ($22),y ; $0814
L_0016:
    sta $2C ; $0816
L_0018:
    dey ; $0818
L_0019:
    lda ($22),y ; $0819
L_001B:
    bne L_0020 ; $081B
L_001D:
    jmp L_0069 ; $081D
L_0020:
    lda #$FF ; $0820
L_0022:
    sta $2A ; $0822
L_0024:
    sta $2B ; $0824
L_0026:
    lda #$02 ; $0826
L_0028:
    sta $2D ; $0828
L_002A:
    lda #$0C ; $082A
L_002C:
    sta $2E ; $082C
L_002E:
    lda #$66 ; $082E
L_0030:
    sta $2F ; $0830
L_0032:
    ldx #$04 ; $0832
L_0034:
    jsr L_00A4 ; $0834
L_0037:
    lda $2F ; $0837
L_0039:
    sta $27 ; $0839
L_003B:
    lda $2E ; $083B
L_003D:
    sta $26 ; $083D
L_003F:
    jsr L_0106 ; $083F
L_0042:
    jsr L_00B7 ; $0842
L_0045:
    jsr L_009C ; $0845
L_0048:
    dec $27 ; $0848
L_004A:
    dec $26 ; $084A
L_004C:
    bne L_0042 ; $084C
L_004E:
    jsr L_0106 ; $084E
L_0051:
    jsr L_009C ; $0851
L_0054:
    clc ; $0854
L_0055:
    txa ; $0855
L_0056:
    adc #$04 ; $0856
L_0058:
    tax ; $0858
L_0059:
    sec ; $0859
L_005A:
    lda $2F ; $085A
L_005C:
    sbc #$04 ; $085C
L_005E:
    sta $2F ; $085E
L_0060:
    dec $2E ; $0860
L_0062:
    bne L_0034 ; $0862
L_0064:
    dec $2D ; $0864
L_0066:
    bne L_002A ; $0866
L_0068:
    rts ; $0868
L_0069:
    lda #$FF ; $0869
L_006B:
    sta $2A ; $086B
L_006D:
    lda #$FF ; $086D
L_006F:
    sta $2B ; $086F
L_0071:
    lda #$02 ; $0871
L_0073:
    sta $2D ; $0873
L_0075:
    lda #$68 ; $0875
L_0077:
    sta $27 ; $0877
L_0079:
    dec $27 ; $0879
L_007B:
    lda #$30 ; $087B
L_007D:
    sta $26 ; $087D
L_007F:
    ldx #$00 ; $087F
L_0081:
    jsr L_011A ; $0881
L_0084:
    jsr L_00A4 ; $0884
L_0087:
    jsr L_009C ; $0887
L_008A:
    jsr L_00B7 ; $088A
L_008D:
    jsr L_009C ; $088D
L_0090:
    inx ; $0890
L_0091:
    dec $27 ; $0891
L_0093:
    dec $26 ; $0893
L_0095:
    bne L_0081 ; $0895
L_0097:
    dec $2D ; $0897
L_0099:
    bne L_0075 ; $0899
L_009B:
    rts ; $089B
L_009C:
    lda $2C ; $089C
L_009E:
    bne L_00A3 ; $089E
L_00A0:
    lda a:$C030 ; $08A0
L_00A3:
    rts ; $08A3
L_00A4:
    clc ; $08A4
L_00A5:
    lda a:$0937,x ; $08A5
L_00A8:
    adc #$00 ; $08A8
L_00AA:
    tay ; $08AA
L_00AB:
    sta $30 ; $08AB
L_00AD:
    sec ; $08AD
L_00AE:
    lda #$13 ; $08AE
L_00B0:
    sbc a:$0937,x ; $08B0
L_00B3:
    tay ; $08B3
L_00B4:
    sta $31 ; $08B4
L_00B6:
    rts ; $08B6
L_00B7:
    jsr L_011A ; $08B7
L_00BA:
    lda a:$096C,x ; $08BA
L_00BD:
    ldy $30 ; $08BD
L_00BF:
    jsr L_00F8 ; $08BF
L_00C2:
    eor ($24),y ; $08C2
L_00C4:
    sta ($24),y ; $08C4
L_00C6:
    lda a:$09A1,x ; $08C6
L_00C9:
    beq L_00D3 ; $08C9
L_00CB:
    iny ; $08CB
L_00CC:
    jsr L_00F8 ; $08CC
L_00CF:
    eor ($24),y ; $08CF
L_00D1:
    sta ($24),y ; $08D1
L_00D3:
    lda a:$096C,x ; $08D3
L_00D6:
    jsr L_012A ; $08D6
L_00D9:
    ldy $31 ; $08D9
L_00DB:
    jsr L_00F8 ; $08DB
L_00DE:
    eor ($24),y ; $08DE
L_00E0:
    sta ($24),y ; $08E0
L_00E2:
    lda a:$09A1,x ; $08E2
L_00E5:
    beq L_00F7 ; $08E5
L_00E7:
    lda a:$09A1,x ; $08E7
L_00EA:
    jsr L_012A ; $08EA
L_00ED:
    ldy $31 ; $08ED
L_00EF:
    dey ; $08EF
L_00F0:
    jsr L_00F8 ; $08F0
L_00F3:
    eor ($24),y ; $08F3
L_00F5:
    sta ($24),y ; $08F5
L_00F7:
    rts ; $08F7
L_00F8:
    pha ; $08F8
L_00F9:
    sty $29 ; $08F9
L_00FB:
    tya ; $08FB
L_00FC:
    and #$01 ; $08FC
L_00FE:
    tay ; $08FE
L_00FF:
    pla ; $08FF
L_0100:
    and a:$002A,y ; $0900
L_0103:
    ldy $29 ; $0903
L_0105:
    rts ; $0905
L_0106:
    jsr L_011A ; $0906
L_0109:
    ldy $30 ; $0909
L_010B:
    iny ; $090B
L_010C:
    cpy $31 ; $090C
L_010E:
    bcs L_0119 ; $090E
L_0110:
    lda #$FF ; $0910
L_0112:
    eor ($24),y ; $0912
L_0114:
    sta ($24),y ; $0914
L_0116:
    iny ; $0916
L_0117:
    bne L_010C ; $0917
L_0119:
    rts ; $0919
L_011A:
    ldy $27 ; $091A
L_011C:
    clc ; $091C
L_011D:
    lda a:$0DC0,y ; $091D
L_0120:
    adc #$0C ; $0920
L_0122:
    sta $24 ; $0922
L_0124:
    lda a:$0E80,y ; $0924
L_0127:
    sta $25 ; $0927
L_0129:
    rts ; $0929
L_012A:
    asl a ; $092A
L_012B:
    clc ; $092B
L_012C:
    ldy #$08 ; $092C
L_012E:
    asl a ; $092E
L_012F:
    ror $32 ; $092F
L_0131:
    dey ; $0931
L_0132:
    bne L_012E ; $0932
L_0134:
    lda $32 ; $0934
L_0136:
    rts ; $0936
L_0137:
; drawing-columns — $08A5/$08B0 read this table
    .byte $00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$03
    .byte $03,$03,$03,$03,$04,$04,$04,$04,$05,$05,$05,$05,$05,$06,$06,$06
    .byte $06,$06,$07,$07,$07,$07,$07,$08,$08,$08,$08,$09,$09,$09,$09,$09
    .byte $0A,$0A,$0A,$0A,$0A
L_016C:
; first-drawing-masks — $08BA/$08D3 read this table
    .byte $7F,$7E,$7C,$70,$60,$7F,$7E,$78,$70,$40,$7F,$7C,$78,$60,$40,$7F
    .byte $7C,$78,$60,$40,$7E,$7C,$70,$60,$1F,$3E,$78,$70,$60,$1F,$3C,$78
    .byte $60,$40,$0E,$1C,$70,$60,$40,$0E,$18,$30,$60,$03,$06,$18,$30,$40
    .byte $03,$06,$18,$30,$40
L_01A1:
; second-drawing-masks — $08C6/$08E2/$08E7 read this table
    .byte $03,$07,$1F,$3F,$7F,$03,$07,$0F,$3F,$7F,$01,$03,$0F,$1F,$3F,$01
    .byte $03,$07,$1F,$3F,$00,$01,$07,$0F,$00,$00,$01,$03,$07,$00,$00,$00
    .byte $03,$07,$00,$00,$00,$01,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00
L_01D6:
    pla ; $09D6
L_01D7:
    sta $20 ; $09D7
L_01D9:
    pla ; $09D9
L_01DA:
    sta $21 ; $09DA
L_01DC:
    pla ; $09DC
L_01DD:
    sta $22 ; $09DD
L_01DF:
    pla ; $09DF
L_01E0:
    sta $23 ; $09E0
L_01E2:
    lda $21 ; $09E2
L_01E4:
    pha ; $09E4
L_01E5:
    lda $20 ; $09E5
L_01E7:
    pha ; $09E7
L_01E8:
    ldy #$00 ; $09E8
L_01EA:
    ldx #$03 ; $09EA
L_01EC:
    lda ($22),y ; $09EC
L_01EE:
    sta $2A,x ; $09EE
L_01F0:
    iny ; $09F0
L_01F1:
    iny ; $09F1
L_01F2:
    dex ; $09F2
L_01F3:
    bpl L_01EC ; $09F3
L_01F5:
    lda $2B ; $09F5
L_01F7:
    sta $26 ; $09F7
L_01F9:
    lda #$08 ; $09F9
L_01FB:
    sta $27 ; $09FB
L_01FD:
    jsr L_011A ; $09FD
L_0200:
    lda $27 ; $0A00
L_0202:
    clc ; $0A02
L_0203:
    adc $2D ; $0A03
L_0205:
    tax ; $0A05
L_0206:
    lda a:$0B00,x ; $0A06
L_0209:
    clc ; $0A09
L_020A:
    adc $2C ; $0A0A
L_020C:
    ldx #$14 ; $0A0C
L_020E:
    stx $28 ; $0A0E
L_0210:
    ldy #$00 ; $0A10
L_0212:
    clc ; $0A12
L_0213:
    adc #$07 ; $0A13
L_0215:
    tax ; $0A15
L_0216:
    cmp #$07 ; $0A16
L_0218:
    bcs L_0227 ; $0A18
L_021A:
    lda a:$0A54,x ; $0A1A
L_021D:
    sta ($24),y ; $0A1D
L_021F:
    iny ; $0A1F
L_0220:
    txa ; $0A20
L_0221:
    dec $28 ; $0A21
L_0223:
    bne L_0212 ; $0A23
L_0225:
    beq L_0231 ; $0A25
L_0227:
    lda #$80 ; $0A27
L_0229:
    sta ($24),y ; $0A29
L_022B:
    iny ; $0A2B
L_022C:
    txa ; $0A2C
L_022D:
    dec $28 ; $0A2D
L_022F:
    bne L_0212 ; $0A2F
L_0231:
    inc $27 ; $0A31
L_0233:
    dec $26 ; $0A33
L_0235:
    bne L_01FD ; $0A35
L_0237:
    lda $2A ; $0A37
L_0239:
    beq L_0253 ; $0A39
L_023B:
    ldy #$00 ; $0A3B
L_023D:
    ldx #$07 ; $0A3D
L_023F:
    lda a:$0A63,x ; $0A3F
L_0242:
    sta $24 ; $0A42
L_0244:
    lda a:$0A5B,x ; $0A44
L_0247:
    sta $25 ; $0A47
L_0249:
    lda a:$0A6B,x ; $0A49
L_024C:
    ora ($24),y ; $0A4C
L_024E:
    sta ($24),y ; $0A4E
L_0250:
    dex ; $0A50
L_0251:
    bpl L_023F ; $0A51
L_0253:
    rts ; $0A53
L_0254:
; pixel-masks — $0A1A indexes only when unsigned X < 7
    .byte $C0,$A0,$90,$88,$84,$82,$81
L_025B:
; mark-address-high — $0A44 reads with X=7 down to 0
    .byte $2B,$2F,$33,$2B,$2F,$33,$3F,$3F
L_0263:
; mark-address-low — $0A3F reads with X=7 down to 0
    .byte $15,$15,$15,$95,$95,$95,$15,$16
L_026B:
; mark-or-masks — $0A49 reads with X=7 down to 0
    .byte $40,$40,$40,$40,$40,$40,$05,$28
L_0273:
    pla ; $0A73
L_0274:
    sta $20 ; $0A74
L_0276:
    pla ; $0A76
L_0277:
    sta $21 ; $0A77
L_0279:
    pla ; $0A79
L_027A:
    sta $22 ; $0A7A
L_027C:
    pla ; $0A7C
L_027D:
    sta $23 ; $0A7D
L_027F:
    lda $21 ; $0A7F
L_0281:
    pha ; $0A81
L_0282:
    lda $20 ; $0A82
L_0284:
    pha ; $0A84
L_0285:
    ldx a:$C070 ; $0A85
L_0288:
    ldx #$00 ; $0A88
L_028A:
    ldy #$00 ; $0A8A
L_028C:
    nop ; $0A8C
L_028D:
    lda a:$C064 ; $0A8D
L_0290:
    bmi L_0295 ; $0A90
L_0292:
    jmp L_02A2 ; $0A92
L_0295:
    inx ; $0A95
L_0296:
    lda a:$C065 ; $0A96
L_0299:
    bmi L_029E ; $0A99
L_029B:
    jmp L_029F ; $0A9B
L_029E:
    iny ; $0A9E
L_029F:
    jmp L_028C ; $0A9F
L_02A2:
    lda a:$C065 ; $0AA2
L_02A5:
    bmi L_02DB ; $0AA5
L_02A7:
    txa ; $0AA7
L_02A8:
    bpl L_02AC ; $0AA8
L_02AA:
    lda #$7F ; $0AAA
L_02AC:
    lsr a ; $0AAC
L_02AD:
    lsr a ; $0AAD
L_02AE:
    tax ; $0AAE
L_02AF:
    tya ; $0AAF
L_02B0:
    bpl L_02B4 ; $0AB0
L_02B2:
    lda #$7F ; $0AB2
L_02B4:
    lsr a ; $0AB4
L_02B5:
    lsr a ; $0AB5
L_02B6:
    tay ; $0AB6
L_02B7:
    lda a:$0ADF,y ; $0AB7
L_02BA:
    php ; $0ABA
L_02BB:
    ldy #$00 ; $0ABB
L_02BD:
    plp ; $0ABD
L_02BE:
    sta ($22),y ; $0ABE
L_02C0:
    jsr L_02D3 ; $0AC0
L_02C3:
    iny ; $0AC3
L_02C4:
    sta ($22),y ; $0AC4
L_02C6:
    iny ; $0AC6
L_02C7:
    lda a:$0ADF,x ; $0AC7
L_02CA:
    sta ($22),y ; $0ACA
L_02CC:
    jsr L_02D3 ; $0ACC
L_02CF:
    iny ; $0ACF
L_02D0:
    sta ($22),y ; $0AD0
L_02D2:
    rts ; $0AD2
L_02D3:
    bmi L_02D8 ; $0AD3
L_02D5:
    lda #$00 ; $0AD5
L_02D7:
    rts ; $0AD7
L_02D8:
    lda #$FF ; $0AD8
L_02DA:
    rts ; $0ADA
L_02DB:
    iny ; $0ADB
L_02DC:
    jmp L_028C ; $0ADC
L_02DF:
; signed-paddle-motion — $0AB7/$0AC7 read using counters limited and shifted to 0-31
    .byte $08,$07,$06,$05,$05,$04,$04,$03,$03,$02,$02,$02,$01,$01,$01,$00
    .byte $00,$FF,$FF,$FF,$FE,$FE,$FE,$FD,$FD,$FC,$FC,$FB,$FB,$FA,$F9,$F8
L_02FF:
; metadata-alignment — Zero byte between motion table and aligned native relocation words
    .byte $00
L_0300:
; native-relocation-counts — Four empty lists independently validated by native_relocations
    .word 0, 0, 0, 0
L_0308:
; native-entry-pointer — Backward pointer to $0800
    .word * - component_start
L_030A:
; native-attributes — Native representation and lexical level zero
    .byte $00,$00
L_030C:
; procedure-dictionary — Backward pointer to $0B0A
    .word * - L_030A
L_030E:
; segment-trailer — Segment and procedure count 1,1
    .byte $01,$01
L_0310:
; initial-drawing-workspace — Game 13 procedure 2 overwrites the entire $0B00-$0BFF page immediately after loading; native $0A06 indexes it
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04
.assert * - component_start = 1024, error, "Raw component size"
