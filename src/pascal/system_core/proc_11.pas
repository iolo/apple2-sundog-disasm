{ system_core0:11 $0292..$0296, attributes$02A0. File pointer3,
  result1/2; no locals; RBP1. Return the full flag word at file offset1.
  No IO, masking, or normalization to Boolean is present in the listing. }
function sys0_11(var f: sysfile): integer;
begin
  sys0_11 := f.words[1]
end;
