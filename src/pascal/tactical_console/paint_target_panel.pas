{ game_12 procedure4, $006A..$0114, attributes $0124; nested in1.
  Clear even without a target; draw six glyphs in two rows, toggling the
  buffer before/after, then establish parent bounds37 and draw the hull bar. }
procedure paint_target_panel;
var
  xpos: integer; {1}
  target_glyph: integer; {2}
  column: integer; {3}
  row: integer; {4}
  last_row: integer; {5}
  last_column: integer; {6}
begin
  clear_text_window;
  if odd(g12.target_present) then
  begin
    set_text_grid_position(1, 2);
    write_wrapped_text('ID:');
    set_text_grid_position(1, 5);
    write_wrapped_text('Target hull:');
    swap_tactical_buffers;
    target_glyph := 80 + 3 * data29.target_class;
    set_glyph_mode(0);
    row := 0;
    last_row := 1;
    while row <= last_row do
    begin
      set_text_grid_position(15, 1 + 2 * row);
      xpos := data29.text_x;
      column := 0;
      last_column := 2;
      while column <= last_column do
      begin
        move_pen(xpos, data29.text_y);
        draw_glyph(target_glyph);
        xpos := xpos + 7;
        target_glyph := target_glyph + 1;
        column := column + 1
      end;
      target_glyph := target_glyph + 29;
      row := row + 1
    end;
    swap_tactical_buffers;
    set_text_grid_position(0, 8);
    assign_bounds(g12.hull37, data29.text_x + 10, data29.text_x + 96,
                data29.text_y - 8, data29.text_y);
    draw_target_hull
  end
end;
