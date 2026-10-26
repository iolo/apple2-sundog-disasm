{ game_13 procedure40, $1CFC..$1D19, attributes $1D24; nested in39.
  City rows have12-byte stride; SAS15 copies their length-prefixed caption. }
procedure proc13_40(var caption: text15; city: integer);
begin
  if city = 0 then caption := 'orbit'
  else caption := data29.names25.cities^[city]
end;
