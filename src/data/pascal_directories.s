; Classified data. Evidence: docs/pascal-directories.md
.segment "DIRECTORIES"

directory_79:
    .word $0000, $0003, $0000 ; directory start/end blocks and type
    .byte $06 ; volume-name length
    .byte $53, $55, $4E, $44, $4F, $47, $00 ; fixed-width volume-name storage
    .word $0118, $0006, $0000, $A313 ; volume blocks, active-file count, access/set dates
    .byte $00, $00, $00, $0E ; reserved header bytes; byte 25 is read by initializer $6A02
directory_79_entry_1:
; Active file record
    .word $0003, $0055, $0005 ; first block, exclusive end block, file type
    .byte $0B ; name length
    .byte $53, $59, $53, $54, $45, $4D, $2E, $44, $41, $54, $41, $00, $00, $EA, $B2 ; fixed-width name storage, including residual bytes
    .word $0200, $A83A ; bytes in final block, modification date
.assert * - directory_79_entry_1 = 26, error, "Directory record size"
directory_79_entry_2:
; Active file record
    .word $0055, $0067, $0002 ; first block, exclusive end block, file type
    .byte $0E ; name length
    .byte $53, $55, $4E, $44, $4F, $47, $2E, $4C, $49, $42, $52, $41, $52, $59, $B2 ; fixed-width name storage, including residual bytes
    .word $0200, $A83A ; bytes in final block, modification date
.assert * - directory_79_entry_2 = 26, error, "Directory record size"
directory_79_entry_3:
; Active file record
    .word $0067, $008C, $0005 ; first block, exclusive end block, file type
    .byte $0E ; name length
    .byte $53, $59, $53, $54, $45, $4D, $2E, $4C, $49, $42, $52, $41, $52, $59, $B2 ; fixed-width name storage, including residual bytes
    .word $0200, $A8CA ; bytes in final block, modification date
.assert * - directory_79_entry_3 = 26, error, "Directory record size"
directory_79_entry_4:
; Active file record
    .word $008C, $00DB, $0002 ; first block, exclusive end block, file type
    .byte $0E ; name length
    .byte $53, $59, $53, $54, $45, $4D, $2E, $53, $54, $41, $52, $54, $55, $50, $60 ; fixed-width name storage, including residual bytes
    .word $0200, $A8CA ; bytes in final block, modification date
.assert * - directory_79_entry_4 = 26, error, "Directory record size"
directory_79_entry_5:
; Active file record
    .word $00DB, $00FB, $0005 ; first block, exclusive end block, file type
    .byte $0C ; name length
    .byte $53, $59, $53, $54, $45, $4D, $2E, $41, $50, $50, $4C, $45, $00, $56, $66 ; fixed-width name storage, including residual bytes
    .word $0200, $A79C ; bytes in final block, modification date
.assert * - directory_79_entry_5 = 26, error, "Directory record size"
directory_79_entry_6:
; Active file record
    .word $00FB, $0118, $0002 ; first block, exclusive end block, file type
    .byte $0D ; name length
    .byte $53, $59, $53, $54, $45, $4D, $2E, $50, $41, $53, $43, $41, $4C, $76, $67 ; fixed-width name storage, including residual bytes
    .word $0200, $A79C ; bytes in final block, modification date
.assert * - directory_79_entry_6 = 26, error, "Directory record size"
directory_79_spare:
    .res 330, 0 ; zero-filled unused record storage and block remainder
.assert * - directory_79 = 512, error, "Directory block size"

directory_80:
    .word $0000, $0003, $0000 ; directory start/end blocks and type
    .byte $06 ; volume-name length
    .byte $53, $55, $4E, $44, $4F, $47, $00 ; fixed-width volume-name storage
    .word $0118, $0006, $0000, $A313 ; volume blocks, active-file count, access/set dates
    .byte $00, $00, $00, $0E ; reserved header bytes; byte 25 is read by initializer $6A02
directory_80_entry_1:
; Active file record
    .word $0003, $0055, $0005 ; first block, exclusive end block, file type
    .byte $0B ; name length
    .byte $53, $59, $53, $54, $45, $4D, $2E, $44, $41, $54, $41, $00, $00, $EA, $B2 ; fixed-width name storage, including residual bytes
    .word $0200, $A83A ; bytes in final block, modification date
.assert * - directory_80_entry_1 = 26, error, "Directory record size"
directory_80_entry_2:
; Active file record
    .word $0055, $0067, $0002 ; first block, exclusive end block, file type
    .byte $0E ; name length
    .byte $53, $59, $53, $54, $45, $4D, $2E, $53, $54, $41, $52, $54, $55, $50, $B2 ; fixed-width name storage, including residual bytes
    .word $0200, $A8EA ; bytes in final block, modification date
.assert * - directory_80_entry_2 = 26, error, "Directory record size"
directory_80_entry_3:
; Active file record
    .word $0067, $008C, $0005 ; first block, exclusive end block, file type
    .byte $0E ; name length
    .byte $53, $59, $53, $54, $45, $4D, $2E, $4C, $49, $42, $52, $41, $52, $59, $B2 ; fixed-width name storage, including residual bytes
    .word $0200, $A8CA ; bytes in final block, modification date
.assert * - directory_80_entry_3 = 26, error, "Directory record size"
directory_80_entry_4:
; Active file record
    .word $008C, $00DB, $0005 ; first block, exclusive end block, file type
    .byte $0E ; name length
    .byte $53, $55, $4E, $44, $4F, $47, $2E, $4C, $49, $42, $52, $41, $52, $59, $B2 ; fixed-width name storage, including residual bytes
    .word $0200, $A8EA ; bytes in final block, modification date
.assert * - directory_80_entry_4 = 26, error, "Directory record size"
directory_80_entry_5:
; Active file record
    .word $00DB, $00FB, $0005 ; first block, exclusive end block, file type
    .byte $0C ; name length
    .byte $53, $59, $53, $54, $45, $4D, $2E, $41, $50, $50, $4C, $45, $00, $56, $66 ; fixed-width name storage, including residual bytes
    .word $0200, $A79C ; bytes in final block, modification date
.assert * - directory_80_entry_5 = 26, error, "Directory record size"
directory_80_entry_6:
; Active file record
    .word $00FB, $0118, $0002 ; first block, exclusive end block, file type
    .byte $0D ; name length
    .byte $53, $59, $53, $54, $45, $4D, $2E, $50, $41, $53, $43, $41, $4C, $76, $67 ; fixed-width name storage, including residual bytes
    .word $0200, $A79C ; bytes in final block, modification date
.assert * - directory_80_entry_6 = 26, error, "Directory record size"
directory_80_spare:
    .res 330, 0 ; zero-filled unused record storage and block remainder
.assert * - directory_80 = 512, error, "Directory block size"

directory_82:
    .word $0000, $0003, $0000 ; directory start/end blocks and type
    .byte $06 ; volume-name length
    .byte $53, $55, $4E, $44, $4F, $47, $00 ; fixed-width volume-name storage
    .word $0118, $0007, $0000, $A313 ; volume blocks, active-file count, access/set dates
    .byte $00, $00, $00, $0E ; reserved header bytes; byte 25 is read by initializer $6A02
directory_82_entry_1:
; Active file record
    .word $0003, $0067, $0005 ; first block, exclusive end block, file type
    .byte $0E ; name length
    .byte $53, $55, $4E, $44, $4F, $47, $2E, $4C, $49, $42, $52, $41, $52, $59, $B2 ; fixed-width name storage, including residual bytes
    .word $0200, $A8CA ; bytes in final block, modification date
.assert * - directory_82_entry_1 = 26, error, "Directory record size"
directory_82_entry_2:
; Active file record
    .word $0067, $008C, $0005 ; first block, exclusive end block, file type
    .byte $0E ; name length
    .byte $53, $59, $53, $54, $45, $4D, $2E, $4C, $49, $42, $52, $41, $52, $59, $B2 ; fixed-width name storage, including residual bytes
    .word $0200, $A8CA ; bytes in final block, modification date
.assert * - directory_82_entry_2 = 26, error, "Directory record size"
directory_82_entry_3:
; Active file record
    .word $008C, $009D, $0005 ; first block, exclusive end block, file type
    .byte $0C ; name length
    .byte $44, $45, $4D, $4F, $2E, $4C, $49, $42, $52, $41, $52, $59, $00, $EA, $B2 ; fixed-width name storage, including residual bytes
    .word $0200, $A8CA ; bytes in final block, modification date
.assert * - directory_82_entry_3 = 26, error, "Directory record size"
directory_82_entry_4:
; Active file record
    .word $009D, $00AE, $0002 ; first block, exclusive end block, file type
    .byte $0E ; name length
    .byte $53, $59, $53, $54, $45, $4D, $2E, $53, $54, $41, $52, $54, $55, $50, $B2 ; fixed-width name storage, including residual bytes
    .word $0200, $A90A ; bytes in final block, modification date
.assert * - directory_82_entry_4 = 26, error, "Directory record size"
directory_82_entry_5:
; Active file record
    .word $00AE, $00DB, $0005 ; first block, exclusive end block, file type
    .byte $09 ; name length
    .byte $44, $45, $4D, $4F, $2E, $44, $41, $54, $41, $8E, $89, $00, $00, $EA, $B2 ; fixed-width name storage, including residual bytes
    .word $0200, $A8CA ; bytes in final block, modification date
.assert * - directory_82_entry_5 = 26, error, "Directory record size"
directory_82_entry_6:
; Active file record
    .word $00DB, $00FB, $0005 ; first block, exclusive end block, file type
    .byte $0C ; name length
    .byte $53, $59, $53, $54, $45, $4D, $2E, $41, $50, $50, $4C, $45, $00, $56, $66 ; fixed-width name storage, including residual bytes
    .word $0200, $A79C ; bytes in final block, modification date
.assert * - directory_82_entry_6 = 26, error, "Directory record size"
directory_82_entry_7:
; Active file record
    .word $00FB, $0118, $0002 ; first block, exclusive end block, file type
    .byte $0D ; name length
    .byte $53, $59, $53, $54, $45, $4D, $2E, $50, $41, $53, $43, $41, $4C, $76, $67 ; fixed-width name storage, including residual bytes
    .word $0200, $A79C ; bytes in final block, modification date
.assert * - directory_82_entry_7 = 26, error, "Directory record size"
directory_82_entry_8:
; Inactive SYSTEM.PASCAL record: cleared name length
    .word $00FB, $0118, $0002 ; first block, exclusive end block, file type
    .byte $00 ; name length
    .byte $53, $59, $53, $54, $45, $4D, $2E, $50, $41, $53, $43, $41, $4C, $76, $67 ; fixed-width name storage, including residual bytes
    .word $0200, $A79C ; bytes in final block, modification date
.assert * - directory_82_entry_8 = 26, error, "Directory record size"
directory_82_entry_9:
; Inactive SYSTEM.PASCAL record: cleared name length
    .word $00FB, $0118, $0002 ; first block, exclusive end block, file type
    .byte $00 ; name length
    .byte $53, $59, $53, $54, $45, $4D, $2E, $50, $41, $53, $43, $41, $4C, $76, $67 ; fixed-width name storage, including residual bytes
    .word $0200, $A79C ; bytes in final block, modification date
.assert * - directory_82_entry_9 = 26, error, "Directory record size"
directory_82_entry_10:
; Inactive SYSTEM.PASCAL record: cleared name length
    .word $00FB, $0118, $0002 ; first block, exclusive end block, file type
    .byte $00 ; name length
    .byte $53, $59, $53, $54, $45, $4D, $2E, $50, $41, $53, $43, $41, $4C, $76, $67 ; fixed-width name storage, including residual bytes
    .word $0200, $A79C ; bytes in final block, modification date
.assert * - directory_82_entry_10 = 26, error, "Directory record size"
directory_82_spare:
    .res 226, 0 ; zero-filled unused record storage and block remainder
.assert * - directory_82 = 512, error, "Directory block size"
