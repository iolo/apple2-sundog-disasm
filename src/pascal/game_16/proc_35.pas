{ game_16 procedure35, $11B4..$1213, attributes $1220.
  Probe each of the first three rectangles before the signed enable check.
  The VAR flag is stored before sound/drawing and reread on the loop backedge;
  parent35 and the VAR selection are updated after those calls. }
procedure proc16_35(first, second: integer; var selected, found: integer);
var
  index: integer;
(*$include src/pascal/game_16/proc_36.pas*)
begin
  index := 0;
  found := 0;
  while (index < 3) and not odd(found) do
  begin
    if proc16_36(first, second, index) and (g16.words[90 + index] >= 0) then
    begin
      found := 1;
      proc22_4(30, 50, 10, 0, 0, 0, 0);
      if not (odd(g16.words[17]) and (index < 2)) then
        proc22_19(g16.buttons72[index], 3);
      g16.words[35] := g16.words[90 + index];
      selected := g16.words[95 + index]
    end
    else index := index + 1
  end
end;
