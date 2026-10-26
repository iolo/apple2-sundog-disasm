{ game_8 procedure18, $0AF4..$0B48, attributes $0B52. }
procedure proc8_18;
begin
  proc22_41(g8a3[13], g8a3[12]);
  proc22_52;
  data29.nibbles45[2] := data29.nibbles45[1];
  if data29.nibbles45[2] >= 5 then
    data29.nibbles45[1] := data29.nibbles45[0]
  else data29.nibbles45[1] := 7;
  data29.nibbles45[0] := 11;
  data29.bounds11 := g8b30;
  data29.words[351] := g8a3[21];
  data29.words[353] := g8a3[20]
end;
