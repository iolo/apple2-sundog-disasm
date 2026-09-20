; Evidence: docs/encoded-native-overlay.md
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
L_0000:
    lda #$00 ; $5800
L_0002:
    php ; $5802
L_0003:
    lda #$60 ; $5803
L_0005:
    sta $00 ; $5805
L_0007:
    jsr a:$0000 ; $5807
L_000A:
    tsx ; $580A
L_000B:
    dex ; $580B
L_000C:
    dex ; $580C
L_000D:
    txs ; $580D
L_000E:
    pla ; $580E
L_000F:
    sta $00 ; $580F
L_0011:
    pla ; $5811
L_0012:
    sta $01 ; $5812
L_0014:
    lda #$09 ; $5814
L_0016:
    sta $02 ; $5816
L_0018:
    lda #$10 ; $5818
L_001A:
    sta $03 ; $581A
L_001C:
    ldx #$08 ; $581C
L_001E:
    ldy #$36 ; $581E
L_0020:
    lda ($00),y ; $5820
L_0022:
    pha ; $5822
L_0023:
    lda ($02),y ; $5823
L_0025:
    sta ($00),y ; $5825
L_0027:
    pla ; $5827
L_0028:
    sta ($02),y ; $5828
L_002A:
    iny ; $582A
L_002B:
    bne L_0020 ; $582B
L_002D:
    inc $01 ; $582D
L_002F:
    inc $03 ; $582F
L_0031:
    dex ; $5831
L_0032:
    bne L_0020 ; $5832
L_0034:
    plp ; $5834
L_0035:
    bne L_003E ; $5835
L_0037:
    jsr a:$11F9 ; $5837
L_003A:
    lda #$FF ; $583A
L_003C:
    bne L_0002 ; $583C
L_003E:
    rts ; $583E
.assert * - component_start = 63, error, "Raw component size"
