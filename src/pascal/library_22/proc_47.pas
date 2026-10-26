{ library_22 procedure 47, $08AA..$08D7, attributes $08E2.
  Position/bounds loads after drawing are deliberately not cached. }
procedure proc22_47(code: integer);
begin
  if data29.words[19] > data29.words[17] - 5 then proc22_45;
  proc22_12(data29.words[19], data29.words[18]);
  proc22_9(code);
  data29.words[19] := data29.words[19] + 6;
  if data29.words[19] > data29.words[17] - 5 then proc22_45
end;
