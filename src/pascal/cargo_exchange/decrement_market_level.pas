{ game_20 procedure20, $0C7C..$0CD4, attributes $0CDE.
  Capture the quantity before random, retain lower-only clamp and packed store. }
procedure decrement_market_level(item_kind: integer; demand: boolean);
var
  quantity: integer;
  random_value: integer;
begin
  if demand then quantity := g20.demand_levels.values[item_kind]
  else quantity := g20.supply_levels.values[item_kind];
  if odd(g20.contract_mode) then quantity := quantity - 1
  else
  begin
    random_value := random_word;
    quantity := quantity - random_value mod 3
  end;
  if quantity < 0 then quantity := 0;
  if demand then g20.demand_levels.values[item_kind] := quantity
  else g20.supply_levels.values[item_kind] := quantity
end;
