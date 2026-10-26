{ game_19 procedure11, $05E2..$06B9, attributes $06C6.
  Retain16-bit SQI/addition and the original wrap correction for planet low
  coordinates. Selectors other than1/2 follow the system-row path. }
function service_route_distance(place_kind, origin_index, dest_index: integer): integer;
var
  squared_distance, axis_index: integer;
  systems: g19addr;
  planets: g19paddr;
  cities: g19caddr;
begin
  squared_distance := 0;
  if place_kind = 1 then
  begin
    cities.word := data29.words[25];
    with cities.rows^[origin_index].coords5 do
      squared_distance := sqr(low6 - cities.rows^[dest_index].coords5.low6)
               + sqr(mid5 - cities.rows^[dest_index].coords5.mid5)
  end
  else if place_kind = 2 then
  begin
    planets.word := data29.words[24];
    with planets.rows^[origin_index].coords6 do
    begin
      squared_distance := word_abs(low - planets.rows^[dest_index].coords6.low);
      if squared_distance > 128 then squared_distance := squared_distance - 256;
      squared_distance := sqr(squared_distance) + sqr(high - planets.rows^[dest_index].coords6.high)
    end
  end
  else
  begin
    systems.word := data29.words[23];
    with systems.rows^[origin_index] do
    begin
      axis_index := 0;
      while axis_index <= 2 do
      begin
        squared_distance := squared_distance + sqr(nibbles8[axis_index] - systems.rows^[dest_index].nibbles8[axis_index]);
        axis_index := axis_index + 1
      end
    end
  end;
  service_route_distance := rounded_word_sqrt(squared_distance)
end;
