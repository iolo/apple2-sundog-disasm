{ game_8 procedure8, $025A..$0368, attributes $0376.
  Saves parent state for procedure18; parent arguments are mutable local words. }
procedure proc8_8;
var
  mode: integer;
begin
  g8b30 := data29.bounds11;
  g8a3[21] := data29.words[351];
  data29.words[351] := 1;
  g8a3[20] := data29.words[353];
  data29.words[353] := 15;
  mode := data29.nibbles45[1];
  if mode = 2 then
  begin
    arg2 := (data29.words[40] + 3) div 7;
    if arg2 < 17 then arg2 := 17;
    arg1 := (data29.bytes[80] - 3) div 8
  end;
  while arg2 > 19 do arg2 := arg2 - 1;
  while arg2 < 11 do arg2 := arg2 + 1;
  if not odd(arg2) then arg2 := arg2 + 1;
  proc22_51(arg2, arg1);
  data31.words[12] := 7 * (data29.words[14] div 7);
  data31.words[11] := 8 * (data29.words[12] div 8);
  proc27_13(0);
  proc22_18(g8b38, data31.words[12] + 55, data31.words[12] + 133,
              data31.words[11] + 2, data31.words[11] + 80);
  proc22_19(g8b38, 8);
  proc27_6(0);
  proc22_18(g8b26, g8b38.lower_first + 2, g8b38.upper_first - 2,
              g8b38.upper_second - 12, g8b38.upper_second - 2);
  proc22_18(g8b22, g8b38.lower_first + 2, g8b38.upper_first - 2,
              g8b38.upper_second - 26, g8b38.upper_second - 16);
  proc8_7;
  proc22_42(g8a3[13], g8a3[12], 2, data31.bounds2);
  g8a3[19] := 0
end;
