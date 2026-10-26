{ game_21 procedure13, $067A..$06B4, attributes $06BE.
  The six-word value copy precedes both sequential VAR output stores. }
procedure project_map_location(var xpos, ypos: integer; position: g19loc);
begin
  xpos := 28 * wrapped_map_offset(position.fields.kind2, map_x_origin, 40) + position.fields.word4 mod 28;
  ypos := g21.tile_height_pixels * wrapped_map_offset(position.fields.kind3, map_y_origin, 24) +
          position.fields.w5low mod g21.tile_height_pixels
end;
