{ game_21 procedure31, $15B0..$1673, attributes $1682.
  Six XOR rectangle steps. The delay path retains its45-iteration empty loop;
  the sound path preserves sign and argument order on the two directions. }
procedure proc21_31(xpos, ypos: integer; expanding, quiet: boolean);
var
  tick, step, leftcol, rightcol, top, bottom: integer;
begin
  proc22_37(42, xpos, 231);
  proc22_37(30, ypos, 161);
  xpos := xpos div 7;
  if expanding then
  begin
    leftcol := xpos - 1;
    rightcol := xpos + 1;
    top := ypos - 5;
    bottom := ypos + 5
  end
  else
  begin
    leftcol := xpos - 6;
    rightcol := xpos + 6;
    top := ypos - 30;
    bottom := ypos + 30
  end;
  step := 1;
  while step <= 6 do
  begin
    proc23_4(leftcol, rightcol, top, bottom);
    if expanding then
    begin
      leftcol := leftcol - 1;
      rightcol := rightcol + 1;
      top := top - 5;
      bottom := bottom + 5
    end
    else
    begin
      leftcol := leftcol + 1;
      rightcol := rightcol - 1;
      top := top + 5;
      bottom := bottom - 5
    end;
    if quiet then
    begin
      tick := 1;
      while tick <= 45 do tick := tick + 1
    end
    else if expanding then proc22_4(4, (8 - step) * 34, 8, -8, 0, 1, 0)
    else proc22_4(4, (step + 1) * 34, 8, 8, 0, 1, 0);
    step := step + 1
  end
end;
