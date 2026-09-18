; Evidence: docs/certificate-reveal.md
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
L_0000:
    pla ; $6000
L_0001:
    sta $10 ; $6001
L_0003:
    pla ; $6003
L_0004:
    sta $11 ; $6004
L_0006:
    pla ; $6006
L_0007:
    pla ; $6007
L_0008:
    lda $11 ; $6008
L_000A:
    pha ; $600A
L_000B:
    lda $10 ; $600B
L_000D:
    pha ; $600D
L_000E:
    lda #$00 ; $600E
L_0010:
    sta $00 ; $6010
L_0012:
    lda #$BF ; $6012
L_0014:
    sec ; $6014
L_0015:
    sbc $00 ; $6015
L_0017:
    sta $01 ; $6017
L_0019:
    ldy $01 ; $6019
L_001B:
    iny ; $601B
L_001C:
    ldx #$20 ; $601C
L_001E:
    dex ; $601E
L_001F:
    bne L_001E ; $601F
L_0021:
    dey ; $6021
L_0022:
    bne L_001C ; $6022
L_0024:
    ldy $01 ; $6024
L_0026:
    lda a:$0DC0,y ; $6026
L_0029:
    sta $04 ; $6029
L_002B:
    lda a:$0E80,y ; $602B
L_002E:
    sta $05 ; $602E
L_0030:
    lda $01 ; $6030
L_0032:
    cmp #$BF ; $6032
L_0034:
    beq L_0044 ; $6034
L_0036:
    iny ; $6036
L_0037:
    lda a:$0DC0,y ; $6037
L_003A:
    sta $02 ; $603A
L_003C:
    lda a:$0E80,y ; $603C
L_003F:
    sta $03 ; $603F
L_0041:
    clv ; $6041
L_0042:
    bvc L_0053 ; $6042
L_0044:
    ldy $00 ; $6044
L_0046:
    lda a:$0DC0,y ; $6046
L_0049:
    sta $02 ; $6049
L_004B:
    lda a:$0E80,y ; $604B
L_004E:
    clc ; $604E
L_004F:
    adc #$20 ; $604F
L_0051:
    sta $03 ; $6051
L_0053:
    ldy #$00 ; $6053
L_0055:
    lda ($02),y ; $6055
L_0057:
    sta ($04),y ; $6057
L_0059:
    iny ; $6059
L_005A:
    lda ($02),y ; $605A
L_005C:
    sta ($04),y ; $605C
L_005E:
    iny ; $605E
L_005F:
    lda ($02),y ; $605F
L_0061:
    sta ($04),y ; $6061
L_0063:
    iny ; $6063
L_0064:
    lda ($02),y ; $6064
L_0066:
    sta ($04),y ; $6066
L_0068:
    iny ; $6068
L_0069:
    lda ($02),y ; $6069
L_006B:
    sta ($04),y ; $606B
L_006D:
    iny ; $606D
L_006E:
    lda ($02),y ; $606E
L_0070:
    sta ($04),y ; $6070
L_0072:
    iny ; $6072
L_0073:
    lda ($02),y ; $6073
L_0075:
    sta ($04),y ; $6075
L_0077:
    iny ; $6077
L_0078:
    lda ($02),y ; $6078
L_007A:
    sta ($04),y ; $607A
L_007C:
    iny ; $607C
L_007D:
    lda ($02),y ; $607D
L_007F:
    sta ($04),y ; $607F
L_0081:
    iny ; $6081
L_0082:
    lda ($02),y ; $6082
L_0084:
    sta ($04),y ; $6084
L_0086:
    iny ; $6086
L_0087:
    lda ($02),y ; $6087
L_0089:
    sta ($04),y ; $6089
L_008B:
    iny ; $608B
L_008C:
    lda ($02),y ; $608C
L_008E:
    sta ($04),y ; $608E
L_0090:
    iny ; $6090
L_0091:
    lda ($02),y ; $6091
L_0093:
    sta ($04),y ; $6093
L_0095:
    iny ; $6095
L_0096:
    lda ($02),y ; $6096
L_0098:
    sta ($04),y ; $6098
L_009A:
    iny ; $609A
L_009B:
    lda ($02),y ; $609B
L_009D:
    sta ($04),y ; $609D
L_009F:
    iny ; $609F
L_00A0:
    lda ($02),y ; $60A0
L_00A2:
    sta ($04),y ; $60A2
L_00A4:
    iny ; $60A4
L_00A5:
    lda ($02),y ; $60A5
L_00A7:
    sta ($04),y ; $60A7
L_00A9:
    iny ; $60A9
L_00AA:
    lda ($02),y ; $60AA
L_00AC:
    sta ($04),y ; $60AC
L_00AE:
    iny ; $60AE
L_00AF:
    lda ($02),y ; $60AF
L_00B1:
    sta ($04),y ; $60B1
L_00B3:
    iny ; $60B3
L_00B4:
    lda ($02),y ; $60B4
L_00B6:
    sta ($04),y ; $60B6
L_00B8:
    iny ; $60B8
L_00B9:
    lda ($02),y ; $60B9
L_00BB:
    sta ($04),y ; $60BB
L_00BD:
    iny ; $60BD
L_00BE:
    lda ($02),y ; $60BE
L_00C0:
    sta ($04),y ; $60C0
L_00C2:
    iny ; $60C2
L_00C3:
    lda ($02),y ; $60C3
L_00C5:
    sta ($04),y ; $60C5
L_00C7:
    iny ; $60C7
L_00C8:
    lda ($02),y ; $60C8
L_00CA:
    sta ($04),y ; $60CA
L_00CC:
    iny ; $60CC
L_00CD:
    lda ($02),y ; $60CD
L_00CF:
    sta ($04),y ; $60CF
L_00D1:
    iny ; $60D1
L_00D2:
    lda ($02),y ; $60D2
L_00D4:
    sta ($04),y ; $60D4
L_00D6:
    iny ; $60D6
L_00D7:
    lda ($02),y ; $60D7
L_00D9:
    sta ($04),y ; $60D9
L_00DB:
    iny ; $60DB
L_00DC:
    lda ($02),y ; $60DC
L_00DE:
    sta ($04),y ; $60DE
L_00E0:
    iny ; $60E0
L_00E1:
    lda ($02),y ; $60E1
L_00E3:
    sta ($04),y ; $60E3
L_00E5:
    iny ; $60E5
L_00E6:
    lda ($02),y ; $60E6
L_00E8:
    sta ($04),y ; $60E8
L_00EA:
    iny ; $60EA
L_00EB:
    lda ($02),y ; $60EB
L_00ED:
    sta ($04),y ; $60ED
L_00EF:
    iny ; $60EF
L_00F0:
    lda ($02),y ; $60F0
L_00F2:
    sta ($04),y ; $60F2
L_00F4:
    iny ; $60F4
L_00F5:
    lda ($02),y ; $60F5
L_00F7:
    sta ($04),y ; $60F7
L_00F9:
    iny ; $60F9
L_00FA:
    lda ($02),y ; $60FA
L_00FC:
    sta ($04),y ; $60FC
L_00FE:
    iny ; $60FE
L_00FF:
    lda ($02),y ; $60FF
L_0101:
    sta ($04),y ; $6101
L_0103:
    iny ; $6103
L_0104:
    lda ($02),y ; $6104
L_0106:
    sta ($04),y ; $6106
L_0108:
    iny ; $6108
L_0109:
    lda ($02),y ; $6109
L_010B:
    sta ($04),y ; $610B
L_010D:
    iny ; $610D
L_010E:
    lda ($02),y ; $610E
L_0110:
    sta ($04),y ; $6110
L_0112:
    iny ; $6112
L_0113:
    lda ($02),y ; $6113
L_0115:
    sta ($04),y ; $6115
L_0117:
    iny ; $6117
L_0118:
    lda ($02),y ; $6118
L_011A:
    sta ($04),y ; $611A
L_011C:
    inc $01 ; $611C
L_011E:
    lda $01 ; $611E
L_0120:
    cmp #$C0 ; $6120
L_0122:
    beq L_0127 ; $6122
L_0124:
    jmp L_0024 ; $6124
L_0127:
    inc $00 ; $6127
L_0129:
    lda $00 ; $6129
L_012B:
    cmp #$C0 ; $612B
L_012D:
    beq L_0132 ; $612D
L_012F:
    jmp L_0012 ; $612F
L_0132:
    rts ; $6132
L_0133:
    .byte 0 ; Alignment after terminal RTS.
L_0134:
    .word 0, 0, 0, 0 ; Interpreter/procedure/segment/global relocation counts.
L_013C:
    .word * - L_0000 ; Native entry displacement.
L_013E:
    .byte 0, 0 ; Native marker and lexical level.
L_0140:
    .word * - L_013E ; Procedure dictionary entry.
L_0142:
    .byte 1, 1 ; Segment number and procedure count.
L_0144:
    .res 188, 0 ; Block padding after the complete segment trailer.
.assert * - component_start = 512, error, "Raw component size"
