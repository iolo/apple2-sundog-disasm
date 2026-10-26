{ game_21 procedure41, $1DFE..$1E3C, attributes $1E46.
  Preserve update/cursor calls before rereading the mode; unused local bytes
  have no observable role. }
procedure open_surface_personal;
begin
  toggle_pointer_glyph(g21.cursor_x, g21.cursor_y);
  run_personal_panel(window_x, window_y);
  initialize_pointer(g21.cursor_x, g21.cursor_y, data29.words[298], g21.pointer_bounds);
  if data29.nibbles45[2] <> 11 then
    data29.nibbles45[1] := data29.nibbles45[2];
  g21.was_moving := 0
end;
