{ library_22 procedure36, $05C2..$05F4, attributes $0600.
  Keep the odd-number accumulation and native shift. No overflow repair or
  floating-point square-root substitution is implied by this recovery. }
function proc22_36(value: integer): integer;
var
  candidate: integer;
  total: integer;
  step: integer;
begin
  step := -1;
  total := 0;
  repeat
    step := step + 2;
    total := total + step
  until value < total;
  candidate := proc22_31(step, 1) + 1;
  if value > total - candidate then proc22_36 := candidate
  else proc22_36 := candidate - 1
end;
