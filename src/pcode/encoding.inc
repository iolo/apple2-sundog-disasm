; Semantic procedure IDs and shared storage offsets; emits no bytes.
.include "identifier_names.inc"

; Apple Pascal version-5 encoding subset verified for the initial system
; procedures and reconstructed modules. Expand only after checking the interpreter.
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

; Historical Apple Pascal $8B: set membership, no inline operand.
; The shipped SunDog interpreter dispatches this opcode to its unsupported path.
.macro p_inn
    .byte $8B
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

; $80: native handler $D6FF.
.macro p_abi
    .byte $80
.endmacro

; $82: native handler $D71D.
.macro p_adi
    .byte $82
.endmacro

; $84: native handler $D5AF.
.macro p_land
    .byte $84
.endmacro

; $86: native handler $D87D.
.macro p_dvi
    .byte $86
.endmacro

; $88: native handler $D8C2.
.macro p_chk
    .byte $88
.endmacro

; $8E: native handler $D8AA.
.macro p_modi
    .byte $8E
.endmacro

; $8F: native handler $D786.
.macro p_mpi
    .byte $8F
.endmacro

; $91: native handler $D735.
.macro p_ngi
    .byte $91
.endmacro

; $93: native handler $D5D5.
.macro p_lnot
    .byte $93
.endmacro

; $98: native handler $D7CD.
.macro p_sqi
    .byte $98
.endmacro

; $9A: native handler $D4BC.
.macro p_sto
    .byte $9A
.endmacro

; $9B: native handler $D98C.
.macro p_ixs
    .byte $9B
.endmacro

; $A2: native handler $D9CB.
.macro p_inc value, width
    .byte $A2
    p_big value, width
.endmacro

; $A3: native handler $D9AF.
.macro p_ind value, width
    .byte $A3
    p_big value, width
.endmacro

; $A4: native handler $D9DE.
.macro p_ixa value, width
    .byte $A4
    p_big value, width
.endmacro

; $A5: native handler $D384.
.macro p_lao value, width
    .byte $A5
    p_big value, width
.endmacro

; $A6: native handler $D929.
.macro p_lsa length
    .assert length >= 0 .and length <= 255, error, "Inline length out of range"
    .byte $A6, length
.endmacro

; $A8: native handler $D59B.
.macro p_mov value, width
    .byte $A8
    p_big value, width
.endmacro

; $A9: native handler $D366.
.macro p_ldo value, width
    .byte $A9
    p_big value, width
.endmacro

; $AA: native handler $D94B.
.macro p_sas value
    .byte $AA
    .assert value >= 0 .and value <= 255, error, "Byte operand out of range"
    .byte value
.endmacro

; $AB: native handler $D3AA.
.macro p_sro value, width
    .byte $AB
    p_big value, width
.endmacro

; $AE: native handler $E285.
.macro p_cip value
    .byte $AE
    .assert value >= 0 .and value <= 255, error, "Byte operand out of range"
    .byte value
.endmacro

; $AF: native handler $DE2C.
.macro p_equ kind, length, width
    .assert kind = 2 .or kind = 4 .or kind = 6 .or kind = 8 .or kind = 10 .or kind = 12, error, "Unsupported comparison type"
    .byte $AF, kind
    .if kind = 10 .or kind = 12
        p_big length, width
    .endif
.endmacro

; $B0: native handler $DE24.
.macro p_geq kind, length, width
    .assert kind = 2 .or kind = 4 .or kind = 6 .or kind = 8 .or kind = 10 .or kind = 12, error, "Unsupported comparison type"
    .byte $B0, kind
    .if kind = 10 .or kind = 12
        p_big length, width
    .endif
.endmacro

; $B1: native handler $DE1C.
.macro p_grt kind, length, width
    .assert kind = 2 .or kind = 4 .or kind = 6 .or kind = 8 .or kind = 10 .or kind = 12, error, "Unsupported comparison type"
    .byte $B1, kind
    .if kind = 10 .or kind = 12
        p_big length, width
    .endif
.endmacro

; $B3: native handler $D4D6.
.macro p_ldc count, padding_width, padding_byte
    .assert count >= 1 .and count <= 126, error, "Unsupported constant-word count"
    .assert padding_width = 0 .or padding_width = 1, error, "Constant padding width invalid"
    .byte $B3, count
    .if padding_width
        .byte padding_byte
    .endif
    .assert (* & 1) = 0, lderror, "Constant words must be aligned"
.endmacro

; $B4: native handler $DE28.
.macro p_leq kind, length, width
    .assert kind = 2 .or kind = 4 .or kind = 6 .or kind = 8 .or kind = 10 .or kind = 12, error, "Unsupported comparison type"
    .byte $B4, kind
    .if kind = 10 .or kind = 12
        p_big length, width
    .endif
.endmacro

; $B5: native handler $DE20.
.macro p_les kind, length, width
    .assert kind = 2 .or kind = 4 .or kind = 6 .or kind = 8 .or kind = 10 .or kind = 12, error, "Unsupported comparison type"
    .byte $B5, kind
    .if kind = 10 .or kind = 12
        p_big length, width
    .endif
.endmacro

; $B7: native handler $DE18.
.macro p_neq kind, length, width
    .assert kind = 2 .or kind = 4 .or kind = 6 .or kind = 8 .or kind = 10 .or kind = 12, error, "Unsupported comparison type"
    .byte $B7, kind
    .if kind = 10 .or kind = 12
        p_big length, width
    .endif
.endmacro

; $B8: native handler $D41C.
.macro p_str level, value, width
    .byte $B8
    .assert level >= 0 .and level <= 255, error, "Byte operand out of range"
    .byte level
    p_big value, width
.endmacro

; $BC: native handler $D50A.
.macro p_ldm value
    .byte $BC
    .assert value >= 0 .and value <= 255, error, "Byte operand out of range"
    .byte value
.endmacro

; $BD: native handler $D539.
.macro p_stm value
    .byte $BD
    .assert value >= 0 .and value <= 255, error, "Byte operand out of range"
    .byte value
.endmacro

; $BF: native handler $D581.
.macro p_stb
    .byte $BF
.endmacro

; $C5: native handler $DF73.
.macro p_gtri
    .byte $C5
.endmacro

; $C9: native handler $DF6F.
.macro p_lesi
    .byte $C9
.endmacro

; $CA: native handler $D2F7.
.macro p_ldl value, width
    .byte $CA
    p_big value, width
.endmacro

; $D0: native handler $D911.
.macro p_lpa length
    .assert length >= 0 .and length <= 255, error, "Inline length out of range"
    .byte $D0, length
.endmacro

; $D5: native handler $E803.
.macro p_bpt value, width
    .byte $D5
    p_big value, width
.endmacro

.macro p_sldo value
    .assert value >= 1 .and value <= 16, error, "Short global out of range"
    .byte $E7 + value
.endmacro

.macro p_sind value
    .assert value >= 0 .and value <= 7, error, "Short indirect out of range"
    .byte $F8 + value
.endmacro
