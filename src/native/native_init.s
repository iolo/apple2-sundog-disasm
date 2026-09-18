; SYSTEM.APPLE initializer, stored at $F290-$F78F and copied to $6800-$6CFF.
; Absolute calls/data accesses to the original image are intentional.
; See docs/native-init.md for aliases, copy/erase behavior, and unresolved payload.

INIT_STORAGE_DELTA = $F290 - $6800
        .setcpu "6502"

; ----------------------------------------------------------------------------
LD00E           := $D00E
dispatch        := $D293
LE0E5           := $E0E5
LE46D           := $E46D
LE4E9           := $E4E9
LF264           := $F264
checksum_original := checksum_page + INIT_STORAGE_DELTA
LFF03           := $FF03
LFF06           := $FF06
LFF12           := $FF12
LFF15           := $FF15
LFF36           := $FF36
LFF3C           := $FF3C
LFF52           := $FF52
LFF54           := $FF54
LFFF8           := $FFF8
; ----------------------------------------------------------------------------

.segment        "NATIVE_INIT"
native_init_start:

initialize_runtime:
        cld                                     ; 6800 D8                       .
        sei                                     ; 6801 78                       x
        lda     #$00                            ; 6802 A9 00                    ..
        sta     $BD                             ; 6804 85 BD                    ..
        sta     $BE                             ; 6806 85 BE                    ..
        tay                                     ; 6808 A8                       .
        tax                                     ; 6809 AA                       .
L680A:  sta     ($BD),y                         ; 680A 91 BD                    ..
        iny                                     ; 680C C8                       .
        bne     L680A                           ; 680D D0 FB                    ..
        inc     $BE                             ; 680F E6 BE                    ..
        inx                                     ; 6811 E8                       .
        cpx     #$20                            ; 6812 E0 20                    . 
        beq     L6820                           ; 6814 F0 0A                    ..
        nop                                     ; 6816 EA                       .
        nop                                     ; 6817 EA                       .
        bne     L680A                           ; 6818 D0 F0                    ..
        ldx     #$6D                            ; 681A A2 6D                    .m
        stx     $BE                             ; 681C 86 BE                    ..
        bne     L680A                           ; 681E D0 EA                    ..
L6820:  ldy     #$C7                            ; 6820 A0 C7                    ..
L6822:  sty     $C6                             ; 6822 84 C6                    ..
        jsr     checksum_original               ; 6824 20 9A F6                  ..
        sta     $D0                             ; 6827 85 D0                    ..
        stx     $D1                             ; 6829 86 D1                    ..
        jsr     checksum_original               ; 682B 20 9A F6                  ..
        cpx     #$00                            ; 682E E0 00                    ..
        beq     L6867                           ; 6830 F0 35                    .5
        cmp     $D0                             ; 6832 C5 D0                    ..
        bne     L6867                           ; 6834 D0 31                    .1
        cpx     $D1                             ; 6836 E4 D1                    ..
        bne     L6867                           ; 6838 D0 2D                    .-
        ldx     #$05                            ; 683A A2 05                    ..
L683C:  ldy     #$05                            ; 683C A0 05                    ..
        lda     ($C5),y                         ; 683E B1 C5                    ..
        cmp     L6C16,x                         ; 6840 DD 16 6C                 ..l
        bne     L684E                           ; 6843 D0 09                    ..
        ldy     #$07                            ; 6845 A0 07                    ..
        lda     ($C5),y                         ; 6847 B1 C5                    ..
        cmp     L6C1A,x                         ; 6849 DD 1A 6C                 ..l
        beq     L6853                           ; 684C F0 05                    ..
L684E:  dex                                     ; 684E CA                       .
        cpx     #$02                            ; 684F E0 02                    ..
        bcs     L683C                           ; 6851 B0 E9                    ..
L6853:  cpx     #$04                            ; 6853 E0 04                    ..
        bne     L6861                           ; 6855 D0 0A                    ..
        ldy     #$0B                            ; 6857 A0 0B                    ..
        lda     ($C5),y                         ; 6859 B1 C5                    ..
        cmp     #$01                            ; 685B C9 01                    ..
        bne     L6861                           ; 685D D0 02                    ..
        ldx     #$06                            ; 685F A2 06                    ..
L6861:  ldy     $C6                             ; 6861 A4 C6                    ..
        txa                                     ; 6863 8A                       .
        sta     $BE67,y                         ; 6864 99 67 BE                 .g.
L6867:  ldy     $C6                             ; 6867 A4 C6                    ..
        dey                                     ; 6869 88                       .
        cpy     #$C0                            ; 686A C0 C0                    ..
        bne     L6822                           ; 686C D0 B4                    ..
        ldx     $BF2A                           ; 686E AE 2A BF                 .*.
        stx     $BF0E                           ; 6871 8E 0E BF                 ...
        lda     #$00                            ; 6874 A9 00                    ..
        sta     $BF2A                           ; 6876 8D 2A BF                 .*.
        ldy     #$03                            ; 6879 A0 03                    ..
        bne     L6881                           ; 687B D0 04                    ..
copied_service_stub:
        jsr     LFF36                           ; 687D 20 36 FF                  6.
        rts                                     ; 6880 60                       `

; ----------------------------------------------------------------------------
L6881:  lda     a:copied_service_stub + INIT_STORAGE_DELTA,y                         ; 6881 B9 0D F3                 ...
        sta     $BF0A,y                         ; 6884 99 0A BF                 ...
        dey                                     ; 6887 88                       .
        bpl     L6881                           ; 6888 10 F7                    ..
        ldy     #$07                            ; 688A A0 07                    ..
L688C:  lda     a:initial_table_pointers + INIT_STORAGE_DELTA,y                         ; 688C B9 B0 F6                 ...
        sta     $E8,y                           ; 688F 99 E8 00                 ...
        dey                                     ; 6892 88                       .
        bpl     L688C                           ; 6893 10 F7                    ..
        lda     #$80                            ; 6895 A9 80                    ..
        sta     $E1                             ; 6897 85 E1                    ..
        lda     $C050                           ; 6899 AD 50 C0                 .P.
        lda     $C052                           ; 689C AD 52 C0                 .R.
        lda     $C054                           ; 689F AD 54 C0                 .T.
        lda     $C057                           ; 68A2 AD 57 C0                 .W.
        lda     $C010                           ; 68A5 AD 10 C0                 ...
        nop                                     ; 68A8 EA                       .
        nop                                     ; 68A9 EA                       .
        nop                                     ; 68AA EA                       .
        lda     $C083                           ; 68AB AD 83 C0                 ...
        lda     a:device_init_return_addresses + 1 + INIT_STORAGE_DELTA                           ; 68AE AD 5D F3                 .].
        pha                                     ; 68B1 48                       H
        lda     a:device_init_return_addresses + INIT_STORAGE_DELTA                           ; 68B2 AD 5C F3                 .\.
        pha                                     ; 68B5 48                       H
        jmp     (LFF52)                         ; 68B6 6C 52 FF                 lR.

; ----------------------------------------------------------------------------
after_first_device_init:
        lda     a:device_init_return_addresses + 3 + INIT_STORAGE_DELTA                           ; 68B9 AD 5F F3                 ._.
        pha                                     ; 68BC 48                       H
        lda     a:device_init_return_addresses + 2 + INIT_STORAGE_DELTA                           ; 68BD AD 5E F3                 .^.
        pha                                     ; 68C0 48                       H
        jmp     (LFF54)                         ; 68C1 6C 54 FF                 lT.

; ----------------------------------------------------------------------------
after_second_device_init:
        jsr     LD00E                           ; 68C4 20 0E D0                  ..
        lda     $C08B                           ; 68C7 AD 8B C0                 ...
        bne     L68D0                           ; 68CA D0 04                    ..
device_init_return_addresses:
        .word   after_first_device_init - 1, after_second_device_init - 1                     ; 68CC B8 68 C3 68              .h.h
; ----------------------------------------------------------------------------
L68D0:  lda     $C081                           ; 68D0 AD 81 C0                 ...
        lda     $C081                           ; 68D3 AD 81 C0                 ...
        lda     $FBB3                           ; 68D6 AD B3 FB                 ...
        ldy     $FBC0                           ; 68D9 AC C0 FB                 ...
        ldx     $C08B                           ; 68DC AE 8B C0                 ...
        ldx     $C08B                           ; 68DF AE 8B C0                 ...
        ldx     #$80                            ; 68E2 A2 80                    ..
        cmp     #$06                            ; 68E4 C9 06                    ..
        beq     L68F2                           ; 68E6 F0 0A                    ..
        lda     $C061                           ; 68E8 AD 61 C0                 .a.
        bmi     L6918                           ; 68EB 30 2B                    0+
        stx     $BF11                           ; 68ED 8E 11 BF                 ...
        bpl     L6918                           ; 68F0 10 26                    .&
L68F2:  stx     $BF11                           ; 68F2 8E 11 BF                 ...
        tya                                     ; 68F5 98                       .
        bne     L68FC                           ; 68F6 D0 04                    ..
        lda     #$C3                            ; 68F8 A9 C3                    ..
        bmi     L6915                           ; 68FA 30 19                    0.
L68FC:  txa                                     ; 68FC 8A                       .
        ldx     $C017                           ; 68FD AE 17 C0                 ...
        bmi     L6915                           ; 6900 30 13                    0.
        lda     #$83                            ; 6902 A9 83                    ..
        sta     $C009                           ; 6904 8D 09 C0                 ...
        sta     $F800                           ; 6907 8D 00 F8                 ...
        lda     #$81                            ; 690A A9 81                    ..
        sta     $FC00                           ; 690C 8D 00 FC                 ...
        lda     $F800                           ; 690F AD 00 F8                 ...
        sta     $C008                           ; 6912 8D 08 C0                 ...
L6915:  sta     $BF31                           ; 6915 8D 31 BF                 .1.
L6918:  lda     #$02                            ; 6918 A9 02                    ..
        sta     $FA                             ; 691A 85 FA                    ..
        ldx     #$FF                            ; 691C A2 FF                    ..
        txs                                     ; 691E 9A                       .
        cld                                     ; 691F D8                       .
        lda     $EE82                           ; 6920 AD 82 EE                 ...
        sta     $BF1D                           ; 6923 8D 1D BF                 ...
        lda     $EE83                           ; 6926 AD 83 EE                 ...
        sta     $BF1E                           ; 6929 8D 1E BF                 ...
        lda     $F1F9                           ; 692C AD F9 F1                 ...
        sta     $BF2F                           ; 692F 8D 2F BF                 ./.
        lda     $F1FA                           ; 6932 AD FA F1                 ...
        sta     $BF30                           ; 6935 8D 30 BF                 .0.
        lda     $F1F7                           ; 6938 AD F7 F1                 ...
        sta     $BF1F                           ; 693B 8D 1F BF                 ...
        lda     $F1F8                           ; 693E AD F8 F1                 ...
        sta     $BF20                           ; 6941 8D 20 BF                 . .
        lda     #$01                            ; 6944 A9 01                    ..
        sta     $BF22                           ; 6946 8D 22 BF                 .".
        lda     #$03                            ; 6949 A9 03                    ..
        sta     $BF21                           ; 694B 8D 21 BF                 .!.
        lda     $F260                           ; 694E AD 60 F2                 .`.
        sta     $E6                             ; 6951 85 E6                    ..
        lda     $F261                           ; 6953 AD 61 F2                 .a.
        sta     $E7                             ; 6956 85 E7                    ..
        lda     $F262                           ; 6958 AD 62 F2                 .b.
        sta     $E4                             ; 695B 85 E4                    ..
        lda     $F263                           ; 695D AD 63 F2                 .c.
        sta     $E5                             ; 6960 85 E5                    ..
        ldy     #$29                            ; 6962 A0 29                    .)
L6964:  lda     a:initialization_payload + INIT_STORAGE_DELTA,y                         ; 6964 B9 18 F4                 ...
        sta     $BF56,y                         ; 6967 99 56 BF                 .V.
        dey                                     ; 696A 88                       .
        bpl     L6964                           ; 696B 10 F7                    ..
        lda     #$56                            ; 696D A9 56                    .V
        sta     $BF23                           ; 696F 8D 23 BF                 .#.
        lda     #$BF                            ; 6972 A9 BF                    ..
        sta     $BF24                           ; 6974 8D 24 BF                 .$.
        lda     $FEB7                           ; 6977 AD B7 FE                 ...
        beq     L69B2                           ; 697A F0 36                    .6
        ldx     #$02                            ; 697C A2 02                    ..
        lda     #$04                            ; 697E A9 04                    ..
        ldy     #$08                            ; 6980 A0 08                    ..
        jsr     LFF3C                           ; 6982 20 3C FF                  <.
        clc                                     ; 6985 18                       .
        bcc     find_system_directory           ; 6986 90 2F                    ./
initialization_payload:
; Copied verbatim from the original image to $BF56-$BF7F; format unresolved.
; This is not claimed as decoded native code or a fully classified asset.
        .byte   $C0,$D2,$5C,$D5,$7A,$D3,$0F,$D2 ; 6988 C0 D2 5C D5 7A D3 0F D2  ..\.z...
        .byte   $20,$B3,$B3,$A5,$46,$85,$4C,$B3 ; 6990 20 B3 B3 A5 46 85 4C B3   ...F.L.
        .byte   $B3,$4C,$B3,$B3,$0E,$49,$AB,$45 ; 6998 B3 4C B3 B3 0E 49 AB 45  .L...I.E
        .byte   $CD,$48,$4A,$68,$2A,$C9,$04,$2A ; 69A0 CD 48 4A 68 2A C9 04 2A  .HJh*..*
        .byte   $85,$46,$60,$A4,$46,$24,$00,$4C ; 69A8 85 46 60 A4 46 24 00 4C  .F`.F$.L
        .byte   $10,$D3                         ; 69B0 10 D3                    ..
; ----------------------------------------------------------------------------
L69B2:  lda     #$04                            ; 69B2 A9 04                    ..
        jsr     LFF15                           ; 69B4 20 15 FF                  ..
find_system_directory:
        lda     #$00                            ; 69B7 A9 00                    ..
        tax                                     ; 69B9 AA                       .
L69BA:  sta     $BDDE,x                         ; 69BA 9D DE BD                 ...
        inx                                     ; 69BD E8                       .
        bne     L69BA                           ; 69BE D0 FA                    ..
L69C0:  sta     $BEDE,x                         ; 69C0 9D DE BE                 ...
        inx                                     ; 69C3 E8                       .
        cpx     #$20                            ; 69C4 E0 20                    . 
        bne     L69C0                           ; 69C6 D0 F8                    ..
        lda     #$00                            ; 69C8 A9 00                    ..
        pha                                     ; 69CA 48                       H
        pha                                     ; 69CB 48                       H
        pha                                     ; 69CC 48                       H
        lda     $FEB7                           ; 69CD AD B7 FE                 ...
        beq     L69D6                           ; 69D0 F0 04                    ..
        lda     #$04                            ; 69D2 A9 04                    ..
        bpl     L69D9                           ; 69D4 10 03                    ..
L69D6:  lda     $FEB6                           ; 69D6 AD B6 FE                 ...
L69D9:  pha                                     ; 69D9 48                       H
        lda     #$60                            ; 69DA A9 60                    .`
        pha                                     ; 69DC 48                       H
        sta     $8B                             ; 69DD 85 8B                    ..
        lda     #$00                            ; 69DF A9 00                    ..
        pha                                     ; 69E1 48                       H
        sta     $8A                             ; 69E2 85 8A                    ..
        lda     #$02                            ; 69E4 A9 02                    ..
        pha                                     ; 69E6 48                       H
        lda     #$00                            ; 69E7 A9 00                    ..
        pha                                     ; 69E9 48                       H
        pha                                     ; 69EA 48                       H
        lda     #$4F                            ; 69EB A9 4F                    .O
        pha                                     ; 69ED 48                       H
        lda     $FEB7                           ; 69EE AD B7 FE                 ...
        beq     L69FF                           ; 69F1 F0 0C                    ..
        ldx     #$00                            ; 69F3 A2 00                    ..
        lda     #$04                            ; 69F5 A9 04                    ..
        ldy     #$08                            ; 69F7 A0 08                    ..
        jsr     LFF3C                           ; 69F9 20 3C FF                  <.
        clc                                     ; 69FC 18                       .
        bcc     directory_read_result           ; 69FD 90 03                    ..
L69FF:  jsr     LFF12                           ; 69FF 20 12 FF                  ..
directory_read_result:
        lda     $6019                           ; 6A02 AD 19 60                 ..`
        and     #$08                            ; 6A05 29 08                    ).
        bne     L6A13                           ; 6A07 D0 0A                    ..
        bit     $BF31                           ; 6A09 2C 31 BF                 ,1.
        bvc     L6A17                           ; 6A0C 50 09                    P.
        lda     $C060                           ; 6A0E AD 60 C0                 .`.
        bpl     L6A17                           ; 6A11 10 04                    ..
L6A13:  lda     #$00                            ; 6A13 A9 00                    ..
        beq     L6A30                           ; 6A15 F0 19                    ..
L6A17:  lda     $BF0E                           ; 6A17 AD 0E BF                 ...
        sta     $BF2A                           ; 6A1A 8D 2A BF                 .*.
        ldy     #$30                            ; 6A1D A0 30                    .0
        ldx     $C083                           ; 6A1F AE 83 C0                 ...
        jsr     LF264                           ; 6A22 20 64 F2                  d.
        lda     $C08B                           ; 6A25 AD 8B C0                 ...
        lda     #$00                            ; 6A28 A9 00                    ..
        cpx     #$00                            ; 6A2A E0 00                    ..
        bne     L6A30                           ; 6A2C D0 02                    ..
        lda     #$04                            ; 6A2E A9 04                    ..
L6A30:  sta     $BF0E                           ; 6A30 8D 0E BF                 ...
        ldx     #$4E                            ; 6A33 A2 4E                    .N
        clc                                     ; 6A35 18                       .
        lda     $8A                             ; 6A36 A5 8A                    ..
        adc     #$06                            ; 6A38 69 06                    i.
        sta     $8A                             ; 6A3A 85 8A                    ..
        bcc     L6A4B                           ; 6A3C 90 0D                    ..
        inc     $8B                             ; 6A3E E6 8B                    ..
L6A40:  clc                                     ; 6A40 18                       .
        lda     $8A                             ; 6A41 A5 8A                    ..
        adc     #$1A                            ; 6A43 69 1A                    i.
        sta     $8A                             ; 6A45 85 8A                    ..
        bcc     L6A4B                           ; 6A47 90 02                    ..
        inc     $8B                             ; 6A49 E6 8B                    ..
L6A4B:  dex                                     ; 6A4B CA                       .
        bne     L6A97                           ; 6A4C D0 49                    .I
        txa                                     ; 6A4E 8A                       .
        sta     $A1                             ; 6A4F 85 A1                    ..
        sta     $A2                             ; 6A51 85 A2                    ..
        lda     $EE83                           ; 6A53 AD 83 EE                 ...
        pha                                     ; 6A56 48                       H
        lda     $EE82                           ; 6A57 AD 82 EE                 ...
        pha                                     ; 6A5A 48                       H
        lda     $F1F8                           ; 6A5B AD F8 F1                 ...
        pha                                     ; 6A5E 48                       H
        lda     $F1F7                           ; 6A5F AD F7 F1                 ...
        pha                                     ; 6A62 48                       H
        jsr     LFF06                           ; 6A63 20 06 FF                  ..
        ldy     #$00                            ; 6A66 A0 00                    ..
        sty     $F1FE                           ; 6A68 8C FE F1                 ...
L6A6B:  lda     $F1FF,y                         ; 6A6B B9 FF F1                 ...
        cmp     #$23                            ; 6A6E C9 23                    .#
        bne     L6A8B                           ; 6A70 D0 19                    ..
        lda     $F1FD                           ; 6A72 AD FD F1                 ...
        bne     L6A7A                           ; 6A75 D0 03                    ..
        inc     $F1FD                           ; 6A77 EE FD F1                 ...
L6A7A:  lda     $C000                           ; 6A7A AD 00 C0                 ...
        bpl     L6A7A                           ; 6A7D 10 FB                    ..
        sta     $C010                           ; 6A7F 8D 10 C0                 ...
        and     #$7F                            ; 6A82 29 7F                    ).
        cmp     #$0D                            ; 6A84 C9 0D                    ..
        bne     L6A7A                           ; 6A86 D0 F2                    ..
        jmp     (LFFF8)                         ; 6A88 6C F8 FF                 l..

; ----------------------------------------------------------------------------
L6A8B:  jsr     LFF03                           ; 6A8B 20 03 FF                  ..
        inc     $F1FE                           ; 6A8E EE FE F1                 ...
        ldy     $F1FE                           ; 6A91 AC FE F1                 ...
        clc                                     ; 6A94 18                       .
        bcc     L6A6B                           ; 6A95 90 D4                    ..
L6A97:  ldy     $F23E                           ; 6A97 AC 3E F2                 .>.
L6A9A:  lda     ($8A),y                         ; 6A9A B1 8A                    ..
        cmp     $F23E,y                         ; 6A9C D9 3E F2                 .>.
        bne     L6A40                           ; 6A9F D0 9F                    ..
        dey                                     ; 6AA1 88                       .
        bpl     L6A9A                           ; 6AA2 10 F6                    ..
        lda     $8A                             ; 6AA4 A5 8A                    ..
        sec                                     ; 6AA6 38                       8
        sbc     #$06                            ; 6AA7 E9 06                    ..
        sta     $8A                             ; 6AA9 85 8A                    ..
        bcs     L6AAF                           ; 6AAB B0 02                    ..
        dec     $8B                             ; 6AAD C6 8B                    ..
L6AAF:  ldy     #$00                            ; 6AAF A0 00                    ..
        lda     ($8A),y                         ; 6AB1 B1 8A                    ..
        sta     $84                             ; 6AB3 85 84                    ..
        iny                                     ; 6AB5 C8                       .
        lda     ($8A),y                         ; 6AB6 B1 8A                    ..
        sta     $85                             ; 6AB8 85 85                    ..
        lda     #$00                            ; 6ABA A9 00                    ..
        pha                                     ; 6ABC 48                       H
        pha                                     ; 6ABD 48                       H
        pha                                     ; 6ABE 48                       H
        lda     $FEB7                           ; 6ABF AD B7 FE                 ...
        beq     L6AC8                           ; 6AC2 F0 04                    ..
        lda     #$04                            ; 6AC4 A9 04                    ..
        bpl     L6ACB                           ; 6AC6 10 03                    ..
L6AC8:  lda     $FEB6                           ; 6AC8 AD B6 FE                 ...
L6ACB:  pha                                     ; 6ACB 48                       H
        lda     #$60                            ; 6ACC A9 60                    .`
        pha                                     ; 6ACE 48                       H
        lda     #$00                            ; 6ACF A9 00                    ..
        pha                                     ; 6AD1 48                       H
        lda     #$02                            ; 6AD2 A9 02                    ..
        pha                                     ; 6AD4 48                       H
        lda     #$00                            ; 6AD5 A9 00                    ..
        pha                                     ; 6AD7 48                       H
        lda     $85                             ; 6AD8 A5 85                    ..
        pha                                     ; 6ADA 48                       H
        lda     $84                             ; 6ADB A5 84                    ..
        pha                                     ; 6ADD 48                       H
        lda     $FEB7                           ; 6ADE AD B7 FE                 ...
        beq     L6AEF                           ; 6AE1 F0 0C                    ..
        ldx     #$00                            ; 6AE3 A2 00                    ..
        lda     #$04                            ; 6AE5 A9 04                    ..
        ldy     #$08                            ; 6AE7 A0 08                    ..
        jsr     LFF3C                           ; 6AE9 20 3C FF                  <.
        clc                                     ; 6AEC 18                       .
        bcc     L6AF2                           ; 6AED 90 03                    ..
L6AEF:  jsr     LFF12                           ; 6AEF 20 12 FF                  ..
L6AF2:  lda     #$00                            ; 6AF2 A9 00                    ..
        tax                                     ; 6AF4 AA                       .
L6AF5:  sta     $BD1E,x                         ; 6AF5 9D 1E BD                 ...
        inx                                     ; 6AF8 E8                       .
        cpx     #$40                            ; 6AF9 E0 40                    .@
        bne     L6AF5                           ; 6AFB D0 F8                    ..
        lda     $F1F5                           ; 6AFD AD F5 F1                 ...
        sta     $7E                             ; 6B00 85 7E                    .~
        lda     $F1F6                           ; 6B02 AD F6 F1                 ...
        sta     $7F                             ; 6B05 85 7F                    ..
        lda     #$61                            ; 6B07 A9 61                    .a
        sta     $81                             ; 6B09 85 81                    ..
        lda     #$00                            ; 6B0B A9 00                    ..
        sta     $80                             ; 6B0D 85 80                    ..
        ldy     #$03                            ; 6B0F A0 03                    ..
        lda     ($80),y                         ; 6B11 B1 80                    ..
        dec     $81                             ; 6B13 C6 81                    ..
system_version_check:
        and     #$E0                            ; 6B15 29 E0                    ).
        cmp     #$A0                            ; 6B17 C9 A0                    ..
        beq     system_header_read_result       ; 6B19 F0 17                    ..
        ldy     #$00                            ; 6B1B A0 00                    ..
        sty     $F1FE                           ; 6B1D 8C FE F1                 ...
L6B20:  lda     $F23E,y                         ; 6B20 B9 3E F2                 .>.
        cmp     #$23                            ; 6B23 C9 23                    .#
L6B25:  beq     L6B25                           ; 6B25 F0 FE                    ..
        jsr     LFF03                           ; 6B27 20 03 FF                  ..
        inc     $F1FE                           ; 6B2A EE FE F1                 ...
        ldy     $F1FE                           ; 6B2D AC FE F1                 ...
        bpl     L6B20                           ; 6B30 10 EE                    ..
system_header_read_result:
        ldx     #$10                            ; 6B32 A2 10                    ..
L6B34:  ldy     #$00                            ; 6B34 A0 00                    ..
        lda     #$04                            ; 6B36 A9 04                    ..
        sta     ($7E),y                         ; 6B38 91 7E                    .~
        tya                                     ; 6B3A 98                       .
        iny                                     ; 6B3B C8                       .
        sta     ($7E),y                         ; 6B3C 91 7E                    .~
        lda     $7E                             ; 6B3E A5 7E                    .~
        clc                                     ; 6B40 18                       .
        adc     #$02                            ; 6B41 69 02                    i.
        sta     $7E                             ; 6B43 85 7E                    .~
        bcc     L6B49                           ; 6B45 90 02                    ..
        inc     $7F                             ; 6B47 E6 7F                    ..
L6B49:  ldy     #$00                            ; 6B49 A0 00                    ..
        clc                                     ; 6B4B 18                       .
        lda     ($80),y                         ; 6B4C B1 80                    ..
        adc     $84                             ; 6B4E 65 84                    e.
        sta     ($7E),y                         ; 6B50 91 7E                    .~
        iny                                     ; 6B52 C8                       .
        lda     ($80),y                         ; 6B53 B1 80                    ..
        adc     $85                             ; 6B55 65 85                    e.
        sta     ($7E),y                         ; 6B57 91 7E                    .~
        iny                                     ; 6B59 C8                       .
        lda     ($80),y                         ; 6B5A B1 80                    ..
        sta     ($7E),y                         ; 6B5C 91 7E                    .~
        iny                                     ; 6B5E C8                       .
        lda     ($80),y                         ; 6B5F B1 80                    ..
        sta     ($7E),y                         ; 6B61 91 7E                    .~
        lda     $7E                             ; 6B63 A5 7E                    .~
        clc                                     ; 6B65 18                       .
        adc     #$04                            ; 6B66 69 04                    i.
        sta     $7E                             ; 6B68 85 7E                    .~
        bcc     L6B6E                           ; 6B6A 90 02                    ..
        inc     $7F                             ; 6B6C E6 7F                    ..
L6B6E:  lda     $80                             ; 6B6E A5 80                    ..
        clc                                     ; 6B70 18                       .
        adc     #$04                            ; 6B71 69 04                    i.
        sta     $80                             ; 6B73 85 80                    ..
        bcc     L6B79                           ; 6B75 90 02                    ..
        inc     $81                             ; 6B77 E6 81                    ..
L6B79:  dex                                     ; 6B79 CA                       .
        bne     L6B34                           ; 6B7A D0 B8                    ..
        lda     $F1F3                           ; 6B7C AD F3 F1                 ...
        sta     $5C                             ; 6B7F 85 5C                    .\
        sta     $52                             ; 6B81 85 52                    .R
        sta     $BDF2                           ; 6B83 8D F2 BD                 ...
        lda     $F1F4                           ; 6B86 AD F4 F1                 ...
        sta     $5D                             ; 6B89 85 5D                    .]
        sta     $53                             ; 6B8B 85 53                    .S
        sta     $BDF3                           ; 6B8D 8D F3 BD                 ...
        lda     #$0C                            ; 6B90 A9 0C                    ..
        sta     $5B                             ; 6B92 85 5B                    .[
        lda     #$0F                            ; 6B94 A9 0F                    ..
        jsr     LE46D                           ; 6B96 20 6D E4                  m.
        lda     $5C                             ; 6B99 A5 5C                    .\
        sta     $76                             ; 6B9B 85 76                    .v
        lda     $5D                             ; 6B9D A5 5D                    .]
        sta     $77                             ; 6B9F 85 77                    .w
        lda     #$FE                            ; 6BA1 A9 FE                    ..
        sta     $5D                             ; 6BA3 85 5D                    .]
        lda     #$7C                            ; 6BA5 A9 7C                    .|
        sta     $5C                             ; 6BA7 85 5C                    .\
        lda     #$00                            ; 6BA9 A9 00                    ..
        jsr     LE4E9                           ; 6BAB 20 E9 E4                  ..
        lda     $76                             ; 6BAE A5 76                    .v
        sta     $5C                             ; 6BB0 85 5C                    .\
        lda     $77                             ; 6BB2 A5 77                    .w
        sta     $5D                             ; 6BB4 85 5D                    .]
        lda     #$01                            ; 6BB6 A9 01                    ..
        sta     $82                             ; 6BB8 85 82                    ..
        jsr     LE0E5                           ; 6BBA 20 E5 E0                  ..
        ldy     #$00                            ; 6BBD A0 00                    ..
        lda     $52                             ; 6BBF A5 52                    .R
        sta     $50                             ; 6BC1 85 50                    .P
        sta     ($52),y                         ; 6BC3 91 52                    .R
        ldy     #$02                            ; 6BC5 A0 02                    ..
        sta     ($52),y                         ; 6BC7 91 52                    .R
        lda     $53                             ; 6BC9 A5 53                    .S
        sta     $51                             ; 6BCB 85 51                    .Q
        dey                                     ; 6BCD 88                       .
        sta     ($52),y                         ; 6BCE 91 52                    .R
        ldy     #$03                            ; 6BD0 A0 03                    ..
        sta     ($52),y                         ; 6BD2 91 52                    .R
        ldy     #$0C                            ; 6BD4 A0 0C                    ..
        lda     $F1F7                           ; 6BD6 AD F7 F1                 ...
        sta     ($52),y                         ; 6BD9 91 52                    .R
        iny                                     ; 6BDB C8                       .
        lda     $F1F8                           ; 6BDC AD F8 F1                 ...
        sta     ($52),y                         ; 6BDF 91 52                    .R
        lda     $BF0E                           ; 6BE1 AD 0E BF                 ...
        and     #$04                            ; 6BE4 29 04                    ).
        beq     L6BEE                           ; 6BE6 F0 06                    ..
        lda     #$08                            ; 6BE8 A9 08                    ..
        sta     $5B                             ; 6BEA 85 5B                    .[
        bpl     L6BF2                           ; 6BEC 10 04                    ..
L6BEE:  lda     #$0C                            ; 6BEE A9 0C                    ..
        sta     $5B                             ; 6BF0 85 5B                    .[
L6BF2:  lda     #$04                            ; 6BF2 A9 04                    ..
        sta     $5A                             ; 6BF4 85 5A                    .Z
        ldx     #$01                            ; 6BF6 A2 01                    ..
        stx     $71                             ; 6BF8 86 71                    .q
        dex                                     ; 6BFA CA                       .
        txa                                     ; 6BFB 8A                       .
L6BFC:  sta     $A0,x                           ; 6BFC 95 A0                    ..
        inx                                     ; 6BFE E8                       .
        cpx     #$0D                            ; 6BFF E0 0D                    ..
        bne     L6BFC                           ; 6C01 D0 F9                    ..
        lda     #$04                            ; 6C03 A9 04                    ..
        sta     $BDE2                           ; 6C05 8D E2 BD                 ...
        bne     erase_initializer               ; 6C08 D0 1E                    ..
checksum_page:
        lda     #$00                            ; 6C0A A9 00                    ..
        tax                                     ; 6C0C AA                       .
        tay                                     ; 6C0D A8                       .
L6C0E:  clc                                     ; 6C0E 18                       .
        adc     ($C5),y                         ; 6C0F 71 C5                    q.
        bcc     L6C14                           ; 6C11 90 01                    ..
        inx                                     ; 6C13 E8                       .
L6C14:  iny                                     ; 6C14 C8                       .
L6C16           := * + 1
        bne     L6C0E                           ; 6C15 D0 F7                    ..
        rts                                     ; 6C17 60                       `

; ----------------------------------------------------------------------------
slot_signature_bytes:
        .byte   $03,$18                         ; 6C18 03 18                    ..
L6C1A:  .byte   $38,$48,$3C,$38,$18,$48         ; 6C1A 38 48 3C 38 18 48        8H<8.H
; ----------------------------------------------------------------------------
initial_table_pointers:
        .word   $FE80,$FEB0,$FF00,$FF5C         ; 6C20 80 FE B0 FE 00 FF 5C FF  ......\.
; ----------------------------------------------------------------------------
erase_initializer:
        ldx     #$60                            ; 6C28 A2 60                    .`
        stx     $BE                             ; 6C2A 86 BE                    ..
        lda     #$00                            ; 6C2C A9 00                    ..
        sta     $BD                             ; 6C2E 85 BD                    ..
        tay                                     ; 6C30 A8                       .
L6C31:  cpy     #$31                            ; 6C31 C0 31                    .1
        bne     L6C39                           ; 6C33 D0 04                    ..
        cpx     #$6C                            ; 6C35 E0 6C                    .l
        beq     start_pcode                     ; 6C37 F0 0A                    ..
L6C39:  sta     ($BD),y                         ; 6C39 91 BD                    ..
        iny                                     ; 6C3B C8                       .
        bne     L6C31                           ; 6C3C D0 F3                    ..
        inc     $BE                             ; 6C3E E6 BE                    ..
        inx                                     ; 6C40 E8                       .
        bne     L6C31                           ; 6C41 D0 EE                    ..
start_pcode:
        jmp     dispatch                        ; 6C43 4C 93 D2                 L..

; ----------------------------------------------------------------------------
copyright_notice:
        .byte "COPYRIGHT 1979,1980,1981,1983  APPLE COMPUTER, INC."
zero_tail:
        .res $87, 0
.assert * - native_init_start = $0500, error, "Initializer size changed"
