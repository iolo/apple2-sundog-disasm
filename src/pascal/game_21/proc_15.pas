{ game_21 procedure15, $06D8..$0775, attributes $077E.
  Both distance calls execute before the combined rejection. The adjusted
  saved parent15 value is retained even though this body never reads it again. }
procedure proc21_15(var changed: integer);
var
  xpos, ypos, saved, xradius, yradius: integer;
  nearx, neary: boolean;
begin
  changed := 0;
  proc21_13(xpos, ypos, data29.pos72);
  saved := g21.words[15];
  if not data29.flags45[13] then
  begin
    if g21.words[30] <> 16 then exit(proc21_15);
    xpos := xpos + 7;
    saved := saved + 7;
    xradius := 6;
    yradius := 4
  end
  else
  begin
    xradius := 4;
    yradius := 4
  end;
  nearx := proc21_14(g21.words[26], xpos, xradius);
  neary := proc21_14(g21.words[25], ypos, yradius);
  if not nearx or not neary then exit(proc21_15);
  changed := 1;
  data29.nibbles45[1] := data29.nibbles45[2];
  data29.flags45[12] := data29.flags45[13];
  if data29.flags45[13] then data29.nibbles45[2] := 2
  else
  begin
    data29.nibbles45[2] := 2;
    data29.flags82[7] := true;
    data29.words[294] := data29.words[296]
  end
end;
