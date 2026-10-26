{ Library 22:34, $0584..$059C, attributes $05A6. Signed sign function. }
function proc22_34(value: integer): integer;
begin
  if value > 0 then proc22_34 := 1       { $0584..$058C }
  else if value < 0 then proc22_34 := -1 { $058E..$0597 }
  else proc22_34 := 0                   { $0599..$059A }
end;
