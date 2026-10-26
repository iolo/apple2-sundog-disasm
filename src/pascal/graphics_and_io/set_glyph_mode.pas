{ Library 22:11, $0052..$007C, attributes $0086. One word argument, no result. }
procedure set_glyph_mode(mode: integer);
begin
  data29.glyph_mode := mode;                       { $0052..$0053 }
  if data29.glyph_mode = 3 then                    { $0057..$0064 }
    data29.words[357] := 63
  else if data29.glyph_mode = 0 then               { $0066..$0075 }
    data29.words[357] := 255
  else
    data29.words[357] := 0                         { $0077..$0078 }
end;
