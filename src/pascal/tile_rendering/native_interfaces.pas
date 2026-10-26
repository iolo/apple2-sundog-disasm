{ Native library23:2, $000C..$006A: pops return address plus destination
  and source address words. Expands24 rows of40 bytes using its state table.
  The source is also modified by ROR stores at $0032. No result is pushed. }
procedure expand_tile_map(source, destination: integer); external;

{ Native library23:3, $00B6..$019C: callers push five words, in this order.
  The native prologue nevertheless pops16 bytes: return address, these five
  words, then four further stack bytes into unused $0C..$0F. It restores only
  the return address. Preserve this extra stack consumption when binding the
  original native body; this declaration documents caller arity, not a normal
  five-word callee cleanup. Do not invent two additional Pascal arguments.
  $02=map address, $04=start row, $06=start column, $08=tile height,
  $0A=row count (low bytes used except address/row-address arithmetic).
  Reads tile data and $0DC0/$0E80 scanline tables, writes display memory. }
procedure draw_tile_rows(row_count, tile_height, start_column, start_row, map_address: integer); external;

{ Native library23:4, $01AC..$0247: pops return address plus four words.
  Low bytes at $08/$06 are left/right byte columns, $04/$02 top/bottom
  scanlines. XORs the rectangle edges through $0DC0/$0E80; no Pascal result. }
procedure xor_map_rectangle(leftcol, rightcol, top, bottom: integer); external;
