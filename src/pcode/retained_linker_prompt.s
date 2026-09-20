; Clipped historical linker procedure 22: docs/retained-linker-code.md
.include "encoding.inc"
.segment "PCODE"
fragment_start:
; Complete donor instruction is LOD 3,3,1 at context offset 45.
; Its opcode is overwritten on these disks; only two operands survive.
    .byte 3                 ; LOD lexical level
    p_big 3, 1              ; LOD variable offset
    p_nop
    p_lsa 8
    .byte "Reading "
    p_sldc 0
.assert * - fragment_start = 14, error, "Linker prompt copy extent"
