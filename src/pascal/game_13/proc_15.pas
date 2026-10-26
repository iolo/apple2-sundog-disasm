{ game_13 procedure15, $07FC..$09F2, attributes $0A00; nested in13.
  System planet range is written into grandparent12 slots8(start)/7(end).
  Preserve both loops, the captured planet row and all drawing mode changes.
  The one-word row temporary15 also supplies raw system-row views before
  the planet loop; its extra private assignments have no external observer. }
procedure proc13_15(var sysloc: g19loc);
var
  index: integer;  {2}
  planet: integer; {3}
  systemid: integer; {4}
  yoffset: integer; {5}
  xoffset: integer; {6}
  ycenter: integer; {7}
  xcenter: integer; {8}
  heading: integer; {9}
  height: integer;  {10}
  ypos: integer;   {11}
  xpos: integer;   {12}
  same: boolean;   {13}
  last: integer;   {14}
  row: g13rowptr;  {15}
begin
  proc25_2;
  systemid := sysloc.fields.system;
  if odd(redraw) then
  begin
    proc22_19(data29.bnd343, 8);
    proc22_13(0);
    proc22_11(0)
  end;
  xcenter := proc22_31(data29.words[345] - data29.words[346], 1);
  ycenter := proc22_31(data29.words[343] - data29.words[344], 1);
  same := data29.loc73.low4 = systemid;
  if odd(redraw) then
  begin
    proc22_12(data29.words[346] + xcenter - 3,
              data29.words[344] + ycenter + 3);
    proc22_9(0)
  end;
  row.word := data29.words[23] + 20 * (systemid - 1);
  mapstate[8] := row.sysrow^.bits5.mid5;
  row.word := data29.words[23] + 20 * (systemid - 1);
  mapstate[7] := mapstate[8] + row.sysrow^.bits5.low2 - 1;
  index := 1;
  planet := mapstate[8];
  last := mapstate[7];
  while planet <= last do
  begin
    row.word := data29.words[24] + 16 * (planet - 1);
    proc24_4(row.planetrow^.coords6.low, row.planetrow^.coords6.high,
              xpos, ypos);
    xpos := xcenter + xpos - 3;
    ypos := ycenter + ypos + 3;
    if odd(redraw) then
    begin
      proc22_13(1);
      proc24_2(row.planetrow^.coords6.high,
                data29.words[346] + xcenter, data29.words[344] + ycenter);
      proc22_13(0);
      proc22_11(0);
      proc22_12(data29.words[346] + xpos, data29.words[344] + ypos);
      proc22_9(1)
    end;
    proc25_4(index, 1, xpos, ypos);
    index := index + 1;
    planet := planet + 1
  end;
  height := 43;
  heading := 0;
  proc22_11(1);
  index := 1;
  last := 16;
  while index <= last do
  begin
    proc24_4(heading, height, xoffset, yoffset);
    if odd(redraw) then
    begin
      proc22_12(data29.words[346] + xcenter + xoffset - 3,
                data29.words[344] + ycenter + yoffset + 3);
      proc22_9(43)
    end;
    proc25_4(heading, 43, xcenter + xoffset - 3, ycenter + yoffset + 3);
    heading := heading + 16;
    index := index + 1
  end;
  if same and odd(redraw) then
  begin
    proc24_4(data29.pos72.fields.w0low, data29.pos72.fields.w0high,
              xpos, ypos);
    xpos := xcenter + xpos;
    ypos := ycenter + ypos;
    proc22_12(data29.words[346] + xpos - 3, data29.words[344] + ypos + 3);
    proc22_11(1);
    proc22_9(data29.words[294]);
    proc22_12(data29.words[346] + xpos - 3, data29.words[344] + ypos + 3);
    if data29.loc73.mid5 > 0 then proc22_9(1)
    else if (data29.pos72.fields.w0high = 43) and
            (data29.pos72.fields.w0low mod 16 = 0) then proc22_9(43)
  end;
  proc22_13(0);
  proc22_11(0)
end;
