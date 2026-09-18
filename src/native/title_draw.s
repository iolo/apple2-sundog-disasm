; Early title-reveal routine loaded at $4000, before the Pascal runtime.
; Disk 1 blocks 201..202. Instructions end at $420F; row tables follow.
; The 8 KB HGR source bitmap is loaded at $4400 and remains temporary for now.
.setcpu "6502"
.segment "TITLE_DRAW"

entry:
; Initial rectangle: byte columns $12..$15, scanlines $5A..$65.
    lda     #$12 ; $4000
    sta     $00 ; $4002
    lda     #$15 ; $4004
    sta     $01 ; $4006
    lda     #$5A ; $4008
    sta     $02 ; $400A
    lda     #$65 ; $400C
    sta     $03 ; $400E
    lda     #$00 ; $4010
    sta     $23 ; $4012
    ldx     #$5F ; $4014
    lda     #$13 ; $4016
    jsr     hgr_address ; $4018
    lda     $18 ; $401B
    sta     $1E ; $401D
    lda     $19 ; $401F
    sta     $1F ; $4021
    lda     $1E ; $4023
    sta     $1C ; $4025
    lda     $1F ; $4027
    clc ; $4029
    adc     #$24 ; $402A
    sta     $1D ; $402C
    ldy     #$00 ; $402E
    lda     ($1C),y ; $4030
    sta     ($1E),y ; $4032
    iny ; $4034
    lda     ($1C),y ; $4035
    sta     ($1E),y ; $4037
    ldx     #$60 ; $4039
    lda     #$13 ; $403B
    jsr     hgr_address ; $403D
    lda     $18 ; $4040
    sta     $1E ; $4042
    lda     $19 ; $4044
    sta     $1F ; $4046
    lda     $1E ; $4048
    sta     $1C ; $404A
    lda     $1F ; $404C
    clc ; $404E
    adc     #$24 ; $404F
    sta     $1D ; $4051
    ldy     #$00 ; $4053
    lda     ($1C),y ; $4055
    sta     ($1E),y ; $4057
    iny ; $4059
    lda     ($1C),y ; $405A
    sta     ($1E),y ; $405C

; Copy strips from the bitmap into HGR page 1. Source high byte = destination + $24.

reveal_next_rectangle:
    lda     $02 ; $405E
    sta     $21 ; $4060
    ldx     $21 ; $4062
    lda     $00 ; $4064
    jsr     hgr_address ; $4066
    lda     $18 ; $4069
    sta     $04 ; $406B
    sta     $0E ; $406D
    lda     $19 ; $406F
    sta     $05 ; $4071
    clc ; $4073
    adc     #$24 ; $4074
    sta     $0F ; $4076
    inc     $21 ; $4078
    ldx     $21 ; $407A
    lda     $00 ; $407C
    jsr     hgr_address ; $407E
    lda     $18 ; $4081
    sta     $06 ; $4083
    sta     $10 ; $4085
    lda     $19 ; $4087
    sta     $07 ; $4089
    clc ; $408B
    adc     #$24 ; $408C
    sta     $11 ; $408E
    inc     $21 ; $4090
    ldx     $21 ; $4092
    lda     $00 ; $4094
    jsr     hgr_address ; $4096
    lda     $18 ; $4099
    sta     $08 ; $409B
    sta     $12 ; $409D
    lda     $19 ; $409F
    sta     $09 ; $40A1
    clc ; $40A3
    adc     #$24 ; $40A4
    sta     $13 ; $40A6
    inc     $21 ; $40A8
    ldx     $21 ; $40AA
    lda     $00 ; $40AC
    jsr     hgr_address ; $40AE
    lda     $18 ; $40B1
    sta     $0A ; $40B3
    sta     $14 ; $40B5
    lda     $19 ; $40B7
    sta     $0B ; $40B9
    clc ; $40BB
    adc     #$24 ; $40BC
    sta     $15 ; $40BE
    inc     $21 ; $40C0
    ldx     $21 ; $40C2
    lda     $00 ; $40C4
    jsr     hgr_address ; $40C6
    lda     $18 ; $40C9
    sta     $0C ; $40CB
    sta     $16 ; $40CD
    lda     $19 ; $40CF
    sta     $0D ; $40D1
    clc ; $40D3
    adc     #$24 ; $40D4
    sta     $17 ; $40D6
    sec ; $40D8
    lda     $01 ; $40D9
    sbc     $00 ; $40DB
    sta     $20 ; $40DD
    ldy     $20 ; $40DF

L40E1:
    ldx     #$00 ; $40E1

L40E3:
    lda     ($0E,x) ; $40E3
    sta     ($04,x) ; $40E5
    inc     $0E,x ; $40E7
    inc     $04,x ; $40E9
    inx ; $40EB
    inx ; $40EC
    cpx     #$0A ; $40ED
    bne     L40E3 ; $40EF
    dey ; $40F1
    cpy     #$FF ; $40F2
    bne     L40E1 ; $40F4
    lda     $02 ; $40F6
    sta     $21 ; $40F8

L40FA:
    ldx     $21 ; $40FA
    lda     $01 ; $40FC
    jsr     hgr_address ; $40FE
    lda     $18 ; $4101
    sta     $1E ; $4103
    sta     $1C ; $4105
    lda     $19 ; $4107
    sta     $1F ; $4109
    clc ; $410B
    adc     #$24 ; $410C
    sta     $1D ; $410E
    ldx     #$00 ; $4110
    lda     ($1C,x) ; $4112
    sta     ($1E,x) ; $4114
    inc     $21 ; $4116
    lda     $21 ; $4118
    cmp     $03 ; $411A
    bcc     L40FA ; $411C
    beq     L40FA ; $411E
    lda     $03 ; $4120
    sta     $21 ; $4122
    ldx     $21 ; $4124
    lda     $01 ; $4126
    jsr     hgr_address ; $4128
    lda     $18 ; $412B
    sta     $04 ; $412D
    sta     $0E ; $412F
    lda     $19 ; $4131
    sta     $05 ; $4133
    clc ; $4135
    adc     #$24 ; $4136
    sta     $0F ; $4138
    dec     $21 ; $413A
    ldx     $21 ; $413C
    lda     $01 ; $413E
    jsr     hgr_address ; $4140
    lda     $18 ; $4143
    sta     $06 ; $4145
    sta     $10 ; $4147
    lda     $19 ; $4149
    sta     $07 ; $414B
    clc ; $414D
    adc     #$24 ; $414E
    sta     $11 ; $4150
    dec     $21 ; $4152
    ldx     $21 ; $4154
    lda     $01 ; $4156
    jsr     hgr_address ; $4158
    lda     $18 ; $415B
    sta     $08 ; $415D
    sta     $12 ; $415F
    lda     $19 ; $4161
    sta     $09 ; $4163
    clc ; $4165
    adc     #$24 ; $4166
    sta     $13 ; $4168
    dec     $21 ; $416A
    ldx     $21 ; $416C
    lda     $01 ; $416E
    jsr     hgr_address ; $4170
    lda     $18 ; $4173
    sta     $0A ; $4175
    sta     $14 ; $4177
    lda     $19 ; $4179
    sta     $0B ; $417B
    clc ; $417D
    adc     #$24 ; $417E
    sta     $15 ; $4180
    dec     $21 ; $4182
    ldx     $21 ; $4184
    lda     $01 ; $4186
    jsr     hgr_address ; $4188
    lda     $18 ; $418B
    sta     $0C ; $418D
    sta     $16 ; $418F
    lda     $19 ; $4191
    sta     $0D ; $4193
    clc ; $4195
    adc     #$24 ; $4196
    sta     $17 ; $4198
    sec ; $419A
    lda     $01 ; $419B
    sbc     $00 ; $419D
    sta     $20 ; $419F
    ldy     $20 ; $41A1

L41A3:
    ldx     #$00 ; $41A3

L41A5:
    lda     ($0E,x) ; $41A5
    sta     ($04,x) ; $41A7
    dec     $0E,x ; $41A9
    dec     $04,x ; $41AB
    inx ; $41AD
    inx ; $41AE
    cpx     #$0A ; $41AF
    bne     L41A5 ; $41B1
    dey ; $41B3
    cpy     #$FF ; $41B4
    bne     L41A3 ; $41B6
    lda     $03 ; $41B8
    sta     $21 ; $41BA

L41BC:
    ldx     $21 ; $41BC
    lda     $00 ; $41BE
    jsr     hgr_address ; $41C0
    lda     $18 ; $41C3
    sta     $1E ; $41C5
    sta     $1C ; $41C7
    lda     $19 ; $41C9
    sta     $1F ; $41CB
    clc ; $41CD
    adc     #$24 ; $41CE
    sta     $1D ; $41D0
    ldx     #$00 ; $41D2
    lda     ($1C,x) ; $41D4
    sta     ($1E,x) ; $41D6
    dec     $21 ; $41D8
    lda     $21 ; $41DA
    cmp     $02 ; $41DC
    beq     L41E2 ; $41DE
    bcs     L41BC ; $41E0

L41E2:
    dec     $00 ; $41E2
    inc     $01 ; $41E4
    sec ; $41E6
    lda     $02 ; $41E7
    sbc     #$05 ; $41E9
    sta     $02 ; $41EB
    clc ; $41ED
    lda     $03 ; $41EE
    adc     #$05 ; $41F0
    sta     $03 ; $41F2
    inc     $23 ; $41F4
    lda     $23 ; $41F6
    cmp     #$13 ; $41F8
    beq     L41FF ; $41FA
    jmp     reveal_next_rectangle ; $41FC

L41FF:
    rts ; $41FF

; A = byte column, X = scanline; return page-1 address in $18/$19.

hgr_address:
    sta     $1A ; $4200
    lda     hgr_row_low,x ; $4202
    clc ; $4205
    adc     $1A ; $4206
    sta     $18 ; $4208
    lda     hgr_row_high,x ; $420A
    sta     $19 ; $420D
    rts ; $420F

hgr_row_low:
.repeat 192, row
    .byte <($2000 + (row & 7) * $400 + ((row >> 3) & 7) * $80 + (row >> 6) * 40)
.endrepeat
hgr_row_high:
.repeat 192, row
    .byte >($2000 + (row & 7) * $400 + ((row >> 3) & 7) * $80 + (row >> 6) * 40)
.endrepeat

; Unreferenced bytes in the loaded prefix. Preserve their values without
; promoting them to code or assigning an unverified metadata interpretation.
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$98,$03,$00,$00,$02,$00,$01,$01
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04

.assert * - entry = $400, error, "Title routine prefix size changed"
