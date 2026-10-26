{ game_19 procedure14, $070E..$0785, attributes $078E; nested in12.
  Parent22/23/24 hold elapsed/distance/work; grandparent13 is the rate. }
procedure cost_transport_route(level, leftidx, rightidx: integer);
var
  minimum_delay, random_value: integer;
begin
  distance := service_route_distance(level, leftidx, rightidx);
  selector_or_cost := g19.transport_rate * distance;
  if level = 1 then
  begin
    selector_or_cost := left_shift_word(selector_or_cost, 1);
    elapsed_minutes := 15
  end
  else if level = 2 then elapsed_minutes := distance
  else if level = 3 then
  begin
    selector_or_cost := left_shift_word(selector_or_cost, 6);
    minimum_delay := (distance + 5) * 60;
    random_value := random_word;
    elapsed_minutes := minimum_delay + random_value mod 60
  end;
  arrival_time := data29.clock42;
  add_clock_minutes(arrival_time, elapsed_minutes);
  make_amount(trip_cost, 0, selector_or_cost)
end;
