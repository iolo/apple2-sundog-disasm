{ game_16 procedure42, $1748..$178B, attributes $1796; nested in41.
  Transfer price before updating elapsed ticks/item count, then dispatch the
  first action with previous item7. Both buffer-selection calls remain. }
procedure proc16_42;
begin
  if odd(g16.words[18]) then proc28_2(g16.price106, g16.cash104)
  else proc28_3(g16.price106, g16.cash104);
  g16.words[43] := g16.words[43] + 2;
  data31.words[16] := data31.words[16] - 1;
  proc22_21(0, false);
  g16.words[41] := previous;
  proc16_34(g16.words[95], 0);
  proc22_21(0, false)
end;
