EXT_L_0000 = segment_start + (-454)
EXT_L_0059 = segment_start + (-365)
EXT_L_0076 = segment_start + (-336)
EXT_L_00EE = segment_start + (-216)
EXT_L_0111 = segment_start + (-181)
EXT_L_013F = segment_start + (-135)
EXT_L_01C4 = segment_start + (-2)
EXT_L_0318 = segment_start + (338)
EXT_L_031A = segment_start + (340)
EXT_L_031C = segment_start + (342)
EXT_L_031E = segment_start + (344)
EXT_L_0328 = segment_start + (354)
; Historical linker fragment: docs/retained-linker-code.md
.include "encoding.inc"
.segment "PCODE"
segment_start:
L_01C6:
    p_big 295, 2 ; retained operand of preceding LDL opcode
L_01C8:
    p_leqi
L_01C9:
    p_fjp_direct L_01FD
L_01CB:
    p_ldl 294, 2
L_01CE:
    p_inc 128, 2
L_01D1:
    p_sldl 10
L_01D2:
    p_sldc 0
L_01D3:
    p_sldc 15
L_01D4:
    p_chk
L_01D5:
    p_ixa 1, 1
L_01D7:
    p_sldc 8
L_01D8:
    p_sldc 0
L_01D9:
    p_ldp
L_01DA:
    p_ldl 26, 1
L_01DC:
    p_equi
L_01DD:
    p_fjp_direct L_01F6
L_01DF:
    p_sldl 2
L_01E0:
    p_inc 4, 1
L_01E2:
    p_ldl 294, 2
L_01E5:
    p_sldl 10
L_01E6:
    p_sldc 0
L_01E7:
    p_sldc 15
L_01E8:
    p_chk
L_01E9:
    p_ixa 2, 1
L_01EB:
    p_sind 1
L_01EC:
    p_sldc 2
L_01ED:
    p_dvi
L_01EE:
    p_sldc 1
L_01EF:
    p_adi
L_01F0:
    p_sldc 1
L_01F1:
    p_ldci 32767
L_01F4:
    p_chk
L_01F5:
    p_sto
L_01F6:
    p_sldl 10
L_01F7:
    p_sldc 1
L_01F8:
    p_adi
L_01F9:
    p_stl 10, 1
L_01FB:
    p_ujp_table L_0238, L_024A
L_01FD:
    p_sldl 2
L_01FE:
    p_inc 5, 1
L_0200:
    p_ldl 26, 1
L_0202:
    p_sldc 0
L_0203:
    p_ldci 255
L_0206:
    p_chk
L_0207:
    p_sto
L_0208:
    p_ujp_direct L_020A
L_020A:
    p_ujp_direct L_0227
L_020C:
    p_sldl 9
L_020D:
    p_sldo 9
L_020E:
    p_equi
L_020F:
    p_ldl 293, 2
L_0212:
    p_land
L_0213:
    p_fjp_direct L_0227
L_0215:
    p_lla 5, 1
L_0217:
    p_sldc 12
L_0218:
    p_csp 1
L_021A:
    p_sldl 5
L_021B:
    p_inc 3, 1
L_021D:
    p_lla 20, 1
L_021F:
    p_mov 9, 1
L_0221:
    p_sldl 5
L_0222:
    p_sldl 2
L_0223:
    p_inc 2, 1
L_0225:
    p_cgp 11
L_0227:
    p_ldl 24, 1
L_0229:
    p_sldc 0
L_022A:
    p_equi
L_022B:
    p_fjp_table L_0230, L_024A
L_022D:
    p_rnp 0
L_022F:
    .byte 0
L_0230:
    .word (* - EXT_L_0059) & $FFFF
L_0232:
    .word (* - L_020C) & $FFFF
L_0234:
    .word (* - L_020A) & $FFFF
L_0236:
    .word (* - L_0208) & $FFFF
L_0238:
    .word (* - EXT_L_01C4) & $FFFF
L_023A:
    .word (* - EXT_L_013F) & $FFFF
L_023C:
    .word (* - EXT_L_00EE) & $FFFF
L_023E:
    .word (* - EXT_L_0111) & $FFFF
L_0240:
    .word (* - EXT_L_0076) & $FFFF
L_0242:
    .word 586
L_0244:
    .word 4
L_0246:
    .word * - L_022D
L_0248:
    .word * - EXT_L_0000
L_024A:
    .byte 22, $02
L_024C:
    p_sldl 1
L_024D:
    p_ldcn
L_024E:
    p_neqi
L_024F:
    p_fjp_table EXT_L_031A, EXT_L_0328
L_0251:
    p_sldl 1
L_0252:
    p_sind 2
L_0253:
    p_cip 26
L_0255:
    p_sldl 1
L_0256:
    p_sind 1
L_0257:
    p_cip 26
L_0259:
    p_sldl 1
L_025A:
    p_sind 0
L_025B:
    p_cip 26
L_025D:
    p_sldl 1
L_025E:
    p_inc 3, 1
L_0260:
    p_stl 4, 1
L_0262:
    p_sldl 4
L_0263:
    p_sind 4
L_0264:
    p_ldci 6144
L_0267:
    p_sldc 1
L_0268:
    p_inn
L_0269:
    p_fjp_table EXT_L_031C, EXT_L_0328
L_026B:
    p_sldl 4
L_026C:
    p_sind 5
L_026D:
    p_sldc 0
L_026E:
    p_leqi
L_026F:
    p_sldl 4
L_0270:
    p_sind 5
L_0271:
    p_lod 1, 5, 1
L_0274:
    p_gtri
L_0275:
    p_lor
L_0276:
    p_fjp_direct L_0289
L_0278:
    p_nop
L_0279:
    p_lsa 10
L_027B:
    .byte $62, $61, $64, $20, $70, $72, $6F, $63, $20, $23
L_0285:
    p_cgp 3
L_0287:
    p_ujp_table EXT_L_031E, EXT_L_0328
L_0289:
    p_lod 1, 7, 1
L_028C:
    p_sldc 2
L_028D:
    p_sbi
L_028E:
    p_sldc 2
L_028F:
    p_sldl 4
L_0290:
    p_sind 5
L_0291:
    p_mpi
L_0292:
    p_sbi
L_0293:
    p_stl 3, 1
L_0295:
    p_sldl 3
L_0296:
    p_lod 1, 2, 1
L_0299:
    p_sldl 3
L_029A:
    p_sldc 0
L_029B:
    p_sldc 0
L_029C:
    p_cgp 6
L_029E:
    p_sbi
L_029F:
    p_stl 3, 1
L_02A1:
    p_lod 1, 2, 1
L_02A4:
    p_sldl 3
L_02A5:
    p_sldc 0
L_02A6:
    p_sldc 0
L_02A7:
    p_cgp 5
L_02A9:
    p_sldl 4
L_02AA:
    p_sind 5
L_02AB:
    p_neqi
L_02AC:
    p_lod 1, 2, 1
L_02AF:
    p_sldl 3
L_02B0:
    p_sldc 0
L_02B1:
    p_sldc 0
L_02B2:
    p_cgp 5
L_02B4:
    p_sldc 0
L_02B5:
    p_neqi
L_02B6:
    p_land
L_02B7:
    p_fjp_direct L_02CF
L_02B9:
    p_lsa 15
L_02BB:
    .byte $64, $69, $73, $61, $67, $72, $65, $65, $69, $6E, $67, $20, $70, $20, $23
L_02CA:
    p_nop
L_02CB:
    p_cgp 3
L_02CD:
    p_ujp_direct EXT_L_0318
L_02CF:
    p_lod 1, 2, 1
L_02D2:
    p_sldl 3
L_02D3:
    p_sldc 2
L_02D4:
    p_sbi
L_02D5:
    p_sldc 0
L_02D6:
    p_sldc 0
L_02D7:
    p_cgp 6
L_02D9:
    p_sldc 4
L_02DA:
    p_adi
L_02DB:
    p_stl 2, 1
L_02DD:
    p_sldl 4
L_02DE:
    p_sind 7
L_02DF:
    p_inc 1, 1
L_02E1:
    p_sldl 3
L_02E2:
    p_sldc 2
L_02E3:
    p_adi
L_02E4:
    p_sldl 2
L_02E5:
    p_sbi
L_02E6:
    p_sto
L_02E7:
    p_sldl 4
L_02E8:
    p_sind 7
L_02E9:
    p_sind 1
L_02EA:
    p_sldc 0
L_02EB:
    p_lesi
L_02EC:
    p_sldl 2
L_02ED:
    p_sldc 0
L_02EE:
    p_leqi
L_02EF:
    p_lor
L_02F0:
    p_sldl 2
L_02F1:
    p_ldci 20000
.assert * - segment_start = 302, error, "Linker copy extent"
