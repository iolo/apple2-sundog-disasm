{ game_12 procedure10, $0876..$09AE, attributes $09BC; nested in1.
  Inputs2/1 are horizontal/vertical motion. After applying those inputs,
  reuse their private value slots for two visibility predicates so both
  original absolute-value calls run. Speed3 remains available for drawing. }
procedure move_tactical_view(horizontal, vertical: integer);
var speed: integer; {3}
begin
  if odd(g12.manual_mode) or odd(g12.target_present) or odd(g12.wreck_cargo_present) then
  begin
    set_glyph_mode(1);
    apply_bounds(data29.bnd343, 0);
    g12.back_x_offset := g12.back_x_offset - horizontal;
    g12.back_y_offset := g12.back_y_offset - vertical;
    if odd(g12.target_present) then
    begin
      if data29.target_motion_ticks > 0 then
      begin
        data29.target_range := data29.target_range + data29.words[207];
        if data29.target_range < 5 then data29.target_range := 5;
        data29.target_motion_ticks := data29.target_motion_ticks - 1
      end;
      speed := 3 - right_shift_word(data29.target_range, 5);
      data29.words[206] := word_and(data29.words[206] + horizontal + horizontal +
                                     speed * data29.words[209], 1023);
      data29.words[205] := word_and(data29.words[205] + vertical + vertical +
                                     speed * data29.words[208], 1023)
    end;
    if g12.display_level > 1 then
    begin
      if odd(g12.target_present) then
      begin
        g12.target_x_offset := right_shift_word(data29.words[206], 1) - 256;
        g12.target_y_offset := right_shift_word(data29.words[205], 1) - 256;
        horizontal := ord(word_abs(g12.target_x_offset) < 65);
        vertical := ord(word_abs(g12.target_y_offset) < 45);
        if odd(horizontal) and odd(vertical) and (data29.target_range < 108) then
        begin
          move_pen(g12.view_x_origin + g12.target_x_offset, g12.view_y_origin + g12.target_y_offset);
          call_sky_overlay(g12.background_address, 2518);
          draw_glyph(g12.target_glyph_base + speed);
          g12.target_visible := 1
        end
        else
        begin
          call_sky_overlay(g12.background_address, 2518);
          g12.target_visible := 0;
          g12.radar_countdown := 2
        end
      end
      else call_sky_overlay(g12.background_address, 2518)
    end
    else apply_bounds(data29.bnd343, 8)
  end
end;
