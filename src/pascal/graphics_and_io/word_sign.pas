{ Library 22:34, $0584..$059C, attributes $05A6. Signed sign function. }
function word_sign(value: integer): integer;
begin
  if value > 0 then word_sign := 1       { $0584..$058C }
  else if value < 0 then word_sign := -1 { $058E..$0597 }
  else word_sign := 0                   { $0599..$059A }
end;
