{ game_12 procedure7, $0296..$0461, attributes $0474; nested in1.
  Both absolute-distance calls precede the disabled-weapon self EXIT. That
  early exit skips charge clearing; all other paths reach the common tail.
  Slot9 is the original reused loop bound/system-row pointer. }
procedure fire_tactical_weapon;
var
  unused1: integer;
  divisor: integer; {2}
  unused3: integer;
  power_shift: integer; {4}
  weapon_range: integer; {5}
  dy: integer; {6}
  dx: integer; {7}
  hull_or_flag_index: integer; {8; later flag-loop index}
  scratch: g12scratch; {9}
begin
  dx := word_abs(data29.words[206] - 512);
  dy := word_abs(data29.words[205] - 512);
  if (data29.bytes[178 + 80] = 0) or (data29.weapon_charge = 0) then
    exit(fire_tactical_weapon);
  if g12.display_level > 1 then
  begin
    if odd(g12.laser_selected) then call_beam_overlay(g12.laser_beam_style, 2048)
    else call_beam_overlay(g12.cannon_beam_style, 2048)
  end;
  if odd(g12.laser_selected) then weapon_range := g12.weapon_base_range - right_shift_word(data29.target_range, 5)
  else weapon_range := 2 * g12.weapon_base_range - right_shift_word(data29.target_range, 4);
  if weapon_range < 0 then weapon_range := 0;
  if odd(g12.target_present) then
  begin
    data29.bytes[178 + 193] := right_shift_word(data29.bytes[178 + 193] + 127, 1);
    if dx + dy <= weapon_range then
    begin
      play_sound(2, 100, 50, 0, 0, 0, 1);
      data29.words[354] := data29.words[354] + 1;
      data29.target_motion_ticks := 4;
      if data29.flags82[18] then power_shift := 6 else power_shift := 5;
      if odd(g12.laser_selected) then divisor := left_shift_word(dy + dx, 4)
      else divisor := left_shift_word(data29.target_range + dy + dx, 1);
      if divisor <= 0 then divisor := 1;
      hull_or_flag_index := data29.target_hull -
                left_shift_word(data29.weapon_charge + 1, power_shift - data29.target_class) div divisor;
      if hull_or_flag_index <= 0 then
      begin
        data29.target_hull := 0;
        hull_or_flag_index := 41;
        scratch.word := 47;
        while hull_or_flag_index <= scratch.word do
        begin
          data29.flags82[hull_or_flag_index] := false;
          hull_or_flag_index := hull_or_flag_index + 1
        end;
        g12.target_present := 0;
        scratch.word := data29.words[23] + 20 * (data29.loc73.low4 - 1);
        scratch.row^.nibbles8[7] := scratch.row^.nibbles8[7] + data29.target_class;
        g12.words[11] := 0;
        g12.target_visible := 0;
        g12.back_y_offset := 128;
        g12.back_x_offset := data29.pos72.fields.w0low;
        if g12.display_level > 0 then
        begin
          expand_screen_effect(0);
          call_sky_overlay(g12.background_address, 2518)
        end
        else apply_bounds(data29.bnd343, 8);
        swap_tactical_buffers;
        handle_target_destroyed;
        swap_tactical_buffers
      end
      else
      begin
        data29.target_hull := hull_or_flag_index;
        draw_target_hull
      end
    end
    else if dx + dy < left_shift_word(weapon_range, 2) then data29.target_motion_ticks := 0
  end;
  data29.weapon_charge := 0;
  draw_vertical_gauge(data29.weapon_gauge_bounds, data29.weapon_charge, 4, 6)
end;
