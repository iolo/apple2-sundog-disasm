{ library_22 procedure27, $02CE..$033B, attributes $0346.
  Two-word value copy precedes comparisons. Equality returns true. }
function proc22_27(stamp: clock4): boolean;
begin
  proc22_27 := false;
  if data29.clock42.day < stamp.day then exit(proc22_27);
  if data29.clock42.day > stamp.day then proc22_27 := true
  else
  begin
    if data29.clock42.hour < stamp.hour then exit(proc22_27);
    if data29.clock42.hour > stamp.hour then proc22_27 := true
    else
    begin
      if data29.clock42.minute < stamp.minute then exit(proc22_27);
      proc22_27 := true
    end
  end
end;
