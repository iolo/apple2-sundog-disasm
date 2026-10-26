{ game_19 procedure21, $10E2..$1147, attributes $1150.
  Byte192 relative to DATASEG29 word90 is absolute byte370. }
procedure repair_at_depot;
var
  price, quantity: integer;
(*$include src/pascal/civic_services/adjust_service_price.pas*)
begin
  quantity := data29.bytes[370];
  price := 250 * ((16 - quantity) div 4 + 1);
  adjust_service_price(price, 12, g19.repair_discount);
  adjust_service_price(price, g19.transport_rate, 11);
  if data29.bits37.mid6 <> data29.bits73.mid6 then price := -1;
  buy_service_units('ALL', 'ship', 'repair', 'hour', price, quantity);
  data29.bytes[370] := quantity
end;
