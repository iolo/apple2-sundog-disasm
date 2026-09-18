; Evidence: docs/disk-checksum.md
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
L_0000:
; block-checksum-pairs — Game 21 compares entries indexed by block >> 2; 31 checked eight-block groups match separate even/odd sums, with group 48 explicitly skipped
    .byte $C0,$38,$8D,$0D,$7C,$B6,$57,$F8,$E1,$E9,$79,$8C,$57,$92,$AC,$A0
    .byte $0A,$A6,$5D,$10,$3C,$CE,$AF,$A2,$58,$18,$EB,$7D,$31,$75,$74,$B4
    .byte $B3,$FD,$CB,$6D,$DE,$6D,$BF,$BC,$D8,$2F,$87,$83,$4A,$9C,$48,$C5
    .byte $64,$7F,$7D,$C4,$4C,$7E,$93,$B8,$D6,$26,$CD,$CE,$5A,$EA,$B0,$03
L_0040:
    pla ; $1840
L_0041:
    sta $00 ; $1841
L_0043:
    pla ; $1843
L_0044:
    sta $01 ; $1844
L_0046:
    pla ; $1846
L_0047:
    sta $02 ; $1847
L_0049:
    pla ; $1849
L_004A:
    sta $03 ; $184A
L_004C:
    lda $01 ; $184C
L_004E:
    pha ; $184E
L_004F:
    lda $00 ; $184F
L_0051:
    pha ; $1851
L_0052:
    lda #$10 ; $1852
L_0054:
    sta $08 ; $1854
L_0056:
    lda #$40 ; $1856
L_0058:
    sta $07 ; $1858
L_005A:
    lda #$00 ; $185A
L_005C:
    sta $04 ; $185C
L_005E:
    sta $05 ; $185E
L_0060:
    sta $06 ; $1860
L_0062:
    ldy #$00 ; $1862
L_0064:
    clc ; $1864
L_0065:
    lda ($06),y ; $1865
L_0067:
    adc $04 ; $1867
L_0069:
    sta $04 ; $1869
L_006B:
    iny ; $186B
L_006C:
    clc ; $186C
L_006D:
    lda ($06),y ; $186D
L_006F:
    adc $05 ; $186F
L_0071:
    sta $05 ; $1871
L_0073:
    iny ; $1873
L_0074:
    bne L_0064 ; $1874
L_0076:
    inc $07 ; $1876
L_0078:
    dec $08 ; $1878
L_007A:
    bne L_0062 ; $187A
L_007C:
    ldy #$01 ; $187C
L_007E:
    lda a:$0004,y ; $187E
L_0081:
    sta ($02),y ; $1881
L_0083:
    dey ; $1883
L_0084:
    bpl L_007E ; $1884
L_0086:
    rts ; $1886
.assert * - component_start = 135, error, "Raw component size"
