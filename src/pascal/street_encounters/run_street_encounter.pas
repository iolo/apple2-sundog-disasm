{ game_17 procedure1, $0D64..$0D9B, attributes $0DA6.
  Startup passes addresses of caller slots4,3,1. VAR declarations retain the
  original six parameter bytes and all caller aliasing. Preserve the196-byte
  parent frame and the physical child11/12 frames used by save/restore. }
procedure run_street_encounter(var window_x, window_y, resume_selector: integer);
var
(*$include src/pascal/street_encounters/locals.pas*)
(*$include src/pascal/street_encounters/query_encounter_mask.pas*)
(*$include src/pascal/street_encounters/toggle_fighter_glyph.pas*)
(*$include src/pascal/street_encounters/remove_ground_fighter.pas*)
(*$include src/pascal/street_encounters/update_player_stun.pas*)
(*$include src/pascal/street_encounters/find_personal_shield.pas*)
(*$include src/pascal/street_encounters/equip_personal_weapon.pas*)
(*$include src/pascal/street_encounters/place_ground_fighter.pas*)
(*$include src/pascal/street_encounters/setup_ground_fighters.pas*)
(*$include src/pascal/street_encounters/set_encounter_bounds.pas*)
(*$include src/pascal/street_encounters/trace_ground_hit.pas*)
(*$include src/pascal/street_encounters/fire_personal_weapon.pas*)
(*$include src/pascal/street_encounters/switch_encounter_mode.pas*)
(*$include src/pascal/street_encounters/restore_ground_session.pas*)
(*$include src/pascal/street_encounters/persist_ground_session.pas*)
(*$include src/pascal/street_encounters/tick_player_fighter.pas*)
(*$include src/pascal/street_encounters/tick_enemy_fighters.pas*)
begin
  restore_ground_session;
  if resume_selector = 0 then switch_encounter_mode(true);
  initialize_pointer(g17.cursor_x, g17.cursor_y, 2, data29.bounds11);
  while not odd(g17.exit_requested) or odd(data29.words[347]) do
  begin
    tick_player_fighter;
    tick_enemy_fighters
  end;
  if odd(g17.victory_pending) then switch_encounter_mode(true);
  toggle_pointer_glyph(g17.cursor_x, g17.cursor_y);
  persist_ground_session
end;
