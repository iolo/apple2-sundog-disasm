{ game_21 procedure29, $12D8..$1330, attributes $133A. }
procedure proc21_29;
begin
  proc22_23(20480, g21.map55.word);
  g21.words[23] := 4;
  g21.words[22] := 3;
  g21.words[21] := 8 * g21.words[22];
  g21.words[20] := 7;
  if (data29.nibbles45[1] = 2) or (data29.nibbles45[1] = 3) or
     (data29.nibbles45[1] = 11) then proc21_28
  else proc21_3;
  data29.words[353] := 2;
  if data29.flags45[13] then data29.words[351] := 120
  else data29.words[351] := 20
end;
