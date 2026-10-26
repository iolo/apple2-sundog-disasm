{ game_21 procedure25, $0CA0..$0E95, attributes $0EAC.
  The expanding search has no invented bound. Increment/wrap its counter
  before the drawing probe, preserving the original candidate coordinates.
  In the non-city branch for previous mode2, BOTH coordinates read parent15. }
procedure place_surface_player;
var
  search_radius, search_index, search_x, search_y: integer;
begin
  if (data29.nibbles45[1] = 7) or (data29.nibbles45[1] = 11) or data29.flags82[28] then
    project_map_location(g21.player_x, g21.player_y, data29.pos36)
  else if (data29.nibbles45[1] <> data29.nibbles45[2]) and (data29.nibbles45[1] <> 2) then
  begin
    g21.player_x := data29.words[40];
    g21.player_y := data29.bytes[80]
  end
  else if data29.nibbles45[1] = 2 then
  begin
    if data29.nibbles45[2] = 3 then
    begin
      g21.player_x := 140 + g21.ship_x_offset + 6 * ((data29.words[292] - 1) div 3 - 1);
      if not data29.flags45[13] then g21.player_x := g21.player_x + 3;
      g21.player_y := 96 + g21.ship_y_offset + 6 * ((data29.words[292] - 1) mod 3 - 1)
    end
    else
    begin
      g21.player_x := g21.ship_x_offset;
      g21.player_y := g21.ship_x_offset
    end
  end
  else if not data29.flags45[13] and data29.flags45[12] then
  begin
    data29.rec36 := data29.rec228;
    project_map_location(g21.player_x, g21.player_y, data29.pos36);
    if data29.nibbles45[2] = 4 then toggle_surface_player
  end
  else if not data29.flags45[12] and data29.flags45[13] then
  begin
    if data29.nibbles45[2] = 3 then
    begin
      data29.words[2] := 2;
      g21.parked_x_cell := data29.pos228.fields.kind2;
      g21.parked_y_cell := data29.pos228.fields.kind3;
      g21.parked_x_offset := data29.words[232] mod 28;
      g21.parked_y_offset := data29.pos228.fields.w5low mod g21.tile_height_pixels;
      search_index := 0;
      search_radius := 1;
      repeat
        search_x := 28 * wrapped_map_offset(g21.parked_x_cell, map_x_origin, 40) + g21.parked_x_offset;
        search_y := g21.tile_height_pixels * wrapped_map_offset(g21.parked_y_cell, map_y_origin, 24) + g21.parked_y_offset;
        g21.player_x := search_x + search_radius * (search_index div 7 - 3);
        g21.player_y := search_y + search_radius * (search_index mod 7 - 3);
        search_index := search_index + 1;
        if search_index = 49 then
        begin
          search_radius := search_radius + 1;
          search_index := 0
        end
      until not odd(query_surface_mask(g21.collision_glyph, g21.player_x, g21.player_y))
    end
    else
    begin
      project_map_location(g21.player_x, g21.player_y, data29.pos228);
      set_glyph_mode(1);
      move_pen(g21.player_x, g21.player_y);
      draw_glyph(data29.bytes[507])
    end
  end
  else project_map_location(g21.player_x, g21.player_y, data29.pos36);
  window_x := (g21.player_x + 3) div 7;
  window_y := (g21.player_y - 3) div 8;
  if data29.flags45[13] or not odd(exit_requested) then toggle_surface_player;
  data29.words[2] := 9
end;
