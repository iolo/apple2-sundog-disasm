{ game_15 procedure13, $070C..$07BE, attributes $07CA.
  Six locals retain slots1..6. Try doubled signed steps, clipped to distance;
  retry with unit steps only when BOTH coordinates remain unchanged.
  Cursor calls bracket both attempts; arithmetic remains signed16-bit. }
procedure proc15_13;
var
  dy: integer;
  dx: integer;
  oldy: integer;
  oldx: integer;
  stepy: integer;
  stepx: integer;
begin
  dx := (g15.words[3] - 3) - g15.words[6];
  dy := (g15.words[2] + 3) - g15.words[5];
  if (dx <> 0) or (dy <> 0) then
  begin
    stepx := proc22_34(dx);
    stepx := stepx + stepx;
    if proc22_35(stepx) > proc22_35(dx) then stepx := dx;
    stepy := proc22_34(dy);
    stepy := stepy + stepy;
    if proc22_35(stepy) > proc22_35(dy) then stepy := dy;
    proc22_41(g15.words[3], g15.words[2]);
    oldx := g15.words[6];
    oldy := g15.words[5];
    proc22_22(g15.words[9], g15.words[8], stepx, stepy, g15.words[6], g15.words[5]);
    if (oldx = g15.words[6]) and (oldy = g15.words[5]) then
      proc22_22(g15.words[9], g15.words[8], proc22_34(stepx), proc22_34(stepy),
                g15.words[6], g15.words[5]);
    proc22_41(g15.words[3], g15.words[2])
  end
end;
