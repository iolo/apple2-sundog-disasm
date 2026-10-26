{ game_21 procedure41, $1DFE..$1E3C, attributes $1E46.
  Preserve update/cursor calls before rereading the mode; unused local bytes
  have no observable role. }
procedure proc21_41;
begin
  proc22_41(g21.words[19], g21.words[18]);
  proc8_1(arg4, arg3);
  proc22_42(g21.words[19], g21.words[18], data29.words[298], g21.area62);
  if data29.nibbles45[2] <> 11 then
    data29.nibbles45[1] := data29.nibbles45[2];
  g21.words[38] := 0
end;
