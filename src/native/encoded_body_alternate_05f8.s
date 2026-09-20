; Evidence: docs/encoded-native-overlay-body.md
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
L_0000:
; track-sequence-index — STY at $0271, LDY at $0274 and INC at $04C0 manage the track index.
    .byte $00
L_0001:
; read-mode — STA at $00AB/$03AA and BIT/LDA at $0184/$048F/$0516 select disk-read mode.
    .byte $00
L_0002:
; wipe-start-address — LDA at $0602/$0607 loads this little-endian initial address into zero page for the terminal memory-wipe routine.
    .byte $10,$16
L_0004:
    lda a:$C083 ; $15FC
L_0007:
    lda a:$C083 ; $15FF
L_000A:
    lda a:$15FA ; $1602
L_000D:
    sta $00 ; $1605
L_000F:
    lda a:$15FB ; $1607
L_0012:
    sta $01 ; $160A
L_0014:
    lda #$00 ; $160C
L_0016:
    ldy #$00 ; $160E
L_0018:
    cmp $00 ; $1610
L_001A:
    bne L_0028 ; $1612
L_001C:
    cmp $01 ; $1614
L_001E:
    bne L_0026 ; $1616
L_0020:
    lda #$C0 ; $1618
L_0022:
    sta $01 ; $161A
L_0024:
    lda #$00 ; $161C
L_0026:
    dec $01 ; $161E
L_0028:
    dec $00 ; $1620
L_002A:
    sta ($00),y ; $1622
L_002C:
    jmp L_0018 ; $1624
.assert * - component_start = 47, error, "Raw component size"
