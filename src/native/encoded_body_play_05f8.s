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
    .byte $10,$12
L_0004:
    lda a:$C083 ; $11FC
L_0007:
    lda a:$C083 ; $11FF
L_000A:
    lda a:$11FA ; $1202
L_000D:
    sta $00 ; $1205
L_000F:
    lda a:$11FB ; $1207
L_0012:
    sta $01 ; $120A
L_0014:
    lda #$00 ; $120C
L_0016:
    ldy #$00 ; $120E
L_0018:
    cmp $00 ; $1210
L_001A:
    bne L_0028 ; $1212
L_001C:
    cmp $01 ; $1214
L_001E:
    bne L_0026 ; $1216
L_0020:
    lda #$C0 ; $1218
L_0022:
    sta $01 ; $121A
L_0024:
    lda #$00 ; $121C
L_0026:
    dec $01 ; $121E
L_0028:
    dec $00 ; $1220
L_002A:
    sta ($00),y ; $1222
L_002C:
    jmp L_0018 ; $1224
.assert * - component_start = 47, error, "Raw component size"
