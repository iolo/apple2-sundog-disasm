{ library_24 procedure9, $0E06..$0E50, attributes $0E5A.
  Shared update entry: save amount before the clock call, update it through
  both VAR callers, test the resulting flag40, then store and draw it. }
procedure update_flight_state;
var
  amount: integer;
begin
  amount := data29.fuel_amount;
  data29.words[352] := data29.words[352] mod 4;
  if data29.words[352] = 0 then advance_clock_and_conditions;
  data29.words[352] := data29.words[352] + 1;
  update_travel_and_encounters(amount);
  update_ship_resources(amount);
  if data29.flags82[40] then update_encounter_and_damage;
  data29.fuel_amount := amount;
  draw_vertical_gauge(data29.fuel_gauge_bounds, data29.fuel_amount, 8, 10)
end;
