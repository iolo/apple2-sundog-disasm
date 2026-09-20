; Evidence: docs/encoded-native-overlay.md
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
L_0000:
    lda #$00 ; $4000
L_0002:
    php ; $4002
L_0003:
    lda #$60 ; $4003
L_0005:
    sta $00 ; $4005
L_0007:
    jsr a:$0000 ; $4007
L_000A:
    tsx ; $400A
L_000B:
    dex ; $400B
L_000C:
    dex ; $400C
L_000D:
    txs ; $400D
L_000E:
    pla ; $400E
L_000F:
    sta $00 ; $400F
L_0011:
    pla ; $4011
L_0012:
    sta $01 ; $4012
L_0014:
    lda #$09 ; $4014
L_0016:
    sta $02 ; $4016
L_0018:
    lda #$0C ; $4018
L_001A:
    sta $03 ; $401A
L_001C:
    ldx #$08 ; $401C
L_001E:
    ldy #$36 ; $401E
L_0020:
    lda ($00),y ; $4020
L_0022:
    pha ; $4022
L_0023:
    lda ($02),y ; $4023
L_0025:
    sta ($00),y ; $4025
L_0027:
    pla ; $4027
L_0028:
    sta ($02),y ; $4028
L_002A:
    iny ; $402A
L_002B:
    bne L_0020 ; $402B
L_002D:
    inc $01 ; $402D
L_002F:
    inc $03 ; $402F
L_0031:
    dex ; $4031
L_0032:
    bne L_0020 ; $4032
L_0034:
    plp ; $4034
L_0035:
    bne L_003E ; $4035
L_0037:
    jsr a:$0DF9 ; $4037
L_003A:
    lda #$FF ; $403A
L_003C:
    bne L_0002 ; $403C
L_003E:
    rts ; $403E
.assert * - component_start = 63, error, "Raw component size"
