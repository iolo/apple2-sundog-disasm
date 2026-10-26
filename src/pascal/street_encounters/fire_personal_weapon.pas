{ game_17 procedure14, $068C..$07C0, attributes $07CC. }
procedure fire_personal_weapon(shooter_index, target_x, target_y: integer);
var
  shot_distance, hit_index, remaining_life, previous_life, random_value: integer;
  hit: boolean;
begin
  with g17.items[shooter_index] do
    shot_distance := word_abs(first - target_x) + word_abs(second - target_y);
  if shooter_index = 1 then shot_distance := shot_distance - data29.bytes[95];
  hit := trace_ground_hit(shooter_index, target_x, target_y, shot_distance, hit_index);
  if shooter_index = hit_index then exit(fire_personal_weapon);
  with g17.items[shooter_index] do
    move_pen(first + 3, second - 3);
  set_line_mode(3);
  move_pen(target_x + 3, target_y - 3);
  play_sound(8, 80, 5, 0, 0, 0, 0);
  set_line_mode(0);
  with g17.items[shooter_index] do
    move_pen(first + 3, second - 3);
  set_line_mode(3);
  move_pen(target_x + 3, target_y - 3);
  set_line_mode(0);
  if hit and (hit_index > 0) then
    with g17.items[hit_index] do
      if odd(g17.personal_shield_active) and (hit_index = 1) then
      begin
        g17.shield_hits_left := g17.shield_hits_left - 1;
        play_sound(4, 50, 50, 0, 0, 0, 0);
        if g17.shield_hits_left = 0 then
        begin
          play_sound(10, 10, 50, 0, 0, 0, 1);
          data29.bytes[122 + g17.shield_inventory_index] := 7;
          find_personal_shield
        end
      end
      else
      begin
        play_sound(8, 40, 10, 0, 0, 0, 1);
        previous_life := life;
        random_value := random_word;
        remaining_life := previous_life - 4 * (random_value mod 16);
        if remaining_life < 0 then remaining_life := 0;
        life := remaining_life;
        if life <= 32 then
        begin
          toggle_fighter_glyph(hit_index);
          draw := 25;
          toggle_fighter_glyph(hit_index);
          if hit_index = 1 then update_player_stun
          else if life = 0 then
          begin
            remove_ground_fighter(hit_index);
            g17.victory_pending := ord(g17.fighter_count = 1);
            if odd(g17.victory_pending) then data29.ground_encounter_mode := 15
          end
        end
      end
end;
