; Retained text suffix and NUL fill, not executable Pascal source.
; Evidence and inference limits: docs/library-text-tail.md.
.segment "LIBRARY_TEXT_TAIL"
retained_text_suffix:
    .byte "an;", $0D
retained_text_fill:
    .res 14, 0
.assert * - retained_text_suffix = 18, error, "Library text tail extent"
