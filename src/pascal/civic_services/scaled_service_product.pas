{ game_19 procedure23, $1088..$10A2, attributes $10AC; nested in22.
  Keep the threshold and division order, including the equality branch.
  No invented zero-divisor guards or widened arithmetic. }
function scaled_service_product(scale, operand, divisor: integer): integer;
begin
  if 32767 div scale <= operand then
    scaled_service_product := scale * (operand div divisor)
  else scaled_service_product := scale * operand div divisor
end;
