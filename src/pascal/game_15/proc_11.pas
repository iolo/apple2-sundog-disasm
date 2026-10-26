{ game_15 procedure11, $04FE..$06DD, attributes $06EC.
  The two early paths skip loading and table updates and join at $066E.
  Do not initialize action1 or flag10 on those paths: the listing does not.
  Original local3 is unused; only row1 and column2 are retained. }
procedure proc15_11;
var
  row: integer;
  column: integer;
begin
  g15.words[11] := ord(data29.flags82[g15.words[13]]);
  if (data29.nibbles45[1] = 8) and (8 <= g15.words[1]) and (g15.words[1] <= 13)
  then
  begin
    g15.words[6] := 7 * 16 - 3;
    if g15.words[1] <= 10 then g15.words[5] := 8 * 7 + 7
    else g15.words[5] := 8 * 17 + 7;
    data29.words[40] := g15.words[6];
    data29.bytes[80] := g15.words[5];
    g15.words[4] := g15.words[1]
  end
  else if (data29.nibbles45[1] = 8) or (data29.nibbles45[1] = 7) then
  begin
    g15.words[6] := data29.words[40];
    g15.words[5] := data29.bytes[80];
    g15.words[4] := g15.words[1]
  end
  else
  begin
    g15.target26.word := 6144;
    g15.target26.text^ := g15.text18;
    g15.words[7] := 3904;
    proc15_8;
    g15.words[10] := ord(g15.target26.text^ <> g15.text18);
    proc22_53(g15.words[7], 1, data29.words[30] + 2, true);
    proc15_9;
    column := 6 + 3;
    row := 12;
    g15.words[4] := 0;
    case data29.nibbles45[1] of
      0: begin
        column := 6;
        row := 12;
        g15.words[4] := 1
      end;
      3,4: if not data29.flags45[13] then
           begin
             column := 14;
             row := 14;
             g15.words[4] := 3;
             proc15_10;
             data29.pos228 := data29.pos72
           end
           else
           begin
             g15.words[6] := 7 * 8 - 2;
             g15.words[5] := 8 * 14 + 6;
             column := 0;
             row := 0;
             g15.words[4] := 4
           end;
      11: begin
        g15.words[6] := data29.words[40];
        g15.words[5] := data29.bytes[80];
        g15.words[4] := 0;
        column := 0;
        row := 0
      end
    end;
    if column + row > 0 then
    begin
      g15.words[6] := column * 7;
      g15.words[5] := row * 8 + 7
    end;
    data29.words[40] := g15.words[6];
    data29.bytes[80] := g15.words[5]
  end;
  { $066E: common tail, including both early paths. }
  if odd(data29.words[347]) then
  begin
    if data29.bytes[118] = 0 then data29.nibbles45[2] := 12
    else data29.nibbles45[2] := 10
  end;
  data29.words[351] := 1;
  data29.words[353] := 15;
  data29.flags45[13] := true;
  g15.words[9] := 12;
  g15.words[8] := 13;
  proc22_19(data29.bounds7, 0);
  proc15_5;
  data29.words[2] := 8;
  g15.words[12] := 0;
  proc22_18(g15.bounds14, data29.words[10], data29.words[9] - 7,
            data29.words[8], data29.words[7] - 8);
  proc22_42(g15.words[3], g15.words[2], data29.words[298], g15.bounds14)
end;
