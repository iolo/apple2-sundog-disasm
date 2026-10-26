{ game_20 procedure2, $0000..$001E, attributes $002A.
  Both input calls execute before the timeout is tested. }
procedure wait_exchange_buttons;
var
  wait_count, input0, input1: integer;
begin
  wait_count := 2000;
  repeat
    wait_count := wait_count - 1;
    input0 := poll_input(0);
    input1 := poll_input(1)
  until odd(input0) or odd(input1) or (wait_count <= 0)
end;
