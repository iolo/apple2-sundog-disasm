{ library_22 procedure 13, $0196..$01C1, attributes $01CC. }
procedure set_line_mode(mode: integer);
begin
  data29.line_mode := mode;
  if data29.line_mode < 4 then data29.words[358] := 1
  else if data29.line_mode > 7 then data29.words[358] := -128
  else data29.words[358] := 0
end;
