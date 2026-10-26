{ game_13 procedure4, $0072..$0092, attributes $009E; nested in3.
  Emit spaces until external word18 changes, then restore the requested
  position. There is no fixed count or timeout in the original. }
procedure blank_text_row(column, row: integer);
var
  original_text_y: integer;
begin
  set_glyph_mode(3);
  set_text_grid_position(column, row);
  original_text_y := data29.text_y;
  while data29.text_y = original_text_y do write_text_glyph(32);
  set_text_grid_position(column, row)
end;
