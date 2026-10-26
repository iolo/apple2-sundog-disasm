{ game_20 procedure20, $0C7C..$0CD4, attributes $0CDE.
  Capture the quantity before random, retain lower-only clamp and packed store. }
procedure proc20_20(kind: integer; demand: boolean);
var
  quantity: integer;
  randomv: integer;
begin
  if demand then quantity := g20.stock22.values[kind]
  else quantity := g20.stock29.values[kind];
  if odd(g20.words[16]) then quantity := quantity - 1
  else
  begin
    randomv := proc22_3;
    quantity := quantity - randomv mod 3
  end;
  if quantity < 0 then quantity := 0;
  if demand then g20.stock22.values[kind] := quantity
  else g20.stock29.values[kind] := quantity
end;
