; SYSTEM.APPLE shared procedure/segment, numeric, and device runtime.
; CPU addresses $E0E5-$F28F, following the native primitive bank's shared tail.
; The initializer at $F290 is a separate region copied to $6800 by the final stub.
; See native_shared.info and docs/native-shared.md for tables and static evidence.

        .setcpu "6502"

; ----------------------------------------------------------------------------
L0000           := $0000
L0090           := $0090
L0092           := $0092
L0094           := $0094
L0098           := $0098
L009A           := $009A
L6800           := $6800
standard_proc_vectors:= $D100
LD155           := $D155
LD190           := $D190
LD1BF           := $D1BF
LD1C3           := $D1C3
LD1DF           := $D1DF
LD1E3           := $D1E3
LD1E7           := $D1E7
LD1EB           := $D1EB
LD1F3           := $D1F3
advance_two     := $D27B
advance_one     := $D28D
dispatch        := $D293
LD6E4           := $D6E4
LFF00           := $FF00
LFF03           := $FF03
LFF06           := $FF06
LFF09           := $FF09
LFF0C           := $FF0C
LFF0F           := $FF0F
LFF12           := $FF12
LFF15           := $FF15
LFF18           := $FF18
LFF1B           := $FF1B
LFF1E           := $FF1E
LFF21           := $FF21
LFF24           := $FF24
LFF2A           := $FF2A
LFF2D           := $FF2D
LFF30           := $FF30
LFF33           := $FF33
LFF39           := $FF39
LFF3C           := $FF3C
LFFE2           := $FFE2
; ----------------------------------------------------------------------------

.segment        "NATIVE_SHARED"
native_shared_start:

prepare_procedure_call:
        pla                                     ; E0E5 68                       h
        sta     L0098                           ; E0E6 85 98                    ..
        pla                                     ; E0E8 68                       h
        sta     $99                             ; E0E9 85 99                    ..
        lda     L0090                           ; E0EB A5 90                    ..
        asl     a                               ; E0ED 0A                       .
        tay                                     ; E0EE A8                       .
        lda     $BD9E,y                         ; E0EF B9 9E BD                 ...
        sta     $8C                             ; E0F2 85 8C                    ..
        sta     $7E                             ; E0F4 85 7E                    .~
        lda     $BD9F,y                         ; E0F6 B9 9F BD                 ...
        sta     $8D                             ; E0F9 85 8D                    ..
        sta     $7F                             ; E0FB 85 7F                    ..
        jmp     LE116                           ; E0FD 4C 16 E1                 L..

; ----------------------------------------------------------------------------
LE100:  pla                                     ; E100 68                       h
        sta     L0098                           ; E101 85 98                    ..
        pla                                     ; E103 68                       h
        sta     $99                             ; E104 85 99                    ..
        lda     $56                             ; E106 A5 56                    .V
        sta     $8C                             ; E108 85 8C                    ..
        sta     $7E                             ; E10A 85 7E                    .~
        lda     $57                             ; E10C A5 57                    .W
        sta     $8D                             ; E10E 85 8D                    ..
        sta     $7F                             ; E110 85 7F                    ..
        lda     #$FF                            ; E112 A9 FF                    ..
        sta     L0090                           ; E114 85 90                    ..
LE116:  lda     $5C                             ; E116 A5 5C                    .\
        sta     $84                             ; E118 85 84                    ..
        lda     $5D                             ; E11A A5 5D                    .]
        sta     $85                             ; E11C 85 85                    ..
        lda     $58                             ; E11E A5 58                    .X
        clc                                     ; E120 18                       .
        adc     #$02                            ; E121 69 02                    i.
        sta     $58                             ; E123 85 58                    .X
        bcc     LE129                           ; E125 90 02                    ..
        inc     $59                             ; E127 E6 59                    .Y
LE129:  lda     $7E                             ; E129 A5 7E                    .~
        sec                                     ; E12B 38                       8
        sbc     $82                             ; E12C E5 82                    ..
        sta     $7E                             ; E12E 85 7E                    .~
        bcs     LE134                           ; E130 B0 02                    ..
        dec     $7F                             ; E132 C6 7F                    ..
LE134:  lda     $7E                             ; E134 A5 7E                    .~
        sec                                     ; E136 38                       8
        sbc     $82                             ; E137 E5 82                    ..
        sta     $7E                             ; E139 85 7E                    .~
        bcs     LE13F                           ; E13B B0 02                    ..
        dec     $7F                             ; E13D C6 7F                    ..
LE13F:  ldy     #$00                            ; E13F A0 00                    ..
        sec                                     ; E141 38                       8
        lda     $7E                             ; E142 A5 7E                    .~
        sbc     ($7E),y                         ; E144 F1 7E                    .~
        sta     $86                             ; E146 85 86                    ..
        lda     $7F                             ; E148 A5 7F                    ..
        iny                                     ; E14A C8                       .
        sbc     ($7E),y                         ; E14B F1 7E                    .~
        sta     $87                             ; E14D 85 87                    ..
        ldy     #$00                            ; E14F A0 00                    ..
        lda     ($86),y                         ; E151 B1 86                    ..
        bne     LE18C                           ; E153 D0 37                    .7
        lda     $86                             ; E155 A5 86                    ..
        sec                                     ; E157 38                       8
        sbc     #$02                            ; E158 E9 02                    ..
        sta     $86                             ; E15A 85 86                    ..
        bcs     LE160                           ; E15C B0 02                    ..
        dec     $87                             ; E15E C6 87                    ..
LE160:  sec                                     ; E160 38                       8
        lda     $86                             ; E161 A5 86                    ..
        sbc     ($86),y                         ; E163 F1 86                    ..
        sta     L009A                           ; E165 85 9A                    ..
        iny                                     ; E167 C8                       .
        lda     $87                             ; E168 A5 87                    ..
        sbc     ($86),y                         ; E16A F1 86                    ..
        sta     $9B                             ; E16C 85 9B                    ..
        lda     L0090                           ; E16E A5 90                    ..
        sta     native_call_segment             ; E170 8D 8B E1                 ...
        lda     native_return_address_minus_one+1; E173 AD 8A E1                ...
        pha                                     ; E176 48                       H
        lda     native_return_address_minus_one ; E177 AD 89 E1                 ...
        pha                                     ; E17A 48                       H
        jmp     (L009A)                         ; E17B 6C 9A 00                 l..

; ----------------------------------------------------------------------------
native_procedure_return:
        lda     native_call_segment             ; E17E AD 8B E1                 ...
        bmi     LE186                           ; E181 30 03                    0.
        jsr     release_segment                 ; E183 20 46 E6                  F.
LE186:  jmp     dispatch                        ; E186 4C 93 D2                 L..

; ----------------------------------------------------------------------------
native_return_address_minus_one:
        .word   native_procedure_return - 1                           ; E189 7D E1                    }.
; ----------------------------------------------------------------------------
native_call_segment:
        .byte   $00                             ; E18B 00                       .
; ----------------------------------------------------------------------------
LE18C:  lda     $86                             ; E18C A5 86                    ..
        sec                                     ; E18E 38                       8
        sbc     #$08                            ; E18F E9 08                    ..
        sta     $86                             ; E191 85 86                    ..
        bcs     LE197                           ; E193 B0 02                    ..
        dec     $87                             ; E195 C6 87                    ..
LE197:  sec                                     ; E197 38                       8
        ldy     #$00                            ; E198 A0 00                    ..
        lda     $84                             ; E19A A5 84                    ..
        sbc     ($86),y                         ; E19C F1 86                    ..
        sta     $88                             ; E19E 85 88                    ..
        lda     $85                             ; E1A0 A5 85                    ..
        iny                                     ; E1A2 C8                       .
        sbc     ($86),y                         ; E1A3 F1 86                    ..
        sta     $89                             ; E1A5 85 89                    ..
        bcc     LE1E9                           ; E1A7 90 40                    .@
        ldy     #$03                            ; E1A9 A0 03                    ..
        lda     ($86),y                         ; E1AB B1 86                    ..
        bne     LE1E9                           ; E1AD D0 3A                    .:
        dey                                     ; E1AF 88                       .
        lda     $88                             ; E1B0 A5 88                    ..
        sec                                     ; E1B2 38                       8
        sbc     ($86),y                         ; E1B3 F1 86                    ..
        sta     $88                             ; E1B5 85 88                    ..
        bcs     LE1C1                           ; E1B7 B0 08                    ..
        lda     $89                             ; E1B9 A5 89                    ..
        sbc     #$00                            ; E1BB E9 00                    ..
        sta     $89                             ; E1BD 85 89                    ..
        bcc     LE1E9                           ; E1BF 90 28                    .(
LE1C1:  lda     $88                             ; E1C1 A5 88                    ..
        sec                                     ; E1C3 38                       8
        sbc     #$0C                            ; E1C4 E9 0C                    ..
        sta     $88                             ; E1C6 85 88                    ..
        lda     $89                             ; E1C8 A5 89                    ..
        sbc     #$00                            ; E1CA E9 00                    ..
        sta     $89                             ; E1CC 85 89                    ..
        bcc     LE1E9                           ; E1CE 90 19                    ..
        sec                                     ; E1D0 38                       8
        lda     $88                             ; E1D1 A5 88                    ..
        sbc     $5A                             ; E1D3 E5 5A                    .Z
        lda     $89                             ; E1D5 A5 89                    ..
        sbc     $5B                             ; E1D7 E5 5B                    .[
        bcs     LE1EC                           ; E1D9 B0 11                    ..
        jsr     LD190                           ; E1DB 20 90 D1                  ..
        sec                                     ; E1DE 38                       8
        lda     $88                             ; E1DF A5 88                    ..
        sbc     $5A                             ; E1E1 E5 5A                    .Z
        lda     $89                             ; E1E3 A5 89                    ..
        sbc     $5B                             ; E1E5 E5 5B                    .[
        bcs     LE1EC                           ; E1E7 B0 03                    ..
LE1E9:  jmp     LD1C3                           ; E1E9 4C C3 D1                 L..

; ----------------------------------------------------------------------------
LE1EC:  ldy     #$02                            ; E1EC A0 02                    ..
LE1EE:  lda     $50,y                           ; E1EE B9 50 00                 .P.
        sta     ($88),y                         ; E1F1 91 88                    ..
        iny                                     ; E1F3 C8                       .
        cpy     #$0A                            ; E1F4 C0 0A                    ..
        bne     LE1EE                           ; E1F6 D0 F6                    ..
        clc                                     ; E1F8 18                       .
        lda     $88                             ; E1F9 A5 88                    ..
        adc     #$0C                            ; E1FB 69 0C                    i.
        sta     $74                             ; E1FD 85 74                    .t
        lda     $89                             ; E1FF A5 89                    ..
        adc     #$00                            ; E201 69 00                    i.
        sta     $75                             ; E203 85 75                    .u
        ldy     #$02                            ; E205 A0 02                    ..
        lda     ($86),y                         ; E207 B1 86                    ..
        ldy     #$00                            ; E209 A0 00                    ..
        tax                                     ; E20B AA                       .
        jmp     LE214                           ; E20C 4C 14 E2                 L..

; ----------------------------------------------------------------------------
LE20F:  pla                                     ; E20F 68                       h
        sta     ($74),y                         ; E210 91 74                    .t
        iny                                     ; E212 C8                       .
        dex                                     ; E213 CA                       .
LE214:  bne     LE20F                           ; E214 D0 F9                    ..
        tsx                                     ; E216 BA                       .
        txa                                     ; E217 8A                       .
        ldy     #$0A                            ; E218 A0 0A                    ..
        sta     ($88),y                         ; E21A 91 88                    ..
        lda     $86                             ; E21C A5 86                    ..
        clc                                     ; E21E 18                       .
        adc     #$06                            ; E21F 69 06                    i.
        sta     $7E                             ; E221 85 7E                    .~
        lda     $87                             ; E223 A5 87                    ..
        adc     #$00                            ; E225 69 00                    i.
        sta     $7F                             ; E227 85 7F                    ..
        ldy     #$00                            ; E229 A0 00                    ..
        sec                                     ; E22B 38                       8
        lda     $7E                             ; E22C A5 7E                    .~
        sbc     ($7E),y                         ; E22E F1 7E                    .~
        sta     $58                             ; E230 85 58                    .X
        lda     $7F                             ; E232 A5 7F                    ..
        iny                                     ; E234 C8                       .
        sbc     ($7E),y                         ; E235 F1 7E                    .~
        sta     $59                             ; E237 85 59                    .Y
        lda     $86                             ; E239 A5 86                    ..
        clc                                     ; E23B 18                       .
        adc     #$08                            ; E23C 69 08                    i.
        sta     $54                             ; E23E 85 54                    .T
        lda     $87                             ; E240 A5 87                    ..
        adc     #$00                            ; E242 69 00                    i.
        sta     $55                             ; E244 85 55                    .U
        lda     $88                             ; E246 A5 88                    ..
        sta     $52                             ; E248 85 52                    .R
        sta     $BDEC                           ; E24A 8D EC BD                 ...
        lda     $89                             ; E24D A5 89                    ..
        sta     $53                             ; E24F 85 53                    .S
        sta     $BDED                           ; E251 8D ED BD                 ...
        lda     $88                             ; E254 A5 88                    ..
        sec                                     ; E256 38                       8
        sbc     #$02                            ; E257 E9 02                    ..
        sta     $80                             ; E259 85 80                    ..
        lda     $89                             ; E25B A5 89                    ..
        sbc     #$00                            ; E25D E9 00                    ..
        sta     $81                             ; E25F 85 81                    ..
        ldy     #$00                            ; E261 A0 00                    ..
        lda     $5C                             ; E263 A5 5C                    .\
        sta     ($80),y                         ; E265 91 80                    ..
        iny                                     ; E267 C8                       .
        lda     $5D                             ; E268 A5 5D                    .]
        sta     ($80),y                         ; E26A 91 80                    ..
        lda     $80                             ; E26C A5 80                    ..
        sta     $5C                             ; E26E 85 5C                    .\
        lda     $81                             ; E270 A5 81                    ..
        sta     $5D                             ; E272 85 5D                    .]
        lda     $8C                             ; E274 A5 8C                    ..
        sta     $56                             ; E276 85 56                    .V
        lda     $8D                             ; E278 A5 8D                    ..
        sta     $57                             ; E27A 85 57                    .W
        inc     L0098                           ; E27C E6 98                    ..
        bne     LE282                           ; E27E D0 02                    ..
        inc     $99                             ; E280 E6 99                    ..
LE282:  jmp     (L0098)                         ; E282 6C 98 00                 l..

; ----------------------------------------------------------------------------
        ldy     #$01                            ; E285 A0 01                    ..
        lda     ($58),y                         ; E287 B1 58                    .X
        sta     $82                             ; E289 85 82                    ..
        jsr     LE100                           ; E28B 20 00 E1                  ..
LE28E:  ldy     #$09                            ; E28E A0 09                    ..
        lda     ($86),y                         ; E290 B1 86                    ..
        sta     $8E                             ; E292 85 8E                    ..
        dec     $8E                             ; E294 C6 8E                    ..
        lda     $52                             ; E296 A5 52                    .R
        sta     L0092                           ; E298 85 92                    ..
        lda     $53                             ; E29A A5 53                    .S
        sta     $93                             ; E29C 85 93                    ..
        jmp     LE2AD                           ; E29E 4C AD E2                 L..

; ----------------------------------------------------------------------------
LE2A1:  ldy     #$02                            ; E2A1 A0 02                    ..
        lda     (L0092),y                       ; E2A3 B1 92                    ..
        tax                                     ; E2A5 AA                       .
        iny                                     ; E2A6 C8                       .
        lda     (L0092),y                       ; E2A7 B1 92                    ..
        sta     $93                             ; E2A9 85 93                    ..
        stx     L0092                           ; E2AB 86 92                    ..
LE2AD:  ldy     #$04                            ; E2AD A0 04                    ..
        lda     (L0092),y                       ; E2AF B1 92                    ..
        sta     $96                             ; E2B1 85 96                    ..
        iny                                     ; E2B3 C8                       .
        lda     (L0092),y                       ; E2B4 B1 92                    ..
        sta     $97                             ; E2B6 85 97                    ..
        ldy     #$01                            ; E2B8 A0 01                    ..
        lda     ($96),y                         ; E2BA B1 96                    ..
        cmp     $8E                             ; E2BC C5 8E                    ..
        bne     LE2A1                           ; E2BE D0 E1                    ..
        ldy     #$02                            ; E2C0 A0 02                    ..
        lda     (L0092),y                       ; E2C2 B1 92                    ..
        ldy     #$00                            ; E2C4 A0 00                    ..
        sta     ($52),y                         ; E2C6 91 52                    .R
        ldy     #$03                            ; E2C8 A0 03                    ..
        lda     (L0092),y                       ; E2CA B1 92                    ..
        ldy     #$01                            ; E2CC A0 01                    ..
        sta     ($52),y                         ; E2CE 91 52                    .R
        jmp     dispatch                        ; E2D0 4C 93 D2                 L..

; ----------------------------------------------------------------------------
        ldy     #$01                            ; E2D3 A0 01                    ..
        lda     ($58),y                         ; E2D5 B1 58                    .X
        sta     $82                             ; E2D7 85 82                    ..
        jsr     LE100                           ; E2D9 20 00 E1                  ..
        ldy     #$02                            ; E2DC A0 02                    ..
        lda     ($88),y                         ; E2DE B1 88                    ..
        ldy     #$00                            ; E2E0 A0 00                    ..
        sta     ($88),y                         ; E2E2 91 88                    ..
        ldy     #$03                            ; E2E4 A0 03                    ..
        lda     ($88),y                         ; E2E6 B1 88                    ..
        ldy     #$01                            ; E2E8 A0 01                    ..
        sta     ($88),y                         ; E2EA 91 88                    ..
        jmp     dispatch                        ; E2EC 4C 93 D2                 L..

; ----------------------------------------------------------------------------
        ldy     #$01                            ; E2EF A0 01                    ..
        lda     ($58),y                         ; E2F1 B1 58                    .X
        sta     $82                             ; E2F3 85 82                    ..
        jsr     LE100                           ; E2F5 20 00 E1                  ..
        ldy     #$00                            ; E2F8 A0 00                    ..
        lda     $50                             ; E2FA A5 50                    .P
        sta     ($88),y                         ; E2FC 91 88                    ..
        lda     $51                             ; E2FE A5 51                    .Q
        iny                                     ; E300 C8                       .
        sta     ($88),y                         ; E301 91 88                    ..
        jmp     dispatch                        ; E303 4C 93 D2                 L..

; ----------------------------------------------------------------------------
        ldy     #$02                            ; E306 A0 02                    ..
        lda     ($58),y                         ; E308 B1 58                    .X
        sta     $82                             ; E30A 85 82                    ..
        ldy     #$01                            ; E30C A0 01                    ..
        lda     ($58),y                         ; E30E B1 58                    .X
        sta     L0090                           ; E310 85 90                    ..
        beq     LE317                           ; E312 F0 03                    ..
        jsr     load_segment                    ; E314 20 E9 E4                  ..
LE317:  inc     $58                             ; E317 E6 58                    .X
        bne     LE31D                           ; E319 D0 02                    ..
        inc     $59                             ; E31B E6 59                    .Y
LE31D:  jsr     prepare_procedure_call          ; E31D 20 E5 E0                  ..
        ldy     #$09                            ; E320 A0 09                    ..
        lda     ($86),y                         ; E322 B1 86                    ..
        beq     LE334                           ; E324 F0 0E                    ..
        bmi     LE334                           ; E326 30 0C                    0.
        jmp     LE28E                           ; E328 4C 8E E2                 L..

; ----------------------------------------------------------------------------
        ldy     #$01                            ; E32B A0 01                    ..
        lda     ($58),y                         ; E32D B1 58                    .X
        sta     $82                             ; E32F 85 82                    ..
        jsr     LE100                           ; E331 20 00 E1                  ..
LE334:  lda     $51                             ; E334 A5 51                    .Q
        pha                                     ; E336 48                       H
        lda     $50                             ; E337 A5 50                    .P
        pha                                     ; E339 48                       H
        tsx                                     ; E33A BA                       .
        txa                                     ; E33B 8A                       .
        ldy     #$0A                            ; E33C A0 0A                    ..
        sta     ($88),y                         ; E33E 91 88                    ..
        ldy     #$00                            ; E340 A0 00                    ..
        lda     ($50),y                         ; E342 B1 50                    .P
        sta     ($88),y                         ; E344 91 88                    ..
        iny                                     ; E346 C8                       .
        lda     ($50),y                         ; E347 B1 50                    .P
        sta     ($88),y                         ; E349 91 88                    ..
        lda     $88                             ; E34B A5 88                    ..
        sta     $50                             ; E34D 85 50                    .P
        sta     $BDEA                           ; E34F 8D EA BD                 ...
        lda     $89                             ; E352 A5 89                    ..
        sta     $51                             ; E354 85 51                    .Q
        sta     $BDEB                           ; E356 8D EB BD                 ...
        jmp     dispatch                        ; E359 4C 93 D2                 L..

; ----------------------------------------------------------------------------
        ldy     #$0A                            ; E35C A0 0A                    ..
        lda     ($52),y                         ; E35E B1 52                    .R
        tax                                     ; E360 AA                       .
        txs                                     ; E361 9A                       .
        pla                                     ; E362 68                       h
        sta     $50                             ; E363 85 50                    .P
        sta     $BDEA                           ; E365 8D EA BD                 ...
        pla                                     ; E368 68                       h
        sta     $51                             ; E369 85 51                    .Q
        sta     $BDEB                           ; E36B 8D EB BD                 ...
        jmp     LE377                           ; E36E 4C 77 E3                 Lw.

; ----------------------------------------------------------------------------
        ldy     #$0A                            ; E371 A0 0A                    ..
        lda     ($52),y                         ; E373 B1 52                    .R
        tax                                     ; E375 AA                       .
        txs                                     ; E376 9A                       .
LE377:  lda     $52                             ; E377 A5 52                    .R
        sec                                     ; E379 38                       8
        sbc     #$02                            ; E37A E9 02                    ..
        sta     $7E                             ; E37C 85 7E                    .~
        lda     $53                             ; E37E A5 53                    .S
        sbc     #$00                            ; E380 E9 00                    ..
        sta     $7F                             ; E382 85 7F                    ..
        ldy     #$00                            ; E384 A0 00                    ..
        lda     ($7E),y                         ; E386 B1 7E                    .~
        sta     $5C                             ; E388 85 5C                    .\
        iny                                     ; E38A C8                       .
        lda     ($7E),y                         ; E38B B1 7E                    .~
        sta     $5D                             ; E38D 85 5D                    .]
        ldy     #$01                            ; E38F A0 01                    ..
        lda     ($58),y                         ; E391 B1 58                    .X
        asl     a                               ; E393 0A                       .
        clc                                     ; E394 18                       .
        adc     #$0B                            ; E395 69 0B                    i.
        tay                                     ; E397 A8                       .
LE398:  cpy     #$0B                            ; E398 C0 0B                    ..
        beq     LE3A3                           ; E39A F0 07                    ..
        lda     ($52),y                         ; E39C B1 52                    .R
        pha                                     ; E39E 48                       H
        dey                                     ; E39F 88                       .
        jmp     LE398                           ; E3A0 4C 98 E3                 L..

; ----------------------------------------------------------------------------
LE3A3:  ldy     #$06                            ; E3A3 A0 06                    ..
        lda     ($52),y                         ; E3A5 B1 52                    .R
        sta     $7E                             ; E3A7 85 7E                    .~
        iny                                     ; E3A9 C8                       .
        lda     ($52),y                         ; E3AA B1 52                    .R
        sta     $7F                             ; E3AC 85 7F                    ..
        ldy     #$00                            ; E3AE A0 00                    ..
        lda     ($56),y                         ; E3B0 B1 56                    .V
        cmp     ($7E),y                         ; E3B2 D1 7E                    .~
        beq     LE3C1                           ; E3B4 F0 0B                    ..
        jsr     release_segment                 ; E3B6 20 46 E6                  F.
        lda     $7E                             ; E3B9 A5 7E                    .~
        sta     $56                             ; E3BB 85 56                    .V
        lda     $7F                             ; E3BD A5 7F                    ..
        sta     $57                             ; E3BF 85 57                    .W
LE3C1:  ldy     #$04                            ; E3C1 A0 04                    ..
        lda     ($52),y                         ; E3C3 B1 52                    .R
        sta     $54                             ; E3C5 85 54                    .T
        iny                                     ; E3C7 C8                       .
        lda     ($52),y                         ; E3C8 B1 52                    .R
        sta     $55                             ; E3CA 85 55                    .U
        ldy     #$08                            ; E3CC A0 08                    ..
        lda     ($52),y                         ; E3CE B1 52                    .R
        sta     $58                             ; E3D0 85 58                    .X
        iny                                     ; E3D2 C8                       .
        lda     ($52),y                         ; E3D3 B1 52                    .R
        sta     $59                             ; E3D5 85 59                    .Y
        ldy     #$03                            ; E3D7 A0 03                    ..
        lda     ($52),y                         ; E3D9 B1 52                    .R
        tax                                     ; E3DB AA                       .
        dey                                     ; E3DC 88                       .
        lda     ($52),y                         ; E3DD B1 52                    .R
        sta     $52                             ; E3DF 85 52                    .R
        sta     $BDEC                           ; E3E1 8D EC BD                 ...
        stx     $53                             ; E3E4 86 53                    .S
        stx     $BDED                           ; E3E6 8E ED BD                 ...
        jmp     dispatch                        ; E3E9 4C 93 D2                 L..

; ----------------------------------------------------------------------------
LE3EC:  ldy     #$00                            ; E3EC A0 00                    ..
        sec                                     ; E3EE 38                       8
        lda     L009A                           ; E3EF A5 9A                    ..
        sbc     (L009A),y                       ; E3F1 F1 9A                    ..
        sta     $86                             ; E3F3 85 86                    ..
        lda     $9B                             ; E3F5 A5 9B                    ..
        iny                                     ; E3F7 C8                       .
        sbc     (L009A),y                       ; E3F8 F1 9A                    ..
        sta     $87                             ; E3FA 85 87                    ..
        rts                                     ; E3FC 60                       `

; ----------------------------------------------------------------------------
LE3FD:  ldy     #$00                            ; E3FD A0 00                    ..
        lda     ($86),y                         ; E3FF B1 86                    ..
        tax                                     ; E401 AA                       .
        inx                                     ; E402 E8                       .
        iny                                     ; E403 C8                       .
        lda     ($86),y                         ; E404 B1 86                    ..
        sta     $8E                             ; E406 85 8E                    ..
        jmp     LE42A                           ; E408 4C 2A E4                 L*.

; ----------------------------------------------------------------------------
LE40B:  ldy     #$00                            ; E40B A0 00                    ..
        sec                                     ; E40D 38                       8
        lda     $86                             ; E40E A5 86                    ..
        sbc     ($86),y                         ; E410 F1 86                    ..
        sta     $7E                             ; E412 85 7E                    .~
        iny                                     ; E414 C8                       .
        lda     $87                             ; E415 A5 87                    ..
        sbc     ($86),y                         ; E417 F1 86                    ..
        sta     $7F                             ; E419 85 7F                    ..
        clc                                     ; E41B 18                       .
        dey                                     ; E41C 88                       .
        lda     ($7E),y                         ; E41D B1 7E                    .~
        adc     L0092                           ; E41F 65 92                    e.
        sta     ($7E),y                         ; E421 91 7E                    .~
        iny                                     ; E423 C8                       .
        lda     ($7E),y                         ; E424 B1 7E                    .~
        adc     $93                             ; E426 65 93                    e.
        sta     ($7E),y                         ; E428 91 7E                    .~
LE42A:  lda     $86                             ; E42A A5 86                    ..
        sec                                     ; E42C 38                       8
        sbc     #$02                            ; E42D E9 02                    ..
        sta     $86                             ; E42F 85 86                    ..
        bcs     LE435                           ; E431 B0 02                    ..
        dec     $87                             ; E433 C6 87                    ..
LE435:  dex                                     ; E435 CA                       .
        bne     LE40B                           ; E436 D0 D3                    ..
        dec     $8E                             ; E438 C6 8E                    ..
        bpl     LE40B                           ; E43A 10 CF                    ..
        rts                                     ; E43C 60                       `

; ----------------------------------------------------------------------------
LE43D:  lda     $BF33                           ; E43D AD 33 BF                 .3.
        bpl     LE446                           ; E440 10 04                    ..
        inc     $5B                             ; E442 E6 5B                    .[
        inc     $5B                             ; E444 E6 5B                    .[
LE446:  rts                                     ; E446 60                       `

; ----------------------------------------------------------------------------
LE447:  lda     $BF33                           ; E447 AD 33 BF                 .3.
        bpl     LE450                           ; E44A 10 04                    ..
        dec     $5B                             ; E44C C6 5B                    .[
        dec     $5B                             ; E44E C6 5B                    .[
LE450:  rts                                     ; E450 60                       `

; ----------------------------------------------------------------------------
LE451:  lda     $5C                             ; E451 A5 5C                    .\
        sbc     $5A                             ; E453 E5 5A                    .Z
        lda     $5D                             ; E455 A5 5D                    .]
        sbc     $5B                             ; E457 E5 5B                    .[
        bcs     LE469                           ; E459 B0 0E                    ..
        jsr     LD190                           ; E45B 20 90 D1                  ..
        sec                                     ; E45E 38                       8
        lda     $5C                             ; E45F A5 5C                    .\
        sbc     $5A                             ; E461 E5 5A                    .Z
        lda     $5D                             ; E463 A5 5D                    .]
        sbc     $5B                             ; E465 E5 5B                    .[
        bcc     LE46A                           ; E467 90 01                    ..
LE469:  rts                                     ; E469 60                       `

; ----------------------------------------------------------------------------
LE46A:  jmp     LD1C3                           ; E46A 4C C3 D1                 L..

; ----------------------------------------------------------------------------
read_segment:
        sta     $7E                             ; E46D 85 7E                    .~
        asl     a                               ; E46F 0A                       .
        clc                                     ; E470 18                       .
        adc     $7E                             ; E471 65 7E                    e~
        asl     a                               ; E473 0A                       .
        tax                                     ; E474 AA                       .
        lda     #$00                            ; E475 A9 00                    ..
        pha                                     ; E477 48                       H
        pha                                     ; E478 48                       H
        pha                                     ; E479 48                       H
        lda     $BE3E,x                         ; E47A BD 3E BE                 .>.
        asl     a                               ; E47D 0A                       .
        tay                                     ; E47E A8                       .
        lda     $FEAF,y                         ; E47F B9 AF FE                 ...
        beq     LE48D                           ; E482 F0 09                    ..
        cmp     #$FF                            ; E484 C9 FF                    ..
        beq     LE4E5                           ; E486 F0 5D                    .]
        lda     $BE3E,x                         ; E488 BD 3E BE                 .>.
        bpl     LE490                           ; E48B 10 03                    ..
LE48D:  lda     $FEAE,y                         ; E48D B9 AE FE                 ...
LE490:  pha                                     ; E490 48                       H
        lda     $BE42,x                         ; E491 BD 42 BE                 .B.
        sta     $80                             ; E494 85 80                    ..
        lda     $BE43,x                         ; E496 BD 43 BE                 .C.
        sta     $81                             ; E499 85 81                    ..
        lda     $5C                             ; E49B A5 5C                    .\
        sec                                     ; E49D 38                       8
        sbc     $80                             ; E49E E5 80                    ..
        sta     $5C                             ; E4A0 85 5C                    .\
        lda     $5D                             ; E4A2 A5 5D                    .]
        sbc     $81                             ; E4A4 E5 81                    ..
        sta     $5D                             ; E4A6 85 5D                    .]
        bcc     LE46A                           ; E4A8 90 C0                    ..
        jsr     LE43D                           ; E4AA 20 3D E4                  =.
        jsr     LE451                           ; E4AD 20 51 E4                  Q.
        jsr     LE447                           ; E4B0 20 47 E4                  G.
        lda     $5D                             ; E4B3 A5 5D                    .]
        sta     $99                             ; E4B5 85 99                    ..
        pha                                     ; E4B7 48                       H
        lda     $5C                             ; E4B8 A5 5C                    .\
        sta     L0098                           ; E4BA 85 98                    ..
        pha                                     ; E4BC 48                       H
        lda     $81                             ; E4BD A5 81                    ..
        pha                                     ; E4BF 48                       H
        lda     $80                             ; E4C0 A5 80                    ..
        pha                                     ; E4C2 48                       H
        lda     $BE41,x                         ; E4C3 BD 41 BE                 .A.
        pha                                     ; E4C6 48                       H
        lda     $BE40,x                         ; E4C7 BD 40 BE                 .@.
        pha                                     ; E4CA 48                       H
        lda     $FEAF,y                         ; E4CB B9 AF FE                 ...
        beq     LE4DB                           ; E4CE F0 0B                    ..
        lda     $BE3E,x                         ; E4D0 BD 3E BE                 .>.
        ldx     #$00                            ; E4D3 A2 00                    ..
        jsr     LFF3C                           ; E4D5 20 3C FF                  <.
        jmp     segment_read_result             ; E4D8 4C DE E4                 L..

; ----------------------------------------------------------------------------
LE4DB:  jsr     LFF12                           ; E4DB 20 12 FF                  ..
segment_read_result:
        cpx     #$00                            ; E4DE E0 00                    ..
        beq     LE4E8                           ; E4E0 F0 06                    ..
        stx     $BDDE                           ; E4E2 8E DE BD                 ...
LE4E5:  jmp     LD1E7                           ; E4E5 4C E7 D1                 L..

; ----------------------------------------------------------------------------
LE4E8:  rts                                     ; E4E8 60                       `

; ----------------------------------------------------------------------------
load_segment:
        sta     L0090                           ; E4E9 85 90                    ..
        asl     a                               ; E4EB 0A                       .
        tay                                     ; E4EC A8                       .
        lda     $BD1E,y                         ; E4ED B9 1E BD                 ...
        bne     LE4F7                           ; E4F0 D0 05                    ..
        lda     $BD1F,y                         ; E4F2 B9 1F BD                 ...
        beq     LE502                           ; E4F5 F0 0B                    ..
LE4F7:  tya                                     ; E4F7 98                       .
        tax                                     ; E4F8 AA                       .
        inc     $BD1E,x                         ; E4F9 FE 1E BD                 ...
        bne     LE501                           ; E4FC D0 03                    ..
        inc     $BD1F,x                         ; E4FE FE 1F BD                 ...
LE501:  rts                                     ; E501 60                       `

; ----------------------------------------------------------------------------
LE502:  lda     $5C                             ; E502 A5 5C                    .\
        sta     $BD5E,y                         ; E504 99 5E BD                 .^.
        lda     $5D                             ; E507 A5 5D                    .]
        sta     $BD5F,y                         ; E509 99 5F BD                 ._.
        lda     #$01                            ; E50C A9 01                    ..
        sta     $BD1E,y                         ; E50E 99 1E BD                 ...
        tya                                     ; E511 98                       .
        sta     $7E                             ; E512 85 7E                    .~
        asl     a                               ; E514 0A                       .
        clc                                     ; E515 18                       .
        adc     $7E                             ; E516 65 7E                    e~
        tax                                     ; E518 AA                       .
        lda     $BE40,x                         ; E519 BD 40 BE                 .@.
        bne     LE54A                           ; E51C D0 2C                    .,
        lda     $BE41,x                         ; E51E BD 41 BE                 .A.
        bne     LE54A                           ; E521 D0 27                    .'
        sec                                     ; E523 38                       8
        lda     $5C                             ; E524 A5 5C                    .\
        sbc     $BE42,x                         ; E526 FD 42 BE                 .B.
        sta     $5C                             ; E529 85 5C                    .\
        lda     $5D                             ; E52B A5 5D                    .]
        sbc     $BE43,x                         ; E52D FD 43 BE                 .C.
        sta     $5D                             ; E530 85 5D                    .]
        bcc     LE547                           ; E532 90 13                    ..
        jsr     LE451                           ; E534 20 51 E4                  Q.
        lda     $5C                             ; E537 A5 5C                    .\
        sec                                     ; E539 38                       8
        sbc     #$02                            ; E53A E9 02                    ..
        sta     $BD9E,y                         ; E53C 99 9E BD                 ...
        lda     $5D                             ; E53F A5 5D                    .]
        sbc     #$00                            ; E541 E9 00                    ..
        sta     $BD9F,y                         ; E543 99 9F BD                 ...
        rts                                     ; E546 60                       `

; ----------------------------------------------------------------------------
LE547:  jmp     LD1C3                           ; E547 4C C3 D1                 L..

; ----------------------------------------------------------------------------
LE54A:  sec                                     ; E54A 38                       8
        lda     $5C                             ; E54B A5 5C                    .\
        sbc     #$02                            ; E54D E9 02                    ..
        sta     $BD9E,y                         ; E54F 99 9E BD                 ...
        sta     L009A                           ; E552 85 9A                    ..
        lda     $5D                             ; E554 A5 5D                    .]
        sbc     #$00                            ; E556 E9 00                    ..
        sta     $BD9F,y                         ; E558 99 9F BD                 ...
        sta     $9B                             ; E55B 85 9B                    ..
        lda     L0090                           ; E55D A5 90                    ..
        jsr     read_segment                    ; E55F 20 6D E4                  m.
        ldy     #$01                            ; E562 A0 01                    ..
        lda     (L009A),y                       ; E564 B1 9A                    ..
        sta     $84                             ; E566 85 84                    ..
        lda     L009A                           ; E568 A5 9A                    ..
        sec                                     ; E56A 38                       8
        sbc     #$02                            ; E56B E9 02                    ..
        sta     L009A                           ; E56D 85 9A                    ..
        bcs     LE573                           ; E56F B0 02                    ..
        dec     $9B                             ; E571 C6 9B                    ..
LE573:  jsr     LE3EC                           ; E573 20 EC E3                  ..
        ldy     #$01                            ; E576 A0 01                    ..
        lda     ($86),y                         ; E578 B1 86                    ..
        cmp     #$01                            ; E57A C9 01                    ..
        bcs     LE5B3                           ; E57C B0 35                    .5
        lda     $86                             ; E57E A5 86                    ..
        sec                                     ; E580 38                       8
        sbc     #$08                            ; E581 E9 08                    ..
        sta     $86                             ; E583 85 86                    ..
        bcs     LE589                           ; E585 B0 02                    ..
        dec     $87                             ; E587 C6 87                    ..
LE589:  sec                                     ; E589 38                       8
        ldy     #$00                            ; E58A A0 00                    ..
        lda     $5C                             ; E58C A5 5C                    .\
        sbc     ($86),y                         ; E58E F1 86                    ..
        sta     $96                             ; E590 85 96                    ..
        iny                                     ; E592 C8                       .
        lda     $5D                             ; E593 A5 5D                    .]
        sbc     ($86),y                         ; E595 F1 86                    ..
        sta     $97                             ; E597 85 97                    ..
        iny                                     ; E599 C8                       .
        sec                                     ; E59A 38                       8
        lda     $96                             ; E59B A5 96                    ..
        sbc     ($86),y                         ; E59D F1 86                    ..
        sta     $96                             ; E59F 85 96                    ..
        bcs     LE5A5                           ; E5A1 B0 02                    ..
        dec     $97                             ; E5A3 C6 97                    ..
LE5A5:  lda     $96                             ; E5A5 A5 96                    ..
        sec                                     ; E5A7 38                       8
        sbc     #$0C                            ; E5A8 E9 0C                    ..
        sta     $96                             ; E5AA 85 96                    ..
        bcs     LE5B0                           ; E5AC B0 02                    ..
        dec     $97                             ; E5AE C6 97                    ..
LE5B0:  jmp     LE5BB                           ; E5B0 4C BB E5                 L..

; ----------------------------------------------------------------------------
LE5B3:  lda     $50                             ; E5B3 A5 50                    .P
        sta     $96                             ; E5B5 85 96                    ..
        lda     $51                             ; E5B7 A5 51                    .Q
        sta     $97                             ; E5B9 85 97                    ..
LE5BB:  jsr     LE3EC                           ; E5BB 20 EC E3                  ..
        ldy     #$00                            ; E5BE A0 00                    ..
        lda     ($86),y                         ; E5C0 B1 86                    ..
        beq     LE5C7                           ; E5C2 F0 03                    ..
        jmp     LE633                           ; E5C4 4C 33 E6                 L3.

; ----------------------------------------------------------------------------
LE5C7:  lda     $86                             ; E5C7 A5 86                    ..
        sec                                     ; E5C9 38                       8
        sbc     #$02                            ; E5CA E9 02                    ..
        sta     $86                             ; E5CC 85 86                    ..
        bcs     LE5D2                           ; E5CE B0 02                    ..
        dec     $87                             ; E5D0 C6 87                    ..
LE5D2:  sec                                     ; E5D2 38                       8
        lda     $86                             ; E5D3 A5 86                    ..
        sbc     ($86),y                         ; E5D5 F1 86                    ..
        sta     L0094                           ; E5D7 85 94                    ..
        iny                                     ; E5D9 C8                       .
        lda     $87                             ; E5DA A5 87                    ..
        sbc     ($86),y                         ; E5DC F1 86                    ..
        sta     $95                             ; E5DE 85 95                    ..
        lda     $86                             ; E5E0 A5 86                    ..
        sec                                     ; E5E2 38                       8
        sbc     #$02                            ; E5E3 E9 02                    ..
        sta     $86                             ; E5E5 85 86                    ..
        bcs     LE5EB                           ; E5E7 B0 02                    ..
        dec     $87                             ; E5E9 C6 87                    ..
LE5EB:  ldy     #$05                            ; E5EB A0 05                    ..
        lda     ($86),y                         ; E5ED B1 86                    ..
        beq     LE605                           ; E5EF F0 14                    ..
        asl     a                               ; E5F1 0A                       .
        tay                                     ; E5F2 A8                       .
        lda     $BD9E,y                         ; E5F3 B9 9E BD                 ...
        clc                                     ; E5F6 18                       .
        adc     #$02                            ; E5F7 69 02                    i.
        sta     L0092                           ; E5F9 85 92                    ..
        lda     $BD9F,y                         ; E5FB B9 9F BD                 ...
        adc     #$00                            ; E5FE 69 00                    i.
        sta     $93                             ; E600 85 93                    ..
        jmp     LE60D                           ; E602 4C 0D E6                 L..

; ----------------------------------------------------------------------------
LE605:  lda     $96                             ; E605 A5 96                    ..
        sta     L0092                           ; E607 85 92                    ..
        lda     $97                             ; E609 A5 97                    ..
        sta     $93                             ; E60B 85 93                    ..
LE60D:  jsr     LE3FD                           ; E60D 20 FD E3                  ..
        lda     L0098                           ; E610 A5 98                    ..
        sta     L0092                           ; E612 85 92                    ..
        lda     $99                             ; E614 A5 99                    ..
        sta     $93                             ; E616 85 93                    ..
        jsr     LE3FD                           ; E618 20 FD E3                  ..
        lda     L0094                           ; E61B A5 94                    ..
        sta     L0092                           ; E61D 85 92                    ..
        lda     $95                             ; E61F A5 95                    ..
        sta     $93                             ; E621 85 93                    ..
        jsr     LE3FD                           ; E623 20 FD E3                  ..
        lda     $D1AD                           ; E626 AD AD D1                 ...
        sta     L0092                           ; E629 85 92                    ..
        lda     $D1AE                           ; E62B AD AE D1                 ...
        sta     $93                             ; E62E 85 93                    ..
        jsr     LE3FD                           ; E630 20 FD E3                  ..
LE633:  lda     L009A                           ; E633 A5 9A                    ..
        sec                                     ; E635 38                       8
        sbc     #$02                            ; E636 E9 02                    ..
        sta     L009A                           ; E638 85 9A                    ..
        bcs     LE63E                           ; E63A B0 02                    ..
        dec     $9B                             ; E63C C6 9B                    ..
LE63E:  dec     $84                             ; E63E C6 84                    ..
        beq     LE645                           ; E640 F0 03                    ..
        jmp     LE5BB                           ; E642 4C BB E5                 L..

; ----------------------------------------------------------------------------
LE645:  rts                                     ; E645 60                       `

; ----------------------------------------------------------------------------
release_segment:
        asl     a                               ; E646 0A                       .
        tax                                     ; E647 AA                       .
        beq     LE66A                           ; E648 F0 20                    . 
        sec                                     ; E64A 38                       8
        lda     $BD1E,x                         ; E64B BD 1E BD                 ...
        sbc     #$01                            ; E64E E9 01                    ..
        sta     $BD1E,x                         ; E650 9D 1E BD                 ...
        bcs     LE659                           ; E653 B0 04                    ..
        dec     $BD1F,x                         ; E655 DE 1F BD                 ...
        rts                                     ; E658 60                       `

; ----------------------------------------------------------------------------
LE659:  bne     LE66A                           ; E659 D0 0F                    ..
        lda     $BD1F,x                         ; E65B BD 1F BD                 ...
        bne     LE66A                           ; E65E D0 0A                    ..
        lda     $BD5E,x                         ; E660 BD 5E BD                 .^.
        sta     $5C                             ; E663 85 5C                    .\
        lda     $BD5F,x                         ; E665 BD 5F BD                 ._.
        sta     $5D                             ; E668 85 5D                    .]
LE66A:  rts                                     ; E66A 60                       `

; ----------------------------------------------------------------------------
        pla                                     ; E66B 68                       h
        tax                                     ; E66C AA                       .
        pla                                     ; E66D 68                       h
        txa                                     ; E66E 8A                       .
        jsr     load_segment                    ; E66F 20 E9 E4                  ..
        jmp     advance_two                     ; E672 4C 7B D2                 L{.

; ----------------------------------------------------------------------------
        pla                                     ; E675 68                       h
        tax                                     ; E676 AA                       .
        pla                                     ; E677 68                       h
        txa                                     ; E678 8A                       .
        jsr     release_segment                 ; E679 20 46 E6                  F.
        jmp     advance_two                     ; E67C 4C 7B D2                 L{.

; ----------------------------------------------------------------------------
call_standard_procedure:
        ldy     #$01                            ; E67F A0 01                    ..
        lda     ($58),y                         ; E681 B1 58                    .X
        asl     a                               ; E683 0A                       .
        sta     standard_procedure_jump+1       ; E684 8D 88 E6                 ...
standard_procedure_jump:
        jmp     (standard_proc_vectors)         ; E687 6C 00 D1                 l..

; ----------------------------------------------------------------------------
fill_bytes:
        pla                                     ; E68A 68                       h
        tax                                     ; E68B AA                       .
        pla                                     ; E68C 68                       h
        pla                                     ; E68D 68                       h
        sta     $68                             ; E68E 85 68                    .h
        pla                                     ; E690 68                       h
        sta     $69                             ; E691 85 69                    .i
        bpl     LE69C                           ; E693 10 07                    ..
        pla                                     ; E695 68                       h
        pla                                     ; E696 68                       h
        pla                                     ; E697 68                       h
        pla                                     ; E698 68                       h
        jmp     advance_two                     ; E699 4C 7B D2                 L{.

; ----------------------------------------------------------------------------
LE69C:  pla                                     ; E69C 68                       h
        sta     $74                             ; E69D 85 74                    .t
        pla                                     ; E69F 68                       h
        sta     $75                             ; E6A0 85 75                    .u
        clc                                     ; E6A2 18                       .
        pla                                     ; E6A3 68                       h
        adc     $74                             ; E6A4 65 74                    et
        sta     $74                             ; E6A6 85 74                    .t
        pla                                     ; E6A8 68                       h
        adc     $75                             ; E6A9 65 75                    eu
        sta     $75                             ; E6AB 85 75                    .u
        txa                                     ; E6AD 8A                       .
        ldx     $69                             ; E6AE A6 69                    .i
        ldy     #$00                            ; E6B0 A0 00                    ..
LE6B2:  cpx     #$00                            ; E6B2 E0 00                    ..
        beq     LE6C1                           ; E6B4 F0 0B                    ..
        dex                                     ; E6B6 CA                       .
LE6B7:  sta     ($74),y                         ; E6B7 91 74                    .t
        iny                                     ; E6B9 C8                       .
        bne     LE6B7                           ; E6BA D0 FB                    ..
        inc     $75                             ; E6BC E6 75                    .u
        jmp     LE6B2                           ; E6BE 4C B2 E6                 L..

; ----------------------------------------------------------------------------
LE6C1:  ldx     $68                             ; E6C1 A6 68                    .h
        jmp     LE6CA                           ; E6C3 4C CA E6                 L..

; ----------------------------------------------------------------------------
LE6C6:  sta     ($74),y                         ; E6C6 91 74                    .t
        iny                                     ; E6C8 C8                       .
        dex                                     ; E6C9 CA                       .
LE6CA:  bne     LE6C6                           ; E6CA D0 FA                    ..
        jmp     advance_two                     ; E6CC 4C 7B D2                 L{.

; ----------------------------------------------------------------------------
        pla                                     ; E6CF 68                       h
        pla                                     ; E6D0 68                       h
        pla                                     ; E6D1 68                       h
        sta     $86                             ; E6D2 85 86                    ..
        pla                                     ; E6D4 68                       h
        sta     $87                             ; E6D5 85 87                    ..
        clc                                     ; E6D7 18                       .
        pla                                     ; E6D8 68                       h
        adc     $86                             ; E6D9 65 86                    e.
        sta     $86                             ; E6DB 85 86                    ..
        sta     $8E                             ; E6DD 85 8E                    ..
        pla                                     ; E6DF 68                       h
        adc     $87                             ; E6E0 65 87                    e.
        sta     $87                             ; E6E2 85 87                    ..
        sta     $8F                             ; E6E4 85 8F                    ..
        pla                                     ; E6E6 68                       h
        sta     L0092                           ; E6E7 85 92                    ..
        pla                                     ; E6E9 68                       h
        pla                                     ; E6EA 68                       h
        sta     L0094                           ; E6EB 85 94                    ..
        pla                                     ; E6ED 68                       h
        pla                                     ; E6EE 68                       h
        sta     $68                             ; E6EF 85 68                    .h
        clc                                     ; E6F1 18                       .
        adc     $8E                             ; E6F2 65 8E                    e.
        sta     $8A                             ; E6F4 85 8A                    ..
        pla                                     ; E6F6 68                       h
        sta     $69                             ; E6F7 85 69                    .i
        sta     L0090                           ; E6F9 85 90                    ..
        adc     $8F                             ; E6FB 65 8F                    e.
        sta     $8B                             ; E6FD 85 8B                    ..
        bpl     LE712                           ; E6FF 10 11                    ..
        tax                                     ; E701 AA                       .
        lda     $68                             ; E702 A5 68                    .h
        eor     #$FF                            ; E704 49 FF                    I.
        clc                                     ; E706 18                       .
        adc     #$01                            ; E707 69 01                    i.
        sta     $68                             ; E709 85 68                    .h
        txa                                     ; E70B 8A                       .
        eor     #$FF                            ; E70C 49 FF                    I.
        adc     #$00                            ; E70E 69 00                    i.
        sta     $69                             ; E710 85 69                    .i
LE712:  ldy     #$00                            ; E712 A0 00                    ..
LE714:  lda     ($86),y                         ; E714 B1 86                    ..
        cmp     L0092                           ; E716 C5 92                    ..
        bne     LE721                           ; E718 D0 07                    ..
        lda     L0094                           ; E71A A5 94                    ..
        beq     LE74C                           ; E71C F0 2E                    ..
        jmp     LE725                           ; E71E 4C 25 E7                 L%.

; ----------------------------------------------------------------------------
LE721:  lda     L0094                           ; E721 A5 94                    ..
        bne     LE74C                           ; E723 D0 27                    .'
LE725:  lda     $8A                             ; E725 A5 8A                    ..
        cmp     $86                             ; E727 C5 86                    ..
        bne     LE731                           ; E729 D0 06                    ..
        lda     $8B                             ; E72B A5 8B                    ..
        cmp     $87                             ; E72D C5 87                    ..
        beq     LE74C                           ; E72F F0 1B                    ..
LE731:  lda     L0090                           ; E731 A5 90                    ..
        bmi     LE73E                           ; E733 30 09                    0.
        inc     $86                             ; E735 E6 86                    ..
        bne     LE714                           ; E737 D0 DB                    ..
        inc     $87                             ; E739 E6 87                    ..
        jmp     LE714                           ; E73B 4C 14 E7                 L..

; ----------------------------------------------------------------------------
LE73E:  lda     $86                             ; E73E A5 86                    ..
        sec                                     ; E740 38                       8
        sbc     #$01                            ; E741 E9 01                    ..
        sta     $86                             ; E743 85 86                    ..
        bcs     LE714                           ; E745 B0 CD                    ..
        dec     $87                             ; E747 C6 87                    ..
        jmp     LE714                           ; E749 4C 14 E7                 L..

; ----------------------------------------------------------------------------
LE74C:  lda     $86                             ; E74C A5 86                    ..
        sec                                     ; E74E 38                       8
        sbc     $8E                             ; E74F E5 8E                    ..
        tax                                     ; E751 AA                       .
        lda     $87                             ; E752 A5 87                    ..
        sbc     $8F                             ; E754 E5 8F                    ..
        pha                                     ; E756 48                       H
        txa                                     ; E757 8A                       .
        pha                                     ; E758 48                       H
        jmp     advance_two                     ; E759 4C 7B D2                 L{.

; ----------------------------------------------------------------------------
        pla                                     ; E75C 68                       h
        sta     $82                             ; E75D 85 82                    ..
        pla                                     ; E75F 68                       h
        pla                                     ; E760 68                       h
        sta     L0090                           ; E761 85 90                    ..
        pla                                     ; E763 68                       h
        ldy     #$01                            ; E764 A0 01                    ..
        lda     ($54),y                         ; E766 B1 54                    .T
        bpl     LE76D                           ; E768 10 03                    ..
        jmp     LD6E4                           ; E76A 4C E4 D6                 L..

; ----------------------------------------------------------------------------
LE76D:  lda     $54                             ; E76D A5 54                    .T
        sec                                     ; E76F 38                       8
        sbc     #$04                            ; E770 E9 04                    ..
        sta     $7E                             ; E772 85 7E                    .~
        lda     $55                             ; E774 A5 55                    .U
        sbc     #$00                            ; E776 E9 00                    ..
        sta     $7F                             ; E778 85 7F                    ..
        ldy     #$00                            ; E77A A0 00                    ..
        lda     $7E                             ; E77C A5 7E                    .~
        sec                                     ; E77E 38                       8
        sbc     ($7E),y                         ; E77F F1 7E                    .~
        sta     $58                             ; E781 85 58                    .X
        iny                                     ; E783 C8                       .
        lda     $7F                             ; E784 A5 7F                    ..
        sbc     ($7E),y                         ; E786 F1 7E                    .~
        sta     $59                             ; E788 85 59                    .Y
        dey                                     ; E78A 88                       .
        lda     $82                             ; E78B A5 82                    ..
        cmp     ($54),y                         ; E78D D1 54                    .T
        bne     LE79A                           ; E78F D0 09                    ..
        lda     L0090                           ; E791 A5 90                    ..
        cmp     ($56),y                         ; E793 D1 56                    .V
        bne     LE79A                           ; E795 D0 03                    ..
        jmp     dispatch                        ; E797 4C 93 D2                 L..

; ----------------------------------------------------------------------------
LE79A:  lda     $52                             ; E79A A5 52                    .R
        sta     L0092                           ; E79C 85 92                    ..
        lda     $53                             ; E79E A5 53                    .S
        sta     $93                             ; E7A0 85 93                    ..
        jmp     LE7B1                           ; E7A2 4C B1 E7                 L..

; ----------------------------------------------------------------------------
LE7A5:  ldy     #$02                            ; E7A5 A0 02                    ..
        lda     (L0092),y                       ; E7A7 B1 92                    ..
        tax                                     ; E7A9 AA                       .
        iny                                     ; E7AA C8                       .
        lda     (L0092),y                       ; E7AB B1 92                    ..
        sta     $93                             ; E7AD 85 93                    ..
        stx     L0092                           ; E7AF 86 92                    ..
LE7B1:  ldy     #$04                            ; E7B1 A0 04                    ..
        lda     (L0092),y                       ; E7B3 B1 92                    ..
        sta     $80                             ; E7B5 85 80                    ..
        iny                                     ; E7B7 C8                       .
        lda     (L0092),y                       ; E7B8 B1 92                    ..
        sta     $81                             ; E7BA 85 81                    ..
        ldy     #$01                            ; E7BC A0 01                    ..
        lda     ($80),y                         ; E7BE B1 80                    ..
        bpl     LE7C5                           ; E7C0 10 03                    ..
        jmp     LD1BF                           ; E7C2 4C BF D1                 L..

; ----------------------------------------------------------------------------
LE7C5:  lda     $80                             ; E7C5 A5 80                    ..
        sec                                     ; E7C7 38                       8
        sbc     #$04                            ; E7C8 E9 04                    ..
        sta     $80                             ; E7CA 85 80                    ..
        bcs     LE7D0                           ; E7CC B0 02                    ..
        dec     $81                             ; E7CE C6 81                    ..
LE7D0:  ldy     #$00                            ; E7D0 A0 00                    ..
        lda     $80                             ; E7D2 A5 80                    ..
        sec                                     ; E7D4 38                       8
        sbc     ($80),y                         ; E7D5 F1 80                    ..
        ldy     #$08                            ; E7D7 A0 08                    ..
        sta     (L0092),y                       ; E7D9 91 92                    ..
        ldy     #$01                            ; E7DB A0 01                    ..
        lda     $81                             ; E7DD A5 81                    ..
        sbc     ($80),y                         ; E7DF F1 80                    ..
        ldy     #$09                            ; E7E1 A0 09                    ..
        sta     (L0092),y                       ; E7E3 91 92                    ..
        ldy     #$04                            ; E7E5 A0 04                    ..
        lda     $82                             ; E7E7 A5 82                    ..
        cmp     ($80),y                         ; E7E9 D1 80                    ..
LE7EB:  bne     LE7A5                           ; E7EB D0 B8                    ..
        ldy     #$06                            ; E7ED A0 06                    ..
        lda     (L0092),y                       ; E7EF B1 92                    ..
        sta     $7E                             ; E7F1 85 7E                    .~
        iny                                     ; E7F3 C8                       .
        lda     (L0092),y                       ; E7F4 B1 92                    ..
        sta     $7F                             ; E7F6 85 7F                    ..
        lda     L0090                           ; E7F8 A5 90                    ..
        ldy     #$00                            ; E7FA A0 00                    ..
        cmp     ($7E),y                         ; E7FC D1 7E                    .~
        bne     LE7EB                           ; E7FE D0 EB                    ..
        jmp     dispatch                        ; E800 4C 93 D2                 L..

; ----------------------------------------------------------------------------
        ldy     #$01                            ; E803 A0 01                    ..
        jsr     LD155                           ; E805 20 55 D1                  U.
        jmp     advance_two                     ; E808 4C 7B D2                 L{.

; ----------------------------------------------------------------------------
        lda     $58                             ; E80B A5 58                    .X
        clc                                     ; E80D 18                       .
        adc     #$02                            ; E80E 69 02                    i.
        sta     $58                             ; E810 85 58                    .X
        bcc     LE816                           ; E812 90 02                    ..
        inc     $59                             ; E814 E6 59                    .Y
LE816:  jmp     LD1E3                           ; E816 4C E3 D1                 L..

; ----------------------------------------------------------------------------
        pla                                     ; E819 68                       h
        sta     $7E                             ; E81A 85 7E                    .~
        pla                                     ; E81C 68                       h
        sta     $7F                             ; E81D 85 7F                    ..
        pla                                     ; E81F 68                       h
        sta     $80                             ; E820 85 80                    ..
        pla                                     ; E822 68                       h
        sta     $81                             ; E823 85 81                    ..
        ldy     #$00                            ; E825 A0 00                    ..
        lda     #$00                            ; E827 A9 00                    ..
        sta     ($7E),y                         ; E829 91 7E                    .~
        sta     ($80),y                         ; E82B 91 80                    ..
        iny                                     ; E82D C8                       .
        sta     ($7E),y                         ; E82E 91 7E                    .~
        sta     ($80),y                         ; E830 91 80                    ..
        jmp     advance_two                     ; E832 4C 7B D2                 L{.

; ----------------------------------------------------------------------------
LE835:  lda     $72                             ; E835 A5 72                    .r
        clc                                     ; E837 18                       .
        adc     $68                             ; E838 65 68                    eh
        sta     $72                             ; E83A 85 72                    .r
        lda     $73                             ; E83C A5 73                    .s
        adc     $69                             ; E83E 65 69                    ei
        sta     $73                             ; E840 85 73                    .s
        lda     $74                             ; E842 A5 74                    .t
        clc                                     ; E844 18                       .
        adc     $68                             ; E845 65 68                    eh
        sta     $74                             ; E847 85 74                    .t
        lda     $75                             ; E849 A5 75                    .u
        adc     $69                             ; E84B 65 69                    ei
        sta     $75                             ; E84D 85 75                    .u
        ldy     #$FF                            ; E84F A0 FF                    ..
        ldx     $69                             ; E851 A6 69                    .i
LE853:  dec     $73                             ; E853 C6 73                    .s
        dec     $75                             ; E855 C6 75                    .u
        cpx     #$00                            ; E857 E0 00                    ..
        beq     LE868                           ; E859 F0 0D                    ..
        dex                                     ; E85B CA                       .
LE85C:  lda     ($72),y                         ; E85C B1 72                    .r
        sta     ($74),y                         ; E85E 91 74                    .t
        dey                                     ; E860 88                       .
        cpy     #$FF                            ; E861 C0 FF                    ..
        bne     LE85C                           ; E863 D0 F7                    ..
        jmp     LE853                           ; E865 4C 53 E8                 LS.

; ----------------------------------------------------------------------------
LE868:  ldx     $68                             ; E868 A6 68                    .h
        jmp     LE873                           ; E86A 4C 73 E8                 Ls.

; ----------------------------------------------------------------------------
LE86D:  lda     ($72),y                         ; E86D B1 72                    .r
        sta     ($74),y                         ; E86F 91 74                    .t
        dey                                     ; E871 88                       .
        dex                                     ; E872 CA                       .
LE873:  bne     LE86D                           ; E873 D0 F8                    ..
        jmp     advance_two                     ; E875 4C 7B D2                 L{.

; ----------------------------------------------------------------------------
        pla                                     ; E878 68                       h
        sta     $68                             ; E879 85 68                    .h
        pla                                     ; E87B 68                       h
        sta     $69                             ; E87C 85 69                    .i
        bmi     LE8D1                           ; E87E 30 51                    0Q
        pla                                     ; E880 68                       h
        sta     $74                             ; E881 85 74                    .t
        pla                                     ; E883 68                       h
        sta     $75                             ; E884 85 75                    .u
        clc                                     ; E886 18                       .
        pla                                     ; E887 68                       h
        adc     $74                             ; E888 65 74                    et
        sta     $74                             ; E88A 85 74                    .t
        pla                                     ; E88C 68                       h
        adc     $75                             ; E88D 65 75                    eu
        sta     $75                             ; E88F 85 75                    .u
        pla                                     ; E891 68                       h
        sta     $72                             ; E892 85 72                    .r
        pla                                     ; E894 68                       h
        sta     $73                             ; E895 85 73                    .s
        clc                                     ; E897 18                       .
        pla                                     ; E898 68                       h
        adc     $72                             ; E899 65 72                    er
        sta     $72                             ; E89B 85 72                    .r
        pla                                     ; E89D 68                       h
        adc     $73                             ; E89E 65 73                    es
        sta     $73                             ; E8A0 85 73                    .s
        ldy     #$01                            ; E8A2 A0 01                    ..
        lda     ($58),y                         ; E8A4 B1 58                    .X
        cmp     #$02                            ; E8A6 C9 02                    ..
        bne     LE835                           ; E8A8 D0 8B                    ..
        ldx     $69                             ; E8AA A6 69                    .i
        ldy     #$00                            ; E8AC A0 00                    ..
LE8AE:  cpx     #$00                            ; E8AE E0 00                    ..
        beq     LE8C1                           ; E8B0 F0 0F                    ..
        dex                                     ; E8B2 CA                       .
LE8B3:  lda     ($72),y                         ; E8B3 B1 72                    .r
        sta     ($74),y                         ; E8B5 91 74                    .t
        iny                                     ; E8B7 C8                       .
        bne     LE8B3                           ; E8B8 D0 F9                    ..
        inc     $75                             ; E8BA E6 75                    .u
        inc     $73                             ; E8BC E6 73                    .s
        jmp     LE8AE                           ; E8BE 4C AE E8                 L..

; ----------------------------------------------------------------------------
LE8C1:  ldx     $68                             ; E8C1 A6 68                    .h
        jmp     LE8CC                           ; E8C3 4C CC E8                 L..

; ----------------------------------------------------------------------------
LE8C6:  lda     ($72),y                         ; E8C6 B1 72                    .r
        sta     ($74),y                         ; E8C8 91 74                    .t
        iny                                     ; E8CA C8                       .
        dex                                     ; E8CB CA                       .
LE8CC:  bne     LE8C6                           ; E8CC D0 F8                    ..
        jmp     advance_two                     ; E8CE 4C 7B D2                 L{.

; ----------------------------------------------------------------------------
LE8D1:  pla                                     ; E8D1 68                       h
        pla                                     ; E8D2 68                       h
        pla                                     ; E8D3 68                       h
        pla                                     ; E8D4 68                       h
        pla                                     ; E8D5 68                       h
        pla                                     ; E8D6 68                       h
        pla                                     ; E8D7 68                       h
        pla                                     ; E8D8 68                       h
        jmp     advance_two                     ; E8D9 4C 7B D2                 L{.

; ----------------------------------------------------------------------------
        sec                                     ; E8DC 38                       8
        lda     $BDE7                           ; E8DD AD E7 BD                 ...
        beq     LE8F0                           ; E8E0 F0 0E                    ..
        lda     $5C                             ; E8E2 A5 5C                    .\
        sbc     $BDE6                           ; E8E4 ED E6 BD                 ...
        tax                                     ; E8E7 AA                       .
        lda     $5D                             ; E8E8 A5 5D                    .]
        sbc     $BDE7                           ; E8EA ED E7 BD                 ...
        jmp     LE8F9                           ; E8ED 4C F9 E8                 L..

; ----------------------------------------------------------------------------
LE8F0:  lda     $5C                             ; E8F0 A5 5C                    .\
        sbc     $5A                             ; E8F2 E5 5A                    .Z
        tax                                     ; E8F4 AA                       .
        lda     $5D                             ; E8F5 A5 5D                    .]
        sbc     $5B                             ; E8F7 E5 5B                    .[
LE8F9:  lsr     a                               ; E8F9 4A                       J
        pha                                     ; E8FA 48                       H
        txa                                     ; E8FB 8A                       .
        ror     a                               ; E8FC 6A                       j
        pha                                     ; E8FD 48                       H
        jmp     advance_two                     ; E8FE 4C 7B D2                 L{.

; ----------------------------------------------------------------------------
LE901:  pla                                     ; E901 68                       h
        sta     L0092                           ; E902 85 92                    ..
        pla                                     ; E904 68                       h
        sta     $93                             ; E905 85 93                    ..
        lda     #$00                            ; E907 A9 00                    ..
        sta     $05,x                           ; E909 95 05                    ..
        sta     L0000,x                         ; E90B 95 00                    ..
        sta     $01,x                           ; E90D 95 01                    ..
        pla                                     ; E90F 68                       h
        sta     $04,x                           ; E910 95 04                    ..
        pla                                     ; E912 68                       h
        sta     $03,x                           ; E913 95 03                    ..
        pla                                     ; E915 68                       h
        rol     a                               ; E916 2A                       *
        rol     $01,x                           ; E917 36 01                    6.
        sec                                     ; E919 38                       8
        ror     a                               ; E91A 6A                       j
        sta     $02,x                           ; E91B 95 02                    ..
        pla                                     ; E91D 68                       h
        clc                                     ; E91E 18                       .
        rol     a                               ; E91F 2A                       *
        ror     L0000,x                         ; E920 76 00                    v.
        ora     $01,x                           ; E922 15 01                    ..
        sta     $01,x                           ; E924 95 01                    ..
        inc     L0092                           ; E926 E6 92                    ..
        bne     LE92C                           ; E928 D0 02                    ..
        inc     $93                             ; E92A E6 93                    ..
LE92C:  jmp     (L0092)                         ; E92C 6C 92 00                 l..

; ----------------------------------------------------------------------------
LE92F:  pla                                     ; E92F 68                       h
        sta     L0092                           ; E930 85 92                    ..
        pla                                     ; E932 68                       h
        sta     $93                             ; E933 85 93                    ..
        lda     $01,x                           ; E935 B5 01                    ..
        clc                                     ; E937 18                       .
        ror     a                               ; E938 6A                       j
        ora     L0000,x                         ; E939 15 00                    ..
        pha                                     ; E93B 48                       H
        lda     $02,x                           ; E93C B5 02                    ..
        rol     a                               ; E93E 2A                       *
        ror     $01,x                           ; E93F 76 01                    v.
        ror     a                               ; E941 6A                       j
        pha                                     ; E942 48                       H
        lda     $03,x                           ; E943 B5 03                    ..
        pha                                     ; E945 48                       H
        lda     $04,x                           ; E946 B5 04                    ..
        pha                                     ; E948 48                       H
        inc     L0092                           ; E949 E6 92                    ..
        bne     LE94F                           ; E94B D0 02                    ..
        inc     $93                             ; E94D E6 93                    ..
LE94F:  jmp     (L0092)                         ; E94F 6C 92 00                 l..

; ----------------------------------------------------------------------------
LE952:  bcc     LE971                           ; E952 90 1D                    ..
        ror     $8C                             ; E954 66 8C                    f.
        ror     $8D                             ; E956 66 8D                    f.
        ror     $8E                             ; E958 66 8E                    f.
        ror     $8F                             ; E95A 66 8F                    f.
        bcc     LE964                           ; E95C 90 06                    ..
        lda     #$01                            ; E95E A9 01                    ..
        ora     $8F                             ; E960 05 8F                    ..
        sta     $8F                             ; E962 85 8F                    ..
LE964:  inc     $8B                             ; E964 E6 8B                    ..
        lda     #$FF                            ; E966 A9 FF                    ..
        cmp     $8B                             ; E968 C5 8B                    ..
        bne     LE971                           ; E96A D0 05                    ..
        pla                                     ; E96C 68                       h
        pla                                     ; E96D 68                       h
        jmp     LD1F3                           ; E96E 4C F3 D1                 L..

; ----------------------------------------------------------------------------
LE971:  rts                                     ; E971 60                       `

; ----------------------------------------------------------------------------
LE972:  lda     $8C                             ; E972 A5 8C                    ..
        bmi     LE991                           ; E974 30 1B                    0.
        clc                                     ; E976 18                       .
        rol     $8F                             ; E977 26 8F                    &.
LE979:  rol     $8E                             ; E979 26 8E                    &.
        rol     $8D                             ; E97B 26 8D                    &.
        rol     $8C                             ; E97D 26 8C                    &.
        bmi     LE988                           ; E97F 30 07                    0.
        clc                                     ; E981 18                       .
        dec     $8B                             ; E982 C6 8B                    ..
        bne     LE979                           ; E984 D0 F3                    ..
        beq     LE98C                           ; E986 F0 04                    ..
LE988:  dec     $8B                             ; E988 C6 8B                    ..
        bne     LE991                           ; E98A D0 05                    ..
LE98C:  pla                                     ; E98C 68                       h
        pla                                     ; E98D 68                       h
        jmp     LD1F3                           ; E98E 4C F3 D1                 L..

; ----------------------------------------------------------------------------
LE991:  rts                                     ; E991 60                       `

; ----------------------------------------------------------------------------
LE992:  clc                                     ; E992 18                       .
        rol     $8F                             ; E993 26 8F                    &.
        bcc     LE9AF                           ; E995 90 18                    ..
        inc     $8E                             ; E997 E6 8E                    ..
        bne     LE9A1                           ; E999 D0 06                    ..
        inc     $8D                             ; E99B E6 8D                    ..
        bne     LE9A1                           ; E99D D0 02                    ..
        inc     $8C                             ; E99F E6 8C                    ..
LE9A1:  lda     $8F                             ; E9A1 A5 8F                    ..
        bne     LE9A9                           ; E9A3 D0 04                    ..
        lsr     $8E                             ; E9A5 46 8E                    F.
        asl     $8E                             ; E9A7 06 8E                    ..
LE9A9:  lda     $8C                             ; E9A9 A5 8C                    ..
        clc                                     ; E9AB 18                       .
        bne     LE9AF                           ; E9AC D0 01                    ..
        sec                                     ; E9AE 38                       8
LE9AF:  rts                                     ; E9AF 60                       `

; ----------------------------------------------------------------------------
LE9B0:  lda     $7F                             ; E9B0 A5 7F                    ..
        sta     $8B                             ; E9B2 85 8B                    ..
        sec                                     ; E9B4 38                       8
        sbc     $85                             ; E9B5 E5 85                    ..
        bcs     LE9D4                           ; E9B7 B0 1B                    ..
        eor     #$FF                            ; E9B9 49 FF                    I.
        tax                                     ; E9BB AA                       .
        inx                                     ; E9BC E8                       .
        lda     $85                             ; E9BD A5 85                    ..
        sta     $8B                             ; E9BF 85 8B                    ..
LE9C1:  lsr     $80                             ; E9C1 46 80                    F.
        ror     $81                             ; E9C3 66 81                    f.
        ror     $82                             ; E9C5 66 82                    f.
        ror     $83                             ; E9C7 66 83                    f.
        bcc     LE9D1                           ; E9C9 90 06                    ..
        lda     #$01                            ; E9CB A9 01                    ..
        ora     $83                             ; E9CD 05 83                    ..
        sta     $83                             ; E9CF 85 83                    ..
LE9D1:  dex                                     ; E9D1 CA                       .
        bne     LE9C1                           ; E9D2 D0 ED                    ..
LE9D4:  beq     LE9EA                           ; E9D4 F0 14                    ..
        tax                                     ; E9D6 AA                       .
LE9D7:  lsr     $86                             ; E9D7 46 86                    F.
        ror     $87                             ; E9D9 66 87                    f.
        ror     $88                             ; E9DB 66 88                    f.
        ror     $89                             ; E9DD 66 89                    f.
        bcc     LE9E7                           ; E9DF 90 06                    ..
        lda     #$01                            ; E9E1 A9 01                    ..
        ora     $89                             ; E9E3 05 89                    ..
        sta     $89                             ; E9E5 85 89                    ..
LE9E7:  dex                                     ; E9E7 CA                       .
        bne     LE9D7                           ; E9E8 D0 ED                    ..
LE9EA:  rts                                     ; E9EA 60                       `

; ----------------------------------------------------------------------------
LE9EB:  jsr     LE9B0                           ; E9EB 20 B0 E9                  ..
        clc                                     ; E9EE 18                       .
        lda     $83                             ; E9EF A5 83                    ..
        adc     $89                             ; E9F1 65 89                    e.
        sta     $8F                             ; E9F3 85 8F                    ..
        lda     $82                             ; E9F5 A5 82                    ..
        adc     $88                             ; E9F7 65 88                    e.
        sta     $8E                             ; E9F9 85 8E                    ..
        lda     $81                             ; E9FB A5 81                    ..
        adc     $87                             ; E9FD 65 87                    e.
        sta     $8D                             ; E9FF 85 8D                    ..
        lda     $80                             ; EA01 A5 80                    ..
        adc     $86                             ; EA03 65 86                    e.
        sta     $8C                             ; EA05 85 8C                    ..
        jsr     LE952                           ; EA07 20 52 E9                  R.
        jsr     LE992                           ; EA0A 20 92 E9                  ..
        jsr     LE952                           ; EA0D 20 52 E9                  R.
        rts                                     ; EA10 60                       `

; ----------------------------------------------------------------------------
LEA11:  jsr     LE9B0                           ; EA11 20 B0 E9                  ..
        sec                                     ; EA14 38                       8
        lda     $89                             ; EA15 A5 89                    ..
        sbc     $83                             ; EA17 E5 83                    ..
        sta     $8F                             ; EA19 85 8F                    ..
        lda     $88                             ; EA1B A5 88                    ..
        sbc     $82                             ; EA1D E5 82                    ..
        sta     $8E                             ; EA1F 85 8E                    ..
        lda     $87                             ; EA21 A5 87                    ..
        sbc     $81                             ; EA23 E5 81                    ..
        sta     $8D                             ; EA25 85 8D                    ..
        lda     $86                             ; EA27 A5 86                    ..
        sbc     $80                             ; EA29 E5 80                    ..
        sta     $8C                             ; EA2B 85 8C                    ..
        lda     $8C                             ; EA2D A5 8C                    ..
        bne     LEA40                           ; EA2F D0 0F                    ..
        lda     $8D                             ; EA31 A5 8D                    ..
        bne     LEA40                           ; EA33 D0 0B                    ..
        lda     $8E                             ; EA35 A5 8E                    ..
        bne     LEA40                           ; EA37 D0 07                    ..
        lda     #$00                            ; EA39 A9 00                    ..
        sta     $8B                             ; EA3B 85 8B                    ..
        sta     $8A                             ; EA3D 85 8A                    ..
        rts                                     ; EA3F 60                       `

; ----------------------------------------------------------------------------
LEA40:  jsr     LE972                           ; EA40 20 72 E9                  r.
        jsr     LE992                           ; EA43 20 92 E9                  ..
        jsr     LE952                           ; EA46 20 52 E9                  R.
        rts                                     ; EA49 60                       `

; ----------------------------------------------------------------------------
LEA4A:  lda     $7F                             ; EA4A A5 7F                    ..
        cmp     $85                             ; EA4C C5 85                    ..
        bcc     LEA72                           ; EA4E 90 22                    ."
        bne     LEA76                           ; EA50 D0 24                    .$
        lda     $80                             ; EA52 A5 80                    ..
        cmp     $86                             ; EA54 C5 86                    ..
        bcc     LEA72                           ; EA56 90 1A                    ..
        bne     LEA76                           ; EA58 D0 1C                    ..
        lda     $81                             ; EA5A A5 81                    ..
        cmp     $87                             ; EA5C C5 87                    ..
        bcc     LEA72                           ; EA5E 90 12                    ..
        bne     LEA76                           ; EA60 D0 14                    ..
        lda     $82                             ; EA62 A5 82                    ..
        cmp     $88                             ; EA64 C5 88                    ..
        bcc     LEA72                           ; EA66 90 0A                    ..
        bne     LEA76                           ; EA68 D0 0C                    ..
        lda     $83                             ; EA6A A5 83                    ..
        cmp     $89                             ; EA6C C5 89                    ..
        bcc     LEA72                           ; EA6E 90 02                    ..
        bne     LEA76                           ; EA70 D0 04                    ..
LEA72:  lda     $84                             ; EA72 A5 84                    ..
        sec                                     ; EA74 38                       8
        rts                                     ; EA75 60                       `

; ----------------------------------------------------------------------------
LEA76:  ldx     $7F                             ; EA76 A6 7F                    ..
        ldy     $85                             ; EA78 A4 85                    ..
        sty     $7F                             ; EA7A 84 7F                    ..
        stx     $85                             ; EA7C 86 85                    ..
        ldx     $80                             ; EA7E A6 80                    ..
        ldy     $86                             ; EA80 A4 86                    ..
        sty     $80                             ; EA82 84 80                    ..
        stx     $86                             ; EA84 86 86                    ..
        ldx     $81                             ; EA86 A6 81                    ..
        ldy     $87                             ; EA88 A4 87                    ..
        sty     $81                             ; EA8A 84 81                    ..
        stx     $87                             ; EA8C 86 87                    ..
        ldx     $82                             ; EA8E A6 82                    ..
        ldy     $88                             ; EA90 A4 88                    ..
        sty     $82                             ; EA92 84 82                    ..
        stx     $88                             ; EA94 86 88                    ..
        lda     $7E                             ; EA96 A5 7E                    .~
        clc                                     ; EA98 18                       .
        rts                                     ; EA99 60                       `

; ----------------------------------------------------------------------------
        ldx     #$7E                            ; EA9A A2 7E                    .~
        jsr     LE901                           ; EA9C 20 01 E9                  ..
        ldx     #$84                            ; EA9F A2 84                    ..
        jsr     LE901                           ; EAA1 20 01 E9                  ..
        lda     $7F                             ; EAA4 A5 7F                    ..
        bne     LEAB0                           ; EAA6 D0 08                    ..
        ldx     #$84                            ; EAA8 A2 84                    ..
        jsr     LE92F                           ; EAAA 20 2F E9                  /.
        jmp     advance_one                     ; EAAD 4C 8D D2                 L..

; ----------------------------------------------------------------------------
LEAB0:  lda     $85                             ; EAB0 A5 85                    ..
        bne     LEABC                           ; EAB2 D0 08                    ..
        ldx     #$7E                            ; EAB4 A2 7E                    .~
        jsr     LE92F                           ; EAB6 20 2F E9                  /.
        jmp     advance_one                     ; EAB9 4C 8D D2                 L..

; ----------------------------------------------------------------------------
LEABC:  lda     $7E                             ; EABC A5 7E                    .~
        eor     $84                             ; EABE 45 84                    E.
        bne     LEAD1                           ; EAC0 D0 0F                    ..
        lda     $7E                             ; EAC2 A5 7E                    .~
        sta     $8A                             ; EAC4 85 8A                    ..
        jsr     LE9EB                           ; EAC6 20 EB E9                  ..
        ldx     #$8A                            ; EAC9 A2 8A                    ..
        jsr     LE92F                           ; EACB 20 2F E9                  /.
        jmp     advance_one                     ; EACE 4C 8D D2                 L..

; ----------------------------------------------------------------------------
LEAD1:  jsr     LEA4A                           ; EAD1 20 4A EA                  J.
        sta     $8A                             ; EAD4 85 8A                    ..
        jsr     LEA11                           ; EAD6 20 11 EA                  ..
        ldx     #$8A                            ; EAD9 A2 8A                    ..
        jsr     LE92F                           ; EADB 20 2F E9                  /.
        jmp     advance_one                     ; EADE 4C 8D D2                 L..

; ----------------------------------------------------------------------------
        ldx     #$7E                            ; EAE1 A2 7E                    .~
        jsr     LE901                           ; EAE3 20 01 E9                  ..
        ldx     #$84                            ; EAE6 A2 84                    ..
        jsr     LE901                           ; EAE8 20 01 E9                  ..
        lda     $7F                             ; EAEB A5 7F                    ..
        bne     LEAF7                           ; EAED D0 08                    ..
        ldx     #$84                            ; EAEF A2 84                    ..
        jsr     LE92F                           ; EAF1 20 2F E9                  /.
        jmp     advance_one                     ; EAF4 4C 8D D2                 L..

; ----------------------------------------------------------------------------
LEAF7:  lda     $85                             ; EAF7 A5 85                    ..
        bne     LEB09                           ; EAF9 D0 0E                    ..
        lda     $7E                             ; EAFB A5 7E                    .~
        eor     #$80                            ; EAFD 49 80                    I.
        sta     $7E                             ; EAFF 85 7E                    .~
        ldx     #$7E                            ; EB01 A2 7E                    .~
        jsr     LE92F                           ; EB03 20 2F E9                  /.
        jmp     advance_one                     ; EB06 4C 8D D2                 L..

; ----------------------------------------------------------------------------
LEB09:  lda     $7E                             ; EB09 A5 7E                    .~
        eor     $84                             ; EB0B 45 84                    E.
        beq     LEB1E                           ; EB0D F0 0F                    ..
        lda     $84                             ; EB0F A5 84                    ..
        sta     $8A                             ; EB11 85 8A                    ..
        jsr     LE9EB                           ; EB13 20 EB E9                  ..
        ldx     #$8A                            ; EB16 A2 8A                    ..
        jsr     LE92F                           ; EB18 20 2F E9                  /.
        jmp     advance_one                     ; EB1B 4C 8D D2                 L..

; ----------------------------------------------------------------------------
LEB1E:  jsr     LEA4A                           ; EB1E 20 4A EA                  J.
        bcs     LEB25                           ; EB21 B0 02                    ..
        eor     #$80                            ; EB23 49 80                    I.
LEB25:  sta     $8A                             ; EB25 85 8A                    ..
        jsr     LEA11                           ; EB27 20 11 EA                  ..
        ldx     #$8A                            ; EB2A A2 8A                    ..
        jsr     LE92F                           ; EB2C 20 2F E9                  /.
        jmp     advance_one                     ; EB2F 4C 8D D2                 L..

; ----------------------------------------------------------------------------
        ldx     #$7E                            ; EB32 A2 7E                    .~
        jsr     LE901                           ; EB34 20 01 E9                  ..
        ldx     #$84                            ; EB37 A2 84                    ..
        jsr     LE901                           ; EB39 20 01 E9                  ..
        lda     $7F                             ; EB3C A5 7F                    ..
        bne     LEB43                           ; EB3E D0 03                    ..
        jmp     LD1DF                           ; EB40 4C DF D1                 L..

; ----------------------------------------------------------------------------
LEB43:  lda     $85                             ; EB43 A5 85                    ..
        bne     LEB50                           ; EB45 D0 09                    ..
        lda     #$00                            ; EB47 A9 00                    ..
        pha                                     ; EB49 48                       H
        pha                                     ; EB4A 48                       H
        pha                                     ; EB4B 48                       H
        pha                                     ; EB4C 48                       H
        jmp     advance_one                     ; EB4D 4C 8D D2                 L..

; ----------------------------------------------------------------------------
LEB50:  lda     $7E                             ; EB50 A5 7E                    .~
        eor     $84                             ; EB52 45 84                    E.
        sta     $8A                             ; EB54 85 8A                    ..
        lda     $85                             ; EB56 A5 85                    ..
        sec                                     ; EB58 38                       8
        sbc     $7F                             ; EB59 E5 7F                    ..
        bcc     LEB68                           ; EB5B 90 0B                    ..
        clc                                     ; EB5D 18                       .
        adc     #$7F                            ; EB5E 69 7F                    i.
        bcs     LEB6E                           ; EB60 B0 0C                    ..
        cmp     #$FF                            ; EB62 C9 FF                    ..
        beq     LEB6E                           ; EB64 F0 08                    ..
        bcc     LEB71                           ; EB66 90 09                    ..
LEB68:  adc     #$7F                            ; EB68 69 7F                    i.
        beq     LEB6E                           ; EB6A F0 02                    ..
        bpl     LEB71                           ; EB6C 10 03                    ..
LEB6E:  jmp     LD1F3                           ; EB6E 4C F3 D1                 L..

; ----------------------------------------------------------------------------
LEB71:  sta     $8B                             ; EB71 85 8B                    ..
        ldx     #$20                            ; EB73 A2 20                    . 
LEB75:  sec                                     ; EB75 38                       8
        lda     $89                             ; EB76 A5 89                    ..
        sbc     $83                             ; EB78 E5 83                    ..
        sta     $91                             ; EB7A 85 91                    ..
        lda     $88                             ; EB7C A5 88                    ..
        sbc     $82                             ; EB7E E5 82                    ..
        sta     L0090                           ; EB80 85 90                    ..
        lda     $87                             ; EB82 A5 87                    ..
        sbc     $81                             ; EB84 E5 81                    ..
        tay                                     ; EB86 A8                       .
        lda     $86                             ; EB87 A5 86                    ..
        sbc     $80                             ; EB89 E5 80                    ..
        bcc     LEB9A                           ; EB8B 90 0D                    ..
        sta     $86                             ; EB8D 85 86                    ..
        sty     $87                             ; EB8F 84 87                    ..
        lda     L0090                           ; EB91 A5 90                    ..
        sta     $88                             ; EB93 85 88                    ..
        lda     $91                             ; EB95 A5 91                    ..
        sta     $89                             ; EB97 85 89                    ..
        sec                                     ; EB99 38                       8
LEB9A:  rol     $8F                             ; EB9A 26 8F                    &.
        rol     $8E                             ; EB9C 26 8E                    &.
        rol     $8D                             ; EB9E 26 8D                    &.
        rol     $8C                             ; EBA0 26 8C                    &.
        lsr     $80                             ; EBA2 46 80                    F.
        ror     $81                             ; EBA4 66 81                    f.
        ror     $82                             ; EBA6 66 82                    f.
        ror     $83                             ; EBA8 66 83                    f.
        dex                                     ; EBAA CA                       .
        bne     LEB75                           ; EBAB D0 C8                    ..
        jsr     LE972                           ; EBAD 20 72 E9                  r.
        jsr     LE992                           ; EBB0 20 92 E9                  ..
        jsr     LE952                           ; EBB3 20 52 E9                  R.
        ldx     #$8A                            ; EBB6 A2 8A                    ..
        jsr     LE92F                           ; EBB8 20 2F E9                  /.
        jmp     advance_one                     ; EBBB 4C 8D D2                 L..

; ----------------------------------------------------------------------------
LEBBE:  lda     $7E                             ; EBBE A5 7E                    .~
        eor     $84                             ; EBC0 45 84                    E.
        sta     $8A                             ; EBC2 85 8A                    ..
        lda     $7F                             ; EBC4 A5 7F                    ..
        sec                                     ; EBC6 38                       8
        sbc     #$7F                            ; EBC7 E9 7F                    ..
        sta     $7F                             ; EBC9 85 7F                    ..
        lda     $85                             ; EBCB A5 85                    ..
        sec                                     ; EBCD 38                       8
        sbc     #$7F                            ; EBCE E9 7F                    ..
        clv                                     ; EBD0 B8                       .
        clc                                     ; EBD1 18                       .
        adc     $7F                             ; EBD2 65 7F                    e.
        bvc     LEBDB                           ; EBD4 50 05                    P.
LEBD6:  pla                                     ; EBD6 68                       h
        pla                                     ; EBD7 68                       h
        jmp     LD1F3                           ; EBD8 4C F3 D1                 L..

; ----------------------------------------------------------------------------
LEBDB:  clc                                     ; EBDB 18                       .
        adc     #$7F                            ; EBDC 69 7F                    i.
        beq     LEBD6                           ; EBDE F0 F6                    ..
        cmp     #$FF                            ; EBE0 C9 FF                    ..
        beq     LEBD6                           ; EBE2 F0 F2                    ..
        sta     $8B                             ; EBE4 85 8B                    ..
        lda     #$00                            ; EBE6 A9 00                    ..
        sta     $8C                             ; EBE8 85 8C                    ..
        sta     $8D                             ; EBEA 85 8D                    ..
        sta     $8E                             ; EBEC 85 8E                    ..
        sta     $8F                             ; EBEE 85 8F                    ..
        ldx     #$18                            ; EBF0 A2 18                    ..
LEBF2:  lsr     $80                             ; EBF2 46 80                    F.
        ror     $81                             ; EBF4 66 81                    f.
        ror     $82                             ; EBF6 66 82                    f.
        bcc     LEC0D                           ; EBF8 90 13                    ..
        clc                                     ; EBFA 18                       .
        lda     $8E                             ; EBFB A5 8E                    ..
        adc     $88                             ; EBFD 65 88                    e.
        sta     $8E                             ; EBFF 85 8E                    ..
        lda     $8D                             ; EC01 A5 8D                    ..
        adc     $87                             ; EC03 65 87                    e.
        sta     $8D                             ; EC05 85 8D                    ..
        lda     $8C                             ; EC07 A5 8C                    ..
        adc     $86                             ; EC09 65 86                    e.
        sta     $8C                             ; EC0B 85 8C                    ..
LEC0D:  dex                                     ; EC0D CA                       .
        beq     LEC23                           ; EC0E F0 13                    ..
        ror     $8C                             ; EC10 66 8C                    f.
        ror     $8D                             ; EC12 66 8D                    f.
        ror     $8E                             ; EC14 66 8E                    f.
        ror     $8F                             ; EC16 66 8F                    f.
        bcc     LEBF2                           ; EC18 90 D8                    ..
        lda     $8F                             ; EC1A A5 8F                    ..
        ora     #$01                            ; EC1C 09 01                    ..
        sta     $8F                             ; EC1E 85 8F                    ..
        jmp     LEBF2                           ; EC20 4C F2 EB                 L..

; ----------------------------------------------------------------------------
LEC23:  jsr     LE952                           ; EC23 20 52 E9                  R.
        jsr     LE992                           ; EC26 20 92 E9                  ..
        jsr     LE952                           ; EC29 20 52 E9                  R.
        rts                                     ; EC2C 60                       `

; ----------------------------------------------------------------------------
        ldx     #$7E                            ; EC2D A2 7E                    .~
        jsr     LE901                           ; EC2F 20 01 E9                  ..
        ldx     #$84                            ; EC32 A2 84                    ..
        jsr     LE901                           ; EC34 20 01 E9                  ..
        lda     $7F                             ; EC37 A5 7F                    ..
        beq     LEC41                           ; EC39 F0 06                    ..
        lda     $85                             ; EC3B A5 85                    ..
        beq     LEC41                           ; EC3D F0 02                    ..
        bne     LEC4A                           ; EC3F D0 09                    ..
LEC41:  lda     #$00                            ; EC41 A9 00                    ..
        pha                                     ; EC43 48                       H
        pha                                     ; EC44 48                       H
        pha                                     ; EC45 48                       H
        pha                                     ; EC46 48                       H
        jmp     advance_one                     ; EC47 4C 8D D2                 L..

; ----------------------------------------------------------------------------
LEC4A:  jsr     LEBBE                           ; EC4A 20 BE EB                  ..
        ldx     #$8A                            ; EC4D A2 8A                    ..
        jsr     LE92F                           ; EC4F 20 2F E9                  /.
        jmp     advance_one                     ; EC52 4C 8D D2                 L..

; ----------------------------------------------------------------------------
        ldx     #$7E                            ; EC55 A2 7E                    .~
        jsr     LE901                           ; EC57 20 01 E9                  ..
        lda     $7F                             ; EC5A A5 7F                    ..
        bne     LEC67                           ; EC5C D0 09                    ..
        lda     #$00                            ; EC5E A9 00                    ..
        pha                                     ; EC60 48                       H
        pha                                     ; EC61 48                       H
        pha                                     ; EC62 48                       H
        pha                                     ; EC63 48                       H
        jmp     advance_one                     ; EC64 4C 8D D2                 L..

; ----------------------------------------------------------------------------
LEC67:  lda     $7E                             ; EC67 A5 7E                    .~
        sta     $84                             ; EC69 85 84                    ..
        lda     $7F                             ; EC6B A5 7F                    ..
        sta     $85                             ; EC6D 85 85                    ..
        lda     $80                             ; EC6F A5 80                    ..
        sta     $86                             ; EC71 85 86                    ..
        lda     $81                             ; EC73 A5 81                    ..
        sta     $87                             ; EC75 85 87                    ..
        lda     $82                             ; EC77 A5 82                    ..
        sta     $88                             ; EC79 85 88                    ..
        lda     $83                             ; EC7B A5 83                    ..
        sta     $89                             ; EC7D 85 89                    ..
        jsr     LEBBE                           ; EC7F 20 BE EB                  ..
        ldx     #$8A                            ; EC82 A2 8A                    ..
        jsr     LE92F                           ; EC84 20 2F E9                  /.
        jmp     advance_one                     ; EC87 4C 8D D2                 L..

; ----------------------------------------------------------------------------
        tsx                                     ; EC8A BA                       .
        inx                                     ; EC8B E8                       .
        inx                                     ; EC8C E8                       .
        inx                                     ; EC8D E8                       .
        inx                                     ; EC8E E8                       .
        asl     $0100,x                         ; EC8F 1E 00 01                 ...
        lsr     $0100,x                         ; EC92 5E 00 01                 ^..
        jmp     advance_one                     ; EC95 4C 8D D2                 L..

; ----------------------------------------------------------------------------
        tsx                                     ; EC98 BA                       .
        lda     $0103,x                         ; EC99 BD 03 01                 ...
        sta     $7E                             ; EC9C 85 7E                    .~
        lda     $0104,x                         ; EC9E BD 04 01                 ...
        sta     $80                             ; ECA1 85 80                    ..
        rol     $7E                             ; ECA3 26 7E                    &~
        rol     $80                             ; ECA5 26 80                    &.
        beq     LECB5                           ; ECA7 F0 0C                    ..
        inx                                     ; ECA9 E8                       .
        inx                                     ; ECAA E8                       .
        inx                                     ; ECAB E8                       .
        inx                                     ; ECAC E8                       .
        lda     $0100,x                         ; ECAD BD 00 01                 ...
        eor     #$80                            ; ECB0 49 80                    I.
        sta     $0100,x                         ; ECB2 9D 00 01                 ...
LECB5:  jmp     advance_one                     ; ECB5 4C 8D D2                 L..

; ----------------------------------------------------------------------------
LECB8:  pla                                     ; ECB8 68                       h
        sta     L0092                           ; ECB9 85 92                    ..
        pla                                     ; ECBB 68                       h
        sta     $93                             ; ECBC 85 93                    ..
        pla                                     ; ECBE 68                       h
        sta     L0090                           ; ECBF 85 90                    ..
        pla                                     ; ECC1 68                       h
        sta     $91                             ; ECC2 85 91                    ..
        lda     $91                             ; ECC4 A5 91                    ..
        bne     LECD8                           ; ECC6 D0 10                    ..
        lda     L0090                           ; ECC8 A5 90                    ..
        bne     LECD8                           ; ECCA D0 0C                    ..
        sta     $8A                             ; ECCC 85 8A                    ..
        sta     $8B                             ; ECCE 85 8B                    ..
        sta     $8C                             ; ECD0 85 8C                    ..
        sta     $8D                             ; ECD2 85 8D                    ..
        sta     $8E                             ; ECD4 85 8E                    ..
        beq     LED0E                           ; ECD6 F0 36                    .6
LECD8:  lda     #$00                            ; ECD8 A9 00                    ..
        sta     $8A                             ; ECDA 85 8A                    ..
        ldx     #$8E                            ; ECDC A2 8E                    ..
        lda     $91                             ; ECDE A5 91                    ..
        bpl     LECF9                           ; ECE0 10 17                    ..
        lda     #$80                            ; ECE2 A9 80                    ..
        sta     $8A                             ; ECE4 85 8A                    ..
        clc                                     ; ECE6 18                       .
        lda     L0090                           ; ECE7 A5 90                    ..
        eor     #$FF                            ; ECE9 49 FF                    I.
        adc     #$01                            ; ECEB 69 01                    i.
        sta     L0090                           ; ECED 85 90                    ..
        lda     $91                             ; ECEF A5 91                    ..
        eor     #$FF                            ; ECF1 49 FF                    I.
        adc     #$00                            ; ECF3 69 00                    i.
        sta     $91                             ; ECF5 85 91                    ..
        bmi     LED00                           ; ECF7 30 07                    0.
LECF9:  dex                                     ; ECF9 CA                       .
        asl     L0090                           ; ECFA 06 90                    ..
        rol     $91                             ; ECFC 26 91                    &.
        bpl     LECF9                           ; ECFE 10 F9                    ..
LED00:  stx     $8B                             ; ED00 86 8B                    ..
        lda     $91                             ; ED02 A5 91                    ..
        sta     $8C                             ; ED04 85 8C                    ..
        lda     L0090                           ; ED06 A5 90                    ..
        sta     $8D                             ; ED08 85 8D                    ..
        lda     #$00                            ; ED0A A9 00                    ..
        sta     $8E                             ; ED0C 85 8E                    ..
LED0E:  inc     L0092                           ; ED0E E6 92                    ..
        bne     LED14                           ; ED10 D0 02                    ..
        inc     $93                             ; ED12 E6 93                    ..
LED14:  jmp     (L0092)                         ; ED14 6C 92 00                 l..

; ----------------------------------------------------------------------------
        pla                                     ; ED17 68                       h
        sta     $83                             ; ED18 85 83                    ..
        pla                                     ; ED1A 68                       h
        sta     $82                             ; ED1B 85 82                    ..
        pla                                     ; ED1D 68                       h
        sta     $81                             ; ED1E 85 81                    ..
        pla                                     ; ED20 68                       h
        sta     $80                             ; ED21 85 80                    ..
        jsr     LECB8                           ; ED23 20 B8 EC                  ..
        ldx     #$8A                            ; ED26 A2 8A                    ..
        jsr     LE92F                           ; ED28 20 2F E9                  /.
        lda     $80                             ; ED2B A5 80                    ..
        pha                                     ; ED2D 48                       H
        lda     $81                             ; ED2E A5 81                    ..
        pha                                     ; ED30 48                       H
        lda     $82                             ; ED31 A5 82                    ..
        pha                                     ; ED33 48                       H
        lda     $83                             ; ED34 A5 83                    ..
        pha                                     ; ED36 48                       H
        jmp     advance_one                     ; ED37 4C 8D D2                 L..

; ----------------------------------------------------------------------------
        jsr     LECB8                           ; ED3A 20 B8 EC                  ..
        ldx     #$8A                            ; ED3D A2 8A                    ..
        jsr     LE92F                           ; ED3F 20 2F E9                  /.
        jmp     advance_one                     ; ED42 4C 8D D2                 L..

; ----------------------------------------------------------------------------
LED45:  sec                                     ; ED45 38                       8
        lda     #$8D                            ; ED46 A9 8D                    ..
        sbc     $7F                             ; ED48 E5 7F                    ..
        bcs     LED51                           ; ED4A B0 05                    ..
LED4C:  pla                                     ; ED4C 68                       h
        pla                                     ; ED4D 68                       h
        jmp     LD1F3                           ; ED4E 4C F3 D1                 L..

; ----------------------------------------------------------------------------
LED51:  tax                                     ; ED51 AA                       .
        cpx     #$18                            ; ED52 E0 18                    ..
        bmi     LED5F                           ; ED54 30 09                    0.
        lda     #$00                            ; ED56 A9 00                    ..
        sta     $80                             ; ED58 85 80                    ..
        sta     $81                             ; ED5A 85 81                    ..
        sta     $82                             ; ED5C 85 82                    ..
        rts                                     ; ED5E 60                       `

; ----------------------------------------------------------------------------
LED5F:  lsr     $80                             ; ED5F 46 80                    F.
        ror     $81                             ; ED61 66 81                    f.
        ror     $82                             ; ED63 66 82                    f.
        dex                                     ; ED65 CA                       .
        bpl     LED5F                           ; ED66 10 F7                    ..
        lda     L0090                           ; ED68 A5 90                    ..
        beq     LED7B                           ; ED6A F0 0F                    ..
        lda     $82                             ; ED6C A5 82                    ..
        bpl     LED7B                           ; ED6E 10 0B                    ..
        inc     $81                             ; ED70 E6 81                    ..
        bne     LED7B                           ; ED72 D0 07                    ..
        inc     $80                             ; ED74 E6 80                    ..
        bpl     LED7B                           ; ED76 10 03                    ..
        jmp     LED4C                           ; ED78 4C 4C ED                 LL.

; ----------------------------------------------------------------------------
LED7B:  lda     $7E                             ; ED7B A5 7E                    .~
        bpl     LED92                           ; ED7D 10 13                    ..
        lda     $80                             ; ED7F A5 80                    ..
        eor     #$FF                            ; ED81 49 FF                    I.
        sta     $80                             ; ED83 85 80                    ..
        lda     $81                             ; ED85 A5 81                    ..
        eor     #$FF                            ; ED87 49 FF                    I.
        clc                                     ; ED89 18                       .
        adc     #$01                            ; ED8A 69 01                    i.
        sta     $81                             ; ED8C 85 81                    ..
        bcc     LED92                           ; ED8E 90 02                    ..
        inc     $80                             ; ED90 E6 80                    ..
LED92:  rts                                     ; ED92 60                       `

; ----------------------------------------------------------------------------
        lda     #$01                            ; ED93 A9 01                    ..
        sta     L0090                           ; ED95 85 90                    ..
        ldx     #$7E                            ; ED97 A2 7E                    .~
        jsr     LE901                           ; ED99 20 01 E9                  ..
        jsr     LED45                           ; ED9C 20 45 ED                  E.
        lda     $80                             ; ED9F A5 80                    ..
        pha                                     ; EDA1 48                       H
        lda     $81                             ; EDA2 A5 81                    ..
        pha                                     ; EDA4 48                       H
        jmp     advance_two                     ; EDA5 4C 7B D2                 L{.

; ----------------------------------------------------------------------------
        lda     #$00                            ; EDA8 A9 00                    ..
        sta     L0090                           ; EDAA 85 90                    ..
        ldx     #$7E                            ; EDAC A2 7E                    .~
        jsr     LE901                           ; EDAE 20 01 E9                  ..
        jsr     LED45                           ; EDB1 20 45 ED                  E.
        lda     $80                             ; EDB4 A5 80                    ..
        pha                                     ; EDB6 48                       H
        lda     $81                             ; EDB7 A5 81                    ..
        pha                                     ; EDB9 48                       H
        jmp     advance_two                     ; EDBA 4C 7B D2                 L{.

; ----------------------------------------------------------------------------
        pla                                     ; EDBD 68                       h
        tax                                     ; EDBE AA                       .
        pla                                     ; EDBF 68                       h
        bne     LEDDD                           ; EDC0 D0 1B                    ..
        cpx     #$27                            ; EDC2 E0 27                    .'
        bpl     LEDDD                           ; EDC4 10 17                    ..
        txa                                     ; EDC6 8A                       .
        asl     a                               ; EDC7 0A                       .
        asl     a                               ; EDC8 0A                       .
        tax                                     ; EDC9 AA                       .
        lda     powers_of_ten+1,x               ; EDCA BD E7 ED                 ...
        pha                                     ; EDCD 48                       H
        lda     powers_of_ten,x                 ; EDCE BD E6 ED                 ...
        pha                                     ; EDD1 48                       H
        lda     powers_of_ten+3,x               ; EDD2 BD E9 ED                 ...
        pha                                     ; EDD5 48                       H
        lda     powers_of_ten+2,x               ; EDD6 BD E8 ED                 ...
        pha                                     ; EDD9 48                       H
        jmp     advance_two                     ; EDDA 4C 7B D2                 L{.

; ----------------------------------------------------------------------------
LEDDD:  lda     #$00                            ; EDDD A9 00                    ..
        pha                                     ; EDDF 48                       H
        pha                                     ; EDE0 48                       H
        pha                                     ; EDE1 48                       H
        pha                                     ; EDE2 48                       H
        jmp     LD1F3                           ; EDE3 4C F3 D1                 L..

; ----------------------------------------------------------------------------
; Binary32 constants in high-word/low-word order, each word little-endian.
powers_of_ten:
        .word $3F80, $0000             ; 10^0
        .word $4120, $0000             ; 10^1
        .word $42C8, $0000             ; 10^2
        .word $447A, $0000             ; 10^3
        .word $461C, $4000             ; 10^4
        .word $47C3, $5000             ; 10^5
        .word $4974, $2400             ; 10^6
        .word $4B18, $9680             ; 10^7
        .word $4CBE, $BC20             ; 10^8
        .word $4E6E, $6B28             ; 10^9
        .word $5015, $02F9             ; 10^10
        .word $51BA, $43B7             ; 10^11
        .word $5368, $D4A5             ; 10^12
        .word $5511, $84E7             ; 10^13
        .word $56B5, $E621             ; 10^14
        .word $5863, $5FA9             ; 10^15
        .word $5A0E, $1BCA             ; 10^16
        .word $5BB1, $A2BC             ; 10^17
        .word $5D5E, $0B6B             ; 10^18
        .word $5F0A, $C723             ; 10^19
        .word $60AD, $78EC             ; 10^20
        .word $6258, $D727             ; 10^21
        .word $6407, $8678             ; 10^22
        .word $65A9, $6816             ; 10^23
        .word $6753, $C21C             ; 10^24
        .word $6904, $5951             ; 10^25
        .word $6AA5, $6FA6             ; 10^26
        .word $6C4E, $CB8F             ; 10^27
        .word $6E01, $3F39             ; 10^28
        .word $6FA1, $8F08             ; 10^29
        .word $7149, $F2CA             ; 10^30
        .word $72FC, $6F7C             ; 10^31
        .word $749D, $C5AE             ; 10^32
        .word $7645, $3719             ; 10^33
        .word $77F6, $84DF             ; 10^34
        .word $799A, $130C             ; 10^35
        .word $7B40, $97CE             ; 10^36
        .word $7CF0, $BDC2             ; 10^37
        .word $7E96, $769C             ; 10^38 (original value is 3 ULP above nearest)

io_error_entry:
        .word   $D1E3                           ; EE82 E3 D1                    ..
; ----------------------------------------------------------------------------
io_mode:.byte   $00                             ; EE84 00                       .
; ----------------------------------------------------------------------------
output_device_vectors:
        .addr   LFF03                           ; EE85 03 FF                    ..
        .addr   LFF03                           ; EE87 03 FF                    ..
        .addr   LFF21                           ; EE89 21 FF                    !.
        .addr   L0000                           ; EE8B 00 00                    ..
        .addr   L0000                           ; EE8D 00 00                    ..
        .addr   LFF09                           ; EE8F 09 FF                    ..
        .addr   L0000                           ; EE91 00 00                    ..
        .addr   LFF1B                           ; EE93 1B FF                    ..
input_device_vectors:
        .addr   LFF00                           ; EE95 00 FF                    ..
        .addr   LFF00                           ; EE97 00 FF                    ..
        .addr   L0000                           ; EE99 00 00                    ..
        .addr   L0000                           ; EE9B 00 00                    ..
        .addr   L0000                           ; EE9D 00 00                    ..
        .addr   L0000                           ; EE9F 00 00                    ..
        .addr   LFF18                           ; EEA1 18 FF                    ..
        .addr   L0000                           ; EEA3 00 00                    ..
; ----------------------------------------------------------------------------
validate_device_number:
        and     #$80                            ; EEA5 29 80                    ).
        bne     LEEB3                           ; EEA7 D0 0A                    ..
        txa                                     ; EEA9 8A                       .
        cmp     #$15                            ; EEAA C9 15                    ..
        bcs     LEEC7                           ; EEAC B0 19                    ..
        cmp     #$01                            ; EEAE C9 01                    ..
        bcc     LEEC7                           ; EEB0 90 15                    ..
        rts                                     ; EEB2 60                       `

; ----------------------------------------------------------------------------
LEEB3:  txa                                     ; EEB3 8A                       .
        and     #$7F                            ; EEB4 29 7F                    ).
        sta     $96                             ; EEB6 85 96                    ..
        cmp     #$10                            ; EEB8 C9 10                    ..
        bcs     LEEC7                           ; EEBA B0 0B                    ..
        asl     a                               ; EEBC 0A                       .
        adc     $96                             ; EEBD 65 96                    e.
        tay                                     ; EEBF A8                       .
        lda     $FE82,y                         ; EEC0 B9 82 FE                 ...
        beq     LEEC7                           ; EEC3 F0 02                    ..
        txa                                     ; EEC5 8A                       .
        rts                                     ; EEC6 60                       `

; ----------------------------------------------------------------------------
LEEC7:  ldx     #$02                            ; EEC7 A2 02                    ..
        stx     $BDDE                           ; EEC9 8E DE BD                 ...
        pla                                     ; EECC 68                       h
        pla                                     ; EECD 68                       h
        jmp     advance_two                     ; EECE 4C 7B D2                 L{.

; ----------------------------------------------------------------------------
        lda     $BDDF                           ; EED1 AD DF BD                 ...
        pha                                     ; EED4 48                       H
        lda     $BDDE                           ; EED5 AD DE BD                 ...
        pha                                     ; EED8 48                       H
        jmp     advance_two                     ; EED9 4C 7B D2                 L{.

; ----------------------------------------------------------------------------
        lda     $BDDE                           ; EEDC AD DE BD                 ...
        beq     LEEE4                           ; EEDF F0 03                    ..
        jmp     LD1EB                           ; EEE1 4C EB D1                 L..

; ----------------------------------------------------------------------------
LEEE4:  jmp     advance_two                     ; EEE4 4C 7B D2                 L{.

; ----------------------------------------------------------------------------
        pla                                     ; EEE7 68                       h
        tax                                     ; EEE8 AA                       .
        pla                                     ; EEE9 68                       h
        txa                                     ; EEEA 8A                       .
        jsr     validate_device_number          ; EEEB 20 A5 EE                  ..
        lda     #$00                            ; EEEE A9 00                    ..
        pha                                     ; EEF0 48                       H
        pha                                     ; EEF1 48                       H
        jmp     advance_two                     ; EEF2 4C 7B D2                 L{.

; ----------------------------------------------------------------------------
        pla                                     ; EEF5 68                       h
        tax                                     ; EEF6 AA                       .
        pla                                     ; EEF7 68                       h
        txa                                     ; EEF8 8A                       .
        jsr     validate_device_number          ; EEF9 20 A5 EE                  ..
        jmp     advance_two                     ; EEFC 4C 7B D2                 L{.

; ----------------------------------------------------------------------------
        lda     #$04                            ; EEFF A9 04                    ..
        sta     $86                             ; EF01 85 86                    ..
        pla                                     ; EF03 68                       h
        sta     $8C                             ; EF04 85 8C                    ..
        pla                                     ; EF06 68                       h
        sta     $8D                             ; EF07 85 8D                    ..
        pla                                     ; EF09 68                       h
        sta     $84                             ; EF0A 85 84                    ..
        pla                                     ; EF0C 68                       h
        sta     $85                             ; EF0D 85 85                    ..
        clc                                     ; EF0F 18                       .
        pla                                     ; EF10 68                       h
        adc     $84                             ; EF11 65 84                    e.
        sta     $84                             ; EF13 85 84                    ..
        pla                                     ; EF15 68                       h
        adc     $85                             ; EF16 65 85                    e.
        sta     $85                             ; EF18 85 85                    ..
        pla                                     ; EF1A 68                       h
        tax                                     ; EF1B AA                       .
        pla                                     ; EF1C 68                       h
        txa                                     ; EF1D 8A                       .
        jsr     validate_device_number          ; EF1E 20 A5 EE                  ..
        lda     $8D                             ; EF21 A5 8D                    ..
        pha                                     ; EF23 48                       H
        lda     $8C                             ; EF24 A5 8C                    ..
        pha                                     ; EF26 48                       H
        lda     $85                             ; EF27 A5 85                    ..
        pha                                     ; EF29 48                       H
        lda     $84                             ; EF2A A5 84                    ..
        pha                                     ; EF2C 48                       H
        txa                                     ; EF2D 8A                       .
        and     #$80                            ; EF2E 29 80                    ).
        beq     LEF34                           ; EF30 F0 02                    ..
        bne     LEF8C                           ; EF32 D0 58                    .X
LEF34:  txa                                     ; EF34 8A                       .
        cmp     #$07                            ; EF35 C9 07                    ..
        bne     LEF3C                           ; EF37 D0 03                    ..
        lda     #$08                            ; EF39 A9 08                    ..
        tax                                     ; EF3B AA                       .
LEF3C:  asl     a                               ; EF3C 0A                       .
        tay                                     ; EF3D A8                       .
        lda     $FEAF,y                         ; EF3E B9 AF FE                 ...
        beq     LEF49                           ; EF41 F0 06                    ..
        cmp     #$FF                            ; EF43 C9 FF                    ..
        beq     LEF52                           ; EF45 F0 0B                    ..
        bne     LEFA8                           ; EF47 D0 5F                    ._
LEF49:  lda     $FEAE,y                         ; EF49 B9 AE FE                 ...
        jsr     LFF30                           ; EF4C 20 30 FF                  0.
        jmp     LF008                           ; EF4F 4C 08 F0                 L..

; ----------------------------------------------------------------------------
LEF52:  txa                                     ; EF52 8A                       .
        tay                                     ; EF53 A8                       .
        ldx     #$04                            ; EF54 A2 04                    ..
        cpy     #$03                            ; EF56 C0 03                    ..
        bcs     LEF60                           ; EF58 B0 06                    ..
        jsr     LFF2A                           ; EF5A 20 2A FF                  *.
        jmp     LF008                           ; EF5D 4C 08 F0                 L..

; ----------------------------------------------------------------------------
LEF60:  cpy     #$06                            ; EF60 C0 06                    ..
        bne     LEF6A                           ; EF62 D0 06                    ..
        jsr     LFF2D                           ; EF64 20 2D FF                  -.
        jmp     LF008                           ; EF67 4C 08 F0                 L..

; ----------------------------------------------------------------------------
LEF6A:  cpy     #$08                            ; EF6A C0 08                    ..
        bne     LEF74                           ; EF6C D0 06                    ..
        jsr     LFF33                           ; EF6E 20 33 FF                  3.
        jmp     LF008                           ; EF71 4C 08 F0                 L..

; ----------------------------------------------------------------------------
LEF74:  ldx     #$09                            ; EF74 A2 09                    ..
        pla                                     ; EF76 68                       h
        pla                                     ; EF77 68                       h
        pla                                     ; EF78 68                       h
        pla                                     ; EF79 68                       h
        jmp     LF008                           ; EF7A 4C 08 F0                 L..

; ----------------------------------------------------------------------------
        lda     #$02                            ; EF7D A9 02                    ..
        sta     $86                             ; EF7F 85 86                    ..
        pla                                     ; EF81 68                       h
        tax                                     ; EF82 AA                       .
        pla                                     ; EF83 68                       h
        txa                                     ; EF84 8A                       .
        jsr     validate_device_number          ; EF85 20 A5 EE                  ..
        and     #$80                            ; EF88 29 80                    ).
        beq     LEF95                           ; EF8A F0 09                    ..
LEF8C:  txa                                     ; EF8C 8A                       .
        ldx     $86                             ; EF8D A6 86                    ..
        jsr     LFF39                           ; EF8F 20 39 FF                  9.
        jmp     LF008                           ; EF92 4C 08 F0                 L..

; ----------------------------------------------------------------------------
LEF95:  txa                                     ; EF95 8A                       .
        cmp     #$07                            ; EF96 C9 07                    ..
        bne     LEF9D                           ; EF98 D0 03                    ..
        lda     #$08                            ; EF9A A9 08                    ..
        tax                                     ; EF9C AA                       .
LEF9D:  asl     a                               ; EF9D 0A                       .
        tay                                     ; EF9E A8                       .
        lda     $FEAF,y                         ; EF9F B9 AF FE                 ...
        beq     LEFB1                           ; EFA2 F0 0D                    ..
        cmp     #$FF                            ; EFA4 C9 FF                    ..
        beq     LEFBA                           ; EFA6 F0 12                    ..
LEFA8:  txa                                     ; EFA8 8A                       .
        ldx     $86                             ; EFA9 A6 86                    ..
        jsr     LFF3C                           ; EFAB 20 3C FF                  <.
        jmp     LF008                           ; EFAE 4C 08 F0                 L..

; ----------------------------------------------------------------------------
LEFB1:  lda     $FEAE,y                         ; EFB1 B9 AE FE                 ...
        jsr     LFF15                           ; EFB4 20 15 FF                  ..
        jmp     LF008                           ; EFB7 4C 08 F0                 L..

; ----------------------------------------------------------------------------
LEFBA:  txa                                     ; EFBA 8A                       .
        tay                                     ; EFBB A8                       .
        ldx     #$02                            ; EFBC A2 02                    ..
        cpy     #$03                            ; EFBE C0 03                    ..
        bcs     LEFDE                           ; EFC0 B0 1C                    ..
        lda     #$00                            ; EFC2 A9 00                    ..
        sta     $A1                             ; EFC4 85 A1                    ..
        sta     $A2                             ; EFC6 85 A2                    ..
        lda     io_error_entry+1                ; EFC8 AD 83 EE                 ...
        pha                                     ; EFCB 48                       H
        lda     io_error_entry                  ; EFCC AD 82 EE                 ...
        pha                                     ; EFCF 48                       H
        lda     io_result_pointer+1             ; EFD0 AD F8 F1                 ...
        pha                                     ; EFD3 48                       H
        lda     io_result_pointer               ; EFD4 AD F7 F1                 ...
        pha                                     ; EFD7 48                       H
        jsr     LFF06                           ; EFD8 20 06 FF                  ..
        jmp     LF008                           ; EFDB 4C 08 F0                 L..

; ----------------------------------------------------------------------------
LEFDE:  cpy     #$06                            ; EFDE C0 06                    ..
        bne     LEFEC                           ; EFE0 D0 0A                    ..
        lda     #$00                            ; EFE2 A9 00                    ..
        sta     $A6                             ; EFE4 85 A6                    ..
        jsr     LFF0C                           ; EFE6 20 0C FF                  ..
        jmp     LF008                           ; EFE9 4C 08 F0                 L..

; ----------------------------------------------------------------------------
LEFEC:  cpy     #$08                            ; EFEC C0 08                    ..
        bne     LEFF6                           ; EFEE D0 06                    ..
        jsr     LFF1E                           ; EFF0 20 1E FF                  ..
        jmp     LF008                           ; EFF3 4C 08 F0                 L..

; ----------------------------------------------------------------------------
LEFF6:  cpy     #$03                            ; EFF6 C0 03                    ..
        bne     LEFFD                           ; EFF8 D0 03                    ..
        jsr     LFF24                           ; EFFA 20 24 FF                  $.
LEFFD:  ldx     #$09                            ; EFFD A2 09                    ..
        jmp     LF008                           ; EFFF 4C 08 F0                 L..

; ----------------------------------------------------------------------------
LF002:  lda     io_mode                         ; F002 AD 84 EE                 ...
        sta     $BF1C                           ; F005 8D 1C BF                 ...
LF008:  stx     $BDDE                           ; F008 8E DE BD                 ...
        jmp     advance_two                     ; F00B 4C 7B D2                 L{.

; ----------------------------------------------------------------------------
LF00E:  pla                                     ; F00E 68                       h
        sta     L0098                           ; F00F 85 98                    ..
        pla                                     ; F011 68                       h
        sta     $99                             ; F012 85 99                    ..
        lda     $8D                             ; F014 A5 8D                    ..
        pha                                     ; F016 48                       H
        lda     $8C                             ; F017 A5 8C                    ..
        pha                                     ; F019 48                       H
        lda     #$00                            ; F01A A9 00                    ..
        pha                                     ; F01C 48                       H
        txa                                     ; F01D 8A                       .
        pha                                     ; F01E 48                       H
        lda     $85                             ; F01F A5 85                    ..
        pha                                     ; F021 48                       H
        lda     $84                             ; F022 A5 84                    ..
        pha                                     ; F024 48                       H
        lda     $83                             ; F025 A5 83                    ..
        pha                                     ; F027 48                       H
        lda     $82                             ; F028 A5 82                    ..
        pha                                     ; F02A 48                       H
        lda     $81                             ; F02B A5 81                    ..
        pha                                     ; F02D 48                       H
        lda     $80                             ; F02E A5 80                    ..
        pha                                     ; F030 48                       H
        lda     $99                             ; F031 A5 99                    ..
        pha                                     ; F033 48                       H
        lda     L0098                           ; F034 A5 98                    ..
        pha                                     ; F036 48                       H
        rts                                     ; F037 60                       `

; ----------------------------------------------------------------------------
LF038:  lda     io_mode                         ; F038 AD 84 EE                 ...
        sta     $BF1C                           ; F03B 8D 1C BF                 ...
        jmp     advance_two                     ; F03E 4C 7B D2                 L{.

; ----------------------------------------------------------------------------
        lda     #$00                            ; F041 A9 00                    ..
        jmp     LF048                           ; F043 4C 48 F0                 LH.

; ----------------------------------------------------------------------------
        lda     #$01                            ; F046 A9 01                    ..
LF048:  sta     $86                             ; F048 85 86                    ..
        ldy     #$01                            ; F04A A0 01                    ..
        sty     $88                             ; F04C 84 88                    ..
        sty     $8A                             ; F04E 84 8A                    ..
        ldy     $BF1C                           ; F050 AC 1C BF                 ...
        sty     io_mode                         ; F053 8C 84 EE                 ...
        pla                                     ; F056 68                       h
        tax                                     ; F057 AA                       .
        sta     $8C                             ; F058 85 8C                    ..
        lsr     a                               ; F05A 4A                       J
        lsr     a                               ; F05B 4A                       J
        lsr     a                               ; F05C 4A                       J
        lsr     a                               ; F05D 4A                       J
        and     #$03                            ; F05E 29 03                    ).
        ora     $BF1C                           ; F060 0D 1C BF                 ...
        sta     $BF1C                           ; F063 8D 1C BF                 ...
        ldy     #$00                            ; F066 A0 00                    ..
        sty     $BDDE                           ; F068 8C DE BD                 ...
        txa                                     ; F06B 8A                       .
        and     #$04                            ; F06C 29 04                    ).
        bne     LF072                           ; F06E D0 02                    ..
        sty     $88                             ; F070 84 88                    ..
LF072:  txa                                     ; F072 8A                       .
        and     #$08                            ; F073 29 08                    ).
        bne     LF079                           ; F075 D0 02                    ..
        sty     $8A                             ; F077 84 8A                    ..
LF079:  pla                                     ; F079 68                       h
        sta     $8D                             ; F07A 85 8D                    ..
        pla                                     ; F07C 68                       h
        sta     $80                             ; F07D 85 80                    ..
        pla                                     ; F07F 68                       h
        sta     $81                             ; F080 85 81                    ..
        pla                                     ; F082 68                       h
        sta     $82                             ; F083 85 82                    ..
        beq     LF098                           ; F085 F0 11                    ..
        pla                                     ; F087 68                       h
        sta     $83                             ; F088 85 83                    ..
        bmi     LF08F                           ; F08A 30 03                    0.
        jmp     LF09F                           ; F08C 4C 9F F0                 L..

; ----------------------------------------------------------------------------
LF08F:  pla                                     ; F08F 68                       h
        pla                                     ; F090 68                       h
        pla                                     ; F091 68                       h
        pla                                     ; F092 68                       h
        pla                                     ; F093 68                       h
        pla                                     ; F094 68                       h
        jmp     advance_two                     ; F095 4C 7B D2                 L{.

; ----------------------------------------------------------------------------
LF098:  pla                                     ; F098 68                       h
        beq     LF08F                           ; F099 F0 F4                    ..
        bmi     LF08F                           ; F09B 30 F2                    0.
        sta     $83                             ; F09D 85 83                    ..
LF09F:  pla                                     ; F09F 68                       h
        sta     $84                             ; F0A0 85 84                    ..
        pla                                     ; F0A2 68                       h
        sta     $85                             ; F0A3 85 85                    ..
        clc                                     ; F0A5 18                       .
        pla                                     ; F0A6 68                       h
        adc     $84                             ; F0A7 65 84                    e.
        sta     $84                             ; F0A9 85 84                    ..
        pla                                     ; F0AB 68                       h
        adc     $85                             ; F0AC 65 85                    e.
        sta     $85                             ; F0AE 85 85                    ..
        pla                                     ; F0B0 68                       h
        sta     $8E                             ; F0B1 85 8E                    ..
        tax                                     ; F0B3 AA                       .
        pla                                     ; F0B4 68                       h
        txa                                     ; F0B5 8A                       .
        jsr     validate_device_number          ; F0B6 20 A5 EE                  ..
        and     #$80                            ; F0B9 29 80                    ).
        beq     LF0C9                           ; F0BB F0 0C                    ..
        jsr     LF00E                           ; F0BD 20 0E F0                  ..
        txa                                     ; F0C0 8A                       .
        ldx     $86                             ; F0C1 A6 86                    ..
        jsr     LFF39                           ; F0C3 20 39 FF                  9.
        jmp     LF002                           ; F0C6 4C 02 F0                 L..

; ----------------------------------------------------------------------------
LF0C9:  txa                                     ; F0C9 8A                       .
        asl     a                               ; F0CA 0A                       .
        tay                                     ; F0CB A8                       .
        lda     $FEAF,y                         ; F0CC B9 AF FE                 ...
        beq     LF0E1                           ; F0CF F0 10                    ..
        cmp     #$FF                            ; F0D1 C9 FF                    ..
        beq     LF0F7                           ; F0D3 F0 22                    ."
        jsr     LF00E                           ; F0D5 20 0E F0                  ..
        txa                                     ; F0D8 8A                       .
        ldx     $86                             ; F0D9 A6 86                    ..
        jsr     LFF3C                           ; F0DB 20 3C FF                  <.
        jmp     LF002                           ; F0DE 4C 02 F0                 L..

; ----------------------------------------------------------------------------
LF0E1:  ldx     $FEAE,y                         ; F0E1 BE AE FE                 ...
        jsr     LF00E                           ; F0E4 20 0E F0                  ..
        lda     $86                             ; F0E7 A5 86                    ..
        bne     LF0F1                           ; F0E9 D0 06                    ..
        jsr     LFF12                           ; F0EB 20 12 FF                  ..
        jmp     LF002                           ; F0EE 4C 02 F0                 L..

; ----------------------------------------------------------------------------
LF0F1:  jsr     LFF0F                           ; F0F1 20 0F FF                  ..
        jmp     LF002                           ; F0F4 4C 02 F0                 L..

; ----------------------------------------------------------------------------
LF0F7:  lda     #$01                            ; F0F7 A9 01                    ..
        cpx     #$01                            ; F0F9 E0 01                    ..
        bne     LF0FF                           ; F0FB D0 02                    ..
        lda     #$00                            ; F0FD A9 00                    ..
LF0FF:  sta     $7E                             ; F0FF 85 7E                    .~
        cpx     #$09                            ; F101 E0 09                    ..
        bcc     LF109                           ; F103 90 04                    ..
        ldx     #$02                            ; F105 A2 02                    ..
        bne     LF12A                           ; F107 D0 21                    .!
LF109:  txa                                     ; F109 8A                       .
        asl     a                               ; F10A 0A                       .
        tax                                     ; F10B AA                       .
        lda     io_error_entry+1,x              ; F10C BD 83 EE                 ...
        sta     L0094                           ; F10F 85 94                    ..
        lda     io_mode,x                       ; F111 BD 84 EE                 ...
        sta     $95                             ; F114 85 95                    ..
        lda     output_device_vectors+14,x      ; F116 BD 93 EE                 ...
        sta     L0090                           ; F119 85 90                    ..
        lda     output_device_vectors+15,x      ; F11B BD 94 EE                 ...
        sta     $91                             ; F11E 85 91                    ..
        lda     $86                             ; F120 A5 86                    ..
        beq     LF12D                           ; F122 F0 09                    ..
        lda     $95                             ; F124 A5 95                    ..
        bne     LF131                           ; F126 D0 09                    ..
LF128:  ldx     #$03                            ; F128 A2 03                    ..
LF12A:  jmp     LF002                           ; F12A 4C 02 F0                 L..

; ----------------------------------------------------------------------------
LF12D:  lda     $91                             ; F12D A5 91                    ..
        beq     LF128                           ; F12F F0 F7                    ..
LF131:  ldx     $82                             ; F131 A6 82                    ..
        jmp     LF181                           ; F133 4C 81 F1                 L..

; ----------------------------------------------------------------------------
LF136:  lda     $86                             ; F136 A5 86                    ..
        bne     LF172                           ; F138 D0 38                    .8
        jsr     read_character_indirect         ; F13A 20 E2 F1                  ..
        ldx     #$00                            ; F13D A2 00                    ..
        sta     ($84,x)                         ; F13F 81 84                    ..
        ldy     $88                             ; F141 A4 88                    ..
        bne     LF168                           ; F143 D0 23                    .#
        cmp     $BE30                           ; F145 CD 30 BE                 .0.
        bne     LF168                           ; F148 D0 1E                    ..
        ldy     #$01                            ; F14A A0 01                    ..
        cpy     $8E                             ; F14C C4 8E                    ..
        beq     LF153                           ; F14E F0 03                    ..
        jmp     LF038                           ; F150 4C 38 F0                 L8.

; ----------------------------------------------------------------------------
LF153:  lda     #$00                            ; F153 A9 00                    ..
LF155:  sta     ($84,x)                         ; F155 81 84                    ..
        inc     $84                             ; F157 E6 84                    ..
        bne     LF15D                           ; F159 D0 02                    ..
        inc     $85                             ; F15B E6 85                    ..
LF15D:  dec     $82                             ; F15D C6 82                    ..
        bne     LF155                           ; F15F D0 F4                    ..
        dec     $83                             ; F161 C6 83                    ..
        bpl     LF155                           ; F163 10 F0                    ..
        jmp     LF038                           ; F165 4C 38 F0                 L8.

; ----------------------------------------------------------------------------
LF168:  ldy     $7E                             ; F168 A4 7E                    .~
        bne     LF179                           ; F16A D0 0D                    ..
        jsr     LF18A                           ; F16C 20 8A F1                  ..
        jmp     LF179                           ; F16F 4C 79 F1                 Ly.

; ----------------------------------------------------------------------------
LF172:  ldx     #$00                            ; F172 A2 00                    ..
        lda     ($84,x)                         ; F174 A1 84                    ..
        jsr     LF18A                           ; F176 20 8A F1                  ..
LF179:  inc     $84                             ; F179 E6 84                    ..
        bne     LF17F                           ; F17B D0 02                    ..
        inc     $85                             ; F17D E6 85                    ..
LF17F:  dec     $82                             ; F17F C6 82                    ..
LF181:  bne     LF136                           ; F181 D0 B3                    ..
        dec     $83                             ; F183 C6 83                    ..
        bpl     LF136                           ; F185 10 AF                    ..
        jmp     LF038                           ; F187 4C 38 F0                 L8.

; ----------------------------------------------------------------------------
LF18A:  ldy     $88                             ; F18A A4 88                    ..
        bne     LF1B6                           ; F18C D0 28                    .(
        ldy     $8E                             ; F18E A4 8E                    ..
        ldx     $A0,y                           ; F190 B6 A0                    ..
        beq     LF1AC                           ; F192 F0 18                    ..
        sec                                     ; F194 38                       8
        sbc     #$1F                            ; F195 E9 1F                    ..
        sta     L0098                           ; F197 85 98                    ..
LF199:  lda     #$20                            ; F199 A9 20                    . 
        dec     L0098                           ; F19B C6 98                    ..
        beq     LF1A5                           ; F19D F0 06                    ..
        jsr     write_character_indirect        ; F19F 20 D1 F1                  ..
        jmp     LF199                           ; F1A2 4C 99 F1                 L..

; ----------------------------------------------------------------------------
LF1A5:  ldx     #$00                            ; F1A5 A2 00                    ..
        ldy     $8E                             ; F1A7 A4 8E                    ..
        stx     $A0,y                           ; F1A9 96 A0                    ..
        rts                                     ; F1AB 60                       `

; ----------------------------------------------------------------------------
LF1AC:  cmp     #$10                            ; F1AC C9 10                    ..
        bne     LF1B6                           ; F1AE D0 06                    ..
        lda     #$01                            ; F1B0 A9 01                    ..
        sta     $A0,y                           ; F1B2 99 A0 00                 ...
        rts                                     ; F1B5 60                       `

; ----------------------------------------------------------------------------
LF1B6:  ldy     $8A                             ; F1B6 A4 8A                    ..
        bne     LF1C7                           ; F1B8 D0 0D                    ..
        cmp     #$0D                            ; F1BA C9 0D                    ..
        bne     LF1C7                           ; F1BC D0 09                    ..
        jsr     write_character_indirect        ; F1BE 20 D1 F1                  ..
        lda     #$0A                            ; F1C1 A9 0A                    ..
        jsr     write_character_indirect        ; F1C3 20 D1 F1                  ..
        rts                                     ; F1C6 60                       `

; ----------------------------------------------------------------------------
LF1C7:  jsr     write_character_indirect        ; F1C7 20 D1 F1                  ..
        rts                                     ; F1CA 60                       `

; ----------------------------------------------------------------------------
device_return_address_minus_one:
        .word   device_call_return - 1                           ; F1CB CC F1                    ..
; ----------------------------------------------------------------------------
device_call_return:
        stx     $BDDE                           ; F1CD 8E DE BD                 ...
        rts                                     ; F1D0 60                       `

; ----------------------------------------------------------------------------
write_character_indirect:
        tay                                     ; F1D1 A8                       .
        lda     device_return_address_minus_one+1; F1D2 AD CC F1                ...
        pha                                     ; F1D5 48                       H
        lda     device_return_address_minus_one ; F1D6 AD CB F1                 ...
        pha                                     ; F1D9 48                       H
        tya                                     ; F1DA 98                       .
        ldy     $8E                             ; F1DB A4 8E                    ..
        ldx     #$01                            ; F1DD A2 01                    ..
        jmp     (L0094)                         ; F1DF 6C 94 00                 l..

; ----------------------------------------------------------------------------
read_character_indirect:
        tay                                     ; F1E2 A8                       .
        lda     device_return_address_minus_one+1; F1E3 AD CC F1                ...
        pha                                     ; F1E6 48                       H
        lda     device_return_address_minus_one ; F1E7 AD CB F1                 ...
        pha                                     ; F1EA 48                       H
        tya                                     ; F1EB 98                       .
        ldy     $8E                             ; F1EC A4 8E                    ..
        ldx     #$00                            ; F1EE A2 00                    ..
        jmp     (L0090)                         ; F1F0 6C 90 00                 l..

; ----------------------------------------------------------------------------
core_segment_end_pointer:
        .word   $BD1C                           ; F1F3 1C BD                    ..
segment_directory_pointer:
        .word   $BE3E                           ; F1F5 3E BE                    >.
io_result_pointer:
        .word   $BDDE                           ; F1F7 DE BD                    ..
initial_vector_pointer:
        .word   $D6E4                           ; F1F9 E4 D6                    ..
; ----------------------------------------------------------------------------
        .byte   $00,$00                         ; F1FB 00 00                    ..
boot_message_column:
        .byte   $00                             ; F1FD 00                       .
boot_message_index:
        .byte   $00                             ; F1FE 00                       .
insert_boot_disk_message:
        .byte $0D, "Insert boot disk with SYSTEM.PASCAL", $0D, $0A
        .byte "on it, then press RETURN#"
wrong_system_version_message:
        .byte $0D, "SYSTEM.PASCAL is not version 1.2#"
; '#' terminates these messages; the relocated initializer displays them.

output_vector_table_pointer:
        .word   $EE85                           ; F260 85 EE                    ..
input_vector_table_pointer:
        .word   $EE95                           ; F262 95 EE                    ..
; ----------------------------------------------------------------------------
system_reset_indirect:
        jmp     (LFFE2)                         ; F264 6C E2 FF                 l..

; ----------------------------------------------------------------------------
initializer_source:
        .word   $F290                           ; F267 90 F2                    ..
; ----------------------------------------------------------------------------
copy_initializer:
        lda     initializer_source              ; F269 AD 67 F2                 .g.
        sta     L0000                           ; F26C 85 00                    ..
        lda     initializer_source+1            ; F26E AD 68 F2                 .h.
        sta     $01                             ; F271 85 01                    ..
        lda     #$68                            ; F273 A9 68                    .h
        sta     $03                             ; F275 85 03                    ..
        lda     #$00                            ; F277 A9 00                    ..
        sta     $02                             ; F279 85 02                    ..
        tax                                     ; F27B AA                       .
        tay                                     ; F27C A8                       .
LF27D:  lda     (L0000),y                       ; F27D B1 00                    ..
        sta     ($02),y                         ; F27F 91 02                    ..
        iny                                     ; F281 C8                       .
        bne     LF27D                           ; F282 D0 F9                    ..
        inc     $01                             ; F284 E6 01                    ..
        inc     $03                             ; F286 E6 03                    ..
        inx                                     ; F288 E8                       .
        cpx     #$05                            ; F289 E0 05                    ..
        bne     LF27D                           ; F28B D0 F0                    ..
        jmp     L6800                           ; F28D 4C 00 68                 L.h

; ----------------------------------------------------------------------------

; End of "NATIVE_SHARED" segment
; ----------------------------------------------------------------------------

.assert * - native_shared_start = $11AB, error, "Shared native runtime size changed"
