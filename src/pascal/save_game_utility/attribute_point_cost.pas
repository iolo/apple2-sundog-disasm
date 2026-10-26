{ utility_disk1:27 $0D8E..$0DB6, attributes$0DC2. Integer result1,
  value parameter3, local cost4. Retain signed16-bit arithmetic and overflow;
  do not replace this loop with a floating-point exponential or clamp. }
function attribute_point_cost(stat_value: integer): integer;
var point_cost: integer;
begin
  point_cost := 1;
  stat_value := stat_value - 30;
  while stat_value > 0 do
  begin
    point_cost := point_cost * 2;
    if stat_value > 60 then stat_value := stat_value - 10
    else stat_value := stat_value - 20
  end;
  attribute_point_cost := point_cost
end;
