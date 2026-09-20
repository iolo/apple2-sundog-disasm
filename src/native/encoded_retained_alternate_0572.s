; Evidence: docs/encoded-retained-stubs.md
; retained-jump-vector, stored bank offset $0572
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
    .word $135D
.assert * - component_start = 2, error, "Retained slice size"
