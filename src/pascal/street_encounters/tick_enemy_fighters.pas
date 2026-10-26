{ game_17 procedure17, $0B4E..$0D52, attributes $0D62.
  Entry addresses stay captured across calls and record compaction. Removing
  an entry decrements the scan index before the common increment. }
procedure tick_enemy_fighters;
var
  fighter_index, trail_index, random_value, old_x, old_y: integer;
begin
  fighter_index := 2;
  while fighter_index <= g17.fighter_count do
  begin
    random_value := random_word;
    trail_index := random_value mod 7;
    update_pointer(g17.cursor_x, g17.cursor_y);
    { Keep the original post-input comparison, even though a stable count
      would make index=count+2 impossible inside this loop. }
    if fighter_index = g17.fighter_count + 2 then tick_player_fighter;
    with g17.items[fighter_index] do
    begin
      if delay > 0 then delay := delay - 1;
      if life <= 32 then
      begin
        if delay <= 0 then
        begin
          toggle_fighter_glyph(fighter_index);
          if life > 0 then
          begin
            draw := 23;
            toggle_fighter_glyph(fighter_index);
            life := 33
          end
          else
          begin
            remove_ground_fighter(fighter_index);
            fighter_index := fighter_index - 1
          end
        end
      end
      else
      begin
        g17.trail_distance := word_abs(g17.trail[trail_index].first - first)
                        + word_abs(g17.trail[trail_index].second - second);
        if (g17.player_status = 2) or data29.flags82[50] then
        begin
          g17.enemy_x_step := word_sign(first - g17.trail[trail_index].first);
          g17.enemy_y_step := word_sign(second - g17.trail[trail_index].second)
        end
        else if (g17.trail_distance > 35) or (g17.player_status = 1) then
        begin
          g17.enemy_x_step := word_sign(g17.trail[trail_index].first - first);
          g17.enemy_y_step := word_sign(g17.trail[trail_index].second - second)
        end
        else
        begin
          g17.enemy_x_step := 0;
          g17.enemy_y_step := 0;
          random_value := random_word;
          if odd(random_value) then g17.enemy_x_step := g17.trail[trail_index].word1
          else g17.enemy_y_step := g17.trail[trail_index].word0
        end;
        old_x := first;
        old_y := second;
        step_glyph_pair(draw, code, g17.enemy_x_step, g17.enemy_y_step, first, second);
        if (old_x = first) and (old_y = second) then
        begin
          toggle_pointer_glyph(g17.cursor_x, g17.cursor_y);
          step_glyph_pair(draw, code, g17.enemy_x_step, g17.enemy_y_step, first, second);
          if (old_x = first) and (old_y = second)
             and (g17.player_status = 2) then
          begin
            toggle_fighter_glyph(1);
            step_glyph_pair(draw, code, g17.enemy_x_step, g17.enemy_y_step, first, second);
            toggle_fighter_glyph(1)
          end;
          toggle_pointer_glyph(g17.cursor_x, g17.cursor_y)
        end;
        if (first < g17.arena_left + 5) or (first > g17.arena_right - 12)
           or (second < g17.arena_top + 10) or (second > g17.arena_bottom - 5) then
        begin
          remove_ground_fighter(fighter_index);
          fighter_index := fighter_index - 1
        end
        else if (g17.player_status = 0) and (delay <= 0)
                and not data29.flags82[50] then
        begin
          fire_personal_weapon(fighter_index, g17.trail[trail_index].first, g17.trail[trail_index].second);
          { The call may shift records. Write through the previously captured
            entry address and read its current radius after that call. }
          delay := 10 - radius
        end
      end
    end;
    fighter_index := fighter_index + 1
  end
end;
