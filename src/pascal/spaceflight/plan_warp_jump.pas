{ game_13 procedure32, $1630..$170A, attributes $1714; nested in27.
  Copy both full20-byte system rows before displaying their16-byte prefixes.
  Preserve signed16-bit cost arithmetic and the priority of failure checks. }
procedure plan_warp_jump(var place: g19loc);
var
  dest_system: integer; {2}
  origin_system: integer;  {3}
  warp_cost: integer;    {4}
  distance: integer;{5}
  dest_row: name20;  {6..15}
  origin_row: name20;   {16..25}
(*$include src/pascal/spaceflight/reject_warp_plan.pas*)
begin
  origin_system := data29.loc73.low4;
  dest_system := place.fields.system;
  origin_row := data29.names23.systems^[origin_system];
  dest_row := data29.names23.systems^[dest_system];
  write_flight_plan('J-SPACE', origin_row.caption, dest_row.caption);
  update_flight_state;
  distance := system_distance(origin_system, dest_system);
  write_wrapped_text('Dist:  ');
  write_integer(distance, 2, false);
  write_wrapped_text(' j-secs\');
  warp_cost := 3 * (distance * distance) + 10;
  if warp_cost > 255 then reject_warp_plan(1)
  else if data29.fuel_amount = 0 then reject_warp_plan(0)
  else if data29.bytes[178 + 24] = 0 then reject_warp_plan(4)
  else
  begin
    if warp_cost > data29.warp_charge + 2 * data29.fuel_amount then show_flight_error(2);
    data29.flags82[0] := true;
    data29.warp_setting := warp_cost;
    data29.warp_destination_system := place.fields.system;
    write_wrapped_text('Warp engines charging')
  end
end;
