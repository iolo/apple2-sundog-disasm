{ game_20 procedure14, $0822..$084B, attributes $0854; nested in13.
  Reads enclosing row/column slots6/7, not procedure15's unused arguments. }
procedure proc20_14;
begin
  proc22_14(data29.words[14], data29.words[13], row - 8, data29.words[11]);
  proc22_7(8);
  proc22_19(data29.bounds11, 0);
  data29.words[19] := column;
  data29.words[18] := row
end;
