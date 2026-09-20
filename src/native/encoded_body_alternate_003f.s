; Evidence: docs/encoded-native-overlay-body.md
EXT_L_05FC = component_start + (1469)
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
L_0000:
; obfuscation-delimiter — $EA decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $EA
L_0001:
; jump-vector — Read by reviewed JMP indirect; stored target $1274. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $74,$12
L_0003:
; jump-vector — Read by reviewed JMP indirect; stored target $13C6. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $C6,$13
L_0005:
; jump-vector — Read by reviewed JMP indirect; stored target $1220. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $20,$12
L_0007:
; jump-vector — Read by reviewed JMP indirect; stored target $1505. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $05,$15
L_0009:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_000A:
    ldy #$40 ; $1049
L_000C:
    jmp ($14BD) ; $104B
L_000F:
; jump-vector — Read by reviewed JMP indirect; stored target $14A5. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $A5,$14
L_0011:
; obfuscation-delimiter — $AD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $AD
L_0012:
    bne L_001A ; $1051
L_0014:
    jsr L_015E ; $1053
L_0017:
    jmp ($1040) ; $1056
L_001A:
    jmp ($15E5) ; $1059
L_001D:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_001E:
    jmp ($1214) ; $105D
L_0021:
; jump-vector — Read by reviewed JMP indirect; stored target $124C. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $4C,$12
L_0023:
; obfuscation-delimiter — $E6 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $E6
L_0024:
    ldx $01 ; $1063
L_0026:
    jmp ($11FC) ; $1065
L_0029:
; jump-vector — Read by reviewed JMP indirect; stored target $156D. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $6D,$15
L_002B:
; obfuscation-delimiter — $D0 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $D0
L_002C:
    sta a:$4004 ; $106B
L_002F:
    jmp ($13EC) ; $106E
L_0032:
; jump-vector — Read by reviewed JMP indirect; stored target $131E. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $1E,$13
L_0034:
; obfuscation-delimiter — $CD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $CD
L_0035:
    lda #$09 ; $1074
L_0037:
    jmp ($1415) ; $1076
L_003A:
; jump-vector — Read by reviewed JMP indirect; stored target $1393. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $93,$13
L_003C:
; obfuscation-delimiter — $4C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $4C
L_003D:
    jmp ($1196) ; $107C
L_0040:
; jump-vector — Read by reviewed JMP indirect; stored target $113C. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $3C,$11
L_0042:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_0043:
    eor #$22 ; $1082
L_0045:
    sta $05 ; $1084
L_0047:
    lda a:$C08C,x ; $1086
L_004A:
    bpl L_0047 ; $1089
L_004C:
    jmp L_00E4 ; $108B
L_004F:
; entry-address — Stored $0DF9/$11F9 body-entry address, matching the loader call and the relocated counterpart.
    .byte $F9,$11
L_0051:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_0052:
    lda a:$C08E,x ; $1091
L_0055:
    jmp ($12C2) ; $1094
L_0058:
; jump-vector — Read by reviewed JMP indirect; stored target $1102. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $02,$11
L_005A:
; obfuscation-delimiter — $20 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $20
L_005B:
    sty $05 ; $109A
L_005D:
    jmp ($12D1) ; $109C
L_0060:
; jump-vector — Read by reviewed JMP indirect; stored target $149D. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $9D,$14
L_0062:
; obfuscation-delimiter — $6D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6D
L_0063:
    and #$55 ; $10A2
L_0065:
    asl a ; $10A4
L_0066:
    jmp ($13D2) ; $10A5
L_0069:
; jump-vector — Read by reviewed JMP indirect; stored target $12E3. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $E3,$12
L_006B:
; obfuscation-delimiter — $8D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $8D
L_006C:
    sta a:$15F9 ; $10AB
L_006F:
    jmp ($109F) ; $10AE
L_0072:
; jump-vector — Read by reviewed JMP indirect; stored target $13EF. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $EF,$13
L_0074:
; obfuscation-delimiter — $84 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $84
L_0075:
    bne L_0082 ; $10B4
L_0077:
    ldy #$40 ; $10B6
L_0079:
    sty $05 ; $10B8
L_007B:
    dey ; $10BA
L_007C:
    bne L_0085 ; $10BB
L_007E:
    dec $05 ; $10BD
L_0080:
    bne L_0085 ; $10BF
L_0082:
    lda #$FF ; $10C1
L_0084:
    rts ; $10C3
L_0085:
    lda a:$C08C,x ; $10C4
L_0088:
    bpl L_0085 ; $10C7
L_008A:
    cmp #$D7 ; $10C9
L_008C:
    bne L_007B ; $10CB
L_008E:
    lda a:$C08C,x ; $10CD
L_0091:
    bpl L_008E ; $10D0
L_0093:
    cmp #$D5 ; $10D2
L_0095:
    bne L_007B ; $10D4
L_0097:
    jmp ($1071) ; $10D6
L_009A:
; jump-vector — Read by reviewed JMP indirect; stored target $125D. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $5D,$12
L_009C:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_009D:
    cmp #$03 ; $10DC
L_009F:
    jmp ($1334) ; $10DE
L_00A2:
; jump-vector — Read by reviewed JMP indirect; stored target $13A2. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $A2,$13
L_00A4:
; obfuscation-delimiter — $AD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $AD
L_00A5:
    lda a:$C088,x ; $10E4
L_00A8:
    jmp ($125A) ; $10E7
L_00AB:
; jump-vector — Read by reviewed JMP indirect; stored target $10AB. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $AB,$10
L_00AD:
; obfuscation-delimiter — $E6 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $E6
L_00AE:
    lda #$01 ; $10ED
L_00B0:
    jmp ($1262) ; $10EF
L_00B3:
; jump-vector — Read by reviewed JMP indirect; stored target $1133. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $33,$11
L_00B5:
; obfuscation-delimiter — $D0 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $D0
L_00B6:
    jmp ($13BB) ; $10F5
L_00B9:
; jump-vector — Read by reviewed JMP indirect; stored target $136C. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $6C,$13
L_00BB:
; obfuscation-delimiter — $CD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $CD
L_00BC:
    asl a ; $10FB
L_00BD:
    jmp ($1293) ; $10FC
L_00C0:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_00C1:
; jump-vector — Read by reviewed JMP indirect; stored target $142B. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $2B,$14
L_00C3:
    asl a ; $1102
L_00C4:
    ora $00 ; $1103
L_00C6:
    jmp ($1345) ; $1105
L_00C9:
; jump-vector — Read by reviewed JMP indirect; stored target $12C5. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $C5,$12
L_00CB:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_00CC:
    jmp L_00EB ; $110B
L_00CF:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_00D0:
    ldx $01 ; $110F
L_00D2:
    lda a:$C08A,x ; $1111
L_00D5:
    lda a:$C089,x ; $1114
L_00D8:
    ldy #$04 ; $1117
L_00DA:
    lda #$FF ; $1119
L_00DC:
    jsr a:$FCA8 ; $111B
L_00DF:
    dey ; $111E
L_00E0:
    bne L_00DA ; $111F
L_00E2:
    rts ; $1121
L_00E3:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_00E4:
    lda a:$C08D,x ; $1123
L_00E7:
    jmp L_0052 ; $1126
L_00EA:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_00EB:
    lda a:$C083 ; $112A
L_00EE:
    jmp ($13DB) ; $112D
L_00F1:
; jump-vector — Read by reviewed JMP indirect; stored target $14BA. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $BA,$14
L_00F3:
; obfuscation-delimiter — $20 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $20
L_00F4:
    lda a:$15F2 ; $1133
L_00F7:
    jmp ($1223) ; $1136
L_00FA:
; jump-vector — Read by reviewed JMP indirect; stored target $15A2. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $A2,$15
L_00FC:
; obfuscation-delimiter — $6D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6D
L_00FD:
    lda a:$C08C,x ; $113C
L_0100:
    bpl L_00FD ; $113F
L_0102:
    cmp #$FF ; $1141
L_0104:
    bne L_010D ; $1143
L_0106:
    iny ; $1145
L_0107:
    bne L_00FD ; $1146
L_0109:
    inc $02 ; $1148
L_010B:
    bne L_00FD ; $114A
L_010D:
    jmp ($10A8) ; $114C
L_0110:
; jump-vector — Read by reviewed JMP indirect; stored target $12B7. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $B7,$12
L_0112:
; obfuscation-delimiter — $8D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $8D
L_0113:
    and #$55 ; $1152
L_0115:
    sta $00 ; $1154
L_0117:
    jmp ($12D8) ; $1156
L_011A:
; jump-vector — Read by reviewed JMP indirect; stored target $1217. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $17,$12
L_011C:
; obfuscation-delimiter — $84 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $84
L_011D:
    lda a:$15F4 ; $115C
L_0120:
    jmp ($130A) ; $115F
L_0123:
; jump-vector — Read by reviewed JMP indirect; stored target $14D7. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $D7,$14
L_0125:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_0126:
    jmp ($15CA) ; $1165
L_0129:
; jump-vector — Read by reviewed JMP indirect; stored target $1176. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $76,$11
L_012B:
; obfuscation-delimiter — $AD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $AD
L_012C:
    sta $06 ; $116B
L_012E:
    lda a:$15F5 ; $116D
L_0131:
    jmp ($10B1) ; $1170
L_0134:
; jump-vector — Read by reviewed JMP indirect; stored target $1226. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $26,$12
L_0136:
; obfuscation-delimiter — $E6 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $E6
L_0137:
    lda $06 ; $1176
L_0139:
    jmp ($15D2) ; $1178
L_013C:
; jump-vector — Read by reviewed JMP indirect; stored target $15D5. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $D5,$15
L_013E:
; obfuscation-delimiter — $D0 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $D0
L_013F:
    bcs L_0145 ; $117E
L_0141:
    jmp ($15DF) ; $1180
L_0144:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_0145:
    bit a:$15F9 ; $1184
L_0148:
    bmi L_014D ; $1187
L_014A:
    jmp ($15E1) ; $1189
L_014D:
    jmp ($14F2) ; $118C
L_0150:
; jump-vector — Read by reviewed JMP indirect; stored target $1051. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $51,$10
L_0152:
; obfuscation-delimiter — $CD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $CD
L_0153:
    tya ; $1192
L_0154:
    jmp ($1301) ; $1193
L_0157:
; jump-vector — Read by reviewed JMP indirect; stored target $15B2. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $B2,$15
L_0159:
; obfuscation-delimiter — $4C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $4C
L_015A:
    lda #$FF ; $1199
L_015C:
    rts ; $119B
L_015D:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_015E:
    lda #$50 ; $119D
L_0160:
    sta a:$047E ; $119F
L_0163:
    jsr L_0197 ; $11A2
L_0166:
    lda a:$047E ; $11A5
L_0169:
    bne L_0163 ; $11A8
L_016B:
    rts ; $11AA
L_016C:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_016D:
    jsr L_018D ; $11AC
L_0170:
    pla ; $11AF
L_0171:
    cmp a:$047E ; $11B0
L_0174:
    beq L_0180 ; $11B3
L_0176:
    pha ; $11B5
L_0177:
    bcs L_016D ; $11B6
L_0179:
    jsr L_0186 ; $11B8
L_017C:
    jmp L_0170 ; $11BB
L_017F:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_0180:
    lda #$61 ; $11BF
L_0182:
    jmp a:$FCA8 ; $11C1
L_0185:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_0186:
    jsr L_0197 ; $11C5
L_0189:
    jmp L_0197 ; $11C8
L_018C:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_018D:
    jsr L_0190 ; $11CC
L_0190:
    inc a:$047E ; $11CF
L_0193:
    jmp L_019A ; $11D2
L_0196:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_0197:
    dec a:$047E ; $11D6
L_019A:
    lda a:$047E ; $11D9
L_019D:
    and #$03 ; $11DC
L_019F:
    asl a ; $11DE
L_01A0:
    ora $01 ; $11DF
L_01A2:
    tay ; $11E1
L_01A3:
    ldx $01 ; $11E2
L_01A5:
    lda a:$C080,x ; $11E4
L_01A8:
    lda a:$C082,x ; $11E7
L_01AB:
    lda a:$C084,x ; $11EA
L_01AE:
    lda a:$C086,x ; $11ED
L_01B1:
    lda a:$C081,y ; $11F0
L_01B4:
    lda #$56 ; $11F3
L_01B6:
    jmp a:$FCA8 ; $11F5
L_01B9:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_01BA:
    jmp ($1233) ; $11F9
L_01BD:
; jump-vector — Read by reviewed JMP indirect; stored target $1471. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $71,$14
L_01BF:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_01C0:
    clc ; $11FF
L_01C1:
    jmp ($129A) ; $1200
L_01C4:
; jump-vector — Read by reviewed JMP indirect; stored target $1514. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $14,$15
L_01C6:
; obfuscation-delimiter — $20 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $20
L_01C7:
    jmp ($104E) ; $1206
L_01CA:
; jump-vector — Read by reviewed JMP indirect; stored target $14B1. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $B1,$14
L_01CC:
; obfuscation-delimiter — $6D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6D
L_01CD:
    rts ; $120C
L_01CE:
; obfuscation-delimiter — $AD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $AD
L_01CF:
; xor-constant — EOR absolute at body offsets $03B3 and $03E6 reads this $2C constant.
    .byte $2C
L_01D0:
    lda #$00 ; $120F
L_01D2:
    jmp ($13CC) ; $1211
L_01D5:
; jump-vector — Read by reviewed JMP indirect; stored target $1220. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $20,$12
L_01D7:
; obfuscation-delimiter — $8D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $8D
L_01D8:
    jsr L_0171 ; $1217
L_01DB:
    jmp ($1173) ; $121A
L_01DE:
; jump-vector — Read by reviewed JMP indirect; stored target $13DE. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $DE,$13
L_01E0:
; obfuscation-delimiter — $84 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $84
L_01E1:
    jmp ($1405) ; $1220
L_01E4:
; jump-vector — Read by reviewed JMP indirect; stored target $1152. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $52,$11
L_01E6:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_01E7:
    lda #$03 ; $1226
L_01E9:
    jmp ($156A) ; $1228
L_01EC:
; jump-vector — Read by reviewed JMP indirect; stored target $1296. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $96,$12
L_01EE:
; obfuscation-delimiter — $AD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $AD
L_01EF:
    lda $04 ; $122E
L_01F1:
    jmp ($158E) ; $1230
L_01F4:
; jump-vector — Read by reviewed JMP indirect; stored target $14AB. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $AB,$14
L_01F6:
; obfuscation-delimiter — $E6 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $E6
L_01F7:
    jsr EXT_L_05FC ; $1236
L_01FA:
    jmp ($12E0) ; $1239
L_01FD:
; jump-vector — Read by reviewed JMP indirect; stored target $12A9. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $A9,$12
L_01FF:
; obfuscation-delimiter — $D0 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $D0
L_0200:
    pha ; $123F
L_0201:
    jmp ($1168) ; $1240
L_0204:
; jump-vector — Read by reviewed JMP indirect; stored target $14C9. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $C9,$14
L_0206:
; obfuscation-delimiter — $CD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $CD
L_0207:
    jmp ($1251) ; $1246
L_020A:
; jump-vector — Read by reviewed JMP indirect; stored target $1586. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $86,$15
L_020C:
; obfuscation-delimiter — $4C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $4C
L_020D:
    adc #$00 ; $124C
L_020F:
    jmp ($15AF) ; $124E
L_0212:
; jump-vector — Read by reviewed JMP indirect; stored target $12DB. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $DB,$12
L_0214:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_0215:
    lda a:$C088,x ; $1254
L_0218:
    jmp ($139F) ; $1257
L_021B:
; jump-vector — Read by reviewed JMP indirect; stored target $1236. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $36,$12
L_021D:
; obfuscation-delimiter — $20 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $20
L_021E:
    sbc $04 ; $125D
L_0220:
    jmp ($1313) ; $125F
L_0223:
; jump-vector — Read by reviewed JMP indirect; stored target $127D. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $7D,$12
L_0225:
; obfuscation-delimiter — $6D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6D
L_0226:
    ldx #$60 ; $1265
L_0228:
    stx $01 ; $1267
L_022A:
    lda a:$C081 ; $1269
L_022D:
    jsr L_00D0 ; $126C
L_0230:
    ldy #$00 ; $126F
L_0232:
    sty a:$15F8 ; $1271
L_0235:
    ldy a:$15F8 ; $1274
L_0238:
    jmp ($1456) ; $1277
L_023B:
; jump-vector — Read by reviewed JMP indirect; stored target $13F9. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $F9,$13
L_023D:
; obfuscation-delimiter — $8D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $8D
L_023E:
    sta a:$4001 ; $127D
L_0241:
    jmp ($13A7) ; $1280
L_0244:
; jump-vector — Read by reviewed JMP indirect; stored target $13E6. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $E6,$13
L_0246:
; obfuscation-delimiter — $84 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $84
L_0247:
    lda a:$C08C,x ; $1286
L_024A:
    bmi L_0247 ; $1289
L_024C:
    lda a:$C08C,x ; $128B
L_024F:
    bpl L_024C ; $128E
L_0251:
    jmp ($15A8) ; $1290
L_0254:
; jump-vector — Read by reviewed JMP indirect; stored target $15CD. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $CD,$15
L_0256:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_0257:
    pha ; $1296
L_0258:
    jmp ($1100) ; $1297
L_025B:
; jump-vector — Read by reviewed JMP indirect; stored target $1408. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $08,$14
L_025D:
; obfuscation-delimiter — $AD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $AD
L_025E:
    jmp ($13F6) ; $129D
L_0261:
; jump-vector — Read by reviewed JMP indirect; stored target $1304. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $04,$13
L_0263:
; obfuscation-delimiter — $E6 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $E6
L_0264:
    jmp ($1562) ; $12A3
L_0267:
; jump-vector — Read by reviewed JMP indirect; stored target $1401. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $01,$14
L_0269:
; obfuscation-delimiter — $D0 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $D0
L_026A:
    jmp ($1130) ; $12A9
L_026D:
; jump-vector — Read by reviewed JMP indirect; stored target $1192. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $92,$11
L_026F:
; obfuscation-delimiter — $CD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $CD
L_0270:
    sta $04 ; $12AF
L_0272:
    jmp ($121D) ; $12B1
L_0275:
; jump-vector — Read by reviewed JMP indirect; stored target $10FB. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $FB,$10
L_0277:
; obfuscation-delimiter — $4C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $4C
L_0278:
    lda a:$1352,y ; $12B7
L_027B:
    bpl L_0280 ; $12BA
L_027D:
    jmp ($1046) ; $12BC
L_0280:
    jmp ($1369) ; $12BF
L_0283:
; jump-vector — Read by reviewed JMP indirect; stored target $1286. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $86,$12
L_0285:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_0286:
    bcc L_028B ; $12C5
L_0288:
    jmp ($1044) ; $12C7
L_028B:
    lda #$00 ; $12CA
L_028D:
    rts ; $12CC
L_028E:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_028F:
    jmp ($153D) ; $12CE
L_0292:
; jump-vector — Read by reviewed JMP indirect; stored target $1063. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $63,$10
L_0294:
; obfuscation-delimiter — $20 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $20
L_0295:
    asl a ; $12D4
L_0296:
    jmp ($1159) ; $12D5
L_0299:
; jump-vector — Read by reviewed JMP indirect; stored target $1418. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $18,$14
L_029B:
; obfuscation-delimiter — $6D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6D
L_029C:
    ldx $01 ; $12DB
L_029E:
    jmp ($1398) ; $12DD
L_02A1:
; jump-vector — Read by reviewed JMP indirect; stored target $1550. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $50,$15
L_02A3:
; obfuscation-delimiter — $8D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $8D
L_02A4:
    sta $03 ; $12E3
L_02A6:
    jmp ($1249) ; $12E5
L_02A9:
; jump-vector — Read by reviewed JMP indirect; stored target $106B. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $6B,$10
L_02AB:
; obfuscation-delimiter — $84 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $84
L_02AC:
    sta a:$15E7 ; $12EB
L_02AF:
    jmp ($117B) ; $12EE
L_02B2:
; jump-vector — Read by reviewed JMP indirect; stored target $12AF. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $AF,$12
L_02B4:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_02B5:
    sta $04 ; $12F4
L_02B7:
    jmp ($14C6) ; $12F6
L_02BA:
; jump-vector — Read by reviewed JMP indirect; stored target $1575. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $75,$15
L_02BC:
; obfuscation-delimiter — $AD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $AD
L_02BD:
    sta $02 ; $12FC
L_02BF:
    jmp ($1068) ; $12FE
L_02C2:
; jump-vector — Read by reviewed JMP indirect; stored target $11FF. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $FF,$11
L_02C4:
; obfuscation-delimiter — $E6 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $E6
L_02C5:
    eor a:$151F ; $1304
L_02C8:
    jmp ($1283) ; $1307
L_02CB:
; jump-vector — Read by reviewed JMP indirect; stored target $10A2. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $A2,$10
L_02CD:
; obfuscation-delimiter — $D0 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $D0
L_02CE:
    sta a:$4009 ; $130D
L_02D1:
    jmp ($1420) ; $1310
L_02D4:
; jump-vector — Read by reviewed JMP indirect; stored target $123F. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $3F,$12
L_02D6:
; obfuscation-delimiter — $CD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $CD
L_02D7:
    sbc $02 ; $1316
L_02D9:
    jmp ($1323) ; $1318
L_02DC:
; jump-vector — Read by reviewed JMP indirect; stored target $1540. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $40,$15
L_02DE:
; obfuscation-delimiter — $4C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $4C
L_02DF:
    ldy #$05 ; $131E
L_02E1:
    jmp ($14A8) ; $1320
L_02E4:
; jump-vector — Read by reviewed JMP indirect; stored target $1434. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $34,$14
L_02E6:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_02E7:
    lda #$10 ; $1326
L_02E9:
    jmp ($1431) ; $1328
L_02EC:
; jump-vector — Read by reviewed JMP indirect; stored target $1165. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $65,$11
L_02EE:
; obfuscation-delimiter — $20 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $20
L_02EF:
    sta a:$4010 ; $132E
L_02F2:
    jmp ($145E) ; $1331
L_02F5:
; jump-vector — Read by reviewed JMP indirect; stored target $117E. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $7E,$11
L_02F7:
; obfuscation-delimiter — $6D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6D
L_02F8:
    lda #$19 ; $1337
L_02FA:
    jmp ($146E) ; $1339
L_02FD:
; jump-vector — Read by reviewed JMP indirect; stored target $1265. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $65,$12
L_02FF:
; obfuscation-delimiter — $8D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $8D
L_0300:
    sta a:$4019 ; $133F
L_0303:
    jmp ($154D) ; $1342
L_0306:
; jump-vector — Read by reviewed JMP indirect; stored target $13D5. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $D5,$13
L_0308:
; obfuscation-delimiter — $84 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $84
L_0309:
    lda a:$C08B ; $1348
L_030C:
    jmp ($1559) ; $134B
L_030F:
; jump-vector — Read by reviewed JMP indirect; stored target $1363. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $63,$13
L_0311:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_0312:
    rts ; $1351
L_0313:
; track-sequence — LDA indexed at $02B7 reads $22,$23,$22,$FF; negative final byte selects failure, the others supply seek tracks.
    .byte $22,$23,$22,$FF
L_0317:
; obfuscation-delimiter — $AD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $AD
.assert * - component_start = 792, error, "Raw component size"
