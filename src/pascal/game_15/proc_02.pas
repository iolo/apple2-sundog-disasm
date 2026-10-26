{ game_15 procedure2, $0000..$001E, attributes $0028.
  Bounds are copied by value into slots3..6 before any external write. }
procedure proc15_2(bounds: bounds4; mode: integer);
begin
  proc22_14(bounds.lower_first - 2, bounds.upper_first + 2,
            bounds.lower_second - 1, bounds.upper_second + 1);
  proc22_7(11);
  proc22_19(bounds, mode)
end;
