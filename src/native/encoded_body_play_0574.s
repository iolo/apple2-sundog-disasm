; Evidence: docs/encoded-native-overlay-body.md
EXT_L_020F = component_start + (-869)
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
L_0000:
; obfuscation-delimiter — $AD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $AD
L_0001:
    cmp a:$11E8,y ; $1175
L_0004:
    beq L_000C ; $1178
L_0006:
    dey ; $117A
L_0007:
    bpl L_0001 ; $117B
L_0009:
    lda #$04 ; $117D
L_000B:
    rts ; $117F
L_000C:
    jmp ($0EAC) ; $1180
L_000F:
; jump-vector — Read by reviewed JMP indirect; stored target $0CDC. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $DC,$0C
L_0011:
; obfuscation-delimiter — $E6 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $E6
L_0012:
    lda a:$C08C,x ; $1186
L_0015:
    bpl L_0012 ; $1189
L_0017:
    jmp ($0E03) ; $118B
L_001A:
; jump-vector — Read by reviewed JMP indirect; stored target $0F9B. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $9B,$0F
L_001C:
; obfuscation-delimiter — $D0 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $D0
L_001D:
    lda a:$C08C,x ; $1191
L_0020:
    bpl L_001D ; $1194
L_0022:
    sta a:$11F0,y ; $1196
L_0025:
    dey ; $1199
L_0026:
    bne L_001D ; $119A
L_0028:
    jmp ($10FB) ; $119C
L_002B:
; jump-vector — Read by reviewed JMP indirect; stored target $10FE. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $FE,$10
L_002D:
; obfuscation-delimiter — $CD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $CD
L_002E:
    beq L_0031 ; $11A2
L_0030:
    rts ; $11A4
L_0031:
    jmp ($0C79) ; $11A5
L_0034:
; jump-vector — Read by reviewed JMP indirect; stored target $0EA3. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $A3,$0E
L_0036:
; obfuscation-delimiter — $4C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $4C
L_0037:
    pla ; $11AB
L_0038:
    jmp ($10A2) ; $11AC
L_003B:
; jump-vector — Read by reviewed JMP indirect; stored target $0EFC. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $FC,$0E
L_003D:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_003E:
    lda a:$C08E,x ; $11B2
L_0041:
    lda a:$C08C,x ; $11B5
L_0044:
    bmi L_0041 ; $11B8
L_0046:
    lda a:$C08C,x ; $11BA
L_0049:
    bpl L_0046 ; $11BD
L_004B:
    jmp ($10AE) ; $11BF
L_004E:
; jump-vector — Read by reviewed JMP indirect; stored target $0E06. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $06,$0E
L_0050:
; obfuscation-delimiter — $20 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $20
L_0051:
    rol $02 ; $11C5
L_0053:
    jmp ($0EB4) ; $11C7
L_0056:
; jump-vector — Read by reviewed JMP indirect; stored target $0E2E. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $2E,$0E
L_0058:
; obfuscation-delimiter — $6D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6D
L_0059:
    rol $02 ; $11CD
L_005B:
    jmp ($0EA6) ; $11CF
L_005E:
; jump-vector — Read by reviewed JMP indirect; stored target $0F16. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $16,$0F
L_0060:
; obfuscation-delimiter — $8D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $8D
L_0061:
    jsr EXT_L_020F ; $11D5
L_0064:
    jmp ($0E43) ; $11D8
.assert * - component_start = 103, error, "Raw component size"
