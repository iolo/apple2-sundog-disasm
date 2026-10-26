{ game_13 procedure29, $14CE..$15CC, attributes $15DA; nested in27.
  Values outside0..6 do nothing. Cases3/6 share the denial path;4/5 share repair. }
procedure show_flight_error(reason: integer);
(*$include src/pascal/spaceflight/emit_flight_warning.pas*)
begin
  case reason of
    0: emit_flight_warning('Out of fuel');
    1: emit_flight_warning('Beyond maximum jump');
    2: emit_flight_warning('WARNING:  Fuel low');
    3, 6:
      begin
        emit_flight_warning('Lift clearance denied');
        if reason = 3 then emit_flight_warning('due to pirate activity')
        else emit_flight_warning('due to unpaid debts')
      end;
    4, 5:
      begin
        if reason = 4 then emit_flight_warning('Warp engines blown')
        else emit_flight_warning('Sub-c engines blown');
        emit_flight_warning('Please repair')
      end
  end
end;
