; Evidence: docs/window-allocation-tail.md
.segment "WINDOW_TAIL"
; Allocation offsets 1920..1999: between bitmap and saved-position fields.
    .res 80, 0
; Allocation offsets 2002..2031: between saved positions and retained record.
    .res 30, 0
; Allocation offsets 2032..2047: retained Pascal IDENTIFIER record prefix.
retained_identifier_name:
    .byte "INFILE  "
retained_identifier_left_link:
    .word $484E
retained_identifier_right_link:
    .word $4822
retained_identifier_type:
    .word $4806
retained_identifier_next:
    .word $333C
