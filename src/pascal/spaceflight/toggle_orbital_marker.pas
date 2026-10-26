{ game_13 procedure5, $00A0..$00FF, attributes $010A; nested in3.
  Capture each lower bound before the native shift, then derive and draw
  coordinates through native24:4. The code is read after positioning. }
procedure toggle_orbital_marker;
var
  y: integer;
  x: integer;
  midy: integer;
  midx: integer;
begin
  midx := data29.words[346] + right_shift_word(data29.words[345] - data29.words[346], 1);
  midy := data29.words[344] + right_shift_word(data29.words[343] - data29.words[344], 1);
  apply_bounds(data29.bnd343, 0);
  project_polar_point(data29.pos72.fields.w0low, data29.pos72.fields.w0high, x, y);
  set_glyph_mode(1);
  move_pen((x + midx) - 3, (y + midy) + 3);
  draw_glyph(data29.words[294])
end;
