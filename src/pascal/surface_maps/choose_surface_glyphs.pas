{ game_21 procedure23, $0C1E..$0C95, attributes $0C9E. }
procedure choose_surface_glyphs;
(*$include src/pascal/surface_maps/assign_surface_glyphs.pas*)
begin
  g21.use_heading_glyphs := 0;
  if data29.nibbles45[2] = 3 then
  begin
    if data29.flags45[13] then assign_surface_glyphs(10, 10, 11)
    else
    begin
      g21.use_heading_glyphs := 1;
      g21.even_glyph := data29.bytes[507];
      g21.odd_glyph := data29.bytes[507];
      g21.collision_glyph := 17;
      build_heading_glyphs(g21.vehicle_glyphs, 14);
      build_heading_glyphs(g21.vehicle_masks, 15);
      if data29.nibbles45[1] = 4 then
      begin
        g21.even_glyph := g21.vehicle_glyphs[data29.words[292]];
        g21.odd_glyph := g21.even_glyph
      end
    end
  end
  else if data29.flags45[13] then assign_surface_glyphs(10, 10, 15)
  else assign_surface_glyphs(26, 29, 15)
end;
