{ game_16 procedure34, $111A..$117B, attributes $1188.
  Only the redirect flag21 resets on each dispatch. Bank changes store39 before
  I/O and table repair; return records the possibly rewritten action at44. }
procedure proc16_34(action, cursor: integer);
var
  bank: integer;
begin
  if odd(cursor) then proc22_41(g16.words[13], g16.words[12]);
  data29.words[354] := 0;
  g16.words[22] := 1;
  repeat
    g16.words[21] := 0;
    if action < 16 then proc16_33(action)
    else
    begin
      bank := action div 16 - 1;
      if g16.words[39] <> bank then
      begin
        g16.words[39] := bank;
        proc22_53(18432, 1, g16.words[9] + g16.words[39], true);
        proc16_32
      end;
      proc16_23(action)
    end
  until not odd(g16.words[21]);
  g16.words[44] := action;
  if odd(cursor) then proc22_41(g16.words[13], g16.words[12])
end;
