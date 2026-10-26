{ utility_disk1:17 $0650..$0674, attributes$067E, nested in9.
  Four unused local bytes. Initialize systems, planets, templates, inventory
  in that order; write the same three-block table to both original locations. }
procedure write_initial_world;
var unused: array[1..2] of integer;
begin
  place_world_systems;
  seed_planet_rows;
  write_city_templates;
  seed_warehouse_items;
  disk_blocks_io(-5887, 3, data29.words[30] + 1, false);
  disk_blocks_io(-5887, 3, new_game_frame.save_block + 7, false)
end;
