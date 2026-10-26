{ game_21 procedure24, $0C06..$0C13, attributes $0C1C; nested in23. }
procedure proc21_24(evenpix, oddpix, probe: integer);
begin
  g21.words[30] := evenpix;
  g21.words[31] := oddpix;
  g21.words[29] := probe
end;
