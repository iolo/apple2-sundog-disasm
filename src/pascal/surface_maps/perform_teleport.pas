{ game_21 procedure36, $1852..$18FD, attributes $190A.
  Reprobe after each y decrement; the probe's low bit controls the loop.
  The input4 call still runs before its result is immediately overwritten. }
procedure perform_teleport;
begin
  map_x_origin := (data29.bits38.low6 - 5 + 40) mod 40;
  map_y_origin := (data29.bits39.low5 - 3 + 24) mod 24;
  pulse_teleport_box(g21.player_x + 3, g21.player_y - 3, true, false);
  pulse_teleport_box(g21.player_x + 3, g21.player_y - 3, true, true);
  render_surface_tiles;
  paint_parked_transport;
  project_map_location(g21.player_x, g21.player_y, data29.pos36);
  data29.words[2] := 2;
  while odd(query_surface_mask(g21.collision_glyph, g21.player_x, g21.player_y)) do
    g21.player_y := g21.player_y - 1;
  pulse_teleport_box(g21.player_x + 3, g21.player_y - 3, false, true);
  pulse_teleport_box(g21.player_x + 3, g21.player_y - 3, false, false);
  data29.words[2] := 9;
  window_x := (g21.player_x + 3) div 7;
  window_y := (g21.player_y - 3) div 8;
  g21.was_moving := poll_input(4);
  g21.was_moving := 0
end;
