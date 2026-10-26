{ game_21 procedure18, $084E..$09AD, attributes $09B8.
  Search this planet's half-open city range, then special city60 on planet1.
  Preserve signed16-bit scaling, edge priority, and packed truncation. }
procedure proc21_18(mapx, mapy: integer);
var
  xlow, xhigh, ylow, yhigh, city, limit: integer;
  found: boolean;
  planet: g19paddr;
  cityrow: g19caddr;
begin
  found := false;
  planet.word := data29.words[24] + 16 * (data29.loc37.mid5 - 1);
  city := planet.rows^[1].place7.mid6;
  limit := planet.rows^[1].place7.mid6 + planet.rows^[1].place7.low9 mod 8;
  while (city < limit) and not found do
  begin
    cityrow.word := data29.words[25] + 12 * (city - 1);
    if (cityrow.rows^[1].coords5.low6 = mapx) and
       (cityrow.rows^[1].coords5.mid5 = mapy) then found := true
    else city := city + 1
  end;
  if not found and (data29.loc37.mid5 = 1) then
  begin
    cityrow.word := data29.words[25] + 12 * (60 - 1);
    if (cityrow.rows^[1].coords5.low6 = mapx) and
       (cityrow.rows^[1].coords5.mid5 = mapy) then
    begin
      found := true;
      city := 60
    end
  end;
  if not found then exit(proc21_18);
  data29.bits37.mid6 := city;
  data29.nibbles45[1] := data29.nibbles45[2];
  data29.nibbles45[2] := 3;
  g21.words[26] := (g21.words[26] + 3) mod 28;
  g21.words[25] := (g21.words[25] - 3) mod g21.words[21];
  proc21_17(xlow, xhigh, ylow, yhigh);
  data29.bits38.low6 := xlow + (xhigh - xlow + 1) * g21.words[26] div 28;
  data29.bits39.low5 := ylow + (yhigh - ylow + 1) * g21.words[25] div g21.words[21];
  if g21.words[26] < 7 then
  begin
    data29.bits38.low6 := xlow;
    data29.words[292] := 8
  end
  else if g21.words[25] < 12 then
  begin
    data29.bits39.low5 := ylow;
    data29.words[292] := 6
  end
  else if g21.words[26] > 20 then
  begin
    data29.bits38.low6 := xhigh;
    data29.words[292] := 2
  end
  else
  begin
    data29.bits39.low5 := yhigh;
    data29.words[292] := 4
  end;
  data29.words[40] := 160;
  data29.bytes[80] := 108;
  if not data29.flags45[13] then data29.rec228 := data29.rec36
end;
