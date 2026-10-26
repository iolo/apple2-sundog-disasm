{ game_21 procedure29, $12D8..$1330, attributes $133A. }
procedure prepare_planet_view;
begin
  store_word(20480, g21.map_buffer.word);
  g21.view_half_rows := 4;
  g21.scanline_groups := 3;
  g21.tile_height_pixels := 8 * g21.scanline_groups;
  g21.words[20] := 7;
  if (data29.nibbles45[1] = 2) or (data29.nibbles45[1] = 3) or
     (data29.nibbles45[1] = 11) then decode_planet_map
  else load_surface_tiles;
  data29.words[353] := 2;
  if data29.flags45[13] then data29.words[351] := 120
  else data29.words[351] := 20
end;
