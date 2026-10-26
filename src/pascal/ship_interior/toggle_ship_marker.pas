{ game_15 procedure5, $021A..$022D, attributes $0238.
  Reread coordinates after selecting mode1, and code after positioning. }
procedure toggle_ship_marker;
begin
  set_glyph_mode(1);
  move_pen(g15.marker_x, g15.marker_y);
  draw_glyph(g15.marker_glyph)
end;
