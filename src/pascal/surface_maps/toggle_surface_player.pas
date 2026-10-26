{ game_21 procedure5, $0084..$00A5, attributes $00AE.
  The coordinate at parent26 is tested by low bit, not compared with zero. }
procedure toggle_surface_player;
begin
  set_glyph_mode(1);
  move_pen(g21.player_x, g21.player_y);
  if odd(g21.player_x) then draw_glyph(g21.odd_glyph)
  else draw_glyph(g21.even_glyph)
end;
