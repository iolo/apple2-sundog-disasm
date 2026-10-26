{ utility_disk1:28 $0DC4..$0DF5, attributes$0E02. Parameters3 unused x,
  2 y,1 VAR selection; locals4 row,5 index. First vertical match wins. }
procedure pick_attribute_row(x, y: integer; var stat_index: integer);
var
  row: integer;
  index: integer;
begin
  index := 0;
  stat_index := -1;
  row := stat_editor.first_bar_y;
  while index < 5 do
  begin
    if word_abs(y - row) < 8 then
    begin
      stat_index := index;
      index := 5
    end
    else
    begin
      index := index + 1;
      row := row + 16
    end
  end
end;
