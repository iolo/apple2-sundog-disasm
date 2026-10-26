{ game_17 procedure16, $08D4..$0B3A, attributes $0B4C.
  Capture entry1 before input. Input selectors0/1 and both selector5 calls
  retain their original unconditional evaluation within the respective paths. }
procedure tick_player_fighter;
var
  step_x, step_y, old_x, old_y, slot_or_trail_index: integer;
  input0, input1, input5, ignored: integer;
  stun_flag, stun_state: boolean;
begin
  with g17.items[1] do
  begin
    update_pointer(g17.cursor_x, g17.cursor_y);
    step_x := 0;
    step_y := 0;
    if (life <= 32) or data29.flags82[48] then
    begin
      stun_flag := data29.flags82[48];
      stun_state := g17.player_status = 1;
      input0 := poll_input(0);
      input1 := poll_input(1);
      if stun_flag and stun_state and (odd(input0) or odd(input1)) then
      begin
        g17.player_status := 0;
        delay := 0;
        data29.flags82[48] := false
      end
      else if delay > 0 then delay := delay - 1;
      if (delay = 0) and (g17.player_status = 1) then
      begin
        if not data29.flags82[48] then
        begin
          slot_or_trail_index := 0;
          while slot_or_trail_index <= 3 do
          begin
            data29.bytes[122 + slot_or_trail_index] := 0;
            slot_or_trail_index := slot_or_trail_index + 1
          end
        end;
        data29.words[47] := 0;
        data29.words[46] := 0;
        g17.spread_weapon_active := 0;
        g17.personal_shield_active := 0;
        g17.player_status := 2;
        data29.flags82[48] := false
      end
      else if (delay <= 0) and (g17.fighter_count = 1) then
      begin
        g17.exit_requested := 1;
        data29.flags82[48] := false
      end
    end
    else
    begin
      if odd(poll_input(4)) then
      begin
        step_x := word_sign(g17.cursor_x - 3 - first);
        step_y := word_sign(g17.cursor_y + 3 - second);
        old_x := first;
        old_y := second;
        step_glyph_pair(draw, code, step_x, step_y, first, second);
        if (old_x = first) and (old_y = second) then
        begin
          toggle_pointer_glyph(g17.cursor_x, g17.cursor_y);
          step_glyph_pair(draw, code, step_x, step_y, first, second);
          toggle_pointer_glyph(g17.cursor_x, g17.cursor_y)
        end
      end
      else
      begin
        step_x := 0;
        step_y := 0
      end;
      if (first < g17.arena_left + 7) or (first > g17.arena_right - 12)
         or (second < g17.arena_top + 12) or (second > g17.arena_bottom - 8) then
        g17.exit_requested := 1;
      ignored := poll_input(5);
      input5 := poll_input(5);
      if odd(input5) and active and (g17.player_status < 2) then
      begin
        toggle_pointer_glyph(g17.cursor_x, g17.cursor_y);
        fire_personal_weapon(1, g17.cursor_x - 3, g17.cursor_y + 3);
        if odd(g17.spread_weapon_active) then
        begin
          fire_personal_weapon(1, g17.cursor_x - 3, g17.cursor_y - 3);
          fire_personal_weapon(1, g17.cursor_x - 3, g17.cursor_y + 6);
          fire_personal_weapon(1, g17.cursor_x + 3, g17.cursor_y - 3);
          fire_personal_weapon(1, g17.cursor_x - 6, g17.cursor_y - 3);
          g17.spread_shots_left := g17.spread_shots_left - 1;
          if g17.spread_shots_left = 0 then
          begin
            g17.spread_weapon_active := 0;
            data29.bytes[122] := 7;
            play_sound(10, 10, 50, 0, 0, 0, 1);
            equip_personal_weapon
          end
        end;
        toggle_pointer_glyph(g17.cursor_x, g17.cursor_y);
        g17.player_status := 0
      end
    end;
    g17.current_trail_index := (g17.current_trail_index + 1) mod 7;
    { Both pointers were captured in the original. The trail index is read
      once here; the following stores contain no calls or index changes. }
    slot_or_trail_index := g17.current_trail_index;
    g17.trail[slot_or_trail_index].first := first;
    g17.trail[slot_or_trail_index].second := second;
    g17.trail[slot_or_trail_index].word1 := step_x;
    g17.trail[slot_or_trail_index].word0 := step_y;
    g17.oldest_trail_index := (g17.current_trail_index + 1) mod 7
  end
end;
