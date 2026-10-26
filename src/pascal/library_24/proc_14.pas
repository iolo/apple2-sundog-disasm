{ library_24 procedure14, $0AAC..$0AC1, attributes $0ACC.
  Keep both signed multiplications; direction need not be restricted to +/-1. }
procedure proc24_14(var result: integer; current, change, limit, direction: integer);
begin
  if direction * (current + change) > direction * limit then
    result := limit - current
  else result := change
end;
