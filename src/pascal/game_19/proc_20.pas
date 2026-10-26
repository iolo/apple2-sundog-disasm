{ game_19 procedure20, $1016..$107C, attributes $1086.
  Retain16-bit multiply/divide order, post-call MOD16, and upper-only clamp. }
procedure proc19_20;
var
  price, quantity: integer;
begin
  price := 100 * g19.words[15] div 14;
  quantity := (data29.words[227] + 1) div 16;
  if data29.bits37.mid6 <> data29.bits73.mid6 then price := -1;
  proc19_18('FILL', 'ship', 'fuel', 'unit', price, quantity);
  quantity := data29.words[227] mod 16 + 16 * quantity;
  if quantity > 255 then quantity := 255;
  data29.words[227] := quantity
end;
