; Evidence: docs/raw-buffer-transform.md
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
L_0000:
    pla ; $0F40
L_0001:
    sta $00 ; $0F41
L_0003:
    pla ; $0F43
L_0004:
    sta $01 ; $0F44
L_0006:
    pla ; $0F46
L_0007:
    sta $02 ; $0F47
L_0009:
    pla ; $0F49
L_000A:
    sta $03 ; $0F4A
L_000C:
    lda $01 ; $0F4C
L_000E:
    pha ; $0F4E
L_000F:
    lda $00 ; $0F4F
L_0011:
    pha ; $0F51
L_0012:
    ldy #$00 ; $0F52
L_0014:
    lda ($02),y ; $0F54
L_0016:
    sta a:$0005,y ; $0F56
L_0019:
    iny ; $0F59
L_001A:
    cpy #$04 ; $0F5A
L_001C:
    bne L_0014 ; $0F5C
L_001E:
    asl $06 ; $0F5E
L_0020:
    lda $06 ; $0F60
L_0022:
    pha ; $0F62
L_0023:
    lda $05 ; $0F63
L_0025:
    pha ; $0F65
L_0026:
    ldy #$00 ; $0F66
L_0028:
    sty $04 ; $0F68
L_002A:
    clc ; $0F6A
L_002B:
    lda ($04),y ; $0F6B
L_002D:
    adc $07 ; $0F6D
L_002F:
    sta ($04),y ; $0F6F
L_0031:
    clc ; $0F71
L_0032:
    lda $07 ; $0F72
L_0034:
    adc $08 ; $0F74
L_0036:
    sta $07 ; $0F76
L_0038:
    iny ; $0F78
L_0039:
    bne L_002A ; $0F79
L_003B:
    inc $05 ; $0F7B
L_003D:
    dec $06 ; $0F7D
L_003F:
    bne L_002A ; $0F7F
L_0041:
    pla ; $0F81
L_0042:
    sta $05 ; $0F82
L_0044:
    pha ; $0F84
L_0045:
    pla ; $0F85
L_0046:
    pla ; $0F86
L_0047:
    lda #$53 ; $0F87
L_0049:
    sta a:$1801 ; $0F89
L_004C:
    lda #$48 ; $0F8C
L_004E:
    sta a:$1802 ; $0F8E
L_0051:
    lda #$49 ; $0F91
L_0053:
    sta a:$1803 ; $0F93
L_0056:
    lda #$50 ; $0F96
L_0058:
    sta a:$1804 ; $0F98
L_005B:
    nop ; $0F9B
L_005C:
    rts ; $0F9C
.assert * - component_start = 93, error, "Raw component size"
