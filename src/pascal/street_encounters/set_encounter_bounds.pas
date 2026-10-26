{ game_17 procedure10, $03DE..$040D, attributes $0416.
  Parent VAR slots3/2 are caller-owned addresses. Bounds are loaded after
  the optional call. }
procedure set_encounter_bounds(setup: boolean);
begin
  if setup then push_text_window(window_x, window_y);
  g17.arena_left := data29.words[14] - 2;
  g17.arena_right := data29.words[13] + 2;
  g17.arena_top := data29.words[12] - 2;
  g17.arena_bottom := data29.words[11] + 2
end;
