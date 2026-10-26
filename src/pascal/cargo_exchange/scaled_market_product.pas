{ game_20 procedure18, $0A70..$0A8A, attributes $0A94; nested in17.
  Retain the equality threshold and both integer division orders. }
function scaled_market_product(scale, operand, divisor: integer): integer;
begin
  if 32767 div scale <= operand then
    scaled_market_product := scale * (operand div divisor)
  else scaled_market_product := scale * operand div divisor
end;
