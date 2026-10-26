{ game_13 procedure33, $1612..$1623, attributes $162E; nested in32. }
procedure reject_warp_plan(reason: integer);
begin
  show_flight_error(reason);
  data29.flags82[0] := false;
  data29.warp_setting := 0
end;
