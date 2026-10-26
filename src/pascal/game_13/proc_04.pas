{ game_13 procedure4, $0072..$0092, attributes $009E; nested in3.
  Emit spaces until external word18 changes, then restore the requested
  position. There is no fixed count or timeout in the original. }
procedure proc13_4(column, row: integer);
var
  before: integer;
begin
  proc22_11(3);
  proc22_46(column, row);
  before := data29.words[18];
  while data29.words[18] = before do proc22_47(32);
  proc22_46(column, row)
end;
