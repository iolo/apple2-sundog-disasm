{ game_13 procedure6, $010C..$0161, attributes $016C; nested in3. }
procedure setup_status_window;
begin
  data29.nibbles45[1] := data29.nibbles45[2];
  g13s.saved_clock_area := data29.bounds327;
  g13s.saved_tick_limit := data29.words[353];
  data29.words[353] := 2;
  g13s.saved_time_step := data29.words[351];
  data29.words[351] := 1;
  g13s.saved_map_flag := ord(data29.flags82[5]);
  data29.flags82[5] := false;
  g13s.restore_ship_glyph := ord(odd(g13s.saved_map_flag) and (data29.map_view_kind = 2));
  if odd(g13s.restore_ship_glyph) then toggle_orbital_marker
end;
