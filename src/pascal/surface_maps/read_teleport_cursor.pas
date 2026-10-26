{ game_21 procedure35, $177E..$17A8, attributes $17B2; nested in33.
  Native5 writes two adjacent words. Draw old and new positions before
  either VAR output is stored; retain store order if the outputs alias. }
procedure read_teleport_cursor(var cursor_column, cursor_row: integer);
var
  coords: wordpair;
begin
  read_input_coordinates(coords);
  coords.first := coords.first div 7;
  coords.second := coords.second div 8;
  if (coords.first <> cursor_column) or (coords.second <> cursor_row) then
  begin
    toggle_teleport_cursor(cursor_column, cursor_row);
    toggle_teleport_cursor(coords.first, coords.second);
    cursor_column := coords.first;
    cursor_row := coords.second
  end
end;
