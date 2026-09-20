; Evidence: docs/encoded-retained-stubs.md
; disconnected-indirect-jump, stored bank offset $035D
.setcpu "6502"
.segment "RAW_NATIVE"
component_start:
    jmp ($15DB)
.assert * - component_start = 3, error, "Retained slice size"
