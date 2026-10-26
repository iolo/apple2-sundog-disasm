{ library_27 procedure13, $044E..$0614, attributes $0622.
  Mode is an integer: the first branch uses its low bit; later tests use full
  equality with0/1/2. Keep the apparently redundant position calls. }
procedure proc27_13(mode: integer);
var
  secondpos: integer;
  firstpos: integer;
  offset: integer;
  lastcol: integer;
  column: integer;
  row: integer;
  fillmode: integer;
begin
  if odd(mode) then fillmode := 9 else fillmode := 10;
  if mode = 0 then offset := 53 else offset := 37;
  proc22_11(1);
  row := 0;
  while row <= 3 do
  begin
    secondpos := (data31.words[11] + 8 * row) + 26;
    if row < 2 then lastcol := 1 else lastcol := 2;
    column := 0;
    while column <= lastcol do
    begin
      firstpos := (data31.words[12] + 7 * column) + 2;
      proc22_12(firstpos, secondpos);
      proc22_9((27 + column) + 32 * row);
      column := column + 1
    end;
    row := row + 1
  end;
  proc22_12(data31.words[12] + offset, data31.words[11]);
  proc22_13(11);
  proc22_12(data31.words[12] + offset, data31.words[11] + 83);
  proc22_12(data31.words[12], data31.words[11] + 83);
  proc22_12(data31.words[12] + 138, data31.words[11] + 83);
  proc22_13(0);
  proc22_18(data31.bounds6, data31.words[12] + 3, data31.words[12] + 137,
              data31.words[11] + 84, data31.words[11] + 93);
  proc22_18(data31.bounds2, data31.words[12] + 4, data31.words[12] + 135,
              data31.words[11] + 2, data31.words[11] + 80);
  proc22_23(5632, data31.words[1]);
  data31.words[16] := 0;
  proc27_5(2, 9, 7);
  if mode = 0 then
  begin
    proc27_5(6, 41, 51);
    proc27_5(4, 41, 71);
    proc27_5(1, 41, 7);
    proc27_5(5, 41, 31);
    proc27_5(0, 4, 34);
    data31.words[13] := data31.words[16];
    with data31.items[data31.words[13]] do
    begin
      proc22_12(data31.words[12] + firstoff,
                  (data31.words[11] + secondoff) + 7);
      proc22_9(43)
    end
  end
  else if mode = 1 then proc27_5(5, 25, 7)
  else if mode = 2 then proc27_5(3, 25, 7);
  proc27_5(0, 19, 27);
  data31.words[14] := data31.words[16];
  with data31.items[data31.words[14]] do
  begin
    proc22_12(data31.words[12] + firstoff,
                (data31.words[11] + secondoff) + 7);
    proc22_9(43)
  end;
  data31.words[15] := data31.words[14] + 4;
  proc27_15(19, 45, 0);
  proc27_15(3, 48, 1);
  proc27_15(3, 64, 2);
  proc27_15(19, 64, 3);
  data31.words[10] := data31.words[16];
  proc22_14(data31.words[12] + offset, data31.words[12] + 137,
              data31.words[11] + 1, data31.words[11] + 82);
  proc22_7(fillmode)
end;
