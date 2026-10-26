{ library_22 procedure 13, $0196..$01C1, attributes $01CC. }
procedure proc22_13(mode: integer);
begin
  data29.words[366] := mode;
  if data29.words[366] < 4 then data29.words[358] := 1
  else if data29.words[366] > 7 then data29.words[358] := -128
  else data29.words[358] := 0
end;
