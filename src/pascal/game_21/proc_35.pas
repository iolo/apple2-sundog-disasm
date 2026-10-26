{ game_21 procedure35, $177E..$17A8, attributes $17B2; nested in33.
  Native5 writes two adjacent words. Draw old and new positions before
  either VAR output is stored; retain store order if the outputs alias. }
procedure proc21_35(var newcol, newrow: integer);
var
  coords: wordpair;
begin
  proc22_5(coords);
  coords.first := coords.first div 7;
  coords.second := coords.second div 8;
  if (coords.first <> newcol) or (coords.second <> newrow) then
  begin
    proc21_34(newcol, newrow);
    proc21_34(coords.first, coords.second);
    newcol := coords.first;
    newrow := coords.second
  end
end;
