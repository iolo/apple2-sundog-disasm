; Evidence: docs/dialogue-scripts.md
.include "encoding.inc"
.segment "DIALOGUE"

; Disk 2 block 90; offsets below are bank-relative.
b90_offset_012 = $12
b90_offset_022 = $22
b90_offset_02a = $2A
b90_offset_038 = $38
b90_offset_041 = $41
b90_offset_050 = $50
b90_offset_058 = $58
b90_offset_064 = $64
b90_offset_06c = $6C
b90_offset_074 = $74
b90_offset_07a = $7A
b90_offset_083 = $83
b90_offset_08b = $8B
b90_offset_095 = $95
b90_offset_09a = $9A
b90_offset_09f = $9F
b90_text_0b8 = $0B8
b90_text_0be = $0BE
b90_text_0c4 = $0C4
b90_text_0cc = $0CC
b90_text_0d4 = $0D4
b90_text_0e0 = $0E0
b90_text_0ea = $0EA
b90_text_0fe = $0FE
b90_text_108 = $108
b90_text_118 = $118
b90_text_126 = $126
b90_text_134 = $134
b90_text_14a = $14A
b90_text_162 = $162
b90_text_17c = $17C
b90_text_18a = $18A
b90_text_19c = $19C
b90_text_1c0 = $1C0
b90_text_1cc = $1CC
b90_text_1e2 = $1E2
b90_text_1f8 = $1F8
; Entry table bytes 1–15; zero means no stored entry.
    d_entry b90_offset_022 ; slot 1
    d_entry b90_offset_02a ; slot 2
    d_entry b90_offset_038 ; slot 3
    d_entry b90_offset_041 ; slot 4
    d_entry b90_offset_050 ; slot 5
    d_entry b90_offset_058 ; slot 6
    d_entry b90_offset_064 ; slot 7
    d_entry b90_offset_06c ; slot 8
    d_entry b90_offset_074 ; slot 9
    d_entry b90_offset_07a ; slot 10
    d_entry b90_offset_083 ; slot 11
    d_entry b90_offset_08b ; slot 12
    d_entry b90_offset_095 ; slot 13
    d_entry b90_offset_09a ; slot 14
    d_entry b90_offset_09f ; slot 15

b90_record_012:
    d_begin $08, $01, $02, $D0 ; +$012
    d_text_mood21 ; +$014
    d_condition $59 ; +$015
    d_value b90_text_0b8/2 ; +$016
    d_value b90_text_0be/2 ; +$017
    d_value b90_text_0c4/2 ; +$018
    d_next $00 ; +$019
    d_next $14 ; +$01A
    d_reply $0A, $11 ; +$01B
    d_action3 $10, $12, $08, $09 ; +$01D
; End +$022

b90_record_022:
    d_begin $02, $00, $00, $01 ; +$022
    d_state_conditional $03 ; +$024
    d_test $16, $02 ; +$025
    d_test $1A, $01 ; +$027
    d_default $16 ; +$029
; End +$02A (EXIT from interpreter procedure)

b90_record_02a:
    d_begin $09, $00, $01, $01 ; +$02A
    d_text_mood20 ; +$02C
    d_value b90_text_0cc/2 ; +$02D
    d_value b90_text_0d4/2 ; +$02E
    d_value b90_text_0e0/2 ; +$02F
    d_next $00 ; +$030
    d_override $02, $13 ; +$031
    d_next $00 ; +$033
    d_override $02, $13 ; +$034
    d_action1 $10 ; +$036
; End +$038

b90_record_038:
    d_begin $00, $02, $01, $08 ; +$038
    d_say b90_text_0ea/2 ; +$03A
    d_next $00 ; +$03B
    d_next $15 ; +$03C
    d_reply $00, $12 ; +$03D
    d_reply $01, $00 ; +$03F
; End +$041

b90_record_041:
    d_begin $01, $02, $01, $09 ; +$041
    d_text_mood20 ; +$043
    d_value b90_text_0fe/2 ; +$044
    d_value b90_text_108/2 ; +$045
    d_value b90_text_118/2 ; +$046
    d_next $00 ; +$047
    d_no_override ; +$048
    d_next $15 ; +$049
    d_override $02, $14 ; +$04A
    d_reply $00, $10 ; +$04C
    d_reply $01, $00 ; +$04E
; End +$050

b90_record_050:
    d_begin $00, $00, $01, $01 ; +$050
    d_text_mood20 ; +$052
    d_value b90_text_126/2 ; +$053
    d_value b90_text_134/2 ; +$054
    d_value b90_text_14a/2 ; +$055
    d_next $00 ; +$056
    d_next $00 ; +$057
; End +$058

b90_record_058:
    d_begin $02, $02, $01, $01 ; +$058
    d_say b90_text_162/2 ; +$05A
    d_next $00 ; +$05B
    d_next $15 ; +$05C
    d_reply $03, $1A ; +$05D
    d_override $3D, $15 ; +$05F
    d_reply $07, $17 ; +$061
    d_no_override ; +$063
; End +$064

b90_record_064:
    d_begin $08, $01, $02, $C0 ; +$064
    d_say b90_text_1f8/2 ; +$066
    d_next $00 ; +$067
    d_next $15 ; +$068
    d_reply $0B, $18 ; +$069
    d_action0 ; +$06B
; End +$06C

b90_record_06c:
    d_begin $02, $00, $00, $00 ; +$06C
    d_state_conditional $03 ; +$06E
    d_test $19, $08 ; +$06F
    d_test $19, $01 ; +$071
    d_default $15 ; +$073
; End +$074 (EXIT from interpreter procedure)

b90_record_074:
    d_begin $02, $00, $00, $4C ; +$074
    d_state_conditional $02 ; +$076
    d_test $1A, $64 ; +$077
    d_default $1A ; +$079
; End +$07A (EXIT from interpreter procedure)

b90_record_07a:
    d_begin $00, $02, $01, $01 ; +$07A
    d_say b90_text_17c/2 ; +$07C
    d_next $00 ; +$07D
    d_next $1F ; +$07E
    d_reply $08, $1C ; +$07F
    d_reply $09, $1B ; +$081
; End +$083

b90_record_083:
    d_begin $08, $00, $02, $00 ; +$083
    d_say b90_text_18a/2 ; +$085
    d_next $00 ; +$086
    d_next $1F ; +$087
    d_action2 $1E, $1D ; +$088
; End +$08B

b90_record_08b:
    d_begin $08, $00, $02, $00 ; +$08B
    d_say b90_text_1c0/2 ; +$08D
    d_next $00 ; +$08E
    d_next $1F ; +$08F
    d_action3 $1E, $1D, $0F, $01 ; +$090
; End +$095

b90_record_095:
    d_begin $00, $00, $01, $00 ; +$095
    d_say b90_text_19c/2 ; +$097
    d_next $03 ; +$098
    d_next $03 ; +$099
; End +$09A

b90_record_09a:
    d_begin $00, $00, $01, $08 ; +$09A
    d_say b90_text_1cc/2 ; +$09C
    d_next $10 ; +$09D
    d_next $1F ; +$09E
; End +$09F

b90_record_09f:
    d_begin $00, $00, $01, $00 ; +$09F
    d_say b90_text_1e2/2 ; +$0A1
    d_next $00 ; +$0A2
    d_next $00 ; +$0A3
; End +$0A4

; Disk 2 block 91; offsets below are bank-relative.
b91_offset_012 = $12
b91_offset_01b = $1B
b91_offset_027 = $27
b91_offset_03b = $3B
b91_offset_04f = $4F
b91_offset_055 = $55
b91_offset_05f = $5F
b91_offset_065 = $65
b91_offset_076 = $76
b91_offset_07e = $7E
b91_offset_08a = $8A
b91_offset_090 = $90
b91_offset_099 = $99
b91_offset_0a2 = $A2
b91_offset_0ab = $AB
b91_offset_0b0 = $B0
b91_text_12e = $12E
b91_text_13a = $13A
b91_text_148 = $148
b91_text_14e = $14E
b91_text_15c = $15C
b91_text_16e = $16E
b91_text_17a = $17A
b91_text_182 = $182
b91_text_190 = $190
b91_text_19a = $19A
b91_text_1a6 = $1A6
b91_text_1ae = $1AE
b91_text_1be = $1BE
b91_text_1cc = $1CC
b91_text_1e2 = $1E2
b91_text_1ee = $1EE
; Entry table bytes 1–15; zero means no stored entry.
    d_entry b91_offset_01b ; slot 1
    d_entry b91_offset_027 ; slot 2
    d_entry b91_offset_03b ; slot 3
    d_entry b91_offset_04f ; slot 4
    d_entry b91_offset_055 ; slot 5
    d_entry b91_offset_05f ; slot 6
    d_entry b91_offset_065 ; slot 7
    d_entry b91_offset_076 ; slot 8
    d_entry b91_offset_07e ; slot 9
    d_entry b91_offset_08a ; slot 10
    d_entry b91_offset_090 ; slot 11
    d_entry b91_offset_099 ; slot 12
    d_entry b91_offset_0a2 ; slot 13
    d_entry b91_offset_0ab ; slot 14
    d_entry b91_offset_0b0 ; slot 15

b91_record_012:
    d_begin $00, $02, $03, $2C ; +$012
    d_say b91_text_12e/2 ; +$014
    d_next $04 ; +$015
    d_next $2C ; +$016
    d_reply $00, $24 ; +$017
    d_reply $01, $2E ; +$019
; End +$01B

b91_record_01b:
    d_begin $00, $02, $03, $3C ; +$01B
    d_text_conditional $02 ; +$01D
    d_test b91_text_1be/2, $09 ; +$01E
    d_default b91_text_1cc/2 ; +$020
    d_next $04 ; +$021
    d_next $2F ; +$022
    d_reply $00, $24 ; +$023
    d_reply $01, $04 ; +$025
; End +$027

b91_record_027:
    d_begin $02, $03, $02, $08 ; +$027
    d_text_mood23 ; +$029
    d_value b91_text_13a/2 ; +$02A
    d_value b91_text_148/2 ; +$02B
    d_value b91_text_14e/2 ; +$02C
    d_value b91_text_15c/2 ; +$02D
    d_next $04 ; +$02E
    d_next $2C ; +$02F
    d_reply $02, $25 ; +$030
    d_no_override ; +$032
    d_reply $01, $28 ; +$033
    d_override $82, $2F ; +$035
    d_reply $03, $27 ; +$037
    d_override $36, $2F ; +$039
; End +$03B

b91_record_03b:
    d_begin $02, $03, $02, $08 ; +$03B
    d_text_mood23 ; +$03D
    d_value b91_text_16e/2 ; +$03E
    d_value b91_text_17a/2 ; +$03F
    d_value b91_text_14e/2 ; +$040
    d_value b91_text_15c/2 ; +$041
    d_next $04 ; +$042
    d_next $2C ; +$043
    d_reply $02, $25 ; +$044
    d_no_override ; +$046
    d_reply $01, $28 ; +$047
    d_override $96, $2F ; +$049
    d_reply $03, $27 ; +$04B
    d_override $36, $2F ; +$04D
; End +$04F

b91_record_04f:
    d_begin $02, $00, $00, $00 ; +$04F
    d_state_conditional $02 ; +$051
    d_test $23, $06 ; +$052
    d_default $22 ; +$054
; End +$055 (EXIT from interpreter procedure)

b91_record_055:
    d_begin $08, $00, $03, $00 ; +$055
    d_text_conditional $02 ; +$057
    d_test b91_text_19a/2, $06 ; +$058
    d_default b91_text_1a6/2 ; +$05A
    d_next $2D ; +$05B
    d_next $2D ; +$05C
    d_action1 $26 ; +$05D
; End +$05F

b91_record_05f:
    d_begin $02, $00, $00, $00 ; +$05F
    d_state_conditional $02 ; +$061
    d_test $2A, $82 ; +$062
    d_default $2E ; +$064
; End +$065 (EXIT from interpreter procedure)

b91_record_065:
    d_begin $02, $03, $02, $00 ; +$065
    d_say b91_text_190/2 ; +$067
    d_next $04 ; +$068
    d_next $2C ; +$069
    d_reply $0E, $28 ; +$06A
    d_override $96, $29 ; +$06C
    d_reply $05, $28 ; +$06E
    d_override $37, $29 ; +$070
    d_reply $04, $28 ; +$072
    d_override $0A, $2F ; +$074
; End +$076

b91_record_076:
    d_begin $02, $00, $00, $00 ; +$076
    d_state_conditional $03 ; +$078
    d_test $2F, $02 ; +$079
    d_test $24, $07 ; +$07B
    d_default $29 ; +$07D
; End +$07E (EXIT from interpreter procedure)

b91_record_07e:
    d_begin $02, $02, $01, $00 ; +$07E
    d_say b91_text_15c/2 ; +$080
    d_next $2F ; +$081
    d_next $2F ; +$082
    d_reply $02, $25 ; +$083
    d_no_override ; +$085
    d_reply $01, $2A ; +$086
    d_override $96, $2F ; +$088
; End +$08A

b91_record_08a:
    d_begin $02, $00, $00, $00 ; +$08A
    d_state_conditional $02 ; +$08C
    d_test $2E, $06 ; +$08D
    d_default $2B ; +$08F
; End +$090 (EXIT from interpreter procedure)

b91_record_090:
    d_begin $00, $02, $01, $3C ; +$090
    d_say b91_text_1ee/2 ; +$092
    d_next $04 ; +$093
    d_next $2E ; +$094
    d_reply $00, $22 ; +$095
    d_reply $01, $2E ; +$097
; End +$099

b91_record_099:
    d_begin $00, $02, $01, $00 ; +$099
    d_say b91_text_182/2 ; +$09B
    d_next $04 ; +$09C
    d_next $2F ; +$09D
    d_reply $00, $24 ; +$09E
    d_reply $01, $04 ; +$0A0
; End +$0A2

b91_record_0a2:
    d_begin $00, $02, $01, $00 ; +$0A2
    d_say b91_text_1ae/2 ; +$0A4
    d_next $04 ; +$0A5
    d_next $2F ; +$0A6
    d_reply $00, $25 ; +$0A7
    d_reply $01, $04 ; +$0A9
; End +$0AB

b91_record_0ab:
    d_begin $00, $00, $01, $00 ; +$0AB
    d_say b91_text_1e2/2 ; +$0AD
    d_next $04 ; +$0AE
    d_next $04 ; +$0AF
; End +$0B0

b91_record_0b0:
    d_begin $02, $00, $00, $00 ; +$0B0
    d_state_conditional $02 ; +$0B2
    d_test $D0, $64 ; +$0B3
    d_default $D0 ; +$0B5
; End +$0B6 (EXIT from interpreter procedure)

; Disk 2 block 92; offsets below are bank-relative.
b92_offset_012 = $12
b92_offset_018 = $18
b92_offset_027 = $27
b92_offset_02e = $2E
b92_offset_03a = $3A
b92_offset_042 = $42
b92_offset_04a = $4A
b92_text_0b4 = $0B4
b92_text_0d6 = $0D6
b92_text_0f0 = $0F0
b92_text_106 = $106
b92_text_12c = $12C
b92_text_14e = $14E
b92_text_176 = $176
b92_text_196 = $196
b92_text_1c6 = $1C6
b92_text_1dc = $1DC
b92_text_1e6 = $1E6
b92_text_1fa = $1FA
; Entry table bytes 1–15; zero means no stored entry.
    d_entry b92_offset_018 ; slot 1
    d_entry b92_offset_027 ; slot 2
    d_entry b92_offset_02e ; slot 3
    d_entry b92_offset_03a ; slot 4
    d_entry b92_offset_042 ; slot 5
    d_entry b92_offset_04a ; slot 6
    d_entry 0 ; slot 7
    d_entry 0 ; slot 8
    d_entry 0 ; slot 9
    d_entry 0 ; slot 10
    d_entry 0 ; slot 11
    d_entry 0 ; slot 12
    d_entry 0 ; slot 13
    d_entry 0 ; slot 14
    d_entry 0 ; slot 15

b92_record_012:
    d_begin $02, $00, $00, $00 ; +$012
    d_state_conditional $02 ; +$014
    d_test $80, $38 ; +$015
    d_default $36 ; +$017
; End +$018 (EXIT from interpreter procedure)

b92_record_018:
    d_begin $03, $02, $02, $00 ; +$018
    d_say b92_text_106/2 ; +$01A
    d_next $70 ; +$01B
    d_override $0A, $00 ; +$01C
    d_next $70 ; +$01E
    d_no_override ; +$01F
    d_reply $00, $71 ; +$020
    d_no_override ; +$022
    d_reply $01, $70 ; +$023
    d_override $0A, $41 ; +$025
; End +$027

b92_record_027:
    d_begin $00, $01, $03, $00 ; +$027
    d_say b92_text_12c/2 ; +$029
    d_next $00 ; +$02A
    d_next $00 ; +$02B
    d_reply $0F, $35 ; +$02C
; End +$02E

b92_record_02e:
    d_begin $02, $01, $02, $80 ; +$02E
    d_text_random $03 ; +$030
    d_value b92_text_1c6/2 ; +$031
    d_value b92_text_1dc/2 ; +$032
    d_value b92_text_1e6/2 ; +$033
    d_next $06 ; +$034
    d_next $06 ; +$035
    d_reply $14, $34 ; +$036
    d_override $82, $06 ; +$038
; End +$03A

b92_record_03a:
    d_begin $08, $00, $01, $30 ; +$03A
    d_text_random $01 ; +$03C
    d_value b92_text_1fa/2 ; +$03D
    d_next $06 ; +$03E
    d_next $06 ; +$03F
    d_action1 $06 ; +$040
; End +$042

b92_record_042:
    d_begin $00, $00, $01, $40 ; +$042
    d_text_random $03 ; +$044
    d_value b92_text_14e/2 ; +$045
    d_value b92_text_176/2 ; +$046
    d_value b92_text_196/2 ; +$047
    d_next $05 ; +$048
    d_next $05 ; +$049
; End +$04A

b92_record_04a:
    d_begin $00, $00, $01, $00 ; +$04A
    d_text_random $03 ; +$04C
    d_value b92_text_0b4/2 ; +$04D
    d_value b92_text_0d6/2 ; +$04E
    d_value b92_text_0f0/2 ; +$04F
    d_next $00 ; +$050
    d_next $00 ; +$051
; End +$052

; Disk 2 block 93; offsets below are bank-relative.
b93_offset_012 = $12
b93_offset_022 = $22
b93_offset_032 = $32
b93_offset_039 = $39
b93_offset_03e = $3E
b93_offset_045 = $45
b93_offset_054 = $54
b93_offset_061 = $61
b93_offset_072 = $72
b93_offset_077 = $77
b93_offset_07c = $7C
b93_offset_083 = $83
b93_offset_08c = $8C
b93_offset_091 = $91
b93_text_0fc = $0FC
b93_text_10e = $10E
b93_text_126 = $126
b93_text_138 = $138
b93_text_14a = $14A
b93_text_15c = $15C
b93_text_174 = $174
b93_text_178 = $178
b93_text_180 = $180
b93_text_190 = $190
b93_text_19e = $19E
b93_text_1a6 = $1A6
b93_text_1bc = $1BC
b93_text_1c0 = $1C0
b93_text_1d8 = $1D8
b93_text_1e8 = $1E8
b93_text_1ee = $1EE
; Entry table bytes 1–15; zero means no stored entry.
    d_entry b93_offset_022 ; slot 1
    d_entry b93_offset_032 ; slot 2
    d_entry b93_offset_039 ; slot 3
    d_entry b93_offset_03e ; slot 4
    d_entry b93_offset_045 ; slot 5
    d_entry b93_offset_054 ; slot 6
    d_entry b93_offset_061 ; slot 7
    d_entry b93_offset_072 ; slot 8
    d_entry b93_offset_077 ; slot 9
    d_entry b93_offset_07c ; slot 10
    d_entry b93_offset_083 ; slot 11
    d_entry b93_offset_08c ; slot 12
    d_entry b93_offset_091 ; slot 13
    d_entry 0 ; slot 14
    d_entry 0 ; slot 15

b93_record_012:
    d_begin $02, $03, $02, $00 ; +$012
    d_say b93_text_0fc/2 ; +$014
    d_next $44 ; +$015
    d_next $42 ; +$016
    d_reply $0C, $42 ; +$017
    d_no_override ; +$019
    d_reply $0D, $46 ; +$01A
    d_override $82, $44 ; +$01C
    d_reply $03, $45 ; +$01E
    d_override $36, $42 ; +$020
; End +$022

b93_record_022:
    d_begin $02, $03, $02, $00 ; +$022
    d_say b93_text_190/2 ; +$024
    d_next $4B ; +$025
    d_next $4B ; +$026
    d_reply $0C, $4C ; +$027
    d_no_override ; +$029
    d_reply $0D, $47 ; +$02A
    d_override $82, $4A ; +$02C
    d_reply $03, $4D ; +$02E
    d_override $36, $4A ; +$030
; End +$032

b93_record_032:
    d_begin $00, $00, $01, $00 ; +$032
    d_text_random $02 ; +$034
    d_value b93_text_10e/2 ; +$035
    d_value b93_text_126/2 ; +$036
    d_next $05 ; +$037
    d_next $05 ; +$038
; End +$039

b93_record_039:
    d_begin $00, $00, $01, $00 ; +$039
    d_say b93_text_138/2 ; +$03B
    d_next $00 ; +$03C
    d_next $00 ; +$03D
; End +$03E

b93_record_03e:
    d_begin $00, $00, $01, $00 ; +$03E
    d_text_random $02 ; +$040
    d_value b93_text_14a/2 ; +$041
    d_value b93_text_15c/2 ; +$042
    d_next $06 ; +$043
    d_next $06 ; +$044
; End +$045

b93_record_045:
    d_begin $02, $02, $02, $00 ; +$045
    d_text_random $02 ; +$047
    d_value b93_text_174/2 ; +$048
    d_value b93_text_178/2 ; +$049
    d_next $44 ; +$04A
    d_next $42 ; +$04B
    d_reply $0E, $43 ; +$04C
    d_override $05, $42 ; +$04E
    d_reply $04, $43 ; +$050
    d_override $4E, $44 ; +$052
; End +$054

b93_record_054:
    d_begin $02, $02, $02, $00 ; +$054
    d_say b93_text_180/2 ; +$056
    d_next $44 ; +$057
    d_next $42 ; +$058
    d_reply $04, $43 ; +$059
    d_override $4E, $44 ; +$05B
    d_reply $06, $43 ; +$05D
    d_override $37, $42 ; +$05F
; End +$061

b93_record_061:
    d_begin $02, $03, $02, $00 ; +$061
    d_say b93_text_19e/2 ; +$063
    d_next $4B ; +$064
    d_next $4B ; +$065
    d_reply $04, $49 ; +$066
    d_override $0A, $4A ; +$068
    d_reply $11, $49 ; +$06A
    d_override $03, $48 ; +$06C
    d_reply $06, $49 ; +$06E
    d_override $37, $4B ; +$070
; End +$072

b93_record_072:
    d_begin $00, $00, $01, $00 ; +$072
    d_say b93_text_1a6/2 ; +$074
    d_next $08 ; +$075
    d_next $08 ; +$076
; End +$077

b93_record_077:
    d_begin $00, $00, $01, $00 ; +$077
    d_say b93_text_1bc/2 ; +$079
    d_next $00 ; +$07A
    d_next $00 ; +$07B
; End +$07C

b93_record_07c:
    d_begin $00, $00, $01, $00 ; +$07C
    d_text_random $02 ; +$07E
    d_value b93_text_1c0/2 ; +$07F
    d_value b93_text_1ee/2 ; +$080
    d_next $07 ; +$081
    d_next $07 ; +$082
; End +$083

b93_record_083:
    d_begin $00, $02, $01, $00 ; +$083
    d_say b93_text_1d8/2 ; +$085
    d_next $07 ; +$086
    d_next $07 ; +$087
    d_reply $0C, $4C ; +$088
    d_reply $0D, $4A ; +$08A
; End +$08C

b93_record_08c:
    d_begin $00, $00, $01, $00 ; +$08C
    d_say b93_text_1e8/2 ; +$08E
    d_next $08 ; +$08F
    d_next $08 ; +$090
; End +$091

b93_record_091:
    d_begin $02, $03, $02, $00 ; +$091
    d_text_random $02 ; +$093
    d_value b93_text_174/2 ; +$094
    d_value b93_text_178/2 ; +$095
    d_next $4B ; +$096
    d_next $4B ; +$097
    d_reply $04, $49 ; +$098
    d_override $0A, $44 ; +$09A
    d_reply $11, $49 ; +$09C
    d_override $03, $48 ; +$09E
    d_reply $06, $49 ; +$0A0
    d_override $37, $4B ; +$0A2
; End +$0A4

; Disk 2 block 94; offsets below are bank-relative.
b94_offset_012 = $12
b94_offset_01a = $1A
b94_offset_022 = $22
b94_offset_032 = $32
b94_offset_042 = $42
b94_offset_04f = $4F
b94_offset_05d = $5D
b94_offset_066 = $66
b94_offset_075 = $75
b94_offset_07d = $7D
b94_text_12c = $12C
b94_text_140 = $140
b94_text_146 = $146
b94_text_150 = $150
b94_text_158 = $158
b94_text_15e = $15E
b94_text_164 = $164
b94_text_178 = $178
b94_text_182 = $182
b94_text_192 = $192
b94_text_1a0 = $1A0
b94_text_1ae = $1AE
b94_text_1ce = $1CE
b94_text_1da = $1DA
b94_text_1e4 = $1E4
b94_text_1ee = $1EE
; Entry table bytes 1–15; zero means no stored entry.
    d_entry b94_offset_01a ; slot 1
    d_entry b94_offset_022 ; slot 2
    d_entry b94_offset_032 ; slot 3
    d_entry b94_offset_042 ; slot 4
    d_entry b94_offset_04f ; slot 5
    d_entry b94_offset_05d ; slot 6
    d_entry b94_offset_066 ; slot 7
    d_entry b94_offset_075 ; slot 8
    d_entry b94_offset_07d ; slot 9
    d_entry 0 ; slot 10
    d_entry 0 ; slot 11
    d_entry 0 ; slot 12
    d_entry 0 ; slot 13
    d_entry 0 ; slot 14
    d_entry 0 ; slot 15

b94_record_012:
    d_begin $0A, $00, $00, $00 ; +$012
    d_state_conditional $02 ; +$014
    d_test $52, $64 ; +$015
    d_default $52 ; +$017
    d_action5 $52 ; +$018
; End +$01A (EXIT from interpreter procedure)

b94_record_01a:
    d_begin $0A, $00, $00, $00 ; +$01A
    d_state_conditional $02 ; +$01C
    d_test $53, $64 ; +$01D
    d_default $53 ; +$01F
    d_action5 $53 ; +$020
; End +$022 (EXIT from interpreter procedure)

b94_record_022:
    d_begin $08, $01, $02, $D0 ; +$022
    d_text_mood21 ; +$024
    d_condition $93 ; +$025
    d_value b94_text_12c/2 ; +$026
    d_value b94_text_140/2 ; +$027
    d_value b94_text_146/2 ; +$028
    d_next $00 ; +$029
    d_next $57 ; +$02A
    d_reply $0A, $90 ; +$02B
    d_action3 $59, $54, $0A, $00 ; +$02D
; End +$032

b94_record_032:
    d_begin $08, $01, $02, $D0 ; +$032
    d_text_mood21 ; +$034
    d_condition $93 ; +$035
    d_value b94_text_12c/2 ; +$036
    d_value b94_text_140/2 ; +$037
    d_value b94_text_146/2 ; +$038
    d_next $00 ; +$039
    d_next $57 ; +$03A
    d_reply $0A, $A0 ; +$03B
    d_action3 $59, $54, $17, $02 ; +$03D
; End +$042

b94_record_042:
    d_begin $08, $02, $01, $21 ; +$042
    d_text_random $02 ; +$044
    d_value b94_text_1e4/2 ; +$045
    d_value b94_text_1ee/2 ; +$046
    d_next $00 ; +$047
    d_next $57 ; +$048
    d_reply $08, $55 ; +$049
    d_reply $13, $09 ; +$04B
    d_action6 $55 ; +$04D
; End +$04F

b94_record_04f:
    d_begin $09, $00, $01, $00 ; +$04F
    d_text_mood20 ; +$051
    d_value b94_text_150/2 ; +$052
    d_value b94_text_158/2 ; +$053
    d_value b94_text_15e/2 ; +$054
    d_next $00 ; +$055
    d_override $02, $56 ; +$056
    d_next $58 ; +$058
    d_override $02, $56 ; +$059
    d_action1 $09 ; +$05B
; End +$05D

b94_record_05d:
    d_begin $00, $02, $01, $08 ; +$05D
    d_say b94_text_164/2 ; +$05F
    d_next $00 ; +$060
    d_next $58 ; +$061
    d_reply $00, $0A ; +$062
    d_reply $01, $09 ; +$064
; End +$066

b94_record_066:
    d_begin $01, $02, $01, $09 ; +$066
    d_text_mood20 ; +$068
    d_value b94_text_178/2 ; +$069
    d_value b94_text_182/2 ; +$06A
    d_value b94_text_192/2 ; +$06B
    d_next $00 ; +$06C
    d_no_override ; +$06D
    d_next $58 ; +$06E
    d_override $02, $57 ; +$06F
    d_reply $00, $09 ; +$071
    d_reply $01, $00 ; +$073
; End +$075

b94_record_075:
    d_begin $00, $00, $01, $01 ; +$075
    d_text_mood20 ; +$077
    d_value b94_text_1a0/2 ; +$078
    d_value b94_text_1ae/2 ; +$079
    d_value b94_text_1ce/2 ; +$07A
    d_next $00 ; +$07B
    d_next $00 ; +$07C
; End +$07D

b94_record_07d:
    d_begin $00, $00, $01, $00 ; +$07D
    d_say b94_text_1da/2 ; +$07F
    d_next $09 ; +$080
    d_next $09 ; +$081
; End +$082

; Disk 2 block 95; offsets below are bank-relative.
b95_offset_012 = $12
b95_offset_022 = $22
b95_offset_027 = $27
b95_offset_02c = $2C
b95_offset_038 = $38
b95_offset_03d = $3D
b95_text_17a = $17A
b95_text_182 = $182
b95_text_1a2 = $1A2
b95_text_1c6 = $1C6
b95_text_1e0 = $1E0
b95_text_1ee = $1EE
; Entry table bytes 1–15; zero means no stored entry.
    d_entry b95_offset_022 ; slot 1
    d_entry b95_offset_027 ; slot 2
    d_entry b95_offset_02c ; slot 3
    d_entry b95_offset_038 ; slot 4
    d_entry b95_offset_03d ; slot 5
    d_entry 0 ; slot 6
    d_entry 0 ; slot 7
    d_entry 0 ; slot 8
    d_entry 0 ; slot 9
    d_entry 0 ; slot 10
    d_entry 0 ; slot 11
    d_entry 0 ; slot 12
    d_entry 0 ; slot 13
    d_entry 0 ; slot 14
    d_entry 0 ; slot 15

b95_record_012:
    d_begin $02, $02, $02, $00 ; +$012
    d_text_mood21 ; +$014
    d_condition $B4 ; +$015
    d_value b95_text_17a/2 ; +$016
    d_value b95_text_17a/2 ; +$017
    d_value b95_text_17a/2 ; +$018
    d_next $00 ; +$019
    d_next $61 ; +$01A
    d_reply $00, $63 ; +$01B
    d_override $0B, $62 ; +$01D
    d_reply $01, $00 ; +$01F
    d_no_override ; +$021
; End +$022

b95_record_022:
    d_begin $00, $00, $00, $01 ; +$022
    d_say b95_text_182/2 ; +$024
    d_next $00 ; +$025
    d_next $00 ; +$026
; End +$027

b95_record_027:
    d_begin $00, $00, $00, $01 ; +$027
    d_say b95_text_1a2/2 ; +$029
    d_next $00 ; +$02A
    d_next $00 ; +$02B
; End +$02C

b95_record_02c:
    d_begin $02, $02, $02, $01 ; +$02C
    d_say b95_text_1c6/2 ; +$02E
    d_next $00 ; +$02F
    d_next $61 ; +$030
    d_reply $02, $64 ; +$031
    d_override $08, $65 ; +$033
    d_reply $0D, $61 ; +$035
    d_no_override ; +$037
; End +$038

b95_record_038:
    d_begin $00, $00, $01, $40 ; +$038
    d_say b95_text_1e0/2 ; +$03A
    d_next $03 ; +$03B
    d_next $03 ; +$03C
; End +$03D

b95_record_03d:
    d_begin $00, $00, $01, $00 ; +$03D
    d_say b95_text_1ee/2 ; +$03F
    d_next $00 ; +$040
    d_next $00 ; +$041
; End +$042

; Disk 2 block 96; offsets below are bank-relative.
b96_offset_012 = $12
b96_offset_021 = $21
b96_text_0a8 = $0A8
b96_text_0ca = $0CA
b96_text_0e4 = $0E4
b96_text_0fa = $0FA
b96_text_11c = $11C
b96_text_136 = $136
b96_text_15a = $15A
b96_text_178 = $178
b96_text_18c = $18C
b96_text_192 = $192
b96_text_1a8 = $1A8
b96_text_1ba = $1BA
b96_text_1d6 = $1D6
b96_text_1ee = $1EE
; Entry table bytes 1–15; zero means no stored entry.
    d_entry b96_offset_021 ; slot 1
    d_entry 0 ; slot 2
    d_entry 0 ; slot 3
    d_entry 0 ; slot 4
    d_entry 0 ; slot 5
    d_entry 0 ; slot 6
    d_entry 0 ; slot 7
    d_entry 0 ; slot 8
    d_entry 0 ; slot 9
    d_entry 0 ; slot 10
    d_entry 0 ; slot 11
    d_entry 0 ; slot 12
    d_entry 0 ; slot 13
    d_entry 0 ; slot 14
    d_entry 0 ; slot 15

b96_record_012:
    d_begin $00, $00, $01, $00 ; +$012
    d_text_random $0A ; +$014
    d_value b96_text_0a8/2 ; +$015
    d_value b96_text_0ca/2 ; +$016
    d_value b96_text_0e4/2 ; +$017
    d_value b96_text_0fa/2 ; +$018
    d_value b96_text_11c/2 ; +$019
    d_value b96_text_136/2 ; +$01A
    d_value b96_text_15a/2 ; +$01B
    d_value b96_text_178/2 ; +$01C
    d_value b96_text_18c/2 ; +$01D
    d_value b96_text_192/2 ; +$01E
    d_next $00 ; +$01F
    d_next $00 ; +$020
; End +$021

b96_record_021:
    d_begin $00, $00, $01, $40 ; +$021
    d_text_random $04 ; +$023
    d_value b96_text_1a8/2 ; +$024
    d_value b96_text_1ba/2 ; +$025
    d_value b96_text_1d6/2 ; +$026
    d_value b96_text_1ee/2 ; +$027
    d_next $00 ; +$028
    d_next $00 ; +$029
; End +$02A

; Disk 2 block 97; offsets below are bank-relative.
b97_offset_012 = $12
b97_offset_023 = $23
b97_offset_031 = $31
b97_offset_043 = $43
b97_offset_04b = $4B
b97_offset_051 = $51
b97_offset_05a = $5A
b97_offset_063 = $63
b97_offset_068 = $68
b97_offset_06f = $6F
b97_text_0c4 = $0C4
b97_text_0ce = $0CE
b97_text_0ea = $0EA
b97_text_0fa = $0FA
b97_text_106 = $106
b97_text_11c = $11C
b97_text_128 = $128
b97_text_13c = $13C
b97_text_168 = $168
b97_text_17c = $17C
b97_text_194 = $194
b97_text_19e = $19E
b97_text_1ae = $1AE
b97_text_1be = $1BE
b97_text_1d0 = $1D0
b97_text_1e0 = $1E0
; Entry table bytes 1–15; zero means no stored entry.
    d_entry b97_offset_023 ; slot 1
    d_entry b97_offset_031 ; slot 2
    d_entry b97_offset_043 ; slot 3
    d_entry b97_offset_04b ; slot 4
    d_entry b97_offset_051 ; slot 5
    d_entry b97_offset_05a ; slot 6
    d_entry b97_offset_063 ; slot 7
    d_entry b97_offset_068 ; slot 8
    d_entry b97_offset_06f ; slot 9
    d_entry 0 ; slot 10
    d_entry 0 ; slot 11
    d_entry 0 ; slot 12
    d_entry 0 ; slot 13
    d_entry 0 ; slot 14
    d_entry 0 ; slot 15

b97_record_012:
    d_begin $0A, $02, $02, $00 ; +$012
    d_text_random $03 ; +$014
    d_value b97_text_1be/2 ; +$015
    d_value b97_text_1d0/2 ; +$016
    d_value b97_text_1e0/2 ; +$017
    d_next $00 ; +$018
    d_next $89 ; +$019
    d_reply $00, $B0 ; +$01A
    d_override $96, $81 ; +$01C
    d_reply $01, $88 ; +$01E
    d_no_override ; +$020
    d_action5 $81 ; +$021
; End +$023

b97_record_023:
    d_begin $08, $02, $02, $00 ; +$023
    d_text_random $03 ; +$025
    d_value b97_text_0c4/2 ; +$026
    d_value b97_text_0ce/2 ; +$027
    d_value b97_text_0ea/2 ; +$028
    d_next $00 ; +$029
    d_next $89 ; +$02A
    d_reply $00, $82 ; +$02B
    d_reply $01, $88 ; +$02D
    d_action5 $81 ; +$02F
; End +$031

b97_record_031:
    d_begin $0A, $02, $02, $3C ; +$031
    d_text_random $03 ; +$033
    d_value b97_text_0fa/2 ; +$034
    d_value b97_text_106/2 ; +$035
    d_value b97_text_11c/2 ; +$036
    d_next $00 ; +$037
    d_next $89 ; +$038
    d_reply $08, $22 ; +$039
    d_override $37, $87 ; +$03B
    d_reply $09, $83 ; +$03D
    d_override $37, $87 ; +$03F
    d_action5 $82 ; +$041
; End +$043

b97_record_043:
    d_begin $08, $00, $02, $00 ; +$043
    d_say b97_text_128/2 ; +$045
    d_next $00 ; +$046
    d_next $86 ; +$047
    d_action2 $85, $84 ; +$048
; End +$04B

b97_record_04b:
    d_begin $02, $00, $00, $20 ; +$04B
    d_state_conditional $02 ; +$04D
    d_test $23, $64 ; +$04E
    d_default $23 ; +$050
; End +$051 (EXIT from interpreter procedure)

b97_record_051:
    d_begin $00, $02, $02, $00 ; +$051
    d_say b97_text_13c/2 ; +$053
    d_next $00 ; +$054
    d_next $00 ; +$055
    d_reply $00, $83 ; +$056
    d_reply $01, $00 ; +$058
; End +$05A

b97_record_05a:
    d_begin $00, $02, $01, $00 ; +$05A
    d_say b97_text_168/2 ; +$05C
    d_next $00 ; +$05D
    d_next $00 ; +$05E
    d_reply $00, $83 ; +$05F
    d_reply $01, $00 ; +$061
; End +$063

b97_record_063:
    d_begin $00, $00, $01, $00 ; +$063
    d_say b97_text_194/2 ; +$065
    d_next $00 ; +$066
    d_next $00 ; +$067
; End +$068

b97_record_068:
    d_begin $00, $00, $01, $00 ; +$068
    d_text_random $02 ; +$06A
    d_value b97_text_19e/2 ; +$06B
    d_value b97_text_1ae/2 ; +$06C
    d_next $00 ; +$06D
    d_next $00 ; +$06E
; End +$06F

b97_record_06f:
    d_begin $00, $02, $01, $00 ; +$06F
    d_say b97_text_17c/2 ; +$071
    d_next $00 ; +$072
    d_next $00 ; +$073
    d_reply $00, $09 ; +$074
    d_reply $01, $00 ; +$076
; End +$078

; Disk 2 block 98; offsets below are bank-relative.
b98_offset_010 = $10
b98_offset_01c = $1C
b98_offset_021 = $21
b98_offset_02d = $2D
b98_text_07e = $07E
b98_text_092 = $092
b98_text_0a4 = $0A4
b98_text_0dc = $0DC
b98_text_126 = $126
b98_text_168 = $168
b98_text_1ba = $1BA
; Entry table bytes 0–15; zero means no stored entry.
    d_entry b98_offset_010 ; slot 0
    d_entry b98_offset_01c ; slot 1
    d_entry b98_offset_021 ; slot 2
    d_entry b98_offset_02d ; slot 3
    d_entry 0 ; slot 4
    d_entry 0 ; slot 5
    d_entry 0 ; slot 6
    d_entry 0 ; slot 7
    d_entry 0 ; slot 8
    d_entry 0 ; slot 9
    d_entry 0 ; slot 10
    d_entry 0 ; slot 11
    d_entry 0 ; slot 12
    d_entry 0 ; slot 13
    d_entry 0 ; slot 14
    d_entry 0 ; slot 15

b98_record_010:
    d_begin $08, $01, $02, $00 ; +$010
    d_say b98_text_07e/2 ; +$012
    d_next $09 ; +$013
    d_next $09 ; +$014
    d_reply $16, $91 ; +$015
    d_action3 $09, $92, $0A, $00 ; +$017
; End +$01C

b98_record_01c:
    d_begin $00, $00, $01, $00 ; +$01C
    d_say b98_text_0a4/2 ; +$01E
    d_next $93 ; +$01F
    d_next $93 ; +$020
; End +$021

b98_record_021:
    d_begin $00, $00, $01, $20 ; +$021
    d_text_conditional $04 ; +$023
    d_test b98_text_0dc/2, $D2 ; +$024
    d_test b98_text_126/2, $D3 ; +$026
    d_test b98_text_168/2, $D4 ; +$028
    d_default b98_text_1ba/2 ; +$02A
    d_next $93 ; +$02B
    d_next $93 ; +$02C
; End +$02D

b98_record_02d:
    d_begin $08, $01, $02, $00 ; +$02D
    d_say b98_text_092/2 ; +$02F
    d_next $09 ; +$030
    d_next $09 ; +$031
    d_reply $15, $09 ; +$032
    d_action3 $09, $92, $0A, $00 ; +$034
; End +$039

; Disk 2 block 99; offsets below are bank-relative.
b99_offset_012 = $12
b99_offset_01e = $1E
b99_offset_034 = $34
b99_text_0ac = $0AC
b99_text_0c0 = $0C0
b99_text_0c8 = $0C8
b99_text_0dc = $0DC
b99_text_10a = $10A
b99_text_112 = $112
b99_text_144 = $144
b99_text_154 = $154
b99_text_170 = $170
b99_text_190 = $190
b99_text_1c2 = $1C2
; Entry table bytes 1–15; zero means no stored entry.
    d_entry b99_offset_01e ; slot 1
    d_entry b99_offset_034 ; slot 2
    d_entry 0 ; slot 3
    d_entry 0 ; slot 4
    d_entry 0 ; slot 5
    d_entry 0 ; slot 6
    d_entry 0 ; slot 7
    d_entry 0 ; slot 8
    d_entry 0 ; slot 9
    d_entry 0 ; slot 10
    d_entry 0 ; slot 11
    d_entry 0 ; slot 12
    d_entry 0 ; slot 13
    d_entry 0 ; slot 14
    d_entry 0 ; slot 15

b99_record_012:
    d_begin $08, $01, $02, $00 ; +$012
    d_say b99_text_0ac/2 ; +$014
    d_next $09 ; +$015
    d_next $09 ; +$016
    d_reply $15, $09 ; +$017
    d_action3 $09, $A1, $17, $02 ; +$019
; End +$01E

b99_record_01e:
    d_begin $00, $00, $01, $20 ; +$01E
    d_text_conditional $09 ; +$020
    d_test b99_text_0c8/2, $E0 ; +$021
    d_test b99_text_0dc/2, $E1 ; +$023
    d_test b99_text_10a/2, $E2 ; +$025
    d_test b99_text_112/2, $E3 ; +$027
    d_test b99_text_144/2, $E4 ; +$029
    d_test b99_text_154/2, $E5 ; +$02B
    d_test b99_text_170/2, $E6 ; +$02D
    d_test b99_text_190/2, $E7 ; +$02F
    d_default b99_text_1c2/2 ; +$031
    d_next $A2 ; +$032
    d_next $A2 ; +$033
; End +$034

b99_record_034:
    d_begin $08, $01, $02, $00 ; +$034
    d_say b99_text_0c0/2 ; +$036
    d_next $09 ; +$037
    d_next $09 ; +$038
    d_reply $15, $09 ; +$039
    d_action3 $09, $A1, $17, $02 ; +$03B
; End +$040

; Disk 2 block 100; offsets below are bank-relative.
b100_offset_012 = $12
b100_offset_020 = $20
b100_offset_026 = $26
b100_offset_034 = $34
b100_offset_040 = $40
b100_text_134 = $134
b100_text_13a = $13A
b100_text_14c = $14C
b100_text_154 = $154
b100_text_164 = $164
b100_text_17c = $17C
b100_text_196 = $196
b100_text_1b0 = $1B0
b100_text_1be = $1BE
b100_text_1da = $1DA
b100_text_1ee = $1EE
; Entry table bytes 1–15; zero means no stored entry.
    d_entry b100_offset_020 ; slot 1
    d_entry b100_offset_026 ; slot 2
    d_entry b100_offset_034 ; slot 3
    d_entry b100_offset_040 ; slot 4
    d_entry 0 ; slot 5
    d_entry 0 ; slot 6
    d_entry 0 ; slot 7
    d_entry 0 ; slot 8
    d_entry 0 ; slot 9
    d_entry 0 ; slot 10
    d_entry 0 ; slot 11
    d_entry 0 ; slot 12
    d_entry 0 ; slot 13
    d_entry 0 ; slot 14
    d_entry 0 ; slot 15

b100_record_012:
    d_begin $0A, $01, $02, $00 ; +$012
    d_text_random $03 ; +$014
    d_value b100_text_134/2 ; +$015
    d_value b100_text_13a/2 ; +$016
    d_value b100_text_14c/2 ; +$017
    d_next $00 ; +$018
    d_next $B4 ; +$019
    d_reply $17, $B1 ; +$01A
    d_override $38, $09 ; +$01C
    d_action6 $B2 ; +$01E
; End +$020

b100_record_020:
    d_begin $02, $00, $00, $00 ; +$020
    d_state_conditional $02 ; +$022
    d_test $C0, $96 ; +$023
    d_default $B2 ; +$025
; End +$026 (EXIT from interpreter procedure)

b100_record_026:
    d_begin $0A, $01, $02, $00 ; +$026
    d_text_random $03 ; +$028
    d_value b100_text_154/2 ; +$029
    d_value b100_text_164/2 ; +$02A
    d_value b100_text_17c/2 ; +$02B
    d_next $00 ; +$02C
    d_next $B4 ; +$02D
    d_reply $17, $09 ; +$02E
    d_override $96, $B3 ; +$030
    d_action6 $B3 ; +$032
; End +$034

b100_record_034:
    d_begin $08, $01, $02, $00 ; +$034
    d_text_random $03 ; +$036
    d_value b100_text_196/2 ; +$037
    d_value b100_text_1b0/2 ; +$038
    d_value b100_text_1be/2 ; +$039
    d_next $00 ; +$03A
    d_next $B4 ; +$03B
    d_reply $17, $09 ; +$03C
    d_action6 $09 ; +$03E
; End +$040

b100_record_040:
    d_begin $00, $02, $01, $00 ; +$040
    d_text_random $02 ; +$042
    d_value b100_text_1da/2 ; +$043
    d_value b100_text_1ee/2 ; +$044
    d_next $00 ; +$045
    d_next $00 ; +$046
    d_reply $00, $0A ; +$047
    d_reply $01, $00 ; +$049
; End +$04B

; Disk 2 block 101; offsets below are bank-relative.
b101_offset_012 = $12
b101_offset_01f = $1F
b101_text_07a = $07A
b101_text_0a2 = $0A2
b101_text_0ba = $0BA
b101_text_0d6 = $0D6
b101_text_106 = $106
b101_text_126 = $126
b101_text_152 = $152
b101_text_16c = $16C
b101_text_198 = $198
b101_text_1b4 = $1B4
b101_text_1cc = $1CC
b101_text_1dc = $1DC
; Entry table bytes 1–15; zero means no stored entry.
    d_entry b101_offset_01f ; slot 1
    d_entry 0 ; slot 2
    d_entry 0 ; slot 3
    d_entry 0 ; slot 4
    d_entry 0 ; slot 5
    d_entry 0 ; slot 6
    d_entry 0 ; slot 7
    d_entry 0 ; slot 8
    d_entry 0 ; slot 9
    d_entry 0 ; slot 10
    d_entry 0 ; slot 11
    d_entry 0 ; slot 12
    d_entry 0 ; slot 13
    d_entry 0 ; slot 14
    d_entry 0 ; slot 15

b101_record_012:
    d_begin $00, $01, $01, $00 ; +$012
    d_text_random $06 ; +$014
    d_value b101_text_07a/2 ; +$015
    d_value b101_text_0ba/2 ; +$016
    d_value b101_text_106/2 ; +$017
    d_value b101_text_152/2 ; +$018
    d_value b101_text_198/2 ; +$019
    d_value b101_text_1cc/2 ; +$01A
    d_next $00 ; +$01B
    d_next $C1 ; +$01C
    d_reply $18, $C1 ; +$01D
; End +$01F

b101_record_01f:
    d_begin $00, $00, $01, $02 ; +$01F
    d_text_random $06 ; +$021
    d_value b101_text_0a2/2 ; +$022
    d_value b101_text_0d6/2 ; +$023
    d_value b101_text_126/2 ; +$024
    d_value b101_text_16c/2 ; +$025
    d_value b101_text_1b4/2 ; +$026
    d_value b101_text_1dc/2 ; +$027
    d_next $0A ; +$028
    d_next $0A ; +$029
; End +$02A

; Disk 2 block 102; offsets below are bank-relative.
b102_offset_012 = $12
b102_text_1f8 = $1F8
; Entry table bytes 1–15; zero means no stored entry.
    d_entry 0 ; slot 1
    d_entry 0 ; slot 2
    d_entry 0 ; slot 3
    d_entry 0 ; slot 4
    d_entry 0 ; slot 5
    d_entry 0 ; slot 6
    d_entry 0 ; slot 7
    d_entry 0 ; slot 8
    d_entry 0 ; slot 9
    d_entry 0 ; slot 10
    d_entry 0 ; slot 11
    d_entry 0 ; slot 12
    d_entry 0 ; slot 13
    d_entry 0 ; slot 14
    d_entry 0 ; slot 15

b102_record_012:
    d_begin $00, $00, $01, $00 ; +$012
    d_say b102_text_1f8/2 ; +$014
    d_next $04 ; +$015
    d_next $04 ; +$016
; End +$017
