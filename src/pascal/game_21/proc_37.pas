{ game_21 procedure37, $190C..$197D, attributes $198A.
  Subtract from the two base1000 words using the original one-borrow rule.
  On failure, both input calls run even on the last timeout iteration. }
function proc21_37(cost: integer): boolean;
var
  ticks: integer;
  expired: boolean;
  input0: integer;
  input1: integer;
begin
  if (data29.words[46] > 0) or (data29.words[47] >= cost) then
  begin
    proc21_37 := true;
    if data29.words[47] >= cost then
      data29.words[47] := data29.words[47] - cost
    else
    begin
      data29.words[46] := data29.words[46] - 1;
      data29.words[47] := 1000 + data29.words[47] - cost
    end
  end
  else
  begin
    proc21_37 := false;
    proc22_48('||Insufficient funds');
    ticks := 1000;
    repeat
      ticks := ticks - 1;
      expired := ticks = 0;
      input0 := proc22_2(0);
      input1 := proc22_2(1)
    until expired or odd(input0) or odd(input1)
  end
end;
