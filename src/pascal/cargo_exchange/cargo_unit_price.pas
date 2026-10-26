{ game_20 procedure16, $0B6A..$0C71, attributes $0C7A.
  Copy the two-word item first. The name row's byte15 supplies the base price.
  Nested19 uses srcsys/srcplan at slots9/10. }
function cargo_unit_price(item: stock4; selling: boolean): integer;
var
  supply: integer; {7}
  demand: integer; {8}
  origin_system: integer; {9}
  origin_planet: integer; {10}
  price_ceiling: integer; {11}
  unit_price: integer; {12}
  planets: g19paddr;
(*$include src/pascal/cargo_exchange/adjust_market_price.pas*)
(*$include src/pascal/cargo_exchange/locate_cargo_origin.pas*)
begin
  unit_price := g20.cargo_names.bytes^[16 * item.kind + 15];
  if odd(g20.contract_mode) then
  begin
    demand := g20.demand_target.values[item.kind];
    supply := g20.supply_target.values[item.kind]
  end
  else
  begin
    demand := g20.demand_levels.values[item.kind];
    supply := g20.supply_levels.values[item.kind]
  end;
  adjust_market_price(unit_price, demand, supply);
  adjust_market_price(unit_price, g20.system_price_scale, 8);
  adjust_market_price(unit_price, item.category, 6);
  if (16 <= item.kind) and (item.kind <= 24) then
    adjust_market_price(unit_price, 8, g20.grade_price_scale);
  planets.word := data29.words[24];
  if data29.bits37.mid6 <> planets.rows^[data29.loc37.mid5].place7.low9 div 8 then
    if selling then adjust_market_price(unit_price, 8, 6)
    else adjust_market_price(unit_price, 6, 8);
  price_ceiling := unit_price;
  if selling then
  begin
    locate_cargo_origin(item.origin);
    price_ceiling := item.word1;
    if item.origin <> data29.bits37.mid6 then
      if origin_planet = data29.loc37.mid5 then adjust_market_price(price_ceiling, 8, 6)
      else if origin_system = data29.loc37.low4 then adjust_market_price(price_ceiling, 8, 4)
      else price_ceiling := unit_price
  end;
  clamp_word(1, unit_price, price_ceiling);
  cargo_unit_price := unit_price
end;
