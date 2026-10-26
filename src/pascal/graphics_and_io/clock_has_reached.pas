{ library_22 procedure27, $02CE..$033B, attributes $0346.
  Two-word value copy precedes comparisons. Equality returns true. }
function clock_has_reached(stamp: clock4): boolean;
begin
  clock_has_reached := false;
  if data29.clock42.day < stamp.day then exit(clock_has_reached);
  if data29.clock42.day > stamp.day then clock_has_reached := true
  else
  begin
    if data29.clock42.hour < stamp.hour then exit(clock_has_reached);
    if data29.clock42.hour > stamp.hour then clock_has_reached := true
    else
    begin
      if data29.clock42.minute < stamp.minute then exit(clock_has_reached);
      clock_has_reached := true
    end
  end
end;
