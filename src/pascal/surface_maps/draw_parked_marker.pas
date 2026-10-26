{ game_21 procedure7, $01B0..$025C, attributes $0266.
  Copy six words before effects. A clipped point resets mode before self EXIT. }
procedure draw_parked_marker(position: g19loc; glyph: integer; double_glyph: boolean);
var
  screen_column, screen_row, xpos, ypos: integer;
begin
  screen_column := wrapped_map_offset(position.fields.kind2, map_x_origin, 40);
  screen_row := wrapped_map_offset(position.fields.kind3, map_y_origin, 24);
  if (position.fields.city = data29.bits37.mid6) and
     (screen_column < 10) and (screen_row < 6) then
  begin
    xpos := 28 * screen_column + position.fields.word4 mod 28;
    ypos := g21.tile_height_pixels * screen_row + position.fields.w5low mod g21.tile_height_pixels;
    if (xpos > 272) or (ypos < 8) then
    begin
      set_glyph_mode(0);
      exit(draw_parked_marker)
    end;
    if double_glyph then set_glyph_mode(0) else set_glyph_mode(1);
    move_pen(xpos, ypos);
    draw_glyph(glyph);
    if double_glyph then
    begin
      move_pen(xpos + 7, ypos);
      draw_glyph(glyph + 1);
      if data29.flags82[7] then
      begin
        set_glyph_mode(1);
        move_pen(xpos + 7, ypos);
        draw_glyph(16)
      end
    end;
    set_glyph_mode(0)
  end
end;
