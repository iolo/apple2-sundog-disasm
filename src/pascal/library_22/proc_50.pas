{ library_22 procedure 50, $0A36..$0A55, attributes $0A60. }
procedure proc22_50(firstlow, firsthigh, secondlow, secondhigh: integer);
begin
  proc22_18(data29.bounds11, firstlow, firsthigh, secondlow, secondhigh);
  proc22_19(data29.bounds11, 0);
  data29.words[19] := firstlow + 2;
  data29.words[18] := secondlow + 10;
  data29.words[17] := firsthigh
end;
