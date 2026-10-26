{ game_21 procedure5, $0084..$00A5, attributes $00AE.
  The coordinate at parent26 is tested by low bit, not compared with zero. }
procedure proc21_5;
begin
  proc22_11(1);
  proc22_12(g21.words[26], g21.words[25]);
  if odd(g21.words[26]) then proc22_9(g21.words[31])
  else proc22_9(g21.words[30])
end;
