{ game_16 procedure45, $1A06..$1A43, attributes $1A4E.
  Copy all four bounds before drawing; clear them only after waiting. }
procedure show_dialog_clock;
begin
  data29.bounds327 := data31.bounds6;
  apply_bounds(data29.bounds327, 8);
  set_glyph_mode(3);
  move_pen(data29.words[330] + 7, data29.words[327]);
  draw_clock(data29.clock42);
  wait_dialog_input;
  apply_bounds(data29.bounds327, 8);
  assign_bounds(data29.bounds327, 0, 0, 0, 0)
end;
