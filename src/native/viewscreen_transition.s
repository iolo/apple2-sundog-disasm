; Evidence: docs/viewscreen-transition.md
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
L_0000:
    pla ; $1800
L_0001:
    sta $18 ; $1801
L_0003:
    pla ; $1803
L_0004:
    sta $19 ; $1804
L_0006:
    pla ; $1806
L_0007:
    sta $1A ; $1807
L_0009:
    pla ; $1809
L_000A:
    sta $1B ; $180A
L_000C:
    ldy #$00 ; $180C
L_000E:
    sty $2D ; $180E
L_0010:
    sty $2A ; $1810
L_0012:
    lda ($1A),y ; $1812
L_0014:
    tax ; $1814
L_0015:
    iny ; $1815
L_0016:
    lda ($1A),y ; $1816
L_0018:
    sta $14 ; $1818
L_001A:
    iny ; $181A
L_001B:
    lda ($1A),y ; $181B
L_001D:
    sta $1C ; $181D
L_001F:
    iny ; $181F
L_0020:
    lda ($1A),y ; $1820
L_0022:
    sta $2C ; $1822
L_0024:
    txa ; $1824
L_0025:
    beq L_002F ; $1825
L_0027:
    bmi L_002C ; $1827
L_0029:
    jmp L_01B7 ; $1829
L_002C:
    jmp L_020F ; $182C
L_002F:
    lda #$67 ; $182F
L_0031:
    sta $0D ; $1831
L_0033:
    lda #$01 ; $1833
L_0035:
    sta $02 ; $1835
L_0037:
    lda #$10 ; $1837
L_0039:
    sta $08 ; $1839
L_003B:
    lda #$77 ; $183B
L_003D:
    sta $07 ; $183D
L_003F:
    lda #$D5 ; $183F
L_0041:
    sta $15 ; $1841
L_0043:
    lda #$2A ; $1843
L_0045:
    sta $16 ; $1845
L_0047:
    jsr L_0323 ; $1847
L_004A:
    lda #$50 ; $184A
L_004C:
    jsr L_0334 ; $184C
L_004F:
    dec $08 ; $184F
L_0051:
    bne L_0047 ; $1851
L_0053:
    lda #$D5 ; $1853
L_0055:
    sta $0C ; $1855
L_0057:
    sta $0B ; $1857
L_0059:
    lda #$67 ; $1859
L_005B:
    sta $0D ; $185B
L_005D:
    sta $13 ; $185D
L_005F:
    sta $17 ; $185F
L_0061:
    lda #$01 ; $1861
L_0063:
    sta $04 ; $1863
L_0065:
    lda #$08 ; $1865
L_0067:
    sta $05 ; $1867
L_0069:
    lda #$20 ; $1869
L_006B:
    sta $06 ; $186B
L_006D:
    jsr L_0323 ; $186D
L_0070:
    jsr L_02DF ; $1870
L_0073:
    lda #$30 ; $1873
L_0075:
    jsr L_0334 ; $1875
L_0078:
    jsr L_0323 ; $1878
L_007B:
    lda #$30 ; $187B
L_007D:
    jsr L_0334 ; $187D
L_0080:
    jsr L_028B ; $1880
L_0083:
    dec $17 ; $1883
L_0085:
    dec $0D ; $1885
L_0087:
    dec $13 ; $1887
L_0089:
    lda $13 ; $1889
L_008B:
    cmp #$08 ; $188B
L_008D:
    bne L_006D ; $188D
L_008F:
    lda $0D ; $188F
L_0091:
    sta $03 ; $1891
L_0093:
    inc $13 ; $1893
L_0095:
    jsr L_02DF ; $1895
L_0098:
    lda #$D5 ; $1898
L_009A:
    sta $0A ; $189A
L_009C:
    lda #$7F ; $189C
L_009E:
    sta $0E ; $189E
L_00A0:
    ldx #$02 ; $18A0
L_00A2:
    lda $04,x ; $18A2
L_00A4:
    clc ; $18A4
L_00A5:
    adc $13 ; $18A5
L_00A7:
    sta $03 ; $18A7
L_00A9:
    jsr L_0309 ; $18A9
L_00AC:
    dex ; $18AC
L_00AD:
    bpl L_00A2 ; $18AD
L_00AF:
    lda #$08 ; $18AF
L_00B1:
    sta $03 ; $18B1
L_00B3:
    jsr L_0309 ; $18B3
L_00B6:
    lda #$67 ; $18B6
L_00B8:
    sta $11 ; $18B8
L_00BA:
    sta $17 ; $18BA
L_00BC:
    lda #$45 ; $18BC
L_00BE:
    sta $12 ; $18BE
L_00C0:
    lda #$01 ; $18C0
L_00C2:
    sta $02 ; $18C2
L_00C4:
    sta $04 ; $18C4
L_00C6:
    lda #$08 ; $18C6
L_00C8:
    sta $05 ; $18C8
L_00CA:
    lda #$20 ; $18CA
L_00CC:
    sta $06 ; $18CC
L_00CE:
    lda #$AA ; $18CE
L_00D0:
    sta $15 ; $18D0
L_00D2:
    lda #$55 ; $18D2
L_00D4:
    sta $16 ; $18D4
L_00D6:
    ldx #$0F ; $18D6
L_00D8:
    lda #$89 ; $18D8
L_00DA:
    jsr L_0334 ; $18DA
L_00DD:
    dex ; $18DD
L_00DE:
    bne L_00D8 ; $18DE
L_00E0:
    jsr L_02D3 ; $18E0
L_00E3:
    lda $12 ; $18E3
L_00E5:
    jsr L_0334 ; $18E5
L_00E8:
    jsr L_028B ; $18E8
L_00EB:
    inc $12 ; $18EB
L_00ED:
    lda $12 ; $18ED
L_00EF:
    jsr L_0334 ; $18EF
L_00F2:
    dec $11 ; $18F2
L_00F4:
    dec $17 ; $18F4
L_00F6:
    lda $11 ; $18F6
L_00F8:
    cmp #$3C ; $18F8
L_00FA:
    bne L_00E0 ; $18FA
L_00FC:
    inc $11 ; $18FC
L_00FE:
    lda #$10 ; $18FE
L_0100:
    sta $08 ; $1900
L_0102:
    lda $11 ; $1902
L_0104:
    sta $03 ; $1904
L_0106:
    lda #$00 ; $1906
L_0108:
    sta $0A ; $1908
L_010A:
    sta $0E ; $190A
L_010C:
    jsr L_0309 ; $190C
L_010F:
    lda $12 ; $190F
L_0111:
    adc #$04 ; $1911
L_0113:
    sta $12 ; $1913
L_0115:
    jsr L_028B ; $1915
L_0118:
    lda #$00 ; $1918
L_011A:
    sta $02 ; $191A
L_011C:
    lda $12 ; $191C
L_011E:
    jsr L_0334 ; $191E
L_0121:
    lda $12 ; $1921
L_0123:
    jsr L_0334 ; $1923
L_0126:
    dec $08 ; $1926
L_0128:
    bne L_010F ; $1928
L_012A:
    ldy $11 ; $192A
L_012C:
    sty $0D ; $192C
L_012E:
    jsr L_0158 ; $192E
L_0131:
    jsr L_0158 ; $1931
L_0134:
    jsr L_0158 ; $1934
L_0137:
    jsr L_014A ; $1937
L_013A:
    jsr L_014A ; $193A
L_013D:
    lda $2D ; $193D
L_013F:
    ldy #$03 ; $193F
L_0141:
    sta ($1A),y ; $1941
L_0143:
    lda $19 ; $1943
L_0145:
    pha ; $1945
L_0146:
    lda $18 ; $1946
L_0148:
    pha ; $1948
L_0149:
    rts ; $1949
L_014A:
    lda $12 ; $194A
L_014C:
    jsr L_0334 ; $194C
L_014F:
    lda $12 ; $194F
L_0151:
    jsr L_0334 ; $1951
L_0154:
    jsr L_028B ; $1954
L_0157:
    rts ; $1957
L_0158:
    jsr L_0264 ; $1958
L_015B:
    lda $12 ; $195B
L_015D:
    adc #$0A ; $195D
L_015F:
    sta $12 ; $195F
L_0161:
    jsr L_0334 ; $1961
L_0164:
    lda $12 ; $1964
L_0166:
    jsr L_0334 ; $1966
L_0169:
    jmp L_028B ; $1969
L_016C:
    jsr L_01C1 ; $196C
L_016F:
    lda #$37 ; $196F
L_0171:
    sta $11 ; $1971
L_0173:
    ldx #$11 ; $1973
L_0175:
    lda #$80 ; $1975
L_0177:
    jsr L_0334 ; $1977
L_017A:
    dex ; $197A
L_017B:
    bpl L_0175 ; $197B
L_017D:
    lda #$66 ; $197D
L_017F:
    sta $03 ; $197F
L_0181:
    ldy $03 ; $1981
L_0183:
    jsr L_0340 ; $1983
L_0186:
    ldx #$13 ; $1986
L_0188:
    ldy #$0C ; $1988
L_018A:
    lda ($00),y ; $198A
L_018C:
    sta a:$1B8B,x ; $198C
L_018F:
    iny ; $198F
L_0190:
    dex ; $1990
L_0191:
    bpl L_018A ; $1991
L_0193:
    ldy $03 ; $1993
L_0195:
    iny ; $1995
L_0196:
    jsr L_0340 ; $1996
L_0199:
    ldx #$13 ; $1999
L_019B:
    ldy #$0C ; $199B
L_019D:
    lda a:$1B8B,x ; $199D
L_01A0:
    sta ($00),y ; $19A0
L_01A2:
    iny ; $19A2
L_01A3:
    dex ; $19A3
L_01A4:
    bpl L_019D ; $19A4
L_01A6:
    dec $03 ; $19A6
L_01A8:
    lda $03 ; $19A8
L_01AA:
    cmp $11 ; $19AA
L_01AC:
    bne L_0181 ; $19AC
L_01AE:
    inc $11 ; $19AE
L_01B0:
    lda $11 ; $19B0
L_01B2:
    cmp #$66 ; $19B2
L_01B4:
    bne L_017D ; $19B4
L_01B6:
    rts ; $19B6
L_01B7:
    jsr L_016C ; $19B7
L_01BA:
    lda $1C ; $19BA
L_01BC:
    sta $14 ; $19BC
L_01BE:
    jmp L_00B6 ; $19BE
L_01C1:
    lda #$20 ; $19C1
L_01C3:
    sta $04 ; $19C3
L_01C5:
    lda #$08 ; $19C5
L_01C7:
    sta $03 ; $19C7
L_01C9:
    sta $05 ; $19C9
L_01CB:
    lda #$01 ; $19CB
L_01CD:
    sta $06 ; $19CD
L_01CF:
    lda #$D5 ; $19CF
L_01D1:
    sta $0A ; $19D1
L_01D3:
    lda #$7F ; $19D3
L_01D5:
    sta $0E ; $19D5
L_01D7:
    jsr L_0309 ; $19D7
L_01DA:
    inc $03 ; $19DA
L_01DC:
    lda $03 ; $19DC
L_01DE:
    cmp #$3D ; $19DE
L_01E0:
    bne L_01D7 ; $19E0
L_01E2:
    ldx $03 ; $19E2
L_01E4:
    stx $0D ; $19E4
L_01E6:
    stx $17 ; $19E6
L_01E8:
    dec $17 ; $19E8
L_01EA:
    lda #$AA ; $19EA
L_01EC:
    sta $15 ; $19EC
L_01EE:
    sta $0A ; $19EE
L_01F0:
    jsr L_0309 ; $19F0
L_01F3:
    inc $03 ; $19F3
L_01F5:
    lda $03 ; $19F5
L_01F7:
    cmp #$67 ; $19F7
L_01F9:
    bne L_01F0 ; $19F9
L_01FB:
    lda #$00 ; $19FB
L_01FD:
    sta $02 ; $19FD
L_01FF:
    lda #$55 ; $19FF
L_0201:
    sta $16 ; $1A01
L_0203:
    jsr L_028B ; $1A03
L_0206:
    jsr L_0264 ; $1A06
L_0209:
    jsr L_0264 ; $1A09
L_020C:
    jmp L_0264 ; $1A0C
L_020F:
    jsr L_016C ; $1A0F
L_0212:
    lda #$09 ; $1A12
L_0214:
    sta $17 ; $1A14
L_0216:
    sta $07 ; $1A16
L_0218:
    sta $0D ; $1A18
L_021A:
    lda #$20 ; $1A1A
L_021C:
    sta $04 ; $1A1C
L_021E:
    lda #$08 ; $1A1E
L_0220:
    sta $05 ; $1A20
L_0222:
    lda #$01 ; $1A22
L_0224:
    sta $06 ; $1A24
L_0226:
    lda #$D5 ; $1A26
L_0228:
    sta $15 ; $1A28
L_022A:
    lda #$2A ; $1A2A
L_022C:
    sta $16 ; $1A2C
L_022E:
    lda #$FF ; $1A2E
L_0230:
    sta $02 ; $1A30
L_0232:
    ldx #$10 ; $1A32
L_0234:
    lda #$95 ; $1A34
L_0236:
    jsr L_0334 ; $1A36
L_0239:
    dex ; $1A39
L_023A:
    bpl L_0234 ; $1A3A
L_023C:
    jsr L_0323 ; $1A3C
L_023F:
    lda #$80 ; $1A3F
L_0241:
    jsr L_0334 ; $1A41
L_0244:
    jsr L_028B ; $1A44
L_0247:
    inc $17 ; $1A47
L_0249:
    inc $0D ; $1A49
L_024B:
    lda $0D ; $1A4B
L_024D:
    cmp #$68 ; $1A4D
L_024F:
    bne L_023C ; $1A4F
L_0251:
    lda #$10 ; $1A51
L_0253:
    sta $08 ; $1A53
L_0255:
    jsr L_0323 ; $1A55
L_0258:
    lda #$A0 ; $1A58
L_025A:
    jsr L_0334 ; $1A5A
L_025D:
    dec $08 ; $1A5D
L_025F:
    bne L_0255 ; $1A5F
L_0261:
    jmp L_013D ; $1A61
L_0264:
    dec $0D ; $1A64
L_0266:
    ldy $0D ; $1A66
L_0268:
    jsr L_0340 ; $1A68
L_026B:
    lda $14 ; $1A6B
L_026D:
    and #$07 ; $1A6D
L_026F:
    ora #$05 ; $1A6F
L_0271:
    sta $08 ; $1A71
L_0273:
    ldx $14 ; $1A73
L_0275:
    ldy a:$1B4B,x ; $1A75
L_0278:
    lda a:$1B6B,x ; $1A78
L_027B:
    sta ($00),y ; $1A7B
L_027D:
    inx ; $1A7D
L_027E:
    txa ; $1A7E
L_027F:
    and #$1F ; $1A7F
L_0281:
    tax ; $1A81
L_0282:
    dec $08 ; $1A82
L_0284:
    bne L_0275 ; $1A84
L_0286:
    rts ; $1A86
L_0287:
    lda #$01 ; $1A87
L_0289:
    bne L_02BE ; $1A89
L_028B:
    ldx #$02 ; $1A8B
L_028D:
    lda $16 ; $1A8D
L_028F:
    sta $09 ; $1A8F
L_0291:
    lda $15 ; $1A91
L_0293:
    sta $0B ; $1A93
L_0295:
    sta $0C ; $1A95
L_0297:
    lda $04,x ; $1A97
L_0299:
    clc ; $1A99
L_029A:
    adc $17 ; $1A9A
L_029C:
    adc $02 ; $1A9C
L_029E:
    sta $03 ; $1A9E
L_02A0:
    cmp #$67 ; $1AA0
L_02A2:
    bcs L_02A7 ; $1AA2
L_02A4:
    jsr L_02E9 ; $1AA4
L_02A7:
    lda $09 ; $1AA7
L_02A9:
    eor $16 ; $1AA9
L_02AB:
    sta $09 ; $1AAB
L_02AD:
    sta $0A ; $1AAD
L_02AF:
    bne L_02B7 ; $1AAF
L_02B1:
    lda #$00 ; $1AB1
L_02B3:
    sta $0E ; $1AB3
L_02B5:
    beq L_02BB ; $1AB5
L_02B7:
    lda #$7F ; $1AB7
L_02B9:
    sta $0E ; $1AB9
L_02BB:
    lda $04,x ; $1ABB
L_02BD:
    asl a ; $1ABD
L_02BE:
    sta $04,x ; $1ABE
L_02C0:
    cmp #$80 ; $1AC0
L_02C2:
    bcs L_0287 ; $1AC2
L_02C4:
    adc $17 ; $1AC4
L_02C6:
    sta $03 ; $1AC6
L_02C8:
    cmp #$67 ; $1AC8
L_02CA:
    bcs L_02CF ; $1ACA
L_02CC:
    jsr L_0309 ; $1ACC
L_02CF:
    dex ; $1ACF
L_02D0:
    bpl L_0291 ; $1AD0
L_02D2:
    rts ; $1AD2
L_02D3:
    lda $11 ; $1AD3
L_02D5:
    sta $03 ; $1AD5
L_02D7:
    lda #$AA ; $1AD7
L_02D9:
    sta $0B ; $1AD9
L_02DB:
    sta $0C ; $1ADB
L_02DD:
    bne L_02E9 ; $1ADD
L_02DF:
    lda $13 ; $1ADF
L_02E1:
    sta $03 ; $1AE1
L_02E3:
    lda #$D5 ; $1AE3
L_02E5:
    sta $0B ; $1AE5
L_02E7:
    sta $0C ; $1AE7
L_02E9:
    lda $03 ; $1AE9
L_02EB:
    ldy #$7F ; $1AEB
L_02ED:
    sty $0E ; $1AED
L_02EF:
    and #$01 ; $1AEF
L_02F1:
    beq L_02FF ; $1AF1
L_02F3:
    lda $0B ; $1AF3
L_02F5:
    sta $0A ; $1AF5
L_02F7:
    bne L_0309 ; $1AF7
L_02F9:
    lda #$00 ; $1AF9
L_02FB:
    sta $0E ; $1AFB
L_02FD:
    beq L_0309 ; $1AFD
L_02FF:
    lda $0C ; $1AFF
L_0301:
    sta $0A ; $1B01
L_0303:
    bne L_0309 ; $1B03
L_0305:
    ldy #$00 ; $1B05
L_0307:
    sty $0E ; $1B07
L_0309:
    ldy $03 ; $1B09
L_030B:
    jsr L_0340 ; $1B0B
L_030E:
    ldy #$0C ; $1B0E
L_0310:
    lda $0A ; $1B10
L_0312:
    sta ($00),y ; $1B12
L_0314:
    iny ; $1B14
L_0315:
    eor $0E ; $1B15
L_0317:
    bne L_031B ; $1B17
L_0319:
    lda $0A ; $1B19
L_031B:
    sta ($00),y ; $1B1B
L_031D:
    iny ; $1B1D
L_031E:
    cpy #$20 ; $1B1E
L_0320:
    bne L_0310 ; $1B20
L_0322:
    rts ; $1B22
L_0323:
    sec ; $1B23
L_0324:
    lda $0D ; $1B24
L_0326:
    sbc #$08 ; $1B26
L_0328:
    sta $2B ; $1B28
L_032A:
    lda $07 ; $1B2A
L_032C:
    sta $2D ; $1B2C
L_032E:
    jsr a:$09F5 ; $1B2E
L_0331:
    inc $07 ; $1B31
L_0333:
    rts ; $1B33
L_0334:
    sec ; $1B34
L_0335:
    pha ; $1B35
L_0336:
    sbc #$01 ; $1B36
L_0338:
    bne L_0336 ; $1B38
L_033A:
    pla ; $1B3A
L_033B:
    sbc #$01 ; $1B3B
L_033D:
    bne L_0335 ; $1B3D
L_033F:
    rts ; $1B3F
L_0340:
    lda a:$0DC0,y ; $1B40
L_0343:
    sta $00 ; $1B43
L_0345:
    lda a:$0E80,y ; $1B45
L_0348:
    sta $01 ; $1B48
L_034A:
    rts ; $1B4A
L_034B:
; drawing-columns — $1A75 reads columns with an index wrapped by AND $1F at $1A7F
    .byte $1C,$1A,$18,$16,$14,$12,$10,$0E,$1C,$1A,$18,$16,$14,$12,$10,$0E
    .byte $1C,$1A,$18,$16,$14,$12,$10,$0E,$1C,$1A,$18,$16,$14,$12,$10,$0E
L_036B:
; pixel-patterns — $1A78 reads patterns and $1A7B stores them through a screen-row pointer
    .byte $55,$0A,$2A,$7F,$00,$55,$05,$2A,$AA,$06,$55,$77,$2A,$00,$AA,$0A
    .byte $06,$22,$45,$72,$99,$00,$AA,$55,$7F,$08,$09,$10,$20,$2A,$23,$77
L_038B:
; row-copy-buffer — $198C writes and $199D reads with X=19 down to 0
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00
L_039F:
; metadata-alignment — Zero byte after the 20-byte buffer aligns the native relocation words
    .byte $00
L_03A0:
; native-relocation-counts — Four empty relocation lists validated by native_relocations
    .word 0, 0, 0, 0
L_03A8:
; native-entry-pointer — Backward displacement from $1BA8 to entry $1800
    .word * - component_start
L_03AA:
; native-attributes — Native representation and lexical level zero
    .byte $00,$00
L_03AC:
; procedure-dictionary — Backward pointer to native attributes at $1BAA
    .word * - L_03AA
L_03AE:
; segment-trailer — Segment number 1 and procedure count 1; validated by procedure_dictionary
    .byte $01,$01
.assert * - component_start = 944, error, "Raw component size"
