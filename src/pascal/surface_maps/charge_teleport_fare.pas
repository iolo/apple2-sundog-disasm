{ game_21 procedure37, $190C..$197D, attributes $198A.
  Subtract from the two base1000 words using the original one-borrow rule.
  On failure, both input calls run even on the last timeout iteration. }
function charge_teleport_fare(cost: integer): boolean;
var
  wait_count: integer;
  timed_out: boolean;
  input0: integer;
  input1: integer;
begin
  if (data29.words[46] > 0) or (data29.words[47] >= cost) then
  begin
    charge_teleport_fare := true;
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
    charge_teleport_fare := false;
    write_wrapped_text('||Insufficient funds');
    wait_count := 1000;
    repeat
      wait_count := wait_count - 1;
      timed_out := wait_count = 0;
      input0 := poll_input(0);
      input1 := poll_input(1)
    until timed_out or odd(input0) or odd(input1)
  end
end;
