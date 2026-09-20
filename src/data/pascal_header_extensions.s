; Classified header data. Evidence: docs/pascal-header-extensions.md
.segment "HEADER_EXTENSIONS"

header_extension_0:
; Header +$120: intrinsic-segment-set
    .dword $66400000 ; segments 22,25,26,29,30
; Header +$124: zero-library-storage
    .res 140, 0
; Header +$1B0: comment-length
    .byte 0
; Header +$1B1: zero-comment-storage
    .res 79, 0
.assert * - header_extension_0 = 224, error, "Header data slice size"

header_extension_1:
; Header +$120: intrinsic-segment-set
    .dword $00000000 ; segments none
; Header +$124: zero-library-storage
    .res 82, 0
.assert * - header_extension_1 = 86, error, "Header data slice size"

header_extension_2:
; Header +$1A2: prompt-length
    .byte 67
; Header +$1A3: prompt-text
; Command: E(dit, R(un, F(ile, C(omp, L(ink, X(ecute, A(ssem, ? [1.2]
    .byte $43,$6F,$6D,$6D,$61,$6E,$64,$3A,$20,$45,$28,$64,$69,$74,$2C,$20
    .byte $52,$28,$75,$6E,$2C,$20,$46,$28,$69,$6C,$65,$2C,$20,$43,$28,$6F
    .byte $6D,$70,$2C,$20,$4C,$28,$69,$6E,$6B,$2C,$20,$58,$28,$65,$63,$75
    .byte $74,$65,$2C,$20,$41,$28,$73,$73,$65,$6D,$2C,$20,$3F,$20,$5B,$31
    .byte $2E,$32,$5D
.assert * - header_extension_2 = 68, error, "Header data slice size"

header_extension_3:
; Header +$120: intrinsic-segment-set
    .dword $FFC00000 ; segments 22,23,24,25,26,27,28,29,30,31
; Header +$124: zero-library-storage
    .res 140, 0
; Header +$1B0: comment-length
    .byte 73
; Header +$1B1: comment-text
; Copyright (c) 1984 by FTL Games, Inc. All rights reserved. v2.0 14 Oct 84
    .byte $43,$6F,$70,$79,$72,$69,$67,$68,$74,$20,$28,$63,$29,$20,$31,$39
    .byte $38,$34,$20,$62,$79,$20,$46,$54,$4C,$20,$47,$61,$6D,$65,$73,$2C
    .byte $20,$49,$6E,$63,$2E,$20,$41,$6C,$6C,$20,$72,$69,$67,$68,$74,$73
    .byte $20,$72,$65,$73,$65,$72,$76,$65,$64,$2E,$20,$76,$32,$2E,$30,$20
    .byte $31,$34,$20,$4F,$63,$74,$20,$38,$34
; Header +$1FA: zero-comment-storage
    .res 6, 0
.assert * - header_extension_3 = 224, error, "Header data slice size"

header_extension_4:
; Header +$120: intrinsic-segment-set
    .dword $EEC00000 ; segments 22,23,25,26,27,29,30,31
; Header +$124: zero-library-storage
    .res 140, 0
; Header +$1B0: comment-length
    .byte 0
; Header +$1B1: zero-comment-storage
    .res 79, 0
.assert * - header_extension_4 = 224, error, "Header data slice size"

header_extension_5:
; Header +$120: intrinsic-segment-set
    .dword $00000044 ; segments 2,6
; Header +$124: zero-library-storage
    .res 140, 0
; Header +$1B0: comment-length
    .byte 65
; Header +$1B1: comment-text
; COPYRIGHT 1979,1980,1983 APPLE COMPUTER, INC. ALL RIGHTS RESERVED
    .byte $43,$4F,$50,$59,$52,$49,$47,$48,$54,$20,$31,$39,$37,$39,$2C,$31
    .byte $39,$38,$30,$2C,$31,$39,$38,$33,$20,$41,$50,$50,$4C,$45,$20,$43
    .byte $4F,$4D,$50,$55,$54,$45,$52,$2C,$20,$49,$4E,$43,$2E,$20,$41,$4C
    .byte $4C,$20,$52,$49,$47,$48,$54,$53,$20,$52,$45,$53,$45,$52,$56,$45
    .byte $44
; Header +$1F2: zero-comment-storage
    .res 14, 0
.assert * - header_extension_5 = 224, error, "Header data slice size"
