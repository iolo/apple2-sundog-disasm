{ utility_disk1:2 $1838..$1853, attributes$1860, no parameters/locals.
  Error display waits only for input1, testing its low bit. Original runtime
  error dispatch must bind this to procedure2. IORESULT is checked explicitly. }
(*$I-*)
procedure utility_error_prompt;
begin
  apply_bounds(data29.bounds7, 0);
  move_pen(10, 10);
  draw_integer(ioresult, 3, false);
  repeat until odd(poll_input(1))
end;
(*$I+*)
