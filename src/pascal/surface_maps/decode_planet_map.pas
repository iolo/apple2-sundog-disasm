{ game_21 procedure28, $10F2..$12C2, attributes $12D6.
  Cache miss decodes the planet map, then randomizes tile13 in column-major
  order under temporary random state. City markers are written on cache hits
  too. Special city60 placement retries without an invented attempt limit. }
procedure decode_planet_map;
var
  planet_index, cached_planet, part, column, row, first_city, last_city, index: integer;
  random_value: integer;
  tile_address: address16;
  saved_seed: wordpair;
  seed: wordpair;
  scratch: address16;
  planet: g19paddr;
  city_row: g19caddr;
begin
  planet_index := data29.loc37.mid5 - 1;
  scratch.word := 20480;
  cached_planet := scratch.bytes^[1000];
  if cached_planet <> planet_index + 1 then
  begin
    scratch.word := 6144;
    disk_blocks_io(scratch.word, 1, data29.words[29] + planet_index div 2, true);
    part := planet_index mod 2;
    expand_tile_map(scratch.word + 256 * part + 16, g21.map_buffer.word);
    moveleft(data29.words[21], saved_seed, 4);
    seed.first := 3 * data29.loc37.mid5 + 39;
    seed.second := 11 * data29.loc37.mid5 + 51;
    moveleft(seed, data29.words[21], 4);
    column := 0;
    while column <= 39 do
    begin
      row := 0;
      while row <= 23 do
      begin
        if g21.map_buffer.rows^[row][column] = 13 then
        begin
          { Capture the destination before the random call, as in $118A. }
          tile_address.word := g21.map_buffer.word + 40 * row + column;
          random_value := random_word;
          tile_address.bytes^[0] := 14 + random_value mod 7
        end;
        row := row + 1
      end;
      column := column + 1
    end;
    moveleft(saved_seed, data29.words[21], 4)
  end;
  planet.word := data29.words[24] + 16 * (data29.loc37.mid5 - 1);
  first_city := planet.rows^[1].place7.mid6;
  last_city := planet.rows^[1].place7.low9 mod 8 + first_city - 1;
  index := first_city;
  while index <= last_city do
  begin
    city_row.word := data29.words[25] + 12 * (index - 1);
    g21.map_buffer.rows^[city_row.rows^[1].coords5.mid5]
                   [city_row.rows^[1].coords5.low6] := 13;
    index := index + 1
  end;
  if data29.loc37.mid5 = 1 then
  begin
    city_row.word := data29.words[25] + 12 * (60 - 1);
    if data29.flags82[112] then
    begin
      data29.flags82[112] := false;
      repeat
        random_value := random_word;
        index := random_value mod 960;
        city_row.rows^[1].coords5.low6 := index mod 40;
        city_row.rows^[1].coords5.mid5 := index div 40
      until g21.map_buffer.rows^[city_row.rows^[1].coords5.mid5]
                           [city_row.rows^[1].coords5.low6] >= 14
    end;
    g21.map_buffer.rows^[city_row.rows^[1].coords5.mid5]
                   [city_row.rows^[1].coords5.low6] := 13
  end;
  scratch.word := 20480;
  scratch.bytes^[1000] := data29.loc37.mid5;
  tileset_primary := 4;
  tileset_secondary := 4;
  data29.flags82[116] := false;
  map_x_origin := (data29.bits38.low6 - 5 + 40) mod 40;
  map_y_origin := (data29.bits39.low5 - g21.view_half_rows + 24) mod 24;
  if map_y_origin > 20 then map_y_origin := 0;
  render_surface_tiles
end;
