{ game_13 procedure29, $14CE..$15CC, attributes $15DA; nested in27.
  Values outside0..6 do nothing. Cases3/6 share the denial path;4/5 share repair. }
procedure proc13_29(reason: integer);
(*$include src/pascal/game_13/proc_30.pas*)
begin
  case reason of
    0: proc13_30('Out of fuel');
    1: proc13_30('Beyond maximum jump');
    2: proc13_30('WARNING:  Fuel low');
    3, 6:
      begin
        proc13_30('Lift clearance denied');
        if reason = 3 then proc13_30('due to pirate activity')
        else proc13_30('due to unpaid debts')
      end;
    4, 5:
      begin
        if reason = 4 then proc13_30('Warp engines blown')
        else proc13_30('Sub-c engines blown');
        proc13_30('Please repair')
      end
  end
end;
