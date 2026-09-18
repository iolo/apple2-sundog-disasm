; Mixed p-code / native Pascal segment 23, shared by both disks.
; See docs/native-pascal.md for relocation and code/data evidence.
.include "encoding.inc"
.setcpu "6502"
.segment "PCODE"
segment_start:
p1_entry:
    p_rnp 0
    .word 0, 0
    .word * - p1_entry
    .word * - p1_entry
p1_attributes:
    .byte 1, 1
p2_entry:
.scope proc2
        ldx     #$00                            ; segment +$000C
        ldy     #$06                            ; segment +$000E
L_0010:  pla                                     ; segment +$0010
        sta     $00,x                           ; segment +$0011
        inx                                     ; segment +$0013
        dey                                     ; segment +$0014
        bne     L_0010                           ; segment +$0015
        ldy     #$00                            ; segment +$0017
        lda     #$03                            ; segment +$0019
        sta     $0A                             ; segment +$001B
        lda     #$01                            ; segment +$001D
        sta     $0C                             ; segment +$001F
        lda     #$18                            ; segment +$0021
        sta     $06                             ; segment +$0023
L_0025:  lda     #$0C                            ; segment +$0025
        sta     $0E                             ; segment +$0027
        lda     #$28                            ; segment +$0029
        sta     $08                             ; segment +$002B
L_002D:  lda     ($04),y                         ; segment +$002D
        pha                                     ; segment +$002F
        ror     a                               ; segment +$0030
        ror     a                               ; segment +$0031
        sta     ($04),y                         ; segment +$0032
        pla                                     ; segment +$0034
        and     #$03                            ; segment +$0035
        dec     $0A                             ; segment +$0037
        bpl     L_0045                           ; segment +$0039
        ldx     #$03                            ; segment +$003B
        stx     $0A                             ; segment +$003D
        inc     $04                             ; segment +$003F
        bne     L_0045                           ; segment +$0041
        inc     $05                             ; segment +$0043
L_0045:  sta     $10                             ; segment +$0045
        lda     $0E                             ; segment +$0047
        asl     a                               ; segment +$0049
        asl     a                               ; segment +$004A
        clc                                     ; segment +$004B
        adc     $10                             ; segment +$004C
        tax                                     ; segment +$004E
p2_lookup:
        lda a:state_table - p2_entry,x ; procedure-relative operand, relocated by loader
        sta     $0E                             ; segment +$0052
        sta     ($02),y                         ; segment +$0054
        inc     $02                             ; segment +$0056
        bne     L_005C                           ; segment +$0058
        inc     $03                             ; segment +$005A
L_005C:  dec     $08                             ; segment +$005C
        bne     L_002D                           ; segment +$005E
        dec     $06                             ; segment +$0060
        bne     L_0025                           ; segment +$0062
        lda     $01                             ; segment +$0064
        pha                                     ; segment +$0066
        lda     $00                             ; segment +$0067
        pha                                     ; segment +$0069
        rts                                     ; segment +$006A
.endscope
two_bit_masks:
    .byte $03, $0C, $30, $C0
state_table:
    .byte $01, $02, $09, $0D, $00, $07, $0A, $0A
    .byte $03, $04, $0B, $0B, $01, $02, $09, $0D
    .byte $05, $06, $08, $0C, $03, $04, $0B, $0B
    .byte $00, $07, $0A, $0A, $05, $06, $08, $0C
    .byte $01, $02, $09, $0D, $05, $06, $08, $0C
    .byte $00, $07, $0A, $0A, $03, $04, $0B, $0B
    .byte $05, $06, $08, $0C, $01, $02, $09, $0D
    .byte 0 ; word alignment
    .word 0 ; interpreter relocations
    .word * - (proc2::p2_lookup + 1)
    .word 1 ; procedure-relative relocations
    .word 0 ; segment relocations
    .word 0 ; global relocations
    .word * - p2_entry
p2_attributes:
    .byte 0, 1 ; native marker, lexical level
p3_entry:
.scope proc3
        ldx     #$00                            ; segment +$00B6
        ldy     #$10                            ; segment +$00B8
L_00BA:  pla                                     ; segment +$00BA
        sta     $00,x                           ; segment +$00BB
        inx                                     ; segment +$00BD
        dey                                     ; segment +$00BE
        bne     L_00BA                           ; segment +$00BF
        clc                                     ; segment +$00C1
        lda     $04                             ; segment +$00C2
        adc     $04                             ; segment +$00C4
        adc     $04                             ; segment +$00C6
        adc     $04                             ; segment +$00C8
        adc     $04                             ; segment +$00CA
        sta     $04                             ; segment +$00CC
        ldx     #$02                            ; segment +$00CE
L_00D0:  asl     $04                             ; segment +$00D0
        rol     $05                             ; segment +$00D2
        dex                                     ; segment +$00D4
        bpl     L_00D0                           ; segment +$00D5
        clc                                     ; segment +$00D7
        lda     $04                             ; segment +$00D8
        adc     $02                             ; segment +$00DA
        sta     $02                             ; segment +$00DC
        lda     $05                             ; segment +$00DE
        adc     $03                             ; segment +$00E0
        sta     $03                             ; segment +$00E2
        lda     #$00                            ; segment +$00E4
        sta     $14                             ; segment +$00E6
p3_loop:
        ldy     $06                             ; segment +$00E8
        ldx     #$12                            ; segment +$00EA
L_00EC:  lda     ($02),y                         ; segment +$00EC
        and     #$1F                            ; segment +$00EE
        sta     $1A                             ; segment +$00F0
        iny                                     ; segment +$00F2
        cpy     #$28                            ; segment +$00F3
        bne     L_00F9                           ; segment +$00F5
        ldy     #$00                            ; segment +$00F7
L_00F9:  lda     $08                             ; segment +$00F9
        cmp     #$20                            ; segment +$00FB
        beq     L_0123                           ; segment +$00FD
        clc                                     ; segment +$00FF
        lda     $1A                             ; segment +$0100
        adc     $1A                             ; segment +$0102
        adc     $1A                             ; segment +$0104
        sta     $1A                             ; segment +$0106
        lda     #$00                            ; segment +$0108
        sta     $1B                             ; segment +$010A
        txa                                     ; segment +$010C
        ldx     #$05                            ; segment +$010D
L_010F:  clc                                     ; segment +$010F
        rol     $1A                             ; segment +$0110
        rol     $1B                             ; segment +$0112
        dex                                     ; segment +$0114
        bne     L_010F                           ; segment +$0115
        tax                                     ; segment +$0117
        lda     $1A                             ; segment +$0118
        sta     $20,x                           ; segment +$011A
        lda     $1B                             ; segment +$011C
        sta     $21,x                           ; segment +$011E
        clv                                     ; segment +$0120
        bvc     L_012E                           ; segment +$0121
L_0123:  lda     $1A                             ; segment +$0123
        clc                                     ; segment +$0125
        ror     a                               ; segment +$0126
        sta     $21,x                           ; segment +$0127
        lda     #$00                            ; segment +$0129
        ror     a                               ; segment +$012B
        sta     $20,x                           ; segment +$012C
L_012E:  clc                                     ; segment +$012E
        lda     $21,x                           ; segment +$012F
        adc     #$40                            ; segment +$0131
        sta     $21,x                           ; segment +$0133
        dex                                     ; segment +$0135
        dex                                     ; segment +$0136
        bpl     L_00EC                           ; segment +$0137
        lda     $08                             ; segment +$0139
        sta     $18                             ; segment +$013B
L_013D:  ldy     $14                             ; segment +$013D
        lda     $0DC0,y                         ; segment +$013F
        sta     $10                             ; segment +$0142
        lda     $0E80,y                         ; segment +$0144
        sta     $11                             ; segment +$0147
        inc     $14                             ; segment +$0149
        ldx     #$12                            ; segment +$014B
L_014D:  clc                                     ; segment +$014D
        lda     $20,x                           ; segment +$014E
        sta     $12                             ; segment +$0150
        adc     #$04                            ; segment +$0152
        sta     $20,x                           ; segment +$0154
        lda     $21,x                           ; segment +$0156
        sta     $13                             ; segment +$0158
        adc     #$00                            ; segment +$015A
        sta     $21,x                           ; segment +$015C
        ldy     #$00                            ; segment +$015E
        lda     ($12),y                         ; segment +$0160
        sta     ($10),y                         ; segment +$0162
        iny                                     ; segment +$0164
        lda     ($12),y                         ; segment +$0165
        sta     ($10),y                         ; segment +$0167
        iny                                     ; segment +$0169
        lda     ($12),y                         ; segment +$016A
        sta     ($10),y                         ; segment +$016C
        iny                                     ; segment +$016E
        lda     ($12),y                         ; segment +$016F
        sta     ($10),y                         ; segment +$0171
        clc                                     ; segment +$0173
        lda     #$04                            ; segment +$0174
        adc     $10                             ; segment +$0176
        sta     $10                             ; segment +$0178
        dex                                     ; segment +$017A
        dex                                     ; segment +$017B
        bpl     L_014D                           ; segment +$017C
        dec     $18                             ; segment +$017E
        bne     L_013D                           ; segment +$0180
        clc                                     ; segment +$0182
        lda     #$28                            ; segment +$0183
        adc     $02                             ; segment +$0185
        sta     $02                             ; segment +$0187
        lda     #$00                            ; segment +$0189
        adc     $03                             ; segment +$018B
        sta     $03                             ; segment +$018D
        dec     $0A                             ; segment +$018F
        beq     L_0196                           ; segment +$0191
p3_jump:
        jmp a:p3_loop - p3_entry ; procedure-relative operand, relocated by loader
L_0196:  lda     $01                             ; segment +$0196
        pha                                     ; segment +$0198
        lda     $00                             ; segment +$0199
        pha                                     ; segment +$019B
        rts                                     ; segment +$019C
.endscope
    .byte 0 ; word alignment
    .word 0 ; interpreter relocations
    .word * - (proc3::p3_jump + 1)
    .word 1 ; procedure-relative relocations
    .word 0 ; segment relocations
    .word 0 ; global relocations
    .word * - p3_entry
p3_attributes:
    .byte 0, 1 ; native marker, lexical level
p4_entry:
.scope proc4
        ldx     #$00                            ; segment +$01AC
        ldy     #$0A                            ; segment +$01AE
L_01B0:  pla                                     ; segment +$01B0
        sta     $00,x                           ; segment +$01B1
        inx                                     ; segment +$01B3
        dey                                     ; segment +$01B4
        bne     L_01B0                           ; segment +$01B5
        ldy     $04                             ; segment +$01B7
        clc                                     ; segment +$01B9
        lda     $0DC0,y                         ; segment +$01BA
        adc     $08                             ; segment +$01BD
        sta     $0A                             ; segment +$01BF
        lda     $0E80,y                         ; segment +$01C1
        adc     #$00                            ; segment +$01C4
        sta     $0B                             ; segment +$01C6
        ldx     #$00                            ; segment +$01C8
        lda     ($0A,x)                         ; segment +$01CA
        eor     #$60                            ; segment +$01CC
        sta     ($0A,x)                         ; segment +$01CE
        lda     $06                             ; segment +$01D0
        sec                                     ; segment +$01D2
        sbc     $08                             ; segment +$01D3
        tay                                     ; segment +$01D5
L_01D6:  lda     ($0A),y                         ; segment +$01D6
        eor     #$7F                            ; segment +$01D8
        sta     ($0A),y                         ; segment +$01DA
        dey                                     ; segment +$01DC
        bne     L_01D6                           ; segment +$01DD
        ldy     $04                             ; segment +$01DF
        iny                                     ; segment +$01E1
L_01E2:  lda     $0DC0,y                         ; segment +$01E2
        clc                                     ; segment +$01E5
        adc     $08                             ; segment +$01E6
        sta     $0A                             ; segment +$01E8
        lda     $0E80,y                         ; segment +$01EA
        sta     $0B                             ; segment +$01ED
        ldx     #$00                            ; segment +$01EF
        lda     ($0A,x)                         ; segment +$01F1
        eor     #$60                            ; segment +$01F3
        sta     ($0A,x)                         ; segment +$01F5
        iny                                     ; segment +$01F7
        cpy     $02                             ; segment +$01F8
        bne     L_01E2                           ; segment +$01FA
        ldy     $04                             ; segment +$01FC
        iny                                     ; segment +$01FE
L_01FF:  lda     $0DC0,y                         ; segment +$01FF
        clc                                     ; segment +$0202
        adc     $06                             ; segment +$0203
        sta     $0A                             ; segment +$0205
        lda     $0E80,y                         ; segment +$0207
        sta     $0B                             ; segment +$020A
        ldx     #$00                            ; segment +$020C
        lda     ($0A,x)                         ; segment +$020E
        eor     #$60                            ; segment +$0210
        sta     ($0A,x)                         ; segment +$0212
        iny                                     ; segment +$0214
        cpy     $02                             ; segment +$0215
        bne     L_01FF                           ; segment +$0217
        ldy     $02                             ; segment +$0219
        clc                                     ; segment +$021B
        lda     $0DC0,y                         ; segment +$021C
        adc     $08                             ; segment +$021F
        sta     $0A                             ; segment +$0221
        lda     $0E80,y                         ; segment +$0223
        adc     #$00                            ; segment +$0226
        sta     $0B                             ; segment +$0228
        ldx     #$00                            ; segment +$022A
        lda     ($0A,x)                         ; segment +$022C
        eor     #$60                            ; segment +$022E
        sta     ($0A,x)                         ; segment +$0230
        lda     $06                             ; segment +$0232
        sec                                     ; segment +$0234
        sbc     $08                             ; segment +$0235
        tay                                     ; segment +$0237
L_0238:  lda     ($0A),y                         ; segment +$0238
        eor     #$7F                            ; segment +$023A
        sta     ($0A),y                         ; segment +$023C
        dey                                     ; segment +$023E
        bne     L_0238                           ; segment +$023F
        lda     $01                             ; segment +$0241
        pha                                     ; segment +$0243
        lda     $00                             ; segment +$0244
        pha                                     ; segment +$0246
        rts                                     ; segment +$0247
.endscope
    .word 0, 0, 0, 0 ; interpreter, procedure, segment, global counts
    .word * - p4_entry
p4_attributes:
    .byte 0, 1 ; native marker, lexical level
    .word * - p4_attributes
    .word * - p3_attributes
    .word * - p2_attributes
    .word * - p1_attributes
    .byte 23, 4 ; segment, procedure count
.assert * - segment_start = 606, error, "Segment size changed"
