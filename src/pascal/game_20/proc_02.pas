{ game_20 procedure2, $0000..$001E, attributes $002A.
  Both input calls execute before the timeout is tested. }
procedure proc20_2;
var
  count, input0, input1: integer;
begin
  count := 2000;
  repeat
    count := count - 1;
    input0 := proc22_2(0);
    input1 := proc22_2(1)
  until odd(input0) or odd(input1) or (count <= 0)
end;
