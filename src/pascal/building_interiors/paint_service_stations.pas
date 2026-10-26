{ game_18 procedure 19, $0D5E..$0DFE, attributes $0E0A. }
procedure paint_service_stations;
var
  firsthigh, secondbase, firstlow: integer;
  secondhi, secondlo, firstlo, firsthi, column: integer;
begin
  firstlow := data29.words[14] - 2;
  firsthigh := data29.words[13] + 2;
  secondbase := data29.words[12] - 2;
  assign_bounds(service_area_bounds, firstlow, firsthigh, secondbase + 8, secondbase + 27);
  assign_bounds(station_strip_bounds, firstlow, firsthigh, secondbase + 28, secondbase + 40);
  column := 0;
  while column <= 3 do
  begin
    firstlo := (firstlow + 21) + column * 28;
    firsthi := firstlo + 20;
    secondlo := secondbase + 8;
    secondhi := secondlo + 19;
    set_clip_bounds(firstlo, firsthi, secondlo, secondhi);
    draw_clip_pattern(on_station_pattern);
    firstlo := firstlo + 7;
    firsthi := firstlo + 7;
    secondhi := secondlo + 28;
    set_clip_bounds(firstlo, firsthi, secondlo, secondhi);
    draw_clip_pattern(on_station_pattern);
    station_flags[column] := true;
    set_service_indicator(column + 1, false);
    column := column + 1
  end;
  apply_bounds(data29.bounds11, 0)
end;
