{ utility_disk1:2 $1838..$1853, attributes$1860, no parameters/locals.
  Error display waits only for input1, testing its low bit. Original runtime
  error dispatch must bind this to procedure2. IORESULT is checked explicitly. }
(*$I-*)
procedure util1_2;
begin
  proc22_19(data29.bounds7, 0);
  proc22_12(10, 10);
  proc22_39(ioresult, 3, false);
  repeat until odd(proc22_2(1))
end;
(*$I+*)
