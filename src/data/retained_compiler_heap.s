; Classified compiler heap data: docs/retained-compiler-heap.md
.segment "COMPILER_HEAP"
snapshot:
heap_0034:
; Memory $2574: clipped-parameter-variable-fields
; Only surviving record fields; missing fields are excluded.
    .byte $0B,$A5,$8E,$D0
heap_0038:
; Memory $2578: standard-identifier
; NAME, LLINK, RLINK, IDTYPE, NEXT, KLASS, PFDECKIND, CSPNUM
    .byte "ROUND   "
    .word $0000,$0000,$1F0A,$2562,$0006,$0000,$0018
heap_004e:
; Memory $258E: standard-parameter
; Uninitialized NAME, LLINK and RLINK; retained earlier memory contents.
    .byte $90,$22,$D0,$24,$A5,$80,$C5,$86,$90,$1A,$D0,$1C
; IDTYPE, NEXT, KLASS
    .word $25A4,$0000,$0002
; Uninitialized VLEV and VADDR storage.
    .byte $D0,$14,$A5,$82
heap_0064:
; Memory $25A4: pointer-type
; SIZE (words), FORM (POINTER), ELTYPE (nil)
    .word $0001,$0002,$0000
heap_006a:
; Memory $25AA: standard-identifier
; NAME, LLINK, RLINK, IDTYPE, NEXT, KLASS, PFDECKIND, CSPNUM
    .byte "MARK    "
    .word $2F5A,$3A26,$1F0A,$258E,$0005,$0000,$0020
heap_0080:
; Memory $25C0: standard-identifier
; NAME, LLINK, RLINK, IDTYPE, NEXT, KLASS, PFDECKIND, CSPNUM
    .byte "RELEASE "
    .word $0000,$0000,$1F0A,$258E,$0005,$0000,$0021
heap_0096:
; Memory $25D6: standard-identifier
; NAME, LLINK, RLINK, IDTYPE, NEXT, KLASS, PFDECKIND, CSPNUM
    .byte "IORESULT"
    .word $30B4,$4C4E,$1F0A,$0000,$0006,$0000,$0022
heap_00ac:
; Memory $25EC: standard-parameter
; Uninitialized NAME, LLINK and RLINK; retained earlier memory contents.
    .byte $E9,$4C,$8D,$D2,$A5,$85,$D0,$08,$A2,$7E,$20,$2F
; IDTYPE, NEXT, KLASS
    .word $1F0A,$0000,$0003
; Uninitialized VLEV and VADDR storage.
    .byte $45,$84,$D0,$0F
heap_00c2:
; Memory $2602: standard-identifier
; NAME, LLINK, RLINK, IDTYPE, NEXT, KLASS, PFDECKIND, CSPNUM
    .byte "UNITBUSY"
    .word $2644,$3B02,$1F20,$25EC,$0006,$0000,$0023
heap_00d8:
; Memory $2618: standard-identifier
; NAME, LLINK, RLINK, IDTYPE, NEXT, KLASS, PFDECKIND, CSPNUM
    .byte "PWROFTEN"
    .word $0000,$5BCE,$1F10,$25EC,$0006,$0000,$0024
heap_00ee:
; Memory $262E: standard-identifier
; NAME, LLINK, RLINK, IDTYPE, NEXT, KLASS, PFDECKIND, CSPNUM
    .byte "UNITWAIT"
    .word $0000,$0000,$0000,$25EC,$0005,$0000,$0025
heap_0104:
; Memory $2644: standard-identifier
; NAME, LLINK, RLINK, IDTYPE, NEXT, KLASS, PFDECKIND, CSPNUM
    .byte "UNITCLEA"
    .word $32A8,$0000,$0000,$25EC,$0005,$0000,$0026
heap_011a:
; Memory $265A: standard-identifier
; NAME, LLINK, RLINK, IDTYPE, NEXT, KLASS, PFDECKIND, CSPNUM
    .byte "HALT    "
    .word $3078,$33DE,$0000,$0000,$0005,$0000,$0027
heap_0130:
; Memory $2670: standard-identifier
; NAME, LLINK, RLINK, IDTYPE, NEXT, KLASS, PFDECKIND, CSPNUM
    .byte "MEMAVAIL"
    .word $2F32,$2F46,$1F0A,$0000,$0006,$0000,$0028
heap_0146:
; Memory $2686: standard-parameter
; Uninitialized NAME, LLINK and RLINK; retained earlier memory contents.
    .byte $09,$A9,$00,$48,$48,$48,$48,$4C,$8D,$D2,$A5,$7E
; IDTYPE, NEXT, KLASS
    .word $1F3A,$269C,$0002
; Uninitialized VLEV and VADDR storage.
    .byte $38,$E5,$7F,$90
heap_015c:
; Memory $269C: standard-parameter
; Uninitialized NAME, LLINK and RLINK; retained earlier memory contents.
    .byte $0B,$18,$69,$7F,$B0,$0C,$C9,$FF,$F0,$08,$90,$09
; IDTYPE, NEXT, KLASS
    .word $1F0A,$0000,$0003
; Uninitialized VLEV and VADDR storage.
    .byte $4C,$F3,$D1,$85
heap_0172:
; Memory $26B2: standard-identifier
; NAME, LLINK, RLINK, IDTYPE, NEXT, KLASS, PFDECKIND, CSPNUM
    .byte "STRTONUM"
    .word $0000,$0000,$1F10,$2686,$0006,$0000,$0029
heap_0188:
; Memory $26C8: standard-parameter
; Uninitialized NAME, LLINK and RLINK; retained earlier memory contents.
    .byte $86,$E5,$80,$90,$0D,$85,$86,$84,$87,$A5,$90,$85
; IDTYPE, NEXT, KLASS
    .word $1F10,$26DE,$0003
; Uninitialized VLEV and VADDR storage.
    .byte $26,$8F,$26,$8E
heap_019e:
; Memory $26DE: standard-parameter
; Uninitialized NAME, LLINK and RLINK; retained earlier memory contents.
    .byte $26,$8D,$26,$8C,$46,$80,$66,$81,$66,$82,$66,$83
; IDTYPE, NEXT, KLASS
    .word $1F20,$26F4,$0003
; Uninitialized VLEV and VADDR storage.
    .byte $20,$92,$E9,$20
heap_01b4:
; Memory $26F4: standard-parameter
; Uninitialized NAME, LLINK and RLINK; retained earlier memory contents.
    .byte $52,$E9,$A2,$8A,$20,$2F,$E9,$4C,$8D,$D2,$A5,$7E
; IDTYPE, NEXT, KLASS
    .word $1F0A,$270A,$0003
; Uninitialized VLEV and VADDR storage.
    .byte $38,$E9,$7F,$85
heap_01ca:
; Memory $270A: standard-parameter
; Uninitialized NAME, LLINK and RLINK; retained earlier memory contents.
    .byte $7F,$A5,$85,$38,$E9,$7F,$B8,$18,$65,$7F,$50,$05
; IDTYPE, NEXT, KLASS
    .word $1F3A,$2720,$0002
; Uninitialized VLEV and VADDR storage.
    .byte $69,$7F,$F0,$F6
heap_01e0:
; Memory $2720: standard-parameter
; Uninitialized NAME, LLINK and RLINK; retained earlier memory contents.
    .byte $C9,$FF,$F0,$F2,$85,$8B,$A9,$00,$85,$8C,$85,$8D
; IDTYPE, NEXT, KLASS
    .word $1F0A,$0000,$0002
; Uninitialized VLEV and VADDR storage.
    .byte $46,$80,$66,$81
heap_01f6:
; Memory $2736: clipped-identifier
; Only surviving record fields; missing fields are excluded.
    .byte $4E,$55,$4D,$54,$4F,$53,$54,$52,$00,$00
.assert * - snapshot = 460, error, "Compiler heap extent"
