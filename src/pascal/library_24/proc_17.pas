{ library_24 procedure17, $0B5A..$0BD6, attributes $0BE0; nested in15.
  Copy bounds before subtracting the parent's VAR amount or updating value. }
procedure proc24_17(var value: integer; change, cost, marker: integer;
                    bounds: bounds4; mode1, mode2, linecode: integer);
var
  next: integer;
  edge: integer;
begin
  amount := amount - cost;
  proc24_16;
  if amount >= 0 then
  begin
    next := value + change;
    if next > 255 then value := 255
    else if next < 0 then value := 0
    else value := next
  end;
  proc24_7(bounds, value, mode1, mode2);
  if (data29.nibbles45[2] <= 1) and (marker > 0) then
  begin
    proc22_19(bounds, 0);
    edge := bounds.upper_second - proc22_31(marker, 2);
    proc22_12(bounds.lower_first, edge);
    proc22_13(linecode);
    proc22_12(bounds.upper_first - 1, edge);
    proc22_13(0);
    proc22_19(data29.bounds7, 0)
  end
end;
