; Evidence: docs/play-disk-boot.md
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
L_0000:
; boot-sector-count-limit — Disk II ROM compares its sector counter with $0800; boot entry increments this limit by two until it reaches eleven in RAM.
    .byte $01
L_0001:
    lda a:$0800 ; $0801
L_0004:
    cmp #$0A ; $0804
L_0006:
    bcs L_0012 ; $0806
L_0008:
    adc #$02 ; $0808
L_000A:
    sta a:$0800 ; $080A
L_000D:
    inc $3D ; $080D
L_000F:
    jmp a:$C65C ; $080F
L_0012:
    lda a:$0900 ; $0812
L_0015:
    sta $04 ; $0815
L_0017:
    lda #$01 ; $0817
L_0019:
    sta $02 ; $0819
L_001B:
    lda #$09 ; $081B
L_001D:
    sta $03 ; $081D
L_001F:
    lda #$00 ; $081F
L_0021:
    tax ; $0821
L_0022:
    sta $05 ; $0822
L_0024:
    lda #$20 ; $0824
L_0026:
    sta $01 ; $0826
L_0028:
    lda $05 ; $0828
L_002A:
    sta $00 ; $082A
L_002C:
    lda ($02,x) ; $082C
L_002E:
    bmi L_006C ; $082E
L_0030:
    inc $02 ; $0830
L_0032:
    bne L_0036 ; $0832
L_0034:
    inc $03 ; $0834
L_0036:
    tay ; $0836
L_0037:
    iny ; $0837
L_0038:
    lda ($02,x) ; $0838
L_003A:
    sta ($00,x) ; $083A
L_003C:
    pha ; $083C
L_003D:
    lda $00 ; $083D
L_003F:
    clc ; $083F
L_0040:
    adc $04 ; $0840
L_0042:
    sta $00 ; $0842
L_0044:
    bcc L_004E ; $0844
L_0046:
    inc $01 ; $0846
L_0048:
    lda $01 ; $0848
L_004A:
    cmp #$40 ; $084A
L_004C:
    beq L_005A ; $084C
L_004E:
    pla ; $084E
L_004F:
    dey ; $084F
L_0050:
    bne L_003A ; $0850
L_0052:
    inc $02 ; $0852
L_0054:
    bne L_002C ; $0854
L_0056:
    inc $03 ; $0856
L_0058:
    bne L_002C ; $0858
L_005A:
    pla ; $085A
L_005B:
    inc $02 ; $085B
L_005D:
    bne L_0061 ; $085D
L_005F:
    inc $03 ; $085F
L_0061:
    inc $05 ; $0861
L_0063:
    lda $05 ; $0863
L_0065:
    cmp $04 ; $0865
L_0067:
    bne L_0024 ; $0867
L_0069:
    jmp L_0097 ; $0869
L_006C:
    eor #$80 ; $086C
L_006E:
    tay ; $086E
L_006F:
    iny ; $086F
L_0070:
    inc $02 ; $0870
L_0072:
    bne L_0076 ; $0872
L_0074:
    inc $03 ; $0874
L_0076:
    lda ($02,x) ; $0876
L_0078:
    sta ($00,x) ; $0878
L_007A:
    inc $02 ; $087A
L_007C:
    bne L_0080 ; $087C
L_007E:
    inc $03 ; $087E
L_0080:
    lda $00 ; $0880
L_0082:
    clc ; $0882
L_0083:
    adc $04 ; $0883
L_0085:
    sta $00 ; $0885
L_0087:
    bcc L_0091 ; $0887
L_0089:
    inc $01 ; $0889
L_008B:
    lda $01 ; $088B
L_008D:
    cmp #$40 ; $088D
L_008F:
    beq L_0061 ; $088F
L_0091:
    dey ; $0891
L_0092:
    bne L_0076 ; $0892
L_0094:
    jmp L_002C ; $0894
L_0097:
    lda a:$C057 ; $0897
L_009A:
    lda a:$C054 ; $089A
L_009D:
    lda a:$C052 ; $089D
L_00A0:
    lda a:$C050 ; $08A0
L_00A3:
    lda a:$C0E8 ; $08A3
L_00A6:
    lda a:$C0E8 ; $08A6
L_00A9:
    lda a:$C010 ; $08A9
L_00AC:
    lda a:$C061 ; $08AC
L_00AF:
    bmi L_00BB ; $08AF
L_00B1:
    lda a:$C062 ; $08B1
L_00B4:
    bmi L_00BB ; $08B4
L_00B6:
    lda a:$C010 ; $08B6
L_00B9:
    bpl L_00AC ; $08B9
L_00BB:
    lda a:$C08A ; $08BB
L_00BE:
    jmp a:$C600 ; $08BE
.assert * - component_start = 193, error, "Raw component size"
