{ game_13 procedure16, $0A2E..$0C19, attributes $0C28; nested in13.
  The value location occupies copied slots2..7; the full16-byte planet row
  is copied to16..23 after the initial calls. City count and loop index are
  grandparent12 slots7/6. Special final entry60 retains its original code
  calculation relative to the planet's first city, even outside the count.
  Temporary25 supplies the initial row copy, then the captured city pointer. }
procedure proc13_16(localcopy: g19loc);
var
  city: integer;   {8}
  ypos: integer;   {9}
  xpos: integer;   {10}
  visible: boolean; {11}
  special: boolean; {12}
  flag31: boolean;  {13}
  known: boolean;   {14}
  same: boolean;    {15}
  planetrow: g19planet; {16..23}
  last: integer;    {24}
  row: g13rowptr;   {25}
(*$include src/pascal/game_13/proc_17.pas*)
begin
  proc25_2;
  proc22_16(data29.words[344], data29.words[346] div 7);
  row.word := data29.words[24] + 16 * (localcopy.fields.planet - 1);
  planetrow := row.planetrow^;
  if odd(redraw) then
  begin
    proc22_19(data29.bnd343, 8);
    proc22_13(10);
    proc24_2(45, data29.words[346] + 50, data29.words[344] + 48);
    proc22_13(0);
    proc22_13(10);
    proc24_2(45, data29.words[346] + 91, data29.words[344] + 48);
    proc22_13(0);
    proc22_14(data29.words[346] + 40, data29.words[346] + 100,
              data29.words[344] + 8, data29.words[344] + 88);
    proc22_7(8)
  end;
  same := (data29.loc73.low4 = localcopy.fields.system) and
          (data29.loc73.mid5 = localcopy.fields.planet);
  flag31 := data29.flags82[31];
  known := same and data29.flags82[21] and (not flag31);
  special := (localcopy.fields.planet = 1) and known and data29.flags82[113];
  proc13_17(41, 3, xpos, ypos);
  if odd(redraw) then
  begin
    xpos := xpos + data29.words[346];
    ypos := ypos + data29.words[344];
    proc22_19(data29.bnd343, 0);
    if (data29.pos72.fields.city = 0) and same then
    begin
      proc22_12(proc22_32(xpos - 2, 254), ypos + 4);
      proc22_9(data29.words[294])
    end
  end;
  proc22_11(1);
  proc22_13(0);
  city := planetrow.place7.mid6;
  mapstate[7] := planetrow.place7.low9 mod 8;
  if special then mapstate[7] := mapstate[7] + 1;
  mapstate[6] := 1;
  last := mapstate[7];
  while mapstate[6] <= last do
  begin
    if (mapstate[6] = mapstate[7]) and special then city := 60;
    visible := (city = planetrow.place7.mid6) or known or flag31;
    row.word := data29.words[25] + 12 * (city - 1);
    proc13_17(row.cityrow^.coords5.low6, row.cityrow^.coords5.mid5,
                xpos, ypos);
    if odd(redraw) then
    begin
      proc22_12(proc22_32(data29.words[346] + xpos, 254),
                data29.words[344] + ypos);
      if visible then proc22_9(30) else proc22_9(32);
      if (city = data29.pos72.fields.city) and same then
        proc22_9(data29.words[294])
    end;
    if visible then
      proc25_4(city - planetrow.place7.mid6 + 1, 30, xpos, ypos);
    city := city + 1;
    mapstate[6] := mapstate[6] + 1
  end;
  proc22_19(data29.bnd343, 0)
end;
