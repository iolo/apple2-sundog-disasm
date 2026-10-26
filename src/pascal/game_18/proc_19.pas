{ game_18 procedure 19, $0D5E..$0DFE, attributes $0E0A. }
procedure proc18_19;
var
  firsthigh, secondbase, firstlow: integer;
  secondhi, secondlo, firstlo, firsthi, column: integer;
begin
  firstlow := data29.words[14] - 2;
  firsthigh := data29.words[13] + 2;
  secondbase := data29.words[12] - 2;
  proc22_18(g18b99, firstlow, firsthigh, secondbase + 8, secondbase + 27);
  proc22_18(g18b103, firstlow, firsthigh, secondbase + 28, secondbase + 40);
  column := 0;
  while column <= 3 do
  begin
    firstlo := (firstlow + 21) + column * 28;
    firsthi := firstlo + 20;
    secondlo := secondbase + 8;
    secondhi := secondlo + 19;
    proc22_14(firstlo, firsthi, secondlo, secondhi);
    proc22_7(g18w146);
    firstlo := firstlo + 7;
    firsthi := firstlo + 7;
    secondhi := secondlo + 28;
    proc22_14(firstlo, firsthi, secondlo, secondhi);
    proc22_7(g18w146);
    g18f98[column] := true;
    proc18_15(column + 1, false);
    column := column + 1
  end;
  proc22_19(data29.bounds11, 0)
end;
