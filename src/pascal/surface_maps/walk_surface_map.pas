{ game_21 procedure12, $03C4..$0668, attributes $0678.
  Preserve full/axis-only probe order, one-pixel retry after a failed doubled
  step, low-bit flags, horizontal edge priority, and explicit self EXIT after
  leaving a city. Slots1..15 retain the original30-byte local frame. }
procedure walk_surface_map;
var
  radius_y: integer;
  radius_x: integer;
  next_y: integer;
  next_x: integer;
  step_y: integer;
  step_x: integer;
  tries: integer;
  unused8: integer;
  heading_index: integer;
  old_y: integer;
  old_x: integer;
  delta_y: integer;
  delta_x: integer;
  mask_glyph: integer;
  blocked: boolean;
begin
  if odd(g21.planet_view) then
  begin
    step_x := word_sign(right_shift_word(g21.cursor_x - 3 - g21.player_x, 3));
    step_y := word_sign(right_shift_word(g21.cursor_y + 3 - g21.player_y, 3))
  end
  else
  begin
    step_x := word_sign(g21.cursor_x + 7 - (g21.cursor_x + 7) mod 14 -
                         3 - g21.player_x);
    step_y := word_sign(word_and(g21.cursor_y + 8, -16) + 3 - g21.player_y)
  end;
  if (step_x <> 0) or (step_y <> 0) then
  begin
    if odd(g21.use_heading_glyphs) then
    begin
      heading_index := 5 + 3 * step_x + step_y;
      old_x := g21.player_x;
      old_y := g21.player_y
    end
    else mask_glyph := g21.collision_glyph;
    if data29.flags45[13] or (g21.last_x_step <> step_x) or
       (g21.last_y_step <> step_y) then
    begin
      tries := 1;
      delta_x := step_x;
      delta_y := step_y;
      g21.last_x_step := delta_x;
      g21.last_y_step := delta_y
    end
    else
    begin
      tries := 2;
      delta_x := step_x + step_x;
      delta_y := step_y + step_y
    end;
    toggle_surface_player;
    repeat
      blocked := false;
      next_x := g21.player_x + delta_x;
      next_y := g21.player_y + delta_y;
      if odd(g21.use_heading_glyphs) then mask_glyph := g21.vehicle_masks[heading_index];
      if not odd(query_surface_mask(mask_glyph, next_x, next_y)) then
      begin
        g21.player_x := next_x;
        g21.player_y := next_y
      end
      else
      begin
        if odd(g21.use_heading_glyphs) then mask_glyph := g21.vehicle_masks[5 + 3 * step_x];
        if not odd(query_surface_mask(mask_glyph, next_x, g21.player_y)) then
          g21.player_x := next_x
        else
        begin
          if odd(g21.use_heading_glyphs) then mask_glyph := g21.vehicle_masks[5 + step_y];
          if not odd(query_surface_mask(mask_glyph, g21.player_x, next_y)) then
            g21.player_y := next_y
          else
          begin
            blocked := true;
            delta_x := step_x;
            delta_y := step_y;
            tries := tries - 1
          end
        end
      end
    until not blocked or (tries <= 0);
    if odd(g21.use_heading_glyphs) and
       ((g21.player_x <> old_x) or (g21.player_y <> old_y)) then
    begin
      heading_index := 5 + 3 * word_sign(g21.player_x - old_x) +
                         word_sign(g21.player_y - old_y);
      g21.even_glyph := g21.vehicle_glyphs[heading_index];
      g21.odd_glyph := g21.even_glyph;
      g21.collision_glyph := g21.vehicle_masks[heading_index]
    end;
    toggle_surface_player;
    window_x := (g21.player_x + 3) div 7;
    window_y := (g21.player_y - 3) div 8;
    delta_x := 0;
    delta_y := 0;
    if window_x < 7 then delta_x := -1
    else if window_x > 32 then delta_x := 1
    else if window_y < 7 then delta_y := -1
    else if window_y > 16 then delta_y := 1;
    if (delta_x <> 0) or (delta_y <> 0) then
    begin
      if data29.nibbles45[2] = 3 then
      begin
        radius_x := data29.bytes[545];
        radius_y := (radius_x + 1) div 2;
        old_x := map_x_origin + delta_x;
        old_y := map_y_origin + delta_y;
        if (old_x < 12 - radius_x) or (old_x > 17 + radius_x) or
           (old_y < 7 - radius_y) or (old_y > 11 + radius_y) then
        begin
          leave_city_edge(old_x, old_y, radius_x, radius_y);
          exit(walk_surface_map)
        end
      end;
      map_x_origin := (map_x_origin + 40 + delta_x) mod 40;
      map_y_origin := (map_y_origin + 24 + delta_y) mod 24;
      render_surface_tiles;
      g21.player_y := (g21.player_y + 192 - g21.tile_height_pixels * delta_y) mod 192;
      g21.player_x := (g21.player_x + 280 - 28 * delta_x) mod 280;
      toggle_surface_player;
      paint_parked_transport;
      window_x := (g21.player_x + 3) div 7;
      window_y := (g21.player_y - 3) div 8;
      initialize_pointer(g21.cursor_x, g21.cursor_y, data29.words[298], g21.pointer_bounds)
    end
  end
end;
