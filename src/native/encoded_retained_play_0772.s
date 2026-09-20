; Evidence: docs/encoded-retained-stubs.md
; retained-jump-vector, stored bank offset $0772
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
    .word $0F5D
.assert * - component_start = 2, error, "Retained slice size"
