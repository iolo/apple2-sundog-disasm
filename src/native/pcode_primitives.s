; SYSTEM.APPLE native p-code primitives, including their shared-memory tail.
; File layout: alternate bank $D000-$DFFF, then common $E000-$E0E4.
; This CPU-contiguous view is scattered back to two disk extents by the manifest.
; The first instruction crossing the bank seam is STA $88 at $DFFF/$E000.
; Disassembly recipe: pcode_primitives.info. Tables are data, not instructions.



        .setcpu "6502"

; ----------------------------------------------------------------------------
L0000           := $0000
L0096           := $0096
L0098           := $0098
LE0E5           := $E0E5
LE285           := $E285
LE2D3           := $E2D3
LE2EF           := $E2EF
LE306           := $E306
LE32B           := $E32B
LE35C           := $E35C
LE371           := $E371
LE4E9           := $E4E9
LE66B           := $E66B
LE675           := $E675
LE67F           := $E67F
LE68A           := $E68A
LE6CF           := $E6CF
LE75C           := $E75C
LE803           := $E803
LE80B           := $E80B
LE819           := $E819
LE878           := $E878
LE8AA           := $E8AA
LE8DC           := $E8DC
LEED1           := $EED1
LEEDC           := $EEDC
LEEE7           := $EEE7
LEEF5           := $EEF5
LEEFF           := $EEFF
LEF7D           := $EF7D
LF041           := $F041
LF046           := $F046
LF269           := $F269
; ----------------------------------------------------------------------------

.segment        "PCODE_NATIVE": absolute

; Opcodes $80-$FF. The dispatcher uses twice the low seven bits as index.
opcode_vectors:
        .addr   absolute_integer ; $D000
        .addr   unsupported_opcode ; $D002
        .addr   add_integers ; $D004
        .addr   unsupported_opcode ; $D006
        .addr   LD5AF ; $D008
        .addr   unsupported_opcode ; $D00A
        .addr   divide_integers ; $D00C
        .addr   unsupported_opcode ; $D00E
        .addr   check_bounds ; $D010
        .addr   unsupported_opcode ; $D012
        .addr   unsupported_opcode ; $D014
        .addr   unsupported_opcode ; $D016
        .addr   unsupported_opcode ; $D018
        .addr   LD5C2 ; $D01A
        .addr   modulo_integers ; $D01C
        .addr   multiply_integers ; $D01E
        .addr   unsupported_opcode ; $D020
        .addr   negate_integer ; $D022
        .addr   unsupported_opcode ; $D024
        .addr   LD5D5 ; $D026
        .addr   unsupported_opcode ; $D028
        .addr   subtract_integers ; $D02A
        .addr   unsupported_opcode ; $D02C
        .addr   unsupported_opcode ; $D02E
        .addr   square_integer ; $D030
        .addr   unsupported_opcode ; $D032
        .addr   LD4BC ; $D034
        .addr   index_string ; $D036
        .addr   unsupported_opcode ; $D038
        .addr   load_extended ; $D03A
        .addr   LE67F ; $D03C
        .addr   load_nil ; $D03E
        .addr   unsupported_opcode ; $D040
        .addr   false_jump ; $D042
        .addr   LD9CB ; $D044
        .addr   LD9AF ; $D046
        .addr   LD9DE ; $D048
        .addr   load_global_address ; $D04A
        .addr   load_string_address ; $D04C
        .addr   load_extended_address ; $D04E
        .addr   LD59B ; $D050
        .addr   load_global ; $D052
        .addr   assign_string ; $D054
        .addr   store_global ; $D056
        .addr   case_jump ; $D058
        .addr   LE371 ; $D05A
        .addr   LE285 ; $D05C
        .addr   LDE2C ; $D05E
        .addr   LDE24 ; $D060
        .addr   LDE1C ; $D062
        .addr   load_intermediate_address ; $D064
        .addr   load_constant_words ; $D066
        .addr   LDE28 ; $D068
        .addr   LDE20 ; $D06A
        .addr   load_intermediate ; $D06C
        .addr   LDE18 ; $D06E
        .addr   store_intermediate ; $D070
        .addr   unconditional_jump ; $D072
        .addr   load_packed_field ; $D074
        .addr   store_packed_field ; $D076
        .addr   LD50A ; $D078
        .addr   LD539 ; $D07A
        .addr   LD567 ; $D07C
        .addr   LD581 ; $D07E
        .addr   LDA1D ; $D080
        .addr   LE35C ; $D082
        .addr   LE32B ; $D084
        .addr   LDFA9 ; $D086
        .addr   LDF7B ; $D088
        .addr   LDF73 ; $D08A
        .addr   load_local_address ; $D08C
        .addr   load_integer_constant ; $D08E
        .addr   LDF77 ; $D090
        .addr   LDF6F ; $D092
        .addr   LD2F7 ; $D094
        .addr   LDF7F ; $D096
        .addr   store_local ; $D098
        .addr   LE306 ; $D09A
        .addr   LE2D3 ; $D09C
        .addr   LE2EF ; $D09E
        .addr   load_packed_array_address ; $D0A0
        .addr   store_extended ; $D0A2
        .addr   advance_one ; $D0A4
        .addr   unsupported_opcode ; $D0A6
        .addr   unsupported_opcode ; $D0A8
        .addr   LE803 ; $D0AA
        .addr   LD6E4 ; $D0AC
        .addr   advance_one ; $D0AE
        .addr   LD2EA ; $D0B0
        .addr   LD2EA ; $D0B2
        .addr   LD2EA ; $D0B4
        .addr   LD2EA ; $D0B6
        .addr   LD2EA ; $D0B8
        .addr   LD2EA ; $D0BA
        .addr   LD2EA ; $D0BC
        .addr   LD2EA ; $D0BE
        .addr   LD2EA ; $D0C0
        .addr   LD2EA ; $D0C2
        .addr   LD2EA ; $D0C4
        .addr   LD2EA ; $D0C6
        .addr   LD2EA ; $D0C8
        .addr   LD2EA ; $D0CA
        .addr   LD2EA ; $D0CC
        .addr   LD2EA ; $D0CE
        .addr   LD359 ; $D0D0
        .addr   LD359 ; $D0D2
        .addr   LD359 ; $D0D4
        .addr   LD359 ; $D0D6
        .addr   LD359 ; $D0D8
        .addr   LD359 ; $D0DA
        .addr   LD359 ; $D0DC
        .addr   LD359 ; $D0DE
        .addr   LD359 ; $D0E0
        .addr   LD359 ; $D0E2
        .addr   LD359 ; $D0E4
        .addr   LD359 ; $D0E6
        .addr   LD359 ; $D0E8
        .addr   LD359 ; $D0EA
        .addr   LD359 ; $D0EC
        .addr   LD359 ; $D0EE
        .addr   LD4AB ; $D0F0
        .addr   LD4A8 ; $D0F2
        .addr   LD4A8 ; $D0F4
        .addr   LD4A8 ; $D0F6
        .addr   LD4A8 ; $D0F8
        .addr   LD4A8 ; $D0FA
        .addr   LD4A8 ; $D0FC
        .addr   LD4A8 ; $D0FE
; Standard-procedure selector vectors; unused zero entries are preserved.
standard_proc_vectors:
        .addr   LEEDC ; $D100
        .addr   LD673 ; $D102
        .addr   LE878 ; $D104
        .addr   LE878 ; $D106
        .addr   LE75C ; $D108
        .addr   LF041 ; $D10A
        .addr   LF046 ; $D10C
        .addr   unsupported_opcode ; $D10E
        .addr   unsupported_opcode ; $D110
        .addr   LE819 ; $D112
        .addr   LE68A ; $D114
        .addr   LE6CF ; $D116
        .addr   LEEFF ; $D118
        .addr   L0000 ; $D11A
        .addr   L0000 ; $D11C
        .addr   L0000 ; $D11E
        .addr   L0000 ; $D120
        .addr   L0000 ; $D122
        .addr   L0000 ; $D124
        .addr   L0000 ; $D126
        .addr   L0000 ; $D128
        .addr   LE66B ; $D12A
        .addr   LE675 ; $D12C
        .addr   unsupported_opcode ; $D12E
        .addr   unsupported_opcode ; $D130
        .addr   unsupported_opcode ; $D132
        .addr   unsupported_opcode ; $D134
        .addr   unsupported_opcode ; $D136
        .addr   unsupported_opcode ; $D138
        .addr   unsupported_opcode ; $D13A
        .addr   unsupported_opcode ; $D13C
        .addr   unsupported_opcode ; $D13E
        .addr   LD6AF ; $D140
        .addr   LD6C6 ; $D142
        .addr   LEED1 ; $D144
        .addr   LEEE7 ; $D146
        .addr   unsupported_opcode ; $D148
        .addr   LEEF5 ; $D14A
        .addr   LEF7D ; $D14C
        .addr   LE80B ; $D14E
        .addr   LE8DC ; $D150
; ----------------------------------------------------------------------------
runtime_entry:
        jmp     LF269 ; $D152

; ----------------------------------------------------------------------------
; Read one- or two-byte operand through $58/$59; return doubled value in $68/$69.
read_big_word_offset:
        lda     ($58),y ; $D155
        bpl     LD169 ; $D157
        sta     $69 ; $D159
        inc     $58 ; $D15B
        bne     LD161 ; $D15D
        inc     $59 ; $D15F
LD161:  lda     ($58),y ; $D161
        asl     a ; $D163
        sta     $68 ; $D164
        rol     $69 ; $D166
        rts ; $D168

; ----------------------------------------------------------------------------
LD169:  asl     a ; $D169
        sta     $68 ; $D16A
        lda     #$00 ; $D16C
        sta     $69 ; $D16E
        rts ; $D170

; ----------------------------------------------------------------------------
follow_static_links:
        lda     $52 ; $D171
        sta     $6C ; $D173
        lda     $53 ; $D175
        sta     $6D ; $D177
        cpx     #$00 ; $D179
        beq     LD18F ; $D17B
LD17D:  ldy     #$00 ; $D17D
        lda     ($6C),y ; $D17F
        sta     $7E ; $D181
        iny ; $D183
        lda     ($6C),y ; $D184
        sta     $6D ; $D186
        lda     $7E ; $D188
        sta     $6C ; $D18A
        dex ; $D18C
        bne     LD17D ; $D18D
LD18F:  rts ; $D18F

; ----------------------------------------------------------------------------
LD190:  lda     $BDE6 ; $D190
        bne     LD19B ; $D193
        ldx     $BDE7 ; $D195
        bne     LD19B ; $D198
        rts ; $D19A

; ----------------------------------------------------------------------------
LD19B:  sta     $5A ; $D19B
        lda     $BDE7 ; $D19D
        sta     $5B ; $D1A0
        lda     #$00 ; $D1A2
        sta     $BDE6 ; $D1A4
        lda     #$00 ; $D1A7
        sta     $BDE7 ; $D1A9
        rts ; $D1AC

; ----------------------------------------------------------------------------
; Ten-byte descriptor between routines. Field semantics remain unresolved.
descriptor_d1ad:
        .word   $D1AF,$D1FB,$FF00,$BDDE ; $D1AD
        .word   $007E ; $D1B5
; ----------------------------------------------------------------------------
LD1B7:  lda     #$01 ; $D1B7
        bpl     runtime_error ; $D1B9
        lda     #$02 ; $D1BB
        bpl     runtime_error ; $D1BD
        lda     #$03 ; $D1BF
        bpl     runtime_error ; $D1C1
LD1C3:  lda     #$00 ; $D1C3
        sta     $BDE6 ; $D1C5
        sta     $BDE7 ; $D1C8
        sta     $5A ; $D1CB
        sta     $5C ; $D1CD
        lda     #$80 ; $D1CF
        sta     $5D ; $D1D1
        lda     #$62 ; $D1D3
        sta     $5B ; $D1D5
        lda     #$04 ; $D1D7
        bpl     runtime_error ; $D1D9
        lda     #$05 ; $D1DB
        bpl     runtime_error ; $D1DD
LD1DF:  lda     #$06 ; $D1DF
        bpl     runtime_error ; $D1E1
        lda     #$08 ; $D1E3
        bpl     runtime_error ; $D1E5
        lda     #$09 ; $D1E7
        bpl     runtime_error ; $D1E9
        lda     #$0A ; $D1EB
        bpl     runtime_error ; $D1ED
unsupported_opcode:
        lda     #$0B ; $D1EF
        bpl     runtime_error ; $D1F1
        lda     #$0C ; $D1F3
        bpl     runtime_error ; $D1F5
LD1F7:  lda     #$0D ; $D1F7
        bpl     runtime_error ; $D1F9
runtime_error:
        cmp     #$0A ; $D1FB
        beq     LD20A ; $D1FD
        clc ; $D1FF
        adc     #$64 ; $D200
        sta     $BDDE ; $D202
        lda     #$00 ; $D205
        sta     $BDDF ; $D207
LD20A:  ldx     #$02 ; $D20A
        lda     $BD1E,x ; $D20C
        bne     LD21F ; $D20F
        lda     $BD1F,x ; $D211
        bne     LD21F ; $D214
        pha ; $D216
        lda     $BDDE ; $D217
        pha ; $D21A
        lda     #$00 ; $D21B
        beq     LD22C ; $D21D
LD21F:  lda     #$01 ; $D21F
        ldy     #$00 ; $D221
        cmp     ($56),y ; $D223
        beq     LD22A ; $D225
        jsr     LE4E9 ; $D227
LD22A:  lda     #$01 ; $D22A
LD22C:  sta     $90 ; $D22C
        lda     #$02 ; $D22E
        sta     $82 ; $D230
        jsr     LE0E5 ; $D232
        ldy     #$00 ; $D235
        lda     $50 ; $D237
        sta     ($52),y ; $D239
        iny ; $D23B
        lda     $51 ; $D23C
        sta     ($52),y ; $D23E
        ldy     #$04 ; $D240
        lda     ($52),y ; $D242
        sta     $80 ; $D244
        iny ; $D246
        lda     ($52),y ; $D247
        sta     $81 ; $D249
        lda     $80 ; $D24B
        sec ; $D24D
        sbc     #$04 ; $D24E
        sta     $80 ; $D250
        bcs     LD256 ; $D252
        dec     $81 ; $D254
LD256:  ldy     #$00 ; $D256
        lda     $80 ; $D258
        sec ; $D25A
        sbc     ($80),y ; $D25B
        ldy     #$08 ; $D25D
        sta     ($52),y ; $D25F
        ldy     #$01 ; $D261
        lda     $81 ; $D263
        sbc     ($80),y ; $D265
        ldy     #$09 ; $D267
        sta     ($52),y ; $D269
        jmp     dispatch ; $D26B

; ----------------------------------------------------------------------------
LD26E:  lda     $58 ; $D26E
        clc ; $D270
        adc     #$03 ; $D271
        sta     $58 ; $D273
        bcc     dispatch ; $D275
        inc     $59 ; $D277
        bcs     dispatch ; $D279
advance_two:
        lda     $58 ; $D27B
        clc ; $D27D
        adc     #$02 ; $D27E
        sta     $58 ; $D280
        bcc     dispatch ; $D282
        inc     $59 ; $D284
        bcs     dispatch ; $D286
push_short_constant:
        tax ; $D288
        tya ; $D289
        pha ; $D28A
        txa ; $D28B
        pha ; $D28C
advance_one:
        inc     $58 ; $D28D
        bne     dispatch ; $D28F
        inc     $59 ; $D291
; Fetch through the p-code IP. Low opcodes push short constants directly.
dispatch:
        ldy     #$00 ; $D293
        lda     ($58),y ; $D295
        bpl     push_short_constant ; $D297
        asl     a ; $D299
        sta     dispatch_jump+1 ; $D29A
; Self-modifying operand: dispatch writes the low vector byte at this label + 1.
dispatch_jump:
        jmp     (opcode_vectors) ; $D29D

; ----------------------------------------------------------------------------
false_jump:
        pla ; $D2A0
        tax ; $D2A1
        pla ; $D2A2
        txa ; $D2A3
        and     #$01 ; $D2A4
        bne     advance_two ; $D2A6
unconditional_jump:
        clc ; $D2A8
        ldy     #$01 ; $D2A9
        lda     ($58),y ; $D2AB
        bmi     LD2BA ; $D2AD
        adc     $58 ; $D2AF
        sta     $58 ; $D2B1
        bcc     advance_two ; $D2B3
        inc     $59 ; $D2B5
        jmp     advance_two ; $D2B7

; ----------------------------------------------------------------------------
LD2BA:  adc     $54 ; $D2BA
        sta     $7E ; $D2BC
        lda     #$FF ; $D2BE
        adc     $55 ; $D2C0
        sta     $7F ; $D2C2
        lda     $7E ; $D2C4
        sec ; $D2C6
        ldy     #$00 ; $D2C7
        sbc     ($7E),y ; $D2C9
        sta     $58 ; $D2CB
        lda     $7F ; $D2CD
        iny ; $D2CF
        sbc     ($7E),y ; $D2D0
        sta     $59 ; $D2D2
        jmp     dispatch ; $D2D4

; ----------------------------------------------------------------------------
load_nil:
        lda     #$00 ; $D2D7
        pha ; $D2D9
        pha ; $D2DA
        jmp     advance_one ; $D2DB

; ----------------------------------------------------------------------------
load_integer_constant:
        ldy     #$02 ; $D2DE
        lda     ($58),y ; $D2E0
        pha ; $D2E2
        dey ; $D2E3
        lda     ($58),y ; $D2E4
        pha ; $D2E6
        jmp     LD26E ; $D2E7

; ----------------------------------------------------------------------------
LD2EA:  sbc     #$A3 ; $D2EA
        tay ; $D2EC
        lda     ($52),y ; $D2ED
        pha ; $D2EF
        dey ; $D2F0
        lda     ($52),y ; $D2F1
        pha ; $D2F3
        jmp     advance_one ; $D2F4

; ----------------------------------------------------------------------------
LD2F7:  ldy     #$01 ; $D2F7
        jsr     read_big_word_offset ; $D2F9
        lda     $52 ; $D2FC
        clc ; $D2FE
        adc     $68 ; $D2FF
        sta     $6E ; $D301
        lda     $53 ; $D303
        adc     $69 ; $D305
        sta     $6F ; $D307
        ldy     #$0B ; $D309
        lda     ($6E),y ; $D30B
        pha ; $D30D
        dey ; $D30E
        lda     ($6E),y ; $D30F
        pha ; $D311
        jmp     advance_two ; $D312

; ----------------------------------------------------------------------------
load_local_address:
        ldy     #$01 ; $D315
        jsr     read_big_word_offset ; $D317
        lda     $52 ; $D31A
        clc ; $D31C
        adc     $68 ; $D31D
        sta     $6E ; $D31F
        lda     $53 ; $D321
        adc     $69 ; $D323
        sta     $6F ; $D325
        lda     $6E ; $D327
        clc ; $D329
        adc     #$0A ; $D32A
        sta     $6E ; $D32C
        bcc     LD332 ; $D32E
        inc     $6F ; $D330
LD332:  lda     $6F ; $D332
        pha ; $D334
        lda     $6E ; $D335
        pha ; $D337
        jmp     advance_two ; $D338

; ----------------------------------------------------------------------------
store_local:
        ldy     #$01 ; $D33B
        jsr     read_big_word_offset ; $D33D
        lda     $52 ; $D340
        clc ; $D342
        adc     $68 ; $D343
        sta     $6E ; $D345
        lda     $53 ; $D347
        adc     $69 ; $D349
        sta     $6F ; $D34B
        ldy     #$0A ; $D34D
        pla ; $D34F
        sta     ($6E),y ; $D350
        iny ; $D352
        pla ; $D353
        sta     ($6E),y ; $D354
        jmp     advance_two ; $D356

; ----------------------------------------------------------------------------
LD359:  sbc     #$C3 ; $D359
        tay ; $D35B
        lda     ($50),y ; $D35C
        pha ; $D35E
        dey ; $D35F
        lda     ($50),y ; $D360
        pha ; $D362
        jmp     advance_one ; $D363

; ----------------------------------------------------------------------------
load_global:
        ldy     #$01 ; $D366
        jsr     read_big_word_offset ; $D368
        lda     $50 ; $D36B
        clc ; $D36D
        adc     $68 ; $D36E
        sta     $6E ; $D370
        lda     $51 ; $D372
        adc     $69 ; $D374
        sta     $6F ; $D376
        ldy     #$0B ; $D378
        lda     ($6E),y ; $D37A
        pha ; $D37C
        dey ; $D37D
        lda     ($6E),y ; $D37E
        pha ; $D380
        jmp     advance_two ; $D381

; ----------------------------------------------------------------------------
load_global_address:
        ldy     #$01 ; $D384
        jsr     read_big_word_offset ; $D386
        lda     $50 ; $D389
        clc ; $D38B
        adc     $68 ; $D38C
        sta     $6E ; $D38E
        lda     $51 ; $D390
        adc     $69 ; $D392
        sta     $6F ; $D394
        lda     $6E ; $D396
        clc ; $D398
        adc     #$0A ; $D399
        sta     $6E ; $D39B
        bcc     LD3A1 ; $D39D
        inc     $6F ; $D39F
LD3A1:  lda     $6F ; $D3A1
        pha ; $D3A3
        lda     $6E ; $D3A4
        pha ; $D3A6
        jmp     advance_two ; $D3A7

; ----------------------------------------------------------------------------
store_global:
        ldy     #$01 ; $D3AA
        jsr     read_big_word_offset ; $D3AC
        lda     $50 ; $D3AF
        clc ; $D3B1
        adc     $68 ; $D3B2
        sta     $6E ; $D3B4
        lda     $51 ; $D3B6
        adc     $69 ; $D3B8
        sta     $6F ; $D3BA
        ldy     #$0A ; $D3BC
        pla ; $D3BE
        sta     ($6E),y ; $D3BF
        iny ; $D3C1
        pla ; $D3C2
        sta     ($6E),y ; $D3C3
        jmp     advance_two ; $D3C5

; ----------------------------------------------------------------------------
load_intermediate:
        ldy     #$01 ; $D3C8
        lda     ($58),y ; $D3CA
        tax ; $D3CC
        jsr     follow_static_links ; $D3CD
        ldy     #$02 ; $D3D0
        jsr     read_big_word_offset ; $D3D2
        lda     $68 ; $D3D5
        clc ; $D3D7
        adc     $6C ; $D3D8
        sta     $6E ; $D3DA
        lda     $69 ; $D3DC
        adc     $6D ; $D3DE
        sta     $6F ; $D3E0
        ldy     #$0B ; $D3E2
        lda     ($6E),y ; $D3E4
        pha ; $D3E6
        dey ; $D3E7
        lda     ($6E),y ; $D3E8
        pha ; $D3EA
        jmp     LD26E ; $D3EB

; ----------------------------------------------------------------------------
load_intermediate_address:
        ldy     #$01 ; $D3EE
        lda     ($58),y ; $D3F0
        tax ; $D3F2
        jsr     follow_static_links ; $D3F3
        ldy     #$02 ; $D3F6
        jsr     read_big_word_offset ; $D3F8
        lda     $68 ; $D3FB
        clc ; $D3FD
        adc     $6C ; $D3FE
        sta     $6E ; $D400
        lda     $69 ; $D402
        adc     $6D ; $D404
        sta     $6F ; $D406
        lda     $6E ; $D408
        clc ; $D40A
        adc     #$0A ; $D40B
        sta     $6E ; $D40D
        bcc     LD413 ; $D40F
        inc     $6F ; $D411
LD413:  lda     $6F ; $D413
        pha ; $D415
        lda     $6E ; $D416
        pha ; $D418
        jmp     LD26E ; $D419

; ----------------------------------------------------------------------------
store_intermediate:
        ldy     #$01 ; $D41C
        lda     ($58),y ; $D41E
        tax ; $D420
        jsr     follow_static_links ; $D421
        ldy     #$02 ; $D424
        jsr     read_big_word_offset ; $D426
        lda     $68 ; $D429
        clc ; $D42B
        adc     $6C ; $D42C
        sta     $6E ; $D42E
        lda     $69 ; $D430
        adc     $6D ; $D432
        sta     $6F ; $D434
        ldy     #$0A ; $D436
        pla ; $D438
        sta     ($6E),y ; $D439
        iny ; $D43B
        pla ; $D43C
        sta     ($6E),y ; $D43D
        jmp     LD26E ; $D43F

; ----------------------------------------------------------------------------
load_extended:
        ldy     #$01 ; $D442
        lda     ($58),y ; $D444
        asl     a ; $D446
        tax ; $D447
        iny ; $D448
        jsr     read_big_word_offset ; $D449
        lda     $BD9E,x ; $D44C
        clc ; $D44F
        adc     $68 ; $D450
        sta     $7E ; $D452
        lda     $BD9F,x ; $D454
        adc     $69 ; $D457
        sta     $7F ; $D459
        ldy     #$01 ; $D45B
        lda     ($7E),y ; $D45D
        pha ; $D45F
        dey ; $D460
        lda     ($7E),y ; $D461
        pha ; $D463
        jmp     LD26E ; $D464

; ----------------------------------------------------------------------------
store_extended:
        ldy     #$01 ; $D467
        lda     ($58),y ; $D469
        asl     a ; $D46B
        tax ; $D46C
        iny ; $D46D
        jsr     read_big_word_offset ; $D46E
        lda     $BD9E,x ; $D471
        clc ; $D474
        adc     $68 ; $D475
        sta     $7E ; $D477
        lda     $BD9F,x ; $D479
        adc     $69 ; $D47C
        sta     $7F ; $D47E
        ldy     #$00 ; $D480
        pla ; $D482
        sta     ($7E),y ; $D483
        iny ; $D485
        pla ; $D486
        sta     ($7E),y ; $D487
        jmp     LD26E ; $D489

; ----------------------------------------------------------------------------
load_extended_address:
        ldy     #$01 ; $D48C
        lda     ($58),y ; $D48E
        asl     a ; $D490
        tax ; $D491
        iny ; $D492
        jsr     read_big_word_offset ; $D493
        lda     $BD9E,x ; $D496
        clc ; $D499
        adc     $68 ; $D49A
        tay ; $D49C
        lda     $BD9F,x ; $D49D
        adc     $69 ; $D4A0
        pha ; $D4A2
        tya ; $D4A3
        pha ; $D4A4
        jmp     LD26E ; $D4A5

; ----------------------------------------------------------------------------
LD4A8:  sbc     #$F0 ; $D4A8
        tay ; $D4AA
LD4AB:  pla ; $D4AB
        sta     $7E ; $D4AC
        pla ; $D4AE
        sta     $7F ; $D4AF
        iny ; $D4B1
        lda     ($7E),y ; $D4B2
        pha ; $D4B4
        dey ; $D4B5
        lda     ($7E),y ; $D4B6
        pha ; $D4B8
        jmp     advance_one ; $D4B9

; ----------------------------------------------------------------------------
LD4BC:  pla ; $D4BC
        sta     $7E ; $D4BD
        pla ; $D4BF
        sta     $7F ; $D4C0
        pla ; $D4C2
        sta     $80 ; $D4C3
        pla ; $D4C5
        sta     $81 ; $D4C6
        ldy     #$00 ; $D4C8
        lda     $7E ; $D4CA
        sta     ($80),y ; $D4CC
        iny ; $D4CE
        lda     $7F ; $D4CF
        sta     ($80),y ; $D4D1
        jmp     advance_one ; $D4D3

; ----------------------------------------------------------------------------
load_constant_words:
        ldy     #$01 ; $D4D6
        lda     ($58),y ; $D4D8
        tax ; $D4DA
        tay ; $D4DB
        iny ; $D4DC
        tya ; $D4DD
        asl     a ; $D4DE
        sta     $7E ; $D4DF
        lda     $58 ; $D4E1
        and     #$01 ; $D4E3
        beq     LD4ED ; $D4E5
        inc     $58 ; $D4E7
        bne     LD4ED ; $D4E9
        inc     $59 ; $D4EB
LD4ED:  ldy     #$03 ; $D4ED
LD4EF:  lda     ($58),y ; $D4EF
        pha ; $D4F1
        dey ; $D4F2
        lda     ($58),y ; $D4F3
        pha ; $D4F5
        iny ; $D4F6
        iny ; $D4F7
        iny ; $D4F8
        dex ; $D4F9
        bne     LD4EF ; $D4FA
        lda     $58 ; $D4FC
        clc ; $D4FE
        adc     $7E ; $D4FF
        sta     $58 ; $D501
        bcc     LD507 ; $D503
        inc     $59 ; $D505
LD507:  jmp     dispatch ; $D507

; ----------------------------------------------------------------------------
LD50A:  ldy     #$01 ; $D50A
        lda     ($58),y ; $D50C
        sta     $7E ; $D50E
        asl     a ; $D510
        tay ; $D511
        sta     $80 ; $D512
        tsx ; $D514
        txa ; $D515
        sec ; $D516
        sbc     $80 ; $D517
        bcc     LD536 ; $D519
        sbc     #$08 ; $D51B
        bcc     LD536 ; $D51D
        ldx     $7E ; $D51F
        dey ; $D521
        pla ; $D522
        sta     $72 ; $D523
        pla ; $D525
        sta     $73 ; $D526
LD528:  lda     ($72),y ; $D528
        pha ; $D52A
        dey ; $D52B
        lda     ($72),y ; $D52C
        pha ; $D52E
        dey ; $D52F
        dex ; $D530
        bne     LD528 ; $D531
        jmp     advance_two ; $D533

; ----------------------------------------------------------------------------
LD536:  jmp     LD1C3 ; $D536

; ----------------------------------------------------------------------------
LD539:  ldy     #$01 ; $D539
        lda     ($58),y ; $D53B
        sta     $7E ; $D53D
        tsx ; $D53F
        txa ; $D540
        clc ; $D541
        adc     $7E ; $D542
        adc     $7E ; $D544
        tax ; $D546
        lda     $0101,x ; $D547
        sta     $74 ; $D54A
        lda     $0102,x ; $D54C
        sta     $75 ; $D54F
        dey ; $D551
        ldx     $7E ; $D552
        jmp     LD560 ; $D554

; ----------------------------------------------------------------------------
LD557:  pla ; $D557
        sta     ($74),y ; $D558
        iny ; $D55A
        pla ; $D55B
        sta     ($74),y ; $D55C
        iny ; $D55E
        dex ; $D55F
LD560:  bne     LD557 ; $D560
        pla ; $D562
        pla ; $D563
        jmp     advance_two ; $D564

; ----------------------------------------------------------------------------
LD567:  pla ; $D567
        sta     $7E ; $D568
        pla ; $D56A
        sta     $7F ; $D56B
        clc ; $D56D
        pla ; $D56E
        adc     $7E ; $D56F
        sta     $7E ; $D571
        pla ; $D573
        adc     $7F ; $D574
        sta     $7F ; $D576
        lda     #$00 ; $D578
        pha ; $D57A
        lda     ($7E),y ; $D57B
        pha ; $D57D
        jmp     advance_one ; $D57E

; ----------------------------------------------------------------------------
LD581:  pla ; $D581
        tax ; $D582
        pla ; $D583
        pla ; $D584
        sta     $7E ; $D585
        pla ; $D587
        sta     $7F ; $D588
        clc ; $D58A
        pla ; $D58B
        adc     $7E ; $D58C
        sta     $7E ; $D58E
        pla ; $D590
        adc     $7F ; $D591
        sta     $7F ; $D593
        txa ; $D595
        sta     ($7E),y ; $D596
        jmp     advance_one ; $D598

; ----------------------------------------------------------------------------
LD59B:  pla ; $D59B
        sta     $72 ; $D59C
        pla ; $D59E
        sta     $73 ; $D59F
        pla ; $D5A1
        sta     $74 ; $D5A2
        pla ; $D5A4
        sta     $75 ; $D5A5
        ldy     #$01 ; $D5A7
        jsr     read_big_word_offset ; $D5A9
        jmp     LE8AA ; $D5AC

; ----------------------------------------------------------------------------
LD5AF:  pla ; $D5AF
        sta     $7E ; $D5B0
        pla ; $D5B2
        sta     $7F ; $D5B3
        pla ; $D5B5
        tax ; $D5B6
        pla ; $D5B7
        and     $7F ; $D5B8
        pha ; $D5BA
        txa ; $D5BB
        and     $7E ; $D5BC
        pha ; $D5BE
        jmp     advance_one ; $D5BF

; ----------------------------------------------------------------------------
LD5C2:  pla ; $D5C2
        sta     $7E ; $D5C3
        pla ; $D5C5
        sta     $7F ; $D5C6
        pla ; $D5C8
        tax ; $D5C9
        pla ; $D5CA
        ora     $7F ; $D5CB
        pha ; $D5CD
        txa ; $D5CE
        ora     $7E ; $D5CF
        pha ; $D5D1
        jmp     advance_one ; $D5D2

; ----------------------------------------------------------------------------
LD5D5:  pla ; $D5D5
        tax ; $D5D6
        pla ; $D5D7
        eor     #$FF ; $D5D8
        pha ; $D5DA
        txa ; $D5DB
        eor     #$FF ; $D5DC
        pha ; $D5DE
        jmp     advance_one ; $D5DF

; ----------------------------------------------------------------------------
; Align the p-code pointer and select a backwards pointer from the case table.
case_jump:
        lda     #$01 ; $D5E2
        ora     $58 ; $D5E4
        sta     $58 ; $D5E6
        pla ; $D5E8
        sta     L0096 ; $D5E9
        pla ; $D5EB
        sta     $97 ; $D5EC
        ldy     #$02 ; $D5EE
        eor     ($58),y ; $D5F0
        bmi     LD605 ; $D5F2
        lda     ($58),y ; $D5F4
        cmp     $97 ; $D5F6
        bcc     LD609 ; $D5F8
        bne     LD665 ; $D5FA
        dey ; $D5FC
        lda     L0096 ; $D5FD
        cmp     ($58),y ; $D5FF
        bcs     LD609 ; $D601
        bcc     LD665 ; $D603
LD605:  lda     $97 ; $D605
        bmi     LD665 ; $D607
LD609:  ldy     #$04 ; $D609
        lda     ($58),y ; $D60B
        eor     $97 ; $D60D
        bmi     LD622 ; $D60F
        lda     $97 ; $D611
        cmp     ($58),y ; $D613
        bcc     LD626 ; $D615
        bne     LD665 ; $D617
        dey ; $D619
        lda     ($58),y ; $D61A
        cmp     L0096 ; $D61C
        bcs     LD626 ; $D61E
        bcc     LD665 ; $D620
LD622:  lda     $97 ; $D622
        bpl     LD665 ; $D624
LD626:  sec ; $D626
        ldy     #$01 ; $D627
        lda     L0096 ; $D629
        sbc     ($58),y ; $D62B
        sta     L0096 ; $D62D
        lda     $97 ; $D62F
        iny ; $D631
        sbc     ($58),y ; $D632
        sta     $97 ; $D634
        asl     L0096 ; $D636
        rol     $97 ; $D638
        lda     $58 ; $D63A
        clc ; $D63C
        adc     L0096 ; $D63D
        sta     L0096 ; $D63F
        lda     $59 ; $D641
        adc     $97 ; $D643
        sta     $97 ; $D645
        lda     L0096 ; $D647
        clc ; $D649
        adc     #$07 ; $D64A
        sta     L0096 ; $D64C
        bcc     LD652 ; $D64E
        inc     $97 ; $D650
LD652:  ldy     #$00 ; $D652
        sec ; $D654
        lda     L0096 ; $D655
        sbc     (L0096),y ; $D657
        sta     $58 ; $D659
        lda     $97 ; $D65B
        iny ; $D65D
        sbc     (L0096),y ; $D65E
        sta     $59 ; $D660
        jmp     dispatch ; $D662

; ----------------------------------------------------------------------------
LD665:  lda     $58 ; $D665
        clc ; $D667
        adc     #$05 ; $D668
        sta     $58 ; $D66A
        bcc     LD670 ; $D66C
        inc     $59 ; $D66E
LD670:  jmp     dispatch ; $D670

; ----------------------------------------------------------------------------
LD673:  jsr     LD190 ; $D673
        pla ; $D676
        sta     $7E ; $D677
        pla ; $D679
        sta     $7F ; $D67A
        pla ; $D67C
        sta     $80 ; $D67D
        pla ; $D67F
        sta     $81 ; $D680
        asl     $7E ; $D682
        rol     $7F ; $D684
        ldy     #$00 ; $D686
        lda     $5A ; $D688
        sta     ($80),y ; $D68A
        iny ; $D68C
        lda     $5B ; $D68D
        sta     ($80),y ; $D68F
        lda     $5A ; $D691
        clc ; $D693
        adc     $7E ; $D694
        sta     $5A ; $D696
        lda     $5B ; $D698
        adc     $7F ; $D69A
        sta     $5B ; $D69C
        sec ; $D69E
        lda     $5C ; $D69F
        sbc     $5A ; $D6A1
        lda     $5D ; $D6A3
        sbc     $5B ; $D6A5
        bcs     LD6AC ; $D6A7
        jmp     LD1C3 ; $D6A9

; ----------------------------------------------------------------------------
LD6AC:  jmp     advance_two ; $D6AC

; ----------------------------------------------------------------------------
LD6AF:  jsr     LD190 ; $D6AF
        pla ; $D6B2
        sta     $7E ; $D6B3
        pla ; $D6B5
        sta     $7F ; $D6B6
        ldy     #$00 ; $D6B8
        lda     $5A ; $D6BA
        sta     ($7E),y ; $D6BC
        iny ; $D6BE
        lda     $5B ; $D6BF
        sta     ($7E),y ; $D6C1
        jmp     advance_two ; $D6C3

; ----------------------------------------------------------------------------
LD6C6:  pla ; $D6C6
        sta     $7E ; $D6C7
        pla ; $D6C9
        sta     $7F ; $D6CA
        ldy     #$00 ; $D6CC
        lda     ($7E),y ; $D6CE
        sta     $5A ; $D6D0
        iny ; $D6D2
        lda     ($7E),y ; $D6D3
        sta     $5B ; $D6D5
        lda     #$00 ; $D6D7
        sta     $BDE6 ; $D6D9
        lda     #$00 ; $D6DC
        sta     $BDE7 ; $D6DE
        jmp     advance_two ; $D6E1

; ----------------------------------------------------------------------------
LD6E4:  lda     #$AD ; $D6E4
        sta     L0000 ; $D6E6
        lda     #$8A ; $D6E8
        sta     $01 ; $D6EA
        lda     #$C0 ; $D6EC
        sta     $02 ; $D6EE
        lda     #$6C ; $D6F0
        sta     $03 ; $D6F2
        lda     #$FC ; $D6F4
        sta     $04 ; $D6F6
        lda     #$FF ; $D6F8
        sta     $05 ; $D6FA
        jmp     L0000 ; $D6FC

; ----------------------------------------------------------------------------
absolute_integer:
        pla ; $D6FF
        tax ; $D700
        pla ; $D701
        bmi     LD70A ; $D702
        pha ; $D704
        txa ; $D705
        pha ; $D706
        jmp     advance_one ; $D707

; ----------------------------------------------------------------------------
LD70A:  tay ; $D70A
        clc ; $D70B
        txa ; $D70C
        eor     #$FF ; $D70D
        adc     #$01 ; $D70F
        tax ; $D711
        tya ; $D712
        eor     #$FF ; $D713
        adc     #$00 ; $D715
        pha ; $D717
        txa ; $D718
        pha ; $D719
        jmp     advance_one ; $D71A

; ----------------------------------------------------------------------------
add_integers:
        pla ; $D71D
        sta     $7E ; $D71E
        pla ; $D720
        sta     $7F ; $D721
        pla ; $D723
        tay ; $D724
        pla ; $D725
        tax ; $D726
        tya ; $D727
        clc ; $D728
        adc     $7E ; $D729
        tay ; $D72B
        txa ; $D72C
        adc     $7F ; $D72D
        pha ; $D72F
        tya ; $D730
        pha ; $D731
        jmp     advance_one ; $D732

; ----------------------------------------------------------------------------
negate_integer:
        pla ; $D735
        eor     #$FF ; $D736
        clc ; $D738
        adc     #$01 ; $D739
        tax ; $D73B
        pla ; $D73C
        eor     #$FF ; $D73D
        adc     #$00 ; $D73F
        pha ; $D741
        txa ; $D742
        pha ; $D743
        jmp     advance_one ; $D744

; ----------------------------------------------------------------------------
subtract_integers:
        pla ; $D747
        sta     $7E ; $D748
        pla ; $D74A
        sta     $7F ; $D74B
        pla ; $D74D
        tay ; $D74E
        pla ; $D74F
        tax ; $D750
        tya ; $D751
        sec ; $D752
        sbc     $7E ; $D753
        tay ; $D755
        txa ; $D756
        sbc     $7F ; $D757
        pha ; $D759
        tya ; $D75A
        pha ; $D75B
        jmp     advance_one ; $D75C

; ----------------------------------------------------------------------------
LD75F:  lda     #$00 ; $D75F
        sta     $6F ; $D761
        sta     $6E ; $D763
        ldx     #$10 ; $D765
LD767:  ror     $95 ; $D767
        ror     $94 ; $D769
        bcc     LD77A ; $D76B
        lda     $6E ; $D76D
        clc ; $D76F
        adc     $92 ; $D770
        sta     $6E ; $D772
        lda     $6F ; $D774
        adc     $93 ; $D776
        sta     $6F ; $D778
LD77A:  ror     $6F ; $D77A
        ror     $6E ; $D77C
        ror     $97 ; $D77E
        ror     L0096 ; $D780
        dex ; $D782
        bne     LD767 ; $D783
        rts ; $D785

; ----------------------------------------------------------------------------
multiply_integers:
        pla ; $D786
        sta     $94 ; $D787
        pla ; $D789
        sta     $95 ; $D78A
        bmi     LD797 ; $D78C
        pla ; $D78E
        sta     $92 ; $D78F
        pla ; $D791
        sta     $93 ; $D792
        jmp     LD7C1 ; $D794

; ----------------------------------------------------------------------------
LD797:  pla ; $D797
        sta     $92 ; $D798
        pla ; $D79A
        sta     $93 ; $D79B
        bpl     LD7C1 ; $D79D
        lda     $94 ; $D79F
        eor     #$FF ; $D7A1
        clc ; $D7A3
        adc     #$01 ; $D7A4
        sta     $94 ; $D7A6
        lda     $95 ; $D7A8
        eor     #$FF ; $D7AA
        adc     #$00 ; $D7AC
        sta     $95 ; $D7AE
        lda     $92 ; $D7B0
        eor     #$FF ; $D7B2
        clc ; $D7B4
        adc     #$01 ; $D7B5
        sta     $92 ; $D7B7
        lda     $93 ; $D7B9
        eor     #$FF ; $D7BB
        adc     #$00 ; $D7BD
        sta     $93 ; $D7BF
LD7C1:  jsr     LD75F ; $D7C1
        lda     $97 ; $D7C4
        pha ; $D7C6
        lda     L0096 ; $D7C7
        pha ; $D7C9
        jmp     advance_one ; $D7CA

; ----------------------------------------------------------------------------
square_integer:
        tsx ; $D7CD
        lda     $0102,x ; $D7CE
        pha ; $D7D1
        lda     $0101,x ; $D7D2
        pha ; $D7D5
        jmp     multiply_integers ; $D7D6

; ----------------------------------------------------------------------------
LD7D9:  ldy     #$00 ; $D7D9
        sty     $94 ; $D7DB
        sty     $6E ; $D7DD
        sty     $6F ; $D7DF
        sty     L0096 ; $D7E1
        sty     $97 ; $D7E3
        lda     $90 ; $D7E5
        bne     LD7F0 ; $D7E7
        lda     $91 ; $D7E9
        bne     LD7F0 ; $D7EB
        jmp     LD1DF ; $D7ED

; ----------------------------------------------------------------------------
LD7F0:  lda     $91 ; $D7F0
        bpl     LD807 ; $D7F2
        lda     $90 ; $D7F4
        eor     #$FF ; $D7F6
        clc ; $D7F8
        adc     #$01 ; $D7F9
        sta     $90 ; $D7FB
        lda     $91 ; $D7FD
        eor     #$FF ; $D7FF
        adc     #$00 ; $D801
        sta     $91 ; $D803
        inc     $94 ; $D805
LD807:  lda     $93 ; $D807
        bpl     LD81E ; $D809
        lda     $92 ; $D80B
        eor     #$FF ; $D80D
        clc ; $D80F
        adc     #$01 ; $D810
        sta     $92 ; $D812
        lda     $93 ; $D814
        eor     #$FF ; $D816
        adc     #$00 ; $D818
        sta     $93 ; $D81A
        dec     $94 ; $D81C
LD81E:  sec ; $D81E
        lda     $92 ; $D81F
        sbc     $90 ; $D821
        lda     $93 ; $D823
        sbc     $91 ; $D825
        bcs     LD836 ; $D827
        sty     L0096 ; $D829
        sty     $97 ; $D82B
        lda     $92 ; $D82D
        sta     $92 ; $D82F
        lda     $93 ; $D831
        sta     $93 ; $D833
        rts ; $D835

; ----------------------------------------------------------------------------
LD836:  clc ; $D836
        ldx     #$10 ; $D837
        lda     $93 ; $D839
        bne     LD847 ; $D83B
        lda     $90 ; $D83D
        sta     $6F ; $D83F
        lda     $91 ; $D841
        sta     $90 ; $D843
        ldx     #$08 ; $D845
LD847:  clc ; $D847
        ror     $91 ; $D848
        bne     LD86E ; $D84A
        ror     $90 ; $D84C
        bne     LD870 ; $D84E
LD850:  ror     $6F ; $D850
        ror     $6E ; $D852
        lda     $92 ; $D854
        sec ; $D856
        sbc     $6E ; $D857
        tay ; $D859
        lda     $93 ; $D85A
        sbc     $6F ; $D85C
        bcc     LD875 ; $D85E
        sta     $93 ; $D860
        sty     $92 ; $D862
        sec ; $D864
        rol     L0096 ; $D865
        rol     $97 ; $D867
        dex ; $D869
        clc ; $D86A
        bne     LD850 ; $D86B
        rts ; $D86D

; ----------------------------------------------------------------------------
LD86E:  ror     $90 ; $D86E
LD870:  ror     $6F ; $D870
        ror     $6E ; $D872
        clc ; $D874
LD875:  rol     L0096 ; $D875
        rol     $97 ; $D877
        dex ; $D879
        bne     LD847 ; $D87A
        rts ; $D87C

; ----------------------------------------------------------------------------
divide_integers:
        pla ; $D87D
        sta     $90 ; $D87E
        pla ; $D880
        sta     $91 ; $D881
        pla ; $D883
        sta     $92 ; $D884
        pla ; $D886
        sta     $93 ; $D887
        jsr     LD7D9 ; $D889
        lda     $94 ; $D88C
        beq     LD8A1 ; $D88E
        lda     L0096 ; $D890
        eor     #$FF ; $D892
        clc ; $D894
        adc     #$01 ; $D895
        sta     L0096 ; $D897
        lda     $97 ; $D899
        eor     #$FF ; $D89B
        adc     #$00 ; $D89D
        sta     $97 ; $D89F
LD8A1:  lda     $97 ; $D8A1
        pha ; $D8A3
        lda     L0096 ; $D8A4
        pha ; $D8A6
        jmp     advance_one ; $D8A7

; ----------------------------------------------------------------------------
modulo_integers:
        pla ; $D8AA
        sta     $90 ; $D8AB
        pla ; $D8AD
        sta     $91 ; $D8AE
        pla ; $D8B0
        sta     $92 ; $D8B1
        pla ; $D8B3
        sta     $93 ; $D8B4
        jsr     LD7D9 ; $D8B6
        lda     $93 ; $D8B9
        pha ; $D8BB
        lda     $92 ; $D8BC
        pha ; $D8BE
        jmp     advance_one ; $D8BF

; ----------------------------------------------------------------------------
check_bounds:
        pla ; $D8C2
        sta     $7E ; $D8C3
        pla ; $D8C5
        sta     $7F ; $D8C6
        pla ; $D8C8
        sta     $80 ; $D8C9
        pla ; $D8CB
        sta     $81 ; $D8CC
        tsx ; $D8CE
        lda     $0101,x ; $D8CF
        sta     $82 ; $D8D2
        lda     $0102,x ; $D8D4
        sta     $83 ; $D8D7
        eor     $81 ; $D8D9
        bmi     LD8ED ; $D8DB
        lda     $81 ; $D8DD
        cmp     $83 ; $D8DF
        bcc     LD8F1 ; $D8E1
        bne     LD90E ; $D8E3
        lda     $82 ; $D8E5
        cmp     $80 ; $D8E7
        bcs     LD8F1 ; $D8E9
        bcc     LD90E ; $D8EB
LD8ED:  lda     $83 ; $D8ED
        bmi     LD90E ; $D8EF
LD8F1:  lda     $7F ; $D8F1
        eor     $83 ; $D8F3
        bmi     LD907 ; $D8F5
        lda     $83 ; $D8F7
        cmp     $7F ; $D8F9
        bcc     LD90B ; $D8FB
        bne     LD90E ; $D8FD
        lda     $7E ; $D8FF
        cmp     $82 ; $D901
        bcs     LD90B ; $D903
        bcc     LD90E ; $D905
LD907:  lda     $83 ; $D907
        bpl     LD90E ; $D909
LD90B:  jmp     advance_one ; $D90B

; ----------------------------------------------------------------------------
LD90E:  jmp     LD1B7 ; $D90E

; ----------------------------------------------------------------------------
load_packed_array_address:
        inc     $58 ; $D911
        bne     LD917 ; $D913
        inc     $59 ; $D915
LD917:  lda     ($58),y ; $D917
        tax ; $D919
        inc     $58 ; $D91A
        bne     LD920 ; $D91C
        inc     $59 ; $D91E
LD920:  lda     $59 ; $D920
        pha ; $D922
        lda     $58 ; $D923
        pha ; $D925
        jmp     LD93E ; $D926

; ----------------------------------------------------------------------------
load_string_address:
        inc     $58 ; $D929
        bne     LD92F ; $D92B
        inc     $59 ; $D92D
LD92F:  lda     $59 ; $D92F
        pha ; $D931
        lda     $58 ; $D932
        pha ; $D934
        lda     ($58),y ; $D935
        tax ; $D937
        inc     $58 ; $D938
        bne     LD93E ; $D93A
        inc     $59 ; $D93C
LD93E:  clc ; $D93E
        txa ; $D93F
        adc     $58 ; $D940
        sta     $58 ; $D942
        bcc     LD948 ; $D944
        inc     $59 ; $D946
LD948:  jmp     dispatch ; $D948

; ----------------------------------------------------------------------------
assign_string:
        pla ; $D94B
        sta     $72 ; $D94C
        pla ; $D94E
        sta     $73 ; $D94F
        pla ; $D951
        sta     $74 ; $D952
        pla ; $D954
        sta     $75 ; $D955
        ldy     #$01 ; $D957
        lda     ($58),y ; $D959
        ldx     $73 ; $D95B
        bne     LD971 ; $D95D
        cmp     #$01 ; $D95F
        bcc     LD989 ; $D961
        lda     #$01 ; $D963
        ldy     #$00 ; $D965
        sta     ($74),y ; $D967
        lda     $72 ; $D969
        iny ; $D96B
        sta     ($74),y ; $D96C
        jmp     advance_two ; $D96E

; ----------------------------------------------------------------------------
LD971:  ldy     #$00 ; $D971
        cmp     ($72),y ; $D973
        bcc     LD989 ; $D975
        lda     ($72),y ; $D977
        sta     ($74),y ; $D979
        tay ; $D97B
        jmp     LD984 ; $D97C

; ----------------------------------------------------------------------------
LD97F:  lda     ($72),y ; $D97F
        sta     ($74),y ; $D981
        dey ; $D983
LD984:  bne     LD97F ; $D984
        jmp     advance_two ; $D986

; ----------------------------------------------------------------------------
LD989:  jmp     LD1F7 ; $D989

; ----------------------------------------------------------------------------
index_string:
        tsx ; $D98C
        lda     $0102,x ; $D98D
        bne     LD9A9 ; $D990
        lda     $0101,x ; $D992
        beq     LD9A9 ; $D995
        ldy     $0103,x ; $D997
        sty     $7E ; $D99A
        ldy     $0104,x ; $D99C
        sty     $7F ; $D99F
        ldy     #$00 ; $D9A1
        cmp     ($7E),y ; $D9A3
        bcc     LD9AC ; $D9A5
        beq     LD9AC ; $D9A7
LD9A9:  jmp     LD1B7 ; $D9A9

; ----------------------------------------------------------------------------
LD9AC:  jmp     advance_one ; $D9AC

; ----------------------------------------------------------------------------
LD9AF:  ldy     #$01 ; $D9AF
        jsr     read_big_word_offset ; $D9B1
        clc ; $D9B4
        pla ; $D9B5
        adc     $68 ; $D9B6
        sta     $82 ; $D9B8
        pla ; $D9BA
        adc     $69 ; $D9BB
        sta     $83 ; $D9BD
        ldy     #$01 ; $D9BF
        lda     ($82),y ; $D9C1
        pha ; $D9C3
        dey ; $D9C4
        lda     ($82),y ; $D9C5
        pha ; $D9C7
        jmp     advance_two ; $D9C8

; ----------------------------------------------------------------------------
LD9CB:  ldy     #$01 ; $D9CB
        jsr     read_big_word_offset ; $D9CD
        clc ; $D9D0
        pla ; $D9D1
        adc     $68 ; $D9D2
        tax ; $D9D4
        pla ; $D9D5
        adc     $69 ; $D9D6
        pha ; $D9D8
        txa ; $D9D9
        pha ; $D9DA
        jmp     advance_two ; $D9DB

; ----------------------------------------------------------------------------
LD9DE:  pla ; $D9DE
        sta     $92 ; $D9DF
        pla ; $D9E1
        sta     $93 ; $D9E2
        ldy     #$01 ; $D9E4
        jsr     read_big_word_offset ; $D9E6
        lda     $69 ; $D9E9
        bne     LD9FA ; $D9EB
        lda     $68 ; $D9ED
        cmp     #$02 ; $D9EF
        bne     LD9FA ; $D9F1
        asl     $92 ; $D9F3
        rol     $93 ; $D9F5
        jmp     LDA0D ; $D9F7

; ----------------------------------------------------------------------------
LD9FA:  lda     $68 ; $D9FA
        sta     $94 ; $D9FC
        lda     $69 ; $D9FE
        sta     $95 ; $DA00
        jsr     LD75F ; $DA02
        lda     L0096 ; $DA05
        sta     $92 ; $DA07
        lda     $97 ; $DA09
        sta     $93 ; $DA0B
LDA0D:  clc ; $DA0D
        pla ; $DA0E
        adc     $92 ; $DA0F
        sta     $82 ; $DA11
        pla ; $DA13
        adc     $93 ; $DA14
        pha ; $DA16
        lda     $82 ; $DA17
        pha ; $DA19
        jmp     advance_two ; $DA1A

; ----------------------------------------------------------------------------
LDA1D:  ldy     #$01 ; $DA1D
        lda     ($58),y ; $DA1F
        sta     $90 ; $DA21
        ldy     #$02 ; $DA23
        lda     ($58),y ; $DA25
        sta     $84 ; $DA27
        lda     #$00 ; $DA29
        sta     $91 ; $DA2B
        sta     $85 ; $DA2D
        pla ; $DA2F
        sta     $92 ; $DA30
        pla ; $DA32
        sta     $93 ; $DA33
        jsr     LD7D9 ; $DA35
        asl     L0096 ; $DA38
        rol     $97 ; $DA3A
        clc ; $DA3C
        pla ; $DA3D
        adc     L0096 ; $DA3E
        sta     $82 ; $DA40
        pla ; $DA42
        adc     $97 ; $DA43
        pha ; $DA45
        lda     $82 ; $DA46
        pha ; $DA48
        lda     $85 ; $DA49
        pha ; $DA4B
        lda     $84 ; $DA4C
        pha ; $DA4E
        lda     #$00 ; $DA4F
        ldx     $92 ; $DA51
        beq     LDA5B ; $DA53
        clc ; $DA55
LDA56:  adc     $84 ; $DA56
        dex ; $DA58
        bne     LDA56 ; $DA59
LDA5B:  pha ; $DA5B
        pha ; $DA5C
        jmp     LD26E ; $DA5D

; ----------------------------------------------------------------------------
load_packed_field:
        pla ; $DA60
        sta     $86 ; $DA61
        pla ; $DA63
        sta     $87 ; $DA64
        pla ; $DA66
        sta     $84 ; $DA67
        pla ; $DA69
        sta     $85 ; $DA6A
        pla ; $DA6C
        sta     $82 ; $DA6D
        pla ; $DA6F
        sta     $83 ; $DA70
        ldy     #$00 ; $DA72
        lda     ($82),y ; $DA74
        sta     $88 ; $DA76
        iny ; $DA78
        lda     ($82),y ; $DA79
        sta     $89 ; $DA7B
        lda     $86 ; $DA7D
        sec ; $DA7F
        sbc     #$08 ; $DA80
        bmi     LDA93 ; $DA82
        tax ; $DA84
        lda     $88 ; $DA85
        ldy     $89 ; $DA87
        sty     $88 ; $DA89
        sta     $89 ; $DA8B
        cpx     #$00 ; $DA8D
        bne     LDA98 ; $DA8F
        beq     LDA9F ; $DA91
LDA93:  adc     #$08 ; $DA93
        tax ; $DA95
        beq     LDA9F ; $DA96
LDA98:  ror     $89 ; $DA98
        ror     $88 ; $DA9A
        dex ; $DA9C
        bne     LDA98 ; $DA9D
LDA9F:  lda     $84 ; $DA9F
        asl     a ; $DAA1
        tax ; $DAA2
        lda     $88 ; $DAA3
        and     low_bit_masks,x ; $DAA5
        sta     $88 ; $DAA8
        lda     $89 ; $DAAA
        and     low_bit_masks+1,x ; $DAAC
        pha ; $DAAF
        lda     $88 ; $DAB0
        pha ; $DAB2
        jmp     advance_one ; $DAB3

; ----------------------------------------------------------------------------
store_packed_field:
        pla ; $DAB6
        sta     $7E ; $DAB7
        pla ; $DAB9
        sta     $7F ; $DABA
        pla ; $DABC
        sta     $86 ; $DABD
        pla ; $DABF
        sta     $87 ; $DAC0
        pla ; $DAC2
        sta     $84 ; $DAC3
        pla ; $DAC5
        sta     $85 ; $DAC6
        lda     $84 ; $DAC8
        asl     a ; $DACA
        tax ; $DACB
        lda     low_bit_masks,x ; $DACC
        sta     $80 ; $DACF
        and     $7E ; $DAD1
        sta     $7E ; $DAD3
        lda     low_bit_masks+1,x ; $DAD5
        sta     $81 ; $DAD8
        and     $7F ; $DADA
        sta     $7F ; $DADC
        lda     $86 ; $DADE
        sec ; $DAE0
        sbc     #$08 ; $DAE1
        bmi     LDAFC ; $DAE3
        tax ; $DAE5
        lda     $7E ; $DAE6
        ldy     $7F ; $DAE8
        sta     $7F ; $DAEA
        sty     $7E ; $DAEC
        lda     $80 ; $DAEE
        ldy     $81 ; $DAF0
        sta     $81 ; $DAF2
        sty     $80 ; $DAF4
        cpx     #$00 ; $DAF6
        bne     LDB01 ; $DAF8
        beq     LDB0C ; $DAFA
LDAFC:  adc     #$08 ; $DAFC
        tax ; $DAFE
        beq     LDB0C ; $DAFF
LDB01:  asl     $7E ; $DB01
        rol     $7F ; $DB03
        asl     $80 ; $DB05
        rol     $81 ; $DB07
        dex ; $DB09
        bne     LDB01 ; $DB0A
LDB0C:  pla ; $DB0C
        sta     $82 ; $DB0D
        pla ; $DB0F
        sta     $83 ; $DB10
        ldy     #$00 ; $DB12
        lda     ($82),y ; $DB14
        sta     $88 ; $DB16
        iny ; $DB18
        lda     ($82),y ; $DB19
        sta     $89 ; $DB1B
        lda     $80 ; $DB1D
        eor     #$FF ; $DB1F
        and     $88 ; $DB21
        ora     $7E ; $DB23
        sta     $88 ; $DB25
        lda     $81 ; $DB27
        eor     #$FF ; $DB29
        and     $89 ; $DB2B
        ora     $7F ; $DB2D
        sta     $89 ; $DB2F
        ldy     #$00 ; $DB31
        lda     $88 ; $DB33
        sta     ($82),y ; $DB35
        iny ; $DB37
        lda     $89 ; $DB38
        sta     ($82),y ; $DB3A
        jmp     advance_one ; $DB3C

; ----------------------------------------------------------------------------
LDB3F:  pla ; $DB3F
        sta     L0096 ; $DB40
        pla ; $DB42
        sta     $97 ; $DB43
        pla ; $DB45
        asl     a ; $DB46
        sta     $86 ; $DB47
        pla ; $DB49
        tsx ; $DB4A
        txa ; $DB4B
        clc ; $DB4C
        adc     $86 ; $DB4D
        tay ; $DB4F
        iny ; $DB50
        sty     $88 ; $DB51
        lda     $0100,y ; $DB53
        asl     a ; $DB56
        iny ; $DB57
        iny ; $DB58
        sty     $7E ; $DB59
        inc     L0096 ; $DB5B
        bne     LDB61 ; $DB5D
        inc     $97 ; $DB5F
LDB61:  jmp     (L0096) ; $DB61

; ----------------------------------------------------------------------------
        jsr     LDB3F ; $DB64
        ldx     $86 ; $DB67
        sec ; $DB69
        sbc     $86 ; $DB6A
        bpl     LDB74 ; $DB6C
        clc ; $DB6E
        adc     $86 ; $DB6F
        tax ; $DB71
        lda     #$00 ; $DB72
LDB74:  sta     $9A ; $DB74
        cpx     #$00 ; $DB76
        beq     LDB85 ; $DB78
LDB7A:  pla ; $DB7A
        and     $0100,y ; $DB7B
        sta     $0100,y ; $DB7E
        iny ; $DB81
        dex ; $DB82
        bne     LDB7A ; $DB83
LDB85:  ldx     $9A ; $DB85
        beq     LDB94 ; $DB87
        bmi     LDB94 ; $DB89
        lda     #$00 ; $DB8B
LDB8D:  sta     $0100,y ; $DB8D
        iny ; $DB90
        dex ; $DB91
        bne     LDB8D ; $DB92
LDB94:  ldx     $88 ; $DB94
        dex ; $DB96
        txs ; $DB97
        jmp     advance_one ; $DB98

; ----------------------------------------------------------------------------
        jsr     LDB3F ; $DB9B
        ldx     $86 ; $DB9E
        cmp     $86 ; $DBA0
        bpl     LDBA5 ; $DBA2
        tax ; $DBA4
LDBA5:  cpx     #$00 ; $DBA5
        beq     LDBB6 ; $DBA7
LDBA9:  pla ; $DBA9
        eor     #$FF ; $DBAA
        and     $0100,y ; $DBAC
        sta     $0100,y ; $DBAF
        iny ; $DBB2
        dex ; $DBB3
        bne     LDBA9 ; $DBB4
LDBB6:  ldx     $88 ; $DBB6
        dex ; $DBB8
        txs ; $DBB9
        jmp     advance_one ; $DBBA

; ----------------------------------------------------------------------------
        jsr     LDB3F ; $DBBD
        cmp     $86 ; $DBC0
        bmi     LDBDC ; $DBC2
        ldx     $86 ; $DBC4
        cpx     #$00 ; $DBC6
        beq     LDBD5 ; $DBC8
LDBCA:  pla ; $DBCA
        ora     $0100,y ; $DBCB
        sta     $0100,y ; $DBCE
        iny ; $DBD1
        dex ; $DBD2
        bne     LDBCA ; $DBD3
LDBD5:  ldx     $88 ; $DBD5
        dex ; $DBD7
        txs ; $DBD8
        jmp     advance_one ; $DBD9

; ----------------------------------------------------------------------------
LDBDC:  sta     $84 ; $DBDC
        cmp     #$00 ; $DBDE
        bne     LDBE4 ; $DBE0
        beq     LDBFF ; $DBE2
LDBE4:  tsx ; $DBE4
        inx ; $DBE5
        ldy     $7E ; $DBE6
        lda     $84 ; $DBE8
        sta     $82 ; $DBEA
        lda     $85 ; $DBEC
        sta     $83 ; $DBEE
LDBF0:  lda     $0100,y ; $DBF0
        ora     $0100,x ; $DBF3
        sta     $0100,x ; $DBF6
        iny ; $DBF9
        inx ; $DBFA
        dec     $82 ; $DBFB
        bne     LDBF0 ; $DBFD
LDBFF:  lda     $7E ; $DBFF
        clc ; $DC01
        adc     $84 ; $DC02
        tax ; $DC04
        dex ; $DC05
        lda     $86 ; $DC06
        sta     $82 ; $DC08
        lda     $87 ; $DC0A
        sta     $83 ; $DC0C
        ldy     $88 ; $DC0E
        dey ; $DC10
LDC11:  lda     $0100,y ; $DC11
        sta     $0100,x ; $DC14
        dey ; $DC17
        dex ; $DC18
        dec     $82 ; $DC19
        bne     LDC11 ; $DC1B
        txs ; $DC1D
        lsr     $86 ; $DC1E
        lda     $87 ; $DC20
        pha ; $DC22
        lda     $86 ; $DC23
        pha ; $DC25
        jmp     advance_one ; $DC26

; ----------------------------------------------------------------------------
        ldy     #$01 ; $DC29
        lda     ($58),y ; $DC2B
        asl     a ; $DC2D
        sta     $8E ; $DC2E
        pla ; $DC30
        sta     $8C ; $DC31
        pla ; $DC33
        sta     $8D ; $DC34
        asl     $8C ; $DC36
        rol     $8D ; $DC38
        lda     $8C ; $DC3A
        cmp     $8E ; $DC3C
        bne     LDC43 ; $DC3E
        jmp     advance_two ; $DC40

; ----------------------------------------------------------------------------
LDC43:  bmi     LDC60 ; $DC43
        tsx ; $DC45
        txa ; $DC46
        clc ; $DC47
        adc     $8E ; $DC48
        tay ; $DC4A
        txa ; $DC4B
        clc ; $DC4C
        adc     $8C ; $DC4D
        tax ; $DC4F
LDC50:  lda     $0100,y ; $DC50
        sta     $0100,x ; $DC53
        dey ; $DC56
        dex ; $DC57
        dec     $8E ; $DC58
        bne     LDC50 ; $DC5A
        txs ; $DC5C
        jmp     advance_two ; $DC5D

; ----------------------------------------------------------------------------
LDC60:  lda     $8E ; $DC60
        sec ; $DC62
        sbc     $8C ; $DC63
        sta     $90 ; $DC65
        cmp     $8E ; $DC67
        bne     LDC75 ; $DC69
        tsx ; $DC6B
        txa ; $DC6C
        sec ; $DC6D
        sbc     $90 ; $DC6E
        tax ; $DC70
        txs ; $DC71
        inx ; $DC72
        bne     LDC8B ; $DC73
LDC75:  tsx ; $DC75
        txa ; $DC76
        tay ; $DC77
        iny ; $DC78
        sec ; $DC79
        sbc     $90 ; $DC7A
        tax ; $DC7C
        txs ; $DC7D
        inx ; $DC7E
LDC7F:  lda     $0100,y ; $DC7F
        sta     $0100,x ; $DC82
        iny ; $DC85
        inx ; $DC86
        dec     $8C ; $DC87
        bne     LDC7F ; $DC89
LDC8B:  ldy     $90 ; $DC8B
        lda     #$00 ; $DC8D
LDC8F:  sta     $0100,x ; $DC8F
        inx ; $DC92
        dey ; $DC93
        bne     LDC8F ; $DC94
        jmp     advance_two ; $DC96

; ----------------------------------------------------------------------------
        pla ; $DC99
        sta     $8C ; $DC9A
        pla ; $DC9C
        sta     $8D ; $DC9D
        asl     $8C ; $DC9F
        rol     $8D ; $DCA1
        tsx ; $DCA3
        txa ; $DCA4
        clc ; $DCA5
        adc     $8C ; $DCA6
        tay ; $DCA8
        iny ; $DCA9
        lda     $0100,y ; $DCAA
        sta     $86 ; $DCAD
        iny ; $DCAF
        lda     $0100,y ; $DCB0
        sta     $87 ; $DCB3
        sty     $70 ; $DCB5
        and     #$FE ; $DCB7
        bne     LDCEC ; $DCB9
        lda     $86 ; $DCBB
        and     #$07 ; $DCBD
        sta     $7F ; $DCBF
        ror     $87 ; $DCC1
        lda     $86 ; $DCC3
        ror     a ; $DCC5
        ror     a ; $DCC6
        ror     a ; $DCC7
        and     #$3F ; $DCC8
        sta     $7E ; $DCCA
        cmp     $8C ; $DCCC
        bpl     LDCEC ; $DCCE
        tsx ; $DCD0
        inx ; $DCD1
        txa ; $DCD2
        adc     $7E ; $DCD3
        tax ; $DCD5
        lda     $0100,x ; $DCD6
        ldy     $7F ; $DCD9
        and     single_bit_masks,y ; $DCDB
        beq     LDCEC ; $DCDE
        ldx     $70 ; $DCE0
        txs ; $DCE2
        lda     #$00 ; $DCE3
        pha ; $DCE5
        lda     #$01 ; $DCE6
        pha ; $DCE8
        jmp     advance_one ; $DCE9

; ----------------------------------------------------------------------------
LDCEC:  ldx     $70 ; $DCEC
        txs ; $DCEE
        lda     #$00 ; $DCEF
        pha ; $DCF1
        pha ; $DCF2
        jmp     advance_one ; $DCF3

; ----------------------------------------------------------------------------
single_bit_masks:
        .repeat 8, bit
            .byte 1 << bit
        .endrepeat
; ----------------------------------------------------------------------------
        pla ; $DCFE
        sta     $8A ; $DCFF
        pla ; $DD01
        sta     $8B ; $DD02
        lda     $8B ; $DD04
        pha ; $DD06
        lda     $8A ; $DD07
        pha ; $DD09
        lda     $8B ; $DD0A
        pha ; $DD0C
        lda     $8A ; $DD0D
        pha ; $DD0F
        pla ; $DD10
        sta     $84 ; $DD11
        pla ; $DD13
        sta     $85 ; $DD14
        pla ; $DD16
        sta     $86 ; $DD17
        pla ; $DD19
        sta     $87 ; $DD1A
        lda     $87 ; $DD1C
        bpl     LDD23 ; $DD1E
        jmp     LDDCF ; $DD20

; ----------------------------------------------------------------------------
LDD23:  lda     $85 ; $DD23
        and     #$FE ; $DD25
        beq     LDD2C ; $DD27
        jmp     LDDCF ; $DD29

; ----------------------------------------------------------------------------
LDD2C:  sec ; $DD2C
        lda     $84 ; $DD2D
        sbc     $86 ; $DD2F
        sta     $88 ; $DD31
        lda     $85 ; $DD33
        sbc     $87 ; $DD35
        sta     $89 ; $DD37
        lda     $89 ; $DD39
        bpl     LDD40 ; $DD3B
        jmp     LDDC8 ; $DD3D

; ----------------------------------------------------------------------------
LDD40:  lda     $86 ; $DD40
        and     #$0F ; $DD42
        asl     a ; $DD44
        sta     $7F ; $DD45
        lda     $86 ; $DD47
        ldx     #$04 ; $DD49
LDD4B:  ror     $87 ; $DD4B
        ror     a ; $DD4D
        dex ; $DD4E
        bne     LDD4B ; $DD4F
        sta     $7E ; $DD51
        lda     $84 ; $DD53
        and     #$0F ; $DD55
        asl     a ; $DD57
        sta     $81 ; $DD58
        lda     $84 ; $DD5A
        ldx     #$04 ; $DD5C
LDD5E:  ror     $85 ; $DD5E
        ror     a ; $DD60
        dex ; $DD61
        bne     LDD5E ; $DD62
        sta     $80 ; $DD64
        sec ; $DD66
        lda     $80 ; $DD67
        sbc     $7E ; $DD69
        tax ; $DD6B
        ldy     $81 ; $DD6C
        lda     low_bit_masks+2,y ; $DD6E
        sta     $82 ; $DD71
        lda     low_bit_masks+3,y ; $DD73
        sta     $83 ; $DD76
        cpx     #$00 ; $DD78
        beq     LDD93 ; $DD7A
        lda     $83 ; $DD7C
        pha ; $DD7E
        lda     $82 ; $DD7F
        pha ; $DD81
        lda     #$FF ; $DD82
        sta     $82 ; $DD84
        sta     $83 ; $DD86
        bne     LDD90 ; $DD88
LDD8A:  lda     $83 ; $DD8A
        pha ; $DD8C
        lda     $82 ; $DD8D
        pha ; $DD8F
LDD90:  dex ; $DD90
        bne     LDD8A ; $DD91
LDD93:  lda     $82 ; $DD93
        ldy     $7F ; $DD95
        and     high_bit_masks,y ; $DD97
        sta     $82 ; $DD9A
        lda     $83 ; $DD9C
        and     high_bit_masks+1,y ; $DD9E
        sta     $83 ; $DDA1
        lda     $83 ; $DDA3
        pha ; $DDA5
        lda     $82 ; $DDA6
        pha ; $DDA8
        lda     #$00 ; $DDA9
        sta     $82 ; $DDAB
        sta     $83 ; $DDAD
        ldx     $7E ; $DDAF
        beq     LDDBC ; $DDB1
LDDB3:  lda     $83 ; $DDB3
        pha ; $DDB5
        lda     $82 ; $DDB6
        pha ; $DDB8
        dex ; $DDB9
        bne     LDDB3 ; $DDBA
LDDBC:  lda     #$00 ; $DDBC
        pha ; $DDBE
        clc ; $DDBF
        lda     $80 ; $DDC0
        adc     #$01 ; $DDC2
        pha ; $DDC4
        jmp     advance_one ; $DDC5

; ----------------------------------------------------------------------------
LDDC8:  lda     #$00 ; $DDC8
        pha ; $DDCA
        pha ; $DDCB
        jmp     advance_one ; $DDCC

; ----------------------------------------------------------------------------
LDDCF:  lda     #$00 ; $DDCF
        pha ; $DDD1
        pha ; $DDD2
        jmp     LD1B7 ; $DDD3

; ----------------------------------------------------------------------------
; Mask table for packed fields: the low N bits set, N=0..16.
low_bit_masks:
        .repeat 17, bits
            .word (1 << bits) - 1
        .endrepeat
; Complementary masks with 0..15 low bits cleared.
high_bit_masks:
        .repeat 16, bits
            .word ($FFFF << bits) & $FFFF
        .endrepeat
; ----------------------------------------------------------------------------
LDE18:  lda     #$06 ; $DE18
        bpl     LDE2E ; $DE1A
LDE1C:  lda     #$04 ; $DE1C
        bpl     LDE2E ; $DE1E
LDE20:  lda     #$02 ; $DE20
        bpl     LDE2E ; $DE22
LDE24:  lda     #$05 ; $DE24
        bpl     LDE2E ; $DE26
LDE28:  lda     #$03 ; $DE28
        bpl     LDE2E ; $DE2A
LDE2C:  lda     #$01 ; $DE2C
LDE2E:  sta     $76 ; $DE2E
        ldy     #$01 ; $DE30
        lda     ($58),y ; $DE32
        cmp     #$02 ; $DE34
        bne     LDE3B ; $DE36
        jmp     LDF20 ; $DE38

; ----------------------------------------------------------------------------
LDE3B:  cmp     #$04 ; $DE3B
        bne     LDE42 ; $DE3D
        jmp     LDEA8 ; $DE3F

; ----------------------------------------------------------------------------
LDE42:  cmp     #$06 ; $DE42
        bne     LDE49 ; $DE44
        jmp     LDF5A ; $DE46

; ----------------------------------------------------------------------------
LDE49:  cmp     #$08 ; $DE49
        bne     LDE50 ; $DE4B
        jmp     LE06B ; $DE4D

; ----------------------------------------------------------------------------
LDE50:  cmp     #$0A ; $DE50
        beq     LDE56 ; $DE52
        bne     LDE62 ; $DE54
LDE56:  ldy     #$02 ; $DE56
        jsr     read_big_word_offset ; $DE58
        lsr     $69 ; $DE5B
        ror     $68 ; $DE5D
        jmp     LDE67 ; $DE5F

; ----------------------------------------------------------------------------
LDE62:  ldy     #$02 ; $DE62
        jsr     read_big_word_offset ; $DE64
LDE67:  pla ; $DE67
        sta     $80 ; $DE68
        pla ; $DE6A
        sta     $81 ; $DE6B
        pla ; $DE6D
        sta     $7E ; $DE6E
        pla ; $DE70
        sta     $7F ; $DE71
        inc     $58 ; $DE73
        bne     LDE79 ; $DE75
        inc     $59 ; $DE77
LDE79:  ldy     #$00 ; $DE79
        ldx     $68 ; $DE7B
        jmp     LDE93 ; $DE7D

; ----------------------------------------------------------------------------
LDE80:  lda     ($7E),y ; $DE80
        cmp     ($80),y ; $DE82
        bne     LDE9C ; $DE84
        inc     $7E ; $DE86
        bne     LDE8C ; $DE88
        inc     $7F ; $DE8A
LDE8C:  inc     $80 ; $DE8C
        bne     LDE92 ; $DE8E
        inc     $81 ; $DE90
LDE92:  dex ; $DE92
LDE93:  bne     LDE80 ; $DE93
        dec     $69 ; $DE95
        bpl     LDE80 ; $DE97
        jmp     LDF06 ; $DE99

; ----------------------------------------------------------------------------
LDE9C:  bcs     LDEA1 ; $DE9C
        jmp     LDF0A ; $DE9E

; ----------------------------------------------------------------------------
LDEA1:  jmp     LDF02 ; $DEA1

; ----------------------------------------------------------------------------
; Addresses $0088/$008A used when comparison operands hold single characters.
string_scratch_pointers:
        .word   $0088,$008A ; $DEA4
; ----------------------------------------------------------------------------
LDEA8:  pla ; $DEA8
        sta     $80 ; $DEA9
        pla ; $DEAB
        sta     $81 ; $DEAC
        bne     LDEC2 ; $DEAE
        lda     $80 ; $DEB0
        sta     $89 ; $DEB2
        lda     #$01 ; $DEB4
        sta     $88 ; $DEB6
        lda     string_scratch_pointers ; $DEB8
        sta     $80 ; $DEBB
        lda     string_scratch_pointers+1 ; $DEBD
        sta     $81 ; $DEC0
LDEC2:  pla ; $DEC2
        sta     $7E ; $DEC3
        pla ; $DEC5
        sta     $7F ; $DEC6
        bne     LDEDC ; $DEC8
        lda     $7E ; $DECA
        sta     $8B ; $DECC
        lda     #$01 ; $DECE
        sta     $8A ; $DED0
        lda     string_scratch_pointers+2 ; $DED2
        sta     $7E ; $DED5
        lda     string_scratch_pointers+3 ; $DED7
        sta     $7F ; $DEDA
LDEDC:  ldy     #$00 ; $DEDC
        lda     ($7E),y ; $DEDE
        cmp     ($80),y ; $DEE0
        bcc     LDEE6 ; $DEE2
        lda     ($80),y ; $DEE4
LDEE6:  tax ; $DEE6
        inx ; $DEE7
LDEE8:  dex ; $DEE8
        beq     LDEF6 ; $DEE9
        iny ; $DEEB
        lda     ($7E),y ; $DEEC
        cmp     ($80),y ; $DEEE
        beq     LDEE8 ; $DEF0
        bcs     LDF02 ; $DEF2
        bcc     LDF0A ; $DEF4
LDEF6:  ldy     #$00 ; $DEF6
        lda     ($7E),y ; $DEF8
        cmp     ($80),y ; $DEFA
        bcc     LDF0A ; $DEFC
        beq     LDF06 ; $DEFE
        bne     LDF02 ; $DF00
LDF02:  lda     #$04 ; $DF02
        bpl     LDF0C ; $DF04
LDF06:  lda     #$01 ; $DF06
        bpl     LDF0C ; $DF08
LDF0A:  lda     #$02 ; $DF0A
LDF0C:  and     $76 ; $DF0C
        beq     LDF19 ; $DF0E
        lda     #$00 ; $DF10
        pha ; $DF12
        lda     #$01 ; $DF13
        pha ; $DF15
        jmp     advance_two ; $DF16

; ----------------------------------------------------------------------------
LDF19:  lda     #$00 ; $DF19
        pha ; $DF1B
        pha ; $DF1C
        jmp     advance_two ; $DF1D

; ----------------------------------------------------------------------------
LDF20:  ldx     #$07 ; $DF20
LDF22:  pla ; $DF22
        sta     $7E,x ; $DF23
        dex ; $DF25
        bpl     LDF22 ; $DF26
        ldy     #$01 ; $DF28
        lda     #$80 ; $DF2A
        eor     $82 ; $DF2C
        sta     $82 ; $DF2E
        bmi     LDF38 ; $DF30
        lda     $7E ; $DF32
        bpl     LDF38 ; $DF34
        ldy     #$F4 ; $DF36
LDF38:  lda     #$80 ; $DF38
        eor     $7E ; $DF3A
        sta     $7E ; $DF3C
        ldx     #$00 ; $DF3E
LDF40:  lda     $7E,x ; $DF40
        cmp     $82,x ; $DF42
        bne     LDF4D ; $DF44
        inx ; $DF46
        cpx     #$04 ; $DF47
        bne     LDF40 ; $DF49
        beq     LDF06 ; $DF4B
LDF4D:  tya ; $DF4D
        bmi     LDF55 ; $DF4E
        bcs     LDF02 ; $DF50
        jmp     LDF0A ; $DF52

; ----------------------------------------------------------------------------
LDF55:  bcc     LDF02 ; $DF55
        jmp     LDF0A ; $DF57

; ----------------------------------------------------------------------------
LDF5A:  pla ; $DF5A
        and     #$01 ; $DF5B
        sta     $7E ; $DF5D
        pla ; $DF5F
        pla ; $DF60
        and     #$01 ; $DF61
        tay ; $DF63
        pla ; $DF64
        tya ; $DF65
        cmp     $7E ; $DF66
        bcc     LDF0A ; $DF68
        beq     LDF06 ; $DF6A
        jmp     LDF02 ; $DF6C

; ----------------------------------------------------------------------------
LDF6F:  lda     #$02 ; $DF6F
        bpl     LDF81 ; $DF71
LDF73:  lda     #$04 ; $DF73
        bpl     LDF81 ; $DF75
LDF77:  lda     #$03 ; $DF77
        bpl     LDF81 ; $DF79
LDF7B:  lda     #$05 ; $DF7B
        bpl     LDF81 ; $DF7D
LDF7F:  lda     #$06 ; $DF7F
LDF81:  sta     $76 ; $DF81
        pla ; $DF83
        sta     $80 ; $DF84
        pla ; $DF86
        sta     $81 ; $DF87
        pla ; $DF89
        sta     $7E ; $DF8A
        pla ; $DF8C
        sta     $7F ; $DF8D
        eor     $81 ; $DF8F
        bmi     LDFA3 ; $DF91
        lda     $7F ; $DF93
        cmp     $81 ; $DF95
        bne     LDF9F ; $DF97
        lda     $7E ; $DF99
        cmp     $80 ; $DF9B
        beq     LDFCE ; $DF9D
LDF9F:  bcc     LDFD2 ; $DF9F
        bcs     LDFCA ; $DFA1
LDFA3:  lda     $7F ; $DFA3
        bmi     LDFD2 ; $DFA5
        bpl     LDFCA ; $DFA7
LDFA9:  pla ; $DFA9
        sta     $7E ; $DFAA
        pla ; $DFAC
        sta     $7F ; $DFAD
        pla ; $DFAF
        cmp     $7E ; $DFB0
        bne     LDFC2 ; $DFB2
        pla ; $DFB4
        cmp     $7F ; $DFB5
        bne     LDFD8 ; $DFB7
LDFB9:  lda     #$00 ; $DFB9
        pha ; $DFBB
        lda     #$01 ; $DFBC
        pha ; $DFBE
        jmp     advance_one ; $DFBF

; ----------------------------------------------------------------------------
LDFC2:  pla ; $DFC2
        lda     #$00 ; $DFC3
        pha ; $DFC5
        pha ; $DFC6
        jmp     advance_one ; $DFC7

; ----------------------------------------------------------------------------
LDFCA:  lda     #$04 ; $DFCA
        bpl     LDFD4 ; $DFCC
LDFCE:  lda     #$01 ; $DFCE
        bpl     LDFD4 ; $DFD0
LDFD2:  lda     #$02 ; $DFD2
LDFD4:  and     $76 ; $DFD4
        bne     LDFB9 ; $DFD6
LDFD8:  lda     #$00 ; $DFD8
        pha ; $DFDA
        pha ; $DFDB
        jmp     advance_one ; $DFDC

; ----------------------------------------------------------------------------
LDFDF:  pla ; $DFDF
        sta     L0098 ; $DFE0
        pla ; $DFE2
        sta     $99 ; $DFE3
        pla ; $DFE5
        asl     a ; $DFE6
        sta     $86 ; $DFE7
        sta     $88 ; $DFE9
        pla ; $DFEB
        tsx ; $DFEC
        inx ; $DFED
        stx     $80 ; $DFEE
        txa ; $DFF0
        clc ; $DFF1
        adc     $86 ; $DFF2
        tax ; $DFF4
        lda     $0100,x ; $DFF5
        asl     a ; $DFF8
        sta     $84 ; $DFF9
        cmp     $88 ; $DFFB
        bpl     LE001 ; $DFFD
        sta     $88 ; $DFFF
LE001:  sec ; $E001
        sbc     $86 ; $E002
        sta     $90 ; $E004
        inx ; $E006
        txa ; $E007
        clc ; $E008
        adc     $84 ; $E009
        sta     $8A ; $E00B
        inx ; $E00D
        stx     $7E ; $E00E
        inc     L0098 ; $E010
        bne     LE016 ; $E012
        inc     $99 ; $E014
LE016:  jmp     (L0098) ; $E016

; ----------------------------------------------------------------------------
LE019:  lda     #$00 ; $E019
        sec ; $E01B
        sbc     $90 ; $E01C
        tay ; $E01E
        jmp     LE024 ; $E01F

; ----------------------------------------------------------------------------
LE022:  ldy     $90 ; $E022
LE024:  cpy     #$00 ; $E024
        beq     LE034 ; $E026
        bmi     LE034 ; $E028
        clc ; $E02A
LE02B:  lda     $0100,x ; $E02B
        bne     LE035 ; $E02E
        inx ; $E030
        dey ; $E031
        bne     LE02B ; $E032
LE034:  sec ; $E034
LE035:  rts ; $E035

; ----------------------------------------------------------------------------
LE036:  pla ; $E036
        sta     L0096 ; $E037
        pla ; $E039
        sta     $97 ; $E03A
        jsr     LDFDF ; $E03C
        ldx     $7E ; $E03F
        ldy     $88 ; $E041
        beq     LE04F ; $E043
LE045:  pla ; $E045
        cmp     $0100,x ; $E046
        bne     LE061 ; $E049
        inx ; $E04B
        dey ; $E04C
        bne     LE045 ; $E04D
LE04F:  lda     $90 ; $E04F
        bmi     LE059 ; $E051
        jsr     LE022 ; $E053
        jmp     LE062 ; $E056

; ----------------------------------------------------------------------------
LE059:  tsx ; $E059
        inx ; $E05A
        jsr     LE019 ; $E05B
        jmp     LE062 ; $E05E

; ----------------------------------------------------------------------------
LE061:  clc ; $E061
LE062:  inc     L0096 ; $E062
        bne     LE068 ; $E064
        inc     $97 ; $E066
LE068:  jmp     (L0096) ; $E068

; ----------------------------------------------------------------------------
LE06B:  lda     $76 ; $E06B
        cmp     #$01 ; $E06D
        bne     LE074 ; $E06F
        jmp     LE081 ; $E071

; ----------------------------------------------------------------------------
LE074:  cmp     #$06 ; $E074
        bne     LE07B ; $E076
        jmp     LE087 ; $E078

; ----------------------------------------------------------------------------
LE07B:  cmp     #$03 ; $E07B
        bne     LE0AE ; $E07D
        beq     LE093 ; $E07F
LE081:  jsr     LE036 ; $E081
        jmp     LE0D0 ; $E084

; ----------------------------------------------------------------------------
LE087:  jsr     LE036 ; $E087
        bcs     LE08F ; $E08A
        sec ; $E08C
        bcs     LE090 ; $E08D
LE08F:  clc ; $E08F
LE090:  jmp     LE0D0 ; $E090

; ----------------------------------------------------------------------------
LE093:  jsr     LDFDF ; $E093
        ldx     $7E ; $E096
        ldy     $88 ; $E098
        beq     LE0A8 ; $E09A
LE09C:  pla ; $E09C
        eor     #$FF ; $E09D
        and     $0100,x ; $E09F
        bne     LE0CF ; $E0A2
        inx ; $E0A4
        dey ; $E0A5
        bne     LE09C ; $E0A6
LE0A8:  jsr     LE022 ; $E0A8
        jmp     LE0D0 ; $E0AB

; ----------------------------------------------------------------------------
LE0AE:  jsr     LDFDF ; $E0AE
        ldy     $7E ; $E0B1
        tsx ; $E0B3
        inx ; $E0B4
        lda     $88 ; $E0B5
        beq     LE0C9 ; $E0B7
LE0B9:  lda     $0100,y ; $E0B9
        eor     #$FF ; $E0BC
        and     $0100,x ; $E0BE
        bne     LE0CF ; $E0C1
        inx ; $E0C3
        iny ; $E0C4
        dec     $88 ; $E0C5
        bne     LE0B9 ; $E0C7
LE0C9:  jsr     LE019 ; $E0C9
        jmp     LE0D0 ; $E0CC

; ----------------------------------------------------------------------------
LE0CF:  clc ; $E0CF
LE0D0:  ldx     $8A ; $E0D0
        txs ; $E0D2
        ldy     #$00 ; $E0D3
        sty     $8F ; $E0D5
        bcc     LE0DA ; $E0D7
        iny ; $E0D9
LE0DA:  sty     $8E ; $E0DA
        lda     $8F ; $E0DC
        pha ; $E0DE
        lda     $8E ; $E0DF
        pha ; $E0E1
        jmp     advance_two ; $E0E2

; ----------------------------------------------------------------------------

; End of "PCODE_NATIVE" segment
; ----------------------------------------------------------------------------


.assert * - opcode_vectors = $10E5, error, "P-code native component size changed"
