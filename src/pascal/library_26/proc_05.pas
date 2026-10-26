{ Both library26 variants: procedure5, $0210..$02BA, attributes $02C6.
  Initial lasty is unspecified. Timeout resets only on cursor movement.
  Keep random and input1 calls unconditional; unused slot12 saves input1
  to prevent Pascal short-circuit evaluation from omitting the poll. }
procedure proc26_5(var choice: integer; step: integer);
var
  lasty: integer; {3}
  lastx: integer; {4}
  item: integer; {5}
  random: integer; {6}
  ybase: integer; {7}
  xbase: integer; {8}
  y: integer; {9}
  x: integer; {10}
  timeout: integer; {11}
  poll: integer; {12}
  input1: integer; {13}
  input0: integer; {14}
begin
  xbase := data29.words[14];
  ybase := data29.words[12];
  proc25_6(data29.bounds11);
  proc22_42(x, y, 1, data29.bounds11);
  input0 := 0;
  input1 := 0;
  item := 0;
  choice := 0;
  lastx := -1;
  repeat
    proc22_43(x, y);
    if (x <> lastx) or (y <> lasty) then
    begin
      lastx := x;
      lasty := y;
      timeout := 2150
    end;
    random := proc22_3;
    if odd(proc22_2(0)) then
    begin
      proc25_7(x - xbase, y - ybase, choice, item);
      if item > 0 then
      begin
        proc22_4(30, 50, 10, 0, 0, 0, 0);
        proc25_8(item, choice, data29.bounds11, input0, input1)
      end
    end
    else timeout := timeout - step;
    poll := proc22_2(1)
  until odd(input0) or odd(poll) or (timeout <= 0);
  if timeout <= 0 then
  begin
    proc25_8(3, choice, data29.bounds11, input0, input1);
    choice := 3
  end;
  proc22_41(x, y)
end;
