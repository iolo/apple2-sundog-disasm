; Evidence: docs/encoded-native-overlay-body.md
EXT_L_020F = component_start + (-869)
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
L_0000:
; obfuscation-delimiter — $AD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $AD
L_0001:
    cmp a:$15E8,y ; $1575
L_0004:
    beq L_000C ; $1578
L_0006:
    dey ; $157A
L_0007:
    bpl L_0001 ; $157B
L_0009:
    lda #$04 ; $157D
L_000B:
    rts ; $157F
L_000C:
    jmp ($12AC) ; $1580
L_000F:
; jump-vector — Read by reviewed JMP indirect; stored target $10DC. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $DC,$10
L_0011:
; obfuscation-delimiter — $E6 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $E6
L_0012:
    lda a:$C08C,x ; $1586
L_0015:
    bpl L_0012 ; $1589
L_0017:
    jmp ($1203) ; $158B
L_001A:
; jump-vector — Read by reviewed JMP indirect; stored target $139B. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $9B,$13
L_001C:
; obfuscation-delimiter — $D0 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $D0
L_001D:
    lda a:$C08C,x ; $1591
L_0020:
    bpl L_001D ; $1594
L_0022:
    sta a:$15F0,y ; $1596
L_0025:
    dey ; $1599
L_0026:
    bne L_001D ; $159A
L_0028:
    jmp ($14FB) ; $159C
L_002B:
; jump-vector — Read by reviewed JMP indirect; stored target $14FE. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $FE,$14
L_002D:
; obfuscation-delimiter — $CD decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $CD
L_002E:
    beq L_0031 ; $15A2
L_0030:
    rts ; $15A4
L_0031:
    jmp ($1079) ; $15A5
L_0034:
; jump-vector — Read by reviewed JMP indirect; stored target $12A3. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $A3,$12
L_0036:
; obfuscation-delimiter — $4C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $4C
L_0037:
    pla ; $15AB
L_0038:
    jmp ($14A2) ; $15AC
L_003B:
; jump-vector — Read by reviewed JMP indirect; stored target $12FC. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $FC,$12
L_003D:
; obfuscation-delimiter — $6C decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6C
L_003E:
    lda a:$C08E,x ; $15B2
L_0041:
    lda a:$C08C,x ; $15B5
L_0044:
    bmi L_0041 ; $15B8
L_0046:
    lda a:$C08C,x ; $15BA
L_0049:
    bpl L_0046 ; $15BD
L_004B:
    jmp ($14AE) ; $15BF
L_004E:
; jump-vector — Read by reviewed JMP indirect; stored target $1206. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $06,$12
L_0050:
; obfuscation-delimiter — $20 decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $20
L_0051:
    rol $02 ; $15C5
L_0053:
    jmp ($12B4) ; $15C7
L_0056:
; jump-vector — Read by reviewed JMP indirect; stored target $122E. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $2E,$12
L_0058:
; obfuscation-delimiter — $6D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $6D
L_0059:
    rol $02 ; $15CD
L_005B:
    jmp ($12A6) ; $15CF
L_005E:
; jump-vector — Read by reviewed JMP indirect; stored target $1316. See static-write audit in docs/encoded-native-overlay-body.md.
    .byte $16,$13
L_0060:
; obfuscation-delimiter — $8D decoy opcode at a reviewed block boundary; repeated delimiter vocabulary/order matches both relocated banks. See body layout audit.
    .byte $8D
L_0061:
    jsr EXT_L_020F ; $15D5
L_0064:
    jmp ($1243) ; $15D8
.assert * - component_start = 103, error, "Raw component size"
