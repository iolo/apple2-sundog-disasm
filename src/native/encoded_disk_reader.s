; Evidence: docs/encoded-disk-reader.md
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
L_0000:
    pla ; $E000
L_0001:
    sta $00 ; $E001
L_0003:
    pla ; $E003
L_0004:
    sta $01 ; $E004
L_0006:
    pla ; $E006
L_0007:
    sta $02 ; $E007
L_0009:
    pla ; $E009
L_000A:
    sta $03 ; $E00A
L_000C:
    ldx #$60 ; $E00C
L_000E:
    lda a:$C089,x ; $E00E
L_0011:
    lda a:$C08A,x ; $E011
L_0014:
    ldy #$FF ; $E014
L_0016:
    dey ; $E016
L_0017:
    beq L_0062 ; $E017
L_0019:
    lda a:$C08C,x ; $E019
L_001C:
    bpl L_0019 ; $E01C
L_001E:
    cmp #$AA ; $E01E
L_0020:
    bne L_0019 ; $E020
L_0022:
    lda a:$C08C,x ; $E022
L_0025:
    bpl L_0022 ; $E025
L_0027:
    cmp #$D5 ; $E027
L_0029:
    bne L_0016 ; $E029
L_002B:
    lda a:$C08C,x ; $E02B
L_002E:
    bpl L_002B ; $E02E
L_0030:
    cmp #$A7 ; $E030
L_0032:
    bne L_0016 ; $E032
L_0034:
    jsr L_007A ; $E034
L_0037:
    jsr L_0074 ; $E037
L_003A:
    jsr L_0074 ; $E03A
L_003D:
    jsr L_0074 ; $E03D
L_0040:
    jsr L_0074 ; $E040
L_0043:
    jsr L_0074 ; $E043
L_0046:
    jsr L_0074 ; $E046
L_0049:
    jsr L_0070 ; $E049
L_004C:
    jsr L_0070 ; $E04C
L_004F:
    jsr L_0070 ; $E04F
L_0052:
    jsr L_0070 ; $E052
L_0055:
    jsr L_0070 ; $E055
L_0058:
    lda a:$C08C,x ; $E058
L_005B:
    bpl L_0058 ; $E05B
L_005D:
    ldy #$00 ; $E05D
L_005F:
    sta ($02),y ; $E05F
L_0061:
    iny ; $E061
L_0062:
    lda #$00 ; $E062
L_0064:
    sta ($02),y ; $E064
L_0066:
    lda a:$C088,x ; $E066
L_0069:
    lda $01 ; $E069
L_006B:
    pha ; $E06B
L_006C:
    lda $00 ; $E06C
L_006E:
    pha ; $E06E
L_006F:
    rts ; $E06F
L_0070:
    nop ; $E070
L_0071:
    nop ; $E071
L_0072:
    nop ; $E072
L_0073:
    nop ; $E073
L_0074:
    nop ; $E074
L_0075:
    nop ; $E075
L_0076:
    nop ; $E076
L_0077:
    nop ; $E077
L_0078:
    nop ; $E078
L_0079:
    nop ; $E079
L_007A:
    nop ; $E07A
L_007B:
    nop ; $E07B
L_007C:
    nop ; $E07C
L_007D:
    nop ; $E07D
L_007E:
    rts ; $E07E
.assert * - component_start = 127, error, "Raw component size"
