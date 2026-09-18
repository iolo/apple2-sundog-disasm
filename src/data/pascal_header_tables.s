; Classified data only. Evidence: docs/pascal-header-tables.md
; The remaining 224 bytes of each header block are not included.
.segment "HEADER_TABLES"

disk1_header_84:
; Sixteen relative-block / byte-length pairs.
    .word 1, 8188 ; slot 0
    .word 0, 0 ; slot 1
    .word 0, 0 ; slot 2
    .word 0, 0 ; slot 3
    .word 0, 0 ; slot 4
    .word 0, 0 ; slot 5
    .word 0, 0 ; slot 6
    .word 0, 0 ; slot 7
    .word 0, 0 ; slot 8
    .word 0, 0 ; slot 9
    .word 0, 0 ; slot 10
    .word 0, 0 ; slot 11
    .word 0, 0 ; slot 12
    .word 0, 0 ; slot 13
    .word 0, 0 ; slot 14
    .word 0, 0 ; slot 15
.assert * - disk1_header_84 = $40, error, "Extent table size"
; Sixteen eight-byte names; stripped names retain their zero bytes.
    .byte $55,$54,$49,$4C,$49,$54,$59,$20 ; slot 0
    .byte $20,$20,$20,$20,$20,$20,$20,$20 ; slot 1
    .byte $20,$20,$20,$20,$20,$20,$20,$20 ; slot 2
    .byte $20,$20,$20,$20,$20,$20,$20,$20 ; slot 3
    .byte $20,$20,$20,$20,$20,$20,$20,$20 ; slot 4
    .byte $20,$20,$20,$20,$20,$20,$20,$20 ; slot 5
    .byte $20,$20,$20,$20,$20,$20,$20,$20 ; slot 6
    .byte $20,$20,$20,$20,$20,$20,$20,$20 ; slot 7
    .byte $20,$20,$20,$20,$20,$20,$20,$20 ; slot 8
    .byte $20,$20,$20,$20,$20,$20,$20,$20 ; slot 9
    .byte $20,$20,$20,$20,$20,$20,$20,$20 ; slot 10
    .byte $20,$20,$20,$20,$20,$20,$20,$20 ; slot 11
    .byte $20,$20,$20,$20,$20,$20,$20,$20 ; slot 12
    .byte $20,$20,$20,$20,$20,$20,$20,$20 ; slot 13
    .byte $20,$20,$20,$20,$20,$20,$20,$20 ; slot 14
    .byte $20,$20,$20,$20,$20,$20,$20,$20 ; slot 15
.assert * - disk1_header_84 = $C0, error, "Table offset"
; Segment kinds
    .word $0000 ; slot 0
    .word $0000 ; slot 1
    .word $0000 ; slot 2
    .word $0000 ; slot 3
    .word $0000 ; slot 4
    .word $0000 ; slot 5
    .word $0000 ; slot 6
    .word $0000 ; slot 7
    .word $0000 ; slot 8
    .word $0000 ; slot 9
    .word $0000 ; slot 10
    .word $0000 ; slot 11
    .word $0000 ; slot 12
    .word $0000 ; slot 13
    .word $0000 ; slot 14
    .word $0000 ; slot 15
.assert * - disk1_header_84 = $E0, error, "Table offset"
; Text-block pointers
    .word $0000 ; slot 0
    .word $0000 ; slot 1
    .word $0000 ; slot 2
    .word $0000 ; slot 3
    .word $0000 ; slot 4
    .word $0000 ; slot 5
    .word $0000 ; slot 6
    .word $0000 ; slot 7
    .word $0000 ; slot 8
    .word $0000 ; slot 9
    .word $0000 ; slot 10
    .word $0000 ; slot 11
    .word $0000 ; slot 12
    .word $0000 ; slot 13
    .word $0000 ; slot 14
    .word $0000 ; slot 15
.assert * - disk1_header_84 = $100, error, "Table offset"
; Packed segment / machine / version words
    .word $A201 ; slot 0, segment 1, machine 2, version 5
    .word $A200 ; slot 1, segment 0, machine 2, version 5
    .word $A200 ; slot 2, segment 0, machine 2, version 5
    .word $A200 ; slot 3, segment 0, machine 2, version 5
    .word $A200 ; slot 4, segment 0, machine 2, version 5
    .word $A200 ; slot 5, segment 0, machine 2, version 5
    .word $A200 ; slot 6, segment 0, machine 2, version 5
    .word $A200 ; slot 7, segment 0, machine 2, version 5
    .word $A200 ; slot 8, segment 0, machine 2, version 5
    .word $A200 ; slot 9, segment 0, machine 2, version 5
    .word $A200 ; slot 10, segment 0, machine 2, version 5
    .word $A200 ; slot 11, segment 0, machine 2, version 5
    .word $A200 ; slot 12, segment 0, machine 2, version 5
    .word $A200 ; slot 13, segment 0, machine 2, version 5
    .word $A200 ; slot 14, segment 0, machine 2, version 5
    .word $A200 ; slot 15, segment 0, machine 2, version 5
.assert * - disk1_header_84 = $120, error, "Header table size"

disk1_header_85:
; Sixteen relative-block / byte-length pairs.
    .word 1, 8644 ; slot 0
    .word 0, 0 ; slot 1
    .word 0, 0 ; slot 2
    .word 0, 0 ; slot 3
    .word 0, 0 ; slot 4
    .word 0, 0 ; slot 5
    .word 0, 0 ; slot 6
    .word 0, 0 ; slot 7
    .word 0, 0 ; slot 8
    .word 0, 0 ; slot 9
    .word 0, 0 ; slot 10
    .word 0, 0 ; slot 11
    .word 0, 0 ; slot 12
    .word 0, 0 ; slot 13
    .word 0, 0 ; slot 14
    .word 0, 0 ; slot 15
.assert * - disk1_header_85 = $40, error, "Extent table size"
; Sixteen eight-byte names; stripped names retain their zero bytes.
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 0
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 1
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 2
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 3
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 4
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 5
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 6
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 7
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 8
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 9
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 10
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 11
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 12
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 13
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 14
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 15
.assert * - disk1_header_85 = $C0, error, "Table offset"
; Segment kinds
    .word $0000 ; slot 0
    .word $0000 ; slot 1
    .word $0000 ; slot 2
    .word $0000 ; slot 3
    .word $0000 ; slot 4
    .word $0000 ; slot 5
    .word $0000 ; slot 6
    .word $0000 ; slot 7
    .word $0000 ; slot 8
    .word $0000 ; slot 9
    .word $0000 ; slot 10
    .word $0000 ; slot 11
    .word $0000 ; slot 12
    .word $0000 ; slot 13
    .word $0000 ; slot 14
    .word $0000 ; slot 15
.assert * - disk1_header_85 = $E0, error, "Table offset"
; Text-block pointers
    .word $0000 ; slot 0
    .word $0000 ; slot 1
    .word $0000 ; slot 2
    .word $0000 ; slot 3
    .word $0000 ; slot 4
    .word $0000 ; slot 5
    .word $0000 ; slot 6
    .word $0000 ; slot 7
    .word $0000 ; slot 8
    .word $0000 ; slot 9
    .word $0000 ; slot 10
    .word $0000 ; slot 11
    .word $0000 ; slot 12
    .word $0000 ; slot 13
    .word $0000 ; slot 14
    .word $0000 ; slot 15
.assert * - disk1_header_85 = $100, error, "Table offset"
; Packed segment / machine / version words
    .word $A201 ; slot 0, segment 1, machine 2, version 5
    .word $A200 ; slot 1, segment 0, machine 2, version 5
    .word $A200 ; slot 2, segment 0, machine 2, version 5
    .word $A200 ; slot 3, segment 0, machine 2, version 5
    .word $A200 ; slot 4, segment 0, machine 2, version 5
    .word $A200 ; slot 5, segment 0, machine 2, version 5
    .word $A200 ; slot 6, segment 0, machine 2, version 5
    .word $A200 ; slot 7, segment 0, machine 2, version 5
    .word $A200 ; slot 8, segment 0, machine 2, version 5
    .word $A200 ; slot 9, segment 0, machine 2, version 5
    .word $A200 ; slot 10, segment 0, machine 2, version 5
    .word $A200 ; slot 11, segment 0, machine 2, version 5
    .word $A200 ; slot 12, segment 0, machine 2, version 5
    .word $A200 ; slot 13, segment 0, machine 2, version 5
    .word $A200 ; slot 14, segment 0, machine 2, version 5
    .word $A200 ; slot 15, segment 0, machine 2, version 5
.assert * - disk1_header_85 = $120, error, "Header table size"

disk1_header_103:
; Sixteen relative-block / byte-length pairs.
    .word 0, 0 ; slot 0
    .word 1, 6126 ; slot 1
    .word 13, 606 ; slot 2
    .word 15, 4306 ; slot 3
    .word 24, 958 ; slot 4
    .word 26, 3058 ; slot 5
    .word 32, 1616 ; slot 6
    .word 36, 328 ; slot 7
    .word 0, 760 ; slot 8
    .word 0, 342 ; slot 9
    .word 0, 152 ; slot 10
    .word 0, 0 ; slot 11
    .word 0, 0 ; slot 12
    .word 0, 0 ; slot 13
    .word 0, 0 ; slot 14
    .word 0, 0 ; slot 15
.assert * - disk1_header_103 = $40, error, "Extent table size"
; Sixteen eight-byte names; stripped names retain their zero bytes.
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 0
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 1
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 2
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 3
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 4
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 5
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 6
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 7
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 8
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 9
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 10
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 11
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 12
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 13
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 14
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 15
.assert * - disk1_header_103 = $C0, error, "Table offset"
; Segment kinds
    .word $0000 ; slot 0
    .word $0006 ; slot 1
    .word $0006 ; slot 2
    .word $0006 ; slot 3
    .word $0006 ; slot 4
    .word $0006 ; slot 5
    .word $0006 ; slot 6
    .word $0006 ; slot 7
    .word $0007 ; slot 8
    .word $0007 ; slot 9
    .word $0007 ; slot 10
    .word $0000 ; slot 11
    .word $0000 ; slot 12
    .word $0000 ; slot 13
    .word $0000 ; slot 14
    .word $0000 ; slot 15
.assert * - disk1_header_103 = $E0, error, "Table offset"
; Text-block pointers
    .word $0000 ; slot 0
    .word $0000 ; slot 1
    .word $0000 ; slot 2
    .word $0000 ; slot 3
    .word $0000 ; slot 4
    .word $0000 ; slot 5
    .word $0000 ; slot 6
    .word $0000 ; slot 7
    .word $0000 ; slot 8
    .word $0000 ; slot 9
    .word $0000 ; slot 10
    .word $0000 ; slot 11
    .word $0000 ; slot 12
    .word $0000 ; slot 13
    .word $0000 ; slot 14
    .word $0000 ; slot 15
.assert * - disk1_header_103 = $100, error, "Table offset"
; Packed segment / machine / version words
    .word $0000 ; slot 0
    .word $A716 ; slot 1, segment 22, machine 7, version 5
    .word $A717 ; slot 2, segment 23, machine 7, version 5
    .word $A718 ; slot 3, segment 24, machine 7, version 5
    .word $A219 ; slot 4, segment 25, machine 2, version 5
    .word $A71A ; slot 5, segment 26, machine 7, version 5
    .word $A21B ; slot 6, segment 27, machine 2, version 5
    .word $A21C ; slot 7, segment 28, machine 2, version 5
    .word $A21D ; slot 8, segment 29, machine 2, version 5
    .word $A21E ; slot 9, segment 30, machine 2, version 5
    .word $A21F ; slot 10, segment 31, machine 2, version 5
    .word $0000 ; slot 11
    .word $0000 ; slot 12
    .word $0000 ; slot 13
    .word $0000 ; slot 14
    .word $0000 ; slot 15
.assert * - disk1_header_103 = $120, error, "Header table size"

disk1_header_140:
; Sixteen relative-block / byte-length pairs.
    .word 1, 576 ; slot 0
    .word 3, 1868 ; slot 1
    .word 7, 3130 ; slot 2
    .word 0, 0 ; slot 3
    .word 0, 0 ; slot 4
    .word 0, 0 ; slot 5
    .word 34, 5546 ; slot 6
    .word 14, 10214 ; slot 7
    .word 45, 2544 ; slot 8
    .word 50, 2654 ; slot 9
    .word 56, 7446 ; slot 10
    .word 71, 3532 ; slot 11
    .word 78, 6280 ; slot 12
    .word 91, 5200 ; slot 13
    .word 102, 6836 ; slot 14
    .word 116, 8132 ; slot 15
.assert * - disk1_header_140 = $40, error, "Extent table size"
; Sixteen eight-byte names; stripped names retain their zero bytes.
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 0
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 1
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 2
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 3
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 4
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 5
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 6
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 7
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 8
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 9
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 10
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 11
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 12
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 13
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 14
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 15
.assert * - disk1_header_140 = $C0, error, "Table offset"
; Segment kinds
    .word $0000 ; slot 0
    .word $0000 ; slot 1
    .word $0000 ; slot 2
    .word $0000 ; slot 3
    .word $0000 ; slot 4
    .word $0000 ; slot 5
    .word $0000 ; slot 6
    .word $0000 ; slot 7
    .word $0000 ; slot 8
    .word $0000 ; slot 9
    .word $0000 ; slot 10
    .word $0000 ; slot 11
    .word $0000 ; slot 12
    .word $0000 ; slot 13
    .word $0000 ; slot 14
    .word $0000 ; slot 15
.assert * - disk1_header_140 = $E0, error, "Table offset"
; Text-block pointers
    .word $0000 ; slot 0
    .word $0000 ; slot 1
    .word $0000 ; slot 2
    .word $0000 ; slot 3
    .word $0000 ; slot 4
    .word $0000 ; slot 5
    .word $0000 ; slot 6
    .word $0000 ; slot 7
    .word $0000 ; slot 8
    .word $0000 ; slot 9
    .word $0000 ; slot 10
    .word $0000 ; slot 11
    .word $0000 ; slot 12
    .word $0000 ; slot 13
    .word $0000 ; slot 14
    .word $0000 ; slot 15
.assert * - disk1_header_140 = $100, error, "Table offset"
; Packed segment / machine / version words
    .word $A201 ; slot 0, segment 1, machine 2, version 5
    .word $A207 ; slot 1, segment 7, machine 2, version 5
    .word $A208 ; slot 2, segment 8, machine 2, version 5
    .word $0000 ; slot 3
    .word $0000 ; slot 4
    .word $0000 ; slot 5
    .word $A20C ; slot 6, segment 12, machine 2, version 5
    .word $A20D ; slot 7, segment 13, machine 2, version 5
    .word $A20E ; slot 8, segment 14, machine 2, version 5
    .word $A20F ; slot 9, segment 15, machine 2, version 5
    .word $A210 ; slot 10, segment 16, machine 2, version 5
    .word $A211 ; slot 11, segment 17, machine 2, version 5
    .word $A212 ; slot 12, segment 18, machine 2, version 5
    .word $A213 ; slot 13, segment 19, machine 2, version 5
    .word $A214 ; slot 14, segment 20, machine 2, version 5
    .word $A215 ; slot 15, segment 21, machine 2, version 5
.assert * - disk1_header_140 = $120, error, "Header table size"

disk1_header_157:
; Sixteen relative-block / byte-length pairs.
    .word 15, 880 ; slot 0
    .word 1, 764 ; slot 1
    .word 3, 3348 ; slot 2
    .word 10, 1212 ; slot 3
    .word 13, 950 ; slot 4
    .word 0, 0 ; slot 5
    .word 0, 0 ; slot 6
    .word 0, 0 ; slot 7
    .word 0, 0 ; slot 8
    .word 0, 0 ; slot 9
    .word 0, 0 ; slot 10
    .word 0, 0 ; slot 11
    .word 0, 0 ; slot 12
    .word 0, 0 ; slot 13
    .word 0, 0 ; slot 14
    .word 0, 0 ; slot 15
.assert * - disk1_header_157 = $40, error, "Extent table size"
; Sixteen eight-byte names; stripped names retain their zero bytes.
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 0
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 1
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 2
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 3
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 4
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 5
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 6
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 7
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 8
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 9
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 10
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 11
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 12
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 13
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 14
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 15
.assert * - disk1_header_157 = $C0, error, "Table offset"
; Segment kinds
    .word $0000 ; slot 0
    .word $0000 ; slot 1
    .word $0000 ; slot 2
    .word $0000 ; slot 3
    .word $0000 ; slot 4
    .word $0000 ; slot 5
    .word $0000 ; slot 6
    .word $0000 ; slot 7
    .word $0000 ; slot 8
    .word $0000 ; slot 9
    .word $0000 ; slot 10
    .word $0000 ; slot 11
    .word $0000 ; slot 12
    .word $0000 ; slot 13
    .word $0000 ; slot 14
    .word $0000 ; slot 15
.assert * - disk1_header_157 = $E0, error, "Table offset"
; Text-block pointers
    .word $0000 ; slot 0
    .word $0000 ; slot 1
    .word $0000 ; slot 2
    .word $0000 ; slot 3
    .word $0000 ; slot 4
    .word $0000 ; slot 5
    .word $0000 ; slot 6
    .word $0000 ; slot 7
    .word $0000 ; slot 8
    .word $0000 ; slot 9
    .word $0000 ; slot 10
    .word $0000 ; slot 11
    .word $0000 ; slot 12
    .word $0000 ; slot 13
    .word $0000 ; slot 14
    .word $0000 ; slot 15
.assert * - disk1_header_157 = $100, error, "Table offset"
; Packed segment / machine / version words
    .word $A701 ; slot 0, segment 1, machine 7, version 5
    .word $A207 ; slot 1, segment 7, machine 2, version 5
    .word $A208 ; slot 2, segment 8, machine 2, version 5
    .word $A209 ; slot 3, segment 9, machine 2, version 5
    .word $A20A ; slot 4, segment 10, machine 2, version 5
    .word $0000 ; slot 5
    .word $0000 ; slot 6
    .word $0000 ; slot 7
    .word $0000 ; slot 8
    .word $0000 ; slot 9
    .word $0000 ; slot 10
    .word $0000 ; slot 11
    .word $0000 ; slot 12
    .word $0000 ; slot 13
    .word $0000 ; slot 14
    .word $0000 ; slot 15
.assert * - disk1_header_157 = $120, error, "Header table size"

disk1_header_251:
; Sixteen relative-block / byte-length pairs.
    .word 1, 3124 ; slot 0
    .word 9, 20 ; slot 1
    .word 10, 808 ; slot 2
    .word 12, 20 ; slot 3
    .word 13, 1998 ; slot 4
    .word 17, 1670 ; slot 5
    .word 21, 3652 ; slot 6
    .word 0, 0 ; slot 7
    .word 0, 0 ; slot 8
    .word 0, 0 ; slot 9
    .word 0, 0 ; slot 10
    .word 0, 0 ; slot 11
    .word 0, 0 ; slot 12
    .word 0, 0 ; slot 13
    .word 0, 0 ; slot 14
    .word 8, 170 ; slot 15
.assert * - disk1_header_251 = $40, error, "Extent table size"
; Sixteen eight-byte names; stripped names retain their zero bytes.
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 0
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 1
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 2
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 3
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 4
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 5
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 6
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 7
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 8
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 9
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 10
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 11
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 12
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 13
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 14
    .byte $00,$00,$00,$00,$00,$00,$00,$00 ; slot 15
.assert * - disk1_header_251 = $C0, error, "Table offset"
; Segment kinds
    .word $0000 ; slot 0
    .word $0000 ; slot 1
    .word $0006 ; slot 2
    .word $0000 ; slot 3
    .word $0000 ; slot 4
    .word $0000 ; slot 5
    .word $0006 ; slot 6
    .word $0000 ; slot 7
    .word $0000 ; slot 8
    .word $0000 ; slot 9
    .word $0000 ; slot 10
    .word $0000 ; slot 11
    .word $0000 ; slot 12
    .word $0000 ; slot 13
    .word $0000 ; slot 14
    .word $0000 ; slot 15
.assert * - disk1_header_251 = $E0, error, "Table offset"
; Text-block pointers
    .word $0000 ; slot 0
    .word $0000 ; slot 1
    .word $0000 ; slot 2
    .word $0000 ; slot 3
    .word $0000 ; slot 4
    .word $0000 ; slot 5
    .word $0000 ; slot 6
    .word $0000 ; slot 7
    .word $0000 ; slot 8
    .word $0000 ; slot 9
    .word $0000 ; slot 10
    .word $0000 ; slot 11
    .word $0000 ; slot 12
    .word $0000 ; slot 13
    .word $0000 ; slot 14
    .word $0000 ; slot 15
.assert * - disk1_header_251 = $100, error, "Table offset"
; Packed segment / machine / version words
    .word $A200 ; slot 0, segment 0, machine 2, version 5
    .word $A201 ; slot 1, segment 1, machine 2, version 5
    .word $A202 ; slot 2, segment 2, machine 2, version 5
    .word $A203 ; slot 3, segment 3, machine 2, version 5
    .word $A204 ; slot 4, segment 4, machine 2, version 5
    .word $A205 ; slot 5, segment 5, machine 2, version 5
    .word $A206 ; slot 6, segment 6, machine 2, version 5
    .word $0000 ; slot 7
    .word $0000 ; slot 8
    .word $0000 ; slot 9
    .word $0000 ; slot 10
    .word $0000 ; slot 11
    .word $0000 ; slot 12
    .word $0000 ; slot 13
    .word $0000 ; slot 14
    .word $0000 ; slot 15
.assert * - disk1_header_251 = $120, error, "Header table size"
