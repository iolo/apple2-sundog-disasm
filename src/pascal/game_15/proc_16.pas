{ game_15 procedure16, $08E6..$0963, attributes $096E.
  Self EXIT occurs before state writes when the action is unchanged.
  Four unused local bytes are omitted. Game14 receives a VAR action. }
procedure proc15_16;
begin
  g15.words[1] := proc15_14(g15.words[6], g15.words[5]);
  if g15.words[1] = g15.words[4] then exit(proc15_16);
  g15.words[4] := g15.words[1];
  data29.nibbles45[1] := 2;
  data29.nibbles45[0] := 11;
  if g15.words[1] > 0 then
  begin
    proc15_15;
    if g15.words[1] = 1 then
    begin
      data29.nibbles45[2] := 0;
      proc15_4
    end
    else if g15.words[1] = 3 then proc15_7
    else if g15.words[1] = 4 then proc15_6
    else if not odd(data29.words[347]) and (g15.words[1] > 0) then
    begin
      proc14_1(g15.words[1], 0, 0);
      if not odd(data29.words[347]) then proc15_11
    end
  end
end;
