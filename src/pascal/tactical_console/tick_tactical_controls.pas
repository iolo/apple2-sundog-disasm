{ game_12 procedure12, $09F4..$0BF6, attributes $0C02; nested in1.
  Native joystick writes local1(vertical)/2(horizontal); local3 is scratch.
  Both conditional input0 polls and both movement10 calls remain separate.
  Update31 uses the low-bit typed NEQ6 comparison against global flag40. }
procedure tick_tactical_controls;
var
  motion: wordpair; {1/2}
  speed: integer; {3}
begin
  if odd(g12.manual_mode) then call_joystick_overlay(motion, 2675)
  else if data29.flags82[19] and odd(g12.target_present) then
  begin
    if odd(g12.target_visible) then
    begin
      speed := 3 - right_shift_word(data29.target_range, 5);
      if speed < 0 then speed := 0;
      motion.second := -right_shift_word(speed * data29.words[209], 1);
      motion.first := -right_shift_word(speed * data29.words[208], 1)
    end
    else
    begin
      motion.second := left_shift_word(word_sign(512 - data29.words[206]), 3);
      motion.first := left_shift_word(word_sign(512 - data29.words[205]), 3)
    end
  end
  else
  begin
    motion.second := 0;
    motion.first := 0
  end;
  if odd(g12.manual_mode) then
    if odd(poll_input(0)) then fire_tactical_weapon;
  if odd(g12.wreck_cargo_present) then
  begin
    data29.target_range := data29.target_range + data29.words[207];
    if data29.target_range <= 2 then data29.target_range := 1
    else if data29.target_range > 128 then
    begin
      g12.wreck_cargo_present := 0;
      data29.flags82[36] := false
    end
  end;
  if (not odd(g12.target_visible)) or (data29.words[354] = g12.radar_interval) or
     (g12.radar_countdown > 0) then
  begin
    apply_bounds(data29.bnd339, 0);
    set_glyph_mode(1);
    g12.radar_countdown := g12.radar_countdown - 1;
    if odd(g12.radar_visible) then
    begin
      move_pen(g12.left_x, g12.left_y);
      draw_glyph(g12.radar_glyph);
      move_pen(g12.right_x, g12.right_y);
      draw_glyph(g12.radar_glyph)
    end;
    if (odd(g12.target_present) or odd(g12.wreck_cargo_present)) and (g12.display_level > 4) then
    begin
      g12.radar_visible := 1;
      speed := right_shift_word(data29.target_range, 2);
      draw_radar_contact(data29.words[206] + 256, speed, 42, 152, g12.left_x, g12.left_y);
      draw_radar_contact(-data29.words[205], speed, 105, 152, g12.right_x, g12.right_y)
    end
    else g12.radar_visible := 0
  end;
  move_tactical_view(motion.second, motion.first);
  if odd(g12.manual_mode) then
    if odd(poll_input(0)) then fire_tactical_weapon;
  if data29.words[354] >= data29.words[353] then
  begin
    if data29.flags82[45] then flash_target_hit;
    update_flight_state;
    if odd(g12.words[28]) then
    begin
      if g12.words[14] > 0 then g12.words[14] := g12.words[14] - 1
      else
      begin
        g12.words[28] := 0;
        data29.flags82[44] := true
      end
    end;
    g12.display_level := data29.bytes[178 + 108];
    move_tactical_view(motion.second, motion.first);
    g12.words[11] := ord(data29.flags82[41]);
    if data29.flags82[40] <> odd(g12.target_present) then
    begin
      g12.target_present := ord(data29.flags82[40]);
      if odd(g12.target_present) then g12.target_glyph_base := left_shift_word(data29.target_class, 5);
      swap_tactical_buffers;
      paint_target_panel;
      swap_tactical_buffers
    end
  end
end;
