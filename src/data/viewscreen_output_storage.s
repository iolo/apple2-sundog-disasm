; Evidence: docs/native-output-storage.md
.segment "OUTPUT_STORAGE"
; After the complete native container, through output-buffer offset 1022.
    .res 79, 0
; Retained final byte at offset 1023, beyond the assembler's clear count.
    .byte $04
