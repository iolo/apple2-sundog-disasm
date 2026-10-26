{ game_8 procedure8, $025A..$0368, attributes $0376.
  Saves parent state for procedure18; parent arguments are mutable local words. }
procedure setup_personal_panel;
var
  mode: integer;
begin
  saved_personal_bounds := data29.bounds11;
  personal_state[21] := data29.words[351];
  data29.words[351] := 1;
  personal_state[20] := data29.words[353];
  data29.words[353] := 15;
  mode := data29.nibbles45[1];
  if mode = 2 then
  begin
    window_x := (data29.words[40] + 3) div 7;
    if window_x < 17 then window_x := 17;
    window_y := (data29.bytes[80] - 3) div 8
  end;
  while window_x > 19 do window_x := window_x - 1;
  while window_x < 11 do window_x := window_x + 1;
  if not odd(window_x) then window_x := window_x + 1;
  push_text_window(window_x, window_y);
  data31.words[12] := 7 * (data29.words[14] div 7);
  data31.words[11] := 8 * (data29.words[12] div 8);
  setup_item_panel(0);
  assign_bounds(stats_bounds, data31.words[12] + 55, data31.words[12] + 133,
              data31.words[11] + 2, data31.words[11] + 80);
  apply_bounds(stats_bounds, 8);
  draw_panel_items_after(0);
  assign_bounds(sleep_button_bounds, stats_bounds.lower_first + 2, stats_bounds.upper_first - 2,
              stats_bounds.upper_second - 12, stats_bounds.upper_second - 2);
  assign_bounds(save_button_bounds, stats_bounds.lower_first + 2, stats_bounds.upper_first - 2,
              stats_bounds.upper_second - 26, stats_bounds.upper_second - 16);
  paint_condition_panel;
  initialize_pointer(personal_state[13], personal_state[12], 2, data31.bounds2);
  personal_state[19] := 0
end;
