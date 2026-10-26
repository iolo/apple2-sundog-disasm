{ game_21 procedure27, $1070..$10E5, attributes $10F0. }
procedure setup_city_view;
begin
  store_word(21504, g21.map_buffer.word);
  g21.view_half_rows := 3;
  g21.scanline_groups := 4;
  g21.tile_height_pixels := 8 * g21.scanline_groups;
  g21.words[20] := 5;
  if (data29.nibbles45[1] = 2) or (data29.nibbles45[1] = 4) or
     (data29.nibbles45[1] = 11) or data29.flags82[114] or
     data29.flags82[28] then seed_city_map
  else load_surface_tiles;
  g21.contract_city := ord(data29.bits37.mid6 = 60);
  data29.words[353] := 10;
  if data29.flags45[13] then data29.words[351] := 10
  else data29.words[351] := 1
end;
