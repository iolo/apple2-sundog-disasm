{ game_19 procedure11, $05E2..$06B9, attributes $06C6.
  Retain16-bit SQI/addition and the original wrap correction for planet low
  coordinates. Selectors other than1/2 follow the system-row path. }
function proc19_11(kind, leftidx, rightidx: integer): integer;
var
  total, axis: integer;
  systems: g19addr;
  planets: g19paddr;
  cities: g19caddr;
begin
  total := 0;
  if kind = 1 then
  begin
    cities.word := data29.words[25];
    with cities.rows^[leftidx].coords5 do
      total := sqr(low6 - cities.rows^[rightidx].coords5.low6)
               + sqr(mid5 - cities.rows^[rightidx].coords5.mid5)
  end
  else if kind = 2 then
  begin
    planets.word := data29.words[24];
    with planets.rows^[leftidx].coords6 do
    begin
      total := proc22_35(low - planets.rows^[rightidx].coords6.low);
      if total > 128 then total := total - 256;
      total := sqr(total) + sqr(high - planets.rows^[rightidx].coords6.high)
    end
  end
  else
  begin
    systems.word := data29.words[23];
    with systems.rows^[leftidx] do
    begin
      axis := 0;
      while axis <= 2 do
      begin
        total := total + sqr(nibbles8[axis] - systems.rows^[rightidx].nibbles8[axis]);
        axis := axis + 1
      end
    end
  end;
  proc19_11 := proc22_36(total)
end;
