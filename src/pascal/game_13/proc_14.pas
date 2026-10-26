{ game_13 procedure14, $06BE..$07EA, attributes $07FA; nested in13.
  Twelve system markers; the unused VAR parameter still occupies slot1.
  Capture each row pointer before drawing, retain the loop bound and all
  intervening mode/position calls. Every row adds a selection entry. }
procedure proc13_14(var unusedloc: g19loc);
var
  radius: integer; {2}
  unused3: integer;
  index: integer;  {4}
  unused5: array[5..8] of integer;
  ypos: integer;   {9}
  xpos: integer;   {10}
  unused11: integer;
  last: integer;   {12}
  row: g13rowptr;  {13}
begin
  proc25_2;
  if odd(redraw) then
  begin
    proc22_19(data29.bnd343, 8);
    proc22_13(0)
  end;
  index := 1;
  last := 12;
  while index <= last do
  begin
    row.word := data29.words[23] + 20 * (index - 1);
    xpos := row.sysrow^.nibbles8[0] * 10 + 10;
    ypos := proc22_30(row.sysrow^.nibbles8[1], 3) + 8;
    radius := 5 - proc22_31(row.sysrow^.nibbles8[2], 1);
    if odd(redraw) then
    begin
      proc22_13(1);
      proc24_2(radius, data29.words[346] + xpos, data29.words[344] + ypos)
    end;
    if ((index = data29.loc73.low4) and odd(redraw)) or
       (index = data29.words[221]) then
    begin
      radius := radius + 4;
      proc22_13(0);
      proc22_12(data29.words[346] + xpos - radius,
                data29.words[344] + ypos - radius);
      if index = data29.words[221] then
      begin
        if data29.flags82[0] then proc22_13(9) else proc22_13(8)
      end
      else proc22_13(10);
      proc22_12(data29.words[346] + xpos - radius,
                data29.words[344] + ypos + radius);
      proc22_12(data29.words[346] + xpos + radius,
                data29.words[344] + ypos + radius);
      proc22_12(data29.words[346] + xpos + radius,
                data29.words[344] + ypos - radius);
      proc22_12(data29.words[346] + xpos - radius,
                data29.words[344] + ypos - radius)
    end;
    proc22_13(0);
    proc25_4(index, data29.words[298], xpos - 3, ypos + 3);
    index := index + 1
  end
end;
