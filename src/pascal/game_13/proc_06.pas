{ game_13 procedure6, $010C..$0161, attributes $016C; nested in3. }
procedure proc13_6;
begin
  data29.nibbles45[1] := data29.nibbles45[2];
  g13s.saved18 := data29.bounds327;
  g13s.words[4] := data29.words[353];
  data29.words[353] := 2;
  g13s.words[1] := data29.words[351];
  data29.words[351] := 1;
  g13s.words[8] := ord(data29.flags82[5]);
  data29.flags82[5] := false;
  g13s.words[9] := ord(odd(g13s.words[8]) and (data29.words[203] = 2));
  if odd(g13s.words[9]) then proc13_5
end;
