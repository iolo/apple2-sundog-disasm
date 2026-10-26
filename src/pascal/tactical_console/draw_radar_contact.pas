{ game_12 procedure8, $0476..$04CD, attributes $04D8; nested in1.
  Slots6..1: angle, distance, xbase, ybase, VAR xpos/ypos. Preserve output
  aliasing and the distance>=28 self EXIT before any coordinate call. }
procedure draw_radar_contact(angle, distance, xbase, ybase: integer; var xpos, ypos: integer);
begin
  if distance >= 28 then
  begin
    g12.radar_visible := 0;
    exit(draw_radar_contact)
  end;
  angle := right_shift_word(angle, 2);
  if angle < 0 then angle := 256 + angle
  else angle := word_and(angle, 255);
  project_polar_point(angle, distance, xpos, ypos);
  xpos := xbase + xpos - 3;
  ypos := ybase + ypos + 3;
  move_pen(xpos, ypos);
  set_glyph_mode(1);
  draw_glyph(g12.radar_glyph)
end;
