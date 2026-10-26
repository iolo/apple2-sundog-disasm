{ game_21 procedure3, $004C..$0078, attributes $0082. }
procedure load_surface_tiles;
(*$include src/pascal/surface_maps/cache_tile_bank.pas*)
begin
  if data29.nibbles45[2] = 3 then
  begin
    cache_tile_bank(116, 16384, tileset_primary);
    cache_tile_bank(117, 16384 + 2048, tileset_secondary)
  end
  else cache_tile_bank(116, 16384, 4)
end;
