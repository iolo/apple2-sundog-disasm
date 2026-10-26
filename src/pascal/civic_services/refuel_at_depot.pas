{ game_19 procedure20, $1016..$107C, attributes $1086.
  Retain16-bit multiply/divide order, post-call MOD16, and upper-only clamp. }
procedure refuel_at_depot;
var
  price, quantity: integer;
begin
  price := 100 * g19.depot_unit_factor div 14;
  quantity := (data29.fuel_amount + 1) div 16;
  if data29.bits37.mid6 <> data29.bits73.mid6 then price := -1;
  buy_service_units('FILL', 'ship', 'fuel', 'unit', price, quantity);
  quantity := data29.fuel_amount mod 16 + 16 * quantity;
  if quantity > 255 then quantity := 255;
  data29.fuel_amount := quantity
end;
