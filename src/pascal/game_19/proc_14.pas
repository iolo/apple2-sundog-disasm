{ game_19 procedure14, $070E..$0785, attributes $078E; nested in12.
  Parent22/23/24 hold elapsed/distance/work; grandparent13 is the rate. }
procedure proc19_14(level, leftidx, rightidx: integer);
var
  delaybase, randomv: integer;
begin
  distance := proc19_11(level, leftidx, rightidx);
  work := g19.words[13] * distance;
  if level = 1 then
  begin
    work := proc22_30(work, 1);
    elapsed := 15
  end
  else if level = 2 then elapsed := distance
  else if level = 3 then
  begin
    work := proc22_30(work, 6);
    delaybase := (distance + 5) * 60;
    randomv := proc22_3;
    elapsed := delaybase + randomv mod 60
  end;
  eta := data29.clock42;
  proc22_26(eta, elapsed);
  proc28_4(cost, 0, work)
end;
