{ game_21 procedure16, $0780..$07D8, attributes $07E2.
  Both proximity calls run; copy their combined output through parent arg1,
  then reread it. These VAR references may alias. }
procedure proc21_16(var changed: integer);
var
  xpos, ypos: integer;
  nearx, neary: boolean;
begin
  changed := 0;
  proc21_13(xpos, ypos, data29.pos228);
  nearx := proc21_14(g21.words[26], xpos, 4);
  neary := proc21_14(g21.words[25], ypos, 4);
  changed := ord(nearx and neary);
  arg1 := changed;
  if odd(arg1) then
  begin
    proc22_41(g21.words[19], g21.words[18]);
    data29.nibbles45[1] := 5;
    data29.flags45[12] := false;
    data29.flags45[13] := false;
    proc21_5;
    data29.rec36 := data29.rec228
  end
end;
