; Apple Pascal version-5 encoding subset verified for the initial system
; procedure. Expand only after checking the shipped interpreter. This is not a
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
