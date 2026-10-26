{ library_22 procedure 37, $06DA..$06EE, attributes $06F8.
  Ordered tests are significant when lower > upper. }
procedure proc22_37(lower: integer; var value: integer; upper: integer);
begin
  if value < lower then value := lower
  else if value > upper then value := upper
end;
