{ Native library24:3, $0E68..$0F20, attributes $0F5C.
  Pops four bytes (return plus one selector word) into $00..$03; restores
  only return. Low two selector bits choose XOR7F (0), fillFF (1/3), or
  fill00 (2); bit2 enables speaker reads during the writes. High byte ignored.
  Writes the table-defined expanding regions through HGR row tables at
  $0DC0/$0E80. Twelve shapes use the native offset/width/height tables and
  rows alternating around55/56. No Pascal result. }
procedure proc24_3(selector: integer); external;

{ Native library24:5, $1010..$109E, attributes $10AC.
  No arguments or result: saves return in $08/$09 and restores it before RTS.
  Reads encoded bytes at $4000: first byte is destination stride, followed
  by runs. High-bit-clear commands repeat the next byte count+1 times;
  high-bit-set commands copy (command AND127)+1 literals. Writes columns
  starting at $2000, stepping by stride until destination high byte reaches
  $40, then starts the next column. Requires the original encoded input at
  that fixed address; no invented buffer argument, bounds checks, or status.
  Game15 $0326..$033C loads the data through22:53 before this zero-arg call. }
procedure proc24_5; external;
