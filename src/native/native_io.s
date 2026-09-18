; SYSTEM.APPLE native disk/device/console services: language-card bank 2.
; Disk 1 Pascal blocks 219-226, loaded at $D000-$DFFF.
; Preserve polling-loop instruction timing and original self-modifying operands.
; Code/data boundaries and overlaps: native_io.info and docs/native-io.md.

        .setcpu "6502"

; ----------------------------------------------------------------------------
L00BF           := $00BF
L00F6           := $00F6
LC800           := $C800
LC84D           := $C84D
LC9AA           := $C9AA
LFEE6           := $FEE6
LFFBB           := $FFBB
LFFCE           := $FFCE
LFFD4           := $FFD4
LFFD8           := $FFD8
; ----------------------------------------------------------------------------

.segment        "NATIVE_IO"
native_io_start:

poll_during_disk_io:
        php                                     ; D000 08                       .
        pha                                     ; D001 48                       H
        lda     $FF                             ; D002 A5 FF                    ..
        pha                                     ; D004 48                       H
        plp                                     ; D005 28                       (
        nop                                     ; D006 EA                       .
        sei                                     ; D007 78                       x
        jsr     poll_devices                    ; D008 20 A5 D6                  ..
        pla                                     ; D00B 68                       h
        plp                                     ; D00C 28                       (
        rts                                     ; D00D 60                       `

; ----------------------------------------------------------------------------
initialize_disk_state:
        lda     $C0EA                           ; D00E AD EA C0                 ...
        ldy     #$00                            ; D011 A0 00                    ..
        sty     $03A3                           ; D013 8C A3 03                 ...
        sty     $047E                           ; D016 8C 7E 04                 .~.
        sty     $04FE                           ; D019 8C FE 04                 ...
        iny                                     ; D01C C8                       .
        sty     $03B0                           ; D01D 8C B0 03                 ...
        lda     #$60                            ; D020 A9 60                    .`
        sta     $03AF                           ; D022 8D AF 03                 ...
        rts                                     ; D025 60                       `

; ----------------------------------------------------------------------------
write_blocks:
        ldy     #$02                            ; D026 A0 02                    ..
; BIT absolute consumes the following LDY #1 when entered from write_blocks.
        .byte   $2C                             ; D028 2C                       ,
; ----------------------------------------------------------------------------
read_blocks:
        ldy     #$01                            ; D029 A0 01                    ..
        sty     $03AC                           ; D02B 8C AC 03                 ...
        pla                                     ; D02E 68                       h
        sta     $C0                             ; D02F 85 C0                    ..
        pla                                     ; D031 68                       h
        sta     $C1                             ; D032 85 C1                    ..
        pla                                     ; D034 68                       h
        sta     $BE                             ; D035 85 BE                    ..
        asl     a                               ; D037 0A                       .
        and     #$0F                            ; D038 29 0F                    ).
        sta     $BD                             ; D03A 85 BD                    ..
        pla                                     ; D03C 68                       h
        lsr     a                               ; D03D 4A                       J
        sta     $C2                             ; D03E 85 C2                    ..
        lda     $BE                             ; D040 A5 BE                    ..
        ror     a                               ; D042 6A                       j
        lsr     a                               ; D043 4A                       J
        lsr     a                               ; D044 4A                       J
        sta     $03A4                           ; D045 8D A4 03                 ...
        pla                                     ; D048 68                       h
        sta     $BE                             ; D049 85 BE                    ..
        cmp     #$01                            ; D04B C9 01                    ..
        pla                                     ; D04D 68                       h
        adc     #$00                            ; D04E 69 00                    i.
        dey                                     ; D050 88                       .
        beq     LD056                           ; D051 F0 03                    ..
        dey                                     ; D053 88                       .
        sty     $BE                             ; D054 84 BE                    ..
LD056:  sta     L00BF                           ; D056 85 BF                    ..
        pla                                     ; D058 68                       h
        sta     $03A8                           ; D059 8D A8 03                 ...
        sta     $C4                             ; D05C 85 C4                    ..
        pla                                     ; D05E 68                       h
        sta     $03A9                           ; D05F 8D A9 03                 ...
        pla                                     ; D062 68                       h
        lsr     a                               ; D063 4A                       J
        tay                                     ; D064 A8                       .
        lda     #$01                            ; D065 A9 01                    ..
        adc     #$00                            ; D067 69 00                    i.
        sta     $03A2                           ; D069 8D A2 03                 ...
        lda     disk_slot_offsets,y             ; D06C B9 80 D6                 ...
        sta     $03A1                           ; D06F 8D A1 03                 ...
        pla                                     ; D072 68                       h
        tax                                     ; D073 AA                       .
        pla                                     ; D074 68                       h
        pla                                     ; D075 68                       h
        txa                                     ; D076 8A                       .
        ldx     #$08                            ; D077 A2 08                    ..
        ora     $C2                             ; D079 05 C2                    ..
        bne     LD0E5                           ; D07B D0 68                    .h
        tya                                     ; D07D 98                       .
        jsr     LD684                           ; D07E 20 84 D6                  ..
        bne     LD0E5                           ; D081 D0 62                    .b
        lda     L00BF                           ; D083 A5 BF                    ..
        beq     LD0E3                           ; D085 F0 5C                    .\
LD087:  ldy     #$0F                            ; D087 A0 0F                    ..
        lda     #$00                            ; D089 A9 00                    ..
LD08B:  sta     $D0,y                           ; D08B 99 D0 00                 ...
        dey                                     ; D08E 88                       .
        bpl     LD08B                           ; D08F 10 FA                    ..
        lda     #$10                            ; D091 A9 10                    ..
        sec                                     ; D093 38                       8
        sbc     $BD                             ; D094 E5 BD                    ..
        cmp     L00BF                           ; D096 C5 BF                    ..
        bcc     LD09C                           ; D098 90 02                    ..
        lda     L00BF                           ; D09A A5 BF                    ..
LD09C:  sta     $C6                             ; D09C 85 C6                    ..
        sta     $C3                             ; D09E 85 C3                    ..
        php                                     ; D0A0 08                       .
        pla                                     ; D0A1 68                       h
        sta     $FF                             ; D0A2 85 FF                    ..
        sei                                     ; D0A4 78                       x
        lda     #$01                            ; D0A5 A9 01                    ..
        sta     $FD                             ; D0A7 85 FD                    ..
        jsr     transfer_track                  ; D0A9 20 EC D0                  ..
        lda     #$00                            ; D0AC A9 00                    ..
        sta     $FD                             ; D0AE 85 FD                    ..
        rol     $27                             ; D0B0 26 27                    &'
        lda     $FF                             ; D0B2 A5 FF                    ..
        pha                                     ; D0B4 48                       H
        plp                                     ; D0B5 28                       (
        ror     $27                             ; D0B6 66 27                    f'
        nop                                     ; D0B8 EA                       .
        ldx     $03AD                           ; D0B9 AE AD 03                 ...
        bcs     LD0E5                           ; D0BC B0 27                    .'
        lda     #$00                            ; D0BE A9 00                    ..
        sta     $BD                             ; D0C0 85 BD                    ..
        inc     $03A4                           ; D0C2 EE A4 03                 ...
        lda     $03A9                           ; D0C5 AD A9 03                 ...
        adc     $C6                             ; D0C8 65 C6                    e.
        sta     $03A9                           ; D0CA 8D A9 03                 ...
        lda     L00BF                           ; D0CD A5 BF                    ..
        sec                                     ; D0CF 38                       8
        sbc     $C6                             ; D0D0 E5 C6                    ..
        sta     L00BF                           ; D0D2 85 BF                    ..
        bne     LD087                           ; D0D4 D0 B1                    ..
        ldy     $BE                             ; D0D6 A4 BE                    ..
        beq     LD0E3                           ; D0D8 F0 09                    ..
LD0DA:  dey                                     ; D0DA 88                       .
        lda     $0200,y                         ; D0DB B9 00 02                 ...
        sta     ($C4),y                         ; D0DE 91 C4                    ..
        tya                                     ; D0E0 98                       .
        bne     LD0DA                           ; D0E1 D0 F7                    ..
LD0E3:  ldx     #$00                            ; D0E3 A2 00                    ..
LD0E5:  lda     $C1                             ; D0E5 A5 C1                    ..
        pha                                     ; D0E7 48                       H
        lda     $C0                             ; D0E8 A5 C0                    ..
        pha                                     ; D0EA 48                       H
        rts                                     ; D0EB 60                       `

; ----------------------------------------------------------------------------
transfer_track:
        ldy     #$02                            ; D0EC A0 02                    ..
        sty     seek_retries                    ; D0EE 8C 94 DC                 ...
        ldy     #$0A                            ; D0F1 A0 0A                    ..
        sty     address_retries                 ; D0F3 8C 92 DC                 ...
        ldx     $03A1                           ; D0F6 AE A1 03                 ...
        cpx     $03AF                           ; D0F9 EC AF 03                 ...
        beq     LD10F                           ; D0FC F0 11                    ..
        ldx     $03AF                           ; D0FE AE AF 03                 ...
LD101:  jsr     poll_during_disk_io             ; D101 20 00 D0                  ..
        jsr     wait_disk_change                ; D104 20 82 D3                  ..
        bne     LD101                           ; D107 D0 F8                    ..
        ldx     $03A1                           ; D109 AE A1 03                 ...
        stx     $03AF                           ; D10C 8E AF 03                 ...
LD10F:  jsr     wait_disk_change                ; D10F 20 82 D3                  ..
        php                                     ; D112 08                       .
        lda     $C089,x                         ; D113 BD 89 C0                 ...
        lda     $03A2                           ; D116 AD A2 03                 ...
        cmp     $03B0                           ; D119 CD B0 03                 ...
        beq     LD125                           ; D11C F0 07                    ..
        sta     $03B0                           ; D11E 8D B0 03                 ...
        plp                                     ; D121 28                       (
        ldy     #$00                            ; D122 A0 00                    ..
        php                                     ; D124 08                       .
LD125:  and     #$01                            ; D125 29 01                    ).
        eor     #$01                            ; D127 49 01                    I.
        ora     $03A1                           ; D129 0D A1 03                 ...
        tay                                     ; D12C A8                       .
        cmp     $C08A,y                         ; D12D D9 8A C0                 ...
        lsr     a                               ; D130 4A                       J
        php                                     ; D131 08                       .
        lsr     a                               ; D132 4A                       J
        lsr     a                               ; D133 4A                       J
        plp                                     ; D134 28                       (
        ror     a                               ; D135 6A                       j
        sta     $C7                             ; D136 85 C7                    ..
        lda     #$EF                            ; D138 A9 EF                    ..
        sta     $46                             ; D13A 85 46                    .F
        lda     #$D8                            ; D13C A9 D8                    ..
        sta     $47                             ; D13E 85 47                    .G
        plp                                     ; D140 28                       (
        php                                     ; D141 08                       .
        bne     LD14F                           ; D142 D0 0B                    ..
        ldy     #$08                            ; D144 A0 08                    ..
LD146:  jsr     LD6A2                           ; D146 20 A2 D6                  ..
        dey                                     ; D149 88                       .
        bne     LD146                           ; D14A D0 FA                    ..
        ldx     $03A1                           ; D14C AE A1 03                 ...
LD14F:  lda     $03A4                           ; D14F AD A4 03                 ...
        jsr     LD26B                           ; D152 20 6B D2                  k.
        plp                                     ; D155 28                       (
        bne     LD178                           ; D156 D0 20                    . 
        lda     $03AC                           ; D158 AD AC 03                 ...
        cmp     #$02                            ; D15B C9 02                    ..
        bne     LD16F                           ; D15D D0 10                    ..
LD15F:  ldy     #$12                            ; D15F A0 12                    ..
LD161:  dey                                     ; D161 88                       .
        bne     LD161                           ; D162 D0 FD                    ..
        inc     $46                             ; D164 E6 46                    .F
        bne     LD15F                           ; D166 D0 F7                    ..
        jsr     poll_during_disk_io             ; D168 20 00 D0                  ..
        inc     $47                             ; D16B E6 47                    .G
        bne     LD15F                           ; D16D D0 F0                    ..
LD16F:  jsr     wait_disk_change                ; D16F 20 82 D3                  ..
        bne     LD178                           ; D172 D0 04                    ..
        lda     #$09                            ; D174 A9 09                    ..
        bne     LD1CF                           ; D176 D0 57                    .W
LD178:  lda     $03AC                           ; D178 AD AC 03                 ...
        ror     a                               ; D17B 6A                       j
        php                                     ; D17C 08                       .
        lda     #$FF                            ; D17D A9 FF                    ..
        sta     $03A5                           ; D17F 8D A5 03                 ...
LD182:  ldy     #$80                            ; D182 A0 80                    ..
        sty     sector_retries                  ; D184 8C 93 DC                 ...
LD187:  dec     sector_retries                  ; D187 CE 93 DC                 ...
        bmi     LD1AC                           ; D18A 30 20                    0 
        jsr     poll_during_disk_io             ; D18C 20 00 D0                  ..
        ldx     $03A1                           ; D18F AE A1 03                 ...
        jsr     read_address_field              ; D192 20 24 D3                  $.
        bcs     LD187                           ; D195 B0 F0                    ..
        lda     $CC                             ; D197 A5 CC                    ..
        cmp     current_halftrack               ; D199 CD 90 DC                 ...
        beq     LD1D2                           ; D19C F0 34                    .4
        ldy     $C7                             ; D19E A4 C7                    ..
        asl     a                               ; D1A0 0A                       .
        sta     $0478,y                         ; D1A1 99 78 04                 .x.
        lda     current_halftrack               ; D1A4 AD 90 DC                 ...
        dec     address_retries                 ; D1A7 CE 92 DC                 ...
        bne     LD1C7                           ; D1AA D0 1B                    ..
LD1AC:  dec     seek_retries                    ; D1AC CE 94 DC                 ...
        beq     LD1CC                           ; D1AF F0 1B                    ..
        lda     current_halftrack               ; D1B1 AD 90 DC                 ...
        pha                                     ; D1B4 48                       H
        lda     #$0A                            ; D1B5 A9 0A                    ..
        sta     address_retries                 ; D1B7 8D 92 DC                 ...
        lda     #$60                            ; D1BA A9 60                    .`
        ldy     $C7                             ; D1BC A4 C7                    ..
        sta     $0478,y                         ; D1BE 99 78 04                 .x.
        lda     #$00                            ; D1C1 A9 00                    ..
        jsr     LD26B                           ; D1C3 20 6B D2                  k.
        pla                                     ; D1C6 68                       h
LD1C7:  jsr     LD26B                           ; D1C7 20 6B D2                  k.
        bpl     LD182                           ; D1CA 10 B6                    ..
LD1CC:  lda     #$40                            ; D1CC A9 40                    .@
LD1CE:  plp                                     ; D1CE 28                       (
LD1CF:  jmp     disk_error_exit                 ; D1CF 4C 59 D2                 LY.

; ----------------------------------------------------------------------------
LD1D2:  lda     $03A3                           ; D1D2 AD A3 03                 ...
        pha                                     ; D1D5 48                       H
        lda     $CD                             ; D1D6 A5 CD                    ..
        sta     $03AE                           ; D1D8 8D AE 03                 ...
        pla                                     ; D1DB 68                       h
        beq     LD1E6                           ; D1DC F0 08                    ..
        cmp     $CD                             ; D1DE C5 CD                    ..
        beq     LD1E6                           ; D1E0 F0 04                    ..
        lda     #$20                            ; D1E2 A9 20                    . 
        bne     LD1CE                           ; D1E4 D0 E8                    ..
LD1E6:  plp                                     ; D1E6 28                       (
        php                                     ; D1E7 08                       .
        bcs     LD1FD                           ; D1E8 B0 13                    ..
        lda     $CB                             ; D1EA A5 CB                    ..
        cmp     $03A5                           ; D1EC CD A5 03                 ...
        beq     LD261                           ; D1EF F0 70                    .p
        clc                                     ; D1F1 18                       .
        adc     #$01                            ; D1F2 69 01                    i.
        and     #$0F                            ; D1F4 29 0F                    ).
        cmp     $03A5                           ; D1F6 CD A5 03                 ...
        beq     LD187                           ; D1F9 F0 8C                    ..
        sta     $CB                             ; D1FB 85 CB                    ..
LD1FD:  ldy     $CB                             ; D1FD A4 CB                    ..
        lda     $D0,y                           ; D1FF B9 D0 00                 ...
        beq     LD207                           ; D202 F0 03                    ..
        jmp     LD187                           ; D204 4C 87 D1                 L..

; ----------------------------------------------------------------------------
LD207:  tya                                     ; D207 98                       .
        lsr     a                               ; D208 4A                       J
        bcc     LD20D                           ; D209 90 02                    ..
        ora     #$08                            ; D20B 09 08                    ..
LD20D:  sec                                     ; D20D 38                       8
        sbc     $BD                             ; D20E E5 BD                    ..
        bcc     LD240                           ; D210 90 2E                    ..
        tay                                     ; D212 A8                       .
        clc                                     ; D213 18                       .
        adc     $03A9                           ; D214 6D A9 03                 m..
        iny                                     ; D217 C8                       .
        cpy     L00BF                           ; D218 C4 BF                    ..
        bcc     LD22A                           ; D21A 90 0E                    ..
        bne     LD240                           ; D21C D0 22                    ."
        ldy     $BE                             ; D21E A4 BE                    ..
        beq     LD22A                           ; D220 F0 08                    ..
        sta     $C5                             ; D222 85 C5                    ..
        ldy     #$00                            ; D224 A0 00                    ..
        lda     #$02                            ; D226 A9 02                    ..
        bcs     LD22D                           ; D228 B0 03                    ..
LD22A:  ldy     $03A8                           ; D22A AC A8 03                 ...
LD22D:  sty     $3E                             ; D22D 84 3E                    .>
        sta     $3F                             ; D22F 85 3F                    .?
        plp                                     ; D231 28                       (
        php                                     ; D232 08                       .
        bcs     LD243                           ; D233 B0 0E                    ..
        jsr     pack_six_and_two                ; D235 20 58 D6                  X.
        ldx     $03A1                           ; D238 AE A1 03                 ...
        lda     $CB                             ; D23B A5 CB                    ..
        sta     $03A5                           ; D23D 8D A5 03                 ...
LD240:  jmp     LD187                           ; D240 4C 87 D1                 L..

; ----------------------------------------------------------------------------
LD243:  jsr     read_data_field                 ; D243 20 02 D5                  ..
        bcs     LD240                           ; D246 B0 F8                    ..
LD248:  ldy     $CB                             ; D248 A4 CB                    ..
        lda     #$FF                            ; D24A A9 FF                    ..
        sta     $D0,y                           ; D24C 99 D0 00                 ...
        sta     $03A5                           ; D24F 8D A5 03                 ...
        dec     $C3                             ; D252 C6 C3                    ..
        bne     LD240                           ; D254 D0 EA                    ..
        plp                                     ; D256 28                       (
        clc                                     ; D257 18                       .
; BIT zp skips SEC, preserving C=0 on the successful fall-through path.
        .byte   $24                             ; D258 24                       $
; ----------------------------------------------------------------------------
disk_error_exit:
        sec                                     ; D259 38                       8
        sta     $03AD                           ; D25A 8D AD 03                 ...
        lda     $C088,x                         ; D25D BD 88 C0                 ...
        rts                                     ; D260 60                       `

; ----------------------------------------------------------------------------
LD261:  jsr     write_data_field                ; D261 20 8C D2                  ..
        bcc     LD248                           ; D264 90 E2                    ..
        pla                                     ; D266 68                       h
        lda     #$10                            ; D267 A9 10                    ..
        bcs     disk_error_exit                 ; D269 B0 EE                    ..
LD26B:  asl     a                               ; D26B 0A                       .
        pha                                     ; D26C 48                       H
        lda     $C080,x                         ; D26D BD 80 C0                 ...
        lda     $C082,x                         ; D270 BD 82 C0                 ...
        lda     $C084,x                         ; D273 BD 84 C0                 ...
        lda     $C086,x                         ; D276 BD 86 C0                 ...
        ldy     $C7                             ; D279 A4 C7                    ..
        lda     $0478,y                         ; D27B B9 78 04                 .x.
        sta     current_halftrack               ; D27E 8D 90 DC                 ...
        pla                                     ; D281 68                       h
        sta     $0478,y                         ; D282 99 78 04                 .x.
        jsr     seek_halftrack                  ; D285 20 DA D5                  ..
        lsr     current_halftrack               ; D288 4E 90 DC                 N..
        rts                                     ; D28B 60                       `

; ----------------------------------------------------------------------------
write_data_field:
        sec                                     ; D28C 38                       8
        stx     $CE                             ; D28D 86 CE                    ..
        stx     write_slot_offset               ; D28F 8E 8F DC                 ...
        lda     $C08D,x                         ; D292 BD 8D C0                 ...
        lda     $C08E,x                         ; D295 BD 8E C0                 ...
        bmi     LD316                           ; D298 30 7C                    0|
        lda     $0300                           ; D29A AD 00 03                 ...
        sta     $CF                             ; D29D 85 CF                    ..
        lda     #$FF                            ; D29F A9 FF                    ..
        sta     $C08F,x                         ; D2A1 9D 8F C0                 ...
        ora     $C08C,x                         ; D2A4 1D 8C C0                 ...
        pha                                     ; D2A7 48                       H
        pla                                     ; D2A8 68                       h
        nop                                     ; D2A9 EA                       .
        ldy     #$04                            ; D2AA A0 04                    ..
LD2AC:  pha                                     ; D2AC 48                       H
        pla                                     ; D2AD 68                       h
        jsr     LD31B                           ; D2AE 20 1B D3                  ..
        dey                                     ; D2B1 88                       .
        bne     LD2AC                           ; D2B2 D0 F8                    ..
        lda     #$D5                            ; D2B4 A9 D5                    ..
        jsr     write_disk_byte                 ; D2B6 20 1A D3                  ..
        lda     #$AA                            ; D2B9 A9 AA                    ..
        jsr     write_disk_byte                 ; D2BB 20 1A D3                  ..
        lda     #$AD                            ; D2BE A9 AD                    ..
        jsr     write_disk_byte                 ; D2C0 20 1A D3                  ..
        tya                                     ; D2C3 98                       .
        ldy     #$56                            ; D2C4 A0 56                    .V
        bne     LD2CB                           ; D2C6 D0 03                    ..
LD2C8:  lda     $0300,y                         ; D2C8 B9 00 03                 ...
LD2CB:  eor     $02FF,y                         ; D2CB 59 FF 02                 Y..
        tax                                     ; D2CE AA                       .
        lda     gcr_conversion_table+3,x        ; D2CF BD 03 D4                 ...
        ldx     $CE                             ; D2D2 A6 CE                    ..
        sta     $C08D,x                         ; D2D4 9D 8D C0                 ...
        lda     $C08C,x                         ; D2D7 BD 8C C0                 ...
        dey                                     ; D2DA 88                       .
        bne     LD2C8                           ; D2DB D0 EB                    ..
        lda     $CF                             ; D2DD A5 CF                    ..
        nop                                     ; D2DF EA                       .
LD2E0:  eor     $0200,y                         ; D2E0 59 00 02                 Y..
        tax                                     ; D2E3 AA                       .
        lda     gcr_conversion_table+3,x        ; D2E4 BD 03 D4                 ...
        ldx     write_slot_offset               ; D2E7 AE 8F DC                 ...
        sta     $C08D,x                         ; D2EA 9D 8D C0                 ...
        lda     $C08C,x                         ; D2ED BD 8C C0                 ...
        lda     $0200,y                         ; D2F0 B9 00 02                 ...
        iny                                     ; D2F3 C8                       .
        bne     LD2E0                           ; D2F4 D0 EA                    ..
        tax                                     ; D2F6 AA                       .
        lda     gcr_conversion_table+3,x        ; D2F7 BD 03 D4                 ...
        ldx     $CE                             ; D2FA A6 CE                    ..
        jsr     LD31D                           ; D2FC 20 1D D3                  ..
; Indexed decode base, not a callable entry: valid disk symbols select $D396-$D3FF.
gcr_decode_page := * + 1
        lda     #$DE                            ; D2FF A9 DE                    ..
        jsr     write_disk_byte                 ; D301 20 1A D3                  ..
        lda     #$AA                            ; D304 A9 AA                    ..
        jsr     write_disk_byte                 ; D306 20 1A D3                  ..
        lda     #$EB                            ; D309 A9 EB                    ..
        jsr     write_disk_byte                 ; D30B 20 1A D3                  ..
        lda     #$FF                            ; D30E A9 FF                    ..
        jsr     write_disk_byte                 ; D310 20 1A D3                  ..
        lda     $C08E,x                         ; D313 BD 8E C0                 ...
LD316:  lda     $C08C,x                         ; D316 BD 8C C0                 ...
        rts                                     ; D319 60                       `

; ----------------------------------------------------------------------------
write_disk_byte:
        clc                                     ; D31A 18                       .
LD31B:  pha                                     ; D31B 48                       H
        pla                                     ; D31C 68                       h
LD31D:  sta     $C08D,x                         ; D31D 9D 8D C0                 ...
        ora     $C08C,x                         ; D320 1D 8C C0                 ...
        rts                                     ; D323 60                       `

; ----------------------------------------------------------------------------
read_address_field:
        ldy     #$FC                            ; D324 A0 FC                    ..
        sty     $CF                             ; D326 84 CF                    ..
LD328:  iny                                     ; D328 C8                       .
        bne     LD32F                           ; D329 D0 04                    ..
        inc     $CF                             ; D32B E6 CF                    ..
        beq     LD380                           ; D32D F0 51                    .Q
LD32F:  lda     $C08C,x                         ; D32F BD 8C C0                 ...
        bpl     LD32F                           ; D332 10 FB                    ..
LD334:  cmp     #$D5                            ; D334 C9 D5                    ..
        bne     LD328                           ; D336 D0 F0                    ..
        nop                                     ; D338 EA                       .
LD339:  lda     $C08C,x                         ; D339 BD 8C C0                 ...
        bpl     LD339                           ; D33C 10 FB                    ..
        cmp     #$AA                            ; D33E C9 AA                    ..
        bne     LD334                           ; D340 D0 F2                    ..
        ldy     #$03                            ; D342 A0 03                    ..
LD344:  lda     $C08C,x                         ; D344 BD 8C C0                 ...
        bpl     LD344                           ; D347 10 FB                    ..
        cmp     #$96                            ; D349 C9 96                    ..
        bne     LD334                           ; D34B D0 E7                    ..
        lda     #$00                            ; D34D A9 00                    ..
LD34F:  sta     $CE                             ; D34F 85 CE                    ..
LD351:  lda     $C08C,x                         ; D351 BD 8C C0                 ...
        bpl     LD351                           ; D354 10 FB                    ..
        rol     a                               ; D356 2A                       *
        sta     $CF                             ; D357 85 CF                    ..
LD359:  lda     $C08C,x                         ; D359 BD 8C C0                 ...
        bpl     LD359                           ; D35C 10 FB                    ..
        and     $CF                             ; D35E 25 CF                    %.
        sta     $CA,y                           ; D360 99 CA 00                 ...
        eor     $CE                             ; D363 45 CE                    E.
        dey                                     ; D365 88                       .
        bpl     LD34F                           ; D366 10 E7                    ..
        tay                                     ; D368 A8                       .
        bne     LD380                           ; D369 D0 15                    ..
LD36B:  lda     $C08C,x                         ; D36B BD 8C C0                 ...
        bpl     LD36B                           ; D36E 10 FB                    ..
        cmp     #$DE                            ; D370 C9 DE                    ..
        bne     LD380                           ; D372 D0 0C                    ..
        nop                                     ; D374 EA                       .
LD375:  lda     $C08C,x                         ; D375 BD 8C C0                 ...
        bpl     LD375                           ; D378 10 FB                    ..
        cmp     #$AA                            ; D37A C9 AA                    ..
        bne     LD380                           ; D37C D0 02                    ..
        clc                                     ; D37E 18                       .
        rts                                     ; D37F 60                       `

; ----------------------------------------------------------------------------
LD380:  sec                                     ; D380 38                       8
        rts                                     ; D381 60                       `

; ----------------------------------------------------------------------------
wait_disk_change:
        ldy     #$00                            ; D382 A0 00                    ..
LD384:  lda     $C08C,x                         ; D384 BD 8C C0                 ...
        jsr     LD394                           ; D387 20 94 D3                  ..
        pha                                     ; D38A 48                       H
        pla                                     ; D38B 68                       h
        cmp     $C08C,x                         ; D38C DD 8C C0                 ...
        bne     LD394                           ; D38F D0 03                    ..
        dey                                     ; D391 88                       .
        bne     LD384                           ; D392 D0 F0                    ..
LD394:  rts                                     ; D394 60                       `

; ----------------------------------------------------------------------------
        .byte   $00,$00,$04,$98,$99,$08,$0C,$9C ; D395 00 00 04 98 99 08 0C 9C  ........
        .byte   $10,$14,$18,$A0,$A1,$A2,$A3,$A4 ; D39D 10 14 18 A0 A1 A2 A3 A4  ........
        .byte   $A5,$1C,$20,$A8,$A9,$AA,$24,$28 ; D3A5 A5 1C 20 A8 A9 AA 24 28  .. ...$(
        .byte   $2C,$30,$34,$B0,$B1,$38,$3C,$40 ; D3AD 2C 30 34 B0 B1 38 3C 40  ,04..8<@
        .byte   $44,$48,$4C,$B8,$50,$54,$58,$5C ; D3B5 44 48 4C B8 50 54 58 5C  DHL.PTX\
        .byte   $60,$64,$68,$C0,$C1,$C2,$C3,$C4 ; D3BD 60 64 68 C0 C1 C2 C3 C4  `dh.....
        .byte   $C5,$C6,$C7,$C8,$C9,$CA,$6C,$CC ; D3C5 C5 C6 C7 C8 C9 CA 6C CC  ......l.
        .byte   $70,$74,$78,$D0,$D1,$D2,$7C,$D4 ; D3CD 70 74 78 D0 D1 D2 7C D4  ptx...|.
        .byte   $D5,$80,$84,$D8,$88,$8C,$90,$94 ; D3D5 D5 80 84 D8 88 8C 90 94  ........
        .byte   $98,$9C,$A0,$E0,$E1,$E2,$E3,$E4 ; D3DD 98 9C A0 E0 E1 E2 E3 E4  ........
        .byte   $A4,$A8,$AC,$E8,$B0,$B4,$B8,$BC ; D3E5 A4 A8 AC E8 B0 B4 B8 BC  ........
        .byte   $C0,$C4,$C8,$F0,$F1,$CC,$D0,$D4 ; D3ED C0 C4 C8 F0 F1 CC D0 D4  ........
        .byte   $D8,$DC,$E0,$F8,$E4,$E8,$EC,$F0 ; D3F5 D8 DC E0 F8 E4 E8 EC F0  ........
        .byte   $F4,$F8,$FC                     ; D3FD F4 F8 FC                 ...
; Each row: three reversed bit pairs, then the corresponding disk symbol.
; $D403,X encodes an aligned six-bit value; $D400..2,X unpack its low bits.
.define REVERSE_PAIR(value) (((value & 1) << 1) | ((value & 2) >> 1))
gcr_conversion_table:
        .byte REVERSE_PAIR(0), REVERSE_PAIR(0 >> 2), REVERSE_PAIR(0 >> 4), $96
        .byte REVERSE_PAIR(1), REVERSE_PAIR(1 >> 2), REVERSE_PAIR(1 >> 4), $97
        .byte REVERSE_PAIR(2), REVERSE_PAIR(2 >> 2), REVERSE_PAIR(2 >> 4), $9A
        .byte REVERSE_PAIR(3), REVERSE_PAIR(3 >> 2), REVERSE_PAIR(3 >> 4), $9B
        .byte REVERSE_PAIR(4), REVERSE_PAIR(4 >> 2), REVERSE_PAIR(4 >> 4), $9D
        .byte REVERSE_PAIR(5), REVERSE_PAIR(5 >> 2), REVERSE_PAIR(5 >> 4), $9E
        .byte REVERSE_PAIR(6), REVERSE_PAIR(6 >> 2), REVERSE_PAIR(6 >> 4), $9F
        .byte REVERSE_PAIR(7), REVERSE_PAIR(7 >> 2), REVERSE_PAIR(7 >> 4), $A6
        .byte REVERSE_PAIR(8), REVERSE_PAIR(8 >> 2), REVERSE_PAIR(8 >> 4), $A7
        .byte REVERSE_PAIR(9), REVERSE_PAIR(9 >> 2), REVERSE_PAIR(9 >> 4), $AB
        .byte REVERSE_PAIR(10), REVERSE_PAIR(10 >> 2), REVERSE_PAIR(10 >> 4), $AC
        .byte REVERSE_PAIR(11), REVERSE_PAIR(11 >> 2), REVERSE_PAIR(11 >> 4), $AD
        .byte REVERSE_PAIR(12), REVERSE_PAIR(12 >> 2), REVERSE_PAIR(12 >> 4), $AE
        .byte REVERSE_PAIR(13), REVERSE_PAIR(13 >> 2), REVERSE_PAIR(13 >> 4), $AF
        .byte REVERSE_PAIR(14), REVERSE_PAIR(14 >> 2), REVERSE_PAIR(14 >> 4), $B2
        .byte REVERSE_PAIR(15), REVERSE_PAIR(15 >> 2), REVERSE_PAIR(15 >> 4), $B3
        .byte REVERSE_PAIR(16), REVERSE_PAIR(16 >> 2), REVERSE_PAIR(16 >> 4), $B4
        .byte REVERSE_PAIR(17), REVERSE_PAIR(17 >> 2), REVERSE_PAIR(17 >> 4), $B5
        .byte REVERSE_PAIR(18), REVERSE_PAIR(18 >> 2), REVERSE_PAIR(18 >> 4), $B6
        .byte REVERSE_PAIR(19), REVERSE_PAIR(19 >> 2), REVERSE_PAIR(19 >> 4), $B7
        .byte REVERSE_PAIR(20), REVERSE_PAIR(20 >> 2), REVERSE_PAIR(20 >> 4), $B9
        .byte REVERSE_PAIR(21), REVERSE_PAIR(21 >> 2), REVERSE_PAIR(21 >> 4), $BA
        .byte REVERSE_PAIR(22), REVERSE_PAIR(22 >> 2), REVERSE_PAIR(22 >> 4), $BB
        .byte REVERSE_PAIR(23), REVERSE_PAIR(23 >> 2), REVERSE_PAIR(23 >> 4), $BC
        .byte REVERSE_PAIR(24), REVERSE_PAIR(24 >> 2), REVERSE_PAIR(24 >> 4), $BD
        .byte REVERSE_PAIR(25), REVERSE_PAIR(25 >> 2), REVERSE_PAIR(25 >> 4), $BE
        .byte REVERSE_PAIR(26), REVERSE_PAIR(26 >> 2), REVERSE_PAIR(26 >> 4), $BF
        .byte REVERSE_PAIR(27), REVERSE_PAIR(27 >> 2), REVERSE_PAIR(27 >> 4), $CB
        .byte REVERSE_PAIR(28), REVERSE_PAIR(28 >> 2), REVERSE_PAIR(28 >> 4), $CD
        .byte REVERSE_PAIR(29), REVERSE_PAIR(29 >> 2), REVERSE_PAIR(29 >> 4), $CE
        .byte REVERSE_PAIR(30), REVERSE_PAIR(30 >> 2), REVERSE_PAIR(30 >> 4), $CF
        .byte REVERSE_PAIR(31), REVERSE_PAIR(31 >> 2), REVERSE_PAIR(31 >> 4), $D3
        .byte REVERSE_PAIR(32), REVERSE_PAIR(32 >> 2), REVERSE_PAIR(32 >> 4), $D6
        .byte REVERSE_PAIR(33), REVERSE_PAIR(33 >> 2), REVERSE_PAIR(33 >> 4), $D7
        .byte REVERSE_PAIR(34), REVERSE_PAIR(34 >> 2), REVERSE_PAIR(34 >> 4), $D9
        .byte REVERSE_PAIR(35), REVERSE_PAIR(35 >> 2), REVERSE_PAIR(35 >> 4), $DA
        .byte REVERSE_PAIR(36), REVERSE_PAIR(36 >> 2), REVERSE_PAIR(36 >> 4), $DB
        .byte REVERSE_PAIR(37), REVERSE_PAIR(37 >> 2), REVERSE_PAIR(37 >> 4), $DC
        .byte REVERSE_PAIR(38), REVERSE_PAIR(38 >> 2), REVERSE_PAIR(38 >> 4), $DD
        .byte REVERSE_PAIR(39), REVERSE_PAIR(39 >> 2), REVERSE_PAIR(39 >> 4), $DE
        .byte REVERSE_PAIR(40), REVERSE_PAIR(40 >> 2), REVERSE_PAIR(40 >> 4), $DF
        .byte REVERSE_PAIR(41), REVERSE_PAIR(41 >> 2), REVERSE_PAIR(41 >> 4), $E5
        .byte REVERSE_PAIR(42), REVERSE_PAIR(42 >> 2), REVERSE_PAIR(42 >> 4), $E6
        .byte REVERSE_PAIR(43), REVERSE_PAIR(43 >> 2), REVERSE_PAIR(43 >> 4), $E7
        .byte REVERSE_PAIR(44), REVERSE_PAIR(44 >> 2), REVERSE_PAIR(44 >> 4), $E9
        .byte REVERSE_PAIR(45), REVERSE_PAIR(45 >> 2), REVERSE_PAIR(45 >> 4), $EA
        .byte REVERSE_PAIR(46), REVERSE_PAIR(46 >> 2), REVERSE_PAIR(46 >> 4), $EB
        .byte REVERSE_PAIR(47), REVERSE_PAIR(47 >> 2), REVERSE_PAIR(47 >> 4), $EC
        .byte REVERSE_PAIR(48), REVERSE_PAIR(48 >> 2), REVERSE_PAIR(48 >> 4), $ED
        .byte REVERSE_PAIR(49), REVERSE_PAIR(49 >> 2), REVERSE_PAIR(49 >> 4), $EE
        .byte REVERSE_PAIR(50), REVERSE_PAIR(50 >> 2), REVERSE_PAIR(50 >> 4), $EF
        .byte REVERSE_PAIR(51), REVERSE_PAIR(51 >> 2), REVERSE_PAIR(51 >> 4), $F2
        .byte REVERSE_PAIR(52), REVERSE_PAIR(52 >> 2), REVERSE_PAIR(52 >> 4), $F3
        .byte REVERSE_PAIR(53), REVERSE_PAIR(53 >> 2), REVERSE_PAIR(53 >> 4), $F4
        .byte REVERSE_PAIR(54), REVERSE_PAIR(54 >> 2), REVERSE_PAIR(54 >> 4), $F5
        .byte REVERSE_PAIR(55), REVERSE_PAIR(55 >> 2), REVERSE_PAIR(55 >> 4), $F6
        .byte REVERSE_PAIR(56), REVERSE_PAIR(56 >> 2), REVERSE_PAIR(56 >> 4), $F7
        .byte REVERSE_PAIR(57), REVERSE_PAIR(57 >> 2), REVERSE_PAIR(57 >> 4), $F9
        .byte REVERSE_PAIR(58), REVERSE_PAIR(58 >> 2), REVERSE_PAIR(58 >> 4), $FA
        .byte REVERSE_PAIR(59), REVERSE_PAIR(59 >> 2), REVERSE_PAIR(59 >> 4), $FB
        .byte REVERSE_PAIR(60), REVERSE_PAIR(60 >> 2), REVERSE_PAIR(60 >> 4), $FC
        .byte REVERSE_PAIR(61), REVERSE_PAIR(61 >> 2), REVERSE_PAIR(61 >> 4), $FD
        .byte REVERSE_PAIR(62), REVERSE_PAIR(62 >> 2), REVERSE_PAIR(62 >> 4), $FE
        .byte REVERSE_PAIR(63), REVERSE_PAIR(63 >> 2), REVERSE_PAIR(63 >> 4), $FF

; ----------------------------------------------------------------------------
LD500:  sec                                     ; D500 38                       8
        rts                                     ; D501 60                       `

; ----------------------------------------------------------------------------
read_data_field:
        stx     $CE                             ; D502 86 CE                    ..
        txa                                     ; D504 8A                       .
        ora     #$8C                            ; D505 09 8C                    ..
        sta     read_low_bits_latch+1           ; D507 8D 61 D5                 .a.
        sta     read_first_group_latch+1        ; D50A 8D 78 D5                 .x.
        sta     read_second_group_latch+1       ; D50D 8D 8E D5                 ...
        sta     read_third_group_latch+1        ; D510 8D A2 D5                 ...
        sta     read_checksum_latch+1           ; D513 8D B7 D5                 ...
        lda     $3E                             ; D516 A5 3E                    .>
        ldy     $3F                             ; D518 A4 3F                    .?
        sta     store_third_group+1             ; D51A 8D B4 D5                 ...
        sty     store_third_group+2             ; D51D 8C B5 D5                 ...
        sec                                     ; D520 38                       8
        sbc     #$54                            ; D521 E9 54                    .T
        bcs     LD527                           ; D523 B0 02                    ..
        dey                                     ; D525 88                       .
        sec                                     ; D526 38                       8
LD527:  sta     store_second_group+1            ; D527 8D 9C D5                 ...
        sty     store_second_group+2            ; D52A 8C 9D D5                 ...
        sbc     #$57                            ; D52D E9 57                    .W
        bcs     LD532                           ; D52F B0 01                    ..
        dey                                     ; D531 88                       .
LD532:  sta     store_first_group+1             ; D532 8D 75 D5                 .u.
        sty     store_first_group+2             ; D535 8C 76 D5                 .v.
        ldy     #$20                            ; D538 A0 20                    . 
LD53A:  dey                                     ; D53A 88                       .
        beq     LD500                           ; D53B F0 C3                    ..
LD53D:  lda     $C08C,x                         ; D53D BD 8C C0                 ...
        bpl     LD53D                           ; D540 10 FB                    ..
LD542:  eor     #$D5                            ; D542 49 D5                    I.
        bne     LD53A                           ; D544 D0 F4                    ..
        nop                                     ; D546 EA                       .
LD547:  lda     $C08C,x                         ; D547 BD 8C C0                 ...
        bpl     LD547                           ; D54A 10 FB                    ..
        cmp     #$AA                            ; D54C C9 AA                    ..
        bne     LD542                           ; D54E D0 F2                    ..
        nop                                     ; D550 EA                       .
LD551:  lda     $C08C,x                         ; D551 BD 8C C0                 ...
        bpl     LD551                           ; D554 10 FB                    ..
        cmp     #$AD                            ; D556 C9 AD                    ..
        bne     LD542                           ; D558 D0 E8                    ..
        ldy     #$AA                            ; D55A A0 AA                    ..
        lda     #$00                            ; D55C A9 00                    ..
LD55E:  sta     $CF                             ; D55E 85 CF                    ..
read_low_bits_latch:
        ldx     $C0EC                           ; D560 AE EC C0                 ...
        bpl     read_low_bits_latch             ; D563 10 FB                    ..
        lda     gcr_decode_page,x               ; D565 BD 00 D3                 ...
        sta     $0256,y                         ; D568 99 56 02                 .V.
        eor     $CF                             ; D56B 45 CF                    E.
        iny                                     ; D56D C8                       .
        bne     LD55E                           ; D56E D0 EE                    ..
        ldy     #$AA                            ; D570 A0 AA                    ..
        bne     read_first_group_latch          ; D572 D0 03                    ..
store_first_group:
        sta     $1000,y                         ; D574 99 00 10                 ...
read_first_group_latch:
        ldx     $C0EC                           ; D577 AE EC C0                 ...
        bpl     read_first_group_latch          ; D57A 10 FB                    ..
        eor     gcr_decode_page,x               ; D57C 5D 00 D3                 ]..
        ldx     $0256,y                         ; D57F BE 56 02                 .V.
        eor     gcr_conversion_table,x          ; D582 5D 00 D4                 ]..
        iny                                     ; D585 C8                       .
        bne     store_first_group               ; D586 D0 EC                    ..
        pha                                     ; D588 48                       H
        and     #$FC                            ; D589 29 FC                    ).
        ldy     #$AA                            ; D58B A0 AA                    ..
read_second_group_latch:
        ldx     $C0EC                           ; D58D AE EC C0                 ...
        bpl     read_second_group_latch         ; D590 10 FB                    ..
        eor     gcr_decode_page,x               ; D592 5D 00 D3                 ]..
        ldx     $0256,y                         ; D595 BE 56 02                 .V.
        eor     gcr_conversion_table+1,x        ; D598 5D 01 D4                 ]..
store_second_group:
        sta     $1000,y                         ; D59B 99 00 10                 ...
        iny                                     ; D59E C8                       .
        bne     read_second_group_latch         ; D59F D0 EC                    ..
read_third_group_latch:
        ldx     $C0EC                           ; D5A1 AE EC C0                 ...
        bpl     read_third_group_latch          ; D5A4 10 FB                    ..
        and     #$FC                            ; D5A6 29 FC                    ).
        ldy     #$AC                            ; D5A8 A0 AC                    ..
LD5AA:  eor     gcr_decode_page,x               ; D5AA 5D 00 D3                 ]..
        ldx     $0254,y                         ; D5AD BE 54 02                 .T.
        eor     gcr_conversion_table+2,x        ; D5B0 5D 02 D4                 ]..
store_third_group:
        sta     $1000,y                         ; D5B3 99 00 10                 ...
read_checksum_latch:
        ldx     $C0EC                           ; D5B6 AE EC C0                 ...
        bpl     read_checksum_latch             ; D5B9 10 FB                    ..
        iny                                     ; D5BB C8                       .
        bne     LD5AA                           ; D5BC D0 EC                    ..
        and     #$FC                            ; D5BE 29 FC                    ).
        eor     gcr_decode_page,x               ; D5C0 5D 00 D3                 ]..
        ldx     $CE                             ; D5C3 A6 CE                    ..
        tay                                     ; D5C5 A8                       .
        bne     LD5D1                           ; D5C6 D0 09                    ..
LD5C8:  lda     $C08C,x                         ; D5C8 BD 8C C0                 ...
        bpl     LD5C8                           ; D5CB 10 FB                    ..
        cmp     #$DE                            ; D5CD C9 DE                    ..
        beq     LD5D3                           ; D5CF F0 02                    ..
LD5D1:  sec                                     ; D5D1 38                       8
; BIT zp skips CLC, preserving C=1 on the failed checksum/epilogue path.
        .byte   $24                             ; D5D2 24                       $
; ----------------------------------------------------------------------------
LD5D3:  clc                                     ; D5D3 18                       .
        pla                                     ; D5D4 68                       h
        ldy     #$55                            ; D5D5 A0 55                    .U
        sta     ($3E),y                         ; D5D7 91 3E                    .>
        rts                                     ; D5D9 60                       `

; ----------------------------------------------------------------------------
seek_halftrack:
        stx     $C8                             ; D5DA 86 C8                    ..
        sta     $C9                             ; D5DC 85 C9                    ..
        cmp     current_halftrack               ; D5DE CD 90 DC                 ...
        beq     LD636                           ; D5E1 F0 53                    .S
        lda     #$00                            ; D5E3 A9 00                    ..
        sta     $CF                             ; D5E5 85 CF                    ..
LD5E7:  lda     current_halftrack               ; D5E7 AD 90 DC                 ...
        sta     $CE                             ; D5EA 85 CE                    ..
        sec                                     ; D5EC 38                       8
        sbc     $C9                             ; D5ED E5 C9                    ..
        beq     LD624                           ; D5EF F0 33                    .3
        bcs     LD5FA                           ; D5F1 B0 07                    ..
        eor     #$FF                            ; D5F3 49 FF                    I.
        inc     current_halftrack               ; D5F5 EE 90 DC                 ...
        bcc     LD5FF                           ; D5F8 90 05                    ..
LD5FA:  adc     #$FE                            ; D5FA 69 FE                    i.
        dec     current_halftrack               ; D5FC CE 90 DC                 ...
LD5FF:  cmp     $CF                             ; D5FF C5 CF                    ..
        bcc     LD605                           ; D601 90 02                    ..
        lda     $CF                             ; D603 A5 CF                    ..
LD605:  cmp     #$08                            ; D605 C9 08                    ..
        bcs     LD60A                           ; D607 B0 01                    ..
        tay                                     ; D609 A8                       .
LD60A:  sec                                     ; D60A 38                       8
        jsr     LD628                           ; D60B 20 28 D6                  (.
        lda     phase_on_delays,y               ; D60E B9 48 D6                 .H.
        jsr     LD6A2                           ; D611 20 A2 D6                  ..
        lda     $CE                             ; D614 A5 CE                    ..
        clc                                     ; D616 18                       .
        jsr     LD62B                           ; D617 20 2B D6                  +.
        lda     phase_off_delays,y              ; D61A B9 50 D6                 .P.
        jsr     LD6A2                           ; D61D 20 A2 D6                  ..
        inc     $CF                             ; D620 E6 CF                    ..
        bne     LD5E7                           ; D622 D0 C3                    ..
LD624:  jsr     LD6A2                           ; D624 20 A2 D6                  ..
        clc                                     ; D627 18                       .
LD628:  lda     current_halftrack               ; D628 AD 90 DC                 ...
LD62B:  and     #$03                            ; D62B 29 03                    ).
        rol     a                               ; D62D 2A                       *
        ora     $C8                             ; D62E 05 C8                    ..
        tax                                     ; D630 AA                       .
        lda     $C080,x                         ; D631 BD 80 C0                 ...
        ldx     $C8                             ; D634 A6 C8                    ..
LD636:  rts                                     ; D636 60                       `

; ----------------------------------------------------------------------------
seek_delay:
        ldx     #$11                            ; D637 A2 11                    ..
LD639:  dex                                     ; D639 CA                       .
        bne     LD639                           ; D63A D0 FD                    ..
        inc     $46                             ; D63C E6 46                    .F
        bne     LD642                           ; D63E D0 02                    ..
        inc     $47                             ; D640 E6 47                    .G
LD642:  sec                                     ; D642 38                       8
        sbc     #$01                            ; D643 E9 01                    ..
        bne     seek_delay                      ; D645 D0 F0                    ..
        rts                                     ; D647 60                       `

; ----------------------------------------------------------------------------
phase_on_delays:
        .byte   $01,$30,$28,$24,$20,$1E,$1D,$1C ; D648 01 30 28 24 20 1E 1D 1C  .0($ ...
phase_off_delays:
        .byte   $70,$2C,$26,$22,$1F,$1E,$1D,$1C ; D650 70 2C 26 22 1F 1E 1D 1C  p,&"....
; ----------------------------------------------------------------------------
pack_six_and_two:
        ldy     #$56                            ; D658 A0 56                    .V
        lda     #$00                            ; D65A A9 00                    ..
LD65C:  sta     $02FF,y                         ; D65C 99 FF 02                 ...
        dey                                     ; D65F 88                       .
        bne     LD65C                           ; D660 D0 FA                    ..
LD662:  ldx     #$55                            ; D662 A2 55                    .U
LD664:  lda     ($3E),y                         ; D664 B1 3E                    .>
        and     #$FC                            ; D666 29 FC                    ).
        sta     $0200,y                         ; D668 99 00 02                 ...
        eor     ($3E),y                         ; D66B 51 3E                    Q>
        iny                                     ; D66D C8                       .
        cmp     #$02                            ; D66E C9 02                    ..
        ora     $0300,x                         ; D670 1D 00 03                 ...
        ror     a                               ; D673 6A                       j
        ror     a                               ; D674 6A                       j
        sta     $0300,x                         ; D675 9D 00 03                 ...
        dex                                     ; D678 CA                       .
        bpl     LD664                           ; D679 10 E9                    ..
        cpy     #$02                            ; D67B C0 02                    ..
        bne     LD662                           ; D67D D0 E3                    ..
        rts                                     ; D67F 60                       `

; ----------------------------------------------------------------------------
disk_slot_offsets:
        .byte   $60,$50,$40                     ; D680 60 50 40                 `P@
; ----------------------------------------------------------------------------
check_disk_device:
        lsr     a                               ; D683 4A                       J
LD684:  cmp     #$03                            ; D684 C9 03                    ..
        bcs     LD693                           ; D686 B0 0B                    ..
        eor     #$03                            ; D688 49 03                    I.
        tax                                     ; D68A AA                       .
        lda     $BF2A,x                         ; D68B BD 2A BF                 .*.
        eor     #$02                            ; D68E 49 02                    I.
        tax                                     ; D690 AA                       .
        beq     LD695                           ; D691 F0 02                    ..
LD693:  ldx     #$09                            ; D693 A2 09                    ..
LD695:  rts                                     ; D695 60                       `

; ----------------------------------------------------------------------------
LD696:  sec                                     ; D696 38                       8
LD697:  pha                                     ; D697 48                       H
LD698:  sbc     #$01                            ; D698 E9 01                    ..
        bne     LD698                           ; D69A D0 FC                    ..
        pla                                     ; D69C 68                       h
        sbc     #$01                            ; D69D E9 01                    ..
        bne     LD697                           ; D69F D0 F6                    ..
        rts                                     ; D6A1 60                       `

; ----------------------------------------------------------------------------
LD6A2:  jsr     seek_delay                      ; D6A2 20 37 D6                  7.
poll_devices:
        php                                     ; D6A5 08                       .
        pha                                     ; D6A6 48                       H
        txa                                     ; D6A7 8A                       .
        pha                                     ; D6A8 48                       H
        tya                                     ; D6A9 98                       .
        pha                                     ; D6AA 48                       H
LD6AB:  inc     $BF13                           ; D6AB EE 13 BF                 ...
        bne     LD6B3                           ; D6AE D0 03                    ..
        inc     $BF14                           ; D6B0 EE 14 BF                 ...
LD6B3:  lda     $BF2A                           ; D6B3 AD 2A BF                 .*.
        cmp     #$03                            ; D6B6 C9 03                    ..
        bne     LD6BD                           ; D6B8 D0 03                    ..
        jmp     LD75E                           ; D6BA 4C 5E D7                 L^.

; ----------------------------------------------------------------------------
LD6BD:  cmp     #$04                            ; D6BD C9 04                    ..
        beq     LD707                           ; D6BF F0 46                    .F
        cmp     #$06                            ; D6C1 C9 06                    ..
        bne     LD6D4                           ; D6C3 D0 0F                    ..
        lda     #$01                            ; D6C5 A9 01                    ..
        ldy     #$30                            ; D6C7 A0 30                    .0
        jsr     LD987                           ; D6C9 20 87 D9                  ..
        bcc     LD707                           ; D6CC 90 39                    .9
        jsr     LD961                           ; D6CE 20 61 D9                  a.
        jmp     LD767                           ; D6D1 4C 67 D7                 Lg.

; ----------------------------------------------------------------------------
LD6D4:  lda     $FE                             ; D6D4 A5 FE                    ..
        beq     LD6E0                           ; D6D6 F0 08                    ..
        lda     $FD                             ; D6D8 A5 FD                    ..
        bne     LD6E0                           ; D6DA D0 04                    ..
        sta     $FE                             ; D6DC 85 FE                    ..
        beq     LD6FE                           ; D6DE F0 1E                    ..
LD6E0:  lda     $C000                           ; D6E0 AD 00 C0                 ...
        bpl     LD707                           ; D6E3 10 22                    ."
        sta     $C010                           ; D6E5 8D 10 C0                 ...
        and     #$7F                            ; D6E8 29 7F                    ).
        tax                                     ; D6EA AA                       .
        lda     $BF1C                           ; D6EB AD 1C BF                 ...
        ror     a                               ; D6EE 6A                       j
        txa                                     ; D6EF 8A                       .
        bcs     LD730                           ; D6F0 B0 3E                    .>
        cmp     #$01                            ; D6F2 C9 01                    ..
        bne     LD70A                           ; D6F4 D0 14                    ..
        lda     $FD                             ; D6F6 A5 FD                    ..
        beq     LD6FE                           ; D6F8 F0 04                    ..
        sta     $FE                             ; D6FA 85 FE                    ..
        bne     LD707                           ; D6FC D0 09                    ..
LD6FE:  jsr     LFFCE                           ; D6FE 20 CE FF                  ..
        lda     $FA                             ; D701 A5 FA                    ..
        and     #$FE                            ; D703 29 FE                    ).
LD705:  sta     $FA                             ; D705 85 FA                    ..
LD707:  jmp     LD7CD                           ; D707 4C CD D7                 L..

; ----------------------------------------------------------------------------
LD70A:  cmp     #$1A                            ; D70A C9 1A                    ..
        bne     LD714                           ; D70C D0 06                    ..
        lda     $FA                             ; D70E A5 FA                    ..
        ora     #$01                            ; D710 09 01                    ..
        bne     LD705                           ; D712 D0 F1                    ..
LD714:  bit     $BF31                           ; D714 2C 31 BF                 ,1.
        bmi     LD76E                           ; D717 30 55                    0U
        cmp     #$17                            ; D719 C9 17                    ..
        bne     LD721                           ; D71B D0 04                    ..
        lda     #$C0                            ; D71D A9 C0                    ..
        bmi     LD729                           ; D71F 30 08                    0.
LD721:  cmp     #$05                            ; D721 C9 05                    ..
        bne     LD735                           ; D723 D0 10                    ..
        lda     $E1                             ; D725 A5 E1                    ..
        eor     #$80                            ; D727 49 80                    I.
LD729:  sta     $E1                             ; D729 85 E1                    ..
        jsr     LDAE1                           ; D72B 20 E1 DA                  ..
        bne     LD707                           ; D72E D0 D7                    ..
LD730:  bit     $BF31                           ; D730 2C 31 BF                 ,1.
        bmi     LD76E                           ; D733 30 39                    09
LD735:  ldx     #$08                            ; D735 A2 08                    ..
        bit     $C063                           ; D737 2C 63 C0                 ,c.
        bpl     LD74C                           ; D73A 10 10                    ..
        ldx     #$02                            ; D73C A2 02                    ..
        bit     $E1                             ; D73E 24 E1                    $.
        bmi     LD74C                           ; D740 30 0A                    0.
        cmp     #$41                            ; D742 C9 41                    .A
        bcc     LD74C                           ; D744 90 06                    ..
        cmp     #$5B                            ; D746 C9 5B                    .[
        bcs     LD74C                           ; D748 B0 02                    ..
        ora     #$20                            ; D74A 09 20                    . 
LD74C:  bit     $E1                             ; D74C 24 E1                    $.
        bvc     LD754                           ; D74E 50 04                    P.
        ldy     #$00                            ; D750 A0 00                    ..
        sty     $E1                             ; D752 84 E1                    ..
LD754:  cmp     $FFE4,x                         ; D754 DD E4 FF                 ...
        beq     LD76B                           ; D757 F0 12                    ..
        dex                                     ; D759 CA                       .
        bpl     LD754                           ; D75A 10 F8                    ..
        bmi     LD76E                           ; D75C 30 10                    0.
LD75E:  lda     $C0BE                           ; D75E AD BE C0                 ...
        lsr     a                               ; D761 4A                       J
        bcc     LD7CD                           ; D762 90 69                    .i
        lda     $C0BF                           ; D764 AD BF C0                 ...
LD767:  and     #$7F                            ; D767 29 7F                    ).
        bpl     LD76E                           ; D769 10 03                    ..
LD76B:  lda     $FFED,x                         ; D76B BD ED FF                 ...
LD76E:  tax                                     ; D76E AA                       .
        lda     $BF1C                           ; D76F AD 1C BF                 ...
        ror     a                               ; D772 6A                       j
        ror     a                               ; D773 6A                       j
        txa                                     ; D774 8A                       .
        bcs     LD79C                           ; D775 B0 25                    .%
        ldy     #$55                            ; D777 A0 55                    .U
        cmp     ($F8),y                         ; D779 D1 F8                    ..
        bne     LD783                           ; D77B D0 06                    ..
        lda     $FA                             ; D77D A5 FA                    ..
        eor     #$80                            ; D77F 49 80                    I.
LD781:  bne     LD705                           ; D781 D0 82                    ..
LD783:  dey                                     ; D783 88                       .
        cmp     ($F8),y                         ; D784 D1 F8                    ..
        bne     LD791                           ; D786 D0 09                    ..
        lda     $FA                             ; D788 A5 FA                    ..
        and     #$3F                            ; D78A 29 3F                    )?
        sta     $FA                             ; D78C 85 FA                    ..
        jmp     LFEE6                           ; D78E 4C E6 FE                 L..

; ----------------------------------------------------------------------------
LD791:  dey                                     ; D791 88                       .
        cmp     ($F8),y                         ; D792 D1 F8                    ..
        bne     LD79C                           ; D794 D0 06                    ..
        lda     $FA                             ; D796 A5 FA                    ..
        eor     #$40                            ; D798 49 40                    I@
        bne     LD781                           ; D79A D0 E5                    ..
LD79C:  ldy     #$00                            ; D79C A0 00                    ..
        ldx     $C061                           ; D79E AE 61 C0                 .a.
        bpl     LD7A8                           ; D7A1 10 05                    ..
        ora     $BF11                           ; D7A3 0D 11 BF                 ...
        ldy     #$84                            ; D7A6 A0 84                    ..
LD7A8:  pha                                     ; D7A8 48                       H
        tya                                     ; D7A9 98                       .
        ldx     $C062                           ; D7AA AE 62 C0                 .b.
        bpl     LD7B1                           ; D7AD 10 02                    ..
        ora     #$90                            ; D7AF 09 90                    ..
LD7B1:  ldx     $C063                           ; D7B1 AE 63 C0                 .c.
        bmi     LD7B8                           ; D7B4 30 02                    0.
        ora     #$C0                            ; D7B6 09 C0                    ..
LD7B8:  ldx     $BF19                           ; D7B8 AE 19 BF                 ...
        tay                                     ; D7BB A8                       .
        beq     LD7C1                           ; D7BC F0 03                    ..
        jsr     LD7D4                           ; D7BE 20 D4 D7                  ..
LD7C1:  pla                                     ; D7C1 68                       h
        pha                                     ; D7C2 48                       H
        jsr     LD7D4                           ; D7C3 20 D4 D7                  ..
        stx     $BF19                           ; D7C6 8E 19 BF                 ...
        pla                                     ; D7C9 68                       h
        inc     $BF15                           ; D7CA EE 15 BF                 ...
LD7CD:  bit     $FA                             ; D7CD 24 FA                    $.
        bpl     LD7E8                           ; D7CF 10 17                    ..
        jmp     LD6AB                           ; D7D1 4C AB D6                 L..

; ----------------------------------------------------------------------------
LD7D4:  jsr     advance_key_index               ; D7D4 20 9A D9                  ..
        cpx     $BF18                           ; D7D7 EC 18 BF                 ...
        bne     LD7E4                           ; D7DA D0 08                    ..
        pla                                     ; D7DC 68                       h
        pla                                     ; D7DD 68                       h
        pla                                     ; D7DE 68                       h
        jsr     LDA87                           ; D7DF 20 87 DA                  ..
        beq     LD7CD                           ; D7E2 F0 E9                    ..
LD7E4:  sta     $03B1,x                         ; D7E4 9D B1 03                 ...
        rts                                     ; D7E7 60                       `

; ----------------------------------------------------------------------------
LD7E8:  pla                                     ; D7E8 68                       h
        tay                                     ; D7E9 A8                       .
        pla                                     ; D7EA 68                       h
        tax                                     ; D7EB AA                       .
        pla                                     ; D7EC 68                       h
        plp                                     ; D7ED 28                       (
        rts                                     ; D7EE 60                       `

; ----------------------------------------------------------------------------
        pla                                     ; D7EF 68                       h
        sta     L00F6                           ; D7F0 85 F6                    ..
        pla                                     ; D7F2 68                       h
        sta     $F7                             ; D7F3 85 F7                    ..
        pla                                     ; D7F5 68                       h
        sta     $F8                             ; D7F6 85 F8                    ..
        pla                                     ; D7F8 68                       h
        sta     $F9                             ; D7F9 85 F9                    ..
        pla                                     ; D7FB 68                       h
        sta     $BF16                           ; D7FC 8D 16 BF                 ...
        pla                                     ; D7FF 68                       h
        sta     $BF17                           ; D800 8D 17 BF                 ...
        lda     $F7                             ; D803 A5 F7                    ..
        pha                                     ; D805 48                       H
        lda     L00F6                           ; D806 A5 F6                    ..
        pha                                     ; D808 48                       H
        lda     $BF18                           ; D809 AD 18 BF                 ...
        sta     $BF19                           ; D80C 8D 19 BF                 ...
        lda     $FA                             ; D80F A5 FA                    ..
        and     #$3E                            ; D811 29 3E                    )>
        sta     $FA                             ; D813 85 FA                    ..
        jsr     LFFD8                           ; D815 20 D8 FF                  ..
        ldx     #$00                            ; D818 A2 00                    ..
        stx     $BF15                           ; D81A 8E 15 BF                 ...
        rts                                     ; D81D 60                       `

; ----------------------------------------------------------------------------
        ldy     #$30                            ; D81E A0 30                    .0
        lda     $BF2A                           ; D820 AD 2A BF                 .*.
        cmp     #$04                            ; D823 C9 04                    ..
        bne     LD82D                           ; D825 D0 06                    ..
        jsr     LD978                           ; D827 20 78 D9                  x.
        and     #$7F                            ; D82A 29 7F                    ).
        rts                                     ; D82C 60                       `

; ----------------------------------------------------------------------------
LD82D:  cmp     #$03                            ; D82D C9 03                    ..
        beq     LD845                           ; D82F F0 14                    ..
        cmp     #$06                            ; D831 C9 06                    ..
        beq     LD845                           ; D833 F0 10                    ..
        jsr     LD845                           ; D835 20 45 D8                  E.
        pha                                     ; D838 48                       H
        pla                                     ; D839 68                       h
        ldx     #$00                            ; D83A A2 00                    ..
LD83C:  rts                                     ; D83C 60                       `

; ----------------------------------------------------------------------------
LD83D:  lda     $BF12                           ; D83D AD 12 BF                 ...
        bne     LD83C                           ; D840 D0 FA                    ..
        jmp     LDB03                           ; D842 4C 03 DB                 L..

; ----------------------------------------------------------------------------
LD845:  jmp     LD9A3                           ; D845 4C A3 D9                 L..

; ----------------------------------------------------------------------------
        ldy     #$10                            ; D848 A0 10                    ..
        lda     $BF28                           ; D84A AD 28 BF                 .(.
        cmp     #$05                            ; D84D C9 05                    ..
        beq     LD89E                           ; D84F F0 4D                    .M
LD851:  cmp     #$04                            ; D851 C9 04                    ..
        beq     LD898                           ; D853 F0 43                    .C
        cmp     #$03                            ; D855 C9 03                    ..
        beq     LD88C                           ; D857 F0 33                    .3
        cmp     #$06                            ; D859 C9 06                    ..
        beq     LD860                           ; D85B F0 03                    ..
        ldx     #$09                            ; D85D A2 09                    ..
        rts                                     ; D85F 60                       `

; ----------------------------------------------------------------------------
LD860:  pha                                     ; D860 48                       H
        jsr     LD8A1                           ; D861 20 A1 D8                  ..
        ldy     #$0D                            ; D864 A0 0D                    ..
LD866:  lda     (L00F6),y                       ; D866 B1 F6                    ..
        sta     L00F6                           ; D868 85 F6                    ..
        ldy     $06F8                           ; D86A AC F8 06                 ...
        pla                                     ; D86D 68                       h
        sta     $C001                           ; D86E 8D 01 C0                 ...
        jsr     LD87E                           ; D871 20 7E D8                  ~.
        sta     $C000                           ; D874 8D 00 C0                 ...
        bit     $C083                           ; D877 2C 83 C0                 ,..
        bit     $C083                           ; D87A 2C 83 C0                 ,..
        rts                                     ; D87D 60                       `

; ----------------------------------------------------------------------------
LD87E:  jmp     (L00F6)                         ; D87E 6C F6 00                 l..

; ----------------------------------------------------------------------------
        lda     $C050                           ; D881 AD 50 C0                 .P.
        rts                                     ; D884 60                       `

; ----------------------------------------------------------------------------
        lda     $BF29                           ; D885 AD 29 BF                 .).
        ldy     #$20                            ; D888 A0 20                    . 
        bne     LD851                           ; D88A D0 C5                    ..
LD88C:  lda     #$03                            ; D88C A9 03                    ..
        sta     $C08E,y                         ; D88E 99 8E C0                 ...
        lda     #$15                            ; D891 A9 15                    ..
        sta     $C08E,y                         ; D893 99 8E C0                 ...
        bne     LD89E                           ; D896 D0 06                    ..
LD898:  jsr     LD8A1                           ; D898 20 A1 D8                  ..
        jsr     LC800                           ; D89B 20 00 C8                  ..
LD89E:  ldx     #$00                            ; D89E A2 00                    ..
        rts                                     ; D8A0 60                       `

; ----------------------------------------------------------------------------
LD8A1:  sty     $06F8                           ; D8A1 8C F8 06                 ...
        tya                                     ; D8A4 98                       .
        lsr     a                               ; D8A5 4A                       J
        lsr     a                               ; D8A6 4A                       J
        lsr     a                               ; D8A7 4A                       J
        lsr     a                               ; D8A8 4A                       J
        ora     #$C0                            ; D8A9 09 C0                    ..
        tax                                     ; D8AB AA                       .
        lda     #$00                            ; D8AC A9 00                    ..
        sta     L00F6                           ; D8AE 85 F6                    ..
        stx     $F7                             ; D8B0 86 F7                    ..
        lda     $CFFF                           ; D8B2 AD FF CF                 ...
        lda     (L00F6),y                       ; D8B5 B1 F6                    ..
        rts                                     ; D8B7 60                       `

; ----------------------------------------------------------------------------
output_console_character:
        jsr     poll_devices                    ; D8B8 20 A5 D6                  ..
        bit     $FA                             ; D8BB 24 FA                    $.
        bvs     LD8DE                           ; D8BD 70 1F                    p.
        tax                                     ; D8BF AA                       .
        ldy     #$30                            ; D8C0 A0 30                    .0
        lda     $BF2A                           ; D8C2 AD 2A BF                 .*.
        cmp     #$03                            ; D8C5 C9 03                    ..
        beq     LD918                           ; D8C7 F0 4F                    .O
        cmp     #$04                            ; D8C9 C9 04                    ..
        beq     LD8F0                           ; D8CB F0 23                    .#
        cmp     #$06                            ; D8CD C9 06                    ..
        beq     LD8E1                           ; D8CF F0 10                    ..
        stx     L00F6                           ; D8D1 86 F6                    ..
        jsr     LD83D                           ; D8D3 20 3D D8                  =.
        ldy     $F4                             ; D8D6 A4 F4                    ..
        jsr     process_console_character       ; D8D8 20 CA D9                  ..
        jsr     LD83D                           ; D8DB 20 3D D8                  =.
LD8DE:  ldx     #$00                            ; D8DE A2 00                    ..
        rts                                     ; D8E0 60                       `

; ----------------------------------------------------------------------------
LD8E1:  txa                                     ; D8E1 8A                       .
        pha                                     ; D8E2 48                       H
        lda     #$00                            ; D8E3 A9 00                    ..
        jsr     LD98F                           ; D8E5 20 8F D9                  ..
        jsr     LD8A1                           ; D8E8 20 A1 D8                  ..
        ldy     #$0F                            ; D8EB A0 0F                    ..
LD8ED:  jmp     LD866                           ; D8ED 4C 66 D8                 Lf.

; ----------------------------------------------------------------------------
LD8F0:  jsr     poll_devices                    ; D8F0 20 A5 D6                  ..
        txa                                     ; D8F3 8A                       .
        pha                                     ; D8F4 48                       H
        jsr     LD8A1                           ; D8F5 20 A1 D8                  ..
        pla                                     ; D8F8 68                       h
        sta     $05B8,x                         ; D8F9 9D B8 05                 ...
        jsr     LC9AA                           ; D8FC 20 AA C9                  ..
        ldx     #$00                            ; D8FF A2 00                    ..
        rts                                     ; D901 60                       `

; ----------------------------------------------------------------------------
        tax                                     ; D902 AA                       .
        lda     $BF29                           ; D903 AD 29 BF                 .).
        ldy     #$20                            ; D906 A0 20                    . 
        bne     LD93C                           ; D908 D0 32                    .2
LD90A:  jsr     poll_devices                    ; D90A 20 A5 D6                  ..
        lda     $C1C1                           ; D90D AD C1 C1                 ...
        bmi     LD90A                           ; D910 30 F8                    0.
        stx     $C090                           ; D912 8E 90 C0                 ...
        ldx     #$00                            ; D915 A2 00                    ..
        rts                                     ; D917 60                       `

; ----------------------------------------------------------------------------
LD918:  jsr     poll_devices                    ; D918 20 A5 D6                  ..
        lda     $C08E,y                         ; D91B B9 8E C0                 ...
        and     #$02                            ; D91E 29 02                    ).
        beq     LD918                           ; D920 F0 F6                    ..
        txa                                     ; D922 8A                       .
        sta     $C08F,y                         ; D923 99 8F C0                 ...
        ldx     #$00                            ; D926 A2 00                    ..
        rts                                     ; D928 60                       `

; ----------------------------------------------------------------------------
        tax                                     ; D929 AA                       .
        lda     $BF0F                           ; D92A AD 0F BF                 ...
        bpl     LD933                           ; D92D 10 04                    ..
        cpx     #$0A                            ; D92F E0 0A                    ..
        beq     LD8DE                           ; D931 F0 AB                    ..
LD933:  ldy     #$10                            ; D933 A0 10                    ..
        lda     $BF28                           ; D935 AD 28 BF                 .(.
        cmp     #$05                            ; D938 C9 05                    ..
        beq     LD90A                           ; D93A F0 CE                    ..
LD93C:  cmp     #$04                            ; D93C C9 04                    ..
        beq     LD8F0                           ; D93E F0 B0                    ..
        cmp     #$03                            ; D940 C9 03                    ..
        beq     LD918                           ; D942 F0 D4                    ..
        cmp     #$06                            ; D944 C9 06                    ..
        beq     LD8E1                           ; D946 F0 99                    ..
LD948:  ldx     #$09                            ; D948 A2 09                    ..
        rts                                     ; D94A 60                       `

; ----------------------------------------------------------------------------
        lda     $BF29                           ; D94B AD 29 BF                 .).
        ldy     #$20                            ; D94E A0 20                    . 
        cmp     #$04                            ; D950 C9 04                    ..
        beq     LD978                           ; D952 F0 24                    .$
        cmp     #$03                            ; D954 C9 03                    ..
        beq     LD969                           ; D956 F0 11                    ..
        cmp     #$06                            ; D958 C9 06                    ..
        bne     LD948                           ; D95A D0 EC                    ..
        lda     #$01                            ; D95C A9 01                    ..
        jsr     LD98F                           ; D95E 20 8F D9                  ..
LD961:  jsr     LD8A1                           ; D961 20 A1 D8                  ..
        pha                                     ; D964 48                       H
        ldy     #$0E                            ; D965 A0 0E                    ..
LD967:  bne     LD8ED                           ; D967 D0 84                    ..
LD969:  jsr     poll_devices                    ; D969 20 A5 D6                  ..
        lda     $C08E,y                         ; D96C B9 8E C0                 ...
        lsr     a                               ; D96F 4A                       J
        bcc     LD969                           ; D970 90 F7                    ..
        lda     $C08F,y                         ; D972 B9 8F C0                 ...
        ldx     #$00                            ; D975 A2 00                    ..
        rts                                     ; D977 60                       `

; ----------------------------------------------------------------------------
LD978:  jsr     poll_devices                    ; D978 20 A5 D6                  ..
        jsr     LD8A1                           ; D97B 20 A1 D8                  ..
        jsr     LC84D                           ; D97E 20 4D C8                  M.
        lda     $05B8,x                         ; D981 BD B8 05                 ...
        ldx     #$00                            ; D984 A2 00                    ..
        rts                                     ; D986 60                       `

; ----------------------------------------------------------------------------
LD987:  pha                                     ; D987 48                       H
        jsr     LD8A1                           ; D988 20 A1 D8                  ..
        ldy     #$10                            ; D98B A0 10                    ..
        bne     LD967                           ; D98D D0 D8                    ..
LD98F:  jsr     poll_devices                    ; D98F 20 A5 D6                  ..
        pha                                     ; D992 48                       H
        jsr     LD987                           ; D993 20 87 D9                  ..
        pla                                     ; D996 68                       h
        bcc     LD98F                           ; D997 90 F6                    ..
        rts                                     ; D999 60                       `

; ----------------------------------------------------------------------------
advance_key_index:
        inx                                     ; D99A E8                       .
        cpx     #$40                            ; D99B E0 40                    .@
        beq     LD9B3                           ; D99D F0 14                    ..
        rts                                     ; D99F 60                       `

; ----------------------------------------------------------------------------
read_buffered_key:
        jsr     LDBBF                           ; D9A0 20 BF DB                  ..
LD9A3:  jsr     key_available                   ; D9A3 20 C3 D9                  ..
        beq     read_buffered_key               ; D9A6 F0 F8                    ..
        dec     $BF15                           ; D9A8 CE 15 BF                 ...
        jsr     take_buffered_key               ; D9AB 20 B6 D9                  ..
        bpl     LD9B3                           ; D9AE 10 03                    ..
        jsr     take_buffered_key               ; D9B0 20 B6 D9                  ..
LD9B3:  ldx     #$00                            ; D9B3 A2 00                    ..
        rts                                     ; D9B5 60                       `

; ----------------------------------------------------------------------------
take_buffered_key:
        ldx     $BF18                           ; D9B6 AE 18 BF                 ...
        jsr     advance_key_index               ; D9B9 20 9A D9                  ..
        stx     $BF18                           ; D9BC 8E 18 BF                 ...
        lda     $03B1,x                         ; D9BF BD B1 03                 ...
        rts                                     ; D9C2 60                       `

; ----------------------------------------------------------------------------
key_available:
        jsr     poll_devices                    ; D9C3 20 A5 D6                  ..
        lda     $BF15                           ; D9C6 AD 15 BF                 ...
        rts                                     ; D9C9 60                       `

; ----------------------------------------------------------------------------
process_console_character:
        lda     $FC                             ; D9CA A5 FC                    ..
        beq     LDA01                           ; D9CC F0 33                    .3
        cmp     #$02                            ; D9CE C9 02                    ..
        bcc     LD9E3                           ; D9D0 90 11                    ..
        beq     LD9E6                           ; D9D2 F0 12                    ..
        lda     L00F6                           ; D9D4 A5 F6                    ..
        sec                                     ; D9D6 38                       8
        sbc     #$20                            ; D9D7 E9 20                    . 
        bmi     LD9DF                           ; D9D9 30 04                    0.
        cmp     #$50                            ; D9DB C9 50                    .P
        bcc     LD9E1                           ; D9DD 90 02                    ..
LD9DF:  lda     #$00                            ; D9DF A9 00                    ..
LD9E1:  sta     $F7                             ; D9E1 85 F7                    ..
LD9E3:  dec     $FC                             ; D9E3 C6 FC                    ..
        rts                                     ; D9E5 60                       `

; ----------------------------------------------------------------------------
LD9E6:  lda     L00F6                           ; D9E6 A5 F6                    ..
        sec                                     ; D9E8 38                       8
        sbc     #$20                            ; D9E9 E9 20                    . 
        bmi     LD9F1                           ; D9EB 30 04                    0.
        cmp     #$18                            ; D9ED C9 18                    ..
        bcc     LD9F3                           ; D9EF 90 02                    ..
LD9F1:  lda     #$00                            ; D9F1 A9 00                    ..
LD9F3:  sta     $F5                             ; D9F3 85 F5                    ..
        jsr     text_row_addresses              ; D9F5 20 44 DB                  D.
        lda     $F7                             ; D9F8 A5 F7                    ..
        sta     $F4                             ; D9FA 85 F4                    ..
        lda     #$00                            ; D9FC A9 00                    ..
LD9FE:  sta     $FC                             ; D9FE 85 FC                    ..
        rts                                     ; DA00 60                       `

; ----------------------------------------------------------------------------
LDA01:  lda     L00F6                           ; DA01 A5 F6                    ..
        cmp     #$20                            ; DA03 C9 20                    . 
        bcc     dispatch_control_character      ; DA05 90 16                    ..
        and     #$7F                            ; DA07 29 7F                    ).
        cmp     #$60                            ; DA09 C9 60                    .`
        lda     L00F6                           ; DA0B A5 F6                    ..
        bcc     LDA16                           ; DA0D 90 07                    ..
        bit     $BF31                           ; DA0F 2C 31 BF                 ,1.
        bmi     character_inverse_mask          ; DA12 30 04                    0.
        sbc     #$20                            ; DA14 E9 20                    . 
LDA16:  and     #$3F                            ; DA16 29 3F                    )?
character_inverse_mask:
        eor     #$80                            ; DA18 49 80                    I.
        jmp     LDAF6                           ; DA1A 4C F6 DA                 L..

; ----------------------------------------------------------------------------
dispatch_control_character:
        ldx     #$11                            ; DA1D A2 11                    ..
LDA1F:  cmp     control_characters,x            ; DA1F DD 59 DC                 .Y.
        beq     LDA28                           ; DA22 F0 04                    ..
        dex                                     ; DA24 CA                       .
        bpl     LDA1F                           ; DA25 10 F8                    ..
        rts                                     ; DA27 60                       `

; ----------------------------------------------------------------------------
LDA28:  txa                                     ; DA28 8A                       .
        asl     a                               ; DA29 0A                       .
        tax                                     ; DA2A AA                       .
        lda     control_handlers+1,x            ; DA2B BD 6C DC                 .l.
        sta     $C0                             ; DA2E 85 C0                    ..
        lda     control_handlers,x              ; DA30 BD 6B DC                 .k.
        sta     L00BF                           ; DA33 85 BF                    ..
        lda     #$80                            ; DA35 A9 80                    ..
        jmp     (L00BF)                         ; DA37 6C BF 00                 l..

; ----------------------------------------------------------------------------
LDA3A:  lda     #$01                            ; DA3A A9 01                    ..
        bne     LD9FE                           ; DA3C D0 C0                    ..
LDA3E:  lda     #$03                            ; DA3E A9 03                    ..
        bne     LD9FE                           ; DA40 D0 BC                    ..
LDA42:  ldy     #$00                            ; DA42 A0 00                    ..
        sty     $F4                             ; DA44 84 F4                    ..
        rts                                     ; DA46 60                       `

; ----------------------------------------------------------------------------
LDA47:  lda     $F5                             ; DA47 A5 F5                    ..
        cmp     #$17                            ; DA49 C9 17                    ..
        beq     LDA51                           ; DA4B F0 04                    ..
LDA4D:  inc     $F5                             ; DA4D E6 F5                    ..
        bpl     LDACD                           ; DA4F 10 7C                    .|
LDA51:  lda     $F4                             ; DA51 A5 F4                    ..
        pha                                     ; DA53 48                       H
        ldx     #$00                            ; DA54 A2 00                    ..
        stx     $F5                             ; DA56 86 F5                    ..
        jsr     text_row_addresses              ; DA58 20 44 DB                  D.
LDA5B:  ldy     #$03                            ; DA5B A0 03                    ..
LDA5D:  lda     $F0,y                           ; DA5D B9 F0 00                 ...
        sta     $C1,y                           ; DA60 99 C1 00                 ...
        dey                                     ; DA63 88                       .
        bpl     LDA5D                           ; DA64 10 F7                    ..
        inx                                     ; DA66 E8                       .
        stx     $F5                             ; DA67 86 F5                    ..
        jsr     text_row_addresses              ; DA69 20 44 DB                  D.
        ldy     #$27                            ; DA6C A0 27                    .'
LDA6E:  lda     ($F0),y                         ; DA6E B1 F0                    ..
        sta     ($C1),y                         ; DA70 91 C1                    ..
        lda     ($F2),y                         ; DA72 B1 F2                    ..
        sta     ($C3),y                         ; DA74 91 C3                    ..
        dey                                     ; DA76 88                       .
        bpl     LDA6E                           ; DA77 10 F5                    ..
        cpx     #$17                            ; DA79 E0 17                    ..
        bne     LDA5B                           ; DA7B D0 DE                    ..
        jsr     LDA42                           ; DA7D 20 42 DA                  B.
        jsr     LDAD0                           ; DA80 20 D0 DA                  ..
        pla                                     ; DA83 68                       h
        sta     $F4                             ; DA84 85 F4                    ..
        rts                                     ; DA86 60                       `

; ----------------------------------------------------------------------------
LDA87:  lda     #$40                            ; DA87 A9 40                    .@
        jsr     LD696                           ; DA89 20 96 D6                  ..
        ldy     #$C0                            ; DA8C A0 C0                    ..
LDA8E:  lda     #$0C                            ; DA8E A9 0C                    ..
        jsr     LD696                           ; DA90 20 96 D6                  ..
        lda     $C030                           ; DA93 AD 30 C0                 .0.
        dey                                     ; DA96 88                       .
        bne     LDA8E                           ; DA97 D0 F5                    ..
LDA99:  rts                                     ; DA99 60                       `

; ----------------------------------------------------------------------------
LDA9A:  lda     $F5                             ; DA9A A5 F5                    ..
        beq     LDA99                           ; DA9C F0 FB                    ..
        dec     $F5                             ; DA9E C6 F5                    ..
        bpl     LDACD                           ; DAA0 10 2B                    .+
LDAA2:  cpy     #$00                            ; DAA2 C0 00                    ..
        beq     LDAA8                           ; DAA4 F0 02                    ..
        dec     $F4                             ; DAA6 C6 F4                    ..
LDAA8:  rts                                     ; DAA8 60                       `

; ----------------------------------------------------------------------------
LDAA9:  jsr     LDAC7                           ; DAA9 20 C7 DA                  ..
LDAAC:  lda     $F4                             ; DAAC A5 F4                    ..
        pha                                     ; DAAE 48                       H
        lda     $F5                             ; DAAF A5 F5                    ..
        pha                                     ; DAB1 48                       H
LDAB2:  jsr     LDAD0                           ; DAB2 20 D0 DA                  ..
        jsr     LDA42                           ; DAB5 20 42 DA                  B.
        jsr     LDA4D                           ; DAB8 20 4D DA                  M.
        lda     $F5                             ; DABB A5 F5                    ..
        cmp     #$18                            ; DABD C9 18                    ..
        bcc     LDAB2                           ; DABF 90 F1                    ..
        pla                                     ; DAC1 68                       h
        sta     $F5                             ; DAC2 85 F5                    ..
        pla                                     ; DAC4 68                       h
        bpl     LDACB                           ; DAC5 10 04                    ..
LDAC7:  lda     #$00                            ; DAC7 A9 00                    ..
        sta     $F5                             ; DAC9 85 F5                    ..
LDACB:  sta     $F4                             ; DACB 85 F4                    ..
LDACD:  jmp     text_row_addresses              ; DACD 4C 44 DB                 LD.

; ----------------------------------------------------------------------------
LDAD0:  ldx     $F4                             ; DAD0 A6 F4                    ..
LDAD2:  lda     #$A0                            ; DAD2 A9 A0                    ..
        jsr     LDAF6                           ; DAD4 20 F6 DA                  ..
        bcc     LDAD2                           ; DAD7 90 F9                    ..
        stx     $F4                             ; DAD9 86 F4                    ..
        rts                                     ; DADB 60                       `

; ----------------------------------------------------------------------------
LDADC:  bit     $BF31                           ; DADC 2C 31 BF                 ,1.
        bmi     LDAE5                           ; DADF 30 04                    0.
LDAE1:  lda     #$80                            ; DAE1 A9 80                    ..
        sta     $E0                             ; DAE3 85 E0                    ..
LDAE5:  rts                                     ; DAE5 60                       `

; ----------------------------------------------------------------------------
LDAE6:  sta     $E1                             ; DAE6 85 E1                    ..
        asl     a                               ; DAE8 0A                       .
        sta     $E0                             ; DAE9 85 E0                    ..
        rts                                     ; DAEB 60                       `

; ----------------------------------------------------------------------------
LDAEC:  asl     a                               ; DAEC 0A                       .
LDAED:  sta     $BF12                           ; DAED 8D 12 BF                 ...
        rts                                     ; DAF0 60                       `

; ----------------------------------------------------------------------------
LDAF1:  asl     a                               ; DAF1 0A                       .
LDAF2:  sta     character_inverse_mask+1        ; DAF2 8D 19 DA                 ...
        rts                                     ; DAF5 60                       `

; ----------------------------------------------------------------------------
LDAF6:  jsr     LDB03                           ; DAF6 20 03 DB                  ..
LDAF9:  ldy     $F4                             ; DAF9 A4 F4                    ..
        cpy     #$4F                            ; DAFB C0 4F                    .O
        bcs     LDB02                           ; DAFD B0 03                    ..
        iny                                     ; DAFF C8                       .
        sty     $F4                             ; DB00 84 F4                    ..
LDB02:  rts                                     ; DB02 60                       `

; ----------------------------------------------------------------------------
LDB03:  pha                                     ; DB03 48                       H
        tay                                     ; DB04 A8                       .
        beq     LDB1B                           ; DB05 F0 14                    ..
        bit     $E0                             ; DB07 24 E0                    $.
        bpl     LDB1B                           ; DB09 10 10                    ..
        lda     L00F6                           ; DB0B A5 F6                    ..
        and     #$7F                            ; DB0D 29 7F                    ).
        cmp     #$41                            ; DB0F C9 41                    .A
        bcc     LDB1B                           ; DB11 90 08                    ..
        cmp     #$5B                            ; DB13 C9 5B                    .[
        bcs     LDB1B                           ; DB15 B0 04                    ..
        pla                                     ; DB17 68                       h
        eor     #$80                            ; DB18 49 80                    I.
        pha                                     ; DB1A 48                       H
LDB1B:  lda     $F4                             ; DB1B A5 F4                    ..
        sec                                     ; DB1D 38                       8
        sbc     $FB                             ; DB1E E5 FB                    ..
        bmi     LDB31                           ; DB20 30 0F                    0.
        cmp     #$28                            ; DB22 C9 28                    .(
        bcs     LDB36                           ; DB24 B0 10                    ..
        tay                                     ; DB26 A8                       .
        pla                                     ; DB27 68                       h
        bne     LDB2E                           ; DB28 D0 04                    ..
        lda     ($F0),y                         ; DB2A B1 F0                    ..
        eor     #$80                            ; DB2C 49 80                    I.
LDB2E:  sta     ($F0),y                         ; DB2E 91 F0                    ..
        rts                                     ; DB30 60                       `

; ----------------------------------------------------------------------------
LDB31:  clc                                     ; DB31 18                       .
        adc     #$28                            ; DB32 69 28                    i(
        bpl     LDB39                           ; DB34 10 03                    ..
LDB36:  sec                                     ; DB36 38                       8
        sbc     #$28                            ; DB37 E9 28                    .(
LDB39:  tay                                     ; DB39 A8                       .
        pla                                     ; DB3A 68                       h
        bne     LDB41                           ; DB3B D0 04                    ..
        lda     ($F2),y                         ; DB3D B1 F2                    ..
        eor     #$80                            ; DB3F 49 80                    I.
LDB41:  sta     ($F2),y                         ; DB41 91 F2                    ..
        rts                                     ; DB43 60                       `

; ----------------------------------------------------------------------------
text_row_addresses:
        lda     $F5                             ; DB44 A5 F5                    ..
        lsr     a                               ; DB46 4A                       J
        and     #$03                            ; DB47 29 03                    ).
        ora     #$04                            ; DB49 09 04                    ..
        sta     $F1                             ; DB4B 85 F1                    ..
        lda     $F5                             ; DB4D A5 F5                    ..
        and     #$18                            ; DB4F 29 18                    ).
        bcc     LDB55                           ; DB51 90 02                    ..
        adc     #$7F                            ; DB53 69 7F                    i.
LDB55:  sta     $F0                             ; DB55 85 F0                    ..
        asl     a                               ; DB57 0A                       .
        asl     a                               ; DB58 0A                       .
        ora     $F0                             ; DB59 05 F0                    ..
        sta     $F0                             ; DB5B 85 F0                    ..
        sta     $F2                             ; DB5D 85 F2                    ..
        lda     $F1                             ; DB5F A5 F1                    ..
        clc                                     ; DB61 18                       .
        adc     #$04                            ; DB62 69 04                    i.
        sta     $F3                             ; DB64 85 F3                    ..
LDB66:  rts                                     ; DB66 60                       `

; ----------------------------------------------------------------------------
shift_text_columns:
        tax                                     ; DB67 AA                       .
        beq     LDB66                           ; DB68 F0 FC                    ..
        lda     $F5                             ; DB6A A5 F5                    ..
        pha                                     ; DB6C 48                       H
        txa                                     ; DB6D 8A                       .
        pha                                     ; DB6E 48                       H
        sec                                     ; DB6F 38                       8
        sbc     #$28                            ; DB70 E9 28                    .(
        bpl     LDB77                           ; DB72 10 03                    ..
        clc                                     ; DB74 18                       .
        adc     #$50                            ; DB75 69 50                    iP
LDB77:  pha                                     ; DB77 48                       H
        lda     #$17                            ; DB78 A9 17                    ..
        sta     $F5                             ; DB7A 85 F5                    ..
LDB7C:  jsr     text_row_addresses              ; DB7C 20 44 DB                  D.
        ldy     #$27                            ; DB7F A0 27                    .'
LDB81:  lda     ($F0),y                         ; DB81 B1 F0                    ..
        sta     $0200,y                         ; DB83 99 00 02                 ...
        lda     ($F2),y                         ; DB86 B1 F2                    ..
        sta     $0228,y                         ; DB88 99 28 02                 .(.
        dey                                     ; DB8B 88                       .
        bpl     LDB81                           ; DB8C 10 F3                    ..
        pla                                     ; DB8E 68                       h
        pha                                     ; DB8F 48                       H
        tax                                     ; DB90 AA                       .
        lda     #$F0                            ; DB91 A9 F0                    ..
        jsr     LDBAC                           ; DB93 20 AC DB                  ..
        lda     #$F2                            ; DB96 A9 F2                    ..
        jsr     LDBAC                           ; DB98 20 AC DB                  ..
        dec     $F5                             ; DB9B C6 F5                    ..
        bpl     LDB7C                           ; DB9D 10 DD                    ..
        pla                                     ; DB9F 68                       h
        pla                                     ; DBA0 68                       h
        clc                                     ; DBA1 18                       .
        adc     $FB                             ; DBA2 65 FB                    e.
        sta     $FB                             ; DBA4 85 FB                    ..
        pla                                     ; DBA6 68                       h
        sta     $F5                             ; DBA7 85 F5                    ..
        jmp     text_row_addresses              ; DBA9 4C 44 DB                 LD.

; ----------------------------------------------------------------------------
LDBAC:  sta     store_shifted_character+1       ; DBAC 8D BA DB                 ...
        ldy     #$27                            ; DBAF A0 27                    .'
LDBB1:  dex                                     ; DBB1 CA                       .
        bpl     LDBB6                           ; DBB2 10 02                    ..
        ldx     #$4F                            ; DBB4 A2 4F                    .O
LDBB6:  lda     $0200,x                         ; DBB6 BD 00 02                 ...
store_shifted_character:
        sta     ($00),y                         ; DBB9 91 00                    ..
        dey                                     ; DBBB 88                       .
        bpl     LDBB1                           ; DBBC 10 F3                    ..
        rts                                     ; DBBE 60                       `

; ----------------------------------------------------------------------------
LDBBF:  lda     $FA                             ; DBBF A5 FA                    ..
        lsr     a                               ; DBC1 4A                       J
        bcc     LDC02                           ; DBC2 90 3E                    .>
        lda     $F4                             ; DBC4 A5 F4                    ..
        cmp     #$14                            ; DBC6 C9 14                    ..
        bcs     LDBCD                           ; DBC8 B0 03                    ..
        jmp     LFFD8                           ; DBCA 4C D8 FF                 L..

; ----------------------------------------------------------------------------
LDBCD:  sec                                     ; DBCD 38                       8
        sbc     $FB                             ; DBCE E5 FB                    ..
        bmi     LDBDF                           ; DBD0 30 0D                    0.
        cmp     #$25                            ; DBD2 C9 25                    .%
        bcc     LDC02                           ; DBD4 90 2C                    .,
        ldy     $F4                             ; DBD6 A4 F4                    ..
        cpy     #$4D                            ; DBD8 C0 4D                    .M
        bcs     LDBE2                           ; DBDA B0 06                    ..
        sec                                     ; DBDC 38                       8
        sbc     #$24                            ; DBDD E9 24                    .$
LDBDF:  jmp     shift_text_columns              ; DBDF 4C 67 DB                 Lg.

; ----------------------------------------------------------------------------
LDBE2:  jmp     LFFD4                           ; DBE2 4C D4 FF                 L..

; ----------------------------------------------------------------------------
LDBE5:  pla                                     ; DBE5 68                       h
        sta     $BD                             ; DBE6 85 BD                    ..
        pla                                     ; DBE8 68                       h
        sta     $BE                             ; DBE9 85 BE                    ..
        pla                                     ; DBEB 68                       h
        pla                                     ; DBEC 68                       h
        pla                                     ; DBED 68                       h
        sta     $D8                             ; DBEE 85 D8                    ..
        pla                                     ; DBF0 68                       h
        sta     $D9                             ; DBF1 85 D9                    ..
        pla                                     ; DBF3 68                       h
        sta     $D6                             ; DBF4 85 D6                    ..
        pla                                     ; DBF6 68                       h
        sta     $D7                             ; DBF7 85 D7                    ..
        lda     $BE                             ; DBF9 A5 BE                    ..
        pha                                     ; DBFB 48                       H
        lda     $BD                             ; DBFC A5 BD                    ..
        pha                                     ; DBFE 48                       H
        lda     #$00                            ; DBFF A9 00                    ..
        tay                                     ; DC01 A8                       .
LDC02:  rts                                     ; DC02 60                       `

; ----------------------------------------------------------------------------
        jsr     LDBE5                           ; DC03 20 E5 DB                  ..
        sta     ($D8),y                         ; DC06 91 D8                    ..
        iny                                     ; DC08 C8                       .
        sta     ($D8),y                         ; DC09 91 D8                    ..
LDC0B:  ldx     #$00                            ; DC0B A2 00                    ..
        jmp     LFFBB                           ; DC0D 4C BB FF                 L..

; ----------------------------------------------------------------------------
        jsr     LDBE5                           ; DC10 20 E5 DB                  ..
        jsr     key_available                   ; DC13 20 C3 D9                  ..
        sta     ($D8),y                         ; DC16 91 D8                    ..
        beq     LDC28                           ; DC18 F0 0E                    ..
        ldy     $BF18                           ; DC1A AC 18 BF                 ...
        jsr     take_buffered_key               ; DC1D 20 B6 D9                  ..
        bmi     LDC24                           ; DC20 30 02                    0.
        lda     #$00                            ; DC22 A9 00                    ..
LDC24:  sty     $BF18                           ; DC24 8C 18 BF                 ...
        asl     a                               ; DC27 0A                       .
LDC28:  sta     status_shift_register           ; DC28 8D 3B DC                 .;.
        lda     #$00                            ; DC2B A9 00                    ..
        ldy     #$07                            ; DC2D A0 07                    ..
LDC2F:  sta     ($D8),y                         ; DC2F 91 D8                    ..
        lsr     a                               ; DC31 4A                       J
        asl     status_shift_register           ; DC32 0E 3B DC                 .;.
        rol     a                               ; DC35 2A                       *
        dey                                     ; DC36 88                       .
        bne     LDC2F                           ; DC37 D0 F6                    ..
        beq     LDC0B                           ; DC39 F0 D0                    ..
status_shift_register:
        .byte   $00                             ; DC3B 00                       .
; ----------------------------------------------------------------------------
        jsr     LDBE5                           ; DC3C 20 E5 DB                  ..
        ldy     #$07                            ; DC3F A0 07                    ..
LDC41:  sta     ($D8),y                         ; DC41 91 D8                    ..
        dey                                     ; DC43 88                       .
        bpl     LDC41                           ; DC44 10 FB                    ..
        ldy     #$03                            ; DC46 A0 03                    ..
        lda     #$01                            ; DC48 A9 01                    ..
        sta     ($D8),y                         ; DC4A 91 D8                    ..
        iny                                     ; DC4C C8                       .
        lda     #$10                            ; DC4D A9 10                    ..
        sta     ($D8),y                         ; DC4F 91 D8                    ..
        ldy     #$06                            ; DC51 A0 06                    ..
        lda     #$23                            ; DC53 A9 23                    .#
        sta     ($D8),y                         ; DC55 91 D8                    ..
        bne     LDC0B                           ; DC57 D0 B2                    ..
control_characters:
        .byte   $1B,$1E,$0D,$0A,$07,$1F,$1C,$08 ; DC59 1B 1E 0D 0A 07 1F 1C 08  ........
        .byte   $0C,$19,$0B,$1D,$12,$14,$05,$06 ; DC61 0C 19 0B 1D 12 14 05 06  ........
        .byte   $0E,$0F                         ; DC69 0E 0F                    ..
; ----------------------------------------------------------------------------
control_handlers:
        .addr   LDA3A                           ; DC6B 3A DA                    :.
        .addr   LDA3E                           ; DC6D 3E DA                    >.
        .addr   LDA42                           ; DC6F 42 DA                    B.
        .addr   LDA47                           ; DC71 47 DA                    G.
        .addr   LDA87                           ; DC73 87 DA                    ..
        .addr   LDA9A                           ; DC75 9A DA                    ..
        .addr   LDAF9                           ; DC77 F9 DA                    ..
        .addr   LDAA2                           ; DC79 A2 DA                    ..
        .addr   LDAA9                           ; DC7B A9 DA                    ..
        .addr   LDAC7                           ; DC7D C7 DA                    ..
        .addr   LDAAC                           ; DC7F AC DA                    ..
        .addr   LDAD0                           ; DC81 D0 DA                    ..
        .addr   LDADC                           ; DC83 DC DA                    ..
        .addr   LDAE6                           ; DC85 E6 DA                    ..
        .addr   LDAEC                           ; DC87 EC DA                    ..
        .addr   LDAED                           ; DC89 ED DA                    ..
        .addr   LDAF2                           ; DC8B F2 DA                    ..
        .addr   LDAF1                           ; DC8D F1 DA                    ..
; ----------------------------------------------------------------------------
write_slot_offset: .byte 0              ; $DC8F
current_halftrack: .byte 0              ; $DC90
        .byte 0                        ; $DC91: preserved, no direct reference found
address_retries: .byte 0                ; $DC92
sector_retries: .byte 0                 ; $DC93
seek_retries: .byte 0                   ; $DC94
; Original zero-filled remainder; not decoded as BRK instructions.
preserved_zero_tail:
        .res $036B, 0                  ; $DC95-$DFFF
.assert * - native_io_start = $1000, error, "Native I/O bank size changed"
