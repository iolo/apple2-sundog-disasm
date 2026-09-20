; Reviewed contexts at the clipped edges of the retained utility variant.
; Evidence: docs/short-pcode-copies.md. Disk mappings select four changed bytes.
.include "encoding.inc"
.segment "PCODE"
fragment_start:
; Disk 1 block 151 bytes 56-65. The procedure entry is outside the retained area.
clipped_procedure_footer:
    .word 26, 8                ; local bytes, parameter bytes
    .word 8, 126               ; stored exit and entry backward displacements
    .byte 31, 2                ; variant procedure number and lexical level
; Disk 1 block 155 bytes 207-208, 252-253 and 289-290.
first_global_address:
    p_lao 11, 1
second_global_address:
    p_lao 11, 1
call_variant_procedure:
    p_cgp 42
.assert * - fragment_start = 16, error, "Variant edge contexts changed size"
