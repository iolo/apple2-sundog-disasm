{ game_13 procedure27, $1F94..$1FEF, attributes $1FFA; nested in1.
  Preserve six local bytes: saved flag3, four-byte native packet at4/5.
  Child35's fifth packet byte is outside the declared frame (see its comment).
  CASE uses action-4 in signed16-bit arithmetic. Copies run even for an
  out-of-range action or a child32/36/39 error return. }
procedure execute_flight_plan(action: integer; var targetloc: g19loc);
var
  saved_clearance_block: integer;
  packet: g13packet;
(*$include src/pascal/spaceflight/write_flight_plan.pas*)
(*$include src/pascal/spaceflight/show_flight_error.pas*)
(*$include src/pascal/spaceflight/load_travel_overlay.pas*)
(*$include src/pascal/spaceflight/plan_warp_jump.pas*)
(*$include src/pascal/spaceflight/cancel_warp_jump.pas*)
(*$include src/pascal/spaceflight/perform_warp_jump.pas*)
(*$include src/pascal/spaceflight/start_sublight_trip.pas*)
(*$include src/pascal/spaceflight/stop_sublight_trip.pas*)
(*$include src/pascal/spaceflight/perform_planetary_trip.pas*)
begin
  update_flight_state;
  saved_clearance_block := ord(data29.flags82[22]);
  case action - 4 of
    0: perform_planetary_trip(targetloc);
    1: stop_sublight_trip;
    2: start_sublight_trip(targetloc);
    3: perform_warp_jump;
    4: plan_warp_jump(targetloc);
    5: cancel_warp_jump
  end;
  data29.pos36 := data29.pos72;
  if data29.flags82[7] then data29.pos228 := data29.pos72
end;
