{ game_13 procedure17, $0A02..$0A21, attributes $0A2C; nested in16.
  Slots4/3 are inputs,2/1 are VAR outputs. The first input's low bit controls
  the extra three units; preserve native shift semantics and output order,
  including when both result addresses alias. }
procedure planet_grid_to_pixel(map_column, map_row: integer; var outx, outy: integer);
begin
  outx := 6 * right_shift_word(map_column + 1, 1);
  if odd(map_column) then outx := outx + 3;
  outy := left_shift_word(map_row, 2)
end;
