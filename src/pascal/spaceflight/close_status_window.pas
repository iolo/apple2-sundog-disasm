{ game_13 procedure11, $0622..$069E, attributes $06A8; nested in3.
  Restore rates and bounds before restoring the screen. Recheck bounds after
  that call, restore flag5, clear118/119, then conditionally redraw. }
procedure close_status_window;
begin
  data29.words[353] := g13s.saved_tick_limit;
  data29.words[351] := g13s.saved_time_step;
  data29.bounds327 := g13s.saved_clock_area;
  pop_text_window;
  if (data29.words[330] < data29.words[329]) and (data29.words[328] < data29.words[327]) then
  begin
    apply_bounds(data29.bounds327, 0);
    move_pen(data29.words[330] + 3, data29.words[327]);
    draw_clock(data29.clock42)
  end;
  data29.flags82[5] := odd(g13s.saved_map_flag);
  data29.flags82[118] := false;
  data29.flags82[119] := false;
  if (data29.nibbles45[2] = data29.nibbles45[1]) and odd(g13s.restore_ship_glyph) then toggle_orbital_marker
end;
