; Evidence: docs/warp-animation.md
.setcpu "6502"
; BIT operand bytes are emitted by the independently reachable next instruction.
.macro bit_abs_overlap
    .byte $2C
.endmacro
.macro bit_zp_overlap
    .byte $24
.endmacro
.segment "RAW_NATIVE"
component_start:
L_0000:
    pla ; $1800
L_0001:
    sta $17 ; $1801
L_0003:
    pla ; $1803
L_0004:
    sta $18 ; $1804
L_0006:
    pla ; $1806
L_0007:
    sta $0C ; $1807
L_0009:
    pla ; $1809
L_000A:
    sta $0D ; $180A
L_000C:
    lda #$00 ; $180C
L_000E:
    sta $11 ; $180E
L_0010:
    sta $14 ; $1810
L_0012:
    tay ; $1812
L_0013:
    lda ($0C),y ; $1813
L_0015:
    and #$01 ; $1815
L_0017:
    bne L_001E ; $1817
L_0019:
    lda #$60 ; $1819
L_001B:
    sta a:$1C09 ; $181B
L_001E:
    iny ; $181E
L_001F:
    lda ($0C),y ; $181F
L_0021:
    sta $0E ; $1821
L_0023:
    iny ; $1823
L_0024:
    lda ($0C),y ; $1824
L_0026:
    sta $19 ; $1826
L_0028:
    iny ; $1828
L_0029:
    lda ($0C),y ; $1829
L_002B:
    sta $1A ; $182B
L_002D:
    iny ; $182D
L_002E:
    lda ($0C),y ; $182E
L_0030:
    and #$01 ; $1830
L_0032:
    beq L_0038 ; $1832
L_0034:
    lda #$50 ; $1834
L_0036:
    sta $11 ; $1836
L_0038:
    lda #$24 ; $1838
L_003A:
    sta a:$1CEF ; $183A
L_003D:
    lda #$D6 ; $183D
L_003F:
    sta $15 ; $183F
L_0041:
    lda #$06 ; $1841
L_0043:
    sta $16 ; $1843
L_0045:
    lda #$46 ; $1845
L_0047:
    sta $06 ; $1847
L_0049:
    sta $05 ; $1849
L_004B:
    lda #$16 ; $184B
L_004D:
    sta $09 ; $184D
L_004F:
    lda #$15 ; $184F
L_0051:
    sta $07 ; $1851
L_0053:
    lda #$FE ; $1853
L_0055:
    sta $0A ; $1855
L_0057:
    lda #$BF ; $1857
L_0059:
    sta $08 ; $1859
L_005B:
    lda #$1E ; $185B
L_005D:
    sta $0B ; $185D
L_005F:
    lda #$2D ; $185F
L_0061:
    sta $02 ; $1861
L_0063:
    ldx #$20 ; $1863
L_0065:
    lda #$00 ; $1865
L_0067:
    sta a:$1EF6,x ; $1867
L_006A:
    sta a:$1EC0,x ; $186A
L_006D:
    dex ; $186D
L_006E:
    bne L_0067 ; $186E
L_0070:
    lda #$78 ; $1870
L_0072:
    sta $00 ; $1872
L_0074:
    lda #$14 ; $1874
L_0076:
    sta $01 ; $1876
L_0078:
    lda #$05 ; $1878
L_007A:
    sta $03 ; $187A
L_007C:
    sta $04 ; $187C
L_007E:
    ldx #$35 ; $187E
L_0080:
    jsr L_02B8 ; $1880
L_0083:
    dex ; $1883
L_0084:
    cpx #$FF ; $1884
L_0086:
    bne L_0080 ; $1886
L_0088:
    ldx #$35 ; $1888
L_008A:
    dec $03 ; $188A
L_008C:
    bne L_00C2 ; $188C
L_008E:
    lda $04 ; $188E
L_0090:
    sta $03 ; $1890
L_0092:
    lda $02 ; $1892
L_0094:
    beq L_0099 ; $1894
L_0096:
    jsr L_03AE ; $1896
L_0099:
    jsr L_0325 ; $1899
L_009C:
    jsr L_03AE ; $189C
L_009F:
    lda $00 ; $189F
L_00A1:
    beq L_00A6 ; $18A1
L_00A3:
    jsr L_0505 ; $18A3
L_00A6:
    lda $11 ; $18A6
L_00A8:
    beq L_00B5 ; $18A8
L_00AA:
    dec $11 ; $18AA
L_00AC:
    bne L_00B5 ; $18AC
L_00AE:
    lda $18 ; $18AE
L_00B0:
    pha ; $18B0
L_00B1:
    lda $17 ; $18B1
L_00B3:
    pha ; $18B3
L_00B4:
    rts ; $18B4
L_00B5:
    lda a:$1DB3,x ; $18B5
L_00B8:
    cmp #$FF ; $18B8
L_00BA:
    bne L_00C2 ; $18BA
L_00BC:
    jsr L_02B8 ; $18BC
L_00BF:
    jsr L_0409 ; $18BF
L_00C2:
    dex ; $18C2
L_00C3:
    cpx #$FF ; $18C3
L_00C5:
    bne L_008A ; $18C5
L_00C7:
    lda $00 ; $18C7
L_00C9:
    beq L_00E2 ; $18C9
L_00CB:
    sec ; $18CB
L_00CC:
    sbc $01 ; $18CC
L_00CE:
    bcs L_00D2 ; $18CE
L_00D0:
    lda #$00 ; $18D0
L_00D2:
    sta $00 ; $18D2
L_00D4:
    sec ; $18D4
L_00D5:
    lda $01 ; $18D5
L_00D7:
    sbc #$02 ; $18D7
L_00D9:
    bcs L_00DD ; $18D9
L_00DB:
    lda #$01 ; $18DB
L_00DD:
    sta $01 ; $18DD
L_00DF:
    jmp L_00F0 ; $18DF
L_00E2:
    jsr L_0409 ; $18E2
L_00E5:
    lda $02 ; $18E5
L_00E7:
    beq L_00ED ; $18E7
L_00E9:
    dec $02 ; $18E9
L_00EB:
    bpl L_00F0 ; $18EB
L_00ED:
    jsr L_0107 ; $18ED
L_00F0:
    lda $04 ; $18F0
L_00F2:
    cmp #$01 ; $18F2
L_00F4:
    beq L_00F8 ; $18F4
L_00F6:
    dec $04 ; $18F6
L_00F8:
    lda $09 ; $18F8
L_00FA:
    cmp #$0B ; $18FA
L_00FC:
    bne L_0088 ; $18FC
L_00FE:
    lda a:$1F03 ; $18FE
L_0101:
    bne L_0088 ; $1901
L_0103:
    jmp L_01AA ; $1903
L_0106:
    rts ; $1906
L_0107:
    dec $0B ; $1907
L_0109:
    bpl L_0106 ; $1909
L_010B:
    jsr L_0409 ; $190B
L_010E:
    ldy $0B ; $190E
L_0110:
    iny ; $1910
L_0111:
    bne L_0110 ; $1911
L_0113:
    jsr L_0409 ; $1913
L_0116:
    txa ; $1916
L_0117:
    pha ; $1917
L_0118:
    ldx #$1F ; $1918
L_011A:
    lda a:$1EF7,x ; $191A
L_011D:
    beq L_0131 ; $191D
L_011F:
    jsr L_0198 ; $191F
L_0122:
    ldy a:$1EF7,x ; $1922
L_0125:
    dey ; $1925
L_0126:
    dey ; $1926
L_0127:
    cpy #$06 ; $1927
L_0129:
    bne L_012D ; $1929
L_012B:
    ldy #$00 ; $192B
L_012D:
    tya ; $192D
L_012E:
    sta a:$1EF7,x ; $192E
L_0131:
    dex ; $1931
L_0132:
    cpx #$FF ; $1932
L_0134:
    bne L_011A ; $1934
L_0136:
    ldx #$1F ; $1936
L_0138:
    lda a:$1EC1,x ; $1938
L_013B:
    beq L_014F ; $193B
L_013D:
    jsr L_0198 ; $193D
L_0140:
    ldy a:$1EC1,x ; $1940
L_0143:
    iny ; $1943
L_0144:
    iny ; $1944
L_0145:
    cpy #$68 ; $1945
L_0147:
    bne L_014B ; $1947
L_0149:
    ldy #$00 ; $1949
L_014B:
    tya ; $194B
L_014C:
    sta a:$1EC1,x ; $194C
L_014F:
    dex ; $194F
L_0150:
    cpx #$FF ; $1950
L_0152:
    bne L_0138 ; $1952
L_0154:
    lda $09 ; $1954
L_0156:
    cmp #$0B ; $1956
L_0158:
    beq L_0195 ; $1958
L_015A:
    lda $0A ; $195A
L_015C:
    sec ; $195C
L_015D:
    ror a ; $195D
L_015E:
    bcs L_0174 ; $195E
L_0160:
    ldy $09 ; $1960
L_0162:
    lda #$38 ; $1962
L_0164:
    sta a:$1EF7,y ; $1964
L_0167:
    sta a:$1EC1,y ; $1967
L_016A:
    dey ; $196A
L_016B:
    sty $09 ; $196B
L_016D:
    lda #$B4 ; $196D
L_016F:
    jsr L_04A8 ; $196F
L_0172:
    lda #$BF ; $1972
L_0174:
    sta $0A ; $1974
L_0176:
    dec $06 ; $1976
L_0178:
    bpl L_017C ; $1978
L_017A:
    inc $06 ; $197A
L_017C:
    lda $08 ; $197C
L_017E:
    sec ; $197E
L_017F:
    rol a ; $197F
L_0180:
    bmi L_0191 ; $1980
L_0182:
    ldy $07 ; $1982
L_0184:
    lda #$38 ; $1984
L_0186:
    sta a:$1EC1,y ; $1986
L_0189:
    sta a:$1EF7,y ; $1989
L_018C:
    iny ; $198C
L_018D:
    sty $07 ; $198D
L_018F:
    lda #$FE ; $198F
L_0191:
    sta $08 ; $1991
L_0193:
    inc $05 ; $1993
L_0195:
    pla ; $1995
L_0196:
    tax ; $1996
L_0197:
    rts ; $1997
L_0198:
    tay ; $1998
L_0199:
    pha ; $1999
L_019A:
    jsr L_01A0 ; $199A
L_019D:
    pla ; $199D
L_019E:
    tay ; $199E
L_019F:
    iny ; $199F
L_01A0:
    jsr L_0457 ; $19A0
L_01A3:
    txa ; $19A3
L_01A4:
    tay ; $19A4
L_01A5:
    lda #$80 ; $19A5
L_01A7:
    sta ($0C),y ; $19A7
L_01A9:
    rts ; $19A9
L_01AA:
    dec $02 ; $19AA
L_01AC:
    lda #$46 ; $19AC
L_01AE:
    sta $06 ; $19AE
L_01B0:
    sta $05 ; $19B0
L_01B2:
    lda #$50 ; $19B2
L_01B4:
    sta $0F ; $19B4
L_01B6:
    lda #$FF ; $19B6
L_01B8:
    jsr L_04A8 ; $19B8
L_01BB:
    lda #$FF ; $19BB
L_01BD:
    jsr L_04A8 ; $19BD
L_01C0:
    lda #$63 ; $19C0
L_01C2:
    jsr L_04A8 ; $19C2
L_01C5:
    lda #$00 ; $19C5
L_01C7:
    sta $10 ; $19C7
L_01C9:
    ldx #$36 ; $19C9
L_01CB:
    lda #$00 ; $19CB
L_01CD:
    sta a:$1E8A,x ; $19CD
L_01D0:
    dex ; $19D0
L_01D1:
    bne L_01CD ; $19D1
L_01D3:
    dec $0F ; $19D3
L_01D5:
    bne L_01F6 ; $19D5
L_01D7:
    lda $0E ; $19D7
L_01D9:
    bne L_01E9 ; $19D9
L_01DB:
    lda $14 ; $19DB
L_01DD:
    beq L_01E2 ; $19DD
L_01DF:
    jsr L_04D5 ; $19DF
L_01E2:
    lda $10 ; $19E2
L_01E4:
    bne L_01F3 ; $19E4
L_01E6:
    jmp L_02B1 ; $19E6
L_01E9:
    ldx #$36 ; $19E9
L_01EB:
    lda a:$1E8A,x ; $19EB
L_01EE:
    beq L_01F9 ; $19EE
L_01F0:
    dex ; $19F0
L_01F1:
    bne L_01EB ; $19F1
L_01F3:
    jmp L_0265 ; $19F3
L_01F6:
    jmp L_026E ; $19F6
L_01F9:
    dex ; $19F9
L_01FA:
    beq L_0265 ; $19FA
L_01FC:
    txa ; $19FC
L_01FD:
    tay ; $19FD
L_01FE:
    lda a:$1E8A,y ; $19FE
L_0201:
    beq L_0208 ; $1A01
L_0203:
    dey ; $1A03
L_0204:
    bne L_01FE ; $1A04
L_0206:
    beq L_0265 ; $1A06
L_0208:
    dey ; $1A08
L_0209:
    tya ; $1A09
L_020A:
    pha ; $1A0A
L_020B:
    jsr L_02B8 ; $1A0B
L_020E:
    jsr L_03AE ; $1A0E
L_0211:
    pla ; $1A11
L_0212:
    tay ; $1A12
L_0213:
    lda a:$1DB3,x ; $1A13
L_0216:
    sta a:$1DB3,y ; $1A16
L_0219:
    lda a:$1DE9,x ; $1A19
L_021C:
    sta a:$1DE9,y ; $1A1C
L_021F:
    lda a:$1D11,x ; $1A1F
L_0222:
    sta a:$1D11,y ; $1A22
L_0225:
    lda a:$1D47,x ; $1A25
L_0228:
    sta a:$1D47,y ; $1A28
L_022B:
    lda a:$1D7D,x ; $1A2B
L_022E:
    sta a:$1D7D,y ; $1A2E
L_0231:
    lda a:$1E55,x ; $1A31
L_0234:
    sta a:$1E55,y ; $1A34
L_0237:
    lda a:$1E1F,x ; $1A37
L_023A:
    sta a:$1E1F,y ; $1A3A
L_023D:
    lda #$14 ; $1A3D
L_023F:
    sta a:$1E8B,x ; $1A3F
L_0242:
    sta a:$1E8B,y ; $1A42
L_0245:
    sta a:$1EC1,x ; $1A45
L_0248:
    sta a:$1EC1,y ; $1A48
L_024B:
    lda #$00 ; $1A4B
L_024D:
    sta a:$1EF7,x ; $1A4D
L_0250:
    tya ; $1A50
L_0251:
    tax ; $1A51
L_0252:
    jsr L_0411 ; $1A52
L_0255:
    adc #$19 ; $1A55
L_0257:
    sta a:$1EF7,x ; $1A57
L_025A:
    inc $10 ; $1A5A
L_025C:
    inc $10 ; $1A5C
L_025E:
    dec $0E ; $1A5E
L_0260:
    lda #$03 ; $1A60
L_0262:
    jsr L_04A8 ; $1A62
L_0265:
    jsr L_0411 ; $1A65
L_0268:
    and #$1F ; $1A68
L_026A:
    adc #$14 ; $1A6A
L_026C:
    sta $0F ; $1A6C
L_026E:
    ldx #$35 ; $1A6E
L_0270:
    lda a:$1E8B,x ; $1A70
L_0273:
    beq L_02A9 ; $1A73
L_0275:
    lda a:$1EF7,x ; $1A75
L_0278:
    beq L_0280 ; $1A78
L_027A:
    dec a:$1EF7,x ; $1A7A
L_027D:
    jmp L_02A9 ; $1A7D
L_0280:
    dec a:$1E8B,x ; $1A80
L_0283:
    bne L_02A9 ; $1A83
L_0285:
    lda a:$1EC1,x ; $1A85
L_0288:
    sta a:$1E8B,x ; $1A88
L_028B:
    tay ; $1A8B
L_028C:
    jsr L_0409 ; $1A8C
L_028F:
    nop ; $1A8F
L_0290:
    dey ; $1A90
L_0291:
    bne L_028F ; $1A91
L_0293:
    jsr L_0409 ; $1A93
L_0296:
    jsr L_0325 ; $1A96
L_0299:
    jsr L_03AE ; $1A99
L_029C:
    lda #$02 ; $1A9C
L_029E:
    jsr L_04A8 ; $1A9E
L_02A1:
    dec a:$1EC1,x ; $1AA1
L_02A4:
    bne L_02A9 ; $1AA4
L_02A6:
    inc a:$1EC1,x ; $1AA6
L_02A9:
    dex ; $1AA9
L_02AA:
    cpx #$FF ; $1AAA
L_02AC:
    bne L_0270 ; $1AAC
L_02AE:
    jmp L_01D3 ; $1AAE
L_02B1:
    lda #$23 ; $1AB1
L_02B3:
    sta $11 ; $1AB3
L_02B5:
    jmp L_0045 ; $1AB5
L_02B8:
    jsr L_0411 ; $1AB8
L_02BB:
    clc ; $1ABB
L_02BC:
    adc #$06 ; $1ABC
L_02BE:
    cmp #$46 ; $1ABE
L_02C0:
    beq L_02B8 ; $1AC0
L_02C2:
    sta a:$1DB3,x ; $1AC2
L_02C5:
    jsr L_0411 ; $1AC5
L_02C8:
    cmp #$5A ; $1AC8
L_02CA:
    bcs L_02C5 ; $1ACA
L_02CC:
    adc #$0C ; $1ACC
L_02CE:
    sta a:$1DE9,x ; $1ACE
L_02D1:
    jsr L_03AE ; $1AD1
L_02D4:
    lda #$00 ; $1AD4
L_02D6:
    sta a:$1D47,x ; $1AD6
L_02D9:
    sta a:$1D7D,x ; $1AD9
L_02DC:
    lda a:$1DB3,x ; $1ADC
L_02DF:
    cmp #$46 ; $1ADF
L_02E1:
    bcs L_02EF ; $1AE1
L_02E3:
    lda #$40 ; $1AE3
L_02E5:
    sta a:$1D7D,x ; $1AE5
L_02E8:
    lda #$46 ; $1AE8
L_02EA:
    sec ; $1AEA
L_02EB:
    sbc a:$1DB3,x ; $1AEB
L_02EE:
    bit_abs_overlap ; bit a:$46E9 ; $1AEE
L_02EF:
    sbc #$46 ; $1AEF
L_02F1:
    sta a:$1E55,x ; $1AF1
L_02F4:
    lsr a ; $1AF4
L_02F5:
    sta a:$1D11,x ; $1AF5
L_02F8:
    lda a:$1DE9,x ; $1AF8
L_02FB:
    cmp #$38 ; $1AFB
L_02FD:
    bcs L_030E ; $1AFD
L_02FF:
    lda #$20 ; $1AFF
L_0301:
    ora a:$1D7D,x ; $1B01
L_0304:
    sta a:$1D7D,x ; $1B04
L_0307:
    lda #$38 ; $1B07
L_0309:
    sec ; $1B09
L_030A:
    sbc a:$1DE9,x ; $1B0A
L_030D:
    bit_abs_overlap ; bit a:$38E9 ; $1B0D
L_030E:
    sbc #$38 ; $1B0E
L_0310:
    sta a:$1E1F,x ; $1B10
L_0313:
    cmp a:$1E55,x ; $1B13
L_0316:
    bcc L_0324 ; $1B16
L_0318:
    lsr a ; $1B18
L_0319:
    sta a:$1D11,x ; $1B19
L_031C:
    lda #$80 ; $1B1C
L_031E:
    ora a:$1D7D,x ; $1B1E
L_0321:
    sta a:$1D7D,x ; $1B21
L_0324:
    rts ; $1B24
L_0325:
    lda a:$1D7D,x ; $1B25
L_0328:
    and #$80 ; $1B28
L_032A:
    bne L_035B ; $1B2A
L_032C:
    jsr L_038A ; $1B2C
L_032F:
    lda a:$1D11,x ; $1B2F
L_0332:
    clc ; $1B32
L_0333:
    adc a:$1E1F,x ; $1B33
L_0336:
    sta a:$1D11,x ; $1B36
L_0339:
    bcc L_0340 ; $1B39
L_033B:
    inc a:$1D47,x ; $1B3B
L_033E:
    bcs L_0348 ; $1B3E
L_0340:
    lda a:$1D11,x ; $1B40
L_0343:
    cmp a:$1E55,x ; $1B43
L_0346:
    bcc L_035A ; $1B46
L_0348:
    lda a:$1D11,x ; $1B48
L_034B:
    sec ; $1B4B
L_034C:
    sbc a:$1E55,x ; $1B4C
L_034F:
    sta a:$1D11,x ; $1B4F
L_0352:
    bcs L_0357 ; $1B52
L_0354:
    dec a:$1D47,x ; $1B54
L_0357:
    jsr L_039F ; $1B57
L_035A:
    rts ; $1B5A
L_035B:
    jsr L_039F ; $1B5B
L_035E:
    lda a:$1D11,x ; $1B5E
L_0361:
    clc ; $1B61
L_0362:
    adc a:$1E55,x ; $1B62
L_0365:
    sta a:$1D11,x ; $1B65
L_0368:
    bcc L_036F ; $1B68
L_036A:
    inc a:$1D47,x ; $1B6A
L_036D:
    bcs L_0377 ; $1B6D
L_036F:
    lda a:$1D11,x ; $1B6F
L_0372:
    cmp a:$1E1F,x ; $1B72
L_0375:
    bcc L_0389 ; $1B75
L_0377:
    lda a:$1D11,x ; $1B77
L_037A:
    sec ; $1B7A
L_037B:
    sbc a:$1E1F,x ; $1B7B
L_037E:
    sta a:$1D11,x ; $1B7E
L_0381:
    bcs L_0386 ; $1B81
L_0383:
    dec a:$1D47,x ; $1B83
L_0386:
    jsr L_038A ; $1B86
L_0389:
    rts ; $1B89
L_038A:
    lda a:$1D7D,x ; $1B8A
L_038D:
    and #$40 ; $1B8D
L_038F:
    bne L_0398 ; $1B8F
L_0391:
    inc a:$1DB3,x ; $1B91
L_0394:
    inc a:$1DB3,x ; $1B94
L_0397:
    rts ; $1B97
L_0398:
    dec a:$1DB3,x ; $1B98
L_039B:
    dec a:$1DB3,x ; $1B9B
L_039E:
    rts ; $1B9E
L_039F:
    lda a:$1D7D,x ; $1B9F
L_03A2:
    and #$20 ; $1BA2
L_03A4:
    bne L_03AA ; $1BA4
L_03A6:
    inc a:$1DE9,x ; $1BA6
L_03A9:
    rts ; $1BA9
L_03AA:
    dec a:$1DE9,x ; $1BAA
L_03AD:
    rts ; $1BAD
L_03AE:
    txa ; $1BAE
L_03AF:
    pha ; $1BAF
L_03B0:
    ldy a:$1DE9,x ; $1BB0
L_03B3:
    cpy #$68 ; $1BB3
L_03B5:
    bcs L_03F3 ; $1BB5
L_03B7:
    cpy #$08 ; $1BB7
L_03B9:
    bcc L_03F3 ; $1BB9
L_03BB:
    lda a:$1DB3,x ; $1BBB
L_03BE:
    cmp #$8C ; $1BBE
L_03C0:
    bcs L_03F3 ; $1BC0
L_03C2:
    cmp $06 ; $1BC2
L_03C4:
    bcc L_03CA ; $1BC4
L_03C6:
    cmp $05 ; $1BC6
L_03C8:
    bcc L_03F0 ; $1BC8
L_03CA:
    tax ; $1BCA
L_03CB:
    jsr L_0457 ; $1BCB
L_03CE:
    ldy #$0B ; $1BCE
L_03D0:
    txa ; $1BD0
L_03D1:
    sec ; $1BD1
L_03D2:
    sbc #$07 ; $1BD2
L_03D4:
    iny ; $1BD4
L_03D5:
    bcs L_03D2 ; $1BD5
L_03D7:
    adc #$07 ; $1BD7
L_03D9:
    tax ; $1BD9
L_03DA:
    lda a:$1C02,x ; $1BDA
L_03DD:
    pha ; $1BDD
L_03DE:
    lda $02 ; $1BDE
L_03E0:
    bne L_03EB ; $1BE0
L_03E2:
    jsr L_0409 ; $1BE2
L_03E5:
    pla ; $1BE5
L_03E6:
    ora ($0C),y ; $1BE6
L_03E8:
    jmp L_03EE ; $1BE8
L_03EB:
    pla ; $1BEB
L_03EC:
    eor ($0C),y ; $1BEC
L_03EE:
    sta ($0C),y ; $1BEE
L_03F0:
    pla ; $1BF0
L_03F1:
    tax ; $1BF1
L_03F2:
    rts ; $1BF2
L_03F3:
    pla ; $1BF3
L_03F4:
    tax ; $1BF4
L_03F5:
    lda #$FF ; $1BF5
L_03F7:
    sta a:$1DB3,x ; $1BF7
L_03FA:
    lda #$00 ; $1BFA
L_03FC:
    sta a:$1E8B,x ; $1BFC
L_03FF:
    dec $10 ; $1BFF
L_0401:
    rts ; $1C01
L_0402:
; pixel-bit-masks — $1BDA indexes this table by a pixel coordinate remainder modulo seven
    .byte $01,$02,$04,$08,$10,$20,$40
L_0409:
    bit a:$C030 ; $1C09
L_040C:
    rts ; $1C0C
L_040D:
; arithmetic-scratch-words — $1C13/$1C18/$1C1D/$1C22 initialize these bytes, and $1C27-$1C41 shift/add them
    .byte $00,$00,$00,$00
L_0411:
    lda #$02 ; $1C11
L_0413:
    sta a:$1C0E ; $1C13
L_0416:
    lda #$94 ; $1C16
L_0418:
    sta a:$1C0D ; $1C18
L_041B:
    lda $1A ; $1C1B
L_041D:
    sta a:$1C10 ; $1C1D
L_0420:
    lda $19 ; $1C20
L_0422:
    sta a:$1C0F ; $1C22
L_0425:
    ldy #$10 ; $1C25
L_0427:
    lsr a:$1C0E ; $1C27
L_042A:
    ror a:$1C0D ; $1C2A
L_042D:
    bcc L_043E ; $1C2D
L_042F:
    clc ; $1C2F
L_0430:
    lda $19 ; $1C30
L_0432:
    adc a:$1C0F ; $1C32
L_0435:
    sta $19 ; $1C35
L_0437:
    lda $1A ; $1C37
L_0439:
    adc a:$1C10 ; $1C39
L_043C:
    sta $1A ; $1C3C
L_043E:
    asl a:$1C0F ; $1C3E
L_0441:
    rol a:$1C10 ; $1C41
L_0444:
    dey ; $1C44
L_0445:
    bne L_0427 ; $1C45
L_0447:
    clc ; $1C47
L_0448:
    lda $19 ; $1C48
L_044A:
    adc #$19 ; $1C4A
L_044C:
    sta $19 ; $1C4C
L_044E:
    lda $1A ; $1C4E
L_0450:
    adc #$36 ; $1C50
L_0452:
    sta $1A ; $1C52
L_0454:
    and #$7F ; $1C54
L_0456:
    rts ; $1C56
L_0457:
    lda a:$0DC0,y ; $1C57
L_045A:
    sta $0C ; $1C5A
L_045C:
    lda a:$0E80,y ; $1C5C
L_045F:
    sta $0D ; $1C5F
L_0461:
    rts ; $1C61
L_0462:
; hgr-bitmap-strip — $1CEC reads $1C61+X for X=70 down to 1; row loop draws seven ten-byte rows
    .byte $33,$33,$1F,$5F,$0F,$4F,$0F,$0F,$4F,$0F,$33,$33,$33,$43,$59,$59
    .byte $59,$59,$59,$01,$33,$33,$33,$43,$59,$41,$59,$59,$41,$01,$3F,$1E
    .byte $1F,$4F,$0F,$4F,$4F,$5F,$41,$07,$33,$0C,$03,$43,$19,$58,$41,$59
    .byte $41,$01,$33,$0C,$03,$43,$59,$59,$41,$59,$59,$01,$33,$0C,$03,$5F
    .byte $19,$4F,$41,$19,$4F,$0F
L_04A8:
    sta $12 ; $1CA8
L_04AA:
    tya ; $1CAA
L_04AB:
    pha ; $1CAB
L_04AC:
    txa ; $1CAC
L_04AD:
    pha ; $1CAD
L_04AE:
    lda $15 ; $1CAE
L_04B0:
    sec ; $1CB0
L_04B1:
    sbc $12 ; $1CB1
L_04B3:
    sta $15 ; $1CB3
L_04B5:
    bcs L_04D0 ; $1CB5
L_04B7:
    dec $16 ; $1CB7
L_04B9:
    bpl L_04D0 ; $1CB9
L_04BB:
    jsr L_04D5 ; $1CBB
L_04BE:
    lda #$51 ; $1CBE
L_04C0:
    sta a:$1CEF ; $1CC0
L_04C3:
    lda $15 ; $1CC3
L_04C5:
    clc ; $1CC5
L_04C6:
    adc #$84 ; $1CC6
L_04C8:
    sta $15 ; $1CC8
L_04CA:
    lda $16 ; $1CCA
L_04CC:
    adc #$03 ; $1CCC
L_04CE:
    sta $16 ; $1CCE
L_04D0:
    pla ; $1CD0
L_04D1:
    tax ; $1CD1
L_04D2:
    pla ; $1CD2
L_04D3:
    tay ; $1CD3
L_04D4:
    rts ; $1CD4
L_04D5:
    lda $14 ; $1CD5
L_04D7:
    eor #$FF ; $1CD7
L_04D9:
    sta $14 ; $1CD9
L_04DB:
    lda #$73 ; $1CDB
L_04DD:
    sta $12 ; $1CDD
L_04DF:
    lda #$0A ; $1CDF
L_04E1:
    sta $13 ; $1CE1
L_04E3:
    ldx #$46 ; $1CE3
L_04E5:
    ldy $12 ; $1CE5
L_04E7:
    jsr L_0457 ; $1CE7
L_04EA:
    ldy #$1B ; $1CEA
L_04EC:
    lda a:$1C61,x ; $1CEC
L_04EF:
    bit $0C ; $1CEF
L_04F1:
    sta ($0C),y ; $1CF1
L_04F3:
    dey ; $1CF3
L_04F4:
    dex ; $1CF4
L_04F5:
    beq L_0504 ; $1CF5
L_04F7:
    dec $13 ; $1CF7
L_04F9:
    bne L_04EC ; $1CF9
L_04FB:
    lda #$0A ; $1CFB
L_04FD:
    sta $13 ; $1CFD
L_04FF:
    dec $12 ; $1CFF
L_0501:
    jmp L_04E5 ; $1D01
L_0504:
    rts ; $1D04
L_0505:
    sec ; $1D05
L_0506:
    pha ; $1D06
L_0507:
    sbc #$01 ; $1D07
L_0509:
    bne L_0507 ; $1D09
L_050B:
    pla ; $1D0B
L_050C:
    sbc #$01 ; $1D0C
L_050E:
    bne L_0506 ; $1D0E
L_0510:
    rts ; $1D10
L_0511:
; initial-work-arrays — Zero initial contents of arrays at $1D11,$1D47,$1D7D,$1DB3 and the loaded prefix of $1DE9; direct indexed native accesses and stores establish data
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
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.assert * - component_start = 1536, error, "Raw component size"
