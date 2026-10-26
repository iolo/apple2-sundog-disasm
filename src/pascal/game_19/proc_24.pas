{ game_19 procedure24, $1152..$120C, attributes $121A.
  Fill only empty entries, retaining the second word and write order. }
procedure proc19_24;
var
  price, quantity, index, before: integer;
begin
  price := 100 * g19.words[15];
  quantity := 16;
  index := 1;
  while index <= 2 do
  begin
    if data29.stock234[index].kind = 0 then quantity := quantity - 1;
    index := index + 1
  end;
  before := quantity;
  if data29.flags45[13] then price := -1;
  proc19_18('BOTH', 'pod', 'load', 'load', price, quantity);
  index := 1;
  while (quantity > before) and (index < 3) do
  begin
    with data29.stock234[index] do
      if kind = 0 then
      begin
        data29.labels238[index] := 'Ship''s fuel';
        category := 7;
        origin := data29.loc37.mid5;
        kind := 1;
        quantity := quantity - 1
      end;
    index := index + 1
  end
end;
