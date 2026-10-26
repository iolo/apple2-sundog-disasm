g21glyphs = packed array[0..15] of 0..255;
g21row = packed array[0..39] of 0..255;
g21map = array[0..23] of g21row;
g21addr = record
  case integer of
    0: (word: integer);
    1: (rows: ^g21map)
end;
{ The eight VAR parameter words precede114 local bytes, slots9..65. }
g21frame = record
  case integer of
    0: (words: array[9..65] of integer);
    1: (pad55: array[9..54] of integer;
        map55: g21addr);
    2: (pad62: array[9..61] of integer;
        area62: bounds4);
    3: (pad39: array[9..38] of integer;
        glyph39: g21glyphs;
        glyph47: g21glyphs)
end;
