{ game_16 procedure40, $172C..$173B, attributes $1746.
  The third argument is unused; keep the raw byte store at DATASEG29 word62. }
procedure store_inventory_code(value, item, unused: integer);
var
  index: integer;
begin
  index := item - data31.words[14] - 1;
  data29.bytes[122 + index] := value
end;
