; Evidence: docs/encoded-retained-stubs.md
; disconnected-indirect-jump, stored bank offset $0357
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
    jmp ($1172)
.assert * - component_start = 3, error, "Retained slice size"
