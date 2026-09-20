; Evidence: docs/native-output-storage.md
; Logical fourth boot sector: output-buffer bytes 768..1023, not live bootstrap code.
.segment "OUTPUT_STORAGE"
    .res 255, 0
; Same uncleared final output-buffer byte as the title/viewscreen native containers.
    .byte $04
