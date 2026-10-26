{ Both library26 variants: procedure16, $007E..$01AC, attributes $01BE;
  nested in13. Preserve animation/sound calls and the two independent flag
  updates: the second can clear the flag set by the first. }
procedure proc26_16;
var
  index: integer; {1}
  ticks: integer; {2}
  tone: integer; {3}
  column: integer; {4}
  x: integer; {5}
  phase: integer; {6}
  sprite: integer; {7}
  unused: integer; {8}
  restore: integer; {9}
  moving: integer; {10}
  limit: integer; {11}
begin
  index := 0;
  limit := 13;
  while index <= limit do
  begin
    proc26_9(index * 2 * 7, 44 - 12, 170);
    proc26_9((index * 2 + 1) * 7, 44 - 12, 213);
    index := index + 1
  end;
  proc26_9(28 * 7, 44 - 12, 170);
  proc26_9(29 * 7, 44 - 12, 0);
  proc26_10(left, right, firsty, lasty, buffer);
  sprite := 0;
  limit := 5;
  while sprite <= limit do
  begin
    phase := 0;
    x := positions[sprite].second;
    column := x + 21;
    tone := 0;
    ticks := 0;
    moving := 1;
    restore := 0;
    unused := 0;
    repeat
      tone := tone + 1;
      proc22_4(1, 10 + (7 - sprite) * 30 - tone * 2, 10, 0, 0, 1, 0);
      if odd(moving) or (phase < 8) then
      begin
        if phase = 8 then proc26_11(sprite, 7, x, 44)
        else proc26_11(sprite, phase, x, 44);
        if x > positions[sprite].first then x := x - 14
        else moving := 0
      end;
      if odd(restore) then
      begin
        proc26_12(left, right, firsty, lasty, buffer, column);
        column := column - 7
      end;
      if x = positions[sprite].second - 28 then restore := 1;
      if column = positions[sprite].first + 21 then restore := 0;
      ticks := ticks + 1;
      if (phase < 8) and (ticks = 2) then
      begin
        ticks := 0;
        phase := phase + 1
      end
    until (column = positions[sprite].first + 21) and (phase = 8);
    sprite := sprite + 1
  end
end;
