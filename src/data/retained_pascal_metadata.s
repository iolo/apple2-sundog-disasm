; Classified data: docs/retained-pascal-metadata.md

.segment "RETAINED_METADATA"

directory_tail:
; Block +$05E: clipped-directory-date
    .word $A9F7
; Block +$060: directory-extent-and-type
    .word $00E5,$00E9,$0003
; Block +$066: directory-name-length
    .byte $0E
; Block +$067: directory-name-storage
; Retained name storage: 'MAINB.LIB.TEXT'
    .byte $4D,$41,$49,$4E,$42,$2E,$4C,$49,$42,$2E,$54,$45,$58,$54,$A5
; Block +$076: directory-size-and-date
    .word $0200,$A868
; Block +$07A: directory-extent-and-type
    .word $00E9,$00ED,$0003
; Block +$080: directory-name-length
    .byte $0D
; Block +$081: directory-name-storage
; Retained name storage: 'GRND.LIB.TEXT'
    .byte $47,$52,$4E,$44,$2E,$4C,$49,$42,$2E,$54,$45,$58,$54,$76,$A5
; Block +$090: directory-size-and-date
    .word $0200,$A868
; Block +$094: directory-extent-and-type
    .word $00ED,$00F1,$0003
; Block +$09A: directory-name-length
    .byte $0D
; Block +$09B: directory-name-storage
; Retained name storage: 'SHIP.LIB.TEXT'
    .byte $53,$48,$49,$50,$2E,$4C,$49,$42,$2E,$54,$45,$58,$54,$76,$A5
; Block +$0AA: directory-size-and-date
    .word $0200,$A868
; Block +$0AE: directory-extent-and-type
    .word $00FE,$0102,$0002
; Block +$0B4: directory-name-length
    .byte $0A
; Block +$0B5: directory-name-storage
; Retained name storage: 'DUMMY.CODE'
    .byte $44,$55,$4D,$4D,$59,$2E,$43,$4F,$44,$45,$0B,$00,$00,$A2,$B4
; Block +$0C4: directory-size-and-date
    .word $0200,$A868
; Block +$0C8: directory-extent-and-type
    .word $00FE,$0140,$A762
; Block +$0CE: directory-name-length
    .byte $00
; Block +$0CF: directory-name-storage
; Retained name storage: 'DUMMY.CODE'
    .byte $44,$55,$4D,$4D,$59,$2E,$43,$4F,$44,$45,$0B,$00,$00,$A2,$B4
; Block +$0DE: directory-size-and-date
    .word $0200,$C800
; Block +$0E2: directory-extent-and-type
    .word $00FD,$0101,$0003
; Block +$0E8: directory-name-length
    .byte $00
; Block +$0E9: directory-name-storage
; Retained name storage: 'SETPRINT.TEXT'
    .byte $53,$45,$54,$50,$52,$49,$4E,$54,$2E,$54,$45,$58,$54,$90,$B2
; Block +$0F8: directory-size-and-date
    .word $0200,$A735
; Block +$0FC: directory-extent-and-type
    .word $012D,$0140,$A763
; Block +$102: directory-name-length
    .byte $00
; Block +$103: directory-name-storage
; Retained name storage: 'SHIP.RDMAP.TEXT'
    .byte $53,$48,$49,$50,$2E,$52,$44,$4D,$41,$50,$2E,$54,$45,$58,$54
; Block +$112: directory-size-and-date
    .word $0200,$C800
; Block +$116: directory-extent-and-type
    .word $010F,$0112,$0005
; Block +$11C: directory-name-length
    .byte $00
; Block +$11D: directory-name-storage
; Retained name storage: 'CHAIN.LIBRARY'
    .byte $43,$48,$41,$49,$4E,$2E,$4C,$49,$42,$52,$41,$52,$59,$90,$B2
; Block +$12C: directory-size-and-date
    .word $0200,$A947
; Block +$130: directory-extent-and-type
    .word $0112,$0140,$A763
; Block +$136: directory-name-length
    .byte $00
; Block +$137: directory-name-storage
; Retained name storage: 'WCHAR.ASM.TEXT'
    .byte $57,$43,$48,$41,$52,$2E,$41,$53,$4D,$2E,$54,$45,$58,$54,$A5
; Block +$146: directory-size-and-date
    .word $0200,$C800
; Block +$14A: zero-directory-storage
    .res 182, 0
.assert * - directory_tail = 418, error, "Metadata fragment extent"

header_tail:
; Block +$0AA: clipped-header-name-storage
; Retained name storage: '                                  '
    .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
; Block +$0CC: segment-kind-words
    .word $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
; Block +$0EC: segment-text-address-words
    .word $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
; Block +$10C: segment-information-words
    .word $A200,$A201,$A203,$A204,$A205,$A200,$A200,$A200,$A200,$A200,$A200,$A200,$A200,$A200,$A200,$A200
; Block +$12C: intrinsic-segment-set
    .dword $00000044 ; segments 2 and 6
; Block +$130: zero-library-information
    .res 140, 0
; Block +$1BC: comment-length
    .byte $00
; Block +$1BD: zero-clipped-comment-storage
    .res 67, 0
.assert * - header_tail = 342, error, "Metadata fragment extent"
