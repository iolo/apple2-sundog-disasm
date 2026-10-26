{ game_21 procedure40, $1B9C..$1DF0, attributes $1DFC.
  Retain map-byte write then modulo write through arg2, low-bit counter gate,
  cursor erase/retry/redraw order, and conditional second random call.
  The original48-byte local frame is retained; unused slot5 holds randomv. }
procedure proc21_40;
var
  deltay: integer;       {1}
  deltax: integer;
  oldy: integer;
  oldx: integer;
  randomv: integer;
  unused6: integer;
  ticks: integer;        {7}
  foey: integer;
  foex: integer;
  cursory: integer;
  cursorx: integer;
  heroy: integer;
  herox: integer;        {13}
  top: integer;
  left: integer;
  viewy: integer;
  viewx: integer;
  foeglyph: integer;
  mask: integer;
  heroglyph: integer;    {20}
  every: boolean;
  unused22: integer;
  unused23: integer;
  caught: boolean;       {24}
begin
  arg2 := g21.map55.rows^[(arg5 + (g21.words[25] - 3) div g21.words[21]) mod 24]
                        [(arg6 + (g21.words[26] + 3) div 28) mod 40];
  arg2 := arg2 mod 16;
  if arg2 < 2 then exit(proc21_40);
  viewx := g21.words[26] div 7 - 10;
  proc22_37(0, viewx, 20);
  viewy := g21.words[25] - 48;
  proc22_37(0, viewy, 96);
  proc22_16(viewy, viewx);
  proc22_15(2);
  left := g21.words[26] - 40;
  proc22_37(10, left, 199);
  top := g21.words[25] - 30;
  proc22_37(10, top, 131);
  proc22_14(left, left + 80, top, top + 60);
  proc22_7(11);
  proc22_14(left + 2, left + 78, top + 1, top + 59);
  proc22_7(8);
  proc22_42(cursorx, cursory, data29.words[298], g21.area62);
  herox := left + 37;
  heroy := top + 33;
  foex := herox;
  foey := heroy;
  randomv := proc22_3;
  case randomv mod 4 of
    0: foex := left + 3;
    1: foey := top + 10;
    2: foex := left + 70;
    3: foey := top + 55
  end;
  heroglyph := 22;
  mask := 24;
  foeglyph := 23;
  ticks := 32767;
  proc22_11(1);
  proc22_12(herox, heroy);
  proc22_9(heroglyph);
  proc22_12(foex, foey);
  proc22_9(foeglyph);
  data29.words[2] := 8;
  caught := false;
  randomv := proc22_3;
  every := randomv mod 3 = 0;
  repeat
    proc22_43(cursorx, cursory);
    if odd(proc22_2(4)) then
      proc22_22(heroglyph, mask, proc22_34(cursorx - herox),
                  proc22_34(cursory - heroy), herox, heroy);
    ticks := ticks - 1;
    if odd(ticks) or every then
    begin
      oldx := foex;
      oldy := foey;
      deltax := herox - foex;
      deltay := heroy - foey;
      proc22_22(foeglyph, mask, proc22_34(deltax), proc22_34(deltay), foex, foey);
      if (oldx = foex) and (oldy = foey) then
      begin
        proc22_41(cursorx, cursory);
        proc22_22(foeglyph, mask, proc22_34(deltax), proc22_34(deltay), foex, foey);
        if (oldx = foex) and (oldy = foey) then caught := true;
        proc22_41(cursorx, cursory)
      end
    end
  until (herox < left + 3) or (herox > left + 71) or
        (heroy < top + 9) or (heroy > top + 57) or caught;
  proc22_41(cursorx, cursory);
  proc22_15(0);
  data29.words[2] := 9;
  if caught then
  begin
    data29.nibbles45[2] := 5;
    data29.nibbles45[1] := 3;
    data29.words[292] := 4 + 3 * proc22_34((foex - herox) div 3) +
                                  proc22_34((foey - heroy) div 3);
    randomv := proc22_3;
    if (randomv mod 16 > g21.words[61]) and (arg2 < 12) then herox := 16
    else
    begin
      randomv := proc22_3;
      if randomv mod 3 = 0 then herox := 22 else herox := 18
    end;
    data29.words[217] := herox;
    arg2 := 255
  end
end;
