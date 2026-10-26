{ game_21 procedure18, $084E..$09AD, attributes $09B8.
  Search this planet's half-open city range, then special city60 on planet1.
  Preserve signed16-bit scaling, edge priority, and packed truncation. }
procedure enter_city_tile(map_column, map_row: integer);
var
  left_limit, right_limit, top_limit, bottom_limit, city, limit: integer;
  found: boolean;
  planet: g19paddr;
  city_row: g19caddr;
begin
  found := false;
  planet.word := data29.words[24] + 16 * (data29.loc37.mid5 - 1);
  city := planet.rows^[1].place7.mid6;
  limit := planet.rows^[1].place7.mid6 + planet.rows^[1].place7.low9 mod 8;
  while (city < limit) and not found do
  begin
    city_row.word := data29.words[25] + 12 * (city - 1);
    if (city_row.rows^[1].coords5.low6 = map_column) and
       (city_row.rows^[1].coords5.mid5 = map_row) then found := true
    else city := city + 1
  end;
  if not found and (data29.loc37.mid5 = 1) then
  begin
    city_row.word := data29.words[25] + 12 * (60 - 1);
    if (city_row.rows^[1].coords5.low6 = map_column) and
       (city_row.rows^[1].coords5.mid5 = map_row) then
    begin
      found := true;
      city := 60
    end
  end;
  if not found then exit(enter_city_tile);
  data29.bits37.mid6 := city;
  data29.nibbles45[1] := data29.nibbles45[2];
  data29.nibbles45[2] := 3;
  g21.player_x := (g21.player_x + 3) mod 28;
  g21.player_y := (g21.player_y - 3) mod g21.tile_height_pixels;
  derive_city_limits(left_limit, right_limit, top_limit, bottom_limit);
  data29.bits38.low6 := left_limit + (right_limit - left_limit + 1) * g21.player_x div 28;
  data29.bits39.low5 := top_limit + (bottom_limit - top_limit + 1) * g21.player_y div g21.tile_height_pixels;
  if g21.player_x < 7 then
  begin
    data29.bits38.low6 := left_limit;
    data29.words[292] := 8
  end
  else if g21.player_y < 12 then
  begin
    data29.bits39.low5 := top_limit;
    data29.words[292] := 6
  end
  else if g21.player_x > 20 then
  begin
    data29.bits38.low6 := right_limit;
    data29.words[292] := 2
  end
  else
  begin
    data29.bits39.low5 := bottom_limit;
    data29.words[292] := 4
  end;
  data29.words[40] := 160;
  data29.bytes[80] := 108;
  if not data29.flags45[13] then data29.rec228 := data29.rec36
end;
