{ game_20 procedure11, $0676..$06CE, attributes $06DC.
  Negative result means no empty entry: scan two pods or four warehouse slots. }
procedure proc20_11(var chosen: integer; pods: boolean);
var
  index: integer;
begin
  chosen := -1;
  index := 1;
  if pods then
    while (chosen < 0) and (index < 3) do
      if data29.stock234[index].kind = 0 then chosen := index
      else index := index + 1
  else
    while (chosen < 0) and (index < 5) do
      if g20.ware52[index].kind = 0 then chosen := index
      else index := index + 1
end;
