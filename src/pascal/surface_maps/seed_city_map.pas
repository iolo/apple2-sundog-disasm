{ game_21 procedure26, $0EAE..$105D, attributes $106E.
  Generate the city interior in column-major order, saving/restoring both
  random-state words. Random is called for every cell, including clipped ones.
  flag28 expects a tile12: if none exists, the original uses uninitialized
  found coordinates; no default or repair is introduced here. }
procedure seed_city_map;
var
  find_arrival_tile: boolean;
  xlow, xhigh, ylow, yhigh: integer;
  tile, column, row, arrival_column, arrival_row: integer;
  block, part, cached_city, random_value: integer;
  saved_seed: wordpair;
  seed: wordpair;
  scratch: address16;
  city_template: g21cptr;
begin
  find_arrival_tile := data29.flags82[28];
  block := (data29.bits37.mid6 - 1) div 4 + data29.words[28];
  part := (data29.bits37.mid6 - 1) mod 4;
  scratch.word := 21504;
  cached_city := scratch.bytes^[1000];
  scratch.word := 6144;
  if (cached_city <> data29.bits37.mid6) or data29.flags82[114] then
  begin
    disk_blocks_io(scratch.word, 1, block, true);
    derive_city_limits(xlow, xhigh, ylow, yhigh);
    moveleft(data29.words[21], saved_seed, 4);
    seed.first := 3 * data29.bits37.mid6 + 39;
    seed.second := 11 * data29.bits37.mid6 + 51;
    moveleft(seed, data29.words[21], 4);
    city_template.word := scratch.word + 128 * part;
    fillchar(g21.map_buffer.rows^, 960, 0);
    column := 10;
    while column <= 29 do
    begin
      row := 6;
      while row <= 17 do
      begin
        tile := city_template.city^.tiles[column - 10][row - 6];
        if find_arrival_tile and (tile = 12) then
        begin
          arrival_column := column;
          arrival_row := row
        end;
        random_value := random_word;
        tile := tile + 16 * (random_value mod 2);
        if not odd(g21.contract_city) then
          g21.map_buffer.rows^[row][column] := tile
        else if (xlow < column) and (column < xhigh) and
                (ylow < row) and (row < yhigh) then
          g21.map_buffer.rows^[row][column] := tile;
        row := row + 1
      end;
      column := column + 1
    end;
    moveleft(saved_seed, data29.words[21], 4)
  end;
  tileset_primary := (data29.loc37.low4 - 1) mod 4;
  tileset_secondary := (data29.loc37.mid5 - 1) mod 4;
  data29.flags82[116] := false;
  data29.flags82[117] := false;
  scratch.word := 21504;
  scratch.bytes^[1000] := data29.bits37.mid6;
  if find_arrival_tile then
  begin
    data29.bits38.low6 := arrival_column;
    data29.bits39.low5 := arrival_row
  end;
  if not data29.flags82[114] then
  begin
    map_x_origin := (data29.bits38.low6 - 5 + 40) mod 40;
    map_y_origin := (data29.bits39.low5 - g21.view_half_rows + 24) mod 24
  end
  else data29.flags82[114] := false;
  render_surface_tiles;
  paint_parked_transport
end;
