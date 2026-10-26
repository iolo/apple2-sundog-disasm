{ utility_disk1:28 $0DC4..$0DF5, attributes$0E02. Parameters3 unused x,
  2 y,1 VAR selection; locals4 row,5 index. First vertical match wins. }
procedure util1_28(x, y: integer; var selection: integer);
var
  row: integer;
  index: integer;
begin
  index := 0;
  selection := -1;
  row := attrwork.words[5];
  while index < 5 do
  begin
    if proc22_35(y - row) < 8 then
    begin
      selection := index;
      index := 5
    end
    else
    begin
      index := index + 1;
      row := row + 16
    end
  end
end;
