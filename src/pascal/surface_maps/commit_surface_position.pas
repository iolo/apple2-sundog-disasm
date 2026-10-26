{ game_21 procedure6, $00B0..$01A5, attributes $01AE.
  Save packed location first, then copy all six words to the parked location
  when flag13 is clear. Later stores must reread aliased VAR arguments. }
procedure commit_surface_position;
begin
  toggle_pointer_glyph(g21.cursor_x, g21.cursor_y);
  if (data29.nibbles45[2] <> 11) and (data29.nibbles45[2] <> 2) then
    if data29.flags45[13] or not odd(exit_requested) then toggle_surface_player;
  data29.bits38.low6 := (map_x_origin + g21.player_x div 28) mod 40;
  data29.bits39.low5 := (map_y_origin + g21.player_y div g21.tile_height_pixels) mod 24;
  if (data29.nibbles45[2] >= 11) or (data29.nibbles45[2] <= 4) then
  begin
    data29.words[40] := 140 + g21.player_x mod 28;
    data29.bytes[80] := 96 + g21.player_y mod g21.tile_height_pixels
  end
  else
  begin
    data29.words[40] := g21.player_x;
    data29.bytes[80] := g21.player_y
  end;
  if not data29.flags45[13] then
  begin
    data29.rec228 := data29.rec36;
    if odd(g21.player_x) then data29.bytes[507] := g21.odd_glyph
    else data29.bytes[507] := g21.even_glyph;
    data29.bytes[506] := g21.collision_glyph
  end;
  if odd(exit_requested) then
  begin
    data29.nibbles45[1] := data29.nibbles45[2];
    data29.nibbles45[2] := 5;
    tile_or_action := 16
  end;
  select_drawing_buffer(data29.words[16], false);
  select_drawing_buffer(2048, true)
end;
