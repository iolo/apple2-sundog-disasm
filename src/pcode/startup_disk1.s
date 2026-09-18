; Disk-1 SYSTEM.STARTUP segment 1: logical block 141, 576 bytes.
; Observed load $B2B4, procedure-1 entry $B49C (segment offset $01E8).
; Reconstructed with tools/pcode_source.py; assembly origin is segment-relative.
; See docs/startup-pcode.md. Calls retain verified segment/procedure numbers.
.include "encoding.inc"
.segment "PCODE"
segment_start:

; Procedure 2, segment-relative offset $0000.
L_0000:
    p_cxp 22, 6 ; instruction
L_0003:
    p_sldc 0 ; instruction
L_0004:
    p_sldc 10 ; instruction
L_0005:
    p_cxp 22, 12 ; instruction
L_0008:
    p_csp 34 ; instruction
L_000A:
    p_sldc 3 ; instruction
L_000B:
    p_sldc 0 ; instruction
L_000C:
    p_cxp 22, 39 ; instruction
L_000F:
    p_sldc 0 ; instruction
L_0010:
    p_fjp_table L_0014, L_001E ; instruction
L_0012:
    p_rnp 0 ; instruction
L_0014:
    .word (* - L_000F) & $FFFF ; jump-pointer
L_0016:
    .word 0 ; local-size
L_0018:
    .word 0 ; parameter-size
L_001A:
    .word * - L_0012 ; exit-pointer
L_001C:
    .word * - L_0000 ; entry-pointer
L_001E:
    .byte 2, $01 ; attributes

; Procedure 3, segment-relative offset $0020.
L_0020:
    p_ujp_direct L_007D ; instruction
L_0022:
    p_sldc 0 ; instruction
L_0023:
    p_ste 29, 347, 2 ; instruction
L_0027:
    p_lae 29, 45, 1 ; instruction
L_002A:
    p_sldc 4 ; instruction
L_002B:
    p_sldc 8 ; instruction
L_002C:
    p_ldp ; instruction
L_002D:
    p_ujp_direct L_0041 ; instruction
L_002F:
    p_cxp 13, 1 ; instruction
L_0032:
    p_ujp_direct L_005C ; instruction
L_0034:
    p_cxp 15, 1 ; instruction
L_0037:
    p_ujp_direct L_005C ; instruction
L_0039:
    p_sldc 22 ; instruction
L_003A:
    p_sldc 9 ; instruction
L_003B:
    p_sldc 19 ; instruction
L_003C:
    p_cxp 16, 1 ; instruction
L_003F:
    p_ujp_direct L_005C ; instruction
L_0041:
    p_xjp 0, 9, 0, $00 ; instruction
L_0046:
    p_ujp_direct L_005C ; instruction
L_0048:
    .word (* - L_002F) & $FFFF ; case-pointer
L_004A:
    .word (* - L_002F) & $FFFF ; case-pointer
L_004C:
    .word (* - L_0034) & $FFFF ; case-pointer
L_004E:
    .word (* - L_0046) & $FFFF ; case-pointer
L_0050:
    .word (* - L_0046) & $FFFF ; case-pointer
L_0052:
    .word (* - L_0046) & $FFFF ; case-pointer
L_0054:
    .word (* - L_0046) & $FFFF ; case-pointer
L_0056:
    .word (* - L_0046) & $FFFF ; case-pointer
L_0058:
    .word (* - L_0046) & $FFFF ; case-pointer
L_005A:
    .word (* - L_0039) & $FFFF ; case-pointer
L_005C:
    p_lae 29, 45, 1 ; instruction
L_005F:
    p_sldc 4 ; instruction
L_0060:
    p_sldc 8 ; instruction
L_0061:
    p_ldp ; instruction
L_0062:
    p_sldc 11 ; instruction
L_0063:
    p_geqi ; instruction
L_0064:
    p_lae 29, 45, 1 ; instruction
L_0067:
    p_sldc 4 ; instruction
L_0068:
    p_sldc 8 ; instruction
L_0069:
    p_ldp ; instruction
L_006A:
    p_sldc 3 ; instruction
L_006B:
    p_equi ; instruction
L_006C:
    p_lor ; instruction
L_006D:
    p_lae 29, 45, 1 ; instruction
L_0070:
    p_sldc 4 ; instruction
L_0071:
    p_sldc 8 ; instruction
L_0072:
    p_ldp ; instruction
L_0073:
    p_sldc 4 ; instruction
L_0074:
    p_equi ; instruction
L_0075:
    p_lor ; instruction
L_0076:
    p_fjp_table L_0086, L_0090 ; instruction
L_0078:
    p_sldc 24 ; instruction
L_0079:
    p_csp 22 ; instruction
L_007B:
    p_ujp_direct L_0082 ; instruction
L_007D:
    p_sldc 24 ; instruction
L_007E:
    p_csp 21 ; instruction
L_0080:
    p_ujp_table L_0084, L_0090 ; instruction
L_0082:
    p_rnp 0 ; instruction
L_0084:
    .word (* - L_0022) & $FFFF ; jump-pointer
L_0086:
    .word (* - L_0027) & $FFFF ; jump-pointer
L_0088:
    .word 0 ; local-size
L_008A:
    .word 0 ; parameter-size
L_008C:
    .word * - L_0078 ; exit-pointer
L_008E:
    .word * - L_0020 ; entry-pointer
L_0090:
    .byte 3, $01 ; attributes

; Procedure 5, segment-relative offset $0092.
L_0092:
    p_ujp_direct L_00BA ; instruction
L_0094:
    p_lae 29, 45, 1 ; instruction
L_0097:
    p_sldc 4 ; instruction
L_0098:
    p_sldc 8 ; instruction
L_0099:
    p_ldp ; instruction
L_009A:
    p_sldc 8 ; instruction
L_009B:
    p_equi ; instruction
L_009C:
    p_fjp_direct L_00AC ; instruction
L_009E:
    p_lda 1, 1, 1 ; instruction
L_00A1:
    p_lod 1, 4, 1 ; instruction
L_00A4:
    p_lod 1, 3, 1 ; instruction
L_00A7:
    p_cxp 14, 1 ; instruction
L_00AA:
    p_ujp_direct L_00B5 ; instruction
L_00AC:
    p_lod 1, 4, 1 ; instruction
L_00AF:
    p_lod 1, 3, 1 ; instruction
L_00B2:
    p_cxp 8, 1 ; instruction
L_00B5:
    p_sldc 27 ; instruction
L_00B6:
    p_csp 22 ; instruction
L_00B8:
    p_ujp_direct L_00BF ; instruction
L_00BA:
    p_sldc 27 ; instruction
L_00BB:
    p_csp 21 ; instruction
L_00BD:
    p_ujp_table L_00C2, L_00CC ; instruction
L_00BF:
    p_rnp 0 ; instruction
L_00C1:
    .byte 0 ; alignment
L_00C2:
    .word (* - L_0094) & $FFFF ; jump-pointer
L_00C4:
    .word 0 ; local-size
L_00C6:
    .word 0 ; parameter-size
L_00C8:
    .word * - L_00B5 ; exit-pointer
L_00CA:
    .word * - L_0092 ; entry-pointer
L_00CC:
    .byte 5, $02 ; attributes

; Procedure 4, segment-relative offset $00CE.
L_00CE:
    p_sldc 0 ; instruction
L_00CF:
    p_stl 1, 1 ; instruction
L_00D1:
    p_sldc 0 ; instruction
L_00D2:
    p_stl 9, 1 ; instruction
L_00D4:
    p_lae 29, 82, 1 ; instruction
L_00D7:
    p_sldc 116 ; instruction
L_00D8:
    p_ixp 16, 1 ; instruction
L_00DB:
    p_sldc 0 ; instruction
L_00DC:
    p_stp ; instruction
L_00DD:
    p_lae 29, 82, 1 ; instruction
L_00E0:
    p_sldc 117 ; instruction
L_00E1:
    p_ixp 16, 1 ; instruction
L_00E4:
    p_sldc 0 ; instruction
L_00E5:
    p_stp ; instruction
L_00E6:
    p_sldc 0 ; instruction
L_00E7:
    p_ste 29, 347, 2 ; instruction
L_00EB:
    p_lae 29, 33, 1 ; instruction
L_00EE:
    p_csp 33 ; instruction
L_00F0:
    p_lae 29, 45, 1 ; instruction
L_00F3:
    p_sldc 4 ; instruction
L_00F4:
    p_sldc 8 ; instruction
L_00F5:
    p_ldp ; instruction
L_00F6:
    p_ujp_direct L_0148 ; instruction
L_00F8:
    p_lla 8, 1 ; instruction
L_00FA:
    p_lla 7, 1 ; instruction
L_00FC:
    p_lla 6, 1 ; instruction
L_00FE:
    p_lla 5, 1 ; instruction
L_0100:
    p_lla 4, 1 ; instruction
L_0102:
    p_lla 3, 1 ; instruction
L_0104:
    p_lla 2, 1 ; instruction
L_0106:
    p_lla 9, 1 ; instruction
L_0108:
    p_cxp 21, 1 ; instruction
L_010B:
    p_ujp_direct L_0160 ; instruction
L_010D:
    p_sldl 2 ; instruction
L_010E:
    p_sldc 3 ; instruction
L_010F:
    p_leqi ; instruction
L_0110:
    p_fjp_direct L_0118 ; instruction
L_0112:
    p_sldl 2 ; instruction
L_0113:
    p_cxp 19, 1 ; instruction
L_0116:
    p_ujp_direct L_011C ; instruction
L_0118:
    p_sldl 2 ; instruction
L_0119:
    p_cxp 20, 1 ; instruction
L_011C:
    p_ujp_direct L_0160 ; instruction
L_011E:
    p_sldl 2 ; instruction
L_011F:
    p_ldci 255 ; instruction
L_0122:
    p_equi ; instruction
L_0123:
    p_fjp_direct L_0130 ; instruction
L_0125:
    p_lla 4, 1 ; instruction
L_0127:
    p_lla 3, 1 ; instruction
L_0129:
    p_lla 1, 1 ; instruction
L_012B:
    p_cxp 17, 1 ; instruction
L_012E:
    p_ujp_direct L_013A ; instruction
L_0130:
    p_lla 4, 1 ; instruction
L_0132:
    p_lla 3, 1 ; instruction
L_0134:
    p_lla 1, 1 ; instruction
L_0136:
    p_sldl 2 ; instruction
L_0137:
    p_cxp 18, 1 ; instruction
L_013A:
    p_ujp_direct L_0160 ; instruction
L_013C:
    p_clp 5 ; instruction
L_013E:
    p_ujp_direct L_0160 ; instruction
L_0140:
    p_sldl 4 ; instruction
L_0141:
    p_sldl 3 ; instruction
L_0142:
    p_sldl 1 ; instruction
L_0143:
    p_cxp 16, 1 ; instruction
L_0146:
    p_ujp_direct L_0160 ; instruction
L_0148:
    p_xjp 3, 10, 1, $00 ; instruction
L_014E:
    p_ujp_direct L_0160 ; instruction
L_0150:
    .word (* - L_00F8) & $FFFF ; case-pointer
L_0152:
    .word (* - L_00F8) & $FFFF ; case-pointer
L_0154:
    .word (* - L_011E) & $FFFF ; case-pointer
L_0156:
    .word (* - L_010D) & $FFFF ; case-pointer
L_0158:
    .word (* - L_013C) & $FFFF ; case-pointer
L_015A:
    .word (* - L_013C) & $FFFF ; case-pointer
L_015C:
    .word (* - L_0140) & $FFFF ; case-pointer
L_015E:
    .word (* - L_013C) & $FFFF ; case-pointer
L_0160:
    p_lae 29, 45, 1 ; instruction
L_0163:
    p_sldc 4 ; instruction
L_0164:
    p_sldc 8 ; instruction
L_0165:
    p_ldp ; instruction
L_0166:
    p_sldc 2 ; instruction
L_0167:
    p_leqi ; instruction
L_0168:
    p_lae 29, 45, 1 ; instruction
L_016B:
    p_sldc 4 ; instruction
L_016C:
    p_sldc 8 ; instruction
L_016D:
    p_ldp ; instruction
L_016E:
    p_sldc 11 ; instruction
L_016F:
    p_geqi ; instruction
L_0170:
    p_lor ; instruction
L_0171:
    p_fjp_table L_0176, L_0180 ; instruction
L_0173:
    p_rnp 0 ; instruction
L_0175:
    .byte 0 ; alignment
L_0176:
    .word (* - L_00E6) & $FFFF ; jump-pointer
L_0178:
    .word 18 ; local-size
L_017A:
    .word 0 ; parameter-size
L_017C:
    .word * - L_0173 ; exit-pointer
L_017E:
    .word * - L_00CE ; entry-pointer
L_0180:
    .byte 4, $01 ; attributes

; Procedure 6, segment-relative offset $0182.
L_0182:
    p_ujp_direct L_01D3 ; instruction
L_0184:
    p_lae 29, 35, 1 ; instruction
L_0187:
    p_csp 32 ; instruction
L_0189:
    p_lae 29, 34, 1 ; instruction
L_018C:
    p_csp 32 ; instruction
L_018E:
    p_ldci 16384 ; instruction
L_0191:
    p_ste 29, 33, 1 ; instruction
L_0194:
    p_lae 29, 33, 1 ; instruction
L_0197:
    p_csp 33 ; instruction
L_0199:
    p_ldci 16384 ; instruction
L_019C:
    p_sldc 1 ; instruction
L_019D:
    p_sldc 80 ; instruction
L_019E:
    p_sldc 1 ; instruction
L_019F:
    p_cxp 22, 53 ; instruction
L_01A2:
    p_lde 29, 33, 1 ; instruction
L_01A5:
    p_sldc 6 ; instruction
L_01A6:
    p_ldb ; instruction
L_01A7:
    p_sldc 3 ; instruction
L_01A8:
    p_sbi ; instruction
L_01A9:
    p_cxp 22, 54 ; instruction
L_01AC:
    p_sldc 1 ; instruction
L_01AD:
    p_cxp 7, 1 ; instruction
L_01B0:
    p_lae 29, 45, 1 ; instruction
L_01B3:
    p_sldc 4 ; instruction
L_01B4:
    p_sldc 8 ; instruction
L_01B5:
    p_ldp ; instruction
L_01B6:
    p_sldc 2 ; instruction
L_01B7:
    p_leqi ; instruction
L_01B8:
    p_fjp_direct L_01BE ; instruction
L_01BA:
    p_cgp 3 ; instruction
L_01BC:
    p_ujp_direct L_01C0 ; instruction
L_01BE:
    p_cgp 4 ; instruction
L_01C0:
    p_lae 29, 45, 1 ; instruction
L_01C3:
    p_sldc 4 ; instruction
L_01C4:
    p_sldc 8 ; instruction
L_01C5:
    p_ldp ; instruction
L_01C6:
    p_sldc 11 ; instruction
L_01C7:
    p_geqi ; instruction
L_01C8:
    p_fjp_table L_01DC, L_01E6 ; instruction
L_01CA:
    p_sldc 0 ; instruction
L_01CB:
    p_cxp 7, 1 ; instruction
L_01CE:
    p_sldc 22 ; instruction
L_01CF:
    p_csp 22 ; instruction
L_01D1:
    p_ujp_direct L_01D8 ; instruction
L_01D3:
    p_sldc 22 ; instruction
L_01D4:
    p_csp 21 ; instruction
L_01D6:
    p_ujp_table L_01DA, L_01E6 ; instruction
L_01D8:
    p_rnp 0 ; instruction
L_01DA:
    .word (* - L_0184) & $FFFF ; jump-pointer
L_01DC:
    .word (* - L_01B0) & $FFFF ; jump-pointer
L_01DE:
    .word 2 ; local-size
L_01E0:
    .word 0 ; parameter-size
L_01E2:
    .word * - L_01CE ; exit-pointer
L_01E4:
    .word * - L_0182 ; entry-pointer
L_01E6:
    .byte 6, $01 ; attributes

; Procedure 1: load library segments, invoke their initializers, and call procedure 6.
; The exit path releases the data/library segments; names remain numeric.
; Procedure 1, segment-relative offset $01E8.
L_01E8:
    p_ujp_direct L_0212 ; instruction
L_01EA:
    p_cxp 22, 1 ; instruction
L_01ED:
    p_cxp 23, 1 ; instruction
L_01F0:
    p_cxp 24, 1 ; instruction
L_01F3:
    p_cxp 25, 1 ; instruction
L_01F6:
    p_cxp 26, 1 ; instruction
L_01F9:
    p_cxp 27, 1 ; instruction
L_01FC:
    p_cxp 28, 1 ; instruction
L_01FF:
    p_clp 6 ; instruction
L_0201:
    p_sldc 31 ; instruction
L_0202:
    p_csp 22 ; instruction
L_0204:
    p_sldc 30 ; instruction
L_0205:
    p_csp 22 ; instruction
L_0207:
    p_sldc 29 ; instruction
L_0208:
    p_csp 22 ; instruction
L_020A:
    p_sldc 31 ; instruction
L_020B:
    p_csp 22 ; instruction
L_020D:
    p_sldc 30 ; instruction
L_020E:
    p_csp 22 ; instruction
L_0210:
    p_ujp_direct L_0223 ; instruction
L_0212:
    p_sldc 30 ; instruction
L_0213:
    p_csp 21 ; instruction
L_0215:
    p_sldc 31 ; instruction
L_0216:
    p_csp 21 ; instruction
L_0218:
    p_sldc 29 ; instruction
L_0219:
    p_csp 21 ; instruction
L_021B:
    p_sldc 30 ; instruction
L_021C:
    p_csp 21 ; instruction
L_021E:
    p_sldc 31 ; instruction
L_021F:
    p_csp 21 ; instruction
L_0221:
    p_ujp_table L_0226, L_0230 ; instruction
L_0223:
    p_rbp 0 ; instruction
L_0225:
    .byte 0 ; alignment
L_0226:
    .word (* - L_01EA) & $FFFF ; jump-pointer
L_0228:
    .word 0 ; local-size
L_022A:
    .word 4 ; parameter-size
L_022C:
    .word * - L_0201 ; exit-pointer
L_022E:
    .word * - L_01E8 ; entry-pointer
L_0230:
    .byte 1, $00 ; attributes
L_0232:
    .word * - L_01E6 ; dictionary-pointer
L_0234:
    .word * - L_00CC ; dictionary-pointer
L_0236:
    .word * - L_0180 ; dictionary-pointer
L_0238:
    .word * - L_0090 ; dictionary-pointer
L_023A:
    .word * - L_001E ; dictionary-pointer
L_023C:
    .word * - L_0230 ; dictionary-pointer
L_023E:
    .byte 1, 6 ; segment-trailer
.assert * - segment_start = 576, error, "P-code segment size changed"
