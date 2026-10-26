{ game_21 procedure36, $1852..$18FD, attributes $190A.
  Reprobe after each y decrement; the probe's low bit controls the loop.
  The input4 call still runs before its result is immediately overwritten. }
procedure proc21_36;
begin
  arg6 := (data29.bits38.low6 - 5 + 40) mod 40;
  arg5 := (data29.bits39.low5 - 3 + 24) mod 24;
  proc21_31(g21.words[26] + 3, g21.words[25] - 3, true, false);
  proc21_31(g21.words[26] + 3, g21.words[25] - 3, true, true);
  proc21_9;
  proc21_8;
  proc21_13(g21.words[26], g21.words[25], data29.pos36);
  data29.words[2] := 2;
  while odd(proc21_10(g21.words[29], g21.words[26], g21.words[25])) do
    g21.words[25] := g21.words[25] - 1;
  proc21_31(g21.words[26] + 3, g21.words[25] - 3, false, true);
  proc21_31(g21.words[26] + 3, g21.words[25] - 3, false, false);
  data29.words[2] := 9;
  arg4 := (g21.words[26] + 3) div 7;
  arg3 := (g21.words[25] - 3) div 8;
  g21.words[38] := proc22_2(4);
  g21.words[38] := 0
end;
