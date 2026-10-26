{ game_20 procedure15, $0856..$08BE, attributes $08CA; nested in13.
  Both scalar arguments are unused. Keep the captured row through text calls
  and reread its kind/category after displaying its name. }
procedure proc20_15(ignoredfirst, ignoredsecond: integer);
var
  index: integer;
begin
  proc20_14;
  proc22_48('Contents:\|\');
  index := 1;
  while index <= 4 do
  begin
    with g20.ware52[index] do
    begin
      proc22_48('|||');
      proc22_48(g20.names19.names^[kind]);
      if kind > 0 then
      begin
        proc22_48(' / ');
        proc22_47(72 - category)
      end;
      if index < 4 then proc22_45;
      index := index + 1
    end
  end
end;
