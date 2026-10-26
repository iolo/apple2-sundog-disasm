{ game_14 procedure4, $02B0..$0345, attributes $0354.
  Explicit inclusive row/column loops retain captured limits and13 local words. }
procedure proc14_4;
var
  base: integer;
  startrow: integer;
  spacing: integer;
  origin: integer;
  columns: integer;
  code: integer;
  y: integer;
  x: integer;
  offset: integer;
  row: integer;
  column: integer;
  lastrow: integer;
  lastcol: integer;
begin
  if odd(g14.words[103]) then
  begin
    startrow := 2;
    base := g14.words[4] - 10
  end
  else
  begin
    startrow := 0;
    base := g14.words[4]
  end;
  if odd(g14.words[104]) then
  begin
    columns := 4;
    origin := 50;
    spacing := 18
  end
  else
  begin
    columns := 3;
    origin := 82;
    spacing := 14
  end;
  data31.words[16] := data31.words[15];
  row := startrow;
  lastrow := 3;
  while row <= lastrow do
  begin
    y := 22 + 16 * row;
    column := 0;
    lastcol := columns;
    while column <= lastcol do
    begin
      x := origin + spacing * column;
      offset := (5 * row + column) + base;
      code := data29.bytes[178 + offset];
      proc27_5(code, x, y);
      column := column + 1
    end;
    row := row + 1
  end;
  proc22_11(0);
  proc27_6(data31.words[15]);
  proc22_11(1);
  proc22_19(data29.bounds11, 0)
end;
