; Evidence: docs/encoded-native-overlay-body.md
EXT_L_0049 = component_start + (-791)
EXT_L_0236 = component_start + (-298)
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
L_0000:
; jump-vector — Read by reviewed JMP indirect; stored target $0EF4. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $F4,$0E
L_0002:
; obfuscation-delimiter — $E6 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $E6
L_0003:
    eor a:$11F1 ; $0F63
L_0006:
    jmp ($1111) ; $0F66
L_0009:
; jump-vector — Read by reviewed JMP indirect; stored target $0ED4. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $D4,$0E
L_000B:
; obfuscation-delimiter — $D0 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $D0
L_000C:
    lda a:$C08C,x ; $0F6C
L_000F:
    bpl L_000C ; $0F6F
L_0011:
    lsr $05 ; $0F71
L_0013:
    bne L_0018 ; $0F73
L_0015:
    jmp L_002D ; $0F75
L_0018:
    eor #$FF ; $0F78
L_001A:
    beq L_0028 ; $0F7A
L_001C:
    bcc L_0025 ; $0F7C
L_001E:
    eor #$01 ; $0F7E
L_0020:
    bne L_000C ; $0F80
L_0022:
    jmp L_002D ; $0F82
L_0025:
    lda #$10 ; $0F85
L_0027:
    rts ; $0F87
L_0028:
    bcc L_000C ; $0F88
L_002A:
    lda #$81 ; $0F8A
L_002C:
    rts ; $0F8C
L_002D:
    jmp ($0CF2) ; $0F8D
L_0030:
; jump-vector — Read by reviewed JMP indirect; stored target $0E0C. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $0C,$0E
L_0032:
; obfuscation-delimiter — $CD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $CD
L_0033:
    lda #$FF ; $0F93
L_0035:
    jmp ($0CEA) ; $0F95
L_0038:
; jump-vector — Read by reviewed JMP indirect; stored target $0CE4. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $E4,$0C
L_003A:
; obfuscation-delimiter — $4C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $4C
L_003B:
    asl a ; $0F9B
L_003C:
    jmp ($0FE3) ; $0F9C
L_003F:
; jump-vector — Read by reviewed JMP indirect; stored target $0D0B. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $0B,$0D
L_0041:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_0042:
    rol $02 ; $0FA2
L_0044:
    jmp ($0F60) ; $0FA4
L_0047:
; jump-vector — Read by reviewed JMP indirect; stored target $1165. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $65,$11
L_0049:
; obfuscation-delimiter — $20 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $20
L_004A:
    sta a:$11F9 ; $0FAA
L_004D:
    jmp ($10B7) ; $0FAD
L_0050:
; jump-vector — Read by reviewed JMP indirect; stored target $1010. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $10,$10
L_0052:
; obfuscation-delimiter — $6D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6D
L_0053:
    eor a:$0E0E ; $0FB3
L_0056:
    sta $06 ; $0FB6
L_0058:
    jmp ($10D4) ; $0FB8
L_005B:
; jump-vector — Read by reviewed JMP indirect; stored target $0C7C. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $7C,$0C
L_005D:
; obfuscation-delimiter — $8D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $8D
L_005E:
    cmp $03 ; $0FBE
L_0060:
    bne L_0066 ; $0FC0
L_0062:
    jmp ($0C42) ; $0FC2
L_0065:
; obfuscation-delimiter — $8D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $8D
L_0066:
    lda $00 ; $0FC6
L_0068:
    sec ; $0FC8
L_0069:
    jmp ($0CD9) ; $0FC9
L_006C:
; jump-vector — Read by reviewed JMP indirect; stored target $0FAA. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $AA,$0F
L_006E:
; obfuscation-delimiter — $84 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $84
L_006F:
    jmp ($0CF8) ; $0FCF
L_0072:
; jump-vector — Read by reviewed JMP indirect; stored target $0D6B. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $6B,$0D
L_0074:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_0075:
    eor a:$11F1 ; $0FD5
L_0078:
    jmp ($0EA0) ; $0FD8
L_007B:
; jump-vector — Read by reviewed JMP indirect; stored target $115C. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $5C,$11
L_007D:
; obfuscation-delimiter — $AD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $AD
L_007E:
    lda $02 ; $0FDE
L_0080:
    jmp ($0C60) ; $0FE0
L_0083:
; jump-vector — Read by reviewed JMP indirect; stored target $11C5. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $C5,$11
L_0085:
; obfuscation-delimiter — $E6 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $E6
L_0086:
    eor a:$0E0E ; $0FE6
L_0089:
    jmp ($1102) ; $0FE9
L_008C:
; jump-vector — Read by reviewed JMP indirect; stored target $0C74. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $74,$0C
L_008E:
; obfuscation-delimiter — $D0 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $D0
L_008F:
    and #$55 ; $0FEF
L_0091:
    ora $06 ; $0FF1
L_0093:
    jmp ($0F4E) ; $0FF3
L_0096:
; jump-vector — Read by reviewed JMP indirect; stored target $0CF5. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $F5,$0C
L_0098:
; obfuscation-delimiter — $CD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $CD
L_0099:
    ldy #$34 ; $0FF9
L_009B:
    jmp ($0D62) ; $0FFB
L_009E:
; jump-vector — Read by reviewed JMP indirect; stored target $0E54. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $54,$0E
L_00A0:
; obfuscation-delimiter — $4C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $4C
L_00A1:
    asl a ; $1001
L_00A2:
    jmp ($0CE1) ; $1002
L_00A5:
; jump-vector — Read by reviewed JMP indirect; stored target $1105. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $05,$11
L_00A7:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_00A8:
    adc $04 ; $1008
L_00AA:
    jmp ($0EF1) ; $100A
L_00AD:
; jump-vector — Read by reviewed JMP indirect; stored target $0E9D. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $9D,$0E
L_00AF:
; obfuscation-delimiter — $20 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $20
L_00B0:
    ldy #$07 ; $1010
L_00B2:
    jmp ($0EF9) ; $1012
L_00B5:
; jump-vector — Read by reviewed JMP indirect; stored target $0F0D. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $0D,$0F
L_00B7:
; obfuscation-delimiter — $6D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6D
L_00B8:
    lda a:$11F3 ; $1018
L_00BB:
    and #$55 ; $101B
L_00BD:
    jmp ($0C97) ; $101D
L_00C0:
; jump-vector — Read by reviewed JMP indirect; stored target $0F26. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $26,$0F
L_00C2:
; obfuscation-delimiter — $8D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $8D
L_00C3:
    sta $00 ; $1023
L_00C5:
    jmp ($1108) ; $1025
L_00C8:
; jump-vector — Read by reviewed JMP indirect; stored target $0E46. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $46,$0E
L_00CA:
; obfuscation-delimiter — $84 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $84
L_00CB:
    jsr EXT_L_0049 ; $102B
L_00CE:
    jmp ($0F5A) ; $102E
L_00D1:
; jump-vector — Read by reviewed JMP indirect; stored target $0F2E. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $2E,$0F
L_00D3:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_00D4:
    beq L_00F3 ; $1034
L_00D6:
    pla ; $1036
L_00D7:
    bcc L_00DC ; $1037
L_00D9:
    jmp ($11E1) ; $1039
L_00DC:
    lda $00 ; $103C
L_00DE:
    pha ; $103E
L_00DF:
    lda $04 ; $103F
L_00E1:
    sta $00 ; $1041
L_00E3:
    pla ; $1043
L_00E4:
    sta $04 ; $1044
L_00E6:
    lda $06 ; $1046
L_00E8:
    pha ; $1048
L_00E9:
    lda $02 ; $1049
L_00EB:
    sta $06 ; $104B
L_00ED:
    pla ; $104D
L_00EE:
    sta $02 ; $104E
L_00F0:
    jmp L_0066 ; $1050
L_00F3:
    jmp ($119F) ; $1053
L_00F6:
; jump-vector — Read by reviewed JMP indirect; stored target $10C0. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $C0,$10
L_00F8:
; obfuscation-delimiter — $AD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $AD
L_00F9:
    cmp #$0B ; $1059
L_00FB:
    jmp ($0D08) ; $105B
L_00FE:
; jump-vector — Read by reviewed JMP indirect; stored target $0F37. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $37,$0F
L_0100:
; obfuscation-delimiter — $E6 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $E6
L_0101:
    ldy #$02 ; $1061
L_0103:
    lda a:$C08C,x ; $1063
L_0106:
    bpl L_0103 ; $1066
L_0108:
    dey ; $1068
L_0109:
    bne L_0103 ; $1069
L_010B:
    jmp ($0F1B) ; $106B
L_010E:
; jump-vector — Read by reviewed JMP indirect; stored target $0F3F. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $3F,$0F
L_0110:
; obfuscation-delimiter — $D0 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $D0
L_0111:
    dey ; $1071
L_0112:
    bne L_011B ; $1072
L_0114:
    dec $05 ; $1074
L_0116:
    bne L_011B ; $1076
L_0118:
    lda #$01 ; $1078
L_011A:
    rts ; $107A
L_011B:
    lda a:$C08C,x ; $107B
L_011E:
    bpl L_011B ; $107E
L_0120:
    cmp #$D5 ; $1080
L_0122:
    bne L_0111 ; $1082
L_0124:
    lda a:$C08C,x ; $1084
L_0127:
    bpl L_0124 ; $1087
L_0129:
    cmp #$D7 ; $1089
L_012B:
    bne L_0111 ; $108B
L_012D:
    ldy #$04 ; $108D
L_012F:
    lda a:$11F9 ; $108F
L_0132:
    bmi L_0137 ; $1092
L_0134:
    jmp L_0103 ; $1094
L_0137:
    jmp ($0E09) ; $1097
L_013A:
; jump-vector — Read by reviewed JMP indirect; stored target $0CB4. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $B4,$0C
L_013C:
; obfuscation-delimiter — $CD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $CD
L_013D:
    lda $03 ; $109D
L_013F:
    jmp ($0E2B) ; $109F
L_0142:
; jump-vector — Read by reviewed JMP indirect; stored target $0FBE. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $BE,$0F
L_0144:
; obfuscation-delimiter — $4C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $4C
L_0145:
    jmp ($0E3C) ; $10A5
L_0148:
; jump-vector — Read by reviewed JMP indirect; stored target $1191. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $91,$11
L_014A:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_014B:
    jmp ($11C2) ; $10AB
L_014E:
; jump-vector — Read by reviewed JMP indirect; stored target $1061. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $61,$10
L_0150:
; obfuscation-delimiter — $20 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $20
L_0151:
    lda a:$C08D,x ; $10B1
L_0154:
    jmp ($100D) ; $10B4
L_0157:
; jump-vector — Read by reviewed JMP indirect; stored target $110B. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $0B,$11
L_0159:
; obfuscation-delimiter — $6D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6D
L_015A:
    jmp ($0F3C) ; $10BA
L_015D:
; jump-vector — Read by reviewed JMP indirect; stored target $0C9A. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $9A,$0C
L_015F:
; obfuscation-delimiter — $8D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $8D
L_0160:
    inc a:$11F8 ; $10C0
L_0163:
    jmp ($0D4F) ; $10C3
L_0166:
; jump-vector — Read by reviewed JMP indirect; stored target $1148. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $48,$11
L_0168:
; obfuscation-delimiter — $84 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $84
L_0169:
    bne L_016E ; $10C9
L_016B:
    jmp L_01F4 ; $10CB
L_016E:
    dec a:$11E7 ; $10CE
L_0171:
    jmp ($0D8F) ; $10D1
L_0174:
; jump-vector — Read by reviewed JMP indirect; stored target $10F5. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $F5,$10
L_0176:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_0177:
    lda a:$C08C,x ; $10D7
L_017A:
    bpl L_0177 ; $10DA
L_017C:
    cmp #$D5 ; $10DC
L_017E:
    beq L_0186 ; $10DE
L_0180:
    dey ; $10E0
L_0181:
    bne L_0177 ; $10E1
L_0183:
    lda #$06 ; $10E3
L_0185:
    rts ; $10E5
L_0186:
    lda a:$C08C,x ; $10E6
L_0189:
    bpl L_0186 ; $10E9
L_018B:
    cmp #$D7 ; $10EB
L_018D:
    bne L_0177 ; $10ED
L_018F:
    jmp ($0F2B) ; $10EF
L_0192:
; jump-vector — Read by reviewed JMP indirect; stored target $1059. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $59,$10
L_0194:
; obfuscation-delimiter — $AD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $AD
L_0195:
    jsr L_0066 ; $10F5
L_0198:
    jmp ($0D39) ; $10F8
L_019B:
; jump-vector — Read by reviewed JMP indirect; stored target $0C82. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $82,$0C
L_019D:
; obfuscation-delimiter — $E6 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $E6
L_019E:
    pla ; $10FE
L_019F:
    jmp ($1183) ; $10FF
L_01A2:
; jump-vector — Read by reviewed JMP indirect; stored target $1023. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $23,$10
L_01A4:
; obfuscation-delimiter — $D0 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $D0
L_01A5:
    jmp ($1028) ; $1105
L_01A8:
; jump-vector — Read by reviewed JMP indirect; stored target $0D5C. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $5C,$0D
L_01AA:
; obfuscation-delimiter — $CD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $CD
L_01AB:
    jsr EXT_L_0049 ; $110B
L_01AE:
    jmp ($109A) ; $110E
L_01B1:
; jump-vector — Read by reviewed JMP indirect; stored target $0FB3. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $B3,$0F
L_01B3:
; obfuscation-delimiter — $4C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $4C
L_01B4:
    sty $04 ; $1114
L_01B6:
    lda a:$11F9 ; $1116
L_01B9:
    bpl L_01C0 ; $1119
L_01BB:
    jmp ($11DD) ; $111B
L_01BE:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_01BF:
; xor-constant — EOR absolute at $0304 reads this $DA constant.
    .byte $DA
L_01C0:
    ldy #$22 ; $1120
L_01C2:
    lda a:$C08C,x ; $1122
L_01C5:
    bpl L_01C2 ; $1125
L_01C7:
    cmp #$D7 ; $1127
L_01C9:
    beq L_01D1 ; $1129
L_01CB:
    dey ; $112B
L_01CC:
    bne L_01C2 ; $112C
L_01CE:
    lda #$05 ; $112E
L_01D0:
    rts ; $1130
L_01D1:
    lda a:$C08C,x ; $1131
L_01D4:
    bpl L_01D1 ; $1134
L_01D6:
    cmp #$D5 ; $1136
L_01D8:
    bne L_01C2 ; $1138
L_01DA:
    jmp ($0E7A) ; $113A
L_01DD:
; jump-vector — Read by reviewed JMP indirect; stored target $0D99. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $99,$0D
L_01DF:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_01E0:
    sty $02 ; $1140
L_01E2:
    jmp ($0C7F) ; $1142
L_01E5:
; jump-vector — Read by reviewed JMP indirect; stored target $0CED. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $ED,$0C
L_01E7:
; obfuscation-delimiter — $20 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $20
L_01E8:
    lda $03 ; $1148
L_01EA:
    jmp ($0FB0) ; $114A
L_01ED:
; jump-vector — Read by reviewed JMP indirect; stored target $0F48. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $48,$0F
L_01EF:
; obfuscation-delimiter — $6D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6D
L_01F0:
    jmp EXT_L_0236 ; $1150
L_01F3:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_01F4:
    ldx $01 ; $1154
L_01F6:
    jmp ($0FFE) ; $1156
L_01F9:
; jump-vector — Read by reviewed JMP indirect; stored target $0F51. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $51,$0F
L_01FB:
; obfuscation-delimiter — $8D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $8D
L_01FC:
    lda a:$C083 ; $115C
L_01FF:
    jmp ($1145) ; $115F
L_0202:
; jump-vector — Read by reviewed JMP indirect; stored target $0FCF. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $CF,$0F
L_0204:
; obfuscation-delimiter — $84 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $84
L_0205:
    lda #$53 ; $1165
L_0207:
    jmp ($0EE8) ; $1167
L_020A:
; jump-vector — Read by reviewed JMP indirect; stored target $0EEB. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $EB,$0E
L_020C:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_020D:
    lda #$00 ; $116D
L_020F:
    jmp ($0F90) ; $116F
.assert * - component_start = 530, error, "Raw component size"
