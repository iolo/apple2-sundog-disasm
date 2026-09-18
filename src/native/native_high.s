; SYSTEM.APPLE final region: $F790-$FFFF.
; Includes a preserved, truncated duplicate of initializer code at $F7A1-$F7FF.
; Its origin is verified byte for byte; execution of that fragment is not claimed.
; Actual high-memory bank-switch/service stubs begin at $FE80.

        .setcpu "6502"

; ----------------------------------------------------------------------------
L0000           := $0000
L00D3           := $00D3
LBF16           := $BF16
LBF2F           := $BF2F
LD026           := $D026
LD029           := $D029
LD152           := $D152
LD683           := $D683
LD6A5           := $D6A5
LD7EF           := $D7EF
LD81E           := $D81E
LD848           := $D848
LD881           := $D881
LD885           := $D885
LD8B8           := $D8B8
LD902           := $D902
LD929           := $D929
LD94B           := $D94B
LDB67           := $DB67
LDC03           := $DC03
LDC10           := $DC10
LDC3C           := $DC3C
; ----------------------------------------------------------------------------

.segment        "NATIVE_HIGH"
native_high_start:

preserved_prefix:
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F790 00 00 00 00 00 00 00 00  ........
        .byte   $98,$27,$00,$00,$02,$00,$01,$01 ; F798 98 27 00 00 02 00 01 01  .'......
        .byte   $03                             ; F7A0 03                       .
; ----------------------------------------------------------------------------
; Exact duplicate of initializer bytes $F5A1-$F5FF (copied view $6B11-$6B6F).
preserved_initializer_fragment:
        lda     ($80),y                         ; F7A1 B1 80                    ..
        dec     $81                             ; F7A3 C6 81                    ..
        and     #$E0                            ; F7A5 29 E0                    ).
        cmp     #$A0                            ; F7A7 C9 A0                    ..
        beq     LF7C2                           ; F7A9 F0 17                    ..
        ldy     #$00                            ; F7AB A0 00                    ..
        sty     $F1FE                           ; F7AD 8C FE F1                 ...
LF7B0:  lda     $F23E,y                         ; F7B0 B9 3E F2                 .>.
        cmp     #$23                            ; F7B3 C9 23                    .#
LF7B5:  beq     LF7B5                           ; F7B5 F0 FE                    ..
        jsr     LFF03                           ; F7B7 20 03 FF                  ..
        inc     $F1FE                           ; F7BA EE FE F1                 ...
        ldy     $F1FE                           ; F7BD AC FE F1                 ...
        bpl     LF7B0                           ; F7C0 10 EE                    ..
LF7C2:  ldx     #$10                            ; F7C2 A2 10                    ..
        ldy     #$00                            ; F7C4 A0 00                    ..
        lda     #$04                            ; F7C6 A9 04                    ..
        sta     ($7E),y                         ; F7C8 91 7E                    .~
        tya                                     ; F7CA 98                       .
        iny                                     ; F7CB C8                       .
        sta     ($7E),y                         ; F7CC 91 7E                    .~
        lda     $7E                             ; F7CE A5 7E                    .~
        clc                                     ; F7D0 18                       .
        adc     #$02                            ; F7D1 69 02                    i.
        sta     $7E                             ; F7D3 85 7E                    .~
        bcc     LF7D9                           ; F7D5 90 02                    ..
        inc     $7F                             ; F7D7 E6 7F                    ..
LF7D9:  ldy     #$00                            ; F7D9 A0 00                    ..
        clc                                     ; F7DB 18                       .
        lda     ($80),y                         ; F7DC B1 80                    ..
        adc     $84                             ; F7DE 65 84                    e.
        sta     ($7E),y                         ; F7E0 91 7E                    .~
        iny                                     ; F7E2 C8                       .
        lda     ($80),y                         ; F7E3 B1 80                    ..
        adc     $85                             ; F7E5 65 85                    e.
        sta     ($7E),y                         ; F7E7 91 7E                    .~
        iny                                     ; F7E9 C8                       .
        lda     ($80),y                         ; F7EA B1 80                    ..
        sta     ($7E),y                         ; F7EC 91 7E                    .~
        iny                                     ; F7EE C8                       .
        lda     ($80),y                         ; F7EF B1 80                    ..
        sta     ($7E),y                         ; F7F1 91 7E                    .~
        lda     $7E                             ; F7F3 A5 7E                    .~
        clc                                     ; F7F5 18                       .
        adc     #$04                            ; F7F6 69 04                    i.
        sta     $7E                             ; F7F8 85 7E                    .~
        bcc     LF7FE                           ; F7FA 90 02                    ..
        inc     $7F                             ; F7FC E6 7F                    ..
LF7FE:  lda     $80                             ; F7FE A5 80                    ..
; The preceding LDA $80 is complete, but the duplicated routine ends here.
preserved_thisisit_records:
; Two original 16-byte records followed by eight spaces. Field meanings unresolved.
        .byte "THISISIT", $0B,0,1,0,0,0,0,0
        .byte "THISISIT", $06,0,1,0,0,0,0,0
        .byte "        "
preserved_zero_area:
        .res $0658, 0                  ; $F828-$FE7F

slot_jump_stubs:
        jmp     L0000                           ; FE80 4C 00 00                 L..

; ----------------------------------------------------------------------------
        jmp     L0000                           ; FE83 4C 00 00                 L..

; ----------------------------------------------------------------------------
        jmp     L0000                           ; FE86 4C 00 00                 L..

; ----------------------------------------------------------------------------
        jmp     L0000                           ; FE89 4C 00 00                 L..

; ----------------------------------------------------------------------------
        jmp     L0000                           ; FE8C 4C 00 00                 L..

; ----------------------------------------------------------------------------
        jmp     L0000                           ; FE8F 4C 00 00                 L..

; ----------------------------------------------------------------------------
        jmp     L0000                           ; FE92 4C 00 00                 L..

; ----------------------------------------------------------------------------
        jmp     L0000                           ; FE95 4C 00 00                 L..

; ----------------------------------------------------------------------------
        jmp     L0000                           ; FE98 4C 00 00                 L..

; ----------------------------------------------------------------------------
        jmp     L0000                           ; FE9B 4C 00 00                 L..

; ----------------------------------------------------------------------------
        jmp     L0000                           ; FE9E 4C 00 00                 L..

; ----------------------------------------------------------------------------
        jmp     L0000                           ; FEA1 4C 00 00                 L..

; ----------------------------------------------------------------------------
        jmp     L0000                           ; FEA4 4C 00 00                 L..

; ----------------------------------------------------------------------------
        jmp     L0000                           ; FEA7 4C 00 00                 L..

; ----------------------------------------------------------------------------
        jmp     L0000                           ; FEAA 4C 00 00                 L..

; ----------------------------------------------------------------------------
        jmp     L0000                           ; FEAD 4C 00 00                 L..

; ----------------------------------------------------------------------------
device_mapping_words:
        .word   $FFFF,$FFFF,$FFFF,$0000         ; FEB0 FF FF FF FF FF FF 00 00  ........
        .word   $0001,$FFFF,$FFFF,$FFFF         ; FEB8 01 00 FF FF FF FF FF FF  ........
        .word   $0004,$0005,$0002,$0003         ; FEC0 04 00 05 00 02 00 03 00  ........
        .word   $FFFF,$FFFF,$FFFF,$FFFF         ; FEC8 FF FF FF FF FF FF FF FF  ........
        .word   $FFFF,$FFFF,$FFFF,$FFFF         ; FED0 FF FF FF FF FF FF FF FF  ........
; ----------------------------------------------------------------------------
call_slot_stub:
        sta     $D2                             ; FED8 85 D2                    ..
        asl     a                               ; FEDA 0A                       .
        asl     a                               ; FEDB 0A                       .
        sbc     $D2                             ; FEDC E5 D2                    ..
        tay                                     ; FEDE A8                       .
        lda     #$FE                            ; FEDF A9 FE                    ..
        pha                                     ; FEE1 48                       H
        tya                                     ; FEE2 98                       .
        jmp     push_return_low                 ; FEE3 4C 4B FF                 LK.

; ----------------------------------------------------------------------------
bank1_input_hook:
        lda     $C08B                           ; FEE6 AD 8B C0                 ...
        jmp     (LBF16)                         ; FEE9 6C 16 BF                 l..

; ----------------------------------------------------------------------------
bank1_interrupt_hook:
        lda     $C08B                           ; FEEC AD 8B C0                 ...
        jmp     (LBF2F)                         ; FEEF 6C 2F BF                 l/.

; ----------------------------------------------------------------------------
enter_interpreter:
        lda     $C08B                           ; FEF2 AD 8B C0                 ...
        jmp     LD152                           ; FEF5 4C 52 D1                 LR.

; ----------------------------------------------------------------------------
reserved_before_services:
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FEF8 00 00 00 00 00 00 00 00  ........
; ----------------------------------------------------------------------------
service_entries:
        jsr     enter_bank2_service             ; FF00 20 9E FF                  ..
LFF03:  jsr     enter_bank2_service             ; FF03 20 9E FF                  ..
        jsr     enter_bank2_service             ; FF06 20 9E FF                  ..
        jsr     enter_bank2_service             ; FF09 20 9E FF                  ..
        jsr     enter_bank2_service             ; FF0C 20 9E FF                  ..
        jsr     enter_bank2_service             ; FF0F 20 9E FF                  ..
        jsr     enter_bank2_service             ; FF12 20 9E FF                  ..
        jsr     enter_bank2_service             ; FF15 20 9E FF                  ..
        jsr     enter_bank2_service             ; FF18 20 9E FF                  ..
        jsr     enter_bank2_service             ; FF1B 20 9E FF                  ..
        jsr     enter_bank2_service             ; FF1E 20 9E FF                  ..
        jsr     enter_bank2_service             ; FF21 20 9E FF                  ..
        jsr     enter_bank2_service             ; FF24 20 9E FF                  ..
        jsr     enter_bank2_service             ; FF27 20 9E FF                  ..
        jsr     enter_bank2_service             ; FF2A 20 9E FF                  ..
        jsr     enter_bank2_service             ; FF2D 20 9E FF                  ..
        jsr     enter_bank2_service             ; FF30 20 9E FF                  ..
        jsr     enter_bank2_service             ; FF33 20 9E FF                  ..
        jsr     enter_bank2_service             ; FF36 20 9E FF                  ..
        jsr     enter_bank2_service             ; FF39 20 9E FF                  ..
        jsr     enter_bank2_service             ; FF3C 20 9E FF                  ..
        jsr     enter_bank2_service             ; FF3F 20 9E FF                  ..
call_mapped_device:
        sta     $D2                             ; FF42 85 D2                    ..
        lda     slot_jump_stubs+47,y            ; FF44 B9 AF FE                 ...
        pha                                     ; FF47 48                       H
        lda     slot_jump_stubs+46,y            ; FF48 B9 AE FE                 ...
push_return_low:
        pha                                     ; FF4B 48                       H
        lda     $D2                             ; FF4C A5 D2                    ..
        rts                                     ; FF4E 60                       `

; ----------------------------------------------------------------------------
reserved_before_init_vectors:
        .byte   $00,$00,$00                     ; FF4F 00 00 00                 ...
; ----------------------------------------------------------------------------
device_init_vectors:
        .word   $DAA9,$D83D                     ; FF52 A9 DA 3D D8              ..=.
; ----------------------------------------------------------------------------
reserved_before_poll:
        .byte   $00,$00                         ; FF56 00 00                    ..
; ----------------------------------------------------------------------------
empty_service:
        rts                                     ; FF58 60                       `

; ----------------------------------------------------------------------------
service_targets:
        jmp     LD6A5                           ; FF59 4C A5 D6                 L..

; ----------------------------------------------------------------------------
        jmp     LD81E                           ; FF5C 4C 1E D8                 L..

; ----------------------------------------------------------------------------
        jmp     LD8B8                           ; FF5F 4C B8 D8                 L..

; ----------------------------------------------------------------------------
        jmp     LD7EF                           ; FF62 4C EF D7                 L..

; ----------------------------------------------------------------------------
        jmp     LD929                           ; FF65 4C 29 D9                 L).

; ----------------------------------------------------------------------------
        jmp     LD848                           ; FF68 4C 48 D8                 LH.

; ----------------------------------------------------------------------------
        jmp     LD026                           ; FF6B 4C 26 D0                 L&.

; ----------------------------------------------------------------------------
        jmp     LD029                           ; FF6E 4C 29 D0                 L).

; ----------------------------------------------------------------------------
        jmp     LD683                           ; FF71 4C 83 D6                 L..

; ----------------------------------------------------------------------------
        jmp     LD94B                           ; FF74 4C 4B D9                 LK.

; ----------------------------------------------------------------------------
        jmp     LD902                           ; FF77 4C 02 D9                 L..

; ----------------------------------------------------------------------------
        jmp     LD885                           ; FF7A 4C 85 D8                 L..

; ----------------------------------------------------------------------------
        jmp     empty_service                   ; FF7D 4C 58 FF                 LX.

; ----------------------------------------------------------------------------
        jmp     LD881                           ; FF80 4C 81 D8                 L..

; ----------------------------------------------------------------------------
        jmp     empty_service                   ; FF83 4C 58 FF                 LX.

; ----------------------------------------------------------------------------
        jmp     LDC10                           ; FF86 4C 10 DC                 L..

; ----------------------------------------------------------------------------
        jmp     LDC03                           ; FF89 4C 03 DC                 L..

; ----------------------------------------------------------------------------
        jmp     LDC3C                           ; FF8C 4C 3C DC                 L<.

; ----------------------------------------------------------------------------
        jmp     LDC03                           ; FF8F 4C 03 DC                 L..

; ----------------------------------------------------------------------------
        jmp     LD6A5                           ; FF92 4C A5 D6                 L..

; ----------------------------------------------------------------------------
        jmp     call_slot_stub                  ; FF95 4C D8 FE                 L..

; ----------------------------------------------------------------------------
        jmp     call_mapped_device              ; FF98 4C 42 FF                 LB.

; ----------------------------------------------------------------------------
trailing_service_padding:
        nop                                     ; FF9B EA                       .
        nop                                     ; FF9C EA                       .
        nop                                     ; FF9D EA                       .
enter_bank2_service:
        sta     $D2                             ; FF9E 85 D2                    ..
        pla                                     ; FFA0 68                       h
        clc                                     ; FFA1 18                       .
        adc     #$5A                            ; FFA2 69 5A                    iZ
        sta     L00D3                           ; FFA4 85 D3                    ..
        pla                                     ; FFA6 68                       h
        adc     #$00                            ; FFA7 69 00                    i.
        sta     $D4                             ; FFA9 85 D4                    ..
        pla                                     ; FFAB 68                       h
        sta     $BF1A                           ; FFAC 8D 1A BF                 ...
        pla                                     ; FFAF 68                       h
        sta     $BF1B                           ; FFB0 8D 1B BF                 ...
        lda     $C083                           ; FFB3 AD 83 C0                 ...
        lda     $D2                             ; FFB6 A5 D2                    ..
        jsr     jump_service_target             ; FFB8 20 CB FF                  ..
return_to_bank1:
        sta     $D2                             ; FFBB 85 D2                    ..
        lda     $BF1B                           ; FFBD AD 1B BF                 ...
        pha                                     ; FFC0 48                       H
        lda     $BF1A                           ; FFC1 AD 1A BF                 ...
        pha                                     ; FFC4 48                       H
        lda     $C08B                           ; FFC5 AD 8B C0                 ...
        lda     $D2                             ; FFC8 A5 D2                    ..
        rts                                     ; FFCA 60                       `

; ----------------------------------------------------------------------------
jump_service_target:
        jmp     (L00D3)                         ; FFCB 6C D3 00                 l..

; ----------------------------------------------------------------------------
adjust_console_columns:
        lda     $FB                             ; FFCE A5 FB                    ..
        cmp     #$14                            ; FFD0 C9 14                    ..
        bcs     LFFD8                           ; FFD2 B0 04                    ..
        lda     #$28                            ; FFD4 A9 28                    .(
        bne     LFFDA                           ; FFD6 D0 02                    ..
LFFD8:  lda     #$00                            ; FFD8 A9 00                    ..
LFFDA:  sec                                     ; FFDA 38                       8
        sbc     $FB                             ; FFDB E5 FB                    ..
        jmp     LDB67                           ; FFDD 4C 67 DB                 Lg.

; ----------------------------------------------------------------------------
reserved_before_reset:
        .byte   $00,$00                         ; FFE0 00 00                    ..
; ----------------------------------------------------------------------------
device_reset_vector:
        .word   $D851                           ; FFE2 51 D8                    Q.
; ----------------------------------------------------------------------------
key_translation_inputs:
        .byte   $0B,$0C,$0F,$5D,$5E,$40,$1D,$1E ; FFE4 0B 0C 0F 5D 5E 40 1D 1E  ...]^@..
        .byte   $00                             ; FFEC 00                       .
key_translation_outputs:
        .byte   $5B,$0A,$0B,$4D,$4E,$50,$5D,$5E ; FFED 5B 0A 0B 4D 4E 50 5D 5E  [..MNP]^
        .byte   $40                             ; FFF5 40                       @
preserved_keyboard_tail:
        .byte   $03,$00                         ; FFF6 03 00                    ..
; ----------------------------------------------------------------------------
boot_vector:
        .addr   enter_interpreter               ; FFF8 F2 FE                    ..
interrupt_vectors:
        .addr   bank1_interrupt_hook            ; FFFA EC FE                    ..
        .addr   bank1_interrupt_hook            ; FFFC EC FE                    ..
        .addr   bank1_interrupt_hook            ; FFFE EC FE                    ..

; End of "NATIVE_HIGH" segment
; ----------------------------------------------------------------------------

.assert * - native_high_start = $0870, error, "Native high region size changed"
