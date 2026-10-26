{ game_19 procedure19, $0DD0..$0E39, attributes $0E42; nested in18.
  The price comparison always executes, even with no remaining units. }
procedure proc19_19;
var
  empty, costly: boolean;
begin
  data29.words[19] := column;
  data29.words[18] := row;
  proc22_49(needed, 3, false);
  proc22_47(32);
  proc22_48(unitname);
  if needed = 1 then proc22_48(' \') else proc22_48('s\');
  proc28_5('Cash on hand ', g19.amount10);
  empty := needed = 0;
  costly := proc28_6(cost, g19.amount10);
  blocked := empty or costly or (quantity = 16)
end;
