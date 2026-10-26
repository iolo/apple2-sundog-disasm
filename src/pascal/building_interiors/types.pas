{ Include after ../storage.pas in a type section.
  The names indicate word/bit offsets; game meanings remain unassigned. }
entry_flags = packed record
  bit0: boolean;
  bit1: boolean;
  bit2: boolean;
  bit3: boolean;
  bit4: boolean;
  bit5: boolean;
  bit6: boolean;
  bit7: boolean;
  high_byte: 0..255
end;
bytepair = packed record
  low: 0..255;
  high: 0..255
end;
entry10 = record
  case integer of
    0: (words: array[0..6] of integer;
        flags: entry_flags;           { Word 7. }
        word8: integer;
        bytes9: packed array[0..1] of 0..255);
    1: (before6: array[0..5] of integer;
        split6: bytepair;
        skip7: integer;
        split8: bytepair);
    2: (before9: array[0..8] of integer;
        pair9: bytepair)
end;
nibbles4 = packed array[0..3] of 0..15;

{ Two-word bounds in the setup table: high bytes are lower bounds and low
  bytes are upper bounds, before translation by the external origin. }
packedbounds = record
  second: bytepair;
  first: bytepair
end;
setupmodes = packed record
  low4: 0..15;
  next4: 0..15;
  high8: 0..255
end;
setupentry = record
  bounds: array[0..4] of packedbounds;  { Words 0..9. }
  modes: setupmodes;                   { Word 10. }
  bytes11: packed array[0..9] of 0..255 { Words 11..15. }
end;
setuptable = array[0..15] of setupentry; { One loaded 512-byte block. }
setupaddr = record
  case integer of
    0: (word: integer);
    1: (table: ^setuptable)
end;
