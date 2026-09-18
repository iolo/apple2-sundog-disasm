; Apple Pascal version-5 encoding subset verified for the initial system
; procedure and startup segment. Expand only after checking the interpreter.
; This is not a
; complete UCSD assembler. p_ prefixes avoid collisions with 6502 mnemonics.

.macro p_big value, width
    .assert value >= 0 .and value <= $7FFF, error, "Big operand out of range"
    .if width = 1
        .assert value < $80, error, "Big operand does not fit one byte"
        .byte value
    .elseif width = 2
        ; Keep explicit width: a non-minimal original encoding must not shrink.
        .byte $80 | (value >> 8), value & $FF
    .else
        .error "Big operand width must be 1 or 2"
    .endif
.endmacro

.macro p_sldc value
    .assert value >= 0 .and value < $80, error, "Short constant out of range"
    .byte value
.endmacro

.macro p_ldcn
    .byte $9F
.endmacro

.macro p_stl local_word, width
    .byte $CC
    p_big local_word, width
.endmacro

.macro p_csp number
    .byte $9E, number
.endmacro

.macro p_cxp segment_number, procedure_number
    .byte $CD, segment_number, procedure_number
.endmacro

.macro p_cbp procedure_number
    .byte $C2, procedure_number
.endmacro

.macro p_sldl local_word
    .assert local_word >= 1 .and local_word <= 16, error, "Short local out of range"
    .byte $D7 + local_word
.endmacro

.macro p_neqi
    .byte $CB
.endmacro

.macro p_fjp_direct target
    .byte $A1
    .assert target - (* + 1) >= 0 .and target - (* + 1) < $80, lderror, "Forward jump out of range"
    .byte target - (* + 1)
.endmacro

.macro p_fjp_table table_word, attributes
    .byte $A1
    .assert table_word - attributes >= -128 .and table_word - attributes < 0, lderror, "Jump table selector out of range"
    .byte (table_word - attributes) & $FF
.endmacro

.macro p_xit
    .byte $D6
.endmacro

; Additional encodings verified against the shipped native handlers for startup.

; $8D: native handler $D5C2.
.macro p_lor
    .byte $8D
.endmacro

; $95: native handler $D747.
.macro p_sbi
    .byte $95
.endmacro

; $9D: native handler $D442.
.macro p_lde level_or_segment, value, width
    .byte $9D
    .assert level_or_segment >= 0 .and level_or_segment <= 255, error, "Byte operand out of range"
    .byte level_or_segment
    p_big value, width
.endmacro

; $A7: native handler $D48C.
.macro p_lae level_or_segment, value, width
    .byte $A7
    .assert level_or_segment >= 0 .and level_or_segment <= 255, error, "Byte operand out of range"
    .byte level_or_segment
    p_big value, width
.endmacro

; $AD: native handler $E371.
.macro p_rnp value
    .byte $AD
    .assert value >= 0 .and value <= 255, error, "Byte operand out of range"
    .byte value
.endmacro

; $B2: native handler $D3EE.
.macro p_lda level_or_segment, value, width
    .byte $B2
    .assert level_or_segment >= 0 .and level_or_segment <= 255, error, "Byte operand out of range"
    .byte level_or_segment
    p_big value, width
.endmacro

; $B6: native handler $D3C8.
.macro p_lod level_or_segment, value, width
    .byte $B6
    .assert level_or_segment >= 0 .and level_or_segment <= 255, error, "Byte operand out of range"
    .byte level_or_segment
    p_big value, width
.endmacro

; $BA: native handler $DA60.
.macro p_ldp
    .byte $BA
.endmacro

; $BB: native handler $DAB6.
.macro p_stp
    .byte $BB
.endmacro

; $BE: native handler $D567.
.macro p_ldb
    .byte $BE
.endmacro

; $C0: native handler $DA1D.
.macro p_ixp first, second
    .byte $C0
    .assert first >= 0 .and first <= 255 .and second >= 0 .and second <= 255, error, "Byte operand out of range"
    .byte first, second
.endmacro

; $C1: native handler $E35C.
.macro p_rbp value
    .byte $C1
    .assert value >= 0 .and value <= 255, error, "Byte operand out of range"
    .byte value
.endmacro

; $C3: native handler $DFA9.
.macro p_equi
    .byte $C3
.endmacro

; $C4: native handler $DF7B.
.macro p_geqi
    .byte $C4
.endmacro

; $C6: native handler $D315.
.macro p_lla value, width
    .byte $C6
    p_big value, width
.endmacro

; $C7: native handler $D2DE.
.macro p_ldci value
    .byte $C7
    .assert value >= -32768 .and value <= 65535, error, "Word operand out of range"
    .word value & $FFFF
.endmacro

; $C8: native handler $DF77.
.macro p_leqi
    .byte $C8
.endmacro

; $CE: native handler $E2D3.
.macro p_clp value
    .byte $CE
    .assert value >= 0 .and value <= 255, error, "Byte operand out of range"
    .byte value
.endmacro

; $CF: native handler $E2EF.
.macro p_cgp value
    .byte $CF
    .assert value >= 0 .and value <= 255, error, "Byte operand out of range"
    .byte value
.endmacro

; $D1: native handler $D467.
.macro p_ste level_or_segment, value, width
    .byte $D1
    .assert level_or_segment >= 0 .and level_or_segment <= 255, error, "Byte operand out of range"
    .byte level_or_segment
    p_big value, width
.endmacro

; $D7: native handler $D28D.
.macro p_nop
    .byte $D7
.endmacro

.macro p_ujp_direct target
    .byte $B9
    .assert target - (* + 1) >= 0 .and target - (* + 1) < $80, lderror, "Forward jump out of range"
    .byte target - (* + 1)
.endmacro

.macro p_ujp_table table_word, attributes
    .byte $B9
    .assert table_word - attributes >= -128 .and table_word - attributes < 0, lderror, "Jump table selector out of range"
    .byte (table_word - attributes) & $FF
.endmacro

; XJP forces its instruction pointer odd before reading aligned signed bounds.
; The following instruction is the two-byte default UJP, then case-pointer words.
.macro p_xjp lower, upper, padding_width, padding_byte
    .assert lower >= -32768 .and upper <= 32767 .and lower <= upper, error, "Case bounds out of range"
    .assert padding_width = 0 .or padding_width = 1, error, "Case padding width invalid"
    .byte $AC
    .if padding_width
        .byte padding_byte
    .endif
    .assert (* & 1) = 0, lderror, "Case bounds must be word aligned"
    .word lower & $FFFF, upper & $FFFF
.endmacro
