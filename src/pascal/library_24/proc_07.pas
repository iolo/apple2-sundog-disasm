{ library_24 procedure7, $00F8..$013F, attributes $014A.
  Four-word value copy occurs even when the mode gate suppresses drawing. }
procedure proc24_7(bounds: bounds4; value, mode1, mode2: integer);
var
  edge: integer;
begin
  if data29.nibbles45[2] <= 1 then
  begin
    edge := bounds.upper_second - proc22_31(value + 3, 2);
    if edge > bounds.lower_second then
    begin
      proc22_14(bounds.lower_first, bounds.upper_first, bounds.lower_second, edge);
      proc22_7(mode1)
    end;
    if edge + 1 < bounds.upper_second then
    begin
      proc22_14(bounds.lower_first, bounds.upper_first, edge + 1, bounds.upper_second);
      proc22_7(mode2)
    end;
    proc22_19(data29.bounds7, 0)
  end
end;
