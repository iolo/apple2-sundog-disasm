{ game_21 procedure27, $1070..$10E5, attributes $10F0. }
procedure proc21_27;
begin
  proc22_23(21504, g21.map55.word);
  g21.words[23] := 3;
  g21.words[22] := 4;
  g21.words[21] := 8 * g21.words[22];
  g21.words[20] := 5;
  if (data29.nibbles45[1] = 2) or (data29.nibbles45[1] = 4) or
     (data29.nibbles45[1] = 11) or data29.flags82[114] or
     data29.flags82[28] then proc21_26
  else proc21_3;
  g21.words[35] := ord(data29.bits37.mid6 = 60);
  data29.words[353] := 10;
  if data29.flags45[13] then data29.words[351] := 10
  else data29.words[351] := 1
end;
