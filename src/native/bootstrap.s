; Disk-1 bootstrap, CPU load address $0800, 768 bytes.
; Verified against the original disk and live load captures in docs/bootstrap.md.
; Generated disassembly was reviewed to separate instructions, tables, and padding.
; Do not optimize instruction encodings or replace disk bytes with runtime patches.

.setcpu "6502"
.segment "BOOTSTRAP"

component_entry   = $4000
disk_rom_continue = $C65C
rom_fbfd          = $FBFD
rom_fc24          = $FC24
runtime_vector    = $FFF8

boot_page_count:
    .byte 1                       ; Disk II ROM page count; changed in RAM only.
entry:
    cpx #$60                      ; Slot 6 is required.
    beq     load_continuation ; $0803
    jmp     slot_error ; $0805

load_continuation:
    lda     boot_page_count ; $0808
    cmp     #$04 ; $080B
    bcs     check_component ; $080D
    adc     #$02 ; $080F
    sta     boot_page_count ; $0811
    inc     $3D ; $0814
    jmp     disk_rom_continue ; $0816

; Compare the existing $4000 component with the marker area before reloading.

check_component:
    ldy     component_entry ; $0819

compare_component:
    lda     component_entry,y ; $081C
    cmp     component_marker,y ; $081F
    bne     initialize_video ; $0822
    dey ; $0824
    bne     compare_component ; $0825
    beq     load_interpreter ; $0827

; Cold-load path: clear the 8 KB high-resolution page at $2000.

initialize_video:
    dey ; $0829
    beq     select_hires ; $082A
    sta     $3F ; $082C
    lda     #$20 ; $082E
    sta     $3F ; $0830
    tax ; $0832
    lda     #$00 ; $0833
    sta     $3E ; $0835
    tay ; $0837

L0838:
    sta     ($3E),y ; $0838
    iny ; $083A
    bne     L0838 ; $083B
    inc     $3F ; $083D
    dex ; $083F
    bne     L0838 ; $0840

select_hires:
    lda     $C057 ; $0842
    lda     $C054 ; $0845
    lda     $C052 ; $0848
    lda     $C050 ; $084B

; Read blocks 201..218 to $4000, then call that component.
    lda     #$00 ; $084E
    sta     $0478 ; $0850
    lda     #$40 ; $0853
    sta     $3F ; $0855
    lda     #$24 ; $0857
    sta     $02 ; $0859
    lda     #$C9 ; $085B
    sta     $0F ; $085D
    lda     #$00 ; $085F
    jsr     read_blocks ; $0861
    jsr     component_entry ; $0864

; Enable bank-2 writes; load blocks 219..242 to $D000..$FFFF.

load_interpreter:
    lda     $C081 ; $0867
    lda     $C081 ; $086A
    lda     #$D0 ; $086D
    sta     $3F ; $086F
    lda     #$30 ; $0871
    sta     $02 ; $0873
    lda     #$DB ; $0875
    sta     $0F ; $0877
    lda     #$00 ; $0879
    jsr     read_blocks ; $087B

; Select bank 1; load blocks 243..250 to $D000..$DFFF.
    lda     $C089 ; $087E
    lda     #$D0 ; $0881
    sta     $3F ; $0883
    lda     #$10 ; $0885
    sta     $02 ; $0887
    clc ; $0889
    lda     #$DB ; $088A
    adc     #$18 ; $088C
    sta     $0F ; $088E
    lda     #$00 ; $0890
    adc     #$00 ; $0892
    jsr     read_blocks ; $0894

; Select bank-2 RAM reads and enter the vector at $FFF8.
    lda     $C080 ; $0897
    jmp     (runtime_vector) ; $089A

component_marker:
    .byte $00
slot_error_text:
    .byte "MUST BOOT FROM SLOT 6"

slot_error:
    lda     $C088,x ; $08B3
    lda     #$0A ; $08B6
    jsr     rom_fc24 ; $08B8
    ldx     #$00 ; $08BB

L08BD:
    lda     slot_error_text,x ; $08BD
    jsr     rom_fbfd ; $08C0
    inx ; $08C3
    cpx     #$15 ; $08C4
    bne     L08BD ; $08C6
    lda     $C051 ; $08C8
    lda     #$00 ; $08CB

halt:
    beq     halt ; $08CD

    .res $2E, $00                 ; Unreferenced zero padding through $08FC.
    .byte $EA, $EA                ; Preserved NOP padding at $08FD/$08FE.

; Reader inputs: A / $0F = block high/low, $02 = page count, $3F = destination page.

read_blocks:
    lsr     a ; $08FF
    php ; $0900
    lda     $0F ; $0901
    and     #$07 ; $0903
    asl     a ; $0905
    sta     $00 ; $0906
    lda     $0F ; $0908
    plp ; $090A
    ror     a ; $090B
    lsr     a ; $090C
    lsr     a ; $090D
    sta     $F0 ; $090E
    lda     #$00 ; $0910
    sta     $3E ; $0912
    jmp     select_sector ; $0914

next_page:
    ldx     $02 ; $0917
    beq     read_blocks_done ; $0919
    dec     $02 ; $091B
    inc     $3F ; $091D
    inc     $00 ; $091F
    lda     $00 ; $0921
    eor     #$10 ; $0923
    bne     select_sector ; $0925
    sta     $00 ; $0927
    inc     $F0 ; $0929

select_sector:
    ldy     $00 ; $092B
    lda     logical_to_physical,y ; $092D
    sta     $F1 ; $0930
    ldx     #$00 ; $0932
    cpx     $02 ; $0934
    beq     read_blocks_done ; $0936
    jsr     read_sector ; $0938
    bcc     next_page ; $093B

read_blocks_done:
    rts ; $093D

logical_to_physical:
    .byte 0,2,4,6,8,10,12,14,1,3,5,7,9,11,13,15

; Slot 6 reader. $F0 = track, $F1 = physical sector.

read_sector:
    ldx     #$60 ; $094E

seek_target:
    lda     $F0 ; $0950
    asl     a ; $0952
    asl     $0478 ; $0953
    jsr     seek_track ; $0956
    lsr     $0478 ; $0959

find_sector:
    jsr     read_address ; $095C
    bcs     find_sector ; $095F
    ldy     $2E ; $0961
    sty     $0478 ; $0963
    cpy     $F0 ; $0966
    bne     seek_target ; $0968
    lda     $2D ; $096A
    cmp     $F1 ; $096C
    bne     find_sector ; $096E
    jsr     read_data ; $0970
    bcs     find_sector ; $0973
    jsr     unpack_6and2 ; $0975
    clc ; $0978
    rts ; $0979

; Unpack the Disk II 6-and-2 data into the destination page.

unpack_6and2:
    ldy     #$00 ; $097A

L097C:
    ldx     #$56 ; $097C

L097E:
    dex ; $097E
    bmi     L097C ; $097F
    lda     $0200,y ; $0981
    lsr     $0300,x ; $0984
    rol     a ; $0987
    lsr     $0300,x ; $0988
    rol     a ; $098B
    sta     ($3E),y ; $098C
    iny ; $098E
    bne     L097E ; $098F
    rts ; $0991

; Locate data prologue D5 AA AD; decode with the ROM-generated table at $02D6,Y.

read_data:
    ldy     #$20 ; $0992

L0994:
    dey ; $0994
    beq     read_error ; $0995

L0997:
    lda     $C08C,x ; $0997
    bpl     L0997 ; $099A

L099C:
    eor     #$D5 ; $099C
    bne     L0994 ; $099E
    nop ; $09A0

L09A1:
    lda     $C08C,x ; $09A1
    bpl     L09A1 ; $09A4
    cmp     #$AA ; $09A6
    bne     L099C ; $09A8
    ldy     #$56 ; $09AA

L09AC:
    lda     $C08C,x ; $09AC
    bpl     L09AC ; $09AF
    cmp     #$AD ; $09B1
    bne     L099C ; $09B3
    lda     #$00 ; $09B5

L09B7:
    dey ; $09B7
    sty     $26 ; $09B8

L09BA:
    ldy     $C08C,x ; $09BA
    bpl     L09BA ; $09BD
    eor     $02D6,y ; $09BF
    ldy     $26 ; $09C2
    sta     $0300,y ; $09C4
    bne     L09B7 ; $09C7

L09C9:
    sty     $26 ; $09C9

L09CB:
    ldy     $C08C,x ; $09CB
    bpl     L09CB ; $09CE
    eor     $02D6,y ; $09D0
    ldy     $26 ; $09D3
    sta     $0200,y ; $09D5
    iny ; $09D8
    bne     L09C9 ; $09D9

L09DB:
    ldy     $C08C,x ; $09DB
    bpl     L09DB ; $09DE
    cmp     $02D6,y ; $09E0
    bne     read_error ; $09E3

L09E5:
    lda     $C08C,x ; $09E5
    bpl     L09E5 ; $09E8
    cmp     #$DE ; $09EA
    bne     read_error ; $09EC
    nop ; $09EE

L09EF:
    lda     $C08C,x ; $09EF
    bpl     L09EF ; $09F2
    cmp     #$AA ; $09F4
    beq     read_ok ; $09F6

read_error:
    sec ; $09F8
    rts ; $09F9

; Locate address prologue D5 AA 96 and verify its checksum/epilogue.

read_address:
    ldy     #$FC ; $09FA
    sty     $26 ; $09FC

L09FE:
    iny ; $09FE
    bne     L0A05 ; $09FF
    inc     $26 ; $0A01
    beq     read_error ; $0A03

L0A05:
    lda     $C08C,x ; $0A05
    bpl     L0A05 ; $0A08

L0A0A:
    cmp     #$D5 ; $0A0A
    bne     L09FE ; $0A0C
    nop ; $0A0E

L0A0F:
    lda     $C08C,x ; $0A0F
    bpl     L0A0F ; $0A12
    cmp     #$AA ; $0A14
    bne     L0A0A ; $0A16
    ldy     #$03 ; $0A18

L0A1A:
    lda     $C08C,x ; $0A1A
    bpl     L0A1A ; $0A1D
    cmp     #$96 ; $0A1F
    bne     L0A0A ; $0A21
    lda     #$00 ; $0A23

L0A25:
    sta     $27 ; $0A25

L0A27:
    lda     $C08C,x ; $0A27
    bpl     L0A27 ; $0A2A
    rol     a ; $0A2C
    sta     $26 ; $0A2D

L0A2F:
    lda     $C08C,x ; $0A2F
    bpl     L0A2F ; $0A32
    and     $26 ; $0A34
    sta     $2C,y ; $0A36
    eor     $27 ; $0A39
    dey ; $0A3B
    bpl     L0A25 ; $0A3C
    tay ; $0A3E
    bne     read_error ; $0A3F

L0A41:
    lda     $C08C,x ; $0A41
    bpl     L0A41 ; $0A44
    cmp     #$DE ; $0A46
    bne     read_error ; $0A48
    nop ; $0A4A

L0A4B:
    lda     $C08C,x ; $0A4B
    bpl     L0A4B ; $0A4E
    cmp     #$AA ; $0A50
    bne     read_error ; $0A52

read_ok:
    clc ; $0A54
    rts ; $0A55

; Seek using half-track phases and the recorded position at $0478.

seek_track:
    stx     $2B ; $0A56
    sta     $2A ; $0A58
    cmp     $0478 ; $0A5A
    beq     enable_phase ; $0A5D
    lda     #$00 ; $0A5F
    sta     $26 ; $0A61

L0A63:
    lda     $0478 ; $0A63
    sta     $27 ; $0A66
    sec ; $0A68
    sbc     $2A ; $0A69
    beq     L0AA4 ; $0A6B
    bcs     L0A76 ; $0A6D
    eor     #$FF ; $0A6F
    inc     $0478 ; $0A71
    bcc     L0A7B ; $0A74

L0A76:
    adc     #$FE ; $0A76
    dec     $0478 ; $0A78

L0A7B:
    cmp     $26 ; $0A7B
    bcc     L0A81 ; $0A7D
    lda     $26 ; $0A7F

L0A81:
    cmp     #$0C ; $0A81
    bcs     L0A86 ; $0A83
    tay ; $0A85

L0A86:
    jsr     enable_phase ; $0A86
    lda     phase_on_delays,y ; $0A89
    jsr     seek_delay ; $0A8C
    lda     $27 ; $0A8F
    and     #$03 ; $0A91
    asl     a ; $0A93
    ora     $2B ; $0A94
    tax ; $0A96
    lda     $C080,x ; $0A97
    lda     phase_off_delays,y ; $0A9A
    jsr     seek_delay ; $0A9D
    inc     $26 ; $0AA0
    bne     L0A63 ; $0AA2

L0AA4:
    jsr     seek_delay ; $0AA4

enable_phase:
    lda     $0478 ; $0AA7
    and     #$03 ; $0AAA
    asl     a ; $0AAC
    ora     $2B ; $0AAD
    tax ; $0AAF
    lda     $C081,x ; $0AB0
    ldx     $2B ; $0AB3
    rts ; $0AB5
    nop ; $0AB6

; Timing loop also advances the two-byte counter at $46/$47.

seek_delay:
    ldx     #$11 ; $0AB7

L0AB9:
    dex ; $0AB9
    bne     L0AB9 ; $0ABA
    inc     $46 ; $0ABC
    bne     L0AC2 ; $0ABE
    inc     $47 ; $0AC0

L0AC2:
    sec ; $0AC2
    sbc     #$01 ; $0AC3
    bne     seek_delay ; $0AC5
    rts ; $0AC7

phase_on_delays:
    .byte $01,$30,$28,$24,$20,$1E,$1D,$1C,$1C,$1C,$1C,$1C
phase_off_delays:
    .byte $70,$2C,$26,$22,$1F,$1E,$1D,$1C,$1C,$1C,$1C,$1C

; Unreferenced trailing bytes, preserved without claiming they are instructions.
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$E8,$02,$00,$00,$02,$00,$01,$01
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

.assert * - boot_page_count = $300, error, "Bootstrap size changed"
