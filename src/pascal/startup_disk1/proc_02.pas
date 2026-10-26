{ startup_disk1 procedure2, $0000..$0012, attributes$001E.
  Display IORESULT then spin forever. Ordinary flow cannot reach RNP.
  Runtime error dispatch must bind this body to original procedure2. Its
  original exit attribute targets RNP at$0012; the reference compiler instead
  points its exit attribute at the spin, so runtime EXIT binding is separate. }
(*$I-*)
procedure boot1_2;
begin
  proc22_6;
  proc22_12(0, 10);
  proc22_39(ioresult, 3, false);
  repeat until false
end;
(*$I+*)
