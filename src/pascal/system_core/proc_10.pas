{ system_core0:10 $0282..$0286, attributes$0290. File pointer3,
  result1/2; no locals; RBP1. Return the full flag word at file offset2.
  No IO, masking, or normalization to Boolean is present in the listing. }
function sys0_10(var f: sysfile): integer;
begin
  sys0_10 := f.words[2]
end;
