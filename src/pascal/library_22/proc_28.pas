{ library_22 procedure28, $0362..$0394, attributes $039E.
  Copies all four bytes before mode/drawing calls; leaves mode3 selected. }
procedure proc22_28(stamp: clock4);
(*$include src/pascal/library_22/proc_59.pas*)
begin
  proc22_11(3);
  proc22_9(48 + (stamp.day div 100) mod 10);
  proc22_59(stamp.day mod 100);
  proc22_9(126);
  proc22_59(stamp.hour);
  proc22_9(58);
  proc22_59(stamp.minute)
end;
