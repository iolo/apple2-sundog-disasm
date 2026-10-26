{ game_15 procedure10, $049A..$04EF, attributes $04FC.
  Inspect at most two4-byte stock rows. Set word227 before clearing the
  matching5-bit kind and its15-character caption; preserve adjacent fields. }
procedure use_cargo_fuel;
var
  index: integer;
begin
  if data29.fuel_amount < 5 then
  begin
    index := 1;
    while (data29.fuel_amount < 5) and (index < 3) do
    begin
      if data29.stock234[index].kind = 1 then
      begin
        data29.fuel_amount := 255;
        data29.stock234[index].kind := 0;
        data29.labels238[index] := '';
        index := 4
      end
      else index := index + 1
    end
  end
end;
