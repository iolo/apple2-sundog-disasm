{ game_19 procedure12, $0790..$09A9, attributes $09BA.
  Retain parent slots8..28 consumed by nested13/14. Extra input snapshots
  follow those slots and preserve both calls even when the timeout expires. }
procedure book_passenger_transport(kind, index: integer; area: bounds4);
var
  destination_name: text15; {8..15}
  arrival_place: g19loc;   {16..21}
  elapsed_minutes: integer; {22}
  distance: integer; {23}
  selector_or_cost: integer;    {24}
  trip_cost: wordpair;   {25..26}
  arrival_time: clock4;      {27..28}
  timedout: boolean;
  input0: integer;
  input1: integer;
(*$include src/pascal/civic_services/write_transport_place.pas*)
(*$include src/pascal/civic_services/cost_transport_route.pas*)
begin
  apply_bounds(area, 8);
  apply_bounds(data29.bounds11, 0);
  compose_transport_location(kind, index, arrival_place);
  set_text_grid_position(0, 5);
  write_wrapped_text('|||||Destination');
  g19.spendable_snapshot := g19.working_funds;
  selector_or_cost := 1;
  write_transport_place('City:      ', arrival_place.fields.city);
  write_transport_place('Planet:    ', arrival_place.fields.planet);
  write_transport_place('System:    ', arrival_place.fields.system);
  case kind of
    1: cost_transport_route(kind, arrival_place.fields.city, data29.bits37.mid6);
    2: cost_transport_route(kind, arrival_place.fields.planet, data29.loc37.mid5);
    3: cost_transport_route(kind, arrival_place.fields.system, data29.loc37.low4)
  end;
  set_text_grid_position(0, 13);
  write_captioned_amount('Cost:      ', trip_cost);
  set_text_grid_position(20, 13);
  write_wrapped_text('Cr');
  if amount_greater(trip_cost, g19.spendable_snapshot) then
  begin
    set_text_grid_position(0, 15);
    write_wrapped_text('||Insufficient funds');
    selector_or_cost := 1000;
    repeat
      selector_or_cost := selector_or_cost - 1;
      timedout := selector_or_cost = 0;
      input0 := poll_input(0);
      input1 := poll_input(1)
    until timedout or odd(input0) or odd(input1);
    exit(book_passenger_transport)
  end;
  set_text_grid_position(0, 15);
  write_wrapped_text('E.T.A.:      ');
  draw_clock(arrival_time);
  reset_menu;
  add_menu_button(1, 'TRANSPORT', g19.menu_left, g19.menu_right,
            g19.menu_bottom - 10, g19.menu_bottom);
  selector_or_cost := 0;
  g19.menu_confirmed := 0;
  poll_service_menu(selector_or_cost, g19.menu_hit, data29.words[297], data29.bounds11, g19.menu_confirmed);
  if selector_or_cost <> 1 then exit(book_passenger_transport);
  subtract_amount(trip_cost, g19.working_funds);
  settle_service_funds;
  set_text_grid_position(0, 15);
  set_clip_bounds(data29.words[14], data29.words[13], data29.text_y + 1, data29.words[11]);
  draw_clip_pattern(8);
  apply_bounds(data29.bounds11, 0);
  set_text_grid_position(0, 17);
  write_wrapped_text('Time:        ');
  set_text_grid_position(13, 17);
  repeat
    add_clock_minutes(data29.clock42, 5);
    move_pen(data29.text_x, data29.text_y);
    draw_clock(data29.clock42)
  until clock_has_reached(arrival_time);
  g19.trip_completed := 1;
  data29.flags82[28] := true;
  data29.flags82[116] := false;
  data29.flags82[117] := false;
  data29.rec36 := arrival_place.words
end;
