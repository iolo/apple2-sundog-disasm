{ game_19 procedure23, $1088..$10A2, attributes $10AC; nested in22.
  Keep the threshold and division order, including the equality branch.
  No invented zero-divisor guards or widened arithmetic. }
function proc19_23(scale, operand, divisor: integer): integer;
begin
  if 32767 div scale <= operand then
    proc19_23 := scale * (operand div divisor)
  else proc19_23 := scale * operand div divisor
end;
