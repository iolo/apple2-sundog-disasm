{ game_12 procedure4, $006A..$0114, attributes $0124; nested in1.
  Clear even without a target; draw six glyphs in two rows, toggling the
  buffer before/after, then establish parent bounds37 and draw the hull bar. }
procedure proc12_4;
var
  xpos: integer; {1}
  glyph: integer; {2}
  column: integer; {3}
  row: integer; {4}
  lastrow: integer; {5}
  lastcol: integer; {6}
begin
  proc22_44;
  if odd(g12.words[31]) then
  begin
    proc22_46(1, 2);
    proc22_48('ID:');
    proc22_46(1, 5);
    proc22_48('Target hull:');
    proc12_2;
    glyph := 80 + 3 * data29.words[214];
    proc22_11(0);
    row := 0;
    lastrow := 1;
    while row <= lastrow do
    begin
      proc22_46(15, 1 + 2 * row);
      xpos := data29.words[19];
      column := 0;
      lastcol := 2;
      while column <= lastcol do
      begin
        proc22_12(xpos, data29.words[18]);
        proc22_9(glyph);
        xpos := xpos + 7;
        glyph := glyph + 1;
        column := column + 1
      end;
      glyph := glyph + 29;
      row := row + 1
    end;
    proc12_2;
    proc22_46(0, 8);
    proc22_18(g12.hull37, data29.words[19] + 10, data29.words[19] + 96,
                data29.words[18] - 8, data29.words[18]);
    proc12_3
  end
end;
