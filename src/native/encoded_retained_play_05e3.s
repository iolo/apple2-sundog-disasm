; Evidence: docs/encoded-retained-stubs.md
; retained-track-sequence-address, stored bank offset $05E3
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
    .word $0F52
.assert * - component_start = 2, error, "Retained slice size"
