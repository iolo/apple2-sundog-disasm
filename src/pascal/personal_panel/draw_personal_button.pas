{ game_8 procedure 6, $012C..$0171, attributes $017C.
  Bounds and caption are value parameters; incoming storage may alias globals. }
procedure draw_personal_button(bounds: bounds4; caption: text15);
var
  caption_x: integer;
begin
  set_clip_bounds(bounds.lower_first - 2, bounds.upper_first + 2,
            bounds.lower_second - 2, bounds.upper_second + 2);
  draw_clip_pattern(10);
  apply_bounds(bounds, 8);
  caption_x := ((bounds.lower_first + bounds.upper_first) -
               6 * length(caption)) div 2;
  set_glyph_mode(3);
  move_pen(caption_x, bounds.upper_second - 2);
  draw_text(caption);
  set_glyph_mode(1)
end;
