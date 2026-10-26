{ utility_disk1:9 $0A86..$0A95, attributes$0AA0. No parameters,34 local
  bytes. Slot2 selects the ten-block save area. Other locals retain their
  original initialization state; in particular13 first reads unknown slot9. }
procedure create_game_state;
var new_game_frame: utilinit;
(*$include src/pascal/save_game_utility/perturb_system_axis.pas*)
(*$include src/pascal/save_game_utility/valid_system_spacing.pas*)
(*$include src/pascal/save_game_utility/place_world_systems.pas*)
(*$include src/pascal/save_game_utility/seed_planet_rows.pas*)
(*$include src/pascal/save_game_utility/write_city_templates.pas*)
(*$include src/pascal/save_game_utility/seed_warehouse_items.pas*)
(*$include src/pascal/save_game_utility/write_initial_world.pas*)
(*$include src/pascal/save_game_utility/set_initial_location.pas*)
(*$include src/pascal/save_game_utility/seed_component_band.pas*)
(*$include src/pascal/save_game_utility/seed_auxiliary_bands.pas*)
(*$include src/pascal/save_game_utility/reset_player_state.pas*)
begin
  new_game_frame.save_block := data29.words[31] + 10 * u1.picked_slot;
  reset_player_state;
  write_initial_world;
  set_initial_location
end;
