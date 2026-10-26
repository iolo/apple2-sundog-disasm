{ utility_disk1:27 $0D8E..$0DB6, attributes$0DC2. Integer result1,
  value parameter3, local cost4. Retain signed16-bit arithmetic and overflow;
  do not replace this loop with a floating-point exponential or clamp. }
function util1_27(value: integer): integer;
var cost: integer;
begin
  cost := 1;
  value := value - 30;
  while value > 0 do
  begin
    cost := cost * 2;
    if value > 60 then value := value - 10
    else value := value - 20
  end;
  util1_27 := cost
end;
