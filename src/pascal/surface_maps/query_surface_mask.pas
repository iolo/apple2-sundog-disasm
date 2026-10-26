{ game_21 procedure10, $02EC..$02FF, attributes $0308.
  Return DATASEG29 word1 only after the drawing calls. }
function query_surface_mask(mask_glyph, xpos, ypos: integer): integer;
begin
  set_glyph_mode(2);
  move_pen(xpos, ypos);
  draw_glyph(mask_glyph);
  query_surface_mask := data29.words[1]
end;
