{ game_16 procedure45, $1A06..$1A43, attributes $1A4E.
  Copy all four bounds before drawing; clear them only after waiting. }
procedure proc16_45;
begin
  data29.bounds327 := data31.bounds6;
  proc22_19(data29.bounds327, 8);
  proc22_11(3);
  proc22_12(data29.words[330] + 7, data29.words[327]);
  proc22_28(data29.clock42);
  proc16_44;
  proc22_19(data29.bounds327, 8);
  proc22_18(data29.bounds327, 0, 0, 0, 0)
end;
