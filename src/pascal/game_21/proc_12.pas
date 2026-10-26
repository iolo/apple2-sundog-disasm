{ game_21 procedure12, $03C4..$0668, attributes $0678.
  Preserve full/axis-only probe order, one-pixel retry after a failed doubled
  step, low-bit flags, horizontal edge priority, and explicit self EXIT after
  leaving a city. Slots1..15 retain the original30-byte local frame. }
procedure proc21_12;
var
  radiusy: integer;
  radiusx: integer;
  nexty: integer;
  nextx: integer;
  stepy: integer;
  stepx: integer;
  tries: integer;
  unused8: integer;
  glyphidx: integer;
  oldy: integer;
  oldx: integer;
  deltay: integer;
  deltax: integer;
  probe: integer;
  blocked: boolean;
begin
  if odd(g21.words[33]) then
  begin
    stepx := proc22_34(proc22_31(g21.words[19] - 3 - g21.words[26], 3));
    stepy := proc22_34(proc22_31(g21.words[18] + 3 - g21.words[25], 3))
  end
  else
  begin
    stepx := proc22_34(g21.words[19] + 7 - (g21.words[19] + 7) mod 14 -
                         3 - g21.words[26]);
    stepy := proc22_34(proc22_32(g21.words[18] + 8, -16) + 3 - g21.words[25])
  end;
  if (stepx <> 0) or (stepy <> 0) then
  begin
    if odd(g21.words[37]) then
    begin
      glyphidx := 5 + 3 * stepx + stepy;
      oldx := g21.words[26];
      oldy := g21.words[25]
    end
    else probe := g21.words[29];
    if data29.flags45[13] or (g21.words[28] <> stepx) or
       (g21.words[27] <> stepy) then
    begin
      tries := 1;
      deltax := stepx;
      deltay := stepy;
      g21.words[28] := deltax;
      g21.words[27] := deltay
    end
    else
    begin
      tries := 2;
      deltax := stepx + stepx;
      deltay := stepy + stepy
    end;
    proc21_5;
    repeat
      blocked := false;
      nextx := g21.words[26] + deltax;
      nexty := g21.words[25] + deltay;
      if odd(g21.words[37]) then probe := g21.glyph47[glyphidx];
      if not odd(proc21_10(probe, nextx, nexty)) then
      begin
        g21.words[26] := nextx;
        g21.words[25] := nexty
      end
      else
      begin
        if odd(g21.words[37]) then probe := g21.glyph47[5 + 3 * stepx];
        if not odd(proc21_10(probe, nextx, g21.words[25])) then
          g21.words[26] := nextx
        else
        begin
          if odd(g21.words[37]) then probe := g21.glyph47[5 + stepy];
          if not odd(proc21_10(probe, g21.words[26], nexty)) then
            g21.words[25] := nexty
          else
          begin
            blocked := true;
            deltax := stepx;
            deltay := stepy;
            tries := tries - 1
          end
        end
      end
    until not blocked or (tries <= 0);
    if odd(g21.words[37]) and
       ((g21.words[26] <> oldx) or (g21.words[25] <> oldy)) then
    begin
      glyphidx := 5 + 3 * proc22_34(g21.words[26] - oldx) +
                         proc22_34(g21.words[25] - oldy);
      g21.words[30] := g21.glyph39[glyphidx];
      g21.words[31] := g21.words[30];
      g21.words[29] := g21.glyph47[glyphidx]
    end;
    proc21_5;
    arg4 := (g21.words[26] + 3) div 7;
    arg3 := (g21.words[25] - 3) div 8;
    deltax := 0;
    deltay := 0;
    if arg4 < 7 then deltax := -1
    else if arg4 > 32 then deltax := 1
    else if arg3 < 7 then deltay := -1
    else if arg3 > 16 then deltay := 1;
    if (deltax <> 0) or (deltay <> 0) then
    begin
      if data29.nibbles45[2] = 3 then
      begin
        radiusx := data29.bytes[545];
        radiusy := (radiusx + 1) div 2;
        oldx := arg6 + deltax;
        oldy := arg5 + deltay;
        if (oldx < 12 - radiusx) or (oldx > 17 + radiusx) or
           (oldy < 7 - radiusy) or (oldy > 11 + radiusy) then
        begin
          proc21_11(oldx, oldy, radiusx, radiusy);
          exit(proc21_12)
        end
      end;
      arg6 := (arg6 + 40 + deltax) mod 40;
      arg5 := (arg5 + 24 + deltay) mod 24;
      proc21_9;
      g21.words[25] := (g21.words[25] + 192 - g21.words[21] * deltay) mod 192;
      g21.words[26] := (g21.words[26] + 280 - 28 * deltax) mod 280;
      proc21_5;
      proc21_8;
      arg4 := (g21.words[26] + 3) div 7;
      arg3 := (g21.words[25] - 3) div 8;
      proc22_42(g21.words[19], g21.words[18], data29.words[298], g21.area62)
    end
  end
end;
