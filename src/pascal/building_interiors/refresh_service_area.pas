{ game_18 procedure 25, $1438..$148D, attributes $1498, lexical level 2.
  Complete body; depends on recovered procedures 2 and 15 and parent storage. }
procedure refresh_service_area;
var
  station_index: integer;
begin
  { $1438..$1440: DATASEG29 word82 + floor(57/16), bit 57 mod 16. }
  data29.flags82[57] := false;
  { $1441..$1447 }
  with room_actors[1] do
  begin
    { $1449..$1454: the two zero words reserve the function's return storage. }
    if inside_actor_area(words[5], words[4], station_strip_bounds) then
    begin
      { $1456..$1463: preserve the nested subtraction before signed division. }
      station_index := ((words[5] - (room_left - 2)) div 28) + 1;
      { $1465..$1472: unequal values do NOT trigger procedure 15. }
      if station_index = active_station then
        set_service_indicator(active_station, true)
    end
    else
    begin
      { $1474..$1478: native effects inside procedure 15 precede these reads. }
      set_service_indicator(active_station, false);
      { $147A..$148C }
      data29.flags82[57] :=
        inside_actor_area(words[5], words[4], service_area_bounds)
    end
  end
  { $148D: RNP 0. }
end;
