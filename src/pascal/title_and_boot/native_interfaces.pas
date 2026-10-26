{ Both library_26_disk1 and library_26_disk2 have identical native bodies.
  These signatures document original stack contracts, not runtime bindings.

  3 $07BA..$07F3: pops10 bytes: return2, result reservation4, blocks2,
  address2. Restores one result word and return. Doubles blocks' LOW BYTE;
  zero after doubling means256 pages, not zero work. For each256-byte page,
  sums even and odd bytes independently modulo256 into result low/high.
  Increments the address high byte after each page, wrapping at64K.
  Clobbers ZP$00..$09 and A/X/Y/flags; no source writes. }
function even_odd_checksum(address, blocks: integer): integer; external;

{ 8 $07A8..$07AB: no parameters/result. Reads $C08A, jumps to slot6 ROM
  $C600. Does not restore/return through the Pascal call frame. }
procedure reboot_slot6; external;

{ 9 $0800..$088E: pops return2 and pattern,y,x (six argument bytes),
  restores return only. Uses full x via18's unchecked division table;
  y and pattern use low bytes. Writes one HGR byte per row: four zero,
  four pattern,32 zero,four pattern,four zero, advancing y modulo256. }
procedure paint_title_border_column(x, y, pattern: integer); external;

{ 10 $08AE..$092D: pops return2 and destination,lasty,firsty,right,left
  (ten argument bytes). Converts both x coordinates through18. Copies
  inclusive byte columns, descending within each row, to contiguous memory;
  rows run firsty..lasty inclusive with byte wrap. Destination advances16-bit.
  Column difference wraps8-bit; no clipping or range validation. }
procedure save_title_strip(left, right, firsty, lasty, destination: integer); external;

{ 11 $0942..$09C0: pops return2 and y,x,phase,sprite (eight argument bytes).
  Uses low sprite/phase bytes to select an image near$4000, phase bit0
  selecting the$80 offset; the byte additions retain native carry behavior.
  Copies24 rows of four bytes, ORing$80 into each destination byte; x uses
  helper18, y wraps8-bit, source increments16-bit by4 per row. }
procedure blit_title_letter(sprite, phase, x, y: integer); external;

{ 12 $09D4..$0A6E: pops return2 and column,source,lasty,firsty,right,left
  (twelve argument bytes). Converts left/right/column through18, offsets
  source by byte-column, and writes ONE byte per inclusive row at column.
  Source advances by wrapped8-bit(rightbyte-leftbyte)+1, with16-bit carry.
  It does not restore a whole rectangular row. }
procedure restore_title_column(left, right, firsty, lasty, source, column: integer); external;

{ Native9..12 restore their saved return and produce no Pascal result.
  They share/clobber ZP$00..$1E as used by their bodies and helper18; A/X/Y
  and flags are not preserved. They depend on row tables$0DC0/$0E80.

  Dictionary18 is an INTERNAL REGISTER-CALL helper, not a Pascal signature.
  $0A86..$0A93: x coordinate in$0E/$0F, result A. If highbyte=0, lookup
  table[xlow]; otherwise table[256+xlow], irrespective of highbyte's value.
  Only indices0..279 are the evidenced floor(x/7) table; larger indices read
  following code/data. Clobbers X and flags, leaves Y. Native9..12 call it
  with JSR and procedure/segment relocations, not CXP.
  $0BAC..$0BBB: byte column in A, row in X; saves column to$10, sets$0E to
  rowlow[X]+column modulo256 and$0F to rowhigh[X] WITHOUT carrying into it.
  Returns A=rowhigh[X], clobbers$0E/$0F/$10 and flags. No Pascal declaration
  is invented for these register entries.

  Raw22:25 target$6000 is the certificate reveal overlay. Its first8 bytes
  consume return2 and one unused pointer2; it restores only return, then
  scrolls HGR rows from$4000 onto$2000. Caller7 passes local11's address.
  See src/native/certificate_reveal.s and docs/certificate-reveal.md. }
procedure call_certificate_reveal(var unused: integer; target: integer); external;
