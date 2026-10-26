{ game_21 procedure9, $029E..$02E0, attributes $02EA.
  Native23:3's extra stack consumption is documented in its interface. }
procedure render_surface_tiles;
begin
  load_surface_tiles;
  if data29.nibbles45[1] = 11 then clear_hires_page1;
  if data29.nibbles45[2] = 3 then
    draw_tile_rows(6, 32, map_x_origin, map_y_origin, g21.map_buffer.word)
  else
    draw_tile_rows(8, 24, map_x_origin, map_y_origin, g21.map_buffer.word);
  draw_parked_marker(data29.pos72, 36, true)
end;
