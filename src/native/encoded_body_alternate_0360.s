; Evidence: docs/encoded-native-overlay-body.md
EXT_L_0049 = component_start + (-791)
EXT_L_0236 = component_start + (-298)
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
L_0000:
; jump-vector — Read by reviewed JMP indirect; stored target $12F4. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $F4,$12
L_0002:
; obfuscation-delimiter — $E6 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $E6
L_0003:
    eor a:$15F1 ; $1363
L_0006:
    jmp ($1511) ; $1366
L_0009:
; jump-vector — Read by reviewed JMP indirect; stored target $12D4. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $D4,$12
L_000B:
; obfuscation-delimiter — $D0 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $D0
L_000C:
    lda a:$C08C,x ; $136C
L_000F:
    bpl L_000C ; $136F
L_0011:
    lsr $05 ; $1371
L_0013:
    bne L_0018 ; $1373
L_0015:
    jmp L_002D ; $1375
L_0018:
    eor #$FF ; $1378
L_001A:
    beq L_0028 ; $137A
L_001C:
    bcc L_0025 ; $137C
L_001E:
    eor #$01 ; $137E
L_0020:
    bne L_000C ; $1380
L_0022:
    jmp L_002D ; $1382
L_0025:
    lda #$10 ; $1385
L_0027:
    rts ; $1387
L_0028:
    bcc L_000C ; $1388
L_002A:
    lda #$81 ; $138A
L_002C:
    rts ; $138C
L_002D:
    jmp ($10F2) ; $138D
L_0030:
; jump-vector — Read by reviewed JMP indirect; stored target $120C. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $0C,$12
L_0032:
; obfuscation-delimiter — $CD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $CD
L_0033:
    lda #$FF ; $1393
L_0035:
    jmp ($10EA) ; $1395
L_0038:
; jump-vector — Read by reviewed JMP indirect; stored target $10E4. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $E4,$10
L_003A:
; obfuscation-delimiter — $4C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $4C
L_003B:
    asl a ; $139B
L_003C:
    jmp ($13E3) ; $139C
L_003F:
; jump-vector — Read by reviewed JMP indirect; stored target $110B. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $0B,$11
L_0041:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_0042:
    rol $02 ; $13A2
L_0044:
    jmp ($1360) ; $13A4
L_0047:
; jump-vector — Read by reviewed JMP indirect; stored target $1565. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $65,$15
L_0049:
; obfuscation-delimiter — $20 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $20
L_004A:
    sta a:$15F9 ; $13AA
L_004D:
    jmp ($14B7) ; $13AD
L_0050:
; jump-vector — Read by reviewed JMP indirect; stored target $1410. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $10,$14
L_0052:
; obfuscation-delimiter — $6D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6D
L_0053:
    eor a:$120E ; $13B3
L_0056:
    sta $06 ; $13B6
L_0058:
    jmp ($14D4) ; $13B8
L_005B:
; jump-vector — Read by reviewed JMP indirect; stored target $107C. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $7C,$10
L_005D:
; obfuscation-delimiter — $8D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $8D
L_005E:
    cmp $03 ; $13BE
L_0060:
    bne L_0066 ; $13C0
L_0062:
    jmp ($1042) ; $13C2
L_0065:
; obfuscation-delimiter — $8D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $8D
L_0066:
    lda $00 ; $13C6
L_0068:
    sec ; $13C8
L_0069:
    jmp ($10D9) ; $13C9
L_006C:
; jump-vector — Read by reviewed JMP indirect; stored target $13AA. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $AA,$13
L_006E:
; obfuscation-delimiter — $84 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $84
L_006F:
    jmp ($10F8) ; $13CF
L_0072:
; jump-vector — Read by reviewed JMP indirect; stored target $116B. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $6B,$11
L_0074:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_0075:
    eor a:$15F1 ; $13D5
L_0078:
    jmp ($12A0) ; $13D8
L_007B:
; jump-vector — Read by reviewed JMP indirect; stored target $155C. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $5C,$15
L_007D:
; obfuscation-delimiter — $AD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $AD
L_007E:
    lda $02 ; $13DE
L_0080:
    jmp ($1060) ; $13E0
L_0083:
; jump-vector — Read by reviewed JMP indirect; stored target $15C5. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $C5,$15
L_0085:
; obfuscation-delimiter — $E6 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $E6
L_0086:
    eor a:$120E ; $13E6
L_0089:
    jmp ($1502) ; $13E9
L_008C:
; jump-vector — Read by reviewed JMP indirect; stored target $1074. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $74,$10
L_008E:
; obfuscation-delimiter — $D0 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $D0
L_008F:
    and #$55 ; $13EF
L_0091:
    ora $06 ; $13F1
L_0093:
    jmp ($134E) ; $13F3
L_0096:
; jump-vector — Read by reviewed JMP indirect; stored target $10F5. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $F5,$10
L_0098:
; obfuscation-delimiter — $CD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $CD
L_0099:
    ldy #$34 ; $13F9
L_009B:
    jmp ($1162) ; $13FB
L_009E:
; jump-vector — Read by reviewed JMP indirect; stored target $1254. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $54,$12
L_00A0:
; obfuscation-delimiter — $4C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $4C
L_00A1:
    asl a ; $1401
L_00A2:
    jmp ($10E1) ; $1402
L_00A5:
; jump-vector — Read by reviewed JMP indirect; stored target $1505. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $05,$15
L_00A7:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_00A8:
    adc $04 ; $1408
L_00AA:
    jmp ($12F1) ; $140A
L_00AD:
; jump-vector — Read by reviewed JMP indirect; stored target $129D. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $9D,$12
L_00AF:
; obfuscation-delimiter — $20 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $20
L_00B0:
    ldy #$07 ; $1410
L_00B2:
    jmp ($12F9) ; $1412
L_00B5:
; jump-vector — Read by reviewed JMP indirect; stored target $130D. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $0D,$13
L_00B7:
; obfuscation-delimiter — $6D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6D
L_00B8:
    lda a:$15F3 ; $1418
L_00BB:
    and #$55 ; $141B
L_00BD:
    jmp ($1097) ; $141D
L_00C0:
; jump-vector — Read by reviewed JMP indirect; stored target $1326. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $26,$13
L_00C2:
; obfuscation-delimiter — $8D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $8D
L_00C3:
    sta $00 ; $1423
L_00C5:
    jmp ($1508) ; $1425
L_00C8:
; jump-vector — Read by reviewed JMP indirect; stored target $1246. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $46,$12
L_00CA:
; obfuscation-delimiter — $84 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $84
L_00CB:
    jsr EXT_L_0049 ; $142B
L_00CE:
    jmp ($135A) ; $142E
L_00D1:
; jump-vector — Read by reviewed JMP indirect; stored target $132E. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $2E,$13
L_00D3:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_00D4:
    beq L_00F3 ; $1434
L_00D6:
    pla ; $1436
L_00D7:
    bcc L_00DC ; $1437
L_00D9:
    jmp ($15E1) ; $1439
L_00DC:
    lda $00 ; $143C
L_00DE:
    pha ; $143E
L_00DF:
    lda $04 ; $143F
L_00E1:
    sta $00 ; $1441
L_00E3:
    pla ; $1443
L_00E4:
    sta $04 ; $1444
L_00E6:
    lda $06 ; $1446
L_00E8:
    pha ; $1448
L_00E9:
    lda $02 ; $1449
L_00EB:
    sta $06 ; $144B
L_00ED:
    pla ; $144D
L_00EE:
    sta $02 ; $144E
L_00F0:
    jmp L_0066 ; $1450
L_00F3:
    jmp ($159F) ; $1453
L_00F6:
; jump-vector — Read by reviewed JMP indirect; stored target $14C0. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $C0,$14
L_00F8:
; obfuscation-delimiter — $AD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $AD
L_00F9:
    cmp #$0B ; $1459
L_00FB:
    jmp ($1108) ; $145B
L_00FE:
; jump-vector — Read by reviewed JMP indirect; stored target $1337. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $37,$13
L_0100:
; obfuscation-delimiter — $E6 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $E6
L_0101:
    ldy #$02 ; $1461
L_0103:
    lda a:$C08C,x ; $1463
L_0106:
    bpl L_0103 ; $1466
L_0108:
    dey ; $1468
L_0109:
    bne L_0103 ; $1469
L_010B:
    jmp ($131B) ; $146B
L_010E:
; jump-vector — Read by reviewed JMP indirect; stored target $133F. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $3F,$13
L_0110:
; obfuscation-delimiter — $D0 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $D0
L_0111:
    dey ; $1471
L_0112:
    bne L_011B ; $1472
L_0114:
    dec $05 ; $1474
L_0116:
    bne L_011B ; $1476
L_0118:
    lda #$01 ; $1478
L_011A:
    rts ; $147A
L_011B:
    lda a:$C08C,x ; $147B
L_011E:
    bpl L_011B ; $147E
L_0120:
    cmp #$D5 ; $1480
L_0122:
    bne L_0111 ; $1482
L_0124:
    lda a:$C08C,x ; $1484
L_0127:
    bpl L_0124 ; $1487
L_0129:
    cmp #$D7 ; $1489
L_012B:
    bne L_0111 ; $148B
L_012D:
    ldy #$04 ; $148D
L_012F:
    lda a:$15F9 ; $148F
L_0132:
    bmi L_0137 ; $1492
L_0134:
    jmp L_0103 ; $1494
L_0137:
    jmp ($1209) ; $1497
L_013A:
; jump-vector — Read by reviewed JMP indirect; stored target $10B4. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $B4,$10
L_013C:
; obfuscation-delimiter — $CD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $CD
L_013D:
    lda $03 ; $149D
L_013F:
    jmp ($122B) ; $149F
L_0142:
; jump-vector — Read by reviewed JMP indirect; stored target $13BE. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $BE,$13
L_0144:
; obfuscation-delimiter — $4C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $4C
L_0145:
    jmp ($123C) ; $14A5
L_0148:
; jump-vector — Read by reviewed JMP indirect; stored target $1591. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $91,$15
L_014A:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_014B:
    jmp ($15C2) ; $14AB
L_014E:
; jump-vector — Read by reviewed JMP indirect; stored target $1461. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $61,$14
L_0150:
; obfuscation-delimiter — $20 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $20
L_0151:
    lda a:$C08D,x ; $14B1
L_0154:
    jmp ($140D) ; $14B4
L_0157:
; jump-vector — Read by reviewed JMP indirect; stored target $150B. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $0B,$15
L_0159:
; obfuscation-delimiter — $6D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6D
L_015A:
    jmp ($133C) ; $14BA
L_015D:
; jump-vector — Read by reviewed JMP indirect; stored target $109A. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $9A,$10
L_015F:
; obfuscation-delimiter — $8D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $8D
L_0160:
    inc a:$15F8 ; $14C0
L_0163:
    jmp ($114F) ; $14C3
L_0166:
; jump-vector — Read by reviewed JMP indirect; stored target $1548. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $48,$15
L_0168:
; obfuscation-delimiter — $84 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $84
L_0169:
    bne L_016E ; $14C9
L_016B:
    jmp L_01F4 ; $14CB
L_016E:
    dec a:$15E7 ; $14CE
L_0171:
    jmp ($118F) ; $14D1
L_0174:
; jump-vector — Read by reviewed JMP indirect; stored target $14F5. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $F5,$14
L_0176:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_0177:
    lda a:$C08C,x ; $14D7
L_017A:
    bpl L_0177 ; $14DA
L_017C:
    cmp #$D5 ; $14DC
L_017E:
    beq L_0186 ; $14DE
L_0180:
    dey ; $14E0
L_0181:
    bne L_0177 ; $14E1
L_0183:
    lda #$06 ; $14E3
L_0185:
    rts ; $14E5
L_0186:
    lda a:$C08C,x ; $14E6
L_0189:
    bpl L_0186 ; $14E9
L_018B:
    cmp #$D7 ; $14EB
L_018D:
    bne L_0177 ; $14ED
L_018F:
    jmp ($132B) ; $14EF
L_0192:
; jump-vector — Read by reviewed JMP indirect; stored target $1459. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $59,$14
L_0194:
; obfuscation-delimiter — $AD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $AD
L_0195:
    jsr L_0066 ; $14F5
L_0198:
    jmp ($1139) ; $14F8
L_019B:
; jump-vector — Read by reviewed JMP indirect; stored target $1082. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $82,$10
L_019D:
; obfuscation-delimiter — $E6 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $E6
L_019E:
    pla ; $14FE
L_019F:
    jmp ($1583) ; $14FF
L_01A2:
; jump-vector — Read by reviewed JMP indirect; stored target $1423. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $23,$14
L_01A4:
; obfuscation-delimiter — $D0 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $D0
L_01A5:
    jmp ($1428) ; $1505
L_01A8:
; jump-vector — Read by reviewed JMP indirect; stored target $115C. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $5C,$11
L_01AA:
; obfuscation-delimiter — $CD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $CD
L_01AB:
    jsr EXT_L_0049 ; $150B
L_01AE:
    jmp ($149A) ; $150E
L_01B1:
; jump-vector — Read by reviewed JMP indirect; stored target $13B3. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $B3,$13
L_01B3:
; obfuscation-delimiter — $4C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $4C
L_01B4:
    sty $04 ; $1514
L_01B6:
    lda a:$15F9 ; $1516
L_01B9:
    bpl L_01C0 ; $1519
L_01BB:
    jmp ($15DD) ; $151B
L_01BE:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_01BF:
; xor-constant — EOR absolute at $0304 reads this $DA constant.
    .byte $DA
L_01C0:
    ldy #$22 ; $1520
L_01C2:
    lda a:$C08C,x ; $1522
L_01C5:
    bpl L_01C2 ; $1525
L_01C7:
    cmp #$D7 ; $1527
L_01C9:
    beq L_01D1 ; $1529
L_01CB:
    dey ; $152B
L_01CC:
    bne L_01C2 ; $152C
L_01CE:
    lda #$05 ; $152E
L_01D0:
    rts ; $1530
L_01D1:
    lda a:$C08C,x ; $1531
L_01D4:
    bpl L_01D1 ; $1534
L_01D6:
    cmp #$D5 ; $1536
L_01D8:
    bne L_01C2 ; $1538
L_01DA:
    jmp ($127A) ; $153A
L_01DD:
; jump-vector — Read by reviewed JMP indirect; stored target $1199. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $99,$11
L_01DF:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_01E0:
    sty $02 ; $1540
L_01E2:
    jmp ($107F) ; $1542
L_01E5:
; jump-vector — Read by reviewed JMP indirect; stored target $10ED. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $ED,$10
L_01E7:
; obfuscation-delimiter — $20 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $20
L_01E8:
    lda $03 ; $1548
L_01EA:
    jmp ($13B0) ; $154A
L_01ED:
; jump-vector — Read by reviewed JMP indirect; stored target $1348. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $48,$13
L_01EF:
; obfuscation-delimiter — $6D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6D
L_01F0:
    jmp EXT_L_0236 ; $1550
L_01F3:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_01F4:
    ldx $01 ; $1554
L_01F6:
    jmp ($13FE) ; $1556
L_01F9:
; jump-vector — Read by reviewed JMP indirect; stored target $1351. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $51,$13
L_01FB:
; obfuscation-delimiter — $8D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $8D
L_01FC:
    lda a:$C083 ; $155C
L_01FF:
    jmp ($1545) ; $155F
L_0202:
; jump-vector — Read by reviewed JMP indirect; stored target $13CF. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $CF,$13
L_0204:
; obfuscation-delimiter — $84 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $84
L_0205:
    lda #$04 ; $1565
L_0207:
    jmp ($12E8) ; $1567
L_020A:
; jump-vector — Read by reviewed JMP indirect; stored target $12EB. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $EB,$12
L_020C:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_020D:
    lda #$00 ; $156D
L_020F:
    jmp ($1390) ; $156F
.assert * - component_start = 530, error, "Raw component size"
