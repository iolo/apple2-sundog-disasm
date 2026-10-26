{ game_20 procedure16, $0B6A..$0C71, attributes $0C7A.
  Copy the two-word item first. The name row's byte15 supplies the base price.
  Nested19 uses srcsys/srcplan at slots9/10. }
function proc20_16(item: stock4; selling: boolean): integer;
var
  supply: integer; {7}
  demand: integer; {8}
  srcsys: integer; {9}
  srcplan: integer; {10}
  ceiling: integer; {11}
  price: integer; {12}
  planets: g19paddr;
(*$include src/pascal/game_20/proc_17.pas*)
(*$include src/pascal/game_20/proc_19.pas*)
begin
  price := g20.names19.bytes^[16 * item.kind + 15];
  if odd(g20.words[16]) then
  begin
    demand := g20.stock38.values[item.kind];
    supply := g20.stock45.values[item.kind]
  end
  else
  begin
    demand := g20.stock22.values[item.kind];
    supply := g20.stock29.values[item.kind]
  end;
  proc20_17(price, demand, supply);
  proc20_17(price, g20.words[10], 8);
  proc20_17(price, item.category, 6);
  if (16 <= item.kind) and (item.kind <= 24) then
    proc20_17(price, 8, g20.words[9]);
  planets.word := data29.words[24];
  if data29.bits37.mid6 <> planets.rows^[data29.loc37.mid5].place7.low9 div 8 then
    if selling then proc20_17(price, 8, 6)
    else proc20_17(price, 6, 8);
  ceiling := price;
  if selling then
  begin
    proc20_19(item.origin);
    ceiling := item.word1;
    if item.origin <> data29.bits37.mid6 then
      if srcplan = data29.loc37.mid5 then proc20_17(ceiling, 8, 6)
      else if srcsys = data29.loc37.low4 then proc20_17(ceiling, 8, 4)
      else ceiling := price
  end;
  proc22_37(1, price, ceiling);
  proc20_16 := price
end;
