; Evidence: docs/encoded-native-overlay-body.md
EXT_L_05FC = component_start + (1469)
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
L_0000:
; obfuscation-delimiter — $EA decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $EA
L_0001:
; jump-vector — Read by reviewed JMP indirect; stored target $0E74. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $74,$0E
L_0003:
; jump-vector — Read by reviewed JMP indirect; stored target $0FC6. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $C6,$0F
L_0005:
; jump-vector — Read by reviewed JMP indirect; stored target $0E20. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $20,$0E
L_0007:
; jump-vector — Read by reviewed JMP indirect; stored target $1105. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $05,$11
L_0009:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_000A:
    ldy #$40 ; $0C49
L_000C:
    jmp ($10BD) ; $0C4B
L_000F:
; jump-vector — Read by reviewed JMP indirect; stored target $10A5. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $A5,$10
L_0011:
; obfuscation-delimiter — $AD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $AD
L_0012:
    bne L_001A ; $0C51
L_0014:
    jsr L_015E ; $0C53
L_0017:
    jmp ($0C40) ; $0C56
L_001A:
    jmp ($11E5) ; $0C59
L_001D:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_001E:
    jmp ($0E14) ; $0C5D
L_0021:
; jump-vector — Read by reviewed JMP indirect; stored target $0E4C. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $4C,$0E
L_0023:
; obfuscation-delimiter — $E6 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $E6
L_0024:
    ldx $01 ; $0C63
L_0026:
    jmp ($0DFC) ; $0C65
L_0029:
; jump-vector — Read by reviewed JMP indirect; stored target $116D. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $6D,$11
L_002B:
; obfuscation-delimiter — $D0 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $D0
L_002C:
    sta a:$1801 ; $0C6B
L_002F:
    jmp ($0FEC) ; $0C6E
L_0032:
; jump-vector — Read by reviewed JMP indirect; stored target $0F1E. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $1E,$0F
L_0034:
; obfuscation-delimiter — $CD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $CD
L_0035:
    lda #$48 ; $0C74
L_0037:
    jmp ($1015) ; $0C76
L_003A:
; jump-vector — Read by reviewed JMP indirect; stored target $0F93. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $93,$0F
L_003C:
; obfuscation-delimiter — $4C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $4C
L_003D:
    jmp ($0D96) ; $0C7C
L_0040:
; jump-vector — Read by reviewed JMP indirect; stored target $0D3C. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $3C,$0D
L_0042:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_0043:
    eor #$22 ; $0C82
L_0045:
    sta $05 ; $0C84
L_0047:
    lda a:$C08C,x ; $0C86
L_004A:
    bpl L_0047 ; $0C89
L_004C:
    jmp L_00E4 ; $0C8B
L_004F:
; entry-address — Stored $0DF9/$11F9 body-entry address, matching the loader call and the relocated counterpart.
    .byte $F9,$0D
L_0051:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_0052:
    lda a:$C08E,x ; $0C91
L_0055:
    jmp ($0EC2) ; $0C94
L_0058:
; jump-vector — Read by reviewed JMP indirect; stored target $0D02. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $02,$0D
L_005A:
; obfuscation-delimiter — $20 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $20
L_005B:
    sty $05 ; $0C9A
L_005D:
    jmp ($0ED1) ; $0C9C
L_0060:
; jump-vector — Read by reviewed JMP indirect; stored target $109D. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $9D,$10
L_0062:
; obfuscation-delimiter — $6D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6D
L_0063:
    and #$55 ; $0CA2
L_0065:
    asl a ; $0CA4
L_0066:
    jmp ($0FD2) ; $0CA5
L_0069:
; jump-vector — Read by reviewed JMP indirect; stored target $0EE3. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $E3,$0E
L_006B:
; obfuscation-delimiter — $8D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $8D
L_006C:
    sta a:$11F9 ; $0CAB
L_006F:
    jmp ($0C9F) ; $0CAE
L_0072:
; jump-vector — Read by reviewed JMP indirect; stored target $0FEF. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $EF,$0F
L_0074:
; obfuscation-delimiter — $84 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $84
L_0075:
    bne L_0082 ; $0CB4
L_0077:
    ldy #$40 ; $0CB6
L_0079:
    sty $05 ; $0CB8
L_007B:
    dey ; $0CBA
L_007C:
    bne L_0085 ; $0CBB
L_007E:
    dec $05 ; $0CBD
L_0080:
    bne L_0085 ; $0CBF
L_0082:
    lda #$FF ; $0CC1
L_0084:
    rts ; $0CC3
L_0085:
    lda a:$C08C,x ; $0CC4
L_0088:
    bpl L_0085 ; $0CC7
L_008A:
    cmp #$D7 ; $0CC9
L_008C:
    bne L_007B ; $0CCB
L_008E:
    lda a:$C08C,x ; $0CCD
L_0091:
    bpl L_008E ; $0CD0
L_0093:
    cmp #$D5 ; $0CD2
L_0095:
    bne L_007B ; $0CD4
L_0097:
    jmp ($0C71) ; $0CD6
L_009A:
; jump-vector — Read by reviewed JMP indirect; stored target $0E5D. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $5D,$0E
L_009C:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_009D:
    cmp #$03 ; $0CDC
L_009F:
    jmp ($0F34) ; $0CDE
L_00A2:
; jump-vector — Read by reviewed JMP indirect; stored target $0FA2. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $A2,$0F
L_00A4:
; obfuscation-delimiter — $AD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $AD
L_00A5:
    lda a:$C088,x ; $0CE4
L_00A8:
    jmp ($0E5A) ; $0CE7
L_00AB:
; jump-vector — Read by reviewed JMP indirect; stored target $0CAB. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $AB,$0C
L_00AD:
; obfuscation-delimiter — $E6 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $E6
L_00AE:
    lda #$04 ; $0CED
L_00B0:
    jmp ($0E62) ; $0CEF
L_00B3:
; jump-vector — Read by reviewed JMP indirect; stored target $0D33. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $33,$0D
L_00B5:
; obfuscation-delimiter — $D0 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $D0
L_00B6:
    jmp ($0FBB) ; $0CF5
L_00B9:
; jump-vector — Read by reviewed JMP indirect; stored target $0F6C. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $6C,$0F
L_00BB:
; obfuscation-delimiter — $CD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $CD
L_00BC:
    asl a ; $0CFB
L_00BD:
    jmp ($0E93) ; $0CFC
L_00C0:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_00C1:
; jump-vector — Read by reviewed JMP indirect; stored target $102B. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $2B,$10
L_00C3:
    asl a ; $0D02
L_00C4:
    ora $00 ; $0D03
L_00C6:
    jmp ($0F45) ; $0D05
L_00C9:
; jump-vector — Read by reviewed JMP indirect; stored target $0EC5. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $C5,$0E
L_00CB:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_00CC:
    jmp L_00EB ; $0D0B
L_00CF:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_00D0:
    ldx $01 ; $0D0F
L_00D2:
    lda a:$C08A,x ; $0D11
L_00D5:
    lda a:$C089,x ; $0D14
L_00D8:
    ldy #$04 ; $0D17
L_00DA:
    lda #$FF ; $0D19
L_00DC:
    jsr a:$FCA8 ; $0D1B
L_00DF:
    dey ; $0D1E
L_00E0:
    bne L_00DA ; $0D1F
L_00E2:
    rts ; $0D21
L_00E3:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_00E4:
    lda a:$C08D,x ; $0D23
L_00E7:
    jmp L_0052 ; $0D26
L_00EA:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_00EB:
    lda a:$C083 ; $0D2A
L_00EE:
    jmp ($0FDB) ; $0D2D
L_00F1:
; jump-vector — Read by reviewed JMP indirect; stored target $10BA. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $BA,$10
L_00F3:
; obfuscation-delimiter — $20 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $20
L_00F4:
    lda a:$11F2 ; $0D33
L_00F7:
    jmp ($0E23) ; $0D36
L_00FA:
; jump-vector — Read by reviewed JMP indirect; stored target $11A2. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $A2,$11
L_00FC:
; obfuscation-delimiter — $6D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6D
L_00FD:
    lda a:$C08C,x ; $0D3C
L_0100:
    bpl L_00FD ; $0D3F
L_0102:
    cmp #$FF ; $0D41
L_0104:
    bne L_010D ; $0D43
L_0106:
    iny ; $0D45
L_0107:
    bne L_00FD ; $0D46
L_0109:
    inc $02 ; $0D48
L_010B:
    bne L_00FD ; $0D4A
L_010D:
    jmp ($0CA8) ; $0D4C
L_0110:
; jump-vector — Read by reviewed JMP indirect; stored target $0EB7. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $B7,$0E
L_0112:
; obfuscation-delimiter — $8D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $8D
L_0113:
    and #$55 ; $0D52
L_0115:
    sta $00 ; $0D54
L_0117:
    jmp ($0ED8) ; $0D56
L_011A:
; jump-vector — Read by reviewed JMP indirect; stored target $0E17. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $17,$0E
L_011C:
; obfuscation-delimiter — $84 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $84
L_011D:
    lda a:$11F4 ; $0D5C
L_0120:
    jmp ($0F0A) ; $0D5F
L_0123:
; jump-vector — Read by reviewed JMP indirect; stored target $10D7. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $D7,$10
L_0125:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_0126:
    jmp ($11CA) ; $0D65
L_0129:
; jump-vector — Read by reviewed JMP indirect; stored target $0D76. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $76,$0D
L_012B:
; obfuscation-delimiter — $AD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $AD
L_012C:
    sta $06 ; $0D6B
L_012E:
    lda a:$11F5 ; $0D6D
L_0131:
    jmp ($0CB1) ; $0D70
L_0134:
; jump-vector — Read by reviewed JMP indirect; stored target $0E26. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $26,$0E
L_0136:
; obfuscation-delimiter — $E6 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $E6
L_0137:
    lda $06 ; $0D76
L_0139:
    jmp ($11D2) ; $0D78
L_013C:
; jump-vector — Read by reviewed JMP indirect; stored target $11D5. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $D5,$11
L_013E:
; obfuscation-delimiter — $D0 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $D0
L_013F:
    bcs L_0145 ; $0D7E
L_0141:
    jmp ($11DF) ; $0D80
L_0144:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_0145:
    bit a:$11F9 ; $0D84
L_0148:
    bmi L_014D ; $0D87
L_014A:
    jmp ($11E1) ; $0D89
L_014D:
    jmp ($10F2) ; $0D8C
L_0150:
; jump-vector — Read by reviewed JMP indirect; stored target $0C51. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $51,$0C
L_0152:
; obfuscation-delimiter — $CD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $CD
L_0153:
    tya ; $0D92
L_0154:
    jmp ($0F01) ; $0D93
L_0157:
; jump-vector — Read by reviewed JMP indirect; stored target $11B2. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $B2,$11
L_0159:
; obfuscation-delimiter — $4C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $4C
L_015A:
    lda #$FF ; $0D99
L_015C:
    rts ; $0D9B
L_015D:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_015E:
    lda #$50 ; $0D9D
L_0160:
    sta a:$047E ; $0D9F
L_0163:
    jsr L_0197 ; $0DA2
L_0166:
    lda a:$047E ; $0DA5
L_0169:
    bne L_0163 ; $0DA8
L_016B:
    rts ; $0DAA
L_016C:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_016D:
    jsr L_018D ; $0DAC
L_0170:
    pla ; $0DAF
L_0171:
    cmp a:$047E ; $0DB0
L_0174:
    beq L_0180 ; $0DB3
L_0176:
    pha ; $0DB5
L_0177:
    bcs L_016D ; $0DB6
L_0179:
    jsr L_0186 ; $0DB8
L_017C:
    jmp L_0170 ; $0DBB
L_017F:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_0180:
    lda #$61 ; $0DBF
L_0182:
    jmp a:$FCA8 ; $0DC1
L_0185:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_0186:
    jsr L_0197 ; $0DC5
L_0189:
    jmp L_0197 ; $0DC8
L_018C:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_018D:
    jsr L_0190 ; $0DCC
L_0190:
    inc a:$047E ; $0DCF
L_0193:
    jmp L_019A ; $0DD2
L_0196:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_0197:
    dec a:$047E ; $0DD6
L_019A:
    lda a:$047E ; $0DD9
L_019D:
    and #$03 ; $0DDC
L_019F:
    asl a ; $0DDE
L_01A0:
    ora $01 ; $0DDF
L_01A2:
    tay ; $0DE1
L_01A3:
    ldx $01 ; $0DE2
L_01A5:
    lda a:$C080,x ; $0DE4
L_01A8:
    lda a:$C082,x ; $0DE7
L_01AB:
    lda a:$C084,x ; $0DEA
L_01AE:
    lda a:$C086,x ; $0DED
L_01B1:
    lda a:$C081,y ; $0DF0
L_01B4:
    lda #$56 ; $0DF3
L_01B6:
    jmp a:$FCA8 ; $0DF5
L_01B9:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_01BA:
    jmp ($0E33) ; $0DF9
L_01BD:
; jump-vector — Read by reviewed JMP indirect; stored target $1071. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $71,$10
L_01BF:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_01C0:
    clc ; $0DFF
L_01C1:
    jmp ($0E9A) ; $0E00
L_01C4:
; jump-vector — Read by reviewed JMP indirect; stored target $1114. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $14,$11
L_01C6:
; obfuscation-delimiter — $20 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $20
L_01C7:
    jmp ($0C4E) ; $0E06
L_01CA:
; jump-vector — Read by reviewed JMP indirect; stored target $10B1. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $B1,$10
L_01CC:
; obfuscation-delimiter — $6D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6D
L_01CD:
    rts ; $0E0C
L_01CE:
; obfuscation-delimiter — $AD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $AD
L_01CF:
; xor-constant — EOR absolute at body offsets $03B3 and $03E6 reads this $2C constant.
    .byte $2C
L_01D0:
    lda #$00 ; $0E0F
L_01D2:
    jmp ($0FCC) ; $0E11
L_01D5:
; jump-vector — Read by reviewed JMP indirect; stored target $0E20. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $20,$0E
L_01D7:
; obfuscation-delimiter — $8D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $8D
L_01D8:
    jsr L_0171 ; $0E17
L_01DB:
    jmp ($0D73) ; $0E1A
L_01DE:
; jump-vector — Read by reviewed JMP indirect; stored target $0FDE. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $DE,$0F
L_01E0:
; obfuscation-delimiter — $84 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $84
L_01E1:
    jmp ($1005) ; $0E20
L_01E4:
; jump-vector — Read by reviewed JMP indirect; stored target $0D52. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $52,$0D
L_01E6:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_01E7:
    lda #$03 ; $0E26
L_01E9:
    jmp ($116A) ; $0E28
L_01EC:
; jump-vector — Read by reviewed JMP indirect; stored target $0E96. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $96,$0E
L_01EE:
; obfuscation-delimiter — $AD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $AD
L_01EF:
    lda $04 ; $0E2E
L_01F1:
    jmp ($118E) ; $0E30
L_01F4:
; jump-vector — Read by reviewed JMP indirect; stored target $10AB. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $AB,$10
L_01F6:
; obfuscation-delimiter — $E6 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $E6
L_01F7:
    jsr EXT_L_05FC ; $0E36
L_01FA:
    jmp ($0EE0) ; $0E39
L_01FD:
; jump-vector — Read by reviewed JMP indirect; stored target $0EA9. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $A9,$0E
L_01FF:
; obfuscation-delimiter — $D0 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $D0
L_0200:
    pha ; $0E3F
L_0201:
    jmp ($0D68) ; $0E40
L_0204:
; jump-vector — Read by reviewed JMP indirect; stored target $10C9. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $C9,$10
L_0206:
; obfuscation-delimiter — $CD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $CD
L_0207:
    jmp ($0E51) ; $0E46
L_020A:
; jump-vector — Read by reviewed JMP indirect; stored target $1186. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $86,$11
L_020C:
; obfuscation-delimiter — $4C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $4C
L_020D:
    adc #$00 ; $0E4C
L_020F:
    jmp ($11AF) ; $0E4E
L_0212:
; jump-vector — Read by reviewed JMP indirect; stored target $0EDB. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $DB,$0E
L_0214:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_0215:
    lda a:$C088,x ; $0E54
L_0218:
    jmp ($0F9F) ; $0E57
L_021B:
; jump-vector — Read by reviewed JMP indirect; stored target $0E36. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $36,$0E
L_021D:
; obfuscation-delimiter — $20 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $20
L_021E:
    sbc $04 ; $0E5D
L_0220:
    jmp ($0F13) ; $0E5F
L_0223:
; jump-vector — Read by reviewed JMP indirect; stored target $0E7D. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $7D,$0E
L_0225:
; obfuscation-delimiter — $6D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6D
L_0226:
    ldx #$60 ; $0E65
L_0228:
    stx $01 ; $0E67
L_022A:
    lda a:$C081 ; $0E69
L_022D:
    jsr L_00D0 ; $0E6C
L_0230:
    ldy #$00 ; $0E6F
L_0232:
    sty a:$11F8 ; $0E71
L_0235:
    ldy a:$11F8 ; $0E74
L_0238:
    jmp ($1056) ; $0E77
L_023B:
; jump-vector — Read by reviewed JMP indirect; stored target $0FF9. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $F9,$0F
L_023D:
; obfuscation-delimiter — $8D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $8D
L_023E:
    sta a:$1800 ; $0E7D
L_0241:
    jmp ($0FA7) ; $0E80
L_0244:
; jump-vector — Read by reviewed JMP indirect; stored target $0FE6. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $E6,$0F
L_0246:
; obfuscation-delimiter — $84 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $84
L_0247:
    lda a:$C08C,x ; $0E86
L_024A:
    bmi L_0247 ; $0E89
L_024C:
    lda a:$C08C,x ; $0E8B
L_024F:
    bpl L_024C ; $0E8E
L_0251:
    jmp ($11A8) ; $0E90
L_0254:
; jump-vector — Read by reviewed JMP indirect; stored target $11CD. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $CD,$11
L_0256:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_0257:
    pha ; $0E96
L_0258:
    jmp ($0D00) ; $0E97
L_025B:
; jump-vector — Read by reviewed JMP indirect; stored target $1008. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $08,$10
L_025D:
; obfuscation-delimiter — $AD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $AD
L_025E:
    jmp ($0FF6) ; $0E9D
L_0261:
; jump-vector — Read by reviewed JMP indirect; stored target $0F04. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $04,$0F
L_0263:
; obfuscation-delimiter — $E6 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $E6
L_0264:
    jmp ($1162) ; $0EA3
L_0267:
; jump-vector — Read by reviewed JMP indirect; stored target $1001. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $01,$10
L_0269:
; obfuscation-delimiter — $D0 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $D0
L_026A:
    jmp ($0D30) ; $0EA9
L_026D:
; jump-vector — Read by reviewed JMP indirect; stored target $0D92. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $92,$0D
L_026F:
; obfuscation-delimiter — $CD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $CD
L_0270:
    sta $04 ; $0EAF
L_0272:
    jmp ($0E1D) ; $0EB1
L_0275:
; jump-vector — Read by reviewed JMP indirect; stored target $0CFB. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $FB,$0C
L_0277:
; obfuscation-delimiter — $4C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $4C
L_0278:
    lda a:$0F52,y ; $0EB7
L_027B:
    bpl L_0280 ; $0EBA
L_027D:
    jmp ($0C46) ; $0EBC
L_0280:
    jmp ($0F69) ; $0EBF
L_0283:
; jump-vector — Read by reviewed JMP indirect; stored target $0E86. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $86,$0E
L_0285:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_0286:
    bcc L_028B ; $0EC5
L_0288:
    jmp ($0C44) ; $0EC7
L_028B:
    lda #$00 ; $0ECA
L_028D:
    rts ; $0ECC
L_028E:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_028F:
    jmp ($113D) ; $0ECE
L_0292:
; jump-vector — Read by reviewed JMP indirect; stored target $0C63. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $63,$0C
L_0294:
; obfuscation-delimiter — $20 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $20
L_0295:
    asl a ; $0ED4
L_0296:
    jmp ($0D59) ; $0ED5
L_0299:
; jump-vector — Read by reviewed JMP indirect; stored target $1018. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $18,$10
L_029B:
; obfuscation-delimiter — $6D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6D
L_029C:
    ldx $01 ; $0EDB
L_029E:
    jmp ($0F98) ; $0EDD
L_02A1:
; jump-vector — Read by reviewed JMP indirect; stored target $1150. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $50,$11
L_02A3:
; obfuscation-delimiter — $8D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $8D
L_02A4:
    sta $03 ; $0EE3
L_02A6:
    jmp ($0E49) ; $0EE5
L_02A9:
; jump-vector — Read by reviewed JMP indirect; stored target $0C6B. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $6B,$0C
L_02AB:
; obfuscation-delimiter — $84 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $84
L_02AC:
    sta a:$11E7 ; $0EEB
L_02AF:
    jmp ($0D7B) ; $0EEE
L_02B2:
; jump-vector — Read by reviewed JMP indirect; stored target $0EAF. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $AF,$0E
L_02B4:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_02B5:
    sta $04 ; $0EF4
L_02B7:
    jmp ($10C6) ; $0EF6
L_02BA:
; jump-vector — Read by reviewed JMP indirect; stored target $1175. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $75,$11
L_02BC:
; obfuscation-delimiter — $AD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $AD
L_02BD:
    sta $02 ; $0EFC
L_02BF:
    jmp ($0C68) ; $0EFE
L_02C2:
; jump-vector — Read by reviewed JMP indirect; stored target $0DFF. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $FF,$0D
L_02C4:
; obfuscation-delimiter — $E6 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $E6
L_02C5:
    eor a:$111F ; $0F04
L_02C8:
    jmp ($0E83) ; $0F07
L_02CB:
; jump-vector — Read by reviewed JMP indirect; stored target $0CA2. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $A2,$0C
L_02CD:
; obfuscation-delimiter — $D0 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $D0
L_02CE:
    sta a:$1802 ; $0F0D
L_02D1:
    jmp ($1020) ; $0F10
L_02D4:
; jump-vector — Read by reviewed JMP indirect; stored target $0E3F. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $3F,$0E
L_02D6:
; obfuscation-delimiter — $CD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $CD
L_02D7:
    sbc $02 ; $0F16
L_02D9:
    jmp ($0F23) ; $0F18
L_02DC:
; jump-vector — Read by reviewed JMP indirect; stored target $1140. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $40,$11
L_02DE:
; obfuscation-delimiter — $4C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $4C
L_02DF:
    ldy #$05 ; $0F1E
L_02E1:
    jmp ($10A8) ; $0F20
L_02E4:
; jump-vector — Read by reviewed JMP indirect; stored target $1034. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $34,$10
L_02E6:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_02E7:
    lda #$49 ; $0F26
L_02E9:
    jmp ($1031) ; $0F28
L_02EC:
; jump-vector — Read by reviewed JMP indirect; stored target $0D65. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $65,$0D
L_02EE:
; obfuscation-delimiter — $20 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $20
L_02EF:
    sta a:$1803 ; $0F2E
L_02F2:
    jmp ($105E) ; $0F31
L_02F5:
; jump-vector — Read by reviewed JMP indirect; stored target $0D7E. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $7E,$0D
L_02F7:
; obfuscation-delimiter — $6D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6D
L_02F8:
    lda #$50 ; $0F37
L_02FA:
    jmp ($106E) ; $0F39
L_02FD:
; jump-vector — Read by reviewed JMP indirect; stored target $0E65. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $65,$0E
L_02FF:
; obfuscation-delimiter — $8D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $8D
L_0300:
    sta a:$1804 ; $0F3F
L_0303:
    jmp ($114D) ; $0F42
L_0306:
; jump-vector — Read by reviewed JMP indirect; stored target $0FD5. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $D5,$0F
L_0308:
; obfuscation-delimiter — $84 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $84
L_0309:
    lda a:$C08B ; $0F48
L_030C:
    jmp ($1159) ; $0F4B
L_030F:
; jump-vector — Read by reviewed JMP indirect; stored target $0F63. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $63,$0F
L_0311:
; obfuscation-delimiter — $A9 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $A9
L_0312:
    rts ; $0F51
L_0313:
; track-sequence — LDA indexed at $02B7 reads $22,$23,$22,$FF; negative final byte selects failure, the others supply seek tracks.
    .byte $22,$23,$22,$FF
L_0317:
; obfuscation-delimiter — $AD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $AD
.assert * - component_start = 792, error, "Raw component size"
