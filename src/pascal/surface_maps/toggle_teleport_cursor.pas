{ game_21 procedure34, $1754..$1772, attributes $177C; nested in33.
  Bases remain in parent slots5/4, with horizontal6 and vertical7 steps. }
procedure toggle_teleport_cursor(cursor_column, cursor_row: integer);
begin
  set_glyph_mode(1);
  move_pen(view_x_base - 1 + 6 * cursor_column, view_y_base + 7 * cursor_row);
  draw_glyph(data29.words[298])
end;
