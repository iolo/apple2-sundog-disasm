{ game_19 procedure21, $10E2..$1147, attributes $1150.
  Byte192 relative to DATASEG29 word90 is absolute byte370. }
procedure proc19_21;
var
  price, quantity: integer;
(*$include src/pascal/game_19/proc_22.pas*)
begin
  quantity := data29.bytes[370];
  price := 250 * ((16 - quantity) div 4 + 1);
  proc19_22(price, 12, g19.words[12]);
  proc19_22(price, g19.words[13], 11);
  if data29.bits37.mid6 <> data29.bits73.mid6 then price := -1;
  proc19_18('ALL', 'ship', 'repair', 'hour', price, quantity);
  data29.bytes[370] := quantity
end;
