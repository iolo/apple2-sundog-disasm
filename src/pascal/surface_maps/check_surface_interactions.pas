{ game_21 procedure21, $0AEA..$0BBA, attributes $0BC4.
  The map is24 rows of40 bytes. Keep proximity calls unconditional at their
  original predicate sites and capture preceding flags before each call. }
procedure check_surface_interactions;
var
  map_column, map_row, mode_changed: integer;
  interaction_allowed, nearx, neary: boolean;
begin
  map_column := (map_x_origin + (g21.player_x + 3) div 28) mod 40;
  map_row := (map_y_origin + (g21.player_y - 3) div g21.tile_height_pixels) mod 24;
  tile_or_action := g21.map_buffer.rows^[map_row][map_column];
  mode_changed := 0;
  interaction_allowed := (data29.bits37.mid6 = data29.pos228.fields.city) and
             data29.flags45[13] and not data29.flags82[7];
  nearx := within_axis_radius(map_column, data29.pos228.fields.kind2, 1);
  neary := within_axis_radius(map_row, data29.pos228.fields.kind3, 1);
  if interaction_allowed and nearx and neary then enter_parked_transport(mode_changed);
  if not odd(mode_changed) and (data29.nibbles45[2] = 3) and (tile_or_action > 6) then
    probe_building_entrance(mode_changed);
  interaction_allowed := not odd(mode_changed) and (data29.bits37.mid6 = data29.bits73.mid6);
  nearx := within_axis_radius(map_column, data29.pos72.fields.kind2, 3);
  if interaction_allowed and nearx and (map_row = data29.pos72.fields.kind3) then try_board_ship(mode_changed);
  if not odd(mode_changed) and (data29.nibbles45[2] = 4) then
    if tile_or_action = 13 then enter_city_tile(map_column, map_row)
end;
