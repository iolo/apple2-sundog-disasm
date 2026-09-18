; SYSTEM.PASCAL segment 0, procedure 1. Disk 1 block 252, bytes 0..35.
; Runtime load address $F248 confirmed by docs/reference/runtime-init.json.
; This small source proves exact p-code reconstruction using ca65 macros.
; Calls retain segment/procedure numbers until their behavior is established.

.include "encoding.inc"
.segment "PCODE"

entry:
    p_ldcn
    p_stl 5, 1
    p_sldc 1
    p_csp 38
    p_cxp 4, 1

dispatch_loop:
    p_cbp 32
    p_sldl 5
    p_ldcn
    p_neqi
    p_fjp_direct repeat_test
    p_cxp 4, 1

repeat_test:
    p_sldc 0
    p_fjp_table loop_pointer, attributes
exit:
    p_xit
    .byte $00                      ; Preserved alignment byte after exit.

loop_pointer:
    .word * - dispatch_loop        ; Backwards pointer, selected by signed -10.
    .word 1068                     ; Local storage in bytes.
    .word 0                        ; Parameter storage in bytes.
    .word * - exit
    .word * - entry
attributes:
    .byte 1, $FF                   ; Procedure 1, lexical level -1.

.assert * - entry = 36, error, "System entry size changed"
