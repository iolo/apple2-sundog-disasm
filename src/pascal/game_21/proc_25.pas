{ game_21 procedure25, $0CA0..$0E95, attributes $0EAC.
  The expanding search has no invented bound. Increment/wrap its counter
  before the drawing probe, preserving the original candidate coordinates.
  In the non-city branch for previous mode2, BOTH coordinates read parent15. }
procedure proc21_25;
var
  radius, index, basex, basey: integer;
begin
  if (data29.nibbles45[1] = 7) or (data29.nibbles45[1] = 11) or data29.flags82[28] then
    proc21_13(g21.words[26], g21.words[25], data29.pos36)
  else if (data29.nibbles45[1] <> data29.nibbles45[2]) and (data29.nibbles45[1] <> 2) then
  begin
    g21.words[26] := data29.words[40];
    g21.words[25] := data29.bytes[80]
  end
  else if data29.nibbles45[1] = 2 then
  begin
    if data29.nibbles45[2] = 3 then
    begin
      g21.words[26] := 140 + g21.words[15] + 6 * ((data29.words[292] - 1) div 3 - 1);
      if not data29.flags45[13] then g21.words[26] := g21.words[26] + 3;
      g21.words[25] := 96 + g21.words[14] + 6 * ((data29.words[292] - 1) mod 3 - 1)
    end
    else
    begin
      g21.words[26] := g21.words[15];
      g21.words[25] := g21.words[15]
    end
  end
  else if not data29.flags45[13] and data29.flags45[12] then
  begin
    data29.rec36 := data29.rec228;
    proc21_13(g21.words[26], g21.words[25], data29.pos36);
    if data29.nibbles45[2] = 4 then proc21_5
  end
  else if not data29.flags45[12] and data29.flags45[13] then
  begin
    if data29.nibbles45[2] = 3 then
    begin
      data29.words[2] := 2;
      g21.words[13] := data29.pos228.fields.kind2;
      g21.words[12] := data29.pos228.fields.kind3;
      g21.words[11] := data29.words[232] mod 28;
      g21.words[10] := data29.pos228.fields.w5low mod g21.words[21];
      index := 0;
      radius := 1;
      repeat
        basex := 28 * proc21_2(g21.words[13], arg6, 40) + g21.words[11];
        basey := g21.words[21] * proc21_2(g21.words[12], arg5, 24) + g21.words[10];
        g21.words[26] := basex + radius * (index div 7 - 3);
        g21.words[25] := basey + radius * (index mod 7 - 3);
        index := index + 1;
        if index = 49 then
        begin
          radius := radius + 1;
          index := 0
        end
      until not odd(proc21_10(g21.words[29], g21.words[26], g21.words[25]))
    end
    else
    begin
      proc21_13(g21.words[26], g21.words[25], data29.pos228);
      proc22_11(1);
      proc22_12(g21.words[26], g21.words[25]);
      proc22_9(data29.bytes[507])
    end
  end
  else proc21_13(g21.words[26], g21.words[25], data29.pos36);
  arg4 := (g21.words[26] + 3) div 7;
  arg3 := (g21.words[25] - 3) div 8;
  if data29.flags45[13] or not odd(arg1) then proc21_5;
  data29.words[2] := 9
end;
