{ game_15 procedure12, $06EE..$0700, attributes $070A.
  Return the whole word1 after the mode2 native draw/query, without coercing
  it to Boolean. Arguments occupy slots5=code,4=x,3=y. }
function proc15_12(code, x, y: integer): integer;
begin
  proc22_11(2);
  proc22_12(x, y);
  proc22_9(code);
  proc15_12 := data29.words[1]
end;
